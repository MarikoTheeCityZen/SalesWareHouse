use SalesWH;
go

create  or alter procedure etl.load_gold as 
begin
	declare @batch_start_time datetime2(3),@batch_end_time datetime2(3),@batch_ingestion_time int,@batch_id bigint,
    @start_time datetime2(3),@end_time datetime2(3),@ingestion_time int,@table_id bigint,@target_rows int
	begin try
		print('_________________________START_________________________')
		set @batch_start_time=getdate()
		insert into etl.batch_log
		(pipeline_name,start_time,status)
		values
		('LOAD GOLD LAYER',@batch_start_time,'RUNNING')
		set @batch_id=@@IDENTITY

		set @start_time=GETDATE()
		insert into etl.table_log
		(batch_id,target_table,status,start_time)
		values
		(@batch_id,'gold.dim_products','running',@start_time)
		set @table_id=@@IDENTITY

		print('Truncating our Products dimensions for a full refresh')
		truncate table gold.dim_products
		print('Inserting our Products data')
		insert into gold.dim_products
		(product_id,product_key,category_id,_product_key,product_number,category,
		subcategory,product_line,maintanance,product_cost,start_date,end_date
		)
		select 
		prod.product_id as product_id,
		prod.product_key as product_key,
		prod.cat_id as category_id,
		prod._product_key as _product_key,
		prod.product_number as product_number,
		cats.category as category,
		cats.subcategory as subcategory,
		prod.product_line as product_line,
		cats.maintanance as maintanance,
		prod.product_cost as product_cost,
		prod.start_date as start_date,
		prod.end_date as end_date
		from silver.products prod
		left join silver.product_categories cats
		on prod.cat_id=cats.cat_id
		set @target_rows=@@ROWCOUNT



		set @end_time=getdate()
		set @ingestion_time=DATEDIFF(MILLISECOND,@start_time,@end_time)
		print('Products fully loaded in '+cast(@ingestion_time as varchar)+' milliseconds')
		update etl.table_log set
		end_time=@end_time,duration=@ingestion_time,status='SUCCESS',target_rows=@target_rows
		where table_load_id=@table_id

		

		set @start_time=GETDATE()
		insert into etl.table_log
		(batch_id,target_table,status,start_time)
		values
		(@batch_id,'gold.dim_customers','running',@start_time)
		set @table_id=@@IDENTITY

		print('Truncating our Customers dimensions for a full refresh')
		truncate table gold.dim_customers
		print('Inserting our Customers data')
		insert into gold.dim_customers
		(customer_id,customer_key,first_name,last_name,gender,marital_status,country,birthdate,create_date)
		select 
		mast.customer_id as customer_id,
		mast.customer_key as customer_key,
		mast.cst_firstname as first_name,
		mast.cst_lastname as last_name,
		case when nullif(info.gender,'n/a') is not null then info.gender
			else mast.cst_gndr
		end as gender,
		mast.cst_marital_status as marital_status,
		locs.country as country,
		info.birthdate as birthdate,
		mast.cst_create_date as create_date
		from silver.customer_master mast
		left join silver.customer_info info
		on mast.customer_key=info.customer_key
		left join silver.customer_locations locs
		on mast.customer_key=locs.customer_key;
		set @target_rows=@@ROWCOUNT

		set @end_time=getdate()
		set @ingestion_time=DATEDIFF(MILLISECOND,@start_time,@end_time)
		print('Customers fully loaded in '+cast(@ingestion_time as varchar)+' milliseconds')
		update etl.table_log set
		end_time=@end_time,duration=@ingestion_time,status='SUCCESS',target_rows=@target_rows
		where table_load_id=@table_id


		set @start_time=GETDATE()
		insert into etl.table_log
		(batch_id,target_table,status,start_time)
		values
		(@batch_id,'gold.fact_sales','running',@start_time)
		set @table_id=@@IDENTITY

		print('Truncating our Fact table for a full refresh: ')
		truncate table gold.fact_sales
		print('Inserting our Fact data : Sales')
		insert into gold.fact_sales
		(order_number,customer_id,product_key,order_date,ship_date,due_date,quantity,price,sales)
		select 
		order_number,
		customer_id,
		product_key,
		order_date,
		ship_date,
		due_date,
		quantity,
		price,
		sales
		from silver.sales
		set @target_rows=@@ROWCOUNT
		
		set @end_time=getdate()
		set @ingestion_time=DATEDIFF(MILLISECOND,@start_time,@end_time)
		print('Orders fully loaded in '+cast(@ingestion_time as varchar)+' milliseconds')
		update etl.table_log set
		end_time=@end_time,duration=@ingestion_time,status='SUCCESS',target_rows=@target_rows
		where table_load_id=@table_id

		set @batch_end_time=getdate()
		set @batch_ingestion_time=DATEDIFF(MILLISECOND,@batch_start_time,@batch_end_time)
		update  etl.batch_log
		set
		end_time=@batch_end_time,status='SUCCESS',duration=@batch_ingestion_time
		where batch_id=@batch_id

		print('Model fully loaded in : '+cast(@batch_ingestion_time as varchar)+ ' seconds')
		print('_________________________END_________________________')
	end try
	begin catch
		declare @error_message nvarchar(3000)
		set @error_message=ERROR_MESSAGE()
		set @batch_end_time=getdate()

		set @batch_ingestion_time=DATEDIFF(MILLISECOND,@batch_start_time,@batch_end_time)
		update  etl.batch_log set
		end_time=@batch_end_time,status='FAILED',duration=@batch_ingestion_time,error_message=@error_message
		where batch_id=@batch_id

		--set @end_time=getdate()
		set @ingestion_time=DATEDIFF(MILLISECOND,@start_time,@batch_end_time)
		--print('Products fully loaded in '+cast(@ingestion_time as varchar)+' milliseconds')
		update etl.table_log set
		end_time=@end_time,duration=@ingestion_time,status='FAILED',error_message=@error_message
		where table_load_id=@table_id

		print(@error_message)

	end catch
end
