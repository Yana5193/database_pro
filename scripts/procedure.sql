create or replace procedure public.calculation(
    in par_equipment_id integer,            
    in par_h0 numeric,                      
    in par_t0 numeric,                      
    in par_wind_param numeric, -- Скорость ветра или дальность сноса 
    in par_wind_dir numeric  -- Направление приземного ветрв
)
language plpgsql
as $$
declare
    delta_h0 numeric; --отклонение давления
    delta_tv numeric; --вирт поправка
    t0_virtual numeric; --приземная виртуальная
    delta_t0_mp numeric; --отклонение приземной виртуальной температуры
    tens integer; --десятки
    units integer; --единицы для отклонения температуры
    is_zero boolean := false; --чтобы по много раз не перепроверять,
    --смотрим,примет ли скорость среднего ветра значение 0

    cur_height record; -- чтобы хранить текущую высоту из таблички
    amendments integer[];-- чтобы хранить массив поправок
    n_index integer;-- найти нужное значение в массиве
    delta_ty numeric; -- температурная попавка
    wind_speed numeric;-- поправка на скорость ветра
    wind_direction numeric;-- скорректированное направление ветра
    type_speed integer;-- айди типа поправки для скорости ветра
    type_direction integer;-- айди типа поправки для направления ветра
    header_vals integer[];-- массив заголовков для температуры
    n_index_tens integer;-- индекс для десятков
    n_index_units integer;-- индекс для единиц
begin
    create temp table if not exists calculation_result (
        height numeric,
        delta_h0 numeric,
        delta_t0_mp numeric,
        delta_ty numeric,
        wind_speed numeric,
        wind_direction numeric
    );

    delete from calculation_result;

    -- отклонение наземного давления 
    delta_h0 := par_h0 - 750.0;

    -- виртуальная поправка
    delta_tv := case
        when par_t0 < 0 then 0
        when par_t0 between 0 and 5 then 0.5
        when par_t0 between 10 and 15 then 1
        when par_t0 = 20 then 1.5
        when par_t0 = 25 then 2
        when par_t0 = 30 then 3.5
        when par_t0 = 40 then 4.5
        else 0
    end;

    -- отклонение приземной виртуальной температуры
    t0_virtual:=par_t0 + delta_tv;
    delta_t0_mp:=round(t0_virtual - 15.9);

    -- среднее отклоненик температуры воздуха (десятки и единицы)
    tens:=trunc(delta_t0_mp / 10.0) * 10;
    units:=delta_t0_mp - tens;

    -- обнулится ли ветер
    if par_equipment_id = 2 and par_wind_param < 40 then
        --вр
        is_zero := true;
    elsif par_equipment_id = 1 and par_wind_param < 3 then
        --дмк
        is_zero := true;
    end if;

    -- массив заголовков для температуры 
    select header_values into header_vals
    from public.calc_headers
    where id = 1;

    -- проходимся по высотам
    for cur_height in
        select id, height
        from public.calc_correction_heights
    loop
        delta_ty := 0;

        if delta_t0_mp < 0 then
            select row_values
            into amendments
            from public.calc_correction
            where height_id = cur_height.id
              and type_id = 9;
        else
            select row_values
            into amendments
            from public.calc_correction
            where height_id = cur_height.id
              and type_id = 8;
        end if;

        --поправка для десятков
        if abs(tens) = 0 then
            n_index_tens := 0; 
        else
            n_index_tens := array_position(header_vals, abs(tens));
        end if;

        -- поправка для единиц
        if abs(units) = 0 then
            n_index_units := 0;
        else
            n_index_units := array_position(header_vals, abs(units));
        end if;

        delta_ty := coalesce(amendments[n_index_tens], 0) + coalesce(amendments[n_index_units], 0);

        -- дмк отрица попрака
        if par_equipment_id = 1 and delta_ty < 0 then
            delta_ty := abs(delta_ty)+50;
        end if;

        -- ветровые поправки
        if is_zero then
            wind_speed := 0;
            wind_direction := 0;
        else
            -- типы поправок в зависимочти от темп
            if par_equipment_id = 2 then
                type_speed := 4;
                type_direction := 5;
            else
                type_speed := 6;
                type_direction := 7;
            end if;

            -- поправка скорости ветра
            select row_values
            into amendments
            from public.calc_correction
            where height_id = cur_height.id
              and type_id = type_speed;

            n_index := array_position(
                (select header_values
                 from public.calc_headers
                 where id = case
                     when par_equipment_id = 2 then 2
                     else 3
                 end),
                case
                    when par_equipment_id = 1 then round(par_wind_param)::integer
                    else par_wind_param::integer
                end
            );

            wind_speed := coalesce(amendments[n_index], 0);

            -- поправка направления ветра
            select row_values
            into amendments
            from public.calc_correction
            where height_id = cur_height.id
              and type_id = type_direction;

            wind_direction := par_wind_dir + coalesce(amendments[n_index], 0);
        end if;

        insert into calculation_result (
            height,
            delta_h0,
            delta_t0_mp,
            delta_ty,
            wind_speed,
            wind_direction
        )
        values (
            cur_height.height,
            delta_h0,
            delta_t0_mp,
            delta_ty,
            wind_speed,
            wind_direction
        );
    end loop;
end;
$$;