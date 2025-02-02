-- Projekt Engeto
-- uživatelské jméno na Discordu: Martina Pal

-- 1. úkol Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
-- vývoj dle odětví a roku
SELECT
	name,
	`year`,
	value,
	value - LAG(value,1) OVER (PARTITION BY name ORDER BY `year`) AS increase,
	ROUND((value - LAG(value,1) OVER (PARTITION BY name ORDER BY `year`))*100/LAG(value,1) OVER (PARTITION BY name ORDER BY `year`),1) AS "percent_increase",
	CASE 
		WHEN (value - LAG(value,1) OVER (PARTITION BY name ORDER BY `year`))>0 THEN "increase"
		WHEN (value - LAG(value,1) OVER (PARTITION BY name ORDER BY `year`))<0 THEN "decrease"
		WHEN (value - LAG(value,1) OVER (PARTITION BY name ORDER BY `year`))=0 THEN "stagnation"
		ELSE "without comparison"
	END AS "progress",
	area_of_data
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data = 'Průměrná hrubá mzda na zaměstnance' AND name IS NOT NULL 
;

-- vypsání odvětví s nejnižsími hodnotami meziročního vývoje
WITH first_question AS (
SELECT
	name,
	`year`,
	value,
	value - LAG(value,1) OVER (PARTITION BY name ORDER BY `year`) AS increase,
	ROUND((value - LAG(value,1) OVER (PARTITION BY name ORDER BY `year`))*100/LAG(value,1) OVER (PARTITION BY name ORDER BY `year`),1) AS "percent_increase",
	CASE 
		WHEN (value - LAG(value,1) OVER (PARTITION BY name ORDER BY `year`))>0 THEN "increase"
		WHEN (value - LAG(value,1) OVER (PARTITION BY name ORDER BY `year`))<0 THEN "decrease"
		WHEN (value - LAG(value,1) OVER (PARTITION BY name ORDER BY `year`))=0 THEN "stagnation"
		ELSE "without comparison"
	END AS "progress",
	area_of_data
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data = 'Průměrná hrubá mzda na zaměstnance' AND name IS NOT NULL)
SELECT 
	DISTINCT name,
	MIN(increase) OVER (PARTITION BY name) AS minimum
FROM first_question
ORDER BY minimum DESC
;

-- vypsání odvětví, kde nedošlo k poklesu mezd
WITH first_question AS (
SELECT
	name,
	`year`,
	value,
	value - LAG(value,1) OVER (PARTITION  BY name ORDER BY `year`) AS increase, 
	ROUND((value - LAG(value,1) OVER (PARTITION BY name ORDER BY `year`))*100/LAG(value,1) OVER (PARTITION BY name ORDER BY `year`),1) AS "percent_increase",
	area_of_data
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data = 'Průměrná hrubá mzda na zaměstnance' AND name IS NOT NULL)
SELECT name 
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data = 'Průměrná hrubá mzda na zaměstnance' AND unit_value_or_industry_code IS NOT NULL
GROUP BY name
EXCEPT 
SELECT name
FROM first_question
WHERE increase <= 0
;

-- 2. úkol: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
SELECT 
	pf.`year`,
	salary.value AS czech_salary,
	ROUND(AVG(pf.value),2) AS average_value_of_commodity,
	ROUND(salary.value/AVG(pf.value),0) AS number_of_commodity,
	pf.name,
	pf.unit_value_or_industry_code ,
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

-- 3. úkol: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
-- meziroční vývoj
SELECT 
	name,
	`year`,
	ROUND(AVG(value),2) AS average_value_CZ,
	ROUND((AVG(value) - LAG(AVG(value),1) OVER (PARTITION  BY name ORDER BY `year`))*100/LAG(AVG(value),1) OVER (PARTITION  BY name ORDER BY `year`),1) AS "percent_increase"
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data != 'Průměrná hrubá mzda na zaměstnance' AND area_of_data != 'Průměrný počet zaměstnaných osob'
GROUP BY name, `year` ;

-- souhrn jednotlivých kategorií potravin
WITH comparison AS (
SELECT 
	name,
	`year`,
	ROUND(AVG(value),2) AS average_value_CZ,
	ROUND((AVG(value) - LAG(AVG(value),1) OVER (PARTITION  BY name ORDER BY `year`))*100/LAG(AVG(value),1) OVER (PARTITION  BY name ORDER BY `year`),1) AS percent_increase
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data != 'Průměrná hrubá mzda na zaměstnance' AND area_of_data != 'Průměrný počet zaměstnaných osob'
GROUP BY name, `year`)
SELECT
	name,
	SUM(percent_increase) AS sum_of_increase,
	ROUND(AVG(percent_increase),1) AS average_increase
FROM comparison
GROUP BY name
ORDER BY sum_of_increase
;

-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
WITH food AS(
SELECT 
	`year`,
	ROUND(AVG(value),2) AS average_value_CZ,
	ROUND((AVG(value) - LAG(AVG(value),1) OVER (ORDER BY `year`))*100/LAG(AVG(value),1) OVER (ORDER BY `year`),1) AS percent_increase_food
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data != 'Průměrná hrubá mzda na zaměstnance' AND area_of_data != 'Průměrný počet zaměstnaných osob'
GROUP BY `year`),
salary AS (
SELECT 
	`year`,
	value,
	ROUND((value - LAG(value,1) OVER (ORDER BY `year`))*100/LAG(value,1) OVER (ORDER BY `year`),1) AS percent_increase_salary
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data = 'Průměrná hrubá mzda na zaměstnance' AND name IS NULL)
SELECT 
	fo.`year`,
	fo.percent_increase_food,
	sa.percent_increase_salary,
	fo.percent_increase_food - sa.percent_increase_salary AS difference
FROM food AS fo
JOIN salary AS sa
	ON fo.`year` = sa.`year`
;

-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
-- projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
WITH food AS(
SELECT 
	`year`,
	ROUND(AVG(value),2) AS average_value_of_food,
	ROUND((AVG(value) - LAG(AVG(value),1) OVER (ORDER BY `year`))*100/LAG(AVG(value),1) OVER (ORDER BY `year`),1) AS percent_increase_food
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data != 'Průměrná hrubá mzda na zaměstnance' AND area_of_data != 'Průměrný počet zaměstnaných osob'
GROUP BY `year`),
salary AS (
SELECT 
	`year`,
	value AS value_of_salary,
	ROUND((value - LAG(value,1) OVER (ORDER BY `year`))*100/LAG(value,1) OVER (ORDER BY `year`),1) AS percent_increase_salary
FROM t_martina_palusgova_project_sql_primary_final
WHERE area_of_data = 'Průměrná hrubá mzda na zaměstnance' AND name IS NULL),
GDP_czechia AS(
SELECT 
	country,
	`year`,
	GDP,
	ROUND((GDP - LAG(GDP,1) OVER (ORDER BY `year`))*100/LAG(GDP,1) OVER (ORDER BY `year`),1) AS percent_increase_GDP
FROM t_martina_palusgova_project_sql_secondary_final
WHERE country LIKE 'Czech%'
ORDER BY `year`)
SELECT 
	fo.`year`,
	g.gdp,
	fo.average_value_of_food,
	sa.value_of_salary,
	g.percent_increase_GDP,
	fo.percent_increase_food,
	sa.percent_increase_salary
FROM food AS fo
JOIN salary AS sa
	ON fo.`year` = sa.`year`
JOIN GDP_czechia AS g
	ON fo.`year` = g.`year`
;