select *
from PortfolioProject..Covid_Deaths_info
where continent is not null
order by 3,4

--select *
--from PortfolioProject..Covid_Vaccines_info
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Covid_Deaths_info
order by 1,2

--Looking at total cases vs total deaths
--Likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/ total_cases) * 100 as DeathPercentage
from PortfolioProject..Covid_Deaths_info
where location like '%india%'
order by 1,2


--Looking at total cases vs population
--Shows what percentage of population got covid

select Location, date, population, total_cases, (total_cases/ population) * 100 as PercentPopulationInfected
from PortfolioProject..Covid_Deaths_info
--where location like '%india%'
order by 1,2


--Looking at countries with highest infection rate compared to population
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/ population)) * 100 as PercentPopulationInfected
from PortfolioProject..Covid_Deaths_info
--where location like '%india%'
group by location, population
order by PercentPopulationInfected desc


--Showing the Countries with Highest Death Count per population
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Covid_Deaths_info
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc


--Breaking down by continent

--Showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Covid_Deaths_info
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers
select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_deaths,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..Covid_Deaths_info
--where location like '%india%'
where continent is not null
--group by date
order by 1,2



--Looking at total population vs vaccinations done

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths_info dea
join PortfolioProject..Covid_Vaccines_info vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 2, 3


--Use CTE
with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths_info dea
join PortfolioProject..Covid_Vaccines_info vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population) * 100
from PopvsVac


--Temp table

drop table if exists #PercentpopulationVaccinated
create table #PercentpopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths_info dea
join PortfolioProject..Covid_Vaccines_info vac
on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) * 100
from #PercentpopulationVaccinated


--creating view to store data for later vizualisations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths_info dea
join PortfolioProject..Covid_Vaccines_info vac
        on dea.location = vac.location 
		and dea.date = vac.date
where dea.continent is not null


select* from PercentPopulationVaccinated