------ Exploratory Data Analysis in SQL Server----------

-- Total number of industries?
SELECT  COUNT(*)
FROM (SELECT DISTINCT NAICS_TITLE 
		FROM BureauWage) AS temp
	-- There are total 394 different industries in the dataset which is kind of a lot. 
	-- Need deeper look into this field and clean it.


-- What are the most common occupations in the dataset?
SELECT TOP (10) OCC_TITLE,
		COUNT(*) AS num_of_occ
FROM BureauWage
GROUP BY OCC_TITLE
HAVING OCC_TITLE <> 'All Occupations'
ORDER BY num_of_occ DESC
	

-- Number of jobs in metropolitan and nonmetropolitan areas?
SELECT area, COUNT(*) AS num
FROM (SELECT CASE WHEN AREA_TITLE LIKE '%nonmetropolitan%' 
		THEN 'Nonmetro' ELSE 'Metro'
		END AS area
	 FROM BureauWage) AS tem
GROUP BY area
	-- Most of the occupations are in metropolitan area (320,811 vs 47,237).


-- Difference in the average between Annual Mean Wage, Annual Median Wage, and Annual 90th Percentile Wage
SELECT AVG(A_MEAN) AS MEAN,
		AVG(A_MEDIAN) AS MEDIAN,
		AVG(A_PCT90) AS PCT90
FROM BureauWage
	-- Mean of annual mean wage and mean of annual median wage are slightly different.
	-- Mean of annual 90th percentile wage is a little greater.


-- Difference in wage between metropolitan and nonmetropolitant areas
WITH TempArea AS (
	SELECT CASE WHEN AREA_TITLE LIKE '%nonmetropolitan%' THEN 'Nonmetro'
			ELSE 'Metro' END AS Area,
			A_MEAN,
			A_MEDIAN,
			A_PCT90
	FROM BureauWage
)
SELECT Area,
		AVG(A_MEAN) AS MEAN,
		AVG(A_MEDIAN) AS MEDIAN,
		AVG(A_PCT90) AS PCT90
FROM TempArea
GROUP BY Area
	-- Jobs seem to pay higher wage in metro area than in nonmetro area.


-- Wage differences among industries
SELECT TOP (10) NAICS_TITLE,
		AVG(A_MEAN) AS MEAN,
		AVG(A_MEDIAN) AS MEDIAN
FROM BureauWage
GROUP BY NAICS_TITLE
ORDER BY MEAN DESC, MEDIAN DESC
		-- Top 10 industries include monetary authorities, pipeline transportation, nuclear and solar electric power,
		-- oil and gas extraction, computer manufacturing, and securities, and commodity contracts.


-- Data-related Jobs
	-- Job positions in the data field. 
SELECT DISTINCT OCC_TITLE FROM BureauWage
WHERE OCC_TITLE LIKE '%data%'

	-- Difference in mean of median wage between data-related job titles
SELECT OCC_TITLE,
		A_MEDIAN AS MedWage,
		ROUND(AVG(A_MEDIAN) OVER(PARTITION BY OCC_TITLE), 2) AS MedWageByPosition
FROM BureauWage
WHERE OCC_TITLE LIKE '%data%'
ORDER BY MedWageByPosition DESC

	-- How different in mean of median wage for data-related jobs among states?
WITH StateDataWage AS(
	SELECT PRIM_STATE,
			OCC_TITLE,
			A_MEDIAN
	FROM BureauWage
	WHERE OCC_TITLE LIKE '%data%'
)
SELECT TOP (10) PRIM_STATE,
		ROUND(AVG(A_MEDIAN), 2) AS MedianWage
FROM StateDataWage
GROUP BY PRIM_STATE
ORDER BY MedianWage DESC, PRIM_STATE

	-- Ranks mean of median wage across job positions for each industry where their median wage is greater than the average of median wage.
WITH GreaterThanAveWage AS (SELECT	NAICS_TITLE,
		OCC_TITLE,
		AVG(A_MEDIAN) AS MeanofMedWage
		FROM BureauWage
		WHERE OCC_TITLE LIKE '%data%' AND A_MEDIAN >= (SELECT AVG(A_MEDIAN) FROM BureauWage)
		GROUP BY NAICS_TITLE, OCC_TITLE
)
SELECT NAICS_TITLE,
		OCC_TITLE,
		MeanofMedWage,
		RANK () OVER(PARTITION BY NAICS_TITLE ORDER BY MeanofMedWage DESC) AS RANK
FROM GreaterThanAveWage

-- Software and Web Delopment Career
	-- What positions are in the dataset for software and web career?
SELECT DISTINCT OCC_TITLE FROM BureauWage
WHERE OCC_TITLE LIKE '%software%' OR OCC_TITLE LIKE '%web%'

	-- Ranks mean of median wage across job titles for each industry
SELECT NAICS_TITLE,
		OCC_TITLE,
		MeanofMedWage,
		RANK() OVER(PARTITION BY NAICS_TITLE ORDER BY MeanofMedWage DESC) AS MedWageRANK
FROM (SELECT NAICS_TITLE,
			OCC_TITLE,
			AVG(A_MEDIAN) AS MeanofMedWage
		FROM BureauWage
		WHERE (OCC_TITLE LIKE '%software%' OR OCC_TITLE LIKE '%web%') AND NAICS_TITLE NOT LIKE '%cross%industry%'
		GROUP BY NAICS_TITLE, OCC_TITLE	
		) t

