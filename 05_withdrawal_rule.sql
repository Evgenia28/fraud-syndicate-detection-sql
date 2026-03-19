
-- Mitigation Rule/Query (based on withdrawal pattern)
-- Goal: to detect early fast funds liquidation on new accounts with high deposit velocity. It's designed as a secondary control to detect users who evade initial deposit-based screening. 
-- The rule prioritises instrument mismatch and near-complete extraction.
-- Assumption/Limitation:  current design assumes near full liquidation on the first withdrawal.
-- Note: in a production environment, flagged accounts would be cross-referenced for shared infrastructure signals

WITH user_deposit AS (
          SELECT
                u.username,
                u.account_created_at,
                COUNT(DISTINCT deposit_id) AS deposit_count,
                SUM(amount) AS total_deposit_amount,
                ARRAY_AGG(DISTINCT card_number_masked) AS dep_cards
         FROM users u
         JOIN deposits d
         ON u.username = d.username
         WHERE account_created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 3 DAY)
         GROUP BY u.username, u.account_created_at
),

txn_summary AS (
         SELECT  
                ud.username,
                ud.account_created_at,
                w.withdrawal_id,
                w.withdrawal_datetime,
                w.card_number_masked AS wld_card,
                w.payment_provider AS wdl_bank,
                ud.total_deposit_count,
                ud.total_deposit_amount,
                w.withdrawal_amount,
                SAFE_DIVIDE(w.withdrawal_amount, ud.total_deposit_amount) AS dep_wd_ratio,
                COUNT(w.withdrawal_id) OVER(PARTITION BY w.username) AS wdl_count
          FROM user_deposit ud
          JOIN   withdrawals w ON ud.username = w.username
          WHERE deposit_count >= 4
)

SELECT  *           
FROM txn_summary 
WHERE wdl_card NOT IN UNNEST(dep_cards)
AND wdl_count = 1
AND dep_wd_ratio BETWEEN 0.7 AND 1.1

-- Example Output:
| username    | account_created_at | withdrawal_id | withdrawal_datetime  | wd_card        | wdl_bank   | total_deposit_count | total_deposit_amount | withdrawal_amount | dep_wd_ratio | wdl_count |
|-------------|--------------------|---------------|----------------------|----------------|------------|---------------------|----------------------|-------------------|--------------|-----------|
| username_xx | 16/07/XXXX 00:01   | 234567        | 16/07/XXXX 01:07     | 987654…...0000 | Their Bank | 13                  | 145                  | 135               | 0.93         | 1         |
