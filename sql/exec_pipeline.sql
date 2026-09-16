use SalesWH
go

exec etl.load_bronze;
exec etl.load_silver;
exec etl.load_gold;

select * from etl.batch_log
select * from etl.table_log



