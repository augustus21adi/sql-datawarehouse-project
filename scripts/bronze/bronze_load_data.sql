


CREATE OR ALTER PROCEDURE sp_dataload AS
BEGIN

	BEGIN TRY
		DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
		PRINT '============================================================================';
		PRINT 'LOADING IN BRONZE LAYER';
		PRINT '============================================================================';

		PRINT '----------------------------------------------------------------------------';
		PRINT 'LOADING FROM CRM';
		PRINT '----------------------------------------------------------------------------';

		SET @batch_start_time = GETDATE();

		SET @start_time = GETDATE();
		PRINT '>> LOADING IN CUST_INFO';
		TRUNCATE TABLE bronze.crm_cust_info;
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\adiau\OneDrive\Desktop\dwh_project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		--SELECT * FROM bronze.crm_cust_info;
		--SELECT COUNT(*) FROM bronze.crm_cust_info;
		SET @end_time = GETDATE();
		PRINT 'TOTAL TIME TAKEN: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' SECONDS';


		SET @start_time = GETDATE();
		PRINT '>>LOADING IN PRD_INFO';
		TRUNCATE TABLE bronze.crm_prd_info;
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\adiau\OneDrive\Desktop\dwh_project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		--SELECT * FROM bronze.crm_prd_info;
		--SELECT COUNT(*) FROM bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT 'TOTAL TIME TAKEN: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' SECONDS';



		SET @start_time = GETDATE();
		PRINT '>>LOADING IN SALES_DETAILS';
		TRUNCATE TABLE bronze.crm_sales_details;
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\adiau\OneDrive\Desktop\dwh_project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		--SELECT * FROM bronze.crm_sales_details;
		--SELECT COUNT(*) FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT 'TOTAL TIME TAKEN: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' SECONDS';
		
		SET @batch_end_time = GETDATE()
		PRINT 'TOTAL BATCH TIME TAKEN: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' SECONDS';



		PRINT '----------------------------------------------------------------------------';
		PRINT 'LOADING FROM ERP';
		PRINT '----------------------------------------------------------------------------';

		SET @batch_start_time = GETDATE();


		SET @start_time = GETDATE();
		PRINT '>>LOADING IN CUST_AZ12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\adiau\OneDrive\Desktop\dwh_project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		--SELECT * FROM bronze.erp_cust_az12;
		--SELECT COUNT(*) FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT 'TOTAL TIME TAKEN: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' SECONDS';


		SET @start_time = GETDATE();
		PRINT '>>LOADING IN ERP_LOC_A101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\adiau\OneDrive\Desktop\dwh_project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		--SELECT * FROM bronze.erp_loc_a101;
		--SELECT COUNT(*) FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT 'TOTAL TIME TAKEN: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' SECONDS';


		SET @start_time = GETDATE();
		PRINT '>>LOADING IN PX_CAT_G1V2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\adiau\OneDrive\Desktop\dwh_project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		--SELECT * FROM bronze.erp_px_cat_g1v2;
		--SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT 'TOTAL TIME TAKEN: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' SECONDS';

		SET @batch_end_time = GETDATE()
		PRINT 'TOTAL BATCH TIME TAKEN: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' SECONDS';
	END TRY

	BEGIN CATCH
		PRINT 'ERROR OCCURRED';
		PRINT 'ERROR: ' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS INT);
	END CATCH;
END;


EXEC sp_dataload;
