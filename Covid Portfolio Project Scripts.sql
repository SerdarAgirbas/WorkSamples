SELECT *
FROM CovidDeaths$
WHERE continent is NOT NULL

-- SELECT DATA THAT WE ARE GOING TO BE USING
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
WHERE continent is NOT NULL
ORDER BY 1,2

-- WE ARE LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT IN YOUR COUNTRY
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent is NOT NULL
and location like '%canada%'
ORDER BY 1,2

-- LOOKING AT THE TOTAL CASES VS POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths$
WHERE continent is NOT NULL
and location like '%canada%'
ORDER BY 1,2

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths$
WHERE continent is NOT NULL
--and location like '%canada%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is NOT NULL
--and location like '%canada%'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is NOT NULL
--and location like '%canada%'
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM CovidDeaths$
WHERE continent is not null
--and location like '%canada%'
--GROUP BY date
ORDER BY 1,2

-- LOOKING AT TOTAL POPULATION VS TOTAL VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
	ORDER BY 2,3

-- USE CTE
	With PopulationvsVaccinations (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
	AS 
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY 2,3
	)
	SELECT *, (RollingPeopleVaccinated/Population*100) AS VacPercentage
	FROM PopulationvsVaccinations

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	--WHERE dea.continent is not null
	SELECT *, (RollingPeopleVaccinated/Population*100) AS VacPercentage
	FROM #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null

	SELECT*
	FROM PercentPopulationVaccinated