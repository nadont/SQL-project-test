select *
from PortfolioProject1..CovidDeaths
order by 3,4

--select *
--from PortfolioProject1..CovidVac
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeaths
order by 1,2

--Ranking populations
select location, population, continent
from PortfolioProject1..CovidDeaths
where continent is not null
group by continent, location, population
order by 2 desc

--Looking at total cases vs total deaths
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
Where location like '%Thailand' and continent is not null
order by 1,2


--Looking at the total cases vs population
select location, date, total_cases, new_cases, population, (total_cases/population)*100 as totalCaseProbability
from PortfolioProject1..CovidDeaths
Where location = 'Thailand' or location = 'China'
order by 1,2

--Looking at Countries with highest infection rate compare to population
select location, continent, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject1..CovidDeaths
--Where location like '%Thailand'
where continent is not null
group by continent, location, population
order by PercentagePopulationInfected desc

--Looking at Countries with highest infection rate compare to population in asia
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected, continent
from PortfolioProject1..CovidDeaths
--Where location like '%Thailand'
where continent like '%asia%' and continent is not null
group by continent, location, population
order by PercentagePopulationInfected desc

--Showing Countires with the highest deathcount per population
select continent, location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject1..CovidDeaths
--Where location like '%Thailand'
Where continent is not null
group by continent, location
order by HighestDeathCount desc

--Continent 
select continent, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject1..CovidDeaths
--Where location like '%Thailand'
where continent is not null
group by continent
order by PercentagePopulationInfected desc

select continent, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject1..CovidDeaths
--Where location like '%Thailand'
Where continent is not null
group by continent
order by HighestDeathCount desc

--select location, max(cast(total_deaths as int)) as HighestDeathCount
--from PortfolioProject1..CovidDeaths
----Where location like '%Thailand'
--Where continent is null
--group by location
--order by HighestDeathCount desc

--Global Numbers
select date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where continent is not null 
Group By date
order by 1,2

--select sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, (SUM(cast(new_deaths as int))/SUM(New_Cases))*100 as DeathPercentage
--From PortfolioProject1..CovidDeaths
--where continent is not null 
----Group By date
--order by 1,2

select sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, sum(convert(Numeric,vacs.new_vaccinations)) 
over (partition by deaths.location Order by deaths.location, deaths.Date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths deaths
join PortfolioProject1..CovidVac vacs
on deaths.location = vacs.location
and deaths.date = vacs.date
where deaths.continent is not null

--Using CTE to perform Calculation on Partition By in previous query
with cte (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, sum(convert(Numeric,vacs.new_vaccinations))
over (partition by deaths.location Order by deaths.location, deaths.Date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths deaths
join PortfolioProject1..CovidVac vacs
on deaths.location = vacs.location
and deaths.date = vacs.date
where deaths.continent is not null
)

--Temp table
drop table if exists #PercentagePopulationVac
create table #PercentagePopulationVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVac
select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, sum(convert(Numeric,vacs.new_vaccinations)) 
over (partition by deaths.location Order by deaths.location, deaths.Date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths deaths
join PortfolioProject1..CovidVac vacs
on deaths.location = vacs.location
and deaths.date = vacs.date
--where deaths.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVac
From #PercentagePopulationVac

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, sum(convert(Numeric,vacs.new_vaccinations)) 
over (partition by deaths.location Order by deaths.location, deaths.Date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths deaths
join PortfolioProject1..CovidVac vacs
on deaths.location = vacs.location
and deaths.date = vacs.date
where deaths.continent is not null