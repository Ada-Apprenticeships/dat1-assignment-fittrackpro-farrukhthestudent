.open fittrackpro.db
.mode column

-- 6.1 
INSERT INTO
    attendance (member_id, location_id, check_in_time)
VALUES
    (7, 1, '2025-02-14 16:30:00');

-- 6.2 
SELECT
    date(check_in_time) AS visit_date,
    check_in_time,
    check_out_time
FROM
    attendance
WHERE
    member_id = 5
ORDER BY
    check_in_time;

-- 6.3 
SELECT
    CASE strftime('%w', check_in_time)
        WHEN '0' THEN 'Sunday'
        WHEN '1' THEN 'Monday'
        WHEN '2' THEN 'Tuesday'
        WHEN '3' THEN 'Wednesday'
        WHEN '4' THEN 'Thursday'
        WHEN '5' THEN 'Friday'
        WHEN '6' THEN 'Saturday'
    END AS day_of_week,
    COUNT(*) AS visit_count
FROM
    attendance
GROUP BY
    strftime('%w', check_in_time)
ORDER BY
    visit_count DESC
LIMIT
    1;

-- 6.4 
-- Calculate average daily attendance per location (including no-show days),
-- using each location's own first and last attendance day range.
WITH
    location_bounds AS (
        SELECT
            location_id,
            MIN(date(check_in_time)) AS min_day,
            MAX(date(check_in_time)) AS max_day
        FROM
            attendance
        GROUP BY
            location_id
    ),
    -- Generates every date between min_day and max_day for each location
    attendance_dates (location_id, visit_date, max_day) AS (
        SELECT
            location_id,
            min_day,
            max_day
        FROM
            location_bounds
        UNION ALL
        SELECT
            location_id,
            date(visit_date, '+1 day'),
            max_day
        FROM
            attendance_dates
        WHERE
            visit_date < max_day
    ),
    -- Calculates real visit counts per location per day
    daily_counts AS (
        SELECT
            location_id,
            date(check_in_time) AS visit_date,
            COUNT(*) AS visit_count
        FROM
            attendance
        GROUP BY
            location_id,
            date(check_in_time)
    ),
    -- For each generated (location, visit_date) use the real count (or 0) and average per location
    avg_per_location AS (
        SELECT
            attendance_dates.location_id,
            AVG(COALESCE(daily_counts.visit_count, 0)) AS avg_daily_attendance
        FROM
            attendance_dates
            LEFT JOIN daily_counts 
                ON daily_counts.location_id = attendance_dates.location_id
                AND daily_counts.visit_date = attendance_dates.visit_date
        GROUP BY
            attendance_dates.location_id
    )
    -- Ensure every location appears, locations with no attendance show 0.0
SELECT
    locations.name AS location_name,
    ROUND(
        COALESCE(avg_per_location.avg_daily_attendance, 0),
        2
    ) AS avg_daily_attendance
FROM
    locations
    LEFT JOIN avg_per_location ON avg_per_location.location_id = locations.location_id;
