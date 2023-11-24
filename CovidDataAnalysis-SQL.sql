select * 
from [COVID Data Analysis Portfolio Project]..Covid_Deaths
where continent is not null 
order by 3,4
select *
from [COVID Data Analysis Portfolio Project]..Covid_Vaccines
where continent is not null
order by 3,4

--following is the query for the data to be used
select location, date, total_cases, new_cases, total_deaths, population
from [COVID Data Analysis Portfolio Project]..Covid_Deaths
where continent is not null
order by 1,2

--Total Cases Vs Total Deaths
--Likelihood of dying due to COVID
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage 
from [COVID Data Analysis Portfolio Project]..Covid_Deaths
where continent is not null
order by 1,2

--Total Cases Vs Population
--Percetnage of Population affected with COVID
select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from [COVID Data Analysis Portfolio Project]..Covid_Deaths
where location like '%india%' 
and continent is not null
order by 1, 2

--looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentageOfPopulationInfected
from [COVID Data Analysis Portfolio Project]..Covid_Deaths
where continent is not null
group by location, population
order by PercentageOfPopulationInfected desc

--showing countries with highest death count per population
select location, max(CONVERT(float, total_deaths)) as TotalDeathCount
from [COVID Data Analysis Portfolio Project]..Covid_Deaths
where continent is not null
group by location
order by TotalDeathCount  desc

--showing continents with death count per population
select location, max(CONVERT(float, total_deaths)) as TotalDeathCount
from [COVID Data Analysis Portfolio Project]..Covid_Deaths
where continent is null
group by location
order by TotalDeathCount  desc 

--GLOBAL NUMBERS
SELECT 
sum(new_cases) as toal_cases, 
sum(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathPercentage
FROM [COVID Data Analysis Portfolio Project]..Covid_Deaths
where continent is not null
group by date
order by 1,2

--joining both the tables
--looking at Total Population VS Vaccinations
--using CTE
;with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select 
death.continent,death.location, death.date, death.population, 
vaccine.new_vaccinations,
SUM(convert(bigint,vaccine.new_vaccinations))
over (partition by death.location order by death.location, death.date)
as RollingPeopleVaccinated
from [COVID Data Analysis Portfolio Project]..Covid_Deaths death
join [COVID Data Analysis Portfolio Project]..Covid_Vaccines vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null
)

select *, (RollingPeopleVaccinated/population)*100
from PopVsVac  


--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
select 
death.continent,death.location, death.date, death.population, 
vaccine.new_vaccinations,
SUM(convert(bigint,vaccine.new_vaccinations))
over (partition by death.location order by death.location, death.date)
as RollingPeopleVaccinated
from [COVID Data Analysis Portfolio Project]..Covid_Deaths death
join [COVID Data Analysis Portfolio Project]..Covid_Vaccines vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null


#for visualizations
--1. 
select 
sum(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [COVID Data Analysis Portfolio Project]..Covid_Deaths
where continent is not null 
order by 1,2
--2
select location, sum(cast(new_deaths as int)) as TotalDeathCount 
from [COVID Data Analysis Portfolio Project]..Covid_Deaths
where continent is null
and location not in ('World','European Union','International')
and location not like '%income%'
group by location
order by TotalDeathCount desc

--3.
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from [COVID Data Analysis Portfolio Project]..Covid_Deaths
group by location, population
order by PercentPopulationInfected desc
--4.
SELECT location, population, date, MAX(TOTAL_CASES) AS HighestInfectionCount, MAX((total_cases/population))*100 PercentPopulationInfected
FROM [COVID Data Analysis Portfolio Project]..Covid_Deaths
group by location, population, date
order by PercentPopulationInfected desc 