-- 1.3 Két terméktípus legnagyobb darabszám-csökkenéssel (javított verzió)
WITH ChurnedSubscriptions AS (
    SELECT
        s1.ProductName,
        COUNT(DISTINCT s1.CustomerNumber) AS ChurnedCustomers
    FROM
        Subscriptions s1
    LEFT JOIN
        Subscriptions s2 ON s1.CustomerNumber = s2.CustomerNumber
                           AND s1.ProductName = s2.ProductName
                           AND s1.Term = s2.Term
                           AND s1.ServiceEndDate < s2.ServiceStartDate
                           AND s2.ServiceStartDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    WHERE
        s1.ServiceEndDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
        AND s2.ServiceStartDate IS NULL
    GROUP BY
        s1.ProductName
),
RankedChurnedSubscriptions AS (
    SELECT
        ProductName,
        ChurnedCustomers,
        @row_number := @row_number + 1 AS rn
    FROM
        ChurnedSubscriptions, (SELECT @row_number := 0) AS r
    ORDER BY
        ChurnedCustomers DESC
)
SELECT
    ProductName,
    ChurnedCustomers
FROM
    RankedChurnedSubscriptions
WHERE
    rn <= 2;