use SalesWH;
go
create or alter procedure load_bronze as
begin
	begin try
		declare @start_time datetime2 , @end_time datetime2 ,@ingestion_time int , @table_load_id bigint,
		@batch_start_time datetime2 , @batch_end_time datetime2 , @batch_ingestion_time int , @batch_id bigint,
		@load_row_count int , @bronze_row_count int ,@target_table varchar(100)


		print('____________________________________START___________________________________');
		print('              ');
		print('                ');


		set @batch_start_time=GETDATE()
		insert into etl.batch_log
		(
		pipeline_name,start_time,status
		)
		values
		('Landing+Bronze FullLoad',@batch_start_time,'RUNNING');
		set @batch_id=SCOPE_IDENTITY()
		print('batch ID : '+ cast(@batch_id as varchar(20)))

		print('*************************************************************')
		set @start_time=getdate()
		set @load_row_count = NULL
		set @bronze_row_count = NULL
		insert into etl.table_log
		(batch_id,start_time,status,source_file,target_table)
		values
		(@batch_id,@start_time,'RUNNING','\source_crm\cust_info.csv','landing.crm_cust_info_load');
		set @table_load_id=SCOPE_IDENTITY()
		print('Table load ID : '+cast(@table_load_id as varchar(20)))

		print('Truncating landing table : crm_cust_info_load');
		truncate table landing.crm_cust_info_load;
		print('Inserting data into our loading table');
		bulk insert landing.crm_cust_info_load
		from 'C:\Users\Administrator\Desktop\LearningMaterials\data_engineering\customers_crp_erp\datasets\source_crm\cust_info.csv'
		with
		(
		firstrow=2,
		fieldterminator=',',
		tablock
		);
		set @load_row_count=@@ROWCOUNT
		print('Truncating our  bronze table : crm_cust_info');
		truncate table bronze.crm_cust_info;
		print('Inserting customer info into our crm_cust_info table with the metadata cols')
		insert into bronze.crm_cust_info
		(
		cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date
		)
		select 
		cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,TRY_CONVERT(date,cst_create_date) as cst_create_date
		from landing.crm_cust_info_load;

		set @bronze_row_count=@@ROWCOUNT

		set @end_time=getdate()
		if @load_row_count=@bronze_row_count
		begin
			set @ingestion_time=datediff(MILLISECOND,@start_time,@end_time)
			print('Row count Validation : SUCCESSS')
			print('Loaded '+ cast(@load_row_count as varchar(20)) + ' rows into our landing table')
			print('Inserted '+ cast(@bronze_row_count as varchar(20)) + ' rows into our bronze table')
			print('loaded customer info in '+ cast(@ingestion_time as varchar(20)) +' milli_seconds')
			update  etl.table_log
			set
			status='SUCCESS',
			source_rows=@load_row_count,
			target_rows=@bronze_row_count,
			duration=@ingestion_time,
			end_time=@end_time
			where table_load_id=@table_load_id
		end
		else
		begin
		/*
			update  etl.table_log
			set
			status='FAILED',
			landing_rows=@load_row_count,
			bronze_rows=@bronze_row_count,
			duration=@ingestion_time,
			end_time=@end_time,
			error_message = 'Landing row count does not match Bronze row count.'
			where table_load_id=@table_load_id */
			print('Row count Validation : FAILURE')
			print ('Landing Rows: '+ cast(@load_row_count as varchar(20)))
			print ('Bronze Rows: '+ cast(@bronze_row_count as varchar(20)));
			throw 50001,'Landing row count does not match Bronze row count.',1;
		end
		print('*************************************************************')



		print('*************************************************************')
		set @start_time=getdate()
		set @load_row_count = NULL;
		set @bronze_row_count = NULL;
		insert into etl.table_log
		(batch_id,start_time,status,source_file,target_table)
		values
		(@batch_id,@start_time,'RUNNING','\source_crm\prd_info.csv','landing.crm_prd_info_load');
		set @table_load_id=SCOPE_IDENTITY()
		print('Table load ID : '+cast(@table_load_id as varchar(20)))

		print('Truncating landing table : crm_prd_info_load');
		truncate table landing.crm_prd_info_load;
		print('Inserting data into our loading table');
		bulk insert landing.crm_prd_info_load
		from 'C:\Users\Administrator\Desktop\LearningMaterials\data_engineering\customers_crp_erp\datasets\source_crm\prd_info.csv'
		with
		(
		firstrow=2,
		fieldterminator=',',
		tablock
		);
		set @load_row_count=@@ROWCOUNT
		print('Truncating our  bronze table : crm_prd_info');
		truncate table bronze.crm_prd_info;
		print('Inserting product info into our crm_prd_info table with the metadata cols')
		insert into bronze.crm_prd_info
		(
		prd_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_date,prd_end_date
		)
		select * from landing.crm_prd_info_load;

		set @bronze_row_count=@@ROWCOUNT
		set @end_time=getdate()
		if @load_row_count=@bronze_row_count
		begin
			set @ingestion_time=datediff(MILLISECOND,@start_time,@end_time)
			print('Row count Validation : SUCCESSS')
			print('Loaded '+ cast(@load_row_count as varchar(20)) + ' rows into our landing table')
			print('Inserted '+ cast(@bronze_row_count as varchar(20)) + ' rows into our bronze table')
			print('loaded customer info in '+ cast(@ingestion_time as varchar(20)) +' milli_seconds')
			update  etl.table_log
			set
			status='SUCCESS',
			source_rows=@load_row_count,
			target_rows=@bronze_row_count,
			duration=@ingestion_time,
			end_time=@end_time
			where table_load_id=@table_load_id
		end
		else
		begin
			print('Row count Validation : FAILURE')
			print ('Landing Rows: '+ cast(@load_row_count as varchar(20)))
			print ('Bronze Rows: '+ cast(@bronze_row_count as varchar(20)));
			throw 50001,'Landing row count does not match Bronze row count.',1;;
		end
		print('*************************************************************')


		print('*************************************************************')
		set @start_time=getdate()
		set @load_row_count = NULL;
		set @bronze_row_count = NULL;
		insert into etl.table_log
		(batch_id,start_time,status,source_file,target_table)
		values
		(@batch_id,@start_time,'RUNNING','\source_crm\sales_details.csv','landing.crm_sales_details_load');
		set @table_load_id=SCOPE_IDENTITY()
		print('Table load ID : '+cast(@table_load_id as varchar(20)))

		print('Truncating landing table : crm_sales_details_load');
		truncate table landing.crm_sales_details_load;
		print('Inserting data into our loading table');

		bulk insert landing.crm_sales_details_load
		from 'C:\Users\Administrator\Desktop\LearningMaterials\data_engineering\customers_crp_erp\datasets\source_crm\sales_details.csv'
		with
		(
		firstrow=2,
		fieldterminator=',',
		tablock
		);

		set @load_row_count=@@ROWCOUNT
		print('Truncating our  bronze table : crm_sales_details');
		truncate table bronze.crm_sales_details;
		print('Inserting orders data into our sales details table with the metadata cols')

		insert into bronze.crm_sales_details
		(
		sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price
		)
		select 
		sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price
		from landing.crm_sales_details_load;

		set @bronze_row_count=@@ROWCOUNT
		set @end_time=getdate()
		if @load_row_count=@bronze_row_count
		begin
			set @ingestion_time=datediff(MILLISECOND,@start_time,@end_time)
			print('Row count Validation : SUCCESSS')
			print('Loaded '+ cast(@load_row_count as varchar(20)) + ' rows into our landing table')
			print('Inserted '+ cast(@bronze_row_count as varchar(20)) + ' rows into our bronze table')
			print('loaded customer info in '+ cast(@ingestion_time as varchar(20)) +' milli_seconds')
			update  etl.table_log
			set
			status='SUCCESS',
			source_rows=@load_row_count,
			target_rows=@bronze_row_count,
			duration=@ingestion_time,
			end_time=@end_time
			where table_load_id=@table_load_id
		end
		else
		begin
			print('Row count Validation : FAILURE')
			print ('Landing Rows: '+ cast(@load_row_count as varchar(20)));
			print ('Bronze Rows: '+ cast(@bronze_row_count as varchar(20)));
			throw 50001,'Landing row count does not match Bronze row count.',1;;
		end
		print('*************************************************************')


		print('*************************************************************')
		set @start_time=getdate()
		set @load_row_count = NULL
		set @bronze_row_count = NULL
		insert into etl.table_log
		(batch_id,start_time,status,source_file,target_table)
		values
		(@batch_id,@start_time,'RUNNING','\source_erp\CUST_AZ12.csv','landing.erp_cust_az12_load');
		set @table_load_id=SCOPE_IDENTITY()
		print('Table load ID : '+cast(@table_load_id as varchar(20)))

		print('Truncating landing table : erp_cust_az12_load');
		truncate table landing.erp_cust_az12_load;
		print('Inserting data into our loading table');

		bulk insert landing.erp_cust_az12_load
		from 'C:\Users\Administrator\Desktop\LearningMaterials\data_engineering\customers_crp_erp\datasets\source_erp\CUST_AZ12.csv'
		with
		(
		firstrow=2,
		fieldterminator=',',
		tablock
		);
		set @load_row_count=@@ROWCOUNT

		print('Truncating our  bronze table : erp_cust_az12');
		truncate table bronze.erp_cust_az12;
		print('Inserting extra cust info  data into our cust_az12  table with the metadata cols')

		insert into bronze.erp_cust_az12
		(
		cid,bdate,gen
		)
		select 
		cid,bdate,gen
		from landing.erp_cust_az12_load;

		set @bronze_row_count=@@ROWCOUNT
		set @end_time=getdate()
		if @load_row_count=@bronze_row_count
		begin
			set @ingestion_time=datediff(MILLISECOND,@start_time,@end_time)
			print('Row count Validation : SUCCESSS')
			print('Loaded '+ cast(@load_row_count as varchar(20)) + ' rows into our landing table')
			print('Inserted '+ cast(@bronze_row_count as varchar(20)) + ' rows into our bronze table')
			print('loaded customer info in '+ cast(@ingestion_time as varchar(20)) +' milli_seconds')
			update  etl.table_log
			set
			status='SUCCESS',
			source_rows=@load_row_count,
			target_rows=@bronze_row_count,
			duration=@ingestion_time,
			end_time=@end_time
			where table_load_id=@table_load_id
		end
		else
		begin
			print('Row count Validation : FAILURE')
			print ('Landing Rows: '+ cast(@load_row_count as varchar(20)))
			print ('Bronze Rows: '+ cast(@bronze_row_count as varchar(20)));
			throw 50001,'Landing row count does not match Bronze row count.',1;;
		end
		print('************************************************************')


		print('*************************************************************')
		set @start_time=getdate()
		set @load_row_count = NULL;
		set @bronze_row_count = NULL;
		insert into etl.table_log
		(batch_id,start_time,status,source_file,target_table)
		values
		(@batch_id,@start_time,'RUNNING','\source_erp\LOC_A101.csv','landing.erp_cust_loc_a101_load');
		set @table_load_id=SCOPE_IDENTITY()
		print('Table load ID : '+cast(@table_load_id as varchar(20)))

		print('Truncating landing table : erp_cust_loc_a101_load');
		truncate table landing.erp_cust_loc_a101_load;
		print('Inserting data into our loading table');

		bulk insert landing.erp_cust_loc_a101_load
		from 'C:\Users\Administrator\Desktop\LearningMaterials\data_engineering\customers_crp_erp\datasets\source_erp\LOC_A101.csv'
		with
		(
		firstrow=2,
		fieldterminator=',',
		tablock
		);

		set @load_row_count=@@ROWCOUNT
		print('Truncating our  bronze table : erp_loc_a101');
		truncate table bronze.erp_cust_loc_a101;
		print('Inserting location  info into our erp_loc_a101  table with the metadata cols')

		insert into bronze.erp_cust_loc_a101
		(
		cid,cntry
		)
		select 
		cid,cntry
		from landing.erp_cust_loc_a101_load;

		set @bronze_row_count=@@ROWCOUNT
		set @end_time=getdate()
		if @load_row_count=@bronze_row_count
		begin
			set @ingestion_time=datediff(MILLISECOND,@start_time,@end_time)
			print('Row count Validation : SUCCESSS')
			print('Loaded '+ cast(@load_row_count as varchar(20)) + ' rows into our landing table')
			print('Inserted '+ cast(@bronze_row_count as varchar(20)) + ' rows into our bronze table')
			print('loaded customer info in '+ cast(@ingestion_time as varchar(20)) +' milli_seconds')
			update  etl.table_log
			set
			status='SUCCESS',
			source_rows=@load_row_count,
			target_rows=@bronze_row_count,
			duration=@ingestion_time,
			end_time=@end_time
			where table_load_id=@table_load_id
		end
		else
		begin
			print('Row count Validation : FAILURE')
			print ('Landing Rows: '+ cast(@load_row_count as varchar(20)))
			print ('Bronze Rows: '+ cast(@bronze_row_count as varchar(20)));
			throw 50001,'Landing row count does not match Bronze row count.',1;
		end
		print('*************************************************************')


		print('*************************************************************')
		set @start_time=getdate()
		set @load_row_count = NULL;
		set @bronze_row_count = NULL;
		insert into etl.table_log
		(batch_id,start_time,status,source_file,target_table)
		values
		(@batch_id,@start_time,'RUNNING','\source_erp\PX_CAT_G1V2.csv','landing.erp_cat_g1v2_load');
		set @table_load_id=SCOPE_IDENTITY()
		print('Table load ID : '+cast(@table_load_id as varchar(20)))

		print('Truncating landing table : erp_cat_g1v2_load');
		truncate table landing.erp_cat_g1v2_load;
		print('Inserting data into our loading table');

		bulk insert landing.erp_cat_g1v2_load
		from 'C:\Users\Administrator\Desktop\LearningMaterials\data_engineering\customers_crp_erp\datasets\source_erp\PX_CAT_G1V2.csv'
		with
		(
		firstrow=2,
		fieldterminator=',',
		tablock
		);

		set @load_row_count=@@ROWCOUNT
		print('Truncating our  bronze table : erp_cat_g1v2');
		truncate table bronze.erp_cat_g1v2;
		print('Inserting category  info into our erp_cat_g1v2  table with the metadata cols')

		insert into bronze.erp_cat_g1v2
		(
		id,cat,subcat,maintanance
		)
		select 
		id,cat,subcat,maintanance
		from landing.erp_cat_g1v2_load;

		set @bronze_row_count=@@ROWCOUNT
		set @end_time=getdate()
		if @load_row_count=@bronze_row_count
		begin
			set @ingestion_time=datediff(MILLISECOND,@start_time,@end_time)
			print('Row count Validation : SUCCESSS')
			print('Loaded '+ cast(@load_row_count as varchar(20)) + ' rows into our landing table')
			print('Inserted '+ cast(@bronze_row_count as varchar(20)) + ' rows into our bronze table')
			print('loaded customer info in '+ cast(@ingestion_time as varchar(20)) +' milli_seconds')
			update  etl.table_log
			set
			status='SUCCESS',
			source_rows=@load_row_count,
			target_rows=@bronze_row_count,
			duration=@ingestion_time,
			end_time=@end_time
			where table_load_id=@table_load_id
		end
		else
		begin
			print('Row count Validation : FAILURE')
			print ('Landing Rows: '+ cast(@load_row_count as varchar(20)))
			print ('Bronze Rows: '+ cast(@bronze_row_count as varchar(20)));
			throw 50001,'Landing row count does not match Bronze row count.',1;;
		end
		print('*************************************************************')

		set @batch_end_time=GETDATE()
		set @batch_ingestion_time=datediff(MILLISECOND,@batch_start_time,@batch_end_time)
		update etl.batch_log
		set
		end_time=@batch_end_time,
		duration=@batch_ingestion_time,
		status='SUCCESS'
		where batch_id=@batch_id;

		print('              ');
		print('                ');
		print('LOADED ALL DATA IN '+ cast(@batch_ingestion_time as varchar(20)) +' milli_seconds')
		print('____________________________________END___________________________________');
	end try

	begin catch
		declare @error_message nvarchar(4000)
		set @error_message=ERROR_MESSAGE()
		set @end_time=getdate()
		set @ingestion_time=datediff(MILLISECOND,@start_time,@end_time)
		PRINT 'Error Message: ' + @error_message

		update etl.table_log
		set error_message=@error_message,
		status='FAILED',
		end_time=@end_time,
		duration=@ingestion_time,
		source_rows=@load_row_count,
		target_rows=@bronze_row_count
		where table_load_id=@table_load_id

		set @batch_end_time=GETDATE()
		set @batch_ingestion_time=datediff(MILLISECOND,@batch_start_time,@batch_end_time)
		update etl.batch_log
		set status='FAILED',
		duration=@batch_ingestion_time,
		end_time=@batch_end_time,
		error_message = @error_message
		where batch_id=@batch_id

	end catch
end
