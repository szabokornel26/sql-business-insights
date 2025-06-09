# sql-business-insights
Analysis of customer, subscription, campaign and notifications data using SQL queries.
SQL Marketing Analytics
This project contains a set of SQL queries designed to extract valuable business insights from subscription, customer, campaign, and notification activity data. These queries help identify top-performing products, most valuable customers, product trends, and notification effectiveness.

Table of Contents
Project Overview
Database Schema
Queries
Top 3 Product Types by Monthly Revenue
Top 10 Active Customers by Revenue
Top 2 Product Types by Largest Quantity Decrease (Based on Churn)
Notification Activities Grouped by Open Rate
Usage
Project Overview
The goal of this project is to provide actionable insights for marketing and sales teams by analyzing key business metrics through SQL queries. The queries leverage data from four core tables: Subscriptions, Customers, Campaigns, and NotificationActivities.

Database Schema
For these queries to function correctly, the following table structures and relationships are assumed. Please adjust the queries if your actual schema differs.

Subscriptions:
SubscriptionID (PK)
CustomerNumber (FK to Customers)
ProductName (e.g., 'Premium', 'Standard', 'Basic')
UnitPrice
Licenses
ServiceStartDate
ServiceEndDate
Term

Customers:
CustomerNumber (PK)
Name
Status (Active or Cancelled)
CountryCode

Campaigns:
CampaignID (PK)
Name
Type

NotificationActivities:
RowKey (contains notification_id, e.g., 'ACTIVITY_C0001_1_2zyexrtb8fz6lenkmtms')
Action (e.g., 'OpenModal', 'Click', 'Dismiss')
LogTime


Queries
Below are the SQL queries included in this project, with descriptions of what they achieve.

Top 3 Product Types by Monthly Revenue

This query identifies the top 3 product types generating the most revenue on a monthly basis over the last two years. This helps in understanding which offerings are most profitable over time.

SQL
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
Top 10 Active Customers by Revenue

This query lists the top 10 most valuable active customers based on the total revenue they've generated. An "active" customer in this context is one whose subscription is currently valid. This is crucial for identifying and nurturing high-value customers.

SQL
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
Top 2 Product Types by Largest Quantity Decrease (Based on Churn)

This refined query identifies the two product types that have experienced the largest number of subscription churns over the past 6 months. In this context, "subscription churn" refers to customers whose subscriptions for a specific product type have ended and were not renewed or replaced with a new subscription for the same product type within the observed period. This analysis is key to understanding product lifecycle and refining retention strategies.

SQL
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
Notification Activities Grouped by Open Rate

This query calculates the open rate for each notification, grouping them by notification_id. It extracts the notification ID from the RowKey field, then counts how many OpenModal events occurred relative to the total number of events for that specific notification. This analysis helps assess the effectiveness of individual notification campaigns or specific notifications.

SQL
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
