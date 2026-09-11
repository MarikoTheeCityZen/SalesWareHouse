--Table Initializations
--We are going to fully recreate our tables from scratch if they exist by dropping and recreating in our initial creation.
--For later structural changes in our table we will implement the migration based strategy

use SalesWH;

if OBJECT_ID(N'silver.customer_master','U') is not null
drop table silver.customer_master;
go

create table silver.customer_master(
	customer_id varchar(100),
	customer_key nvarchar(100),
	cst_firstname nvarchar(100),
	cst_lastname nvarchar(100),
	cst_marital_status varchar(50),
	cst_gndr varchar(50),
	cst_create_date date,
	_created_at datetime2 not null
	default sysutcdatetime() ,
	_source_system nvarchar(200)
);
go



if OBJECT_ID(N'silver.customer_info','U') is not null
drop table silver.customer_info;
go

create table silver.customer_info(
customer_id varchar(100),
customer_key nvarchar(100),
birthdate date,
gender nvarchar(50),
_created_at datetime2 not null
default sysutcdatetime() ,
_source_system nvarchar(200)
);
go



if OBJECT_ID(N'silver.customer_locations','U') is not null
drop table silver.customer_locations;
go

create table silver.customer_locations(
customer_key nvarchar(100),
country nvarchar(100),
_created_at datetime2 not null
default sysutcdatetime() ,
_source_system nvarchar(200)
);
go



if OBJECT_ID(N'silver.products','U') is not null
drop table silver.products;
go

create table silver.products(
product_id int,
product_key nvarchar(100),
cat_id nvarchar(50),
_product_key nvarchar(50),
product_number nvarchar(200),
product_cost int,
product_line varchar(20),
start_date date,
end_date date,
_created_at datetime2 not null
default sysutcdatetime(),
_source_system nvarchar(200)
);
go



if OBJECT_ID(N'silver.product_categories','U') is not null
drop table silver.product_categories;
go

create table silver.product_categories(
cat_id nvarchar(50),
category nvarchar(100),
subcategory nvarchar(100),
maintanance nvarchar(20),
_created_at datetime2 not null
default sysutcdatetime() ,
_source_system nvarchar(200)
);
go


if OBJECT_ID(N'silver.sales','U') is not null
drop table silver.sales;
go

create table silver.sales(
order_number nvarchar(50),
product_key nvarchar(50),
customer_id nvarchar(50),
order_date varchar(50),
ship_date varchar(50),
due_date varchar(50),
sales varchar(50),
quantity varchar(50),
price varchar(50),
_created_at datetime2 not null
default sysutcdatetime() ,
_source_system nvarchar(200)
);
go
