--Select data that we will be using
Select location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths
order by 1,2 -- starts out from 0's at the top

--Looking at the total cases vs total deaths
--This shows the likelihood of dying if you contract Covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
order by 1,2

--Looking at the total cases vs the population
--What percentage of the population git Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PorcentagePopulationInfected
FROM [Portfolio Project].dbo.CovidDeaths
order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfolio Project].dbo.CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--Looking at the countries with the highest death counth per population

Select location, MAX(cast(TOTAL_DEATHS as int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Looking at it by continent

Select location, MAX(cast(TOTAL_DEATHS as int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths
where continent is  null
group by location
order by TotalDeathCount desc

--Looking at the continents with the highest death count per population

Select location, MAX(cast(TOTAL_DEATHS as int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths
where continent is  null
group by location
order by TotalDeathCount desc

--Looking at the global numbers

Select  sum(new_cases) as Total_Cases,
sum(cast(new_deaths as int)) as Total_Deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM Coviddeaths
where continent is not null

--With a join, we're looking at total population vs total vaccination

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM [Portfolio Project]..CovidDeaths as dea
JOIN [Portfolio Project]..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM [Portfolio Project]..CovidDeaths as dea
JOIN [Portfolio Project]..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (Rolling_People_Vaccinated/ population) * 100
FROM PopvsVac


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM [Portfolio Project]..CovidDeaths as dea
JOIN [Portfolio Project]..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null


SELECT *, (Rolling_People_Vaccinated/ population) * 100
FROM #PercentPopulationVaccinated




--Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM [Portfolio Project]..CovidDeaths as dea
JOIN [Portfolio Project]..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
