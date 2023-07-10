SELECT*
FROM `coviddeaths2`
ORDER BY 3,4;

SELECT*
FROM `covidvaccinations2`
ORDER BY 3,4;

SELECT `location`, `date`, `total_cases`, `new_cases`, `total_deaths`, `population`
FROM `coviddeaths2`
ORDER BY 1,2;

-- Total death vs Total cases
-- this shows percentage of total death of covid(likelihood of dying from covid)
SELECT `location`, `date`, `total_cases`, `total_deaths`, (total_deaths/total_cases)*100 As death_percentage
FROM `coviddeaths2`
WHERE `location` like '%state%'
ORDER BY 1,2;

-- lookinging at total cases vs the population
-- this will show the percentage of population that contract covid
SELECT `location`, `date`, `total_cases`, `population`, (total_cases/population)*100 As population_percentage
FROM `coviddeaths2`
WHERE `location` like '%states%'
ORDER BY 1,2;

-- 3
-- looking at countries with highest infection rate against population
SELECT `location`, `population`, max(total_cases) As highest_case_count,  max((total_cases/population))*100 As percentage_population_infected
FROM `coviddeaths2`
-- WHERE `location` like '%states%'
GROUP BY `location`, `population`
ORDER BY percentage_population_infected DESC;

SELECT `location`, `population`, `date`, max(total_cases) As highest_case_count,  max((total_cases/population))*100 As percentage_population_infected
FROM `coviddeaths2`
-- WHERE `location` like '%states%'
GROUP BY `location`, `population`, `date`
ORDER BY percentage_population_infected DESC;

-- countries with highest percentage death count per population
SELECT `location`, `population`, max(total_deaths) As highest_death_count,  max((total_deaths/population))*100 As percentage_death_per_population
FROM `coviddeaths2`
WHERE `continent` is not null
GROUP BY `location`, `population`
ORDER BY percentage_death_per_population DESC;

-- countries with highest death count per population
SELECT `location`, max(cast(`total_deaths` As signed)) As Total_death_count
FROM `coviddeaths2`
WHERE `continent` is not null
GROUP BY `location`
ORDER BY Total_death_count DESC;

-- 2
-- continent with highest death count per population
SELECT `continent`, max(cast(`total_deaths` As signed)) As Total_death_count
FROM `coviddeaths2`
WHERE `continent` is not null
GROUP BY `continent`
ORDER BY Total_death_count DESC;

 -- looking at global numbers
SELECT  `date`, `total_cases`, `total_deaths`, (total_deaths/total_cases)*100 As death_percentage
FROM `coviddeaths2`
WHERE `continent` is not null
GROUP BY `date`
ORDER BY 1,2;

-- 1
 SELECT SUM(`new_cases`) as total_cases, 
		SUM(CAST(`new_deaths` as signed)) as total_deaths,
		SUM(CAST(`new_deaths` as signed))/SUM(new_cases)*100 As death_percentage
FROM `coviddeaths2`
WHERE `continent` is not null
-- GROUP BY `date`
ORDER BY 1,2;

-- SELECT `location`, SUM(cast(new_deaths as SIGNED)) as TotalDeathCount
-- FROM `CovidDeaths2`
-- WHERE `continent` is not  null 
-- AND `location` not  IN ('World', 'European Union', 'International')
-- GROUP BY `location`
-- ORDER BY `TotalDeathCount` DESC;

-- joining coviddeath and covidvaccination tables together
-- looking at total population vs vaccination
SELECT*
FROM `coviddeaths2` Dea
JOIN `covidvaccinations2` Vac
    ON Dea.location = vac.location
    and Dea.date = vac.date;

-- looking at total population vs vaccination
SELECT dea.continent, dea.location, 
	   dea.date, dea.population, 
       vac.new_vaccinations
FROM coviddeaths2 Dea
JOIN covidvaccinations2 Vac
       ON Dea.location = vac.location
       and Dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

SELECT dea.continent, dea.location, 
	   dea.date, dea.population, 
       vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations AS unsigned)) 
OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Accumulated_people_vaccination
FROM coviddeaths2 Dea
JOIN covidvaccinations2 Vac
       ON Dea.location = vac.location
       and Dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;


-- use CTE
WITH population_vs_vaccination (continent, location, date, population,new_vaccinations, Accumulated_people_vaccination)
AS
( 
SELECT dea.continent, dea.location, 
	   dea.date, dea.population, 
       vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS unsigned)) 
OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Accumulated_people_vaccination
FROM coviddeaths2 Dea
JOIN covidvaccinations2 Vac
       ON Dea.location = vac.location
       and Dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3
)
SELECT*, (Accumulated_people_vaccination/population)*100
FROM population_vs_vaccination;

-- creating view to store data for visiualization
CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent, dea.location, 
	   dea.date, dea.population, 
       vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations AS unsigned)) 
OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Accumulated_people_vaccination
FROM coviddeaths2 Dea
JOIN covidvaccinations2 Vac
       ON Dea.location = vac.location
       and Dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

CREATE VIEW total_population_vs_vac AS
SELECT dea.continent, dea.location, 
	   dea.date, dea.population, 
       vac.new_vaccinations
FROM coviddeaths2 Dea
JOIN covidvaccinations2 Vac
       ON Dea.location = vac.location
       and Dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

CREATE VIEW cont_with_highest_death_count_per_pop AS
SELECT `continent`, max(cast(`total_deaths` As unsigned)) As Total_death_count
FROM `coviddeaths2`
WHERE `continent` is not null
GROUP BY `continent`
ORDER BY Total_death_count DESC;