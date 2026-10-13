do $$
begin
    begin
        drop table if exists parameters cascade;
        drop table if exists users cascade;
        drop table if exists positions cascade;
        drop table if exists packs cascade;
        drop table if exists equipment_types cascade;
        drop table if exists type_params cascade;
        drop table if exists unit_measure cascade;
        drop table if exists basic_unit_measure cascade;
        drop table if exists temperature_calculations cascade;
    end;

    begin
        drop sequence if exists seq_equipment_types;
        drop sequence if exists seq_positions;
        drop sequence if exists seq_packs;
        drop sequence if exists seq_users;
        drop sequence if exists seq_parameters;
        drop sequence if exists seq_calc;
    end;
    begin
        create sequence seq_equipment_types start with 1;
        create sequence seq_positions start with 1;
        create sequence seq_packs start with 1;
        create sequence seq_users start with 1;
        create sequence seq_parameters start with 1;
        create sequence seq_calc start with 1;

        -- 1. типы оборудования
        create table equipment_types(
            equipment_type_id int default nextval('seq_equipment_types'),
            equipment_type_name varchar(30),
            primary key (equipment_type_id)
        );
        comment on table equipment_types is 'типы оборудования (например, ветровое ружье)';
        comment on column equipment_types.equipment_type_id is 'уникальный айди оборудования';
        comment on column equipment_types.equipment_type_name is 'название оборудования';

        -- 2. должности
        create table positions(
            position_id int default nextval('seq_positions'),
            position_name varchar(30),
            primary key (position_id)
        );
        comment on table positions is 'должности пользователей';
        comment on column positions.position_id is 'уникальный айди должности';
        comment on column positions.position_name is 'название должности';

        -- 3. пачки
        create table packs(
            pack_id int default nextval('seq_packs'),
            pack_number varchar(30),
            created_date timestamp,
            primary key (pack_id)
        );
        comment on table packs is 'пачки для группировки измерений';
        comment on column packs.pack_id is 'уникальный айди пачки';
        comment on column packs.pack_number is 'номер пачки';
        comment on column packs.created_date is 'дата создания пачки';

        -- 4. пользователи
        create table users(
            user_id int default nextval('seq_users'),
            user_name varchar(50),
            position_id int,
            pack_id int,
            primary key (user_id)
        );
        comment on table users is 'пользователи системы';
        comment on column users.user_id is 'уникальный айди пользователя';
        comment on column users.user_name is 'фамилия и имя пользователя';
        comment on column users.position_id is 'ссылка на должность';
        comment on column users.pack_id is 'ссылка на пачку';

        -- 5. базовые единицы измерения
        create table basic_unit_measure(
            id int primary key,
            name text
        );
        comment on table basic_unit_measure is 'справочник базовых единиц измерения';
        comment on column basic_unit_measure.id is 'уникальный код';
        comment on column basic_unit_measure.name is 'название базовой единицы измерения';

        -- 6. единицы измерения
        create table unit_measure(
            id int primary key,
            name text,
            basic_unit_measure_id int
        );
        comment on table unit_measure is 'справочник единиц измерения';
        comment on column unit_measure.id is 'уникальный код';
        comment on column unit_measure.name is 'название единицы измерения';
        comment on column unit_measure.basic_unit_measure_id is 'ссылка на базовую единицу измерения';

        -- 7. типы параметров
        create table type_params(
            id int primary key,
            name text,
            unit_measure_id int
        );
        comment on table type_params is 'справочник типов параметров';
        comment on column type_params.id is 'уникальный код';
        comment on column type_params.name is 'название типа параметра';
        comment on column type_params.unit_measure_id is 'ссылка на единицу измерения';

        -- 8. параметры 
        create table parameters(
            parameter_id int default nextval('seq_parameters'),
            parameter_value varchar(50),
            user_id int,
            equipment_type_id int,
            type_param_id int,
            primary key (parameter_id)
        );
        comment on table parameters is 'параметры измерений';
        comment on column parameters.parameter_id is 'уникальный айди параметра';
        comment on column parameters.parameter_value is 'значение параметра';
        comment on column parameters.user_id is 'ссылка на пользователя';
        comment on column parameters.equipment_type_id is 'ссылка на тип оборудования';
        comment on column parameters.type_param_id is 'ссылка на тип параметра';

        -- 9. расчетная таблица
        create table temperature_calculations(
            calc_id int default nextval('seq_calc') primary key,
            pack_id int,
            avg_temperature numeric(5, 2),
            calculated_date timestamp default current_timestamp
        );
        comment on table temperature_calculations is 'расчетные данные по средней температуре';
        comment on column temperature_calculations.calc_id is 'уникальный айди расчета';
        comment on column temperature_calculations.pack_id is 'ссылка на пачку';
        comment on column temperature_calculations.avg_temperature is 'средняя температура по пачке';
        comment on column temperature_calculations.calculated_date is 'время проведения расчета';

        --создаем связи
        alter table users
        add constraint fk_users_position foreign key (position_id) references positions(position_id),
        add constraint fk_users_pack foreign key (pack_id) references packs(pack_id);

        alter table unit_measure
        add constraint fk_unit_measure_basic foreign key (basic_unit_measure_id) references basic_unit_measure(id);

        alter table type_params
        add constraint fk_type_params_unit foreign key (unit_measure_id) references unit_measure(id);

        alter table parameters
        add constraint fk_parameters_user foreign key (user_id) references users(user_id),
        add constraint fk_parameters_equipment foreign key (equipment_type_id) references equipment_types(equipment_type_id),
        add constraint fk_parameters_type foreign key (type_param_id) references type_params(id);

        alter table temperature_calculations
        add constraint fk_calc_pack foreign key (pack_id) references packs(pack_id);
    end;

    --заполненеи данными
    begin
        insert into equipment_types (equipment_type_name) values ('ДМК'), ('ВР');

        insert into positions (position_name) values ('Оператор'), ('Старший оператор');

        insert into packs (pack_number, created_date) values 
        ('pack-01aa', '2026-05-11 10:00:00'), 
        ('pack-02ab', '2026-05-11 11:30:00');

        insert into users (user_name, position_id, pack_id) values 
        ('Иван Иванов', 1, 1),
        ('Иван Петров', 2, 2);

        insert into basic_unit_measure (id, name) values 
        (1, 'Метр'), 
        (2, 'Градус'), 
        (3, 'Миллиметр ртутного столба');

        insert into unit_measure (id, name, basic_unit_measure_id) values
        (1, 'м', 1), 
        (2, '°', 2), 
        (3, '°C', 2), 
        (4, 'мм рт. ст.', 3), 
        (5, 'м/с', 1);

        insert into type_params (id, name, unit_measure_id) values
        (1, 'Высота метеопоста', 1),
        (2, 'Температура', 3),
        (3, 'Давление', 4),
        (4, 'Направление ветра', 2),
        (5, 'Скорость ветра', 5),
        (6, 'Дальность сноса пуль', 1);

        insert into parameters (parameter_value, user_id, equipment_type_id, type_param_id) values 
        ('100', 1, 1, 1),
        ('15', 1, 1, 2),
        ('750', 1, 1, 3),
        ('00', 1, 1, 4),
        ('0', 1, 1, 5),
        ('0', 2, 2, 6);

        --запрос, чтобы заполнять таблицу с температурой
        insert into temperature_calculations(pack_id, avg_temperature)
        select 
            u.pack_id,
            avg(p.parameter_value::numeric)
        from parameters p
        join users u on u.user_id = p.user_id
        where p.type_param_id = 2
        group by u.pack_id;
    end;
end $$;

--скрипт для отображения метаданных  
select 
    row_number() over (order by t.table_name) as "№",
    t.table_name as "Наименование",
    t.table_type as "Тип",
    (
        select count(*) 
        from information_schema.columns c 
        where c.table_name = t.table_name and c.table_schema = 'public'
    ) as "Количество столбцов",
    (
        select count(*) 
        from information_schema.table_constraints tc 
        where tc.table_name = t.table_name and tc.table_schema = 'public'
    ) as "Количество ограничений"
from information_schema.tables t
where t.table_schema = 'public' and t.table_catalog = current_database();