-- 1. запрос список параметров с ошибкамм
with error_parameters as (
    select 
        pk.pack_number as pack_num,
        eq.equipment_type_name as eq_name,
        tp.name as param_name,
        p.parameter_value as param_val,
        c.error_text as err_text
    from public.parameters p
    join public.users u on p.user_id = u.user_id
    join public.packs pk on u.pack_id = pk.pack_id
    join public.equipment_types eq on p.equipment_type_id = eq.equipment_type_id
    join public.type_params tp on p.type_param_id = tp.id
    join constants c on p.type_param_id = c.param_id
    where p.parameter_value::numeric < c.min_val 
       or p.parameter_value::numeric > c.max_val
)
select 
    pack_num as "№",
    eq_name as "Тип оборудования",
    param_name as "Параметр",
    param_val as "Значение",
    true as "Флаг: Есть ошибка",
    err_text as "Описание ошибки"
from error_parameters;

-- 2. запрос лучший стрелок
with calculated_errors as (
    select 
        u.user_id,
        u.user_name as "ФИО сотрудника",
        count(p.parameter_id) as "Количество ошибок"
    from public.users u
    left join public.parameters p on u.user_id = p.user_id
    left join constants c on p.type_param_id = c.param_id 
      and (p.parameter_value::numeric < c.min_val or p.parameter_value::numeric > c.max_val)
    group by u.user_id, u.user_name
)
select 
    "ФИО сотрудника",
    coalesce("Количество ошибок", 0) as "Количество ошибок"
from calculated_errors
order by "Количество ошибок" asc;

--добавлены данные с ошибкой чтобы проверить запросыы
truncate table public.parameters restart identity cascade;
insert into parameters (parameter_value, user_id, equipment_type_id, type_param_id) values 
('100', 1, 1, 1),
('99', 1, 1, 2),   
('300', 1, 1, 3),  
('00', 1, 1, 4),
('0', 1, 1, 5),
('145.0', 2, 2, 6);