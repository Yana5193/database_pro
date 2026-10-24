--валидация
create or replace function validate_params(p meteo_params)
returns text as $$
declare 
	v_errors text[] := '{}';
begin
	if p.station_height< -1000 or p.station_height > 10000 then
		v_errors:=array_append(v_errors,'ошибка,неверная высота метеопоста');
	end if;
	if p.temperature<-58 or p.temperature>58 then
		v_errors:=array_append(v_errors,'ошибка,температура вне диапазона');
	end if;
	if p.pressure<500 or p.pressure>900 then
		v_errors:=array_append(v_errors,'ошибка,давление вне диапазона');
	end if;
	if p.wind_direction<0 or p.wind_direction>59 then
		v_errors:=array_append(v_errors,'ошибка,направление ветра должно быть от 0 до 59');
	end if;
	if p.wind_speed<0 or p.wind_speed>15 then
		v_errors:=array_append(v_errors,'ошибка,скорость ветра вне диапазона');
	end if;
	if p. bullet_drift<0 or p.bullet_drift>150 then
		v_errors:=array_append(v_errors,'ошибка,дальность сноса пуль вне диапазона');
	end if;
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