sql
  
-- Monitoring Query
-- Fraud typology: multi-accounting
-- Goal: to identify clusters of newly created accounts on the same IP address 
-- within a short timeframe, which may indicate coordinated account creation. 

SELECT 
       ip,
       COUNT(DISTINCT username) AS username_count
FROM logins
WHERE created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 14 DAY)
GROUP BY ip
HAVING DATETIME_DIFF(MAX(account_created), MIN(account_created), DAYS) <= 2
AND COUNT(DISTINCT username) > = 3
ORDER BY username_count DESC
; 

-- Example output:
-- ip	           | username_count
-- ----------------|---------------
-- 111.233.135.223 | 11
-- 174.0.293.9	   | 9
-- 4.5.181.184	   | 3
