select location,date,total_cases,new_cases,total_deaths,population
  FROM [covid project].[dbo].[covid_deaths]
  order by 1,2
--Comparing total cases to total death
--Likelihood of contracting covid in naija

  select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as PercentageOFdeath
  FROM [covid project].[dbo].[covid_deaths]
  --where location like 'Nigeria'
  --where continent is not null
  order by 1,2

  --Total cases vs population
  --shows percentage of population with covid in Naija

  select location,date,total_cases,population,(total_cases/population)*100 as PercentageOFpopulationInfected
  FROM [covid project].[dbo].[covid_deaths]
  --where location like 'Nigeria'
  --where continent is not null
  order by 1,2

  --Highest infection rate compared to popuation

  select location,population, max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentageOFpopulationInfected
  FROM [covid project].[dbo].[covid_deaths]
  where continent is not null
  --where location like 'Nigeria'
  group by location, population
  order by 4 desc

  --Highest death count by country

  
  select location,max(cast(total_deaths as int)) as HighestDeathCount
  FROM [covid project].[dbo].[covid_deaths]
  where continent is null
  --where location like 'Nigeria'
  group by location
  order by 2 desc

    --Highest death count by continent

  select continent,max(cast(total_deaths as int)) as HighestDeathCount
  FROM [covid project].[dbo].[covid_deaths]
    where continent is null

  --where location like 'Nigeria'
  group by continent
  order by 2 desc

  -- GLOBAL FIGURES
  
 select date,sum(new_cases) as global_daily_new_cases, sum(cast(new_deaths as int)) as global_daily_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as global_perecntage_death
  FROM [covid project].[dbo].[covid_deaths]
  --where location like 'Nigeria'
  where continent is not null
  group by date
  order by 1,2

  --USING CTE
  -- Total Population vs vaccinations

  with popVsVacc (continent,location,date,population,new_vaccinations,pple_vaccinated_cum)
  as (
  select dea.continent,
  dea.location,
  dea.date, 
  dea.population, 
  vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as Pple_vaccinated_cum
  
  from [covid project].dbo.covid_deaths dea
join covid_vaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date)
--where dea.continent is not null
--order by 1,2,3)
 select *, (pple_vaccinated_cum/population)*100 as percentageOfVaccinatedPerLocation from popVsVacc

 --USING TEMP TABLE

 drop table if exists #percentageOfPopulationVaccinated
 create table #percentageOfPopulationVaccinated
 (continent nvarchar(255),
  location nvarchar(255),
  date datetime, 
  population numeric, 
  new_vaccinations numeric,
  Pple_vaccinated_cum numeric)

 insert into  #percentageOfPopulationVaccinated
 select dea.continent,
  dea.location,
  dea.date, 
  dea.population, 
  vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as Pple_vaccinated_cum
  
  from [covid project].dbo.covid_deaths dea
join covid_vaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3)
select *, (pple_vaccinated_cum/population)*100 as percentageOfVaccinatedPerLocation from #percentageOfPopulationVaccinated


--Creating view to store data for later visualization

create view percentageOfPopulationVaccinated as 
select dea.continent,
  dea.location,
  dea.date, 
  dea.population, 
  vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as Pple_vaccinated_cum
  
  from [covid project].dbo.covid_deaths dea
join covid_vaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3)

create view  HighestDeathCount as
  select continent,max(cast(total_deaths as int)) as HighestDeathCount
  FROM [covid project].[dbo].[covid_deaths]
    where continent is null

  --where location like 'Nigeria'
  group by continent
  --order by 2 desc
