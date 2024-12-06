-- Projekt Engeto
SELECT 
	MIN(date_from) AS start_of_date,
	MAX(date_from) AS Finish_of_date,
	MAX(date_to) AS finish_of_date_to
FROM czechia_price;

SELECT 
	MIN(payroll_year) AS start_of_date,
	MAX(payroll_year) AS Finish_of_date
FROM czechia_payroll cp ;
-- nejsem si jistá tím avg, když tam mám id podle kterého budu spojovat
SELECT 
YEAR(cp.date_from) AS rok,
cp.category_code,
cp.region_code,
AVG(cp.value) AS average_value,
cpc.name,
cpc.price_value,
cpc.price_unit 
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code
WHERE cp.region_code IS NOT NULL
GROUP BY YEAR(cp.date_from), cp.category_code, cp.region_code 
ORDER BY date_from;
-- toto by mělo být správně
SELECT 
cp.id,
YEAR(cp.date_from) AS rok,
cp.category_code,
cp.region_code,
cp.value,
cpc.name,
cpc.price_value,
cpc.price_unit 
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code
WHERE cp.region_code IS NOT NULL
ORDER BY date_from;

SELECT DISTINCT payroll_year 
FROM czechia_payroll cp 
ORDER BY payroll_year DESC;

SELECT DISTINCT YEAR(date_from) AS rok
FROM czechia_price cp 
ORDER BY rok DESC;

SELECT *
FROM czechia_price cp 
ORDER BY date_from DESC;

SELECT *
FROM czechia_payroll cp 
WHERE payroll_year BETWEEN 2006 AND 2018
ORDER BY payroll_year DESC;

SELECT value_type_code,
unit_code,
industry_branch_code 
FROM czechia_payroll
GROUP BY value_type_code, unit_code, industry_branch_code ;

SELECT
	cp.id,
	cp.value,
	cp.value_type_code,
	cpvt.name,
	cp.unit_code,
	cpu.name,
	cp.industry_branch_code,
	cpib.name,
	cp.payroll_year 
FROM czechia_payroll cp 
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON cpib.code = cp.industry_branch_code
LEFT JOIN czechia_payroll_unit cpu 
	ON cpu.code = cp.unit_code
LEFT JOIN czechia_payroll_value_type cpvt 
	ON cpvt.code = cp.value_type_code
WHERE payroll_year BETWEEN 2006 AND 2018
ORDER BY payroll_year 
;

SELECT COUNT(DISTINCT id)
FROM czechia_payroll cp ;

SELECT COUNT(DISTINCT id)
FROM czechia_price cp  ;

SELECT COUNT(cp.id)
FROM czechia_payroll cp 
JOIN czechia_price cp2 
	ON cp.id = cp2.id ;
	
-- pokus o spojení
WITH czechia_prices_join AS
(SELECT 
		cpr.id,
		YEAR(cpr.date_from) AS rok,
		cpr.category_code,
		cpr.region_code,
		cpr.value,
		cpc.name,
		cpc.price_value,
		cpc.price_unit 
	FROM czechia_price cpr 
	LEFT JOIN czechia_price_category cpc 
		ON cpr.category_code = cpc.code
	WHERE cpr.region_code IS NOT NULL)
SELECT
	cpj.id,
	cp.id,
	cp.value,
	cp.value_type_code,
	cpvt.name,
	cp.unit_code,
	cpu.name,
	cp.industry_branch_code,
	cpib.name,
	cp.payroll_year 
FROM czechia_payroll cp 
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON cpib.code = cp.industry_branch_code
LEFT JOIN czechia_payroll_unit cpu 
	ON cpu.code = cp.unit_code
LEFT JOIN czechia_payroll_value_type cpvt 
	ON cpvt.code = cp.value_type_code
FULL OUTER JOIN czechia_prices_join AS cpj
	ON cpj.id = cp.id 
WHERE cp.payroll_year BETWEEN 2006 AND 2018;

SELECT 
YEAR(cp.date_from) AS rok,
cp.category_code,
cp.region_code,
cp.value,
cpc.name,
cpc.price_value,
cpc.price_unit
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code
WHERE cp.region_code IS NOT NULL 
GROUP BY YEAR(cp.date_from), cp.category_code, cp.region_code 
ORDER BY date_from;

SELECT
	cp.payroll_year,
	ROUND(AVG(cp.value), 2) AS average_value,
	cp.value_type_code,
	cpvt.name AS value_type_code_name,
	cp.unit_code,
	cpu.name AS unit_code_name,
	cp.industry_branch_code,
	cpib.name
FROM czechia_payroll cp 
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON cpib.code = cp.industry_branch_code
LEFT JOIN czechia_payroll_unit cpu 
	ON cpu.code = cp.unit_code
LEFT JOIN czechia_payroll_value_type cpvt 
	ON cpvt.code = cp.value_type_code
WHERE payroll_year BETWEEN 2006 AND 2018 AND value IS NOT NULL
GROUP BY cp.payroll_year, value_type_code_name,  unit_code_name, cpib.name
ORDER BY payroll_year
;

-- další pokus a spojení
WITH czechia_price_new AS (
SELECT 
YEAR(cpri.date_from) AS rok,
cpri.category_code,
cpri.region_code,
cpri.value,
cpc.name,
cpc.price_value,
cpc.price_unit
FROM czechia_price cpri 
LEFT JOIN czechia_price_category cpc 
	ON cpri.category_code = cpc.code
WHERE cpri.region_code IS NOT NULL 
GROUP BY YEAR(cpri.date_from), cpri.category_code, cpri.region_code 
ORDER BY date_from)
SELECT
	cp.payroll_year,
	ROUND(AVG(cp.value), 2) AS average_value,
	cp.value_type_code,
	cpvt.name AS value_type_code_name,
	cp.unit_code,
	cpu.name AS unit_code_name,
	cp.industry_branch_code,
	cpib.name,
	cpr.rok,
cpr.category_code,
cpr.region_code,
cpr.value,
cpr.name AS name_cpr,
cpr.price_value,
cpr.price_unit
FROM czechia_payroll cp 
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON cpib.code = cp.industry_branch_code
LEFT JOIN czechia_payroll_unit cpu 
	ON cpu.code = cp.unit_code
LEFT JOIN czechia_payroll_value_type cpvt 
	ON cpvt.code = cp.value_type_code
JOIN czechia_price_new AS cpr
	ON cp.payroll_year = cpr.rok
WHERE payroll_year BETWEEN 2006 AND 2018 AND cp.value IS NOT NULL 
GROUP BY cp.payroll_year, value_type_code_name,  unit_code_name, cpib.name
ORDER BY payroll_year
;
-- to by šlo...funguje :D
WITH czechia_price_new AS (
SELECT 
YEAR(cpri.date_from) AS rok,
cpri.category_code,
cpri.region_code,
cpri.value,
cpc.name,
cpc.price_value,
cpc.price_unit
FROM czechia_price cpri 
LEFT JOIN czechia_price_category cpc 
	ON cpri.category_code = cpc.code
WHERE cpri.region_code IS NOT NULL 
GROUP BY YEAR(cpri.date_from), cpri.category_code, cpri.region_code 
ORDER BY date_from),
czechia_payroll_new AS (
SELECT
	cp.payroll_year,
	ROUND(AVG(cp.value), 2) AS average_value,
	cp.value_type_code,
	cpvt.name AS value_type_code_name,
	cp.unit_code,
	cpu.name AS unit_code_name,
	cp.industry_branch_code,
	cpib.name
FROM czechia_payroll cp 
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON cpib.code = cp.industry_branch_code
LEFT JOIN czechia_payroll_unit cpu 
	ON cpu.code = cp.unit_code
LEFT JOIN czechia_payroll_value_type cpvt 
	ON cpvt.code = cp.value_type_code
WHERE payroll_year BETWEEN 2006 AND 2018 AND cp.value IS NOT NULL 
GROUP BY cp.payroll_year, value_type_code_name,  unit_code_name, cpib.name
ORDER BY payroll_year)
SELECT COUNT(*)
FROM czechia_price_new AS cpri
JOIN czechia_payroll_new AS cp
 ON cpri.rok = cp.payroll_year
;

WITH czechia_price_new AS (
    SELECT 
        YEAR(cpri.date_from) AS rok,
        cpri.category_code,
        cpri.region_code,
        cpri.value,
        cpc.name,
        cpc.price_value,
        cpc.price_unit
    FROM czechia_price cpri 
    LEFT JOIN czechia_price_category cpc 
        ON cpri.category_code = cpc.code
    WHERE cpri.region_code IS NOT NULL 
    GROUP BY YEAR(cpri.date_from), cpri.category_code, cpri.region_code 
    ORDER BY date_from
)
SELECT
    cp.payroll_year,
    ROUND(AVG(cp.value), 2) AS average_value,
    cp.value_type_code,
    cpvt.name AS value_type_code_name,
    cp.unit_code,
    cpu.name AS unit_code_name,
    cp.industry_branch_code,
    cpib.name
FROM czechia_payroll cp 
LEFT JOIN czechia_payroll_industry_branch cpib 
    ON cpib.code = cp.industry_branch_code
LEFT JOIN czechia_payroll_unit cpu 
    ON cpu.code = cp.unit_code
LEFT JOIN czechia_payroll_value_type cpvt 
    ON cpvt.code = cp.value_type_code
CROSS JOIN czechia_price_new AS cpr
--    ON cp.payroll_year = cpr.rok
WHERE payroll_year BETWEEN 2006 AND 2018 AND cp.value IS NOT NULL 
GROUP BY cp.payroll_year, value_type_code_name, unit_code_name, cpib.name
ORDER BY payroll_year;

-- pokus číslo 3 přes UNION - vypadá to nadějně...přepsat sloupce
(SELECT 
YEAR(cp.date_from) AS rok, -- stejné hodnoty
cp.value, -- stejné hodnoty
cp.category_code, -- hodoty nemusí být vypsány
cp.region_code, -- vypadá to, že není nutné
cpc.name, -- stejné hodnoty
cpc.price_value, -- musí být
cpc.price_unit AS unit_name -- stejné hodnoty
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code
WHERE cp.region_code IS NOT NULL 
GROUP BY YEAR(cp.date_from), cp.category_code, cp.region_code 
ORDER BY date_from)
UNION 
(SELECT
	cp.payroll_year, -- stejné hodnoty
	ROUND(AVG(cp.value), 2) AS average_value, -- stejné hodnoty
	cp.value_type_code, -- hodnoty nemusí být vypsány
	cpvt.name AS value_type_code_name, -- musí být
	cpib.name, -- stejné hodnoty
	cp.industry_branch_code, -- hodnoty nemusí být vypsány
	cpu.name AS unit_name -- stejné hodnoty
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
ORDER BY category_code
;

-- pokus číslo 3 přes UNION - vypadá to nadějně...další úpravy
WITH primary_table_a AS
((SELECT 
YEAR(cp.date_from) AS rok, -- stejné hodnoty
cp.value, -- stejné hodnoty
cp.category_code, -- hodoty nemusí být vypsány
cp.region_code, -- vypadá to, že není nutné
cpc.name, -- stejné hodnoty
cpc.price_value, -- musí být
cpc.price_unit AS unit_name -- stejné hodnoty
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code
WHERE cp.region_code IS NOT NULL 
GROUP BY YEAR(cp.date_from), cp.category_code, cp.region_code 
ORDER BY date_from)
UNION 
(SELECT
	cp.payroll_year, -- stejné hodnoty
	ROUND(AVG(cp.value), 2) AS average_value, -- stejné hodnoty
	cp.value_type_code, -- hodnoty nemusí být vypsány
	cpvt.name AS value_type_code_name, -- musí být
	cpib.name, -- stejné hodnoty
	cp.industry_branch_code, -- hodnoty nemusí být vypsány
	cpu.name AS unit_name -- stejné hodnoty
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
	rok,
	value,
	region_code AS area_of_data,
	name,
	price_value,
	unit_name
FROM primary_table_a
ORDER BY region_code DESC;

-- zkoušk výpočtu 1
WITH primary_table_a AS
((SELECT 
YEAR(cp.date_from) AS rok, -- stejné hodnoty
cp.value, -- stejné hodnoty
cp.category_code, -- hodoty nemusí být vypsány
cp.region_code, -- vypadá to, že není nutné
cpc.name, -- stejné hodnoty
cpc.price_value, -- musí být
cpc.price_unit AS unit_name -- stejné hodnoty
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code
WHERE cp.region_code IS NOT NULL 
GROUP BY YEAR(cp.date_from), cp.category_code, cp.region_code 
ORDER BY date_from)
UNION 
(SELECT
	cp.payroll_year, -- stejné hodnoty
	ROUND(AVG(cp.value), 2) AS average_value, -- stejné hodnoty
	cp.value_type_code, -- hodnoty nemusí být vypsány
	cpvt.name AS value_type_code_name, -- musí být
	cpib.name, -- stejné hodnoty
	cp.industry_branch_code, -- hodnoty nemusí být vypsány
	cpu.name AS unit_name -- stejné hodnoty
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
	rok,
	value,
	region_code AS area_of_data,
	name,
	price_value,
	unit_name
FROM primary_table_a
WHERE region_code = 'Průměrná hrubá mzda na zaměstnance'
ORDER BY name, rok
;

-- vytvoření tabulky
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

-- už vlastní tabulka
SELECT *
FROM t_martina_palusgova_project_sql_primary_final;

-- pokusy úkolů
SELECT *
FROM t_martina_palusgova_project_sql_primary_final
WHERE name LIKE '%Chléb%' OR name LIKE '%mléko%'
GROUP BY name
;

-- 2. úkol
SELECT 
	pf.`year`,
	pf.value,
	salary.value AS czech_salary,
	ROUND(AVG(pf.value),2) AS all_CZ_average_value,
	salary.value/AVG(pf.value) AS number_of_commodity,
	pf.area_of_data,
	pf.name,
	pf.price_value,
	pf.unit_name 
FROM t_martina_palusgova_project_sql_primary_final AS pf
JOIN (
	SELECT *
	FROM t_martina_palusgova_project_sql_primary_final
	WHERE area_of_data = 'Průměrná hrubá mzda na zaměstnance' AND name IS NULL) AS salary
	ON pf.`year` = salary.`year`
WHERE (pf.name = 'Chléb konzumní kmínový' OR pf.name = 'Mléko polotučné pasterované') AND pf.`year` IN(2006, 2018)
GROUP BY pf.`year` , pf.name 
;

SELECT *
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data = 'Průměrná hrubá mzda na zaměstnance' AND name IS NULL;

-- 1. úkol Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
SELECT
	name,
	`year`,
	value,
	value - LAG(value,1) OVER (ORDER BY name,`year`) AS increase,
	ROUND((value - LAG(value,1) OVER (ORDER BY name,`year`))*100/value,1) AS "%_increase",
	area_of_data
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data = 'Průměrná hrubá mzda na zaměstnance' AND name IS NOT NULL
;

WITH first_question AS (
SELECT
	name,
	`year`,
	value,
	value - LAG(value,1) OVER (ORDER BY name,`year`) AS increase, -- musím vymyslet
	ROUND((value - LAG(value,1) OVER (ORDER BY name,`year`))*100/value,1) AS "%_increase",
	area_of_data
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data = 'Průměrná hrubá mzda na zaměstnance' AND name IS NOT NULL
ORDER BY increase)
SELECT *
FROM first_question
WHERE `year` BETWEEN 2007 AND 2018 AND increase <= 0
ORDER BY name, increase
;

-- vypsání odvětví, kde nedošlo k poklesu mezd
WITH first_question AS (
SELECT
	name,
	`year`,
	value,
	value - LAG(value,1) OVER (ORDER BY name,`year`) AS increase, -- musím vymyslet
	ROUND((value - LAG(value,1) OVER (ORDER BY name,`year`))*100/value,1) AS "%_increase",
	area_of_data
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data = 'Průměrná hrubá mzda na zaměstnance' AND name IS NOT NULL)
SELECT name
FROM czechia_payroll_industry_branch
EXCEPT 
SELECT name
FROM first_question
WHERE `year` BETWEEN 2007 AND 2018 AND increase <= 0
;
-- vypsání odvětví, kde nedošlo k poklesu mezd - kepší verze, kde vycházím jen z primary_final
WITH first_question AS (
SELECT
	name,
	`year`,
	value,
	value - LAG(value,1) OVER (ORDER BY name,`year`) AS increase, -- musím vymyslet
	ROUND((value - LAG(value,1) OVER (ORDER BY name,`year`))*100/value,1) AS "%_increase",
	area_of_data
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data = 'Průměrná hrubá mzda na zaměstnance' AND name IS NOT NULL)
SELECT name 
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data = 'Průměrná hrubá mzda na zaměstnance' AND price_value IS NOT NULL
GROUP BY name
EXCEPT 
SELECT name
FROM first_question
WHERE `year` BETWEEN 2007 AND 2018 AND increase <= 0
;
SELECT *
FROM czechia_payroll_industry_branch;

SELECT *
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data = 'Průměrná hrubá mzda na zaměstnance' AND price_value IS NOT NULL
GROUP BY name
;

-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
SELECT 
	name,
	`year`,
	ROUND(AVG(value),2) AS average_value_CZ,
	LAG(AVG(value),1) OVER (ORDER BY name,`year`) AS controll,
	ROUND((AVG(value) - LAG(AVG(value),1) OVER (ORDER BY name,`year`))*100/AVG(value),1) AS "percent_increase"
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data != 'Průměrná hrubá mzda na zaměstnance' AND area_of_data != 'Průměrný počet zaměstnaných osob'
GROUP BY name, `year` ;

WITH comparison AS (
SELECT 
	name,
	`year`,
	ROUND(AVG(value),2) AS average_value_CZ,
	LAG(AVG(value),1) OVER (ORDER BY name,`year`) AS controll,
	ROUND((AVG(value) - LAG(AVG(value),1) OVER (ORDER BY name,`year`))*100/AVG(value),1) AS percent_increase
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data != 'Průměrná hrubá mzda na zaměstnance' AND area_of_data != 'Průměrný počet zaměstnaných osob'
GROUP BY name, `year`)
SELECT
	name,
	SUM(percent_increase) AS sum_of_increase,
	ROUND(AVG(percent_increase),1) AS average_increase
FROM comparison
WHERE `year` BETWEEN 2007 AND 2018
GROUP BY name
ORDER BY sum_of_increase;
-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
SELECT 
	`year`,
	ROUND(AVG(value),2) AS average_value_CZ,
	LAG(AVG(value),1) OVER (ORDER BY `year`) AS controll,
	ROUND((AVG(value) - LAG(AVG(value),1) OVER (ORDER BY `year`))*100/AVG(value),1) AS percent_increase
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data != 'Průměrná hrubá mzda na zaměstnance' AND area_of_data != 'Průměrný počet zaměstnaných osob'
GROUP BY `year`
ORDER BY percent_increase DESC;

-- Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
-- projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
SELECT 
country
FROM countries 
GROUP BY country;

SELECT e.country 
FROM economies e 
JOIN countries c 
	ON c.country = e.country
GROUP BY e.country ;
