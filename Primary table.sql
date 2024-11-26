CREATE TABLE t_martina_palusgova_project_SQL_primary_final AS (
WITH primary_table_a AS
((SELECT 
YEAR(cp.date_from) AS rok, 
cp.value, 
cp.category_code, 
cp.region_code, 
cpc.name, 
cpc.price_value, 
cpc.price_unit AS unit_name 
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code
WHERE cp.region_code IS NOT NULL 
GROUP BY YEAR(cp.date_from), cp.category_code, cp.region_code 
ORDER BY date_from)
UNION 
(SELECT
	cp.payroll_year,
	ROUND(AVG(cp.value), 2) AS average_value,
	cp.value_type_code, 
	cpvt.name AS value_type_code_name, 
	cpib.name, 
	cp.industry_branch_code, 
	cpu.name AS unit_name 
FROM czechia_payroll cp 
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON cpib.code = cp.industry_branch_code
LEFT JOIN czechia_payroll_unit cpu 
	ON cpu.code = cp.unit_code
LEFT JOIN czechia_payroll_value_type cpvt 
	ON cpvt.code = cp.value_type_code
WHERE payroll_year BETWEEN 2006 AND 2018 AND value IS NOT NULL
GROUP BY cp.payroll_year, value_type_code_name,  unit_name, cpib.name
ORDER BY payroll_year)
)
SELECT
	rok AS year,
	value,
	region_code AS area_of_data,
	name,
	price_value,
	unit_name
FROM primary_table_a
)
;