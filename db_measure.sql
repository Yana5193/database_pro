-- Миграционный скрипт
-- 2026-09-23
drop table if exists military_ranks;
drop table if exists employees;
drop table if exists measurment_types;
drop table if exists measurment_input_params;
drop table if exists measurment_baths;
drop table if exists basic_unit_measure;
drop table if exists unit_measure;
drop table if exists type_params;

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
values(1,'метр'),(2,'градус'),(3,'миллиметр ртутного столба');

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

--заполняем данные
insert into unit_measure(id,name,basic_unit_measure_id)
values(1, 'м', 1),(2, '°', 2),(3, '°C', 2),(4, 'мм рт. ст.', 3),(5, 'м/с', 1);

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

--заполняем данные
insert into type_params(id,name,unit_measure_id)
values(1, 'Высота метеопоста', 1),(2, 'Температура', 3),(3, 'Давление', 4),(4, 'Направление ветра', 2),(5, 'Скорость ветра', 5);

-- 4. Справочник должностей
create table military_ranks
(
	id integer,
	description character varying(255)
);

comment on table military_ranks is 'Справочник должностей';
comment on column military_ranks.id is 'Уникальный код';
comment on column military_ranks.description is 'Описание';

-- Заполняем данные
insert into military_ranks(id, description)
values(1,'Рядовой'),(2,'Лейтенант');

-- 5. Пользователя
create table employees
(
    id integer,
	name text,
	birthday timestamp ,
	military_rank_id integer
);

comment on table employees is 'Пользователи';
comment on column employees.id is 'Уникальный код';
comment on column employees.name is 'Наименование';
comment on column employees.birthday is 'Дата рождения';
comment on column employees.military_rank_id is 'Уникальный код должности';

-- Заполняем данные
insert into employees(id, name, birthday,military_rank_id )  
values(1, 'Воловиков Александр Сергеевич','1978-06-24', 2);

-- 6. Устройства для измерения
create table measurment_types
(
   id integer,
   short_name  character varying(50),
   description text 
);

comment on table measurment_types is 'Измерительное оборудование';
comment on column measurment_types.id is 'Уникальный код';
comment on column measurment_types.short_name is 'Краткое наименование';
comment on column measurment_types.description is 'Описание';

-- Заполняем данные
insert into measurment_types(id, short_name, description)
values(1, 'ДМК', 'Десантный метео комплекс'),
(2,'ВР','Ветровое ружье');


-- 7. Таблица с параметрами
create table measurment_input_params
(
    id integer,
	measurment_bath_id integer,
	height numeric(8,2) default 0,
	temperature numeric(8,2) default 0,
	pressure numeric(8,2) default 0,
	wind_direction numeric(8,2) default 0,
	wind_speed numeric(8,2) default 0
);

comment on table measurment_input_params is 'Таблица с параметрами';
comment on column measurment_input_params.id is 'Уникальный код';
comment on column measurment_input_params.measurment_bath_id is 'Уникальный код пачки';
comment on column measurment_input_params.height is 'Высота';
comment on column measurment_input_params.temperature is 'Температура';
comment on column measurment_input_params.pressure is 'Давление';
comment on column measurment_input_params.wind_direction is 'Направление ветка';
comment on column measurment_input_params.wind_speed is 'Скорость ветра';

-- Заполняем данные
insert into measurment_input_params(id, measurment_bath_id, height, temperature, pressure, wind_direction,wind_speed )
values(1, 1, 100,12,34,0.2,45);

alter table measurment_input_params add column param_type_id integer;
alter table measurment_input_params add column value numeric(8,2) default 0;
 
comment on column measurment_input_params.param_type_id is 'Уникальный код типа параметра';
comment on column measurment_input_params.value is 'Значение параметра';
 
-- DML: удаляем старые данные 
delete from measurment_input_params;
 
-- DML: создаём новые данные 
insert into measurment_input_params(id, measurment_bath_id, param_type_id, value)
values(1,1,1,100),
(2,1,2,12),
(3,1,3,34),
(4,1,4,0.2),
(5,1,5,45);
 
-- DDL: удаляем старые не нужные структуры 
alter table measurment_input_params drop column height;
alter table measurment_input_params drop column temperature;
alter table measurment_input_params drop column pressure;
alter table measurment_input_params drop column wind_direction;
alter table measurment_input_params drop column wind_speed;


-- 8. Таблица с историей
create table measurment_baths
(
	id integer ,
	emploee_id integer,
	measurment_type_id integer,
	started timestamp default now()
);

comment on table measurment_baths is 'Пачки';
comment on column measurment_baths.emploee_id is 'Уникальный код пользователя';
comment on column measurment_baths.measurment_type_id is 'Уникальный код оборудования';
comment on column measurment_baths.started is 'Дата измерения';

-- Заполняем данные
insert into measurment_baths(id, emploee_id, measurment_type_id, started)
values(1, 1, 1, '2026-09-01'),(2,1,2, '2026-09-02');

---------------------------------------------------
-- Итоговый запрос
---------------------------------------------------

select  measurment_baths.started as "Дата измерения",
    measurment_baths.id as "Номер пачки",
    employees.name as "ФИО сотрудника",
    type_params.name || ' (' || unit_measure.name || ')' as "Наименование параметра и ед. измерения",
    measurment_input_params.value as "Значение"
from  measurment_baths, measurment_input_params,measurment_types,employees,military_ranks,type_params,unit_measure
where
        -- Связь пачка - пользователи
	    employees.id = measurment_baths.emploee_id
		-- Связь должность - пользователь
	and employees.military_rank_id = military_ranks.id
	    -- Связь пачка - тип оборудования
	and measurment_types.id = measurment_baths.measurment_type_id
	    -- Связь пачка - параметры
	and measurment_input_params.measurment_bath_id = measurment_baths.id
        -- Связь параметр - тип параметра
	and measurment_input_params.param_type_id = type_params.id
	    -- Связь тип параметра - единица измерения
	and type_params.unit_measure_id = unit_measure.id;






