CREATE TABLE t_martina_palusgova_project_SQL_secondary_final AS (
SELECT 
	e.country,
	e.GDP,
	e.gini,
	e.population,
	e.`year` 
FROM economies AS e 
JOIN (SELECT 
		country 
		FROM countries
		WHERE continent = 'Europe') AS c
	ON c.country = e.country
WHERE `year` BETWEEN 2006 AND 2018
)
;


