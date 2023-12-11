
-- A quick look at the dataset
SELECT TOP (100) * FROM BureauWage


-- Check  NULLs in JOBS_1000, LOC_QUOTIENT, PCT_TOTAL, PCT_RPT, ANNUAL, and HOURLY
	-- Percentage of NULLs in each column
DECLARE @length int = (SELECT COUNT(*) FROM BureauWage)
SELECT CAST(SUM(CASE WHEN JOBS_1000 IS NULL THEN 1 ELSE 0 END) AS numeric) / @length * 100 AS jobs_1000,
		CAST(SUM(CASE WHEN LOC_QUOTIENT IS NULL THEN 1 ELSE 0 END) AS numeric) / @length * 100 AS loc_quotient,
		CAST(SUM(CASE WHEN PCT_TOTAL IS NULL THEN 1 ELSE 0 END) AS numeric) / @length * 100 AS pct_total,
		CAST(SUM(CASE WHEN PCT_RPT IS NULL THEN 1 ELSE 0 END) AS numeric) / @length * 100 AS pct_rpt,
		CAST(SUM(CASE WHEN ANNUAL IS NULL OR ANNUAL = ' ' THEN 1 ELSE 0 END) AS numeric) / @length * 100 AS annual,
		CAST(SUM(CASE WHEN HOURLY IS NULL OR HOURLY = ' ' THEN 1 ELSE 0 END) AS numeric) / @length * 100 AS hourly
FROM BureauWage

	-- Drop those columns
ALTER TABLE BureauWage
DROP COLUMN JOBS_1000, LOC_QUOTIENT, PCT_TOTAL, PCT_RPT, ANNUAL, HOURLY


-- Hourly Mean/Median Wage, Annually Mean/Median Wage
SELECT H_MEAN,
		H_MEAN * 2080 AS ESTIMATED_A_MEAN,
		A_MEAN
FROM BureauWage
	-- So, A_MEAN can be calculated by multiplying H_MEAN by 2080 (40 hours/ week for 52 weeks)

	-- Check for Nulls in H_MEAN, A_MEAN, H_MEDIAN and A_MEDIAN
		-- Numbers of records contain NULLS in both H_MEAN and A_MEAN (5079 rows)
SELECT COUNT(*) FROM BureauWage
WHERE A_MEAN IS NULL AND H_MEAN IS NULL AND A_MEDIAN IS NULL AND H_MEDIAN IS NULL

SELECT * FROM BureauWage
WHERE A_MEAN IS NULL AND H_MEAN IS NULL AND A_MEDIAN IS NULL AND H_MEDIAN IS NUL
		-- Drops those records
DELETE FROM BureauWAGE
WHERE A_MEAN IS NULL AND H_MEAN IS NULL AND A_MEDIAN IS NULL AND H_MEDIAN IS NULL

		
		-- Replace NULLS in H_MEAN and A_MEAN, H_MEDIAN and A_MEDIAN
UPDATE BureauWage
SET H_MEAN = CASE WHEN H_MEAN IS NULL THEN A_MEAN / 2080 ELSE H_MEAN END,
	A_MEAN = CASE WHEN A_MEAN IS NULL THEN H_MEAN * 2080 ELSE A_MEAN END,
	H_MEDIAN = CASE WHEN H_MEDIAN IS NULL THEN A_MEDIAN / 2080 ELSE H_MEDIAN END,
	A_MEDIAN = CASE WHEN A_MEDIAN IS NULL THEN H_MEDIAN * 2080 ELSE A_MEDIAN END

UPDATE BureauWage
SET	H_MEAN = CASE WHEN H_MEAN IS NULL THEN H_MEDIAN ELSE H_MEAN END,
	A_MEAN = CASE WHEN A_MEAN IS NULL THEN A_MEDIAN ELSE A_MEAN END,
	H_MEDIAN = CASE WHEN H_MEDIAN IS NULL THEN H_MEAN ELSE H_MEDIAN END,
	A_MEDIAN = CASE WHEN A_MEDIAN IS NULL THEN A_MEAN ELSE A_MEDIAN END


-- Check for duplicates (36732 duplicates)
WITH RowNum AS (
SELECT * ,
	ROW_NUMBER() OVER (
					PARTITION BY NAICS, NAICS_TITLE, OCC_TITLE, TOT_EMP, H_MEAN, A_MEAN
					ORDER BY OCC_TITLE) row_num
FROM BureauWage
)
DELETE 
FROM RowNum
WHERE row_num > 1


-- Extract City from AREA_TITLE
ALTER TABLE BureauWage
ADD CITY Nvarchar(255)

UPDATE BureauWage
SET CITY =  CASE WHEN AREA_TITLE LIKE '%,%' THEN LEFT(AREA_TITLE, CHARINDEX(',', AREA_TITLE) - 1)
					ELSE NULL END 
			





