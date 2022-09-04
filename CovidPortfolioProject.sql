-- Viewing CovidDeaths table to assure import of data and ordering it firstly by location and then date


Select *
From CovidPortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4



-- Viewing CovidVaccinations table to assure import of data and ordering it firstly by location and then date


Select *
From CovidPortfolioProject..CovidVaccinations
Where continent is not null 
order by 3,4



-- Selecting the Data that I am going to be start with


Select Location, date, total_cases, new_cases, total_deaths, population
From CovidPortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in India


Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
Where location like '%India%'
and continent is not null 
order by 1,2



-- Total Cases vs Population
-- Shows what percentage of population infected with Covid


Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidPortfolioProject..CovidDeaths
--Where location like '%India%'
order by 1,2



-- Countries with Highest Infection Rate compared to Population


Select Location, Population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidPortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected Desc



-- Countries with Highest Death Count


Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount Desc



-- Showing contintents with the highest death count 


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount Desc



-- GLOBAL NUMBERS



-- Number of new cases, globally, on a particular date


Select date, SUM(new_cases) as Number_of_New_Cases
From CovidPortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2



-- Number of deaths, globally, on a particular date


Select date, SUM(cast(new_deaths as int)) Number_of_Deaths
From CovidPortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2



-- Percentage of deaths, globally, on a particular date


Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativePeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (CumulativePeopleVaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (CumulativePeopleVaccinated/Population)*100 as CumulativePercentageOfPeopleVaccinated
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativePeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (CumulativePeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



Select *
From PercentPopulationVaccinated