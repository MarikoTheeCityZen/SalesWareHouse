use SalesWH

select top 2 * from bronze.crm_cust_info
select top 2 * from bronze.erp_cust_az12
select top 2 * from bronze.erp_cust_loc_a101

---------------------------------cust_info-------------------------
--primary key check

select
cst_id,count(*) as count
from bronze.crm_cust_info
group by cst_id
having count(*)>1


select * from  bronze.crm_cust_info where cst_id in(29466)

--select recent customer info based on create date. Exclude rows with null PK
select
*
from
(
	select 
	* ,
	rank() over(partition by cst_id order by cst_create_date desc) as ranked
	from  bronze.crm_cust_info
) t
where ranked = 1 and  cst_id is not null



--Check for whitespaces in our text columns: first and last name

select 
*
from  bronze.crm_cust_info 
where cst_lastname != trim(cst_lastname)

select* from
(
	select 
	*,
	trim(cst_lastname) as trimmed
	from  bronze.crm_cust_info 
	where cst_lastname != trim(cst_lastname)
) t where trimmed!=trim(cst_lastname)


--Data standardization using case statements

select distinct cst_marital_status from  bronze.crm_cust_info
select distinct cst_gndr from  bronze.crm_cust_info

select 
cst_marital_status,
case when cst_marital_status='M' then 'Married'
	 when cst_marital_status='S' then 'Single'
	 else 'n/a' end as marital_status
from  bronze.crm_cust_info

select 
cst_gndr,
case when upper(cst_gndr)='F' then 'Female'
	 when upper(cst_gndr)='M' then 'Male'
	 else 'n/a' 
end as gender
from  bronze.crm_cust_info


-------------------------------------------------------------------------------------------
select * from  bronze.crm_cust_info 

select
cst_id as customer_id,
cst_key as customer_key,
trim(cst_firstname)as first_name,
trim(cst_lastname) as last_name,
case when upper(cst_marital_status)='M' then 'Married'
	 when upper(cst_marital_status)='S' then 'Single'
	 else 'n/a' 
end as marital_status,
case when upper(cst_gndr)='F' then 'Female'
	 when upper(cst_gndr)='M' then 'Male'
	 else 'n/a' 
end as gender,
cast(cst_create_date as date) as create_date,
_created_at,
_source_system
from
(
	select 
	* ,
	rank() over(partition by cst_id order by cst_create_date desc) as ranked
	from  bronze.crm_cust_info
) t
where ranked = 1 and  cst_id is not null


---------------------------------cust_erp-------------------------
select * from bronze.erp_cust_az12;
--primary key check

select
cid,count(*) as count
from bronze.erp_cust_az12
group by cid
having count(*)>1

--low cardinality gender
select distinct gen  from bronze.erp_cust_az12


select distinct gender from
(select 
gen,
coalesce(case  trim(gen)
	  when'F' then 'Female'
	  when'M' then 'Male'
	  when '' then NULL
	  else trim(gen)
end,'n/a') as gender
from bronze.erp_cust_az12) t




--generate key to be used to connect with customer_id from cust_info table

select
cid,
case when cid like 'NAS%' then SUBSTRING(cid,4,len(cid))
	 else cid
end as customer_key
from bronze.erp_cust_az12

-------------------------------------------------------------------------
select 
cid as customer_id,
case when cid like 'NAS%' then SUBSTRING(cid,4,len(cid))
	 else cid
end as customer_key,
cast(bdate as date) as birth_date,
coalesce(case  trim(gen)
	  when'F' then 'Female'
	  when'M' then 'Male'
	  when '' then NULL
	  else trim(gen)
end,'n/a') as gender,
_created_at,
_source_system
from bronze.erp_cust_az12



---------------------------------cust_loc-------------------------
select * from bronze.erp_cust_loc_a101
--primary key check

select
cid,count(*) as count
from bronze.erp_cust_loc_a101
group by cid
having count(*)>1

select 
REPLACE(cid,'-','') as customer_id,
trim(cntry) as country,
_created_at,
_source_system
from  bronze.erp_cust_loc_a101

--checks for referential intergrity
select 
*
from silver.customer_master mast
left join silver.customer_info info
on mast.customer_key=info.customer_key
left join silver.customer_locations loc
on mast.customer_key=loc.customer_key
where info.customer_key is null or loc.customer_key is null





select top 2 * from bronze.crm_prd_info
select top 2 * from bronze.erp_cat_g1v2
select top 2 * from bronze.crm_sales_details

---------------------------------Products-------------------------
select * from bronze.crm_prd_info
--primary key check

select
prd_id,count(*) as count
from bronze.crm_prd_info
group by prd_id
having count(*)>1

select
prd_key,count(*) as count
from bronze.crm_prd_info
group by prd_key
having count(*)>1

select * from bronze.crm_prd_info  where prd_key in ('AC-HE-HL-U509','CO-RF-FR-R38B-60')
--SCDs with prd_id as the surrogate key

select
prd_id,prd_key,count(*) as count
from bronze.crm_prd_info
group by prd_id,prd_key
having count(*)>1
--composite
--Products with start date > end date
select 
*,
dateadd(day,-1,lead(prd_start_date) over(partition by prd_key order by prd_start_date)) as end_date
from bronze.crm_prd_info
where  prd_key in ('AC-HE-HL-U509','CO-RF-FR-R38B-60')

--keys for later joins to category and sales
select 
prd_key,
substring(prd_key,1,5) as cat_id,
substring(prd_key,7,len(prd_key)) as prdoduct_key
from bronze.crm_prd_info

select
prd_id as product_id,
prd_key as product_key,
substring(prd_key,1,5) as cat_id,
substring(prd_key,7,len(prd_key)) as _product_key,
trim(prd_nm) as product_number,
prd_cost as product_cost,
trim(prd_line) as product_line,
cast(prd_start_date as date) as start_date,
cast(dateadd(day,-1,lead(prd_start_date) over(partition by prd_key order by prd_start_date)) as date) as end_date,
_created_at,
_source_system
from bronze.crm_prd_info
order by prd_key

---------------------------------Product categories-------------------------
select * from bronze.erp_cat_g1v2
--primary key check

select
id,count(*) as count
from bronze.erp_cat_g1v2
group by id
having count(*)>1

select 
replace(id,'_','-') as cat_id,
trim(cat) as category,
trim(subcat) as subcategory,
maintanance,
_created_at,
_source_system
from bronze.erp_cat_g1v2



--checks for referential intergrity
select 
* 
from silver.products pr
left join silver.product_categories cat
on pr.cat_id=cat.cat_id
where cat.cat_id is null


---------------------------------Sale Details-------------------------
select * from bronze.crm_sales_details where sls_ord_num='SO55367'
--primary key check

select
sls_ord_num,count(*) as count
from bronze.crm_sales_details
group by sls_ord_num
having count(*)>1
--composite
select
sls_ord_num,sls_prd_key,count(*) as count
from bronze.crm_sales_details
group by sls_ord_num,sls_prd_key
having count(*)>1

--order of order,ship and due dates
select 
*
from 
bronze.crm_sales_details
where sls_order_dt>sls_ship_dt or sls_ship_dt>sls_due_dt or sls_order_dt>sls_due_dt

--convert order,ship and due dates to dates

select * from(
select
sls_order_dt,
case when len(sls_order_dt)!=8 then null
	else cast(sls_order_dt as date)
end as order_date,
sls_ship_dt,
case when len(sls_ship_dt)!=8 then null
	else cast(sls_ship_dt as date)
end as shipping_date,
sls_due_dt,
case when len(sls_due_dt)!=8 then null
	else cast(sls_due_dt as date)
end as due_date
from bronze.crm_sales_details) t
where order_date is null or shipping_date is null or due_date is null

--data intergrity checks for price,quantity and sales
select 
sls_quantity,sls_price,sls_sales
from bronze.crm_sales_details
where 
sls_quantity is null or sls_price is null or sls_sales is null or 
sls_quantity <= 0 or sls_price<=0 or sls_sales<=0 or 
sls_sales!=cast(sls_quantity as float)*sls_price
order by 3,2,1

select 
case when sls_sales is null then  sls_quantity*abs(sls_price)
	 when sls_sales!=sls_quantity*cast(sls_price  as float) then sls_quantity*abs(sls_price)
	 else sls_sales
end as sales,
abs(sls_quantity) as quantity,
case when sls_price is null or sls_price=0 then abs(sls_sales)/sls_quantity
     when sls_price<0 then abs(sls_price)
	 else sls_price
end as price
from bronze.crm_sales_details
where 
sls_quantity is null or sls_price is null or sls_sales is null or 
sls_quantity <= 0 or sls_price<=0 or sls_sales<=0 or 
sls_sales!=cast(sls_quantity as float)*sls_price

--final
select 
sls_ord_num as order_number,
sls_prd_key as product_key,
sls_cust_id as customer_id,
case when len(sls_order_dt)!=8 then null
	else cast(sls_order_dt as date)
end as order_date,
sls_ship_dt,
case when len(sls_ship_dt)!=8 then null
	else cast(sls_ship_dt as date)
end as shipping_date,
sls_due_dt,
case when len(sls_due_dt)!=8 then null
	else cast(sls_due_dt as date)
end as due_date,
case when sls_sales is null then  sls_quantity*abs(sls_price)
	 when sls_sales!=sls_quantity*cast(sls_price  as float) then sls_quantity*abs(sls_price)
	 else sls_sales
end as sales,
abs(sls_quantity) as quantity,
case when sls_price is null or sls_price=0 then abs(sls_sales)/sls_quantity
     when sls_price<0 then abs(sls_price)
	 else sls_price
end as price,
_created_at,
_source_system
from  bronze.crm_sales_details


--checks for referential intergrity
select
sales.*,
pr.*,
cust.*
from silver.sales
left join silver.products pr
on sales.product_key=pr._product_key
left join silver.customer_master cust
on sales.customer_id=cust.customer_id
where pr._product_key is null or cust.customer_id is null

select top 2 * from silver.sales
select top 2 * from silver.products
select top 2 * from silver.customer_master