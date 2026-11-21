--создание ресурсв время
do $$
begin
	create table dim_time
	(
		id bigint primary key,
        date_start date,
        date_end date,
        month_name text,
        year integer,
        quarter_num integer,
        quarter_name text
    );
end;
$$