Select*
from portfolioproject..CovidDeath
where continent is not null
order by 3,4

--Select*
--From portfolioproject..CovidVaccination
--order by 3,4


Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..CovidDeath
where continent is not null
order by 1,2

--looking at Total cases vs Total Death
-- Shows likelihood of deaing in germany

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deatthpercentage
from portfolioproject..CovidDeath
where location like '%germany%'
order by 1,2


--looking at Total cases vs Population
-- shows what percentage of population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from portfolioproject..CovidDeath
where location like '%germany%'
order by 1,2


--Looking at Countries with Heigest Infection Rate compared to papulation
--shows what persentages of population got Covid

Select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as PercentPopulationInfected
from portfolioproject..CovidDeath
--where location like '%germany%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc


--showing countries with higest death count per population


Select location, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeath
--where location like '%germany%'
where continent is not null
group by location
order by totaldeathcount desc


--Lets Break this down by continentSelect location, max(cast(total_deaths as int)) as totaldeathcount

Select location, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeath
--where location like '%germany%'
where continent is null
group by location
order by totaldeathcount desc


-- showing the continent with heighest death count

Select continent, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeath
--where location like '%germany%'
where continent is not null
group by continent
order by totaldeathcount desc



--global number

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/Sum(new_cases)*100 as deatthpercentage
from portfolioproject..CovidDeath
--where location like '%germany%'
where continent is not null
group by date
order by 1,2


--global number per day

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/Sum(new_cases)*100 as deatthpercentage
from portfolioproject..CovidDeath
--where location like '%germany%'
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from portfolioproject..CovidDeath dea
join portfolioproject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location)
From portfolioproject..CovidDeath dea
join portfolioproject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
, (
From portfolioproject..CovidDeath dea
join portfolioproject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location) as rollingpeopelvaccination
--,(rollingPeopleVaccination/population)*100
From portfolioproject..CovidDeath dea
join portfolioproject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use cte

with popvsvac (continent, location, date, population, new_vaccination, rollingpeoplevaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location) as rollingpeopelvaccination
--,(rollingPeopleVaccination/population)*100
From portfolioproject..CovidDeath dea
join portfolioproject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (rollingpeoplevaccination/population)*100
from popvsvac







--temp tabel


drop table if exists #percentpopulationvaccination
create Table #percentpopulationvaccination
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccination numeric
)

insert into #percentpopulationvaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location) as rollingpeopelvaccination
--,(rollingPeopleVaccination/population)*100
From portfolioproject..CovidDeath dea
join portfolioproject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
order by 2,3

select*, (rollingpeoplevaccination/population)*100
from #percentpopulationvaccination


--creating view to store  datafor visulization

Create View PercentpopulationVaccination as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location) as rollingpeopelvaccination
--,(rollingPeopleVaccination/population)*100
From portfolioproject..CovidDeath dea
join portfolioproject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select*
from percentpopulationvaccination