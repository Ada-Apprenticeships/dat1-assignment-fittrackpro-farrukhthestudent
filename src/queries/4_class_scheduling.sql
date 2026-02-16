.open fittrackpro.db
.mode column

-- 4.1 
SELECT
    c.class_id,
    c.name AS class_name,
    s.first_name || ' ' || s.last_name AS instructor_name
FROM
    classes c
    JOIN class_schedule cs ON cs.class_id = c.class_id
    JOIN staff s ON cs.staff_id = s.staff_id;

-- 4.2 
SELECT
    cs.class_id,
    c.name,
    cs.start_time,
    cs.end_time,
    c.capacity - COUNT(ca.class_attendance_id) as available_spots
FROM
    class_schedule cs
    JOIN classes c ON c.class_id = cs.class_id
    JOIN staff s ON cs.staff_id = s.staff_id
    LEFT JOIN class_attendance ca ON ca.schedule_id = cs.schedule_id
    AND ca.attendance_status = 'Registered'
WHERE
    date(cs.start_time) = '2025-02-01'
GROUP BY
    cs.class_id,
    c.name,
    cs.start_time,
    cs.end_time,
    c.capacity;

-- 4.3 
INSERT INTO
    class_attendance (schedule_id, member_id, attendance_status)
VALUES
    (
        (
            SELECT
                schedule_id
            FROM
                class_schedule
            WHERE
                class_id = 1
                AND date(start_time) = '2025-02-01'
            ORDER BY
                start_time
            LIMIT
                1
        ),
        11,
        'Registered'
    );

-- 4.4 
UPDATE class_attendance
SET
    attendance_status = 'Unattended'
WHERE
    member_id = 3
    AND schedule_id = 7
    AND attendance_status = 'Registered';

-- 4.5 
SELECT
    classes.class_id,
    classes.name AS class_name,
    COUNT(*) AS registration_count
FROM
    class_attendance
    JOIN class_schedule ON class_attendance.schedule_id = class_schedule.schedule_id
    JOIN classes ON class_schedule.class_id = classes.class_id
WHERE
    class_attendance.attendance_status = 'Registered'
GROUP BY
    classes.class_id,
    classes.name
ORDER BY
    registration_count DESC
LIMIT
    1;

-- 4.6 
SELECT
    ROUND(AVG(class_count), 1) AS avg_classes_per_member
FROM
    (
        SELECT
            member_id,
            COUNT(*) AS class_count
        FROM
            class_attendance
        WHERE
            attendance_status IN ('Registered', 'Attended')
        GROUP BY
            member_id
    ) per_member;
