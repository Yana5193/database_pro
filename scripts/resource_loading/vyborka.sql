--выборки ресурсов
-- Единицы измерения
select id, sizeid as name, 
portionrate as factor from [size] 

select 'insert into dim_ranges(external_id, name, factor ) values ('
    + cast(id as varchar(max)) + ','''   
    + [sizeid] + ''','  
    + caST(portionrate as varchar(max))   + ');' 
    as [sql]
 from [size] 

--категори
select * FROM
(
select id,  description as name,
   case when coalesce( ParentID,0) = 0 
        then null else parentId end as parent_id
          from category
) as t1
order  by parent_id, name

select 'insert into dim_categories(id, name, parent_id) values ('
    + cast(id as varchar(max)) + ','''
    + cast(description as nvarchar(max)) + ''','
    + coalesce(cast(ParentID as varchar(max)), 'null') + ');'
    as [sql]
from [category];

--поставщики
select * FROM
(
    select id,  clientid as name, clientgroup as parent_id,
    t2.[description] as parent_name
    from vendors t1
    inner join vendorgroup t2 on t1.clientgroup = t2.vendorgroupid
) as t1 
order by parent_id

select 'insert into dim_vendors(external_id, name, parent_id, parent_name) values ('
    + cast(t1.id as varchar(max)) + ','''
    + cast(t1.clientid as nvarchar(max)) + ''','
    + cast(t1.clientgroup as varchar(max)) + ','''
    + cast(t2.[description] as nvarchar(max)) + ''');' as [sql]
from vendors t1
inner join vendorgroup t2 on t1.clientgroup = t2.vendorgroupid
order by t1.clientgroup;

--транзакции
select transtypeid as id, description as name, transgroupid as group_id 
from [transtype];

select 'insert into dim_transtypes(external_id, name, group_external_id) values ('
    + cast(transtypeid as varchar(20)) + ','
    + isnull('''' + replace(description, '''', '''''') + '''', 'null') + ','
    + isnull(cast(transgroupid as varchar(20)), 'null') + ');' as [sql]
from transtype;

--персонал
select personid as id, lastname,firstname
from[personnel]
select 'insert into dim_personals(external_id, lastname, firstname) values ('
    + cast(personid as varchar(max)) + ','''
    + cast(lastname as nvarchar(max)) + ''','''
    + cast(firstname as nvarchar(max)) + ''');' as [sql]
from [personnel];

--остатки.склад
select id,description as name,ResponsibleId as resp_id
from[storages];

select 'insert into dim_storages(external_id,description, resp_id) values ('
    + cast(id as varchar(max)) + ','''
    + cast(description as nvarchar(max)) + ''','
    + cast(ResponsibleId as varchar(max)) + ');' as [sql]
from [storages];
