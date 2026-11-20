create database hr_analytics;
use hr_analytics;

-- 1. Clean view: attrition flag aur income/tenure bands
CREATE OR REPLACE VIEW hr_clean AS
SELECT
  e.*,
  CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END AS Attrition_Flag,
  CASE
    WHEN MonthlyIncome < 3000 THEN 'Low (<3000)'
    WHEN MonthlyIncome < 6000 THEN 'Mid (3000-5999)'
    WHEN MonthlyIncome < 9000 THEN 'Upper-Mid (6000-8999)'
    ELSE 'High (9000+)'
  END AS Income_Band,
  CASE
    WHEN YearsAtCompany <= 2 THEN '0-2 years'
    WHEN YearsAtCompany <= 5 THEN '3-5 years'
    ELSE '6+ years'
  END AS Tenure_Band
FROM hr_employees e;

-- 2. Baseline: overall attrition 
SELECT COUNT(*) AS employees,
       SUM(Attrition_Flag) AS leavers,
       ROUND(AVG(Attrition_Flag) * 100, 1) AS attrition_pct
FROM hr_clean;

-- 3. Overtime 
SELECT OverTime,
       COUNT(*) AS employees,
       ROUND(AVG(Attrition_Flag) * 100, 1) AS attrition_pct
FROM hr_clean
GROUP BY OverTime;

-- 4. Job role, roles with 30+ employees 
SELECT JobRole,
       COUNT(*) AS employees,
       ROUND(AVG(Attrition_Flag) * 100, 1) AS attrition_pct
FROM hr_clean
GROUP BY JobRole
HAVING COUNT(*) >= 30
ORDER BY attrition_pct DESC;

-- 5. Department 
SELECT Department,
       COUNT(*) AS employees,
       ROUND(AVG(Attrition_Flag) * 100, 1) AS attrition_pct
FROM hr_clean
GROUP BY Department
ORDER BY attrition_pct DESC;

-- 6. Income band 
SELECT Income_Band,
       COUNT(*) AS employees,
       ROUND(AVG(Attrition_Flag) * 100, 1) AS attrition_pct
FROM hr_clean
GROUP BY Income_Band
ORDER BY attrition_pct DESC;

-- 7. Job satisfaction (1 = low, 4 = high)
SELECT JobSatisfaction,
       COUNT(*) AS employees,
       ROUND(AVG(Attrition_Flag) * 100, 1) AS attrition_pct
FROM hr_clean
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction;

-- 8. Tenure 
SELECT Tenure_Band,
       COUNT(*) AS employees,
       ROUND(AVG(Attrition_Flag) * 100, 1) AS attrition_pct
FROM hr_clean
GROUP BY Tenure_Band
ORDER BY attrition_pct DESC;

-- 9. Summary: strongest factors vs baseline
SELECT 'Baseline: all employees' AS factor, ROUND(AVG(Attrition_Flag) * 100, 1) AS attrition_pct FROM hr_clean
UNION ALL
SELECT 'Overtime: Yes', ROUND(AVG(Attrition_Flag) * 100, 1) FROM hr_clean WHERE OverTime = 'Yes'
UNION ALL
SELECT 'Overtime: No', ROUND(AVG(Attrition_Flag) * 100, 1) FROM hr_clean WHERE OverTime = 'No'
UNION ALL
SELECT 'Job role: Sales Representative', ROUND(AVG(Attrition_Flag) * 100, 1) FROM hr_clean WHERE JobRole = 'Sales Representative'
UNION ALL
SELECT 'Income: Low (<3000)', ROUND(AVG(Attrition_Flag) * 100, 1) FROM hr_clean WHERE Income_Band = 'Low (<3000)'
UNION ALL
SELECT 'Tenure: 0-2 years', ROUND(AVG(Attrition_Flag) * 100, 1) FROM hr_clean WHERE Tenure_Band = '0-2 years';





