sql

-- Mitigation Rule/Query (based on deposit pattern)
-- Goal: to detect a deposit pattern where users increased deposits in fixed increments (ladder deposit) with controlled timing.
-- Systematic escalation suggests automated or coordinated behaviour designed to test deposit limits and accumulate balance for extraction.
-- Note: output shown in full for demonstration purposes; in production this would feed flagged usernames into a case management queue

WITH  deps AS (
       SELECT 
              username,
              deposit_id,
              card_number_masked,
              deposit_datetime,
              DATETIME_DIFF(deposit_datetime, LAG(deposit_datetime) OVER(PARTITION BY username ORDER BY deposit_datetime), MINUTE) AS time_diff_min,
              amount,
              COALESCE(amount - LAG(amount) OVER(PARTITION BY username, card_number_masked ORDER BY deposit_datetime, deposit_id), 0) AS dep_increase,
              deposit_status    
         FROM deposits
)

SELECT *
FROM deps
WHERE dep_increase = [fixed increment deposit amount]
AND time_diff_min BETWEEN 10 AND 20
QUALIFY COUNT(*) OVER(PARTITION BY username) >= 4

-- Example Output:
| username    | deposit_id | card_number_masked | deposit_datetime | time_diff_min | amount | deposit_increase | deposit_status |
|-------------|------------|--------------------|------------------|---------------|--------|------------------|----------------|
| username_xx | 123456     | 123456......1234   | 16/07/XXXX 00:03 | null          | 10     | 0                | approved       |
| username_xx | 123457     | 123456......1234   | 16/07/XXXX 00:13 | 10            | 15     | 15               | approved       |
| username_xx | 123458     | 123456......1234   | 16/07/XXXX 00:23 | 10            | 25     | 10               | failed         |
| username_xx | 123459     | 123456......1234   | 16/07/XXXX 00:34 | 11            | 25     | 0                | approved       |
| username_xx | 123460     | 654321….....4321   | 16/07/XXXX 00:44 | 10            | 5      | 0                | approved       |
