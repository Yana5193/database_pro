--1. анализ закупки продуктов
--смотрим какие поставщики учавствуют в закупках
select * from vendors t1
left join (
    select VendorID from bm_StorageOperations
    group by VendorID
) as t2
on t1.id = t2.VendorID;

--выявляем типы операций, которые заложены в систему, но ни разу не применялись на практике. если не использовались топоявится null
select * from bm_StorageOperationsType t1
left join (
    select OperationID from bm_StorageOperations
    group by OperationID
) as t2
on t1.ID = t2.OperationID;

--проверка связи журнала с документами и операций склада
select * from bm_JournalBarnetDocs t1
left join (
    select DocumentID from bm_StorageOperations
    group by DocumentID
) as t2
on t1.ID = t2.DocumentID;
--показывает, что по складу есть движение товара
select * from storages t1
left join (
    select StorageID from bm_StorageOperations
    group by StorageID
) as t2
on t1.id = t2.StorageID;

-- показывает список приходных накладных и позиций товара от поставщиков
select * from receiving t1
left join (
    select id from bm_JournalBarnetDocs
    group by id
) as t2
on t1.id = t2.id;

--показывает перечень товаров из справочника и сопоставляет их с записями в складском журнале.
select * from product t1
left join (
    select ProductID from bm_StorageOperations
    group by ProductID
) as t2
on t1.productid = t2.ProductID;

-- Показывает наличие цен поставщиков для каждой товарной позиции.
select * from product t1
left join (
    select productid from pricelist
    group by productid
) as t2
on t1.id = t2.productid;

--2.анализ продажи товара
--проверка связи главного журнала документов с детализированными позициями чеков.
select * from journal t1
right join (
    select SourceID from bm_Journal_Details
    group by SourceID
) as t2
on t1.transnumber = t2.SourceID;
--какие товары попадают в чеки.
select t1.* from product t1
left join (
    select ProductID from bm_Journal_Details
    group by ProductID
) as t2
on t1.id = t2.ProductID
where t2.ProductID is null;

--связь тоаров из таблицы product с размерностями size
select t1.id, t1.sizeid, t1.description
from product t1
left join size t2 
    on cast(t1.sizeid as varchar) = t2.sizeid; 

-- какие типы транзакций реально встречаются в продажах
select * from transtype t1
left join (
    select transtype from journal
    group by transtype
) as t2
on t1.transtypeid = t2.transtype;


--3.анализ взаимоотношений с поставщиками
-- группы поставщиков.в каких группах есть поставщики. 
select * from vendorgroup t1
left join (
    select clientgroup from vendors
    group by clientgroup
) as t2
on t1.vendorgroupid = t2.clientgroup;

--поставщики в товарах.у каких поставщиков есть товары.
select * from vendors t1
left join (
    select vendorid from product
    group by vendorid
) as t2
on t1.id = t2.vendorid;

-- поставщики в прайс-листах.
select * from vendors t1
left join (
    select vendorid from pricelist
    group by vendorid
) as t2
on t1.id = t2.vendorid;

-- поставщики в складских операциях. 
select * from vendors t1
left join (
    select VendorID from bm_StorageOperations
    group by VendorID
) as t2
on t1.id = t2.VendorID;

---анализ работы персоналв
-- сотрудники в журнале сессий
select * from personnel t1
left join (
    select PersonID from bm_JournalSessions
    group by PersonID
) as t2
on t1.personid = t2.PersonID;

--сотрудники с правами доступа
select * from personnel t1
left join (
    select PersonID from bm_PersonnelSecurity
    group by PersonID
) as t2
on t1.personid = t2.PersonID;

--объекты безопасности в правах смотрим какие объекты выданы сотрудникам
select * from bm_SecurityObjects t1
left join (
    select ObjectID from bm_PersonnelSecurity
    group by ObjectID
) as t2
on t1.ID = t2.ObjectID;

--сотрудники в истории бонусов есть ли бонусы, привязанные к несуществующему сотруднику
select * from personnel t1
right join (
    select PersonID from bm_BonusHistory
    group by PersonID
) as t2
on t1.personid = t2.PersonID;

--смены в документах в каких сменах оформлены документы
select * from bm_ShiftsOperations t1
left join (
    select ShiftID from bm_JournalBarnetDocs
    group by ShiftID
) as t2
on t1.ID = t2.ShiftID;

--анализ остатков
--проверка использования складов в складских операциях
select * from storages t1
left join (
    select StorageID from bm_StorageOperations
    group by StorageID
) as t2
on t1.id = t2.StorageID;
--проверка движения товаров по складским операциям
select * from product t1
left join (
    select ProductID from bm_StorageOperations
    group by ProductID
) as t2
on t1.id = t2.ProductID;
--проверка наличия товаров в периодах складских остатков
select * from product t1
left join (
    select productid from stockperiod
    group by productid
) as t2
on t1.productid = t2.productid;

--причины списанич
select * from bm_ReasonDebit t1
left join (
    select ReasonID from bm_StorageOperations
    group by ReasonID
) as t2
on t1.ID = t2.ReasonID;
--тпроверка использования типов операций в таблице складских операций
select * from bm_StorageOperationsType t1
left join (
    select OperationID from bm_StorageOperations_Table
    group by OperationID
) as t2
on t1.ID = t2.OperationID;