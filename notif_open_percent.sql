SELECT 
    notification_id,
    COUNT(*) AS total_events,
    SUM(CASE WHEN action = 'OpenModal' THEN 1 ELSE 0 END) AS open_count,
    ROUND(SUM(CASE WHEN action = 'OpenModal' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS open_rate_percent
FROM (
    SELECT 
        action,
        SUBSTRING_INDEX(RowKey, '_', -1) AS notification_id
    FROM NotificationActivities na
) AS parsed_data
GROUP BY notification_id
ORDER BY open_rate_percent DESC;
