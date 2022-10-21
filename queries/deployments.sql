WITH deploys_github AS (
  SELECT
    source,
    id AS deploy_id,
    time_created,
    JSON_VALUE(metadata, '$.check_run.head_sha') AS main_commit
  FROM
    four_keys.events_raw
  WHERE source = 'github'
  AND event_type = 'check_run'
  AND JSON_VALUE(metadata, '$.check_run.status') = 'completed'
  AND JSON_VALUE(metadata, '$.check_run.name') LIKE 'deploy-mikan-prd%'
), changes_raw AS (
  SELECT id, metadata AS change_metadata FROM four_keys.events_raw
), deployment_changes AS (
  SELECT
    source,
    deploy_id,
    deploys_github.time_created time_created,
    change_metadata,
    four_keys.json2array(JSON_QUERY(change_metadata, '$.commits')) AS array_commits,
    main_commit
  FROM deploys_github
  JOIN changes_raw ON changes_raw.id = deploys_github.main_commit
)
SELECT
  source,
  deploy_id,
  time_created,
  main_commit,
  ARRAY_AGG(DISTINCT JSON_VALUE(array_commits, '$.id')) changes,
FROM deployment_changes
CROSS JOIN deployment_changes.array_commits
GROUP BY 1, 2, 3, 4;