-- 1.1 Top 3 havi bevételt hozó terméktípusok
SELECT
    ProductName,
    SUM(UnitPrice * Licenses) AS TotalRevenue,
    DATE_FORMAT(ServiceStartDate, '%Y-%m') AS BillingMonth
FROM
    Subscriptions
WHERE
    ServiceStartDate >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
GROUP BY
    ProductName,
    BillingMonth
ORDER BY
    BillingMonth,
    TotalRevenue DESC
LIMIT 3;
