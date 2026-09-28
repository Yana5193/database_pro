--1. справочник базовых единиц измерения
create table basic_unit_measure
(
    id integer,
    name text
);

comment on table basic_unit_measure is 'Справочник базовых единиц измерения';
comment on column basic_unit_measure.id is 'уникальный код';
comment on column basic_unit_measure.name is 'название единицы измерения';

-- заполняем данные
insert into basic_unit_measure(id,name)
values
    (1,'метр'),
    (2,'градус'),
    (3,'миллиметр ртутного столба');

--2. справочник единиц измерения
create table unit_measure
(
    id integer,
    name text,
    basic_unit_measure_id integer
);

comment on table unit_measure is 'справочник единиц измерения';
comment on column unit_measure.id is 'уникальный код';
comment on column unit_measure.name is 'название ед измерения';
comment on column unit_measure.basic_unit_measure_id is 'код базовой единицы измерения';

-- заполняем данные
insert into unit_measure(id,name,basic_unit_measure_id)
values
    (1, 'м', 1),
    (2, '°', 2),
    (3, '°C', 2),
    (4, 'мм рт. ст.', 3),
    (5, 'м/с', 1);

--3. справочник типа параметров
create table type_params
(
    id integer,
    name text,
    unit_measure_id integer
);

comment on table type_params is 'справочник типа параметров';
comment on column type_params.id is 'уникальный код';
comment on column type_params.name is 'название типа параметра';
comment on column type_params.unit_measure_id is 'уникальный код единицы измерения';

-- заполняем данные
insert into type_params(id,name,unit_measure_id)
values(1, 'Высота метеопоста', 1),
    (2, 'Температура', 3),
    (3, 'Давление', 4),
    (4, 'Направление ветра', 2),
    (5, 'Скорость ветра', 5),
    (6, 'Дальность сноса пуль', 1);

--добавляем в табоицу параметров уникальный код параметра
alter table parameters
add type_param_id integer;


update parameters
set type_param_id = 1
where parameter_name = 'Высота метеопоста';

update parameters
set type_param_id = 2
where parameter_name = 'Температура';

update parameters
set type_param_id = 3
where parameter_name = 'Давление';

update parameters
set type_param_id = 4
where parameter_name = 'Направление ветра';

update parameters
set type_param_id = 5
where parameter_name = 'Скорость ветра';

update parameters
set type_param_id = 6
where parameter_name = 'Дальность сноса пуль';

--удаление старого поля
alter table parameters
drop COLUMN parameter_name;

select
    pk.created_date AS "Дата измерения",
    pk.pack_number AS "Номер пачки",
    u.user_name AS "ФИО сотрудника",
    tp.name || ', ' || um.name AS "Наименование параметра и ед. измерения",
    p.parameter_value AS "Значение"
from
    parameters p,
    users u,
    packs pk,
    type_params tp,
    unit_measure um
where
    p.user_id = u.user_id
    and u.pack_id = pk.pack_id
    and p.type_param_id = tp.id
    and tp.unit_measure_id = um.id;