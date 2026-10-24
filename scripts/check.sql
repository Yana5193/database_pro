do $$
begin
    raise notice 'x = -5, y = %', calculate_interpolation(-5, get_interpolation_params(-5));
    raise notice 'x = 12, y = %', calculate_interpolation(12, get_interpolation_params(12));
    raise notice 'x = 35, y = %', calculate_interpolation(35, get_interpolation_params(35));
	raise notice 'x = 23, y = %', calculate_interpolation(23, get_interpolation_params(23));
    raise notice 'x = 25, y = %', calculate_interpolation(25, get_interpolation_params(25));
end $$;