use PortfoliooProject;
--select * from covid_vaccination;
select * from covid_deaths;

--select the data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
order by location, date;

--Looking at total number of deaths

select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as death_percent
from covid_deaths
where location like '%india%' and (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 is not null
order by location, date;


--looking at total cases vs population
--shows what percent of population got covid

select location, date, population, total_cases,  (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as infected_population
from covid_deaths
where location like '%india%' and (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 is not null
order by location, date;

--Looking at countries with highest infected rate compared to population

select location, population, max(convert(bigint, total_cases)) as HighestInfection,  (max(CONVERT(bigint, total_cases)) / NULLIF(CONVERT(float, population), 0))*100 as infected_population
from covid_deaths
--where location like '%states%' and (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 is not null
group by location, population
order by infected_population desc;

--showing countries with highest death count percent per population
select location, population, max(convert(bigint, total_deaths)) as Highestdeaths,  (max(CONVERT(bigint, total_deaths)) / NULLIF(CONVERT(float, population), 0))*100 as death_percentage
from covid_deaths
--where location like '%states%' and (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 is not null
group by location, population
order by death_percentage desc;

--showing countries with highest deaths
select location, max(cast(total_deaths as int)) as MaxDeaths
from covid_deaths
where continent is not null
group by location
order by MaxDeaths desc;

--showing continents with highest deaths count
select continent, max(cast(total_deaths as int)) as MaxDeaths
from covid_deaths
where continent is not null
group by continent
order by MaxDeaths desc;

--showing countries with highest deaths count

select location, max(cast(total_deaths as int)) as MaxDeaths
from covid_deaths
where continent is not null
group by location
order by MaxDeaths desc;

--Global numbers

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from covid_deaths
where continent is not null
--group by date
order by 1,2;

--Joining covid_deaths and covid_vaccination tables

select * from covid_deaths dea
join covid_vaccination vac
on dea.location = vac.location and
	dea.date = vac.date;

--Looking at total population got vaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from covid_deaths dea
join covid_vaccination vac
on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
order by 1, 2;

--Looking at total population got vaccinated location wise daily vaccinations update sum

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
from covid_deaths dea
join covid_vaccination vac
on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null and dea.location = 'india'
order by 1, 2;




--Using CTE (Common Table Expreesion)



with popVSvac (continent, location, date, population, new_vaccinations, rollingUpVaccinations)

as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingUpVaccinations

from covid_deaths dea
join covid_vaccination vac
on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null and dea.location = 'india'
--order by 1, 2
)

select *, (rollingUpVaccinations/population) * 100
from popVSvac;




--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingupvaccinations numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingUpVaccinations

from covid_deaths dea
join covid_vaccination vac
on dea.location = vac.location and
	dea.date = vac.date
--where dea.continent is not null and dea.location = 'india'
--order by 1, 2

select *, (rollingUpVaccinations/population) * 100
from #PercentPopulationVaccinated;


--creating view to store data for later visualizations


create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingUpVaccinations

from covid_deaths dea
join covid_vaccination vac
on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
--order by 1, 2

select *
from PercentPopulationVaccinated;