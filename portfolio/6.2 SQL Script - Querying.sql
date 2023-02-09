-- 1. PRELIMINARY QUERYING
SELECT 
    *
FROM
    coviddeaths;

SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_Deaths,
    population
FROM
    coviddeaths
ORDER BY location , date ASC;

-- 2. TOTAL DEATHS vs. CASES / RATIO
SELECT 
    location,
    MAX(total_cases),
    MAX(total_deaths),
    MAX(total_deaths) / MAX(total_cases) * 100 AS DeathCaseRatio
FROM
    coviddeaths
WHERE
    location LIKE '%states%'
GROUP BY location;


-- 3. TOTAL CASES vs. POPULATION
SELECT 
    location,
    date,
    total_cases,
    population,
    (total_cases / population * 100) AS CasePopulationRatio
FROM
    coviddeaths
WHERE
    location LIKE '%states%';

-- 4. HIGHEST INFECTION RATE
SELECT 
    location,
    MAX(total_cases) AS HighestCount,
    (MAX(total_cases) / MAX(population)) AS InfectionRate
FROM
    coviddeaths
GROUP BY location
ORDER BY InfectionRate DESC;

-- 5. COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT 
    location,
    MAX(total_deaths) AS HighestCount,
    (MAX(total_deaths) / MAX(population)) AS DeathRate
FROM
    coviddeaths
WHERE
    continent != ''
GROUP BY location
ORDER BY HighestCount DESC;

-- 5.1 BY CONTINENT
SELECT 
    continent, MAX(total_deaths) TotalDeaths
FROM
    coviddeaths
WHERE
    continent != ''
GROUP BY continent
ORDER BY TotalDeaths DESC;

-- 5.2 GLOBAL
SELECT 
    date,
    MAX(total_cases),
    MAX(total_deaths),
    (MAX(total_deaths) / MAX(total_cases)) * 100 AS deathp
FROM
    coviddeaths
WHERE
    continent != ''
GROUP BY date
ORDER BY 1 DESC , 2;

SELECT 
    date,
    SUM(new_cases) AS total_cases,
    SUM(new_deaths),
    SUM(new_deaths) / SUM(new_cases) * 100 AS dp
FROM
    coviddeaths
WHERE
    continent != ''
GROUP BY date
ORDER BY 1;

SELECT 
    SUM(new_cases),
    SUM(new_deaths),
    SUM(new_deaths) / SUM(new_cases) * 100 AS dp
FROM
    coviddeaths
WHERE
    continent != ''
ORDER BY 1;

-- 6. JOINS
SELECT 
    *
FROM
    coviddeaths CD
        JOIN
    covidvaccinations CV ON cd.location = CV.location
        AND CD.date = CV.date;

-- 6.1 VACCINATION
SELECT 
    CD.continent, CD.location, CD.date, SUM(CV.new_vaccinations) AS NewVaccination
FROM
    coviddeaths CD
        JOIN
    covidvaccinations CV ON CD.location = CV.location
        AND CD.date = CV.date
WHERE
    CD.location = 'Canada'
GROUP BY CD.continent , CD.location , CD.date;

SELECT 
    CD.continent, CD.location, cd.date, (CV.new_vaccinations) AS NewVaccination
FROM
    coviddeaths CD JOIN covidvaccinations CV 
    ON CD.location = CV.location AND CD.date = CV.date
WHERE
    CD.location = 'Canada';

-- 7. ROLLING COUNT
SELECT CD.continent, CD.location, CD.date, (CV.new_vaccinations) AS 'New Vaccinations', 
	SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS 'Rolling Count Vaccinated'
FROM coviddeaths CD
JOIN covidvaccinations CV
ON CD.location = CV.location and CD.date = CV.date
WHERE cd.location = 'Canada';

-- 8. CTE, TEMP TABLE, VIEW
-- 8.1 CTE 
WITH PopVsVac (continent, location, date, population, new_vaccinations, rolling)
AS  
(
SELECT CD.continent, CD.location, CD.date, CD.population, (CV.new_vaccinations) as NewVaccinations, 
	SUM(CV.new_vaccinations) over (PARTITION BY CD.location ORDER BY CD.location, CD.date) as rolling
FROM coviddeaths CD
JOIN covidvaccinations CV
ON CD.location = CV.location and CD.date = CV.date
WHERE CD.location = 'Canada'
)
SELECT *, rolling/population*100 as RollingVacinnatedRatio
FROM PopVsVac;

-- 8.2 TEMP TABLE
DROP TABLE IF EXISTS TEMPppv;

CREATE TABLE TEMPppv (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vac NUMERIC,
    rolling NUMERIC
);

INSERT INTO TEMPppv
(
SELECT CD.continent, CD.location, CD.date, CD.population, (CV.new_vaccinations) AS NewVaccinations, 
	SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS rolling
FROM coviddeaths CD
JOIN covidvaccinations CV
ON CD.location = CV.location and CD.date = CV.date
WHERE CD.location = 'Canada'
);

SELECT 
    *
FROM
    TEMPppv;

-- 8.3 VIEWS
CREATE VIEW vppc AS (
SELECT CD.continent, CD.location, CD.date, CD.population, (CV.new_vaccinations) AS NewVaccinations, 
	SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS rolling
FROM coviddeaths CD
JOIN covidvaccinations CV
ON CD.location = CV.location and CD.date = CV.date
WHERE CD.location = 'Canada'
);

SELECT 
    *
FROM
    vppc


