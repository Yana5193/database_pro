--исправление данных
do $$
begin
    --создание новой таблицы заголовков
    begin

        create sequence calc_headers_seq;
        create table calc_headers(
            id integer primary key not null default nextval('public.calc_headers_seq'),
            description text not null,
            header_values integer[]
        );
        comment on table calc_headers is 'таблица для хранения заголовков';
        comment on column calc_headers.id is 'уникальный код';
        comment on column calc_headers.description is 'описание к таблице';
        comment on column calc_headers.header_values is 'значения в заголовке таблицы';

        --заполняем заголовки (в заголовке таблицы 2 был лишний 0 и 8 дублировалась 2 раза, исправлено)
        insert into calc_headers(description, header_values)
        values('заголовок таблицы 2',array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]),--1
        ('заголовок таблицы 3(вр)',array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]), --2
        ('заголовок таблицы 3(дмк)',array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);--3

        --ссылка на заголовок в справочнике типов
        alter table calc_correction_types add column header_id integer;
        comment on column calc_correction_types.header_id is 'ссылка на заголовок таблицы';

        update calc_correction_types set header_id = 1 where id in (1, 8, 9); --таблица 2
        update calc_correction_types set header_id = 2 where id in (4, 5);    --таблица 3 (вр)
        update calc_correction_types set header_id = 3 where id in (6, 7);    --таблица 3 (дмк)

        --старая колонка с заголовками больше не нужна
        alter table calc_correction_types drop column header_values;
        
        alter table calc_correction_types
        add constraint fk_calc_correction_types_header
        foreign key (header_id) references calc_headers(id);

    end;

    --исправление данных
    begin

        --неправильные type_id: отрицательные температуры записаны в тип 8, должны быть в типе 9
        update calc_correction
        set type_id = 9
        where type_id = 8;

        --неправильные type_id: положительные температуры записаны в тип 7, должны быть в типе 8
        update calc_correction
        set type_id = 8
        where type_id = 7 and array_length(row_values, 1) = 12;

        -- в табличке 2 отрицательные температуры, высота 400: вместо -39 должно быть -38
        update calc_correction
        set row_values[13] = -38
        where type_id = 9 and height_id = 2;

        --табличка 3, скорость среднего ветра дмк, высота 1200: вместо 23 должно быть 22
        update calc_correction
        set row_values[9] = 22
        where type_id = 6 and height_id = 4;

        --табличка 2, положительные температуры: в таблице нет значений под 40 и 50, добавила null
        update calc_correction
        set row_values = row_values || array[null, null]::integer[]
        where type_id = 8;

        --табличка 3, направление среднего ветра (вр): вместо одного значения нужно 12 (по числу столбцов заголовка)
        update calc_correction
        set row_values = array_fill(row_values[1], array[12])
        where type_id = 5;

        --табличка 3, направление среднего ветра (дмк): так же 12 значений вместо одного
        update calc_correction
        set row_values = array_fill(row_values[1], array[12])
        where type_id = 7;

        -- не хватало строк для высот 1600, 2000, 2400, 3000, 4000
        insert into calc_correction(height_id, type_id, row_values)
        values
        -- табличка 2 отрицательные
        (5, 9, array[-1, -2, -3, -3, -4, -4, -5, -6, -7, -7, -17, -25, -34, -42]), -- 1600
        (6, 9, array[-1, -2, -2, -3, -4, -4, -5, -5, -6, -7, -16, -24, -32, -40]), -- 2000
        (7, 9, array[-1, -2, -2, -3, -4, -4, -5, -5, -6, -7, -15, -23, -31, -38]), -- 2400
        (8, 9, array[-1, -2, -2, -3, -4, -4, -4, -5, -5, -6, -15, -22, -30, -37]), -- 3000
        (9, 9, array[-1, -2, -2, -3, -4, -4, -4, -4, -5, -6, -14, -20, -27, -34]), -- 4000
        -- табличка 2 положительные
        (5, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 1600
        (6, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 2000
        (7, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 2400
        (8, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 3000
        (9, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 4000
        -- табличка 3 скорость среднего ветра (ВР)
        (5, 4, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 15, 17, 17]), -- 1600
        (6, 4, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 16, 17, 18]), -- 2000
        (7, 4, array[4, 6, 8, 9, 9, 10, 12, 14, 15, 16, 18, 19]), -- 2400
        (8, 4, array[5, 6, 8, 9, 10, 11, 12, 14, 15, 17, 18, 19]), -- 3000
        (9, 4, array[5, 6, 8, 9, 10, 11, 12, 14, 16, 18, 19, 20]), -- 4000
        --табличка 3 направление среднего ветра (ВР)
        (5, 5, array[3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]), -- 1600
        (6, 5, array[3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]), -- 2000
        (7, 5, array[3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]), -- 2400
        (8, 5, array[4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4]), -- 3000
        (9, 5, array[4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4]), -- 4000
        -- табличка 3  скорость среднего ветра (ДМК)
        (5, 6, array[6, 8, 11, 13, 14, 17, 20, 21, 23, 25, 27, 29, 32]), -- 1600
        (6, 6, array[6, 9, 11, 13, 14, 17, 20, 21, 24, 26, 28, 30, 32]), -- 2000
        (7, 6, array[6, 9, 12, 14, 15, 18, 21, 22, 25, 27, 29, 32, 34]), -- 2400
        (8, 6, array[6, 9, 12, 14, 15, 18, 21, 23, 25, 28, 30, 32, 36]), -- 3000
        (9, 6, array[6, 10, 12, 14, 16, 19, 22, 24, 26, 29, 32, 34, 36]), -- 4000
        -- табличка 3  направление среднего ветра (ДМК)
        (5, 7, array[4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4]), -- 1600
        (6, 7, array[4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4]), -- 2000
        (7, 7, array[4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4]), -- 2400
        (8, 7, array[5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]), -- 3000
        (9, 7, array[5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]); -- 4000

    end;
    --прочее
    begin
        --поменяла владельца (в скрипте admin, у меня postgres)
        alter function public.fn_calc_temperature_interpolation(numeric) owner to postgres;
    end;
    commit;
end $$;