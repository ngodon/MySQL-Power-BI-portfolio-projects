SELECT * 
FROM layoffs;
-- Data cleaning steps:
-- 1. Remove duplicates
-- 2. Standardize the data
-- 3. Clean null values or blank values
-- 4. Remove any Columns

# 1. Remove duplicates
-- create a copy from the raw database to work with (staging table)
DROP TABLE IF EXISTS layoffs_staging_2;
CREATE TABLE layoffs_staging_2
LIKE layoffs_staging;

-- insert distinct values to the staging table to filter out duplicates
INSERT layoffs_staging_2
SELECT DISTINCT *
FROM layoffs;

SELECT * 
FROM layoffs_staging_2;

-- 2. Standardize data

-- 2.1. Standardize company column
SELECT company, TRIM(company)
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET company = TRIM(company);

-- 2.2 Standardize industry column
SELECT DISTINCT industry
FROM layoffs_staging_2;

SELECT industry
FROM layoffs_staging_2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

# 2.3 Standardize country column
SELECT DISTINCT country
FROM layoffs_staging_2;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging_2
WHERE country LIKE 'United States%'
ORDER BY country;

UPDATE layoffs_staging_2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

# 2.4 Standardize date column
SELECT `date`
FROM layoffs_staging_2;

SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') 
FROM layoffs_staging_2;

-- transform text format into date format
UPDATE layoffs_staging_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- change text data type into date 
ALTER TABLE layoffs_staging_2
MODIFY COLUMN `date` DATE;

# 3. Null values or blank values

# 3.1. industry column

SELECT *
FROM layoffs_staging_2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging_2
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND (t2.industry IS NOT NULL AND t2.industry != '')
;

--  update blank values using existing record of the same company
UPDATE layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND (t2.industry IS NOT NULL AND t2.industry != '')
;

# 4. Delete unwanted/unhelpful data

SELECT *
FROM layoffs_staging_2
WHERE (total_laid_off IS NULL OR total_laid_off = '') OR (percentage_laid_off IS NULL OR percentage_laid_off = '');

DELETE
FROM layoffs_staging_2
WHERE (total_laid_off IS NULL OR total_laid_off = '') AND (percentage_laid_off IS NULL OR percentage_laid_off = '');









