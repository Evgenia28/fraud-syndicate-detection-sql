  
-- Follow-up Drill-down Query
-- Fraud typology: card stuffing/limit testing, CNP, card draining
-- Goal: to determine whether clustered accounts exhibit coordinated financial behaviour, 'hit and run' behaviour, deposit velocity, fast withdrawals
-- Note: While this query is shown with hardcoded usernames for demonstration, in a production environment, 
-- this would be automated by joining to the output of the Monitoring Query.


WITH suspect_users AS (
   SELECT 
         username,
         account_created_at,
         first_activity,
         account_status
   FROM  users
   WHERE username IN ('username_x', 'username_y',...'username_z')
),

deposit_summary AS (
  SELECT 
        username,
        COUNT(DISTINCT card_number_masked) AS dep_card_count,
        COUNT(txn_id) AS deposit_count,
        SUM(amount) AS total_deposit
  FROM deposits
  WHERE username IN ('username_x', 'username_y',...'username_z')
),

withdrawal_summary AS (
  SELECT 
        username,
        COUNT(DISTINCT card_number_masked) AS wdl_card_count,
        COUNT(withdrawal_id) AS withdrawal_count,
        SUM(amount) AS total_withdrawal
  FROM withdrawals
  WHERE username IN ('username_x', 'username_y',...'username_z')
)

SELECT 
      su.*,
      COALESCE(ds.dep_card_count, 0) AS dep_card_count,
      COALESCE(ds.deposit_count, 0) AS deposit_count,
      COALESCE(ds.total_deposit, 0) AS total_deposit,
      COALESCE(wds.wdl_card_count, 0) AS wdl_card_count,
      COALESCE(wds.withdrawal_count, 0) AS withdrawal_count,
      COALESCE(wds.total_withdrawal, 0) AS total_withdrawal
FROM   suspect_users su
LEFT JOIN deposit_summary ds
ON su.username = ds.username
LEFT JOIN withdrawal_summary wds
ON su.username = wds.username
;

-- Example Output:
| username    | account_created_at | first_activity   | account_status | dep_card_count | deposit_count | total_deposit | wdl_card_count | withdrawal_count | total_withdrawal |
|-------------|--------------------|------------------|----------------|----------------|---------------|---------------|----------------|------------------|------------------|
| username_aa | 16/07/XXXX 00:25   | 16/07/XXXX 00:26 | active         | 3              | 11            | 175           | 1              | 1                | 155              |
| username_yy | 16/07/XXXX 01:47   | 16/07/XXXX 00:50 | active         | 1              | 7             | 85            | 0              | 0                | 0                |
