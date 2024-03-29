-- CREATEと逆順
DROP TABLE IF EXISTS `unread_announcements`;
DROP TABLE IF EXISTS `announcements`;
DROP TABLE IF EXISTS `submissions`;
DROP TABLE IF EXISTS `classes`;
DROP TABLE IF EXISTS `registrations`;
DROP TABLE IF EXISTS `courses`;
DROP TABLE IF EXISTS `users`;

-- master data
CREATE TABLE `users`
(
    `id`              CHAR(26) PRIMARY KEY,
    `code`            CHAR(6) UNIQUE              NOT NULL,
    `name`            VARCHAR(255)                NOT NULL,
    `hashed_password` BINARY(60)                  NOT NULL,
    `type`            ENUM ('student', 'teacher') NOT NULL
);

CREATE INDEX idx_users_code ON `users` (`code`, `id`);

CREATE TABLE `courses`
(
    `id`          CHAR(26) PRIMARY KEY,
    `code`        VARCHAR(255) UNIQUE                                           NOT NULL,
    `type`        ENUM ('liberal-arts', 'major-subjects')                       NOT NULL,
    `name`        VARCHAR(255)                                                  NOT NULL,
    `description` TEXT                                                          NOT NULL,
    `credit`      TINYINT UNSIGNED                                              NOT NULL,
    `period`      TINYINT UNSIGNED                                              NOT NULL,
    `day_of_week` ENUM ('monday', 'tuesday', 'wednesday', 'thursday', 'friday') NOT NULL,
    `teacher_id`  CHAR(26)                                                      NOT NULL,
    `keywords`    TEXT                                                          NOT NULL,
    `status`      ENUM ('registration', 'in-progress', 'closed')                NOT NULL DEFAULT 'registration',
    CONSTRAINT FK_courses_teacher_id FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`)
);

CREATE INDEX idx_courses_type ON `courses` (`id`, `type`, `teacher_id`, `period`);

CREATE TABLE `registrations`
(
    `course_id` CHAR(26),
    `user_id`   CHAR(26),
    PRIMARY KEY (`course_id`, `user_id`),
    CONSTRAINT FK_registrations_course_id FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`),
    CONSTRAINT FK_registrations_user_id FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
);

-- CREATE INDEX idx_registrations ON `registrations` (`user_id`);

CREATE TABLE `classes`
(
    `id`                CHAR(26) PRIMARY KEY,
    `course_id`         CHAR(26)         NOT NULL,
    `part`              TINYINT UNSIGNED NOT NULL,
    `title`             VARCHAR(255)     NOT NULL,
    `description`       TEXT             NOT NULL,
    `submission_closed` TINYINT(1)       NOT NULL DEFAULT false,
    UNIQUE KEY `idx_classes_course_id_part` (`course_id`, `part`),
    CONSTRAINT FK_classes_course_id FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`)
);

CREATE INDEX idx_classes ON `classes` (`id`, `course_id`, `part` ASC);

CREATE TABLE `submissions`
(
    `user_id`   CHAR(26)     NOT NULL,
    `class_id`  CHAR(26)     NOT NULL,
    `file_name` VARCHAR(255) NOT NULL,
    `score`     TINYINT UNSIGNED,
    PRIMARY KEY (`user_id`, `class_id`),
    CONSTRAINT FK_submissions_user_id FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
    CONSTRAINT FK_submissions_class_id FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`)
);

CREATE INDEX idx_submissions ON `submissions` (`user_id`, `class_id`);

CREATE TABLE `announcements`
(
    `id`         CHAR(26) PRIMARY KEY,
    `course_id`  CHAR(26)     NOT NULL,
    `title`      VARCHAR(255) NOT NULL,
    `message`    TEXT         NOT NULL,
    CONSTRAINT FK_announcements_course_id FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`)
);
CREATE INDEX idx_announcements ON `announcements` (`id` DESC);

CREATE TABLE `unread_announcements`
(
    `announcement_id` CHAR(26)   NOT NULL,
    `user_id`         CHAR(26)   NOT NULL,
    `is_deleted`      TINYINT(1) NOT NULL DEFAULT false,
    -- PRIMARY KEY (`announcement_id`, `user_id`),
    CONSTRAINT FK_unread_announcements_announcement_id FOREIGN KEY (`announcement_id`) REFERENCES `announcements` (`id`),
    CONSTRAINT FK_unread_announcements_user_id FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
);

CREATE INDEX idx_unread_announcements ON `unread_announcements` (`user_id`, `announcement_id`, `is_deleted`);