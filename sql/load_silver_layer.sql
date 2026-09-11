use SalesWH;
go

create procedure etl.load_silver as
begin
	begin try
		print('---------------------------BATCH START---------------------------')
		declare @batch_start_time datetime2,@batch_end_time datetime2,@batch_ingestion_time bigint,
		@start_time datetime2,@end_time datetime2,@ingestion_time bigint,
		@batch_id bigint, @table_id bigint,
		@source_rows bigint, @target_rows bigint

		set @batch_start_time=GETDATE()
		insert into etl.batch_log
		(pipeline_name,start_time,status)
		values
		('LOAD SILVER',@batch_start_time,'RUNNING')
		set @batch_id=SCOPE_IDENTITY()
		print('Batch : '+ cast(@batch_id as varchar))


		--__________________Customer Master_______________________

		set @source_rows=null  set @target_rows=null
		print('_______________Customer Master : Start_______________')
		set @start_time=GETDATE()
		insert into etl.table_log
		(batch_id,start_time,status,target_table)
		values
		(@batch_id,@start_time,'RUNNING','silver.customer_master')
		set @table_id=SCOPE_IDENTITY()
		print('Table ID: '+ cast(@table_id as varchar))

		print('Truncating our table for our Full Refresh Ingestion')
		truncate table silver.customer_master

		insert into silver.customer_master
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
		set @target_rows=@@ROWCOUNT
		set @source_rows=(select count(*) from bronze.crm_cust_info)
		print('Inserted '+cast(@target_rows as varchar)+' rows successfully')


		set @end_time=GETDATE()
		set @ingestion_time=DATEDIFF(MILLISECOND,@start_time,@end_time)
		update etl.table_log set
		end_time=@end_time,
		duration=@ingestion_time,
		status='SUCCESS',
		source_rows=@source_rows,
		target_rows=@target_rows
		where table_load_id=@table_id

		--__________________Customer informations_______________________

		set @source_rows=null  set @target_rows=null
		print('_______________Customer Informations : Start_______________')
		set @start_time=GETDATE()
		insert into etl.table_log
		(batch_id,start_time,status,target_table)
		values
		(@batch_id,@start_time,'RUNNING','silver.customer_info')
		set @table_id=SCOPE_IDENTITY()
		print('Table ID: '+ cast(@table_id as varchar))

		print('Truncating our table for our Full Refresh Ingestion')
		truncate table silver.customer_info

		insert into silver.customer_info
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

		set @target_rows=@@ROWCOUNT
		set @source_rows=(select count(*) from bronze.erp_cust_az12)
		print('Inserted '+cast(@target_rows as varchar)+' rows successfully')


		set @end_time=GETDATE()
		set @ingestion_time=DATEDIFF(MILLISECOND,@start_time,@end_time)
		update etl.table_log set
		end_time=@end_time,
		duration=@ingestion_time,
		status='SUCCESS',
		source_rows=@source_rows,
		target_rows=@target_rows
		where table_load_id=@table_id


		--__________________Customer Locations _______________________

		set @source_rows=null  set @target_rows=null
		print('_______________Customer Locations : Start_______________')
		set @start_time=GETDATE()
		insert into etl.table_log
		(batch_id,start_time,status,target_table)
		values
		(@batch_id,@start_time,'RUNNING','silver.customer_locations')
		set @table_id=SCOPE_IDENTITY()
		print('Table ID: '+ cast(@table_id as varchar))


		print('Truncating our table for our Full Refresh Ingestion')
		truncate table silver.customer_locations

		insert into silver.customer_locations
		select 
		REPLACE(cid,'-','') as customer_key,
		trim(cntry) as country,
		_created_at,
		_source_system
		from  bronze.erp_cust_loc_a101

		set @target_rows=@@ROWCOUNT
		set @source_rows=(select count(*) from bronze.erp_cust_loc_a101)
		print('Inserted '+cast(@target_rows as varchar)+' rows successfully')


		set @end_time=GETDATE()
		set @ingestion_time=DATEDIFF(MILLISECOND,@start_time,@end_time)
		update etl.table_log set
		end_time=@end_time,
		duration=@ingestion_time,
		status='SUCCESS',
		source_rows=@source_rows,
		target_rows=@target_rows
		where table_load_id=@table_id

		--__________________Products _______________________

		set @source_rows=null  set @target_rows=null
		print('_______________Products : Start_______________')
		set @start_time=GETDATE()
		insert into etl.table_log
		(batch_id,start_time,status,target_table)
		values
		(@batch_id,@start_time,'RUNNING','silver.products')
		set @table_id=SCOPE_IDENTITY()
		print('Table ID: '+ cast(@table_id as varchar))

	
		print('Truncating our table for our Full Refresh Ingestion')
		truncate table silver.products

		insert into silver.products
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
		cast(prd_end_date as date) ,
		_created_at,
		_source_system
		from bronze.crm_prd_info

		set @target_rows=@@ROWCOUNT
		set @source_rows=(select count(*) from bronze.crm_prd_info)
		print('Inserted '+cast(@target_rows as varchar)+' rows successfully')


		set @end_time=GETDATE()
		set @ingestion_time=DATEDIFF(MILLISECOND,@start_time,@end_time)
		update etl.table_log set
		end_time=@end_time,
		duration=@ingestion_time,
		status='SUCCESS',
		source_rows=@source_rows,
		target_rows=@target_rows
		where table_load_id=@table_id



		--__________________Product Categories _______________________

		set @source_rows=null  set @target_rows=null
		print('_______________Product Categories: Start_______________')
		set @start_time=GETDATE()
		insert into etl.table_log
		(batch_id,start_time,status,target_table)
		values
		(@batch_id,@start_time,'RUNNING','silver.product_categories')
		set @table_id=SCOPE_IDENTITY()
		print('Table ID: '+ cast(@table_id as varchar))
	
		print('Truncating our table for our Full Refresh Ingestion')
		truncate table silver.product_categories

		insert into silver.product_categories
		select 
		replace(id,'_','-') as cat_id,
		trim(cat) as category,
		trim(subcat) as subcategory,
		maintanance,
		_created_at,
		_source_system
		from bronze.erp_cat_g1v2

		set @target_rows=@@ROWCOUNT
		set @source_rows=(select count(*) from bronze.erp_cat_g1v2)
		print('Inserted '+cast(@target_rows as varchar)+' rows successfully')


		set @end_time=GETDATE()
		set @ingestion_time=DATEDIFF(MILLISECOND,@start_time,@end_time)
		update etl.table_log set
		end_time=@end_time,
		duration=@ingestion_time,
		status='SUCCESS',
		source_rows=@source_rows,
		target_rows=@target_rows
		where table_load_id=@table_id

		--__________________Sales _______________________

		set @source_rows=null  set @target_rows=null
		print('_______________Sales : Start_______________')
		set @start_time=GETDATE()
		insert into etl.table_log
		(batch_id,start_time,status,target_table)
		values
		(@batch_id,@start_time,'RUNNING','silver.sales')
		set @table_id=SCOPE_IDENTITY()
		print('Table ID: '+ cast(@table_id as varchar))

		print('Truncating our table for our Full Refresh Ingestion')
		truncate table silver.sales

		insert into silver.sales
		select 
		sls_ord_num as order_number,
		sls_prd_key as product_key,
		sls_cust_id as customer_id,
		case when len(sls_order_dt)!=8 then null
			else cast(sls_order_dt as date)
		end as order_date,
		case when len(sls_ship_dt)!=8 then null
			else cast(sls_ship_dt as date)
		end as shipping_date,
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

		set @target_rows=@@ROWCOUNT
		set @source_rows=(select count(*) from bronze.crm_sales_details)
		print('Inserted '+cast(@target_rows as varchar)+' rows successfully')


		set @end_time=GETDATE()
		set @ingestion_time=DATEDIFF(MILLISECOND,@start_time,@end_time)
		update etl.table_log set
		end_time=@end_time,
		duration=@ingestion_time,
		status='SUCCESS',
		source_rows=@source_rows,
		target_rows=@target_rows
		where table_load_id=@table_id


		-------------------- BATCH END --------------------------

		set @batch_end_time=GETDATE()
		set @batch_ingestion_time=DATEDIFF(MILLISECOND,@batch_start_time,@batch_end_time)
		update  etl.batch_log
		set end_time=@batch_end_time,
		duration=@batch_ingestion_time,
		status='SUCCESS'
		where batch_id=@batch_id
		print('---------------------------BATCH END---------------------------')
	end try

	begin catch
		declare @error_message nvarchar(2000)
		set @error_message=ERROR_MESSAGE()
		set @batch_end_time=GETDATE()
		set @batch_ingestion_time=DATEDIFF(MILLISECOND,@batch_start_time,@batch_end_time)
		set @end_time=GETDATE()
		set @ingestion_time=DATEDIFF(MILLISECOND,@start_time,@end_time)
		print(@error_message)
		print('Review Log tables for Review')

		update  etl.batch_log set 
		end_time=@batch_end_time,
		duration=@batch_ingestion_time,
		status='FAILED',
		error_message=@error_message
		where batch_id=@batch_id
	
		update etl.table_log set
		end_time=@end_time,
		duration=@ingestion_time,
		status='FAILED',
		source_rows=@source_rows,
		target_rows=@target_rows,
		error_message=@error_message
		where table_load_id=@table_id

	end catch
end





