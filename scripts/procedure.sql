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

    --константы 
    c_h_std constant numeric := 750.0;  
    c_wind_vr constant numeric := 40.0;  
    c_wind_dmk constant numeric := 3.0;  
    
    delta_h0 numeric; --отклонение давления
    delta_tv numeric; --вирт поправка
    t0_virtual numeric; --приземная виртуальная
    delta_t0_mp numeric; --отклонение приземной виртуальной температуры
    is_zero boolean := false; --чтобы по много раз не перепроверять,
    --смотрим,примет ли скорость среднего ветра значение 0

    --вспомогательная переменная для поиска в массиве ветра
    n_index integer;

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
    delta_h0 := par_h0 -  c_h_std;

    -- виртуальная поправка
    delta_tv := public.fn_calc_temperature_interpolation(par_t0);

    -- отклонение приземной виртуальной температуры
    t0_virtual:=par_t0 + delta_tv;
    delta_t0_mp:=round(t0_virtual - 15.9);

    -- обнулится ли ветер
    if par_equipment_id = 2 and par_wind_param < c_wind_vr then
        --вр
        is_zero := true;
    elsif par_equipment_id = 1 and par_wind_param < c_wind_dmk then
        --дмк
        is_zero := true;
    end if;

    --определяем значение для поиска в заголовка
     n_index := case 
        when par_equipment_id = 1 then round(par_wind_param)::integer 
        else par_wind_param::integer 
    end;

    --расчет и заполнение таблицы результатов
    insert into calculation_result (height, delta_h0, delta_t0_mp, delta_ty, wind_speed, wind_direction)
    select 
        alt_tbl.height,
        delta_h0,
        delta_t0_mp,
        
        --темпервтурная поправка
        case 
            when delta_t0_mp < 0 then 
                50 + abs(
                    --поправка десятки (для отриц)
                    coalesce(t_neg.row_values[array_position(h_temp.header_values, abs(trunc(delta_t0_mp / 10.0)) * 10)], 0) 
                    +
                    --поправка единицы (для отриц)
                    coalesce(t_neg.row_values[array_position(h_temp.header_values, abs(delta_t0_mp) % 10)], 0)
                )
            else 
                --поправкв десятки полож
                coalesce(t_pos.row_values[array_position(h_temp.header_values, trunc(delta_t0_mp / 10.0)) * 10], 0) 
                +
                --поправка единицы полож
                coalesce(t_pos.row_values[array_position(h_temp.header_values, delta_t0_mp % 10)], 0)
        end,

       --ветровые поправки
        case 
            when is_zero then 0 
            else 
                -- нужно найти поправку скорости ветра по индексу
                coalesce(w_spd.row_values[array_position(h_wind.header_values, n_index)], 0)
        end,

        case 
            when is_zero then 0 
            else 
                --находим поправку направления и прибавляем к исходному
                par_wind_dir + coalesce(w_dir.row_values[array_position(h_wind.header_values, n_index)], 0)
        end

    from calc_correction_heights alt_tbl
    --связывание заголовков и данных темп
    join calc_headers h_temp on h_temp.id = 1
    left join calc_correction t_neg on t_neg.height_id = alt_tbl.id and t_neg.type_id = 9
    left join calc_correction t_pos on t_pos.height_id = alt_tbl.id and t_pos.type_id = 8
    
    --связывание заголовков и данных ветра
    join calc_headers h_wind on h_wind.id = case when par_equipment_id = 2 then 2 else 3 end
    left join calc_correction w_spd on w_spd.height_id = alt_tbl.id and w_spd.type_id = case when par_equipment_id = 2 then 4 else 6 end
    left join calc_correction w_dir on w_dir.height_id = alt_tbl.id and w_dir.type_id = case when par_equipment_id = 2 then 5 else 7 end;
end;
$$;