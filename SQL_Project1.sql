Select * 
From Portfolio_P1..Covid_Deaths$
order by 3,4

--Select *
--From Portfolio_P1..Covid_Vaccinations$
--order by 3,4

-- Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_P1..Covid_Deaths$
order by 1,2 Desc


-- Looking at Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, Round(total_deaths/total_cases*100, 2) as Death_Percentage
From Portfolio_P1..Covid_Deaths$
Where location like 'Canada' or location like 'Kazakhstan'
order by 1,2 Desc

-- Looking at Total cases vs Population
-- Show what percentage of population got Covid-19
Select location, date, population, total_cases, Round(total_cases/population*100, 2) as CovidPerCapitaCases
From Portfolio_P1..Covid_Deaths$
order by 1,2 Desc

-- Calculating Maximum Covid-19 per Capita Cases and Covid-19 Deaths
Select	location,
		MAX(Round(total_cases/population*100, 2)) as CovidPerCapitaCases
From Portfolio_P1..Covid_Deaths$
group by location
order by location

Select	location, 
		MAX(Round(total_deaths/total_cases*100, 2)) as CovidDeathsPerCapita 
From Portfolio_P1..Covid_Deaths$
group by location
order by location

Select	location, 
		MAX(Round(total_cases/population*100, 2)) as CovidPerCapitaCases,
		MAX(Round(total_deaths/total_cases*100, 2)) as CovidDeathsPercentage 
From Portfolio_P1..Covid_Deaths$
group by location
order by location

-- Looking at countries with the highest infection rate compare to population
Select location, population, MAX(total_cases) as HighrstInfectionCount, ROUND(MAX(total_cases/population)*100, 2) as PercentPopulationInfected
FROM Portfolio_P1..Covid_Deaths$
group by location, population
order by location, population

--Countries with high infection rate
Select location, population, MAX(total_cases) as HighrstInfectionCount, ROUND(MAX(total_cases/population)*100, 2) as PercentPopulationInfected
FROM Portfolio_P1..Covid_Deaths$
group by location, population
having ROUND(MAX(total_cases/population)*100, 2) > 40
order by location, population 

Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM Portfolio_P1..Covid_Deaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- LET'S BREAK IT DOWN BY CONTINENT
Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM Portfolio_P1..Covid_Deaths$
where continent is null
group by location
order by TotalDeathCount desc


-- Showing continents with the highest count per population

select continent, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
from Portfolio_P1..Covid_Deaths$
where continent is not NULL
group by continent
order by TotalDeathCount desc


-- Global Numbers
Select  
	SUM(new_cases) as TotalGlobalCases, 
	SUM(CAST(new_deaths as bigint)) as TotalGlobalCovidDeath, 
	ROUND(SUM(CAST(new_deaths as bigint))/SUM(new_cases), 2) as CovidDeathPercentage
from Portfolio_P1..Covid_Deaths$
where continent is not null
order by 1,2



-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select 
	dea.continent,
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
from Portfolio_P1..Covid_Deaths$ dea
Join Portfolio_P1..Covid_Vaccinations$ vac
		ON dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--order by 1, 2, 3
) 

Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- TEMP Table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select 
	dea.continent,
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
from Portfolio_P1..Covid_Deaths$ dea
Join Portfolio_P1..Covid_Vaccinations$ vac
		ON dea.location = vac.location
		and dea.date = vac.date
	--where dea.continent is not null
	--order by 1, 2, 3

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinePercentage
from #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View VaccinatedPopulationPercentage as
Select 
	dea.continent,
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
from Portfolio_P1..Covid_Deaths$ dea
Join Portfolio_P1..Covid_Vaccinations$ vac
		ON dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select*
from VaccinatedPopulationPercentage