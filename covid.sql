-- infected percentage globally
CREATE VIEW GlobalInfectedPercentage AS
select location, date, total_cases, population, (total_cases/population)*100 as infectedPercentage
from covidDeath
order by 1, 2

CREATE VIEW CurrentGlobalStat AS
SELECT SUM(new_cases) AS totalCases, SUM(CONVERT(int, new_deaths)) AS totalDeaths, 
(SUM(new_cases)/SUM(CONVERT(int, new_deaths)))*100 AS deathPercentage
FROM covidDeath


-- death percentage
CREATE VIEW DeathPercentage AS
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from covidDeath
order by 1, 2

-- highest infected percentage
CREATE VIEW InfectedPercentage AS
select location, population, max(total_cases) as total_cases, max(total_cases/population)*100 as infectedPercentage
from covidDeath
group by location, population
order by infectedPercentage DESC

-- highest death percentage per population based on country
CREATE VIEW DeathPercentagePerCountry AS 
select location, population, max(cast(total_deaths as int)) as total_deaths, 
max(cast(total_deaths as int)/population)*100 as deathPercentage
from covidDeath
where continent is not null
group by location, population
order by total_deaths DESC

-- highest death percentage per population based on continent
CREATE VIEW DeathPercentagePerContinent AS
select location, population, max(cast(total_deaths as int)) as total_deaths, 
max(cast(total_deaths as int)/population)*100 as deathPercentage
from covidDeath
where continent is null AND location != 'International'
group by location, population
order by total_deaths DESC

-- global statistic
CREATE VIEW GlobalStatistic AS
select date, sum(cast(total_deaths as int)) as total_deaths, (sum(total_cases)) as totalCases,
(sum(cast(total_deaths as int))/(sum(total_cases)))*100 as deathPercentage
from covidDeath
where continent is not null
group by date
order by date

-- total population vs vaccinations
CREATE VIEW PopVsVac AS
WITH PopVsVac AS
(
select D.continent, D.location, D.date, D.population, V.new_vaccinations,
sum(cast(V.new_vaccinations as bigint)) 
over (partition by D.continent, D.location order by D.date) as totalVaccinated
from covidDeath as D join covidVaccination as V
on D.continent = V.continent and D.location = V.location and D.date = V.date
--where D.continent = 'Mexico'
)
SELECT *, (totalVaccinated/population)*100 AS VacinatedPercentage
FROM PopVsVac
order by continent, location, date

