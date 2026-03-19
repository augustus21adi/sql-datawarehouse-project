
select *
from bronze.crm_cust_info;


SELECT
	cst_id,
	COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;




select
	cst_firstname
from bronze.crm_cust_info
where cst_firstname != trim(cst_firstname);



-- checking quality of prd_id
select 
	prd_id,
	count(*)
from bronze.crm_prd_info
group by prd_id
having count(*) > 1;


-- checkig quality of prd_key
select
	prd_key,
	substring(prd_key, 1, 5) as cat_id
from bronze.crm_prd_info
where replace(substring(prd_key, 1, 5), '-', '_') not in (
	select distinct id from bronze.erp_px_cat_g1v2
);


select distinct id from bronze.erp_px_cat_g1v2 where id = 'CO-PE';


select prd_cost
from bronze.crm_prd_info
where prd_cost < 0;




select *
from bronze.crm_sales_details;

alter table bronze.crm_sales_details
alter column sls_sales INT;

alter table bronze.crm_sales_details
alter column sls_quantitiy INT;

alter table bronze.crm_sales_details
alter column sls_price INT;

select sls_ord_num
from bronze.crm_sales_details
where trim(sls_ord_num) != sls_ord_num;

select 
	sls_prd_key
from bronze.crm_sales_details
where sls_prd_key not in (
	select prd_key
	from silver.crm_prd_info
);

select
	sls_cust_id
from bronze.crm_sales_details
where sls_cust_id not in (
	select cst_id
	from silver.crm_cust_info
);

select
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt
from bronze.crm_sales_details
where sls_order_dt <= 0 or sls_ship_dt <= 0 or sls_due_dt <= 0
	  or sls_order_dt is null or sls_ship_dt is null or sls_due_dt is null
	  or len(sls_order_dt) != 8 or len(sls_ship_dt) != 8 or len(sls_due_dt) != 8;

select 
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt
from bronze.crm_sales_details
where sls_due_dt < sls_order_dt or sls_ship_dt < sls_order_dt;


select 
	sls_sales,
	sls_quantitiy,
	sls_price
from bronze.crm_sales_details
where sls_sales * sls_quantitiy != sls_price
	or sls_sales <= 0 or sls_quantitiy <= 0 or sls_price <= 0;




select 
	cid,
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		ELSE cid
	END 

from bronze.erp_cust_az12
WHERE CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		ELSE cid
	END  not in (select cst_key from silver.crm_cust_info);

select cst_key
from silver.crm_cust_info;

select * from bronze.erp_cust_az12;

select
	bdate
from silver.erp_cust_az12
where bdate > getdate();

select distinct gen from silver.erp_cust_az12;









	select 
		REPLACE(cid, '-', '') cid,
		CASE 
			WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
			WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
			ELSE TRIM(cntry)
		END as cntry
	from bronze.erp_loc_a101;

select distinct cntry
from bronze.erp_loc_a101;






select *
from bronze.erp_px_cat_g1v2;

select *
from bronze.erp_px_cat_g1v2
where cat != trim(cat) or subcat != trim(subcat) or maintenance != trim(maintenance);

select distinct cat
from bronze.erp_px_cat_g1v2;

select distinct subcat
from bronze.erp_px_cat_g1v2;

select distinct maintenance
from bronze.erp_px_cat_g1v2;




