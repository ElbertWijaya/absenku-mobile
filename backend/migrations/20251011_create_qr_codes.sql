-- Create qr_codes table for daily QR tokens
CREATE TABLE IF NOT EXISTS `qr_codes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `work_date` date NOT NULL,
  `token` varchar(1024) NOT NULL,
  `valid_until` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_qr_work_date` (`work_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
