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