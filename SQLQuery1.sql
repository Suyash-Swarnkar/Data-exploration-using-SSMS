-- Analysis of Covid-19 world data 
--Suyash Swarnkar

select *
from [Portfolio project]..CovidDeaths
where continent is not null
order by 3,4


select *
from [Portfolio project]..CovidVaccinations
order by 3,4
--Select the data we are going to be using 

Select location , date, total_cases , new_cases, total_deaths, population 
from [Portfolio project]..CovidDeaths
order by 1,2 
--Looking at the total cases vs total deaths 

Select location , date, total_cases , total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from [Portfolio project]..CovidDeaths
where total_cases <> 0 And total_deaths <> 0 
order by 1,2 
--Shows the likelyhood of death if you contracte COVID-19 in india

Select location , date, total_cases , total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from [Portfolio project]..CovidDeaths
where total_cases <> 0 And total_deaths <> 0 and location like 'India'
order by 1,2 DESC 


--Looking at total cases vs population
--shows what percentage of population got covid

Select location , date, population, total_cases, (total_cases/population) *100 as CasesPercentage
from [Portfolio project]..CovidDeaths
where  location like 'India' and total_cases <> 0
order by 1,2 

-- Countries with highest infection rate compared to poplation

Select location ,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 as PercetPopulationInfected
from [Portfolio project]..CovidDeaths
--where location like 'India'
group by location, population
order by PercetPopulationInfected DESC


-- Showing the countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths
where continent is not null
group by location, population
order by TotalDeathCount DESC

-- Breaking things by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths
where continent is null
group by location
order by TotalDeathCount DESC

--Global numbers 

Select  SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio project]..CovidDeaths
where new_cases <> 0 And new_deaths <> 0 and continent is not null
--group by date
order by 1,2 


--joining the tables together 

select *
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


-- looking at total population vs vaccinations 

with PopvsVac(continent, location, Date, population, new_vaccinations, RollingPeopleVaccinated) as (
    select 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(Cast(vac.new_vaccinations as bigint)) 
            over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
    from 
        [Portfolio project]..CovidDeaths dea
    join 
        [Portfolio project]..CovidVaccinations vac
    on 
        dea.location = vac.location
    and 
        dea.date = vac.date
    where 
        dea.continent is not null
)
select * , (RollingPeopleVaccinated/population) *100
from PopvsVac
order by location, date;

--Temp table 

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
	Continent nvarchar(255) ,
	Location nvarchar(255) ,
	date datetime,
	population numeric ,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated

  select 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(Cast(vac.new_vaccinations as bigint)) 
            over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
    from 
        [Portfolio project]..CovidDeaths dea
    join 
        [Portfolio project]..CovidVaccinations vac
    on 
        dea.location = vac.location
    and 
        dea.date = vac.date
    where 
        dea.continent is not null

select * , (RollingPeopleVaccinated/population) *100
from #PercentPopulationVaccinated
order by location, date;

--Creating view to store data for later visualisations

-- Drop the existing view if it exists
IF OBJECT_ID('PercentPopulationVaccinated', 'V') IS NOT NULL
DROP VIEW PercentPopulationVaccinated;
GO

-- Create the new view
-- Drop the existing view if it exists
IF OBJECT_ID('PercentPopulationVaccinated', 'V') IS NOT NULL
DROP VIEW PercentPopulationVaccinated;
GO

-- Create the new view

USE [Portfolio project]
GO

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(Cast(vac.new_vaccinations as bigint)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    [Portfolio project]..CovidDeaths dea
JOIN 
    [Portfolio project]..CovidVaccinations vac
ON 
    dea.location = vac.location
AND 
    dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;
GO

select *
from PercentPopulationVaccinated

