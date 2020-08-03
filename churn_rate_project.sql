--Getting familiar with the data:
SELECT * from subscriptions LIMIT 100;

--Getting the raw numbers of users retained,
--canceled, and new to the service during each
--month. The number of new users was included
--to perform sanity checks. 
--Note that my solution differs from the 
--accepted Codecademy one in that what
--I am calling retained + canceled is their
--'active.' Codecademy is using 'active' to mean
--'active at the start of the month.' I prefer to
--search for the number of users who kept their 
--subscriptions and the number who canceled them,
--as that makes the total number of subscribers
--at the start of the month.
WITH months AS(
  SELECT '2017-01-01' AS first_day, '2017-01-31' AS last_day
  UNION
  SELECT '2017-02-01' AS first_day, '2017-02-28' AS last_day
  UNION
  SELECT '2017-03-01' AS first_day, '2017-03-31' AS last_day),
cross_join AS (SELECT * FROM subscriptions CROSS JOIN months),
status AS (SELECT id, first_day AS month, 
CASE WHEN (subscription_start < first_day AND 
(subscription_end > last_day OR subscription_end IS NULL)) THEN 1 ELSE 0 
END AS 'is_retain',
CASE WHEN (segment = 87 AND subscription_start < first_day AND 
(subscription_end > last_day OR subscription_end IS NULL)) THEN 1 ELSE 0 
END AS 'is_retain_87',
CASE WHEN (segment = 30 AND subscription_start < first_day AND 
(subscription_end > last_day OR subscription_end IS NULL)) THEN 1 ELSE 0 
END AS 'is_retain_30',
CASE WHEN (subscription_start BETWEEN first_day and last_day) THEN 1 ELSE 0 
END AS 'is_new',
CASE WHEN (segment = 87 AND subscription_start BETWEEN first_day and last_day) 
THEN 1 ELSE 0 END AS 'is_new_87',
CASE WHEN (segment = 30 AND subscription_start BETWEEN first_day and last_day) 
THEN 1 ELSE 0 END AS 'is_new_30',
CASE WHEN (subscription_start < first_day AND 
subscription_end BETWEEN first_day and last_day) THEN 1 ELSE 0 END AS 'is_canceled',
CASE WHEN (segment = 87 AND subscription_start < first_day AND 
subscription_end BETWEEN first_day and last_day) THEN 1 ELSE 0 END AS 'is_canceled_87',
CASE WHEN (segment = 30 AND subscription_start < first_day AND 
subscription_end BETWEEN first_day and last_day) THEN 1 ELSE 0 END AS 'is_canceled_30'
FROM cross_join),
status_aggregate AS (SELECT month, SUM(is_retain) AS 'all_retained', 
SUM(is_canceled) AS 'all_canceled',SUM(is_new) AS 'all_new', 
SUM(is_retain_87) AS 'retained_87', SUM(is_canceled_87) AS 'canceled_87', 
SUM(is_new_87) AS 'new_87', SUM(is_retain_30) AS 'retained_30', 
SUM(is_canceled_30) AS 'canceled_30', SUM(is_new_30) AS 'new_30'
FROM status GROUP BY month)
SELECT * from status_aggregate GROUP BY month;

--Using SQLite to calculate the churn rate for the "87" members
--and the "30" members. Note that this COULD be done USING
--Microsoft Excel given the above search, but the spirit of
--the project was to code the calculation into SQL.
WITH months AS(
  SELECT '2017-01-01' AS first_day, '2017-01-31' AS last_day
  UNION
  SELECT '2017-02-01' AS first_day, '2017-02-28' AS last_day
  UNION
  SELECT '2017-03-01' AS first_day, '2017-03-31' AS last_day),
cross_join AS (SELECT * FROM subscriptions CROSS JOIN months),
status AS (SELECT id, first_day AS month, 
CASE WHEN (subscription_start < first_day AND 
(subscription_end > last_day OR subscription_end IS NULL)) THEN 1 ELSE 0 
END AS 'is_retain',
CASE WHEN (segment = 87 AND subscription_start < first_day AND 
(subscription_end > last_day OR subscription_end IS NULL)) THEN 1 ELSE 0 
END AS 'is_retain_87',
CASE WHEN (segment = 30 AND subscription_start < first_day AND 
(subscription_end > last_day OR subscription_end IS NULL)) THEN 1 ELSE 0 
END AS 'is_retain_30',
CASE WHEN (subscription_start BETWEEN first_day and last_day) THEN 1 ELSE 0 
END AS 'is_new',
CASE WHEN (segment = 87 AND subscription_start BETWEEN first_day and last_day) 
THEN 1 ELSE 0 END AS 'is_new_87',
CASE WHEN (segment = 30 AND subscription_start BETWEEN first_day and last_day) 
THEN 1 ELSE 0 END AS 'is_new_30',
CASE WHEN (subscription_start < first_day AND 
subscription_end BETWEEN first_day and last_day) THEN 1 ELSE 0 END AS 'is_canceled',
CASE WHEN (segment = 87 AND subscription_start < first_day AND 
subscription_end BETWEEN first_day and last_day) THEN 1 ELSE 0 END AS 'is_canceled_87',
CASE WHEN (segment = 30 AND subscription_start < first_day AND 
subscription_end BETWEEN first_day and last_day) THEN 1 ELSE 0 END AS 'is_canceled_30'
FROM cross_join),
status_aggregate AS (SELECT month, SUM(is_retain) AS 'all_retained', 
SUM(is_canceled) AS 'all_canceled',SUM(is_new) AS 'all_new', 
SUM(is_retain_87) AS 'retained_87', SUM(is_canceled_87) AS 'canceled_87', 
SUM(is_new_87) AS 'new_87', SUM(is_retain_30) AS 'retained_30', 
SUM(is_canceled_30) AS 'canceled_30', SUM(is_new_30) AS 'new_30'
FROM status GROUP BY month)
SELECT month, ROUND(1.0*canceled_87/(retained_87+canceled_87),2) AS 'churn_rate_87',
 ROUND(1.0*canceled_30/(retained_30+canceled_30),2) AS 'churn_rate_30' 
 FROM status_aggregate GROUP BY month;