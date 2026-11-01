drop function if exists validate_params(meteo_params);
drop function if exists calc_data();
drop function if exists calc_vvvv(numeric);
drop function if exists calc_meteo_bbbtt(numeric, numeric);
drop type if exists meteo_params cascade;

--таблица с константами
create table if not exists constants (
    param_id int primary key,
    param_name text,
    min_val numeric,
    max_val numeric,
    error_text text
);
comment on table constants is 'таблица констант и диапазонов для валидации';

truncate table constants;
insert into constants (param_id, param_name, min_val, max_val, error_text) values
(1, 'Высота метеопоста', -1000, 10000, 'ошибка,неверная высота метеопоста'),
(2, 'Температура', -58, 58, 'ошибка,температура вне диапазона (-58...+58)'),
(3, 'Давление', 500, 900, 'ошибка,давление вне допустимого диапазона (500...900)'),
(4, 'Направление ветра', 0, 59, 'ошибка,направление ветра должно быть от 0 до 59'),
(5, 'Скорость ветра', 0, 15, 'ошибка,скорость ветра вне диапазона (0...15)'),
(6, 'Дальность сноса пуль', 0, 150, 'ошибка: дальность сноса пуль вне диапазона (0...150)');

--расширяем табличку с типами параметров
alter table type_params
add column if not exists error_desc text;

update type_params tp
set error_desc=c.error_text
from constants c
where tp.id=c.param_id;

--создаем тип данных список параметров
create type meteo_params as(
	meteo_type varchar(30),
    station_height numeric(8,2),
    temperature numeric(8,2),
    pressure numeric(8,2),
    wind_direction numeric(5,2),
    wind_speed numeric(5,2),
    bullet_drift numeric(8,2)
);