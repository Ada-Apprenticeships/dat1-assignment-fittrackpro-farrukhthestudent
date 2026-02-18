.open fittrackpro.db
.mode column

-- 8.1 
SELECT
    personal_training_sessions.session_id,
    members.first_name || ' ' || members.last_name AS member_name,
    personal_training_sessions.session_date,
    personal_training_sessions.start_time,
    personal_training_sessions.end_time
FROM
    personal_training_sessions
    JOIN members
        ON personal_training_sessions.member_id = members.member_id
    JOIN staff
        ON personal_training_sessions.staff_id = staff.staff_id
WHERE
    staff.first_name || ' ' || staff.last_name = 'Ivy Irwin';
