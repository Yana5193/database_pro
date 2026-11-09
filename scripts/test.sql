do $$
begin
    call public.calculation(
        par_equipment_id:= 1,
        par_h0:=750.0,
        par_t0:=20.0,
        par_wind_param:=5.0,
        par_wind_dir:=180.0
    );
end $$;

select 
    height as "высота",
    delta_h0 as "ΔH0",
    delta_t0_mp as "ΔT0мп",
    delta_ty as "ΔTy",
    wind_speed as "Скорость ветра",
    wind_direction as "Направление ветра"
from calculation_result
order by height;