CREATE OR ALTER PROCEDURE sp_load_silver AS
BEGIN

	BEGIN TRY
		DECLARE @start DATETIME, @end DATETIME, @batchStart DATETIME, @batchEnd DATETIME;
	
		PRINT '==================================================================================='
		PRINT 'LOADING INTO SILVER CRM';
		PRINT '==================================================================================='
		SET @batchStart = GETDATE();


		PRINT '>>TRUNCATING silver.crm_cust_info';
		SET @start = GETDATE();
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>>INSERTING INTO silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) cst_firstname,
			TRIM(cst_lastname) cst_lastname,
			CASE
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				ELSE 'n/a'
			END cst_marital_status,
			CASE
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n/a'
			END cst_gndr,
			cst_create_date
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) t
		WHERE flag_last = 1;
		SET @end = GETDATE();
		PRINT 'TIME TO LOAD: ' + CAST(DATEDIFF(second, @start, @end) AS VARCHAR);



		SET @start = GETDATE();
		PRINT 'TRUNCATING silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT 'INSERTING INTO silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info(prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
			TRIM(prd_nm) AS prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountains'
				WHEN 'T' THEN 'Touring'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'R' THEN 'Road'
				ELSE 'n/a'
			END AS prd_line,
			prd_start_dt,
			LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) as prd_end_dt
		FROM bronze.crm_prd_info;
		SET @end = GETDATE();
		PRINT 'TIME TO LOAD: ' + CAST(DATEDIFF(second, @start, @end) AS VARCHAR);



		SET @start = GETDATE();
		PRINT 'TRUNCATING silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT 'INSERTING INTO silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE
				WHEN sls_order_dt <= 0 OR len(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE
				WHEN sls_ship_dt <= 0 OR len(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE
				WHEN sls_due_dt <= 0 OR len(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE 
				WHEN sls_sales <= 0 OR sls_sales IS NULL  OR sls_sales != (sls_quantitiy / sls_price)
					THEN ABS(sls_price) / sls_quantitiy
				ELSE sls_sales
			END AS sls_sales,
			sls_quantitiy,
			CASE 
				WHEN sls_price <= 0 OR sls_price IS NULL  OR sls_price != (sls_quantitiy * sls_sales) 
					THEN ABS(sls_sales) * sls_quantitiy
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;
		SET @end = GETDATE();
		PRINT 'TIME TO LOAD: ' + CAST(DATEDIFF(second, @start, @end) AS VARCHAR);

		SET @batchend = GETDATE();
		PRINT 'TOTAL TIME TO LOAD IN CRM: ' + CAST(DATEDIFF(second, @batchStart, @batchEnd) AS VARCHAR);



		PRINT '==================================================================================='
		PRINT 'LOADING INTO SILVER ERP';
		PRINT '==================================================================================='
		SET @batchStart = GETDATE();

		SET @start = GETDATE();
		PRINT 'TRUNCATING silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT 'INSERTING INTO silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12(cid, bdate, gen)
		SELECT
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				ELSE cid
			END cid,
			CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END bdate,
			CASE
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'n/a'
			END gen
		FROM bronze.erp_cust_az12;
		SET @end = GETDATE();
		PRINT 'TIME TO LOAD: ' + CAST(DATEDIFF(second, @start, @end) AS VARCHAR);


		SET @start = GETDATE();
		PRINT 'TRUNCATING silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT 'INSERTING INTO silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101(cid, cntry)
		SELECT 
			REPLACE(cid, '-', '') cid,
			CASE 
				WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END AS cntry
		FROM bronze.erp_loc_a101;
		SET @end = GETDATE();
		PRINT 'TIME TO LOAD: ' + CAST(DATEDIFF(second, @start, @end) AS VARCHAR);



		SET @start = GETDATE()
		PRINT 'TRUNCATING silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT 'INSERTING INTO silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2(id, cat, subcat, maintenance)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;
		SET @end = GETDATE();
		PRINT 'TIME TO LOAD: ' + CAST(DATEDIFF(second, @start, @end) AS VARCHAR(50));

		SET @batchend = GETDATE();
		PRINT 'TOTAL TIME TO LOAD IN ERP: ' + CAST(DATEDIFF(second, @batchStart, @batchEnd) AS VARCHAR);
	END TRY

	BEGIN CATCH
		PRINT 'AN ERROR OCCURRED!!!';
		PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS VARCHAR(50))
	END CATCH
END;

EXEC sp_load_silver;
