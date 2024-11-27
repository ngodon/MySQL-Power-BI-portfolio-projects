
SELECT * 
FROM layoffs_staging_2
;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging_2
;

-- Show the companies with highest total and percentage laid off
SELECT *
FROM layoffs_staging_2 
WHERE total_laid_off IN
(SELECT MAX(total_laid_off)
FROM layoffs_staging_2)
OR percentage_laid_off IN
(SELECT MAX(percentage_laid_off)
FROM layoffs_staging_2)
ORDER BY total_laid_off DESC
;

-- date range of the data
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging_2
;

-- Total laid off ranking by different categories
SELECT company, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC
;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC
;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC
;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`) DESC
;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY stage
ORDER BY 2 DESC
;

-- Group companies by average laid off percentage
SELECT percent_laid_off_group,
GROUP_CONCAT(company ORDER BY avg_percent SEPARATOR ', ') AS companies
FROM 
(
SELECT company, AVG(percentage_laid_off)*100 AS avg_percent, 
ROUND(AVG(percentage_laid_off), 1) AS percent_laid_off_group
FROM layoffs_staging_2
GROUP BY company
) sub
GROUP BY percent_laid_off_group
ORDER BY percent_laid_off_group DESC
;

-- Show total laid off over time
SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY SUBSTRING(`date`,1,7)
ORDER BY `month`
;

-- Calculating running total of total laid off
-- running total by company over time
WITH runningtotal_cte_company AS 
(
SELECT company, `date`, total_laid_off, SUM(total_laid_off) OVER(PARTITION BY company ORDER BY `date` ASC) AS running_total
FROM layoffs_staging_2
)
SELECT *
FROM runningtotal_cte_company
WHERE running_total > 1000
; 


-- running total by month over time
WITH running_total_date AS
(
SELECT  SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS month_total
FROM layoffs_staging_2
GROUP BY `month`
ORDER BY `month`
)
SELECT `month`, month_total, SUM(month_total) OVER(ORDER BY `month`) AS running_total
FROM running_total_date
;

-- running total by company over the years
WITH runningtotal_cte_companyyear AS
(
SELECT company, SUBSTRING(`date`,1,4) AS `year`, SUM(total_laid_off) AS year_total
FROM layoffs_staging_2
GROUP BY company, `year`
ORDER BY company, `year`
)
SELECT *, SUM(year_total) OVER (PARTITION BY company ORDER BY `year`)
FROM runningtotal_cte_companyyear
;

-- ranking top 5 most laid off companies by years
WITH total_companyyear AS
(
SELECT company, SUBSTRING(`date`,1,4) AS `year`, SUM(total_laid_off) AS year_total
FROM layoffs_staging_2
GROUP BY company, `year`
ORDER BY company, `year`
)
, ranking_companyyear AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY `year` ORDER BY year_total DESC) AS ranking
FROM total_companyyear
WHERE `year` IS NOT NULL AND year_total IS NOT NULL
)
SELECT * 
FROM ranking_companyyear
WHERE ranking <= 5
ORDER BY `year`
;


