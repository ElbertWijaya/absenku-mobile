-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               12.0.2-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.11.0.7065
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for absensi_db
DROP DATABASE IF EXISTS `absensi_db`;
CREATE DATABASE IF NOT EXISTS `absensi_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;
USE `absensi_db`;

-- Dumping structure for table absensi_db.attendance_logs
DROP TABLE IF EXISTS `attendance_logs`;
CREATE TABLE IF NOT EXISTS `attendance_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` bigint(20) unsigned DEFAULT NULL,
  `work_date` date NOT NULL,
  `location_id` int(10) unsigned NOT NULL,
  `check_in_at` datetime NOT NULL,
  `check_out_at` datetime DEFAULT NULL,
  `work_minutes` int(10) unsigned DEFAULT NULL,
  `late_minutes` int(10) unsigned DEFAULT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `status` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.attendance_logs: ~91 rows (approximately)
DELETE FROM `attendance_logs`;
INSERT INTO `attendance_logs` (`id`, `employee_id`, `work_date`, `location_id`, `check_in_at`, `check_out_at`, `work_minutes`, `late_minutes`, `user_id`, `status`) VALUES
	(1, NULL, '2025-10-10', 1, '2025-10-10 07:50:08', NULL, NULL, 0, 2, 'on_time'),
	(2, NULL, '2025-10-10', 1, '2025-10-10 07:50:09', NULL, NULL, 0, 2, 'on_time'),
	(3, NULL, '2025-10-20', 1, '2025-10-20 04:18:47', '2025-10-20 05:45:42', 87, 123, 2, 'late'),
	(4, NULL, '2025-10-20', 1, '2025-10-20 04:24:17', '2025-10-20 04:51:00', 27, 129, 3, 'late'),
	(5, NULL, '2025-10-20', 1, '2025-10-20 05:25:17', NULL, NULL, 190, 5, 'late'),
	(6, NULL, '2025-10-20', 1, '2025-10-20 05:46:11', '2025-10-20 06:24:31', 38, 211, 2, 'late'),
	(7, NULL, '2025-10-20', 1, '2025-10-20 06:17:20', NULL, NULL, 242, 3, 'late'),
	(8, NULL, '2025-10-20', 1, '2025-10-20 06:24:37', '2025-10-20 07:20:12', 56, 249, 2, 'late'),
	(9, NULL, '2025-10-20', 1, '2025-10-20 07:20:16', '2025-10-20 08:01:11', 41, 305, 2, 'late'),
	(10, NULL, '2025-10-20', 1, '2025-10-20 08:01:17', '2025-10-20 08:22:00', 21, 346, 2, 'late'),
	(11, NULL, '2025-10-20', 1, '2025-10-20 08:22:06', '2025-10-20 08:27:46', 6, 367, 2, 'late'),
	(12, 6, '2025-10-20', 2, '2025-10-20 01:40:21', '2025-10-20 09:18:21', 458, 0, 6, 'on_time'),
	(13, 7, '2025-10-20', 3, '2025-10-20 02:32:51', '2025-10-20 09:58:51', 446, 33, 7, 'late'),
	(14, 8, '2025-10-20', 3, '2025-10-20 02:08:34', '2025-10-20 09:58:34', 470, 0, 8, 'on_time'),
	(15, 10, '2025-10-20', 1, '2025-10-20 02:12:26', '2025-10-20 10:24:26', 492, 0, 10, 'on_time'),
	(16, 13, '2025-10-20', 3, '2025-10-20 01:57:55', '2025-10-20 09:36:55', 459, 0, 13, 'on_time'),
	(17, 16, '2025-10-20', 3, '2025-10-20 02:11:36', '2025-10-20 11:01:36', 530, 0, 16, 'on_time'),
	(18, 17, '2025-10-20', 2, '2025-10-20 02:17:59', '2025-10-20 09:18:59', 421, 18, 17, 'late'),
	(19, 19, '2025-10-20', 3, '2025-10-20 02:41:16', '2025-10-20 11:19:16', 518, 41, 19, 'late'),
	(20, 24, '2025-10-20', 3, '2025-10-20 02:11:25', '2025-10-20 10:34:25', 503, 0, 24, 'on_time'),
	(21, 25, '2025-10-20', 1, '2025-10-20 02:01:45', '2025-10-20 09:07:45', 426, 0, 25, 'on_time'),
	(22, 6, '2025-10-19', 2, '2025-10-19 01:51:51', '2025-10-19 10:36:51', 525, 0, 6, 'on_time'),
	(23, 7, '2025-10-19', 3, '2025-10-19 01:48:00', '2025-10-19 09:40:00', 472, 0, 7, 'on_time'),
	(24, 10, '2025-10-19', 1, '2025-10-19 01:41:54', '2025-10-19 10:29:54', 528, 0, 10, 'on_time'),
	(25, 14, '2025-10-19', 2, '2025-10-19 01:57:25', '2025-10-19 10:11:25', 494, 0, 14, 'on_time'),
	(26, 17, '2025-10-19', 2, '2025-10-19 02:18:57', NULL, NULL, 19, 17, 'late'),
	(27, 21, '2025-10-19', 1, '2025-10-19 02:26:49', '2025-10-19 10:03:49', 457, 27, 21, 'late'),
	(28, 22, '2025-10-19', 2, '2025-10-19 01:39:02', '2025-10-19 10:39:02', 540, 0, 22, 'on_time'),
	(29, 24, '2025-10-19', 3, '2025-10-19 01:52:52', '2025-10-19 09:48:52', 476, 0, 24, 'on_time'),
	(30, 6, '2025-10-18', 2, '2025-10-18 01:56:28', NULL, NULL, 0, 6, 'on_time'),
	(31, 11, '2025-10-18', 1, '2025-10-18 01:51:04', '2025-10-18 09:26:04', 455, 0, 11, 'on_time'),
	(32, 12, '2025-10-18', 1, '2025-10-18 02:23:53', NULL, NULL, 24, 12, 'late'),
	(33, 14, '2025-10-18', 2, '2025-10-18 02:12:50', '2025-10-18 10:13:50', 481, 0, 14, 'on_time'),
	(34, 19, '2025-10-18', 3, '2025-10-18 01:54:22', '2025-10-18 10:11:22', 497, 0, 19, 'on_time'),
	(35, 23, '2025-10-18', 1, '2025-10-18 01:45:04', '2025-10-18 10:37:04', 532, 0, 23, 'on_time'),
	(36, 24, '2025-10-18', 3, '2025-10-18 02:04:22', '2025-10-18 09:33:22', 449, 0, 24, 'on_time'),
	(37, 7, '2025-10-17', 3, '2025-10-17 02:32:44', '2025-10-17 10:42:44', 490, 33, 7, 'late'),
	(38, 10, '2025-10-17', 1, '2025-10-17 02:19:24', '2025-10-17 11:13:24', 534, 19, 10, 'late'),
	(39, 11, '2025-10-17', 1, '2025-10-17 02:10:03', '2025-10-17 09:16:03', 426, 0, 11, 'on_time'),
	(40, 12, '2025-10-17', 1, '2025-10-17 01:53:43', '2025-10-17 10:40:43', 527, 0, 12, 'on_time'),
	(41, 13, '2025-10-17', 3, '2025-10-17 01:40:51', '2025-10-17 10:36:51', 536, 0, 13, 'on_time'),
	(42, 14, '2025-10-17', 2, '2025-10-17 02:25:48', NULL, NULL, 26, 14, 'late'),
	(43, 15, '2025-10-17', 2, '2025-10-17 01:49:14', '2025-10-17 10:25:14', 516, 0, 15, 'on_time'),
	(44, 18, '2025-10-17', 2, '2025-10-17 02:40:11', '2025-10-17 10:00:11', 440, 40, 18, 'late'),
	(45, 19, '2025-10-17', 3, '2025-10-17 01:51:06', '2025-10-17 10:21:06', 510, 0, 19, 'on_time'),
	(46, 21, '2025-10-17', 1, '2025-10-17 01:44:23', '2025-10-17 09:39:23', 475, 0, 21, 'on_time'),
	(47, 22, '2025-10-17', 2, '2025-10-17 01:30:52', '2025-10-17 10:30:52', 540, 0, 22, 'on_time'),
	(48, 23, '2025-10-17', 1, '2025-10-17 01:43:36', '2025-10-17 08:50:36', 427, 0, 23, 'on_time'),
	(49, 6, '2025-10-16', 2, '2025-10-16 01:36:56', '2025-10-16 08:48:56', 432, 0, 6, 'on_time'),
	(50, 7, '2025-10-16', 3, '2025-10-16 02:01:01', '2025-10-16 09:12:01', 431, 0, 7, 'on_time'),
	(51, 8, '2025-10-16', 3, '2025-10-16 01:33:40', '2025-10-16 08:58:40', 445, 0, 8, 'on_time'),
	(52, 10, '2025-10-16', 1, '2025-10-16 01:41:58', NULL, NULL, 0, 10, 'on_time'),
	(53, 11, '2025-10-16', 1, '2025-10-16 01:33:47', NULL, NULL, 0, 11, 'on_time'),
	(54, 12, '2025-10-16', 1, '2025-10-16 01:34:30', '2025-10-16 09:02:30', 448, 0, 12, 'on_time'),
	(55, 16, '2025-10-16', 3, '2025-10-16 02:09:28', '2025-10-16 10:35:28', 506, 0, 16, 'on_time'),
	(56, 19, '2025-10-16', 3, '2025-10-16 01:55:52', '2025-10-16 10:00:52', 485, 0, 19, 'on_time'),
	(57, 21, '2025-10-16', 1, '2025-10-16 02:35:04', '2025-10-16 10:01:04', 446, 35, 21, 'late'),
	(58, 23, '2025-10-16', 1, '2025-10-16 02:27:09', '2025-10-16 10:04:09', 457, 27, 23, 'late'),
	(59, 25, '2025-10-16', 1, '2025-10-16 02:05:17', '2025-10-16 10:56:17', 531, 0, 25, 'on_time'),
	(60, 7, '2025-10-15', 3, '2025-10-15 02:20:59', '2025-10-15 09:28:59', 428, 21, 7, 'late'),
	(61, 8, '2025-10-15', 3, '2025-10-15 02:10:56', '2025-10-15 10:27:56', 497, 0, 8, 'on_time'),
	(62, 9, '2025-10-15', 3, '2025-10-15 02:05:25', '2025-10-15 10:42:25', 517, 0, 9, 'on_time'),
	(63, 12, '2025-10-15', 1, '2025-10-15 01:36:25', '2025-10-15 10:22:25', 526, 0, 12, 'on_time'),
	(64, 14, '2025-10-15', 2, '2025-10-15 01:45:54', '2025-10-15 10:30:54', 525, 0, 14, 'on_time'),
	(65, 15, '2025-10-15', 2, '2025-10-15 02:26:44', NULL, NULL, 27, 15, 'late'),
	(66, 17, '2025-10-15', 2, '2025-10-15 01:38:04', NULL, NULL, 0, 17, 'on_time'),
	(67, 21, '2025-10-15', 1, '2025-10-15 01:35:19', '2025-10-15 09:07:19', 452, 0, 21, 'on_time'),
	(68, 6, '2025-10-14', 2, '2025-10-14 02:24:46', '2025-10-14 10:25:46', 481, 25, 6, 'late'),
	(69, 8, '2025-10-14', 3, '2025-10-14 01:50:26', '2025-10-14 08:58:26', 428, 0, 8, 'on_time'),
	(70, 9, '2025-10-14', 3, '2025-10-14 01:57:33', NULL, NULL, 0, 9, 'on_time'),
	(71, 11, '2025-10-14', 1, '2025-10-14 01:39:22', NULL, NULL, 0, 11, 'on_time'),
	(72, 12, '2025-10-14', 1, '2025-10-14 01:30:55', '2025-10-14 10:12:55', 522, 0, 12, 'on_time'),
	(73, 13, '2025-10-14', 3, '2025-10-14 02:38:38', '2025-10-14 09:56:38', 438, 39, 13, 'late'),
	(74, 16, '2025-10-14', 3, '2025-10-14 01:48:10', '2025-10-14 09:49:10', 481, 0, 16, 'on_time'),
	(75, 17, '2025-10-14', 2, '2025-10-14 02:36:13', '2025-10-14 11:30:13', 534, 36, 17, 'late'),
	(76, 18, '2025-10-14', 2, '2025-10-14 02:21:44', '2025-10-14 10:50:44', 509, 22, 18, 'late'),
	(77, 22, '2025-10-14', 2, '2025-10-14 01:52:58', NULL, NULL, 0, 22, 'on_time'),
	(78, 24, '2025-10-14', 3, '2025-10-14 01:47:54', '2025-10-14 09:00:54', 433, 0, 24, 'on_time'),
	(79, 6, '2025-10-13', 2, '2025-10-13 02:37:07', '2025-10-13 11:15:07', 518, 37, 6, 'late'),
	(80, 9, '2025-10-13', 3, '2025-10-13 01:50:10', '2025-10-13 10:35:10', 525, 0, 9, 'on_time'),
	(81, 11, '2025-10-13', 1, '2025-10-13 02:17:58', '2025-10-13 09:31:58', 434, 18, 11, 'late'),
	(82, 13, '2025-10-13', 3, '2025-10-13 02:37:56', '2025-10-13 10:06:56', 449, 38, 13, 'late'),
	(83, 19, '2025-10-13', 3, '2025-10-13 01:30:55', NULL, NULL, 0, 19, 'on_time'),
	(84, 22, '2025-10-13', 2, '2025-10-13 02:41:50', '2025-10-13 10:03:50', 442, 42, 22, 'late'),
	(85, 24, '2025-10-13', 3, '2025-10-13 01:55:34', '2025-10-13 09:14:34', 439, 0, 24, 'on_time'),
	(86, 6, '2025-10-12', 2, '2025-10-12 01:37:09', '2025-10-12 08:52:09', 435, 0, 6, 'on_time'),
	(87, 8, '2025-10-12', 3, '2025-10-12 01:42:31', '2025-10-12 10:24:31', 522, 0, 8, 'on_time'),
	(88, 11, '2025-10-12', 1, '2025-10-12 01:54:47', '2025-10-12 10:20:47', 506, 0, 11, 'on_time'),
	(89, 12, '2025-10-12', 1, '2025-10-12 01:53:12', '2025-10-12 10:45:12', 532, 0, 12, 'on_time'),
	(90, 13, '2025-10-12', 3, '2025-10-12 01:46:46', '2025-10-12 09:04:46', 438, 0, 13, 'on_time'),
	(91, 15, '2025-10-12', 2, '2025-10-12 02:00:27', '2025-10-12 10:25:27', 505, 0, 15, 'on_time');

-- Dumping structure for table absensi_db.audit_logs
DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `actor_user_id` bigint(20) unsigned DEFAULT NULL,
  `action` varchar(120) NOT NULL,
  `resource` varchar(120) DEFAULT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`details`)),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_audit_time` (`created_at`),
  KEY `fk_audit_user` (`actor_user_id`),
  CONSTRAINT `fk_audit_user` FOREIGN KEY (`actor_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.audit_logs: ~0 rows (approximately)
DELETE FROM `audit_logs`;

-- Dumping structure for table absensi_db.employees
DROP TABLE IF EXISTS `employees`;
CREATE TABLE IF NOT EXISTS `employees` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `full_name` varchar(150) NOT NULL,
  `role_title` varchar(100) DEFAULT NULL,
  `gender` enum('M','F') DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `religion` varchar(50) DEFAULT NULL,
  `join_date` date DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `default_location_id` int(10) unsigned DEFAULT NULL,
  `base_salary_rate` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_765bc1ac8967533a04c74a9f6a` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.employees: ~25 rows (approximately)
DELETE FROM `employees`;
INSERT INTO `employees` (`id`, `full_name`, `role_title`, `gender`, `phone`, `address`, `email`, `birth_date`, `religion`, `join_date`, `is_active`, `default_location_id`, `base_salary_rate`) VALUES
	(1, 'Administrator', NULL, NULL, NULL, NULL, 'admin@example.com', NULL, NULL, NULL, 1, NULL, NULL),
	(2, 'Elbert', NULL, NULL, NULL, NULL, 'elbert@example.com', NULL, NULL, NULL, 1, NULL, NULL),
	(3, 'Fernando', NULL, NULL, '081654986843', NULL, 'fernando@example.com', NULL, NULL, NULL, 1, NULL, NULL),
	(4, 'Thoro', NULL, NULL, NULL, NULL, 'thoro@example.com', NULL, NULL, NULL, 1, NULL, NULL),
	(5, 'Howard', NULL, NULL, NULL, NULL, 'howard@example.com', NULL, NULL, NULL, 1, NULL, NULL),
	(6, 'Mira Santoso', 'Staff', 'F', '08910823166', NULL, 'employee1@example.com', '1983-03-26', NULL, '2022-02-07', 1, 2, 5000000.00),
	(7, 'Tono Utami', 'Staff', 'M', '08124477531', NULL, 'employee2@example.com', '1993-06-16', NULL, '2025-10-06', 1, 3, 5000000.00),
	(8, 'Mira Nuraini', 'Staff', 'F', '08614180441', NULL, 'employee3@example.com', '1990-08-01', NULL, '2024-07-19', 1, 3, 5000000.00),
	(9, 'Indah Siregar', 'Staff', 'M', '08782515753', NULL, 'employee4@example.com', '1998-12-21', NULL, '2025-06-07', 1, 3, 5000000.00),
	(10, 'Indah Nuraini', 'Staff', 'F', '08993953692', NULL, 'employee5@example.com', '1999-04-08', NULL, '2020-09-14', 1, 1, 5000000.00),
	(11, 'Tono Siregar', 'Staff', 'F', '08451336933', NULL, 'employee6@example.com', '1999-12-28', NULL, '2024-11-16', 1, 1, 5000000.00),
	(12, 'Indah Maulana', 'Staff', 'F', '08419937624', NULL, 'employee7@example.com', '1991-09-12', NULL, '2025-10-06', 1, 1, 5000000.00),
	(13, 'Eka Utami', 'Staff', 'M', '08635053046', NULL, 'employee8@example.com', '1990-10-18', NULL, '2022-12-27', 1, 3, 5000000.00),
	(14, 'Kiki Sitohang', 'Staff', 'F', '08155514613', NULL, 'employee9@example.com', '1980-09-09', NULL, '2024-05-27', 1, 2, 5000000.00),
	(15, 'Rani Wijaya', 'Staff', 'M', '08309714068', NULL, 'employee10@example.com', '1994-09-12', NULL, '2025-04-11', 1, 2, 5000000.00),
	(16, 'Putra Sitohang', 'Staff', 'M', '08208136196', NULL, 'employee11@example.com', '1982-07-23', NULL, '2020-11-09', 1, 3, 5000000.00),
	(17, 'Hadi Wijaya', 'Staff', 'F', '08559676025', NULL, 'employee12@example.com', '1986-08-17', NULL, '2022-07-01', 1, 2, 5000000.00),
	(18, 'Budi Saputra', 'Staff', 'F', '08445803179', NULL, 'employee13@example.com', '1998-11-05', NULL, '2025-11-19', 1, 2, 5000000.00),
	(19, 'Mira Pratama', 'Staff', 'M', '08870142054', NULL, 'employee14@example.com', '1996-01-12', NULL, '2021-08-21', 1, 3, 5000000.00),
	(20, 'Dewi Pratama', 'Staff', 'M', '08522953227', NULL, 'employee15@example.com', '1984-08-02', NULL, '2023-08-21', 1, 2, 5000000.00),
	(21, 'Hadi Wijaya', 'Staff', 'F', '08377366952', NULL, 'employee16@example.com', '1991-09-27', NULL, '2025-03-23', 1, 1, 5000000.00),
	(22, 'Mira Sitohang', 'Staff', 'F', '08369185305', NULL, 'employee17@example.com', '1980-04-23', NULL, '2025-08-14', 1, 2, 5000000.00),
	(23, 'Dewi Siregar', 'Staff', 'M', '08970055481', NULL, 'employee18@example.com', '1998-01-06', NULL, '2022-08-06', 1, 1, 5000000.00),
	(24, 'Citra Siregar', 'Staff', 'F', '08861777640', NULL, 'employee19@example.com', '1986-11-28', NULL, '2025-06-25', 1, 3, 5000000.00),
	(25, 'Tono Sitohang', 'Staff', 'F', '08539724639', NULL, 'employee20@example.com', '1988-12-07', NULL, '2020-11-05', 1, 1, 5000000.00);

-- Dumping structure for table absensi_db.holidays
DROP TABLE IF EXISTS `holidays`;
CREATE TABLE IF NOT EXISTS `holidays` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `name` varchar(120) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.holidays: ~0 rows (approximately)
DELETE FROM `holidays`;

-- Dumping structure for table absensi_db.leave_requests
DROP TABLE IF EXISTS `leave_requests`;
CREATE TABLE IF NOT EXISTS `leave_requests` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` bigint(20) unsigned NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `type` varchar(50) NOT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `reason` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_leave_emp` (`employee_id`),
  CONSTRAINT `fk_leave_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.leave_requests: ~0 rows (approximately)
DELETE FROM `leave_requests`;

-- Dumping structure for table absensi_db.locations
DROP TABLE IF EXISTS `locations`;
CREATE TABLE IF NOT EXISTS `locations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `address` text DEFAULT NULL,
  `lat` decimal(10,7) DEFAULT NULL,
  `lng` decimal(10,7) DEFAULT NULL,
  `radius_m` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.locations: ~0 rows (approximately)
DELETE FROM `locations`;

-- Dumping structure for table absensi_db.migrations
DROP TABLE IF EXISTS `migrations`;
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.migrations: ~4 rows (approximately)
DELETE FROM `migrations`;
INSERT INTO `migrations` (`id`, `timestamp`, `name`) VALUES
	(1, 251007090000, 'InitSchema20251007090000'),
	(2, 251007090500, 'MultilocationShiftDefaults20251007090500'),
	(3, 251018123000, 'RemoveShifts20251018123000'),
	(4, 1760774098606, 'Auto1760774098606');

-- Dumping structure for table absensi_db.payroll_items
DROP TABLE IF EXISTS `payroll_items`;
CREATE TABLE IF NOT EXISTS `payroll_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `payroll_run_id` bigint(20) unsigned NOT NULL,
  `employee_id` bigint(20) unsigned NOT NULL,
  `base_pay` decimal(12,2) NOT NULL DEFAULT 0.00,
  `late_deduction` decimal(12,2) NOT NULL DEFAULT 0.00,
  `overtime_pay` decimal(12,2) NOT NULL DEFAULT 0.00,
  `allowances` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_pay` decimal(12,2) NOT NULL DEFAULT 0.00,
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_pi_run` (`payroll_run_id`),
  KEY `idx_pi_emp_run` (`employee_id`,`payroll_run_id`),
  CONSTRAINT `fk_pi_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pi_run` FOREIGN KEY (`payroll_run_id`) REFERENCES `payroll_runs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.payroll_items: ~0 rows (approximately)
DELETE FROM `payroll_items`;

-- Dumping structure for table absensi_db.payroll_runs
DROP TABLE IF EXISTS `payroll_runs`;
CREATE TABLE IF NOT EXISTS `payroll_runs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `status` enum('draft','finalized') NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.payroll_runs: ~0 rows (approximately)
DELETE FROM `payroll_runs`;

-- Dumping structure for table absensi_db.qr_codes
DROP TABLE IF EXISTS `qr_codes`;
CREATE TABLE IF NOT EXISTS `qr_codes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `work_date` date NOT NULL,
  `token` varchar(1024) NOT NULL,
  `valid_until` datetime NOT NULL,
  `created_at` timestamp(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_e8f6a36eaaabdf1f53ef44366e` (`work_date`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.qr_codes: ~8 rows (approximately)
DELETE FROM `qr_codes`;
INSERT INTO `qr_codes` (`id`, `work_date`, `token`, `valid_until`, `created_at`) VALUES
	(1, '2025-10-11', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ3ZCI6IjIwMjUtMTAtMTEiLCJ0eXAiOiJxciIsImlhdCI6MTc2MDE2NjczMiwiZXhwIjoxNzYwMjAxOTk5fQ.wMuSzrGBNm2bygJ38C76oKWTrZr29QNAs1gnVVHW3Fo', '2025-10-11 16:59:59', '2025-10-11 07:12:12.657268'),
	(2, '2025-10-14', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ3ZCI6IjIwMjUtMTAtMTQiLCJ0eXAiOiJxciIsImlhdCI6MTc2MDQ0ODc5OSwiZXhwIjoxNzYwNDYxMTk5fQ.ZHsGonqwzQAdkqqYrkScQG17Oh_MP5Juh3c8SVYWItU', '2025-10-14 16:59:59', '2025-10-14 13:33:19.120479'),
	(3, '2025-10-17', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ3ZCI6IjIwMjUtMTAtMTciLCJ0eXAiOiJxciIsImlhdCI6MTc2MDY3NDQxOCwiZXhwIjoxNzYwNzIwMzk5fQ.KSh6AwOIeCat_b54wh9lxFO3L9BKNyvZ9iExKY6Mw_4', '2025-10-17 16:59:59', '2025-10-17 04:13:38.763175'),
	(4, '2025-10-20', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ3ZCI6IjIwMjUtMTAtMjAiLCJ0eXAiOiJxciIsImlhdCI6MTc2MDkzMDk5OSwiZXhwIjoxNzYwOTc5NTk5fQ.4l8zK_jJeB3qyXDv0yyxM4zrNWyzvscMRYeCT2HTy3w', '2025-10-20 16:59:59', '2025-10-20 03:29:59.391206'),
	(5, '2025-10-19', 'dummy-token-2025-10-19-242664', '2025-10-19 16:59:59', '2025-10-20 09:23:29.593129'),
	(6, '2025-10-18', 'dummy-token-2025-10-18-319985', '2025-10-18 16:59:59', '2025-10-20 09:23:29.595992'),
	(7, '2025-10-16', 'dummy-token-2025-10-16-823866', '2025-10-16 16:59:59', '2025-10-20 09:23:29.599732'),
	(8, '2025-10-15', 'dummy-token-2025-10-15-435238', '2025-10-15 16:59:59', '2025-10-20 09:23:29.603456');

-- Dumping structure for table absensi_db.qr_tokens
DROP TABLE IF EXISTS `qr_tokens`;
CREATE TABLE IF NOT EXISTS `qr_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `location_id` int(10) unsigned DEFAULT NULL,
  `shift_id` int(10) unsigned DEFAULT NULL,
  `jti` char(36) NOT NULL,
  `issued_at` datetime NOT NULL,
  `expires_at` datetime NOT NULL,
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_qr_jti` (`jti`),
  KEY `idx_qr_active` (`expires_at`),
  KEY `fk_qr_shift` (`shift_id`),
  KEY `fk_qr_loc` (`location_id`),
  CONSTRAINT `fk_qr_loc` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_qr_shift` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.qr_tokens: ~0 rows (approximately)
DELETE FROM `qr_tokens`;

-- Dumping structure for table absensi_db.roles
DROP TABLE IF EXISTS `roles`;
CREATE TABLE IF NOT EXISTS `roles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_648e3f5447f725579d7d4ffdfb` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.roles: ~2 rows (approximately)
DELETE FROM `roles`;
INSERT INTO `roles` (`id`, `name`) VALUES
	(1, 'ADMIN'),
	(2, 'EMPLOYEE');

-- Dumping structure for table absensi_db.schedules
DROP TABLE IF EXISTS `schedules`;
CREATE TABLE IF NOT EXISTS `schedules` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` bigint(20) unsigned NOT NULL,
  `shift_id` int(10) unsigned NOT NULL,
  `location_id` int(10) unsigned DEFAULT NULL,
  `work_date` date NOT NULL,
  `status` enum('planned','completed','absent') NOT NULL DEFAULT 'planned',
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_schedule` (`employee_id`,`work_date`,`shift_id`),
  UNIQUE KEY `uq_schedule_emp_date` (`employee_id`,`work_date`),
  KEY `fk_sched_shift` (`shift_id`),
  KEY `fk_sched_loc` (`location_id`),
  CONSTRAINT `fk_sched_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_sched_loc` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.schedules: ~0 rows (approximately)
DELETE FROM `schedules`;

-- Dumping structure for table absensi_db.shifts
DROP TABLE IF EXISTS `shifts`;
CREATE TABLE IF NOT EXISTS `shifts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `grace_minutes` int(11) NOT NULL DEFAULT 10,
  `min_check_out_after_minutes` int(11) NOT NULL DEFAULT 60,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.shifts: ~0 rows (approximately)
DELETE FROM `shifts`;

-- Dumping structure for table absensi_db.users
DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` bigint(20) unsigned DEFAULT NULL,
  `email` varchar(150) NOT NULL,
  `username` varchar(80) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` timestamp(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` timestamp(6) NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_97672ac88f789774dd47f7c8be` (`email`),
  UNIQUE KEY `IDX_fe0bb3f6520ee0469504521e71` (`username`),
  KEY `FK_9760615d88ed518196bb79ea03d` (`employee_id`),
  CONSTRAINT `FK_9760615d88ed518196bb79ea03d` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.users: ~25 rows (approximately)
DELETE FROM `users`;
INSERT INTO `users` (`id`, `employee_id`, `email`, `username`, `password_hash`, `last_login_at`, `created_at`, `updated_at`) VALUES
	(1, 1, 'admin@example.com', 'admin', '$2b$10$9roqm0Mcignq6usTqscHyebZiZDQKdRmMrgtvzJfhnWFaz6mI2AkW', NULL, '2025-10-07 06:41:16.000000', NULL),
	(2, 2, 'elbert@example.com', 'Elbert', '$2b$10$W/8cuf6pAWFlMt6CxRZVaOJZHH1WiDcYcfgdgftOOc3lOj2ecphhO', NULL, '2025-10-08 12:49:49.989485', '2025-10-18 05:35:14.000000'),
	(3, 3, 'fernando@example.com', 'Fernando', '$2b$10$W/8cuf6pAWFlMt6CxRZVaOJZHH1WiDcYcfgdgftOOc3lOj2ecphhO', NULL, '2025-10-08 12:49:50.005251', '2025-10-18 05:35:14.000000'),
	(4, 4, 'thoro@example.com', 'Thoro', '$2b$10$W/8cuf6pAWFlMt6CxRZVaOJZHH1WiDcYcfgdgftOOc3lOj2ecphhO', NULL, '2025-10-08 12:49:50.011801', '2025-10-18 05:35:14.000000'),
	(5, 5, 'howard@example.com', 'Howard', '$2b$10$W/8cuf6pAWFlMt6CxRZVaOJZHH1WiDcYcfgdgftOOc3lOj2ecphhO', NULL, '2025-10-08 12:49:50.019476', '2025-10-18 05:35:14.000000'),
	(6, 6, 'employee1@example.com', 'employee1', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.098842', '2025-10-20 09:23:29.098842'),
	(7, 7, 'employee2@example.com', 'employee2', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.111267', '2025-10-20 09:23:29.111267'),
	(8, 8, 'employee3@example.com', 'employee3', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.127300', '2025-10-20 09:23:29.127300'),
	(9, 9, 'employee4@example.com', 'employee4', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.138851', '2025-10-20 09:23:29.138851'),
	(10, 10, 'employee5@example.com', 'employee5', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.153052', '2025-10-20 09:23:29.153052'),
	(11, 11, 'employee6@example.com', 'employee6', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.165041', '2025-10-20 09:23:29.165041'),
	(12, 12, 'employee7@example.com', 'employee7', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.176968', '2025-10-20 09:23:29.176968'),
	(13, 13, 'employee8@example.com', 'employee8', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.188222', '2025-10-20 09:23:29.188222'),
	(14, 14, 'employee9@example.com', 'employee9', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.199645', '2025-10-20 09:23:29.199645'),
	(15, 15, 'employee10@example.com', 'employee10', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.210528', '2025-10-20 09:23:29.210528'),
	(16, 16, 'employee11@example.com', 'employee11', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.222482', '2025-10-20 09:23:29.222482'),
	(17, 17, 'employee12@example.com', 'employee12', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.233709', '2025-10-20 09:23:29.233709'),
	(18, 18, 'employee13@example.com', 'employee13', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.243857', '2025-10-20 09:23:29.243857'),
	(19, 19, 'employee14@example.com', 'employee14', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.257563', '2025-10-20 09:23:29.257563'),
	(20, 20, 'employee15@example.com', 'employee15', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.268448', '2025-10-20 09:23:29.268448'),
	(21, 21, 'employee16@example.com', 'employee16', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.277868', '2025-10-20 09:23:29.277868'),
	(22, 22, 'employee17@example.com', 'employee17', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.288470', '2025-10-20 09:23:29.288470'),
	(23, 23, 'employee18@example.com', 'employee18', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.298626', '2025-10-20 09:23:29.298626'),
	(24, 24, 'employee19@example.com', 'employee19', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.307913', '2025-10-20 09:23:29.307913'),
	(25, 25, 'employee20@example.com', 'employee20', '$2b$10$VSIyTYeVZqumtBmpSucZJO.RPEL9uXtGXT.z5Gn/Fok0ZIKr4fly.', NULL, '2025-10-20 09:23:29.317044', '2025-10-20 09:23:29.317044');

-- Dumping structure for table absensi_db.user_roles
DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE IF NOT EXISTS `user_roles` (
  `user_id` bigint(20) unsigned NOT NULL,
  `role_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `IDX_87b8888186ca9769c960e92687` (`user_id`),
  KEY `IDX_b23c65e50a758245a33ee35fda` (`role_id`),
  CONSTRAINT `FK_87b8888186ca9769c960e926870` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_b23c65e50a758245a33ee35fda1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table absensi_db.user_roles: ~25 rows (approximately)
DELETE FROM `user_roles`;
INSERT INTO `user_roles` (`user_id`, `role_id`) VALUES
	(1, 1),
	(2, 2),
	(3, 2),
	(4, 2),
	(5, 2),
	(6, 2),
	(7, 2),
	(8, 2),
	(9, 2),
	(10, 2),
	(11, 2),
	(12, 2),
	(13, 2),
	(14, 2),
	(15, 2),
	(16, 2),
	(17, 2),
	(18, 2),
	(19, 2),
	(20, 2),
	(21, 2),
	(22, 2),
	(23, 2),
	(24, 2),
	(25, 2);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
