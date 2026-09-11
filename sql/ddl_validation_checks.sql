--confirm we created our database correctly
select 
name,
database_id,
create_date
from sys.databases where name='SalesWH';
go

use SalesWH;
go

--confirm we initialized our  schemas
select
*
from sys.schemas
where name in ('landing','bronze','silver','gold','etl');
go

--check for existence of all our  tables
select
sch.name,
tb.name,
tb.object_id,
count(*) over() as no_of_tables
from sys.tables tb
inner join sys.schemas sch
on tb.schema_id=sch.schema_id
where sch.name='landing' or sch.name='bronze' or sch.name='etl' or sch.name='silver' or sch.name='gold';
go

--check if all our columns follow the desired data types
select
sch.name as schema_name,
tb.name as table_name,
col.column_id,
col.name,
ty.name as dtype
from sys.columns col
inner join sys.tables tb
on col.object_id=tb.object_id
inner join sys.schemas sch
on tb.schema_id=sch.schema_id
inner join sys.types ty
on col.user_type_id=ty.user_type_id
where sch.name='landing' or sch.name='bronze' or sch.name='etl' or sch.name='silver' or sch.name='gold';



--Check for our default constants to confirm they are correct and active

select
tb.name as table_name,
cols.name as col_name,
dfc.definition
from sys.default_constraints dfc
inner join sys.columns cols
on dfc.parent_column_id=cols.column_id and
dfc.parent_object_id=cols.object_id
inner join sys.tables tb
on dfc.parent_object_id=tb.object_id

