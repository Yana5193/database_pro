--валидация
create or replace function validate_params(p meteo_params)
returns text as $$
declare 
	r record;
	v_errors text[] := '{}';
begin
	for r in select param_id, min_val, max_val, error_text from constants loop
        if r.param_id = 1 and (p.station_height < r.min_val or p.station_height > r.max_val) then
            v_errors := array_append(v_errors, r.error_text);
        elsif r.param_id = 2 and (p.temperature < r.min_val or p.temperature > r.max_val) then
            v_errors := array_append(v_errors, r.error_text);
        elsif r.param_id = 3 and (p.pressure < r.min_val or p.pressure > r.max_val) then
            v_errors := array_append(v_errors, r.error_text);
        elsif r.param_id = 4 and (p.wind_direction < r.min_val or p.wind_direction > r.max_val) then
            v_errors := array_append(v_errors, r.error_text);
        elsif r.param_id = 5 and (p.wind_speed < r.min_val or p.wind_speed > r.max_val) then
            v_errors := array_append(v_errors, r.error_text);
        elsif r.param_id = 6 and (p.bullet_drift < r.min_val or p.bullet_drift > r.max_val) then
            v_errors := array_append(v_errors, r.error_text);
        end if;
    end loop;
    if array_length(v_errors, 1) is null then
        return 'Ошибок нет';
    else
        return array_to_string(v_errors, '; ');
    end if;
end;
$$ language plpgsql;

-- расчет ДДЧЧМ
create or replace function calc_data()
returns text as $$
declare
	v_day text;
	v_hour text;
	v_min text;
begin
	v_day:=to_char(current_timestamp,'DD');
	v_hour:=to_char(current_timestamp,'HH24');
	v_min := (to_char(current_timestamp, 'MI')::int / 10)::text;
	return v_day || v_hour || v_min;
end;
$$ language plpgsql;

--расчет ВВВВ
create or replace function calc_vvvv(p_height numeric)
returns text as $$
begin
	return lpad(coalesce(round(p_height)::int, 0)::text, 4, '0');
end;
$$ language plpgsql;

--расчет БББТТ
create or replace function calc_meteo_bbbtt(p_pressure numeric, p_temp numeric)
returns text as $$
declare
    v_dp int;
    v_dt int;
    v_pressure_str text;
    v_temp_str text;
begin
    v_dp := round(p_pressure - 750);
    v_dt := round(p_temp - 16);
    if v_dp >= 0 then
        v_pressure_str := lpad(v_dp::text, 3, '0');
    else
        v_pressure_str := '5' || lpad(abs(v_dp)::text, 2, '0');
    end if;
    if v_dt < 0 then
        v_dt := 0;
    end if;
    v_temp_str := lpad(v_dt::text, 2, '0');
    return v_pressure_str || v_temp_str;
end;
$$ language plpgsql;
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