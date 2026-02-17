.open fittrackpro.db
.mode column

-- 1.1
SELECT member_id, first_name, last_name, email, join_date
FROM members;

-- 1.2
UPDATE members
SET
    phone_number = '07000 100005',
    email = 'emily.jones.updated@email.com'
WHERE member_id = 5;

-- 1.3
SELECT COUNT(*)
FROM members;


-- 1.4
SELECT 
    members.member_id, 
    members.first_name, 
    members.last_name,
    COUNT(*) as registration_count
FROM class_attendance
JOIN members
    on members.member_id = class_attendance.member_id
WHERE class_attendance.attendance_status IN ('Registered', 'Attended')
GROUP BY members.member_id, members.first_name, members.last_name
ORDER BY registration_count DESC
LIMIT 1;

-- 1.5
SELECT 
    members.member_id, 
    members.first_name, 
    members.last_name,
    COUNT(class_attendance.class_attendance_id) as registration_count
FROM members
LEFT JOIN class_attendance
    ON members.member_id = class_attendance.member_id
    AND class_attendance.attendance_status IN ('Registered', 'Attended')
GROUP BY members.member_id, members.first_name, members.last_name
ORDER BY registration_count ASC
LIMIT 1;

-- 1.6
SELECT COUNT(*)
FROM (
    SELECT class_attendance.member_id
    FROM class_attendance
    WHERE class_attendance.attendance_status = 'Attended'
    GROUP BY class_attendance.member_id
    HAVING COUNT(*) >= 2
) qualifying_members;

