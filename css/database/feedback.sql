-- ============================================================
-- Advanced Student Feedback Database
-- Compatible with MariaDB 10.1+
-- ============================================================

SET SQL_MODE = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,
                ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,
                NO_ENGINE_SUBSTITUTION';

SET time_zone = '+00:00';

CREATE DATABASE IF NOT EXISTS feedback_system
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE feedback_system;


-- ============================================================
-- USERS
-- ============================================================

DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,

    email VARCHAR(191) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,

    role ENUM('admin', 'staff') NOT NULL DEFAULT 'staff',

    is_active TINYINT(1) NOT NULL DEFAULT 1,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    last_login_at TIMESTAMP NULL DEFAULT NULL,

    PRIMARY KEY (id),
    UNIQUE KEY uq_users_email (email),
    KEY idx_users_role (role),
    KEY idx_users_active (is_active)

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- FEEDBACK
-- ============================================================

DROP TABLE IF EXISTS feedback;

CREATE TABLE feedback (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    academic_year YEAR NOT NULL,
    semester TINYINT UNSIGNED NOT NULL,

    feedback_date DATE NOT NULL,

    branch VARCHAR(100) NOT NULL,
    section VARCHAR(50) NOT NULL,
    subject VARCHAR(150) NOT NULL,

    -- Questions
    ques1 TINYINT UNSIGNED NOT NULL,
    ques2_i TINYINT UNSIGNED NOT NULL,
    ques2_ii TINYINT UNSIGNED NOT NULL,
    ques2_iii TINYINT UNSIGNED NOT NULL,
    ques2_iv TINYINT UNSIGNED NOT NULL,
    ques2_v TINYINT UNSIGNED NOT NULL,
    ques3 TINYINT UNSIGNED NOT NULL,
    ques4 TINYINT UNSIGNED NOT NULL,

    remarks TEXT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    KEY idx_feedback_year_semester
        (academic_year, semester),

    KEY idx_feedback_branch
        (branch),

    KEY idx_feedback_section
        (section),

    KEY idx_feedback_subject
        (subject),

    KEY idx_feedback_date
        (feedback_date),

    CONSTRAINT chk_semester
        CHECK (semester BETWEEN 1 AND 2),

    CONSTRAINT chk_ques1
        CHECK (ques1 BETWEEN 1 AND 5),

    CONSTRAINT chk_ques2_i
        CHECK (ques2_i BETWEEN 1 AND 5),

    CONSTRAINT chk_ques2_ii
        CHECK (ques2_ii BETWEEN 1 AND 5),

    CONSTRAINT chk_ques2_iii
        CHECK (ques2_iii BETWEEN 1 AND 5),

    CONSTRAINT chk_ques2_iv
        CHECK (ques2_iv BETWEEN 1 AND 5),

    CONSTRAINT chk_ques2_v
        CHECK (ques2_v BETWEEN 1 AND 5),

    CONSTRAINT chk_ques3
        CHECK (ques3 BETWEEN 1 AND 5),

    CONSTRAINT chk_ques4
        CHECK (ques4 BETWEEN 1 AND 5)

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- DEFAULT ADMIN USER
-- ============================================================
-- IMPORTANT:
-- Never store the actual password here in plaintext.
--
-- Generate a password hash in PHP:
--
-- password_hash('your-password', PASSWORD_DEFAULT)
--
-- Then insert the generated hash.
--
-- Example:
--
-- INSERT INTO users (email, password_hash, role)
-- VALUES (
--     'admin@admin.com',
--     '$2y$10$YOUR_GENERATED_PASSWORD_HASH_HERE',
--     'admin'
-- );


-- ============================================================
-- SAMPLE FEEDBACK DATA
-- ============================================================

INSERT INTO feedback (
    academic_year,
    semester,
    feedback_date,
    branch,
    section,
    subject,
    ques1,
    ques2_i,
    ques2_ii,
    ques2_iii,
    ques2_iv,
    ques2_v,
    ques3,
    ques4,
    remarks
) VALUES (
    2019,
    2,
    '2019-05-09',
    'CSE',
    'A',
    'Database Management System',
    5,
    4,
    5,
    4,
    5,
    4,
    5,
    4,
    'Good teaching and explanation.'
);


-- ============================================================
-- USEFUL REPORT QUERIES
-- ============================================================

-- Average score for every question
SELECT
    ROUND(AVG(ques1), 2) AS ques1_avg,
    ROUND(AVG(ques2_i), 2) AS ques2_i_avg,
    ROUND(AVG(ques2_ii), 2) AS ques2_ii_avg,
    ROUND(AVG(ques2_iii), 2) AS ques2_iii_avg,
    ROUND(AVG(ques2_iv), 2) AS ques2_iv_avg,
    ROUND(AVG(ques2_v), 2) AS ques2_v_avg,
    ROUND(AVG(ques3), 2) AS ques3_avg,
    ROUND(AVG(ques4), 2) AS ques4_avg
FROM feedback;


-- Overall average
SELECT
    ROUND(
        (
            AVG(ques1) +
            AVG(ques2_i) +
            AVG(ques2_ii) +
            AVG(ques2_iii) +
            AVG(ques2_iv) +
            AVG(ques2_v) +
            AVG(ques3) +
            AVG(ques4)
        ) / 8,
        2
    ) AS overall_average
FROM feedback;


-- Subject-wise average
SELECT
    subject,
    COUNT(*) AS total_feedback,
    ROUND(
        (
            AVG(ques1) +
            AVG(ques2_i) +
            AVG(ques2_ii) +
            AVG(ques2_iii) +
            AVG(ques2_iv) +
            AVG(ques2_v) +
            AVG(ques3) +
            AVG(ques4)
        ) / 8,
        2
    ) AS average_score
FROM feedback
GROUP BY subject
ORDER BY subject;


-- Branch-wise feedback count
SELECT
    branch,
    COUNT(*) AS total_feedback
FROM feedback
GROUP BY branch
ORDER BY total_feedback DESC;


-- Semester-wise report
SELECT
    academic_year,
    semester,
    COUNT(*) AS total_feedback,
    ROUND(
        (
            AVG(ques1) +
            AVG(ques2_i) +
            AVG(ques2_ii) +
            AVG(ques2_iii) +
            AVG(ques2_iv) +
            AVG(ques2_v) +
            AVG(ques3) +
            AVG(ques4)
        ) / 8,
        2
    ) AS average_score
FROM feedback
GROUP BY academic_year, semester
ORDER BY academic_year DESC, semester;
