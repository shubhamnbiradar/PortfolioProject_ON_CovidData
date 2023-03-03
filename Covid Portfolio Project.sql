--SELECT * From CovidDeaths
--SELECT * FROM CovidVaccinations ORDER BY 3,4;

SELECT location,date,total_cases,new_cases, total_deaths,population FROM CovidDeaths
ORDER BY 1,2


--shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM CovidDeaths
WHERE location= 'India'
ORDER BY 1,2 

--looking at Total Cases vs Polpulation
SELECT location, date, total_cases, population, (total_cases/population)*100 as infectionPercentagePopulation
FROM CovidDeaths
WHERE location= 'Pakistan'
ORDER BY 1,2 


--countries with highest infection rate compared to total population
SELECT location,MAX(total_cases) as no_of_cases, max(population) as population , (MAX(total_cases)/max(population))*100 as infection_rate
FROM CovidDeaths
GROUP BY location
ORDER BY infection_rate DESC


--countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths as int)) as total_death_count 
FROM CovidDeaths WHERE continent is not null
GROUP BY location
ORDER by total_death_count DESC


--lets break things down by continent
SELECT continent , MAX(CAST(total_deaths as int)) as total_death_count
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC


--breaking global numbers date wise and as per cases and deaths registered
SELECT date, SUM(new_cases),SUM(CAST(new_deaths as int))
FROM CovidDeaths
GROUP BY date
ORDER BY date


--looking at total population to the vaccinated population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as total_vaccinations_till_date
FROM CovidDeaths dea JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date=vac.date
WHERE dea.continent is not null 
ORDER BY 1,2


--use CTE

with popvsvacc (continent,location,date,population, new_vaccinations, total_vaccinations_till_date)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as total_vaccinations_till_date
FROM CovidDeaths dea JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date=vac.date
WHERE dea.continent is not null 
)
SELECT *, (total_vaccinations_till_date/population)*100 as vaccination_rate FROM popvsvacc
ORDER BY 1,2,3


--using TEMP Table
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations_till_date numeric
)

INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as total_vaccinations_till_date
FROM CovidDeaths dea JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date=vac.date
WHERE dea.continent is not null 
ORDER BY 1,2

SELECT * FROM #PercentPopulationVaccinated


--Creating VIEWS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as total_vaccinations_till_date
FROM CovidDeaths dea JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date=vac.date
WHERE dea.continent is not null 


SELECT * FROM PercentPopulationVaccinated









