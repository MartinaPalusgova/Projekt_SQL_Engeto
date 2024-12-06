CREATE TABLE t_martina_palusgova_project_SQL_secondary_final AS (
SELECT 
	e.*,
	c.abbreviation,
	c.avg_height,
	c.calling_code,
	c.capital_city,
	c.continent,
	c.currency_name,
	c.religion,
	c.currency_code,
	c.domain_tld,
	c.elevation,
	c.north,
	c.south,
	c.west,
	c.east,
	c.government_type,
	c.independence_date,
	c.iso_numeric,
	c.landlocked,
	c.life_expectancy,
	c.national_symbol,
	c.national_dish,
	c.population_density,
	c.region_in_world,
	c.surface_area,
	c.yearly_average_temperature,
	c.median_age_2018,
	c.iso2,
	c.iso3 
FROM economies AS e
JOIN countries AS c
	ON e.country = c.country
)
;