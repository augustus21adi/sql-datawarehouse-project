IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW gold.dim_customers;

GO
CREATE VIEW gold.dim_customers AS(
	SELECT 
		ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
		ci.cst_id AS Customer_id,
		ci.cst_key AS Customer_number,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS lat_name,
		la.cntry AS country,
		ci.cst_marital_status AS marital_status,
		CASE 
			WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
			ELSE COALESCE(ca.gen, 'n/a')
		END AS gender, 
		ca.bdate AS birthdate,
		ci.cst_create_date AS creat_date
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca
	ON		  ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
	ON		  ci.cst_key = la.cid
);

--SELECT * FROM gold.dim_customers;




IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
	DROP VIEW gold.dim_products;


GO
CREATE VIEW gold.dim_products AS (
	SELECT 
		ROW_NUMBER() OVER(ORDER BY prd_id, cat_id) AS product_key,
		pn.prd_id AS product_id,
		pn.prd_key AS product_number,
		pn.prd_nm AS product_name,
		pn.prd_cost AS product_cost,
		pn.prd_line AS product_line,
		pn.cat_id AS category_id,
		pc.cat AS product_category,
		pc.subcat AS product_subcategory,
		pc.maintenance AS product_maintenance,
		pn.prd_start_dt AS product_start_date
	FROM silver.crm_prd_info pn
	LEFT JOIN silver.erp_px_cat_g1v2 pc
	ON pn.cat_id = pc.id
	WHERE prd_end_dt IS NULL
);


--SELECT * FROM gold.dim_products;


IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW gold.fact_sales;


GO
CREATE VIEW gold.fact_sales AS (
SELECT 
	s.sls_ord_num AS sales_order_number,
	p.product_key,
	c.customer_key,
	s.sls_order_dt AS order_date,
	s.sls_ship_dt AS ship_date,
	s.sls_due_dt AS due_date,
	s.sls_sales AS sales,
	s.sls_quantity AS quantity,
	s.sls_price AS price
FROM silver.crm_sales_details s
LEFT JOIN gold.dim_customers c
ON s.sls_cust_id = c.customer_id
LEFT JOIN gold.dim_products p
ON s.sls_prd_key = p.product_number
);

--select * from silver.crm_sales_details;
--SELECT * FROM gold.fact_sales;
