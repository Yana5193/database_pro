--создаем таблички
do $$
begin
create sequence seq_dim_ranges;
create sequence seq_dim_categories;
create sequence seq_dim_vendors;
create sequence seq_dim_transtypes;
create sequence seq_dim_personals;
create sequence seq_dim_storages;
--единицы измерения
create table dim_ranges
(
      --- Внутрений код
    id bigint primary key DEFAULT nextval('public.seq_dim_ranges'),
    external_id bigint,
    name text,
    factor float,
    -- Дата добавления
    date_add timestamp default now()
);

--категории
create table dim_categories
(

      --- Внутрений код
    id bigint primary key DEFAULT nextval('public.seq_dim_categories'),
    name text,
    parent_id bigint references public.dim_categories(id),
    -- Дата добавления
    date_add timestamp default now()
);

--поставщики
create table dim_vendors
(
	id bigint primary key DEFAULT nextval('public.seq_dim_vendors'),
	external_id bigint,
	name text,
	parent_id bigint,
	parent_name text,
	date_add timestamp default now()
);

--транзакции
create table dim_transtypes
(
	id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_transtypes'),
	external_id bigint,
    name text,
    group_external_id bigint,
    date_add timestamp default now()
);

--персонал
create table dim_personals
(
	id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_personals'),
	external_id bigint,
	lastname text,
	firstname text,
	date_add timestamp default now()
);

--склад
create table dim_storages(
	id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_storages'),
	external_id bigint,
	description text,
	resp_id bigint,
	date_add timestamp default now()
);
end;
$$;