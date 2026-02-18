.open fittrackpro.db
.mode column

-- 2.1 
/* Did not specify payment_date because schema has a default which selects current datetime
when none is provided */
INSERT INTO payments (
    member_id,
    amount,
    payment_method,
    payment_type
) VALUES
    (11,  50.00,  'Credit Card'   ,'Monthly membership fee'); 

-- 2.2 
WITH months(month) AS (
    VALUES
        ('2024-11'),
        ('2024-12'),
        ('2025-01'),
        ('2025-02')
),
monthly_revenue AS (
    SELECT
        strftime('%Y-%m', payment_date) AS month,
        SUM(amount) AS total_revenue
    FROM payments
    WHERE payment_type = 'Monthly membership fee'
      AND payment_date >= '2024-11-01'
      AND payment_date <  '2025-03-01'
    GROUP BY strftime('%Y-%m', payment_date)
)
SELECT
    months.month,
    COALESCE(monthly_revenue.total_revenue, 0) AS total_revenue
FROM months
LEFT JOIN monthly_revenue
    ON months.month = monthly_revenue.month
ORDER BY months.month;

-- 2.3 
SELECT
    payment_id,
    amount,
    payment_date,
    payment_method
FROM payments
WHERE payment_type = 'Day pass';


