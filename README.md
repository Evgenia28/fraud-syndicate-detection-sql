## Overview
A synthetic SQL case study modelling fraudulent user behaviour across 
transaction and login data. The project demonstrates how structured 
query logic can be used to detect coordinated account activity, 
deposit-based fraud patterns, and early fund extraction attempts.

All data is fabricated. Schemas, thresholds, and behavioural patterns 
are illustrative and not derived from any real operational environment.

## Schema
Four synthetic tables modelling a regulated digital platform:

- `users` — account registration and status data
- `logins` — session and device fingerprint data  
- `deposits` — transaction-level deposit records
- `withdrawals` — withdrawal events and payment instrument data

### Part 1 — Exploratory Analysis
| File                           | Description                                                                                                     |
|--------------------------------|-----------------------------------------------------------------------------------------------------------------|
| `01_monitoring_query.sql`      | IP clustering and account creation velocity — identifies suspicious concentrations of newly registered accounts |
| `02_drill_down_query.sql`      | User cluster profile — aggregated behavioural summary for flagged accounts                                      |
| `03_behaviour_audit_query.sql` | Transaction-level deposit audit — velocity, card usage, and running balance per user                            |

### Part 2 — Detection Rules
| File                                   | Description                                                                                              |
|----------------------------------------|----------------------------------------------------------------------------------------------------------|
| `04_ladder_deposit_rule.sql`           | Detects systematic deposit escalation in fixed increments with controlled timing                         |
| `05_withdrawal_rule.sql`               | Detects early fund extraction to a new payment instrument on recently created accounts |

## Fraud Behaviours Covered
- Multi-accounting and Sybil attack patterns
- Card stuffing and limit testing
- Deposit laddering
- Hit-and-run fund extraction
- New instrument diversion

## SQL Concepts Demonstrated
- Common Table Expressions (CTEs)
- Window functions: `LAG`, `COUNT OVER`, `SUM OVER`, `ARRAY_AGG`
- `QUALIFY` for post-window filtering
- `SAFE_DIVIDE` and `COALESCE` for null handling
- `DATETIME_DIFF` and `TIMESTAMP_SUB` for time-based analysis
- Multi-table joins and aggregation
