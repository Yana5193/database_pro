do $$
begin
	begin
	drop function if exists get_interpolation_params(numeric) cascade;
	drop function if exists calculate_interpolation(numeric, interpolations_type) cascade;
	drop table if exists calc_temperature_correction cascade;
	drop type if exists public.interpolations_type cascade;
	end;

begin
-- 1.создание польз типа
create type public.interpolations_type as (
    x0 numeric(8,2),
    y0 numeric(8,2),
    x1 numeric(8,2),
    y1 numeric(8,2)
);

-- 2.создание таблицы 
    create table calc_temperature_correction
    (
        temperature numeric(8,2),
        correction numeric(8,2)
    );
    insert into public.calc_temperature_correction(temperature, correction)
    values (0, 0.5), (5, 0.5), (10, 1), (20, 1), (25, 2), (30, 3.5), (40, 4.5);
end;

begin
-- 3.первая функция (определение параметров)
create or replace function get_interpolation_params(par_temperature numeric)
returns interpolations_type as  $func$
declare
    v_result interpolations_type;
begin
    select temperature, correction
    into v_result.x0, v_result.y0
    from calc_temperature_correction
    where temperature <= par_temperature
    order by temperature desc
    limit 1;

    select temperature, correction
    into v_result.x1, v_result.y1
    from calc_temperature_correction
    where temperature >= par_temperature
    order by temperature asc
    limit 1;

    if v_result.x0 is null then
        v_result.x0 := v_result.x1;
        v_result.y0 := v_result.y1;
    end if;
    
    if v_result.x1 is null then
        v_result.x1 := v_result.x0;
        v_result.y1 := v_result.y0;
    end if;

    return v_result;
end;
$func$ language plpgsql;

-- 4.функция 2 (расчет интерполяции) 
create or replace function calculate_interpolation(p_x numeric, p_struct interpolations_type)
returns numeric as  $func$
begin
    if p_struct.x1 = p_struct.x0 then
        return p_struct.y0;
    end if;
    
    return p_struct.y0 + (p_x - p_struct.x0) * (p_struct.y1 - p_struct.y0) / (p_struct.x1 - p_struct.x0);
end;
$func$ language plpgsql;
end;
end $$;
