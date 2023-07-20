Select *
From SQLPortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From SQLPortfolioProject..CovidVaccinations
--Order by 3,4

--Select the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From SQLPortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total_Cases vs Total_Deaths
--Shows likelihood of dying if you get Covid in your country


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From SQLPortfolioProject..CovidDeaths
Where location like '%India%'
and continent is not null
order by 1,2

--Looking at Total_Cases vs Population
--Shows what percentage of population got covid

Select Location, date, total_cases, total_deaths, Population, (total_cases/Population)* 100 as DeathPercentage
From SQLPortfolioProject..CovidDeaths
Where location like '%India%'
order by 1,2

--Countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/Population))* 100 as
PercentPopulationInfected
From SQLPortfolioProject..CovidDeaths
--Where location like '%India%'
GROUP BY Location, Population
order by PercentPopulationInfected desc

--Showing Countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLPortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
GROUP BY Location
order by TotalDeathCount desc

--Let's break things down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLPortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
GROUP BY continent
order by TotalDeathCount desc


--Continents with the highest death counts per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLPortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
GROUP BY continent
order by TotalDeathCount desc

--Showing Global Numbers

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
From SQLPortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
Group By date
order by 1,2


Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
From SQLPortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
--Group By date
order by 1,2


--Looking at total population vs vaccination


Select dat.continent, dat.location, dat.date, dat.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dat.Location Order by dat.location, dat.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)* 100
From SQLPortfolioProject..CovidDeaths dat
Join SQLPortfolioProject..CovidVaccinations vac
    on dat.location = vac.location
	and dat.date = vac.date
where dat.continent is not null
order by 2,3 

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dat.continent, dat.location, dat.date, dat.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations )) OVER (Partition by dat.Location Order by dat.location, dat.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)* 100
From SQLPortfolioProject..CovidDeaths dat
Join SQLPortfolioProject..CovidVaccinations vac
    on dat.location = vac.location
	and dat.date = vac.date
where dat.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)* 100
From PopvsVac



--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dat.continent, dat.location, dat.date, dat.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dat.Location Order by dat.location, dat.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)* 100
From SQLPortfolioProject..CovidDeaths dat
Join SQLPortfolioProject..CovidVaccinations vac
    on dat.location = vac.location
	and dat.date = vac.date
--where dat.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)* 100
From #PercentPopulationVaccinated



--Creating view to store data for later visualisation

CREATE VIEW PercentPopulationVaccinated as
Select dat.continent, dat.location, dat.date, dat.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dat.Location Order by dat.location, dat.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)* 100
From SQLPortfolioProject..CovidDeaths dat
Join SQLPortfolioProject..CovidVaccinations vac
    on dat.location = vac.location
	and dat.date = vac.date
where dat.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated