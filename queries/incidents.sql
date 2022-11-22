# Incidents Table
SELECT
  source,
  incident_id,
  MIN(IF(root.time_created < issue.time_created, root.time_created, issue.time_created)) as time_created,
  MAX(time_resolved) as time_resolved,
  ARRAY_AGG(root_cause IGNORE NULLS) changes,
FROM (
  SELECT 
    source,
    JSON_EXTRACT_SCALAR(metadata, '$.issue.number') AS incident_id,
    TIMESTAMP(JSON_EXTRACT_SCALAR(metadata, '$.issue.created_at')) AS time_created,
    TIMESTAMP(JSON_EXTRACT_SCALAR(metadata, '$.issue.closed_at')) AS time_resolved,
    REGEXP_EXTRACT(metadata, r"root cause: ([[:alnum:]]*)") as root_cause,
    REGEXP_CONTAINS(JSON_EXTRACT(metadata, '$.issue.labels'), '"name":"incident"') AS bug,
  FROM four_keys.events_raw 
  WHERE event_type LIKE "issue%"
) issue
LEFT JOIN (
  SELECT time_created, changes FROM four_keys.deployments d, d.changes
) root
ON root.changes = root_cause
GROUP BY 1,2
HAVING max(bug) is True
;
