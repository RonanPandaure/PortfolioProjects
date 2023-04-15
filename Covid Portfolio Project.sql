--select *
--from PortefolioProject..CovidDeaths
--order by 3,4

--select *
--from PortefolioProject..CovidVaccinations
--order by 3,4

--Select Data that I will be using

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortefolioProject..covidDeaths
Where continent is not null
Order by 1,2

-- Looking at total Cases VS total Deaths in France
-- Allow us to see the likelihood of dying of covid in 2020 & 2021 based on countries
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
From PortefolioProject..covidDeaths
Where location like 'France'
Order by 1,2

-- What rate of the population got Covid in France?
Select Location, Date, total_cases, Population, (total_cases/population)*100 AS PercentPopulationInfected
From PortefolioProject..covidDeaths
Where location like 'France'
Order by 1,2

--What country had the most infection rate worldwild?
Select location, population, Max(total_cases) as HighestInfectionCount, Max((Total_cases/population))*100 as 
PercentPopulationInfected
from PortefolioProject..CovidDeaths
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with the Highest Death Count 
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortefolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc


--Showing Continent with the Highest Death Count 
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortefolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

--Global numbers by date
Select date, SUM(new_cases) AS GlobalNewCase, sum(cast(new_deaths as int)) as GlobalNewDeaths, 
sum(cast(New_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
From PortefolioProject..covidDeaths
Where continent is not null
Group by date
Order by 1,2

--Global total cases 
Select SUM(new_cases) AS GlobalNewCase, sum(cast(new_deaths as int)) as GlobalNewDeaths, 
sum(cast(New_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
From PortefolioProject..covidDeaths
Where continent is not null
Order by 1,2


--Looking at total Population Vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as TotalVaccinated
From covidDeaths dea
Join covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3 

		--CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, TotalVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, (convert(int,vac.new_vaccinations))
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as TotalVaccinated
From covidDeaths dea
Join covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
) 
Select * , (TotalVaccinated/population)*100
From PopvsVac

--TEMP Table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, (convert(int,vac.new_vaccinations))
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as TotalVaccinated
From covidDeaths dea
Join covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Select *, (TotalVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, (convert(int,vac.new_vaccinations)) as new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as TotalVaccinated
From covidDeaths dea
Join covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

select *
from PercentPopulationVaccinated