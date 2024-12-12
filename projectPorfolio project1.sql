select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

--create table #tempTemp(
--select * from PortfolioProject..CovidDeaths
--where location = 'Kenya'
--);


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

--death percentage if you have covid
select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%state%'
and continent is not null
order by 1,2;

-- infection percentage
select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from PortfolioProject..CovidDeaths
where location = 'Kenya'
and continent is not null
order by 1,2;

-- country with highest infection rate with countries repeating
select location, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by InfectionPercentage Desc;

-- country with highest infection rate with countries not repeating
select location, population, max(total_cases) as HighestInfected, max(total_cases/population)*100 as InfectionPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by InfectionPercentage Desc;

-- countries with highest death count per population
--max(cast(total_deaths as int)) changing datatype to integer
--death percentage shown here is the percentage of death in the entire country whether you are infected or not
--select location, population, max(cast(total_deaths as int)) as TotalDeathsCount, max(total_deaths/population)*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
--group by location, population
--order by TotalDeathsCount Desc;
select location, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathsCount Desc;

--These are the accurates
select location, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathsCount Desc;

--BREAKING DOWN USING CONTINENTS
-- CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION
select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathsCount Desc;

--GLOBAL NUMBERS
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
--where location like '%state%'
where continent is not null
group by date
order by 1,2;

--TOTAL GLOBAL NUMBERS
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
--where location like '%state%'
where continent is not null
--group by date
order by 1,2;

--TOTAL POPULATION VS NEW VACCINATIONS PER DAY
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--TOTAL POPULATION VS VACCINATIONS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--USE CTE to create a temp table
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
  dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac
--end of the cte table

--Temp table
drop table if exists #PercentPopulationVaccineted
create table #PercentPopulationVaccineted(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccineted
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
  dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccineted;

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
--THIS VIEW IS PERMANENT UNLIKE THE TEMP TABLE
create view PercentagePopulationVaccinated 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
  dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select * 
from PercentagePopulationVaccinated