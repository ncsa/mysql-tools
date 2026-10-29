SELECT
  user,
  SUBSTRING_INDEX(host, ':', 1) AS host,
  db,
  COUNT(*) AS connections
FROM information_schema.processlist
WHERE user NOT IN ('event_scheduler', 'system user')
GROUP BY user, SUBSTRING_INDEX(host, ':', 1), db
ORDER BY user, host, db;
