-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

create database world_layoff;
select * from layoffs;

-- Broad Information of Table
describe layoffs;

/* first thing we want to do is create a staging table.
This is the one we will work in and clean the data.
We want a table with the raw data in case something happens */

create table layoffs2 LIKE layoffs;

-- Insert values
INSERT layoffs2
select * from layoffs;

/* now when we are data cleaning we usually follow a few steps
1. check for duplicates and remove any
2. standardize data and fix errors
3. Look at null values and see what 
4. remove any columns and rows that are not necessary - few ways */

-- Find duplicate values
select *, row_number()
OVER(partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions)
as row_num from layoffs2;

with duplicate_cte as
(select *, row_number()
OVER(partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions)
as row_num from layoffs2)
select * from duplicate_cte where row_num > 1;

-- these are the ones we want to delete where the row number is > 1 or 2or greater essentially

-- create a new column and add those row numbers in. Then delete where row numbers are over 2, then delete that column
CREATE TABLE `layoffs3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int)
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
  
  -- INSERT Values 
  /* Insert values from table 'layoffs2' which is created by above query using WINDOW FUNCTIONS */

insert layoffs3
select *, row_number()
OVER(partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions)
as row_num from layoffs2;

-- Remove Duplicates by using DELETE query
DELETE from layoffs3 
where row_num >1;
select * from layoffs3 where row_num >1;

-- Standardizing Data

-- UPDATE 'Company' column
UPDATE layoffs3
SET company = TRIM(company);

-- if we look at industry it looks like we have some null and empty rows
-- UPDATE 'Industry' column
select distinct Industry from layoffs3
order by 1;

--  the Crypto has multiple different variations. We need to standardize that - let's say all to Crypto
UPDATE layoffs3
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- UPDATE 'Country' Column
select * from layoffs3
order by country desc;

/* everything looks good except apparently we have some "United States" and some "United States." with a period at the end. 
Let's standardize this. */

UPDATE layoffs3
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- UPDATE 'date' column. Change the data type from text to date.
UPDATE layoffs3
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs3
MODIFY COLUMN date DATE;

-- we should set the blanks to nulls since those are typically easier to work with
UPDATE layoffs3
SET industry = null
WHERE Industry = '';

-- UPDTAE the column'Industry' 
UPDATE layoffs3 as t1
JOIN 
layoffs3 as t2
ON t1.company = t2.company
SET t1.Industry = t2.Industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

select * from layoffs3
where industry IS NULL OR industry = '';

-- Delete Useless data we can't really use
delete FROM layoffs3
WHERE total_laid_off IS NULL
AND 
percentage_laid_off IS NULL;

ALTER Table layoffs3
DROP column row_num;

										-- EDA (Exploratory Data Analysis)
                                        
-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers

select * from layoffs3;

-- Indutsry wise Layoff
select Industry,
max(total_laid_off) as Max_fired, 
min(total_laid_off) as Min_fired
FROM layoffs3
group by Industry;

-- Which country has most affected by layoff
select country,
max(total_laid_off) as Max_fired, 
min(total_laid_off) as Min_fired
FROM layoffs3
group by country
order by  max_fired DESC;

-- Looking at Percentage to see how big these layoffs were
select max(percentage_laid_off) as `max_layoff%`,
min(percentage_laid_off) as `min_layoff%`
FROM layoffs3
WHERE percentage_laid_off is not null;

-- Which companies had 1 which is basically 100 percent of they company laid off
select * from layoffs3
where percentage_laid_off = 1
order by total_laid_off desc;
-- these are mostly startups it looks like who all went out of business during this time

-- if we order by funcs_raised_millions we can see how big some of these companies were
select * from layoffs3
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- Companies with the biggest single Layoff
select company, industry, total_laid_off
from layoffs3
order by 3 desc limit 5;

-- now that's just on a single day

-- Companies with the most Total Layoffs
select company, sum(total_laid_off) as total_layoffs
from layoffs3
group by company
order by 2 desc limit 10;

-- by location
select location, sum(total_laid_off) as total_layoffs
from layoffs3
group by location
order by 2 desc limit 10;

-- this is total in the past 3 years or in the dataset
-- by country
select country, sum(total_laid_off) as total_layoffs
from layoffs3
group by country
order by 2 desc limit 10;

select year(date) as year,
concat((sum(total_laid_off)/1000),' k') as total_layoffs
from layoffs3
group by year(date)
order by year desc
limit 10; 

select industry, sum(total_laid_off) as total_layoff
from layoffs3
group by industry
order by 2 desc;

select stage, sum(total_laid_off) as total_layoff
from layoffs3
group by stage
order by 2 desc;

-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year.
with CTE1 as(
select company, year(date) as years,
sum(total_laid_off) total_layoff
from layoffs3
group by company, years
),

CTE2 as(
select company, years, total_layoff, 
dense_rank () OVER (partition by years order by total_layoff DESC) as ranking
FROM CTE1
)

select company, years, total_layoff, ranking
FROM CTE2
where ranking <=3
AND years IS NOT NULL
order by years ASC, total_layoff DESC;


