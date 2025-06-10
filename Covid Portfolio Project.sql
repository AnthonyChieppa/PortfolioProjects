Select * 
From Covid_deaths
Where continent IS NOT NULL
Order by 3,4

--Select * 
--From Covid_vac
--Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population 
From Covid_deaths
Order by 1,2

-- Looking at total cases vs total deaths
-- NULLIF used for situations where total_cases was 0.
-- Where statement used to find all United States specific data
-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, 
	(total_deaths/NULLIF(total_cases,0))*100 AS Death_percenatge 
From Covid_deaths
Where location LIKE '%States'
And continent IS NOT NULL
Order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got covid

Select Location, date, total_cases, population, 
	(total_cases/NULLIF(population,0))*100 AS Percent_pop_infected
From Covid_deaths
Where location LIKE '%States' 
And continent IS NOT NULL
Order by 1,2

-- Looking at Countries with highest infecrtion rate compared to population
-- Where statment on total_cases that removes the countries that have no data

Select Location, population, MAX(total_cases) AS Highest_Infection_Count,
	MAX((total_cases/NULLIF(population,0)))*100 AS Percent_pop_infected
From Covid_deaths
Where total_cases IS NOT NULL 
And continent IS NOT NULL
Group by Location, population
Order by Percent_pop_infected desc

-- Showing countries with highest death count per population
-- Where statment on continent to remove their death counts 

Select Location, Max(total_deaths) AS Total_death_count
From Covid_deaths
Where total_deaths IS NOT NULL 
And continent IS NOT NULL
Group by Location
Order by Total_death_count desc

-- Break things down by continent
-- Showing continents with the highest death count per population

Select continent, Max(total_deaths) AS Total_death_count
From Covid_deaths
Where total_deaths IS NOT NULL 
And continent IS NOT NULL
Group by continent
Order by Total_death_count desc

-- Global numbers
-- Remove date to see overall death percentage

Select SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_deaths, 
	SUM(new_deaths)/SUM(NULLIF(new_cases,0))*100 AS Death_percenatge 
From Covid_deaths
--Where location LIKE '%States' AND 
Where continent IS NOT NULL
--Group by date
Order by 1,2

-- Joined the two tables on the location and date
-- specified terms in the table
-- looking at total popilation vs vaccinations
-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vac)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, 
		dea.date) AS Rolling_People_Vac --,(Rolling_People_Vac/population)
From covid_deaths dea
Join covid_vac vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent IS NOT NULL
--Order by 2,3
)
Select *, (Rolling_People_Vac/population)*100 AS Rolling_Num_Perc
From PopvsVac

-- Temp Table

Drop Table If Exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent varchar,
location varchar,
date date,
population numeric,
new_vaccinations numeric,
Rolling_People_Vac numeric
)

Insert Into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, 
		dea.date) AS Rolling_People_Vac --,(Rolling_People_Vac/population)
From covid_deaths dea
Join covid_vac vac
	On dea.location = vac.location
	And dea.date = vac.date
--Where dea.continent IS NOT NULL
--Order by 2,3

Select *, (Rolling_People_Vac/population)*100 AS Rolling_Num_Perc
From PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View Per_Pop_Vac As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, 
		dea.date) AS Rolling_People_Vac --,(Rolling_People_Vac/population)
From covid_deaths dea
Join covid_vac vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent IS NOT NULL
--Order by 2,3

Select * 
From Per_Pop_Vac

Create View Global_Deaths AS
Select SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_deaths, 
	SUM(new_deaths)/SUM(NULLIF(new_cases,0))*100 AS Death_percenatge 
From Covid_deaths
--Where location LIKE '%States' AND 
Where continent IS NOT NULL
--Group by date
--Order by 1,2

Create View Death_per_Pop AS
Select Location, Max(total_deaths) AS Total_death_count
From Covid_deaths
Where total_deaths IS NOT NULL 
And continent IS NOT NULL
Group by Location
Order by Total_death_count desc

Create View Death_Count_Continent AS
Select continent, Max(total_deaths) AS Total_death_count
From Covid_deaths
Where total_deaths IS NOT NULL 
And continent IS NOT NULL
Group by continent
Order by Total_death_count desc

