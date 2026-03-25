
-- Behaviour Audit Query (deposit-based, per user)
-- Fraud typology: card stuffing/testing, CNP, card hopping, ladder deposits, deposit velocity
-- Goal: obtain user-level fraud profile for clustered accounts

SELECT username,
       deposit_id,
       card_number_masked,
       deposit_datetime,
       DATETIME_DIFF(deposit_datetime, LAG(deposit_datetime) OVER(PARTITION BY username ORDER BY  deposit_datetime, deposit_id), MINUTE) AS time_diff,
       payment_provider,     
       card_verification, -- 'Yes'/'No' (for example, 2FA, AVS, etc),
       COUNT(transaction_id) OVER(PARTITION BY username ORDER BY deposit_datetime, transaction_id) AS txn_count,
       amount,
       SUM(CASE WHEN deposit_status = 'approved' THEN amount ELSE 0 END) 
       OVER(PARTITION BY username ORDER BY deposit_datetime, transaction_id) AS rolling_amount
       deposit_status -- 'approved'/'failed'       
FROM deposits
WHERE username IN ('username_x', 'username_y',...'username_z')

-- Example Output:
| username    | deposit_id | card_masked_number | deposit_datetime   | time_diff | payment_provider | card_verification | txn_count | amount | deposit_status | rolling_amount |
|-------------|------------|--------------------|--------------------|-----------|------------------|-------------------|-----------|--------|----------------|----------------|
| username_yy | 33434      | 123456….1234       | 14/03/2026   00:03 | NULL      | Your Bank        | No                | 1         | 5      | approved       | 0              |
| username_yy | 33439      | 123456….1235       | 14/03/2026   00:04 | 1         | Your Bank        | No                | 2         | 15     | approved       | 20             |
| username_yy | 33440      | 123456….1234       | 14/03/2026   00:06 | 2         | Your Bank        | No                | 3         | 25     | approved       | 45             |
| username_yy | 33445      | 123456….1234       | 14/03/2026   00:06 | 0         | Your Bank        | No                | 4         | 25     | failed         | 45             |
| username_yy | 33446      | 123456….1235       | 15/03/2026   00:06 | 1         | Your Bank        | No                | 4         | 25     | failed         | 45             |
| username_yy | 33447      | 987654….0000       | 14/03/2026   00:10 | 4         |  My Bank         | No                | 5         | 5      | approved       | 50             |
