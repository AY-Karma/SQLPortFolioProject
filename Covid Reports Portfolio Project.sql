select *
from PortfolioProject..['death-covid-data$']
where continent is not null
order by 3,4

--select *
--from PortfolioProject..['vaccine-covid-data']
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..['death-covid-data$']
order by 1,2

--Total cases vs Total Deaths occured
select location,date,total_cases,total_deaths, (convert(float,total_cases)/convert(float,total_deaths))*100 as DeathPerc
from PortfolioProject..['death-covid-data$']
where location like '%states%'
and continent is not null
order by 1,2


--Glance at Total cases vs total Population
select location,date,total_cases,population, (convert(float,total_cases)/convert(float,population))*100 as Popaffected
from PortfolioProject..['death-covid-data$']
where location like '%states%'
and continent is not null
order by 1,2


--Countries with Highest Infection Rate as to Population
select location,population, MAX(total_cases) as HighestInfectRate , MAX((convert(float,total_cases)/convert(float,population))*100) as PercPopAffected
from PortfolioProject..['death-covid-data$']
--where location like '%states%'
where continent is not null
group by location , population
order by PercPopAffected desc;

-- Countries with Highest Fatality per Population
select location , MAX(cast(total_deaths as int)) as TotalDeaths
from PortfolioProject..['death-covid-data$']
--where location like '%states%'
where continent is  null
group by location 
order by TotalDeaths desc

--Showcasing continents with highest death toll per population
select continent , MAX(cast(total_deaths as int)) as TotalDeaths
from PortfolioProject..['death-covid-data$']
where continent is not null
group by continent 
order by TotalDeaths desc

--global numbers
select sum(new_cases) as New_Cases, sum(cast(new_deaths as int)) as Total_Deaths , sum(cast(new_deaths as int))/nullif(sum(new_cases),0) *100 as DeathPerc
from PortfolioProject..['death-covid-data$']
--where location like '%states%'
where continent is not null
--group by date 
order by 1,2

--using cte
with PopvsVacc (Continent , Location , date, population , SumPopVac ,new_vaccinations)
as 
(
-- Total Population vs No. of Vaccinations
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, sum (cast(vac.new_vaccinations as bigint))  over (partition by dea.location order by dea.location , dea.date) as SumPopVac
from PortfolioProject..['death-covid-data$'] dea
join PortfolioProject..['vaccine-covid-data'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (SumPopVac/population) * 100  
from PopvsVacc

--Temp table
drop table if exists #PercPopVaCC
create table #PercPopVaCC
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
SumPopVac numeric
)
insert into #PercPopVaCC
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, sum (cast(vac.new_vaccinations as bigint))  over (partition by dea.location order by dea.location , dea.date) as SumPopVac
from PortfolioProject..['death-covid-data$'] dea
join PortfolioProject..['vaccine-covid-data'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * , (SumPopVac/population) * 100  
from #PercPopVaCC


--Creating View for later use
create view PercPopVaCC as
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, sum (cast(vac.new_vaccinations as bigint))  over (partition by dea.location order by dea.location , dea.date) as SumPopVac
from PortfolioProject..['death-covid-data$'] dea
join PortfolioProject..['vaccine-covid-data'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercPopVaCC