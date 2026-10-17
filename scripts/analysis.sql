-- 1. Очистка таблиц 
truncate table public.parameters restart identity cascade;
truncate table public.users restart identity cascade;
truncate table public.packs restart identity cascade;

-- 2. Вставка пачек
insert into public.packs (pack_id, pack_number, created_date) values
(1, 'PACK-2026-001', '2026-10-04 06:00:00+03'),
(2, 'PACK-2026-002', '2026-10-04 18:00:00+03');

-- 3. Вставка сотрудников
insert into public.users (user_id, user_name, position_id, pack_id) values
(1, 'Волков И.А.', 1, 1),
(2, 'Лебедева М.С.', 2, 1),
(3, 'Соколов В.П.', 1, 2),
(4, 'Морозова Е.Д.', 2, 2);

-- 4. Вставка замеров
insert into public.parameters (parameter_id, parameter_value, user_id, type_param_id, equipment_type_id) values
-- Пачка 1
(1, '145.0', 1, 1, 1),
(2, '8.5', 1, 2, 2),
(3, '1015.2', 1, 3, 1),
(4, '90', 2, 4, 2),
(5, '2.1', 2, 5, 2),
(6, '8.2', 2, 2, 2),
(7, '1015.5', 2, 3, 1),

-- Пачка 2
(8, '145.0', 3, 1, 1),
(9, '16.3', 3, 2, 2),
(10, '1011.8', 3, 3, 1),
(11, '270', 4, 4, 2),
(12, '5.4', 4, 5, 2),
(13, '16.5', 4, 2, 2),
(14, '1011.5', 4, 3, 1);

--запрос1
select * from public.users as t1
inner join (
    select user_id, cnt_records from (
        select 
            u.user_id, 
            count(p.parameter_id) as cnt_records
        from public.users u
        left join public.parameters p on p.user_id = u.user_id
        group by u.user_id
    ) as t1
    where cnt_records != 5
) as inner_t2 on t1.user_id = inner_t2.user_id;

--запрос 2
select * from public.packs as t1
inner join (
    select pack_id, cnt_records from (
        select 
            pk.pack_id, 
            count(p.parameter_id) as cnt_records
        from public.packs pk
        left join public.users u on u.pack_id = pk.pack_id
        left join public.parameters p on p.user_id = u.user_id
        group by pk.pack_id
    ) as t1
    where cnt_records = 0
) as inner_t2 on t1.pack_id = inner_t2.pack_id;

--запрос 3
select * from public.packs as t1
inner join(
	select pack_id,cnt_params from(
		select
			u.pack_id,
			count(distinct p.type_param_id) as cnt_params
		from public.parameters p
		inner join public.users u on u.user_id = p.user_id
    	group by u.pack_id
)as t1	
 where cnt_params!=5
)as inner_t2 on t1.pack_id=inner_t2.pack_id;

-- запрос 4
select * from public.parameters as t1
inner join(
	select parameter_id from(
		select 
			p.parameter_id,
			p.type_param_id,
			p.parameter_value
		from public.parameters p
		where
			(p.type_param_id = 1 and (p.parameter_value::numeric < 0 or p.parameter_value::numeric > 10000))
            or (p.type_param_id = 2 and (p.parameter_value::numeric < -50 or p.parameter_value::numeric > 50))
            or (p.type_param_id = 3 and (p.parameter_value::numeric < 700 or p.parameter_value::numeric > 800))
            or (p.type_param_id = 4 and (p.parameter_value::numeric < 0 or p.parameter_value::numeric > 360))
            or (p.type_param_id = 5 and (p.parameter_value::numeric < 0 or p.parameter_value::numeric > 60))
            or (p.type_param_id = 6 and (p.parameter_value::numeric < 0 or p.parameter_value::numeric > 5000))
	)as t1
)as inner_t2 on t1.parameter_id = inner_t2.parameter_id;

--запрос 5
select * from public.parameters as t1
inner join (
    select parameter_id from (
        select
            p.parameter_id,
            tp.id,
            um.name as unit_name
        from public.parameters p
        inner join public.type_params tp on tp.id=p.type_param_id
        inner join public.unit_measure um on um.id = tp.unit_measure_id
        where
            (tp.id = 1 and um.name != 'м')
            or (tp.id = 2 and um.name != '°C')
            or (tp.id = 3 and um.name != 'мм рт. ст.')
            or (tp.id = 4 and um.name != '°')
            or (tp.id = 5 and um.name != 'м/с')
            or (tp.id = 6 and um.name != 'м')
    ) as t1
) as inner_t2 on t1.parameter_id =  inner_t2.parameter_id;
