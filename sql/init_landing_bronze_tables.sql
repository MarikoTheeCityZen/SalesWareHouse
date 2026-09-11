--Table Initializations
--We are going to fully recreate our tables from scratch if they exist by dropping and recreating in our initial creation.
--For later structural changes in our table we will implement the migration based strategy
--Add metadata for ingestion time and source system for auditing
--Due to restrictions regarding metadata cols ingestion using bulk insert we have a landing layer to get the data as it is from our csv files  
--The landing layer will be our first copy of our data after which we will insert it into our bronze layer with the metadata columns

use SalesWH;

if OBJECT_ID(N'landing.crm_cust_info_load','U') is not null
drop table landing.crm_cust_info_load;
go

create table landing.crm_cust_info_load(
	cst_id varchar(50),
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status varchar(20),
	cst_gndr varchar(20),
	cst_create_date nvarchar(50)
);
go

if OBJECT_ID(N'bronze.crm_cust_info','U') is not null
drop table bronze.crm_cust_info;
go

create table bronze.crm_cust_info(
	cst_id varchar(50),
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status varchar(20),
	cst_gndr varchar(20),
	cst_create_date datetime2,
	_created_at datetime  not null default getdate(),
	_source_system nvarchar(100) not null default 'crm/cust_info.csv'
);
go


if OBJECT_ID(N'landing.erp_cust_az12_load','U') is not null
drop table landing.erp_cust_az12_load;
go

create table landing.erp_cust_az12_load(
cid nvarchar(100),
bdate date,
gen nvarchar(50)
);
go

if OBJECT_ID(N'bronze.erp_cust_az12','U') is not null
drop table bronze.erp_cust_az12;
go


create table bronze.erp_cust_az12(
cid nvarchar(100),
bdate date,
gen nvarchar(50),
_created_at datetime2  not null default getdate(),
_source_system nvarchar(100) not null default 'erp/cust_az12.csv'
);
go


if OBJECT_ID(N'landing.erp_cust_loc_a101_load','U') is not null
drop table landing.erp_cust_loc_a101_load;
go

create table landing.erp_cust_loc_a101_load(
cid nvarchar(100),
cntry nvarchar(100)
);
go

if OBJECT_ID(N'bronze.erp_cust_loc_a101','U') is not null
drop table bronze.erp_cust_loc_a101;
go

create table bronze.erp_cust_loc_a101(
cid nvarchar(100),
cntry nvarchar(100),
_created_at datetime2  not null default getdate(),
_source_system nvarchar(100) not null default 'erp/cust_loc_a101.csv'
);
go


if OBJECT_ID(N'landing.crm_prd_info_load','U') is not null
drop table landing.crm_prd_info_load;
go

create table landing.crm_prd_info_load(
prd_id nvarchar(50),
prd_key nvarchar(100),
prd_nm nvarchar(200),
prd_cost int,
prd_line varchar(20),
prd_start_date date,
prd_end_date date
);
go

if OBJECT_ID(N'bronze.crm_prd_info','U') is not null
drop table bronze.crm_prd_info;
go

create table bronze.crm_prd_info(
prd_id nvarchar(50),
prd_key nvarchar(100),
prd_nm nvarchar(200),
prd_cost int,
prd_line varchar(20),
prd_start_date date,
prd_end_date date,
_created_at datetime2  not null default getdate(),
_source_system nvarchar(100) not null default 'crm/prd_info.csv'
);
go


if OBJECT_ID(N'landing.erp_cat_g1v2_load','U') is not null
drop table landing.erp_cat_g1v2_load;
go

create table landing.erp_cat_g1v2_load(
id nvarchar(50),
cat nvarchar(100),
subcat nvarchar(100),
maintanance nvarchar(20)
);
go

if OBJECT_ID(N'bronze.erp_cat_g1v2','U') is not null
drop table bronze.erp_cat_g1v2;
go

create table bronze.erp_cat_g1v2(
id nvarchar(50),
cat nvarchar(100),
subcat nvarchar(100),
maintanance nvarchar(20),
_created_at datetime2  not null default getdate(),
_source_system nvarchar(100) not null default 'erp/cat_g1v2.csv'
);
go

if OBJECT_ID(N'landing.crm_sales_details_load','U') is not null
drop table landing.crm_sales_details_load;
go

create table landing.crm_sales_details_load(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id nvarchar(50),
sls_order_dt varchar(50),
sls_ship_dt varchar(50),
sls_due_dt varchar(50),
sls_sales varchar(50),
sls_quantity varchar(50),
sls_price varchar(50)
);
go


if OBJECT_ID(N'bronze.crm_sales_details','U') is not null
drop table bronze.crm_sales_details;
go

create table bronze.crm_sales_details(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id nvarchar(50),
sls_order_dt varchar(50),
sls_ship_dt varchar(50),
sls_due_dt varchar(50),
sls_sales varchar(50),
sls_quantity varchar(50),
sls_price varchar(50),
_created_at datetime2  not null default getdate(),
_source_system nvarchar(100) not null default 'crm/sales_details.csv'
);
go


if OBJECT_ID(N'etl.batch_log','U') is not null
drop table etl.batch_log;

create table etl.batch_log
(
	batch_id bigint  identity(1,1) primary key,
	pipeline_name nvarchar(100) not null,
	start_time datetime2(3) not null,
	end_time datetime2(3),
	duration bigint,
	status nvarchar(40) not null,
	error_message  nvarchar(4000) NULL,
	created_at datetime2(3) not null
	default sysutcdatetime(),
	constraint CHK_batch_status
	check(status in('RUNNING','SUCCESS','FAILED'))
)

if OBJECT_ID(N'etl.table_log','U') is not null
drop table etl.table_log;

create table etl.table_log
(
	table_load_id bigint  identity(1,1) primary key,
	batch_id bigint not null,
	source_file nvarchar(100),
	target_table nvarchar(100),
	source_rows int,
	target_rows int,
	start_time datetime2(3) not null,
	end_time datetime2(3),
	duration bigint,
	status nvarchar(40) not null,
	error_message  nvarchar(4000) NULL,
	created_at datetime2(3) not null
	default sysutcdatetime(),
	constraint FK_batch_table
	foreign key (batch_id) references etl.batch_log(batch_id),
	constraint CHK_table_status
	check(status in('RUNNING','SUCCESS','FAILED'))

)

