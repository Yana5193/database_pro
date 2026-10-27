-- 1. запрос список параметров с ошибкамм
with raw_parameters as (
    select 
       pk.pack_number as "№",
       eq.equipment_type_name as "Тип оборудования",
       max(case when p.type_param_id = 1 then p.parameter_value::numeric end) as "Высота метеопоста",
       max(case when p.type_param_id = 2 then p.parameter_value::numeric end) as "Температура",
       max(case when p.type_param_id = 3 then p.parameter_value::numeric end) as "Давление",
       max(case when p.type_param_id = 4 then p.parameter_value::numeric end) as "Направление ветра",
       max(case when p.type_param_id = 5 then p.parameter_value::numeric end) as "Скорость ветра",
       max(case when p.type_param_id = 6 then p.parameter_value::numeric end) as "Дальность сноса пуль"
    from public.parameters p
    join public.users u on p.user_id = u.user_id
    join public.packs pk on u.pack_id = pk.pack_id
    join public.equipment_types eq on p.equipment_type_id = eq.equipment_type_id
    group by pk.pack_number, eq.equipment_type_name
),
validated_packs as (
    select 
        *,
        validate_params(
            ROW(
                "Тип оборудования",
                coalesce("Высота метеопоста", 0),
                coalesce("Температура", 0),
                coalesce("Давление", 0),
                coalesce("Направление ветра", 0),
                coalesce("Скорость ветра", 0),
                coalesce("Дальность сноса пуль", 0)
            )::meteo_params
        ) as error_description
    from raw_parameters
)
select 
    "№",
    "Тип оборудования",
    "Высота метеопоста",
    "Температура",
    "Давление",
    "Направление ветра",
    "Скорость ветра",
    "Дальность сноса пуль",
    true as "Флаг: Есть ошибка",
    error_description as "Описание ошибки"
from validated_packs
where error_description != 'Ошибок нет';

-- 2. запрос лучший стрелок
with shooter_packs as (
    select 
        u.user_id,
        u.user_name as "ФИО сотрудника",
        pk.pack_number,
        eq.equipment_type_name as "Тип оборудования",
        max(case when p.type_param_id = 1 then p.parameter_value::numeric end) as h,
        max(case when p.type_param_id = 2 then p.parameter_value::numeric end) as t,
        max(case when p.type_param_id = 3 then p.parameter_value::numeric end) as pr,
        max(case when p.type_param_id = 4 then p.parameter_value::numeric end) as wd,
        max(case when p.type_param_id = 5 then p.parameter_value::numeric end) as ws,
        max(case when p.type_param_id = 6 then p.parameter_value::numeric end) as bd
    from public.users u
    join public.packs pk on u.pack_id = pk.pack_id
    join public.parameters p on p.user_id = u.user_id
    join public.equipment_types eq on p.equipment_type_id = eq.equipment_type_id
    group by u.user_id, u.user_name, pk.pack_number, eq.equipment_type_name
),
evaluated_shooter_packs as (
    select 
        user_id,
        "ФИО сотрудника",
        validate_params(
            ROW(
                "Тип оборудования",
                coalesce(h, 0),
                coalesce(t, 0),
                coalesce(pr, 0),
                coalesce(wd, 0),
                coalesce(ws, 0),
                coalesce(bd, 0)
            )::meteo_params
        ) as err_desc
    from shooter_packs
)
select 
    "ФИО сотрудника",
    count(case when err_desc != 'Ошибок нет' then 1 end) as "Количество ошибок"
from evaluated_shooter_packs
group by user_id, "ФИО сотрудника"
order by "Количество ошибок" asc;