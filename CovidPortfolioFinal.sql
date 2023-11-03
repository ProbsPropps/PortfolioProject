

--SELECT *
--FROM [Portfolio Project].dbo.CovidVaccinations
--ORDER BY 3, 4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths in the United States

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2

-- Looking at Total Cases vs Population in the United States

SELECT Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2

-- Ordering country by Highest Infection Rate per Population

SELECT location, population, MAX(total_cases) as HighestCount, (MAX(total_cases)/population)*100 as InfectedPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectedPercentage DESC

-- Ordering country by Highest Death Count

SELECT location, MAX(cast(total_deaths as bigint)) as HighestDeaths
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeaths DESC

-- Ordering continent by Highest Death Count

SELECT location, MAX(cast(total_deaths as bigint)) as HighestDeaths
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income%' AND location NOT LIKE '%Union%'
GROUP BY location
ORDER BY HighestDeaths DESC

-- Total Population vs New vaccinations per location and date

DROP TABLE IF EXISTS #PercentPopulationVaccination
CREATE TABLE #PercentPopulationVaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric
)

INSERT INTO #PercentPopulationVaccination
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations
, SUM(CONVERT(bigint, vaccs.new_vaccinations)) OVER (Partition by deaths.location Order BY deaths.location, deaths.date) as RollingVaccinationCount
FROM [Portfolio Project]..CovidDeaths deaths
JOIN [Portfolio Project]..CovidVaccinations vaccs
	ON deaths.location = vaccs.location
	AND deaths.date = vaccs.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (RollingVaccinationCount/population)*100 as RollingPercentVaccinated
FROM #PercentPopulationVaccination
ORDER BY location, date

--Creating a View for future Visualizations

CREATE VIEW PercentPopulationVaccination as
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations
, SUM(CONVERT(bigint, vaccs.new_vaccinations)) OVER (Partition by deaths.location Order BY deaths.location, deaths.date) as RollingVaccinationCount
FROM [Portfolio Project]..CovidDeaths deaths
JOIN [Portfolio Project]..CovidVaccinations vaccs
	ON deaths.location = vaccs.location
	AND deaths.date = vaccs.date
WHERE deaths.continent IS NOT NULL
