.open fittrackpro.db
.mode column
PRAGMA foreign_keys = ON;
-- CONSIDER THE ON UPDATE CASCADE
-- CONSIDER DEFAULT VALUES and UNIQUE

CREATE TABLE locations (
    location_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    phone_number VARCHAR(16) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE
        CHECK (email LIKE '_%@fittrackpro.com'),
    opening_hours VARCHAR(11) NOT NULL
        CHECK (opening_hours LIKE '__:__-__:__')
);

CREATE TABLE members (
    member_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE
        CHECK (email LIKE '%_@_%._%'),
    phone_number VARCHAR(20) NOT NULL UNIQUE, -- Allows spaces/country code
    date_of_birth DATE NOT NULL
        CHECK (date(date_of_birth) = date_of_birth),
    join_date DATE NOT NULL
        CHECK (date(join_date) = join_date),
    emergency_contact_name VARCHAR(100) NOT NULL,
    emergency_contact_phone VARCHAR(20) NOT NULL
);

CREATE TABLE staff (
    staff_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE
        CHECK (email LIKE '_%@fittrackpro.com'),
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    position VARCHAR(20) NOT NULL
        CHECK (position IN('Trainer', 'Manager', 'Receptionist', 'Maintenance')),
    hire_date DATE NOT NULL
        CHECK (date(hire_date) = hire_date),
    location_id INTEGER NOT NULL,
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE equipment (
    equipment_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(10) NOT NULL
        CHECK (type IN('Cardio', 'Strength')),
    purchase_date DATE NOT NULL
        CHECK (date(purchase_date) = purchase_date),
    last_maintenance_date DATE NOT NULL
        CHECK (date(last_maintenance_date) = last_maintenance_date),
    next_maintenance_date DATE NOT NULL
        CHECK (date(next_maintenance_date) = next_maintenance_date),
    location_id INTEGER NOT NULL,
    CHECK (next_maintenance_date >= last_maintenance_date),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE classes (
    class_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL, -- Set to TEXT as descriptions can be long.
    capacity INTEGER NOT NULL
        CHECK (capacity > 0),
    duration INTEGER NOT NULL
        CHECK (duration > 0),
    location_id INTEGER NOT NULL,
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE class_schedule (
    schedule_id INTEGER PRIMARY KEY,
    class_id INTEGER NOT NULL,
    staff_id INTEGER NOT NULL,
    start_time DATETIME NOT NULL
        CHECK (datetime(start_time) = start_time),
    end_time DATETIME NOT NULL
        CHECK (datetime(end_time) = end_time),
    CHECK (julianday(end_time) > julianday(start_time)),
    FOREIGN KEY (class_id) REFERENCES classes(class_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE memberships (
    membership_id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    type VARCHAR(10) NOT NULL
        CHECK (type IN('Premium', 'Standard')),
    start_date DATE NOT NULL
        CHECK (date(start_date) = start_date),
    end_date DATE NOT NULL
        CHECK (date(end_date) = end_date),
    status VARCHAR(8) NOT NULL
        DEFAULT 'Active'
        CHECK(status IN('Active', 'Inactive')),
    CHECK (end_date >= start_date),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE attendance (
    attendance_id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    check_in_time DATETIME NOT NULL
        DEFAULT(datetime('now'))
        CHECK (datetime(check_in_time) = check_in_time),
    check_out_time DATETIME
        CHECK (
                check_out_time IS NULL
                OR datetime(check_out_time) = check_out_time
            ),
    CHECK (
            check_out_time IS NULL
            OR julianday(check_out_time) > julianday(check_in_time)
            ),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE class_attendance (
    class_attendance_id INTEGER PRIMARY KEY,
    schedule_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    attendance_status VARCHAR(15) NOT NULL
        CHECK (attendance_status IN('Registered', 'Attended', 'Unattended')),
    UNIQUE (schedule_id, member_id),
    FOREIGN KEY (schedule_id) REFERENCES class_schedule(schedule_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    amount DECIMAL(5,2) NOT NULL
        CHECK (amount >= 0),
    payment_date DATETIME NOT NULL
        DEFAULT (datetime('now'))
        CHECK (datetime(payment_date) = payment_date),
    payment_method VARCHAR(20) NOT NULL
        CHECK (payment_method IN('Credit Card', 'Bank Transfer', 'PayPal')),
    payment_type VARCHAR(30) NOT NULL
        CHECK (payment_type IN('Monthly membership fee', 'Day pass')),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE personal_training_sessions (
    session_id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    staff_id INTEGER NOT NULL,
    session_date DATE NOT NULL
        CHECK (date(session_date) = session_date),
    start_time TEXT NOT NULL -- set to TEXT instead of TIME so that it doesn't perform Type coercion
        CHECK (time(start_time) = start_time),
    end_time TEXT NOT NULL
        CHECK (time(end_time) = end_time),
    notes VARCHAR(200),
    CHECK (time(end_time) > time(start_time)),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE member_health_metrics (
    metric_id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    measurement_date DATE NOT NULL
        CHECK (date(measurement_date) = measurement_date),
    weight DECIMAL(4,1) NOT NULL
        CHECK (ROUND(weight, 1) = weight),
    body_fat_percentage DECIMAL(3, 1) NOT NULL
        CHECK(ROUND(body_fat_percentage, 1) = body_fat_percentage),
    muscle_mass DECIMAL(4, 1) NOT NULL
        CHECK(ROUND(muscle_mass, 1) = muscle_mass),
    bmi DECIMAL (3, 1) NOT NULL
        CHECK(ROUND(bmi, 1) = bmi),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE equipment_maintenance_log (
    log_id INTEGER PRIMARY KEY,
    equipment_id INTEGER NOT NULL,
    maintenance_date DATE NOT NULL
        CHECK (date(maintenance_date) = maintenance_date),
    description TEXT, -- Description can be long on certain occasions
    staff_id INTEGER NOT NULL,
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);