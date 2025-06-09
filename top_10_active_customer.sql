-- 1.2 Top 10 aktív ügyfél bevétel szerint
SELECT
    c.Name,
    SUM(s.UnitPrice * s.Licenses) AS CurrentRevenue
FROM
    Customers c
JOIN
    Subscriptions s ON c.CustomerNumber = s.CustomerNumber
WHERE
    s.ServiceStartDate <= CURDATE() AND s.ServiceEndDate >= CURDATE()
GROUP BY
    c.Name
ORDER BY
    CurrentRevenue DESC
LIMIT 10;