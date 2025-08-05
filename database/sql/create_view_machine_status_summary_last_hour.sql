CREATE OR REPLACE VIEW `MachineStatusSummaryLastHour`
SQL SECURITY INVOKER AS
SELECT
  r.RunBy,
  COUNTIF(r.Status = 'COMPLETED') AS CompletedCount,
  COUNTIF(r.Status = 'FAILED') AS FailedCount,
  COUNTIF(r.Status = 'RUNNING') AS RunningCount,
  COUNT(*) AS Total,
  ROUND(COUNTIF(r.Status = 'COMPLETED') * 100.0 / COUNT(*), 2) AS CompletedPercent,
  ROUND(COUNTIF(r.Status = 'FAILED') * 100.0 / COUNT(*), 2) AS FailedPercent,
  ROUND(COUNTIF(r.Status = 'RUNNING') * 100.0 / COUNT(*), 2) AS RunningPercent
FROM
  RunRecord r
WHERE
  r.LastUpdate >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
  AND r.Status IN ('COMPLETED', 'FAILED', 'RUNNING')
GROUP BY
  r.RunBy
ORDER BY
  r.RunBy;
