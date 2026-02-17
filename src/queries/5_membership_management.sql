.open fittrackpro.db
.mode column

-- 5.1 
SELECT
    members.member_id,
    members.first_name,
    members.last_name,
    memberships.type AS membership_type,
    memberships.start_date AS join_date
FROM
    memberships
    JOIN members ON members.member_id = memberships.member_id
WHERE
    status = 'Active'
    -- 5.2 
SELECT
    memberships.type AS membership_type,
    ROUND(
        AVG(
            (
                julianday(attendance.check_out_time) - julianday(attendance.check_in_time)
            ) * 24 * 60
        ),
        1
    ) AS avg_visit_duration_minutes
FROM
    attendance
    JOIN memberships ON memberships.member_id = attendance.member_id
WHERE
    attendance.check_out_time IS NOT NULL
GROUP BY
    memberships.type;

-- 5.3 
SELECT
    members.member_id,
    members.first_name,
    members.last_name,
    members.email,
    memberships.end_date
FROM
    memberships
    JOIN members ON members.member_id = memberships.member_id
WHERE
    memberships.end_date >= '2025-01-01'
    AND memberships.end_date < '2026-01-01'