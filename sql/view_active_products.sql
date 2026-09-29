use SalesWH;
go
create or alter view gold.view_active_products as 
select * from gold.dim_products where end_date is null

