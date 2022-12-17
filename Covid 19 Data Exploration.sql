/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


select location ,date,total_cases,new_cases ,total_deaths,population from [dbo].[CovidDeaths]
order by 1,2

--select data that we are going to be using 

select location,date,total_cases,new_cases,total_deaths,population from coviddeaths
order by 1,2

 ---looking at total cases vs total deaths
 --shows likelihood of dying in you country if you contract covid in your country
 select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercendage 
 from coviddeaths
 where location in ('asia')
order by 1,2

--looking at totalcases vs population
--show what precentage of population got covid
 select location,date,total_cases,new_cases,total_deaths,population,(total_cases/population)*100 as totalcasepercendage 
 from coviddeaths
-- where location in ('asia')
order by 1,2


--looking at totaldeath vs population
--show precendate of population death in covid
 select location,date,total_cases,new_cases,total_deaths,population,(total_deaths/population)*100 as deathpercendage 
 from coviddeaths
 where location in ('asia')
order by 1,2

--looking at countries with hight infection rate compared to population
select location,population,max(total_cases),max((total_cases/population))*100 as totalcasespercendage 
 from coviddeaths
 --where location in ('asia')
 group by location,population
order by totalcasespercendage desc


--showing countries with highest depth count per population 

select location,max(convert(int,total_deaths)) totaldeathcount
 from coviddeaths
 where continent is not null
 group by location
order by totaldeathcount desc

--lets break things down by continent

select location,max(convert(int,total_deaths)) totaldeathcount
 from coviddeaths
 where continent is  null
 group by location
order by totaldeathcount desc


select continent,max(convert(int,total_deaths)) totaldeathcount
 from coviddeaths
 where continent is not null
 group by continent
order by totaldeathcount desc

---showing contintents with higesh counter per population

select continent,max(convert(int,total_deaths)) totaldeathcount
 from coviddeaths
 where continent is not null
 group by continent
order by totaldeathcount desc

--global number

select sum(new_cases)total_cases, sum(convert(int,new_deaths))total_deaths,(sum(convert(int,new_deaths))/sum(new_cases))*100 DeathPercentage
from CovidDeaths
where   continent is not null
--group by date
order by 1,2

select continent ,max(cast(total_deaths as int))totaldeath 
from [dbo].[CovidDeaths]
 where continent is not null
 group by continent
order by totaldeath  desc

---looking at total population vs vaccinations
--rolling people vaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location 
,dea.date) RollingPeopleVaccinated
from CovidDeaths dea 
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3 


--use CTE
with popvsvac (continent, location, date,population,new_vaccinations,RollingPeopleVaccinated)
as
(

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location 
,dea.date) RollingPeopleVaccinated
from CovidDeaths dea 
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
)
select *,( RollingPeopleVaccinated /population)*100 from popvsvac




---temptable

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location 
,dea.date) rolingpeoplevacinate
from CovidDeaths dea 
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 

select *,( RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated



------ creating view to store the data for visualizations

create view PercentPopulationVaccinated as

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location 
,dea.date) rolingpeoplevacinate
from CovidDeaths dea 
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated

