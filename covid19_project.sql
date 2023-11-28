--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

-- Data Exploration 

Select *
From CovidDeath
Where continent is not null 
order by 3,4


-- transoforming columns data type to start calculations 

alter table coviddeath 
alter column total_deaths numeric

alter table coviddeath 
alter column total_cases numeric

alter table coviddeath 
alter column population numeric

alter table coviddeath 
alter column new_cases numeric

alter table coviddeath 
alter column new_deaths numeric


-- select important columns for calculations 


Select Location, date, total_cases, new_cases, total_deaths, population
From covidDeath
Where continent is not null 
order by 1,2


-- total_deaths vs total_cases globaly and in my contries 

-- lets start with the percentage of death/new_cases

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentage_of_death
From covidDeath
order by 1,2

-- develepment of covid19 in USA

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentage_of_death
From covidDeath
where location = 'United States'
and continent is not null 

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeath
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Infection Rate compared to Population and countrie population over 10000000 Millions 

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeath
where population > 10000000
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

select Location, MAX(Total_deaths) as TotalDeathCount
From CovidDeath
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENTS

-- Showing the continents with the highest death count per population

Select continent,max(total_deaths) as TotalDeathCount
From CovidDeath
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeath
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVacsination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeath dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

