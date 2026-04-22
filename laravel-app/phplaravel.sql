-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 15, 2025 at 12:15 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.1.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `phplaravel`
--

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(50) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `slug`, `created_at`, `updated_at`) VALUES
(1, 'CPU', 'cpu', '2025-03-06 15:06:04', '2025-03-06 08:09:02'),
(2, 'RAM', 'ram', '2025-03-06 15:06:04', '2025-03-06 15:06:04'),
(3, 'Mainboard', 'mainboard', '2025-03-06 15:06:04', '2025-03-06 15:06:04'),
(4, 'GPU', 'gpu', '2025-03-06 15:06:04', '2025-03-06 15:06:04'),
(5, 'SSD', 'ssd', '2025-03-06 15:06:04', '2025-03-06 15:06:04'),
(6, 'HDD', 'hdd', '2025-03-06 15:06:04', '2025-03-06 15:06:04'),
(7, 'Case', 'case', '2025-03-06 15:06:04', '2025-03-06 15:06:04'),
(8, 'Tản nhiệt', 'tan-nhiet', '2025-03-06 15:06:04', '2025-03-06 15:06:04'),
(12, 'PSU', 'psuu', '2025-03-06 08:10:21', '2025-03-06 08:10:31');

-- --------------------------------------------------------

--
-- Table structure for table `homepage_sections`
--

CREATE TABLE `homepage_sections` (
  `id` int(11) NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL DEFAULT '',
  `display_type` enum('latest','bestseller') NOT NULL DEFAULT 'latest',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2019_12_14_000001_create_personal_access_tokens_table', 1),
(2, '2025_02_26_122525_create_categories_table', 1),
(3, '2025_02_26_122525_create_products_table', 1),
(4, '2025_02_26_122525_create_users_table', 1),
(5, '2025_02_26_122526_create_cart_table', 1),
(6, '2025_02_26_122526_create_orders_table', 1),
(7, '2025_02_26_122526_create_statistics_table', 1),
(8, '2025_03_05_105144_create_comments_table', 2),
(9, '2025_03_05_113822_add_slug_to_categories', 3),
(10, '2025_03_05_142243_add_slug_to_categories_table', 4);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `customer_name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `address` text NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `status` enum('pending','processing','completed','canceled') NOT NULL DEFAULT 'pending',
  `cancel_reason` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `payment_method` varchar(50) NOT NULL DEFAULT 'cod'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `customer_name`, `email`, `phone`, `address`, `total_price`, `status`, `cancel_reason`, `created_at`, `updated_at`, `payment_method`) VALUES
(1, 2, 'hưng', '19novemberrr@gmail.com', '0898657182', 'a', 2000.00, 'completed', NULL, '2025-03-10 18:07:40', '2025-03-11 11:05:44', 'COD'),
(2, 2, 'hưng', '19novemberrr@gmail.com', '0898657182', 'a', 2000.00, 'canceled', 'Khách hàng yêu cầu hủy', '2025-03-10 18:09:17', '2025-03-11 10:08:28', 'COD'),
(3, 2, 'hưng', '19novemberrr@gmail.com', '0898657182', 'a', 2000.00, 'canceled', 'Tôi không muốn mua nữa', '2025-03-10 18:26:28', '2025-03-11 09:31:34', 'COD'),
(4, 1, 'admin', 'jericho.terryon@frontbridges.com', '0987654321', 'a', 2000.00, 'canceled', 'Không thể liên lạc với khách hàng', '2025-03-11 14:52:14', '2025-03-11 14:53:36', 'COD'),
(5, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'b', 4000.00, 'completed', NULL, '2025-03-11 14:53:09', '2025-03-11 14:55:24', 'COD'),
(6, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', '3', 2000.00, 'completed', NULL, '2025-03-11 15:07:45', '2025-03-11 15:18:15', 'COD'),
(7, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', '4', 1290000.00, 'completed', NULL, '2025-03-11 15:08:15', '2025-03-11 15:18:03', 'COD'),
(8, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', '4', 2000.00, 'completed', NULL, '2025-03-11 15:21:46', '2025-03-11 15:22:20', 'COD'),
(9, 1, 'admin', '19novemberrr@gmail.com', '0898657182', '5', 2000.00, 'canceled', 'Khách hàng yêu cầu hủy', '2025-03-11 15:23:35', '2025-03-11 15:23:59', 'COD'),
(10, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', '6', 2000.00, 'canceled', 'Lý do khác', '2025-03-11 15:27:41', '2025-03-11 15:28:50', 'online'),
(11, 1, 'admin', '19novemberrr@gmail.com', '0898657182', '7', 2000.00, 'completed', NULL, '2025-03-11 15:34:00', '2025-03-11 15:35:19', 'COD'),
(12, 1, 'hưng', '19novemberrr@gmail.com', '0898657182', 'a', 2000.00, 'completed', NULL, '2025-03-11 15:35:38', '2025-03-11 15:35:51', 'COD'),
(13, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'canceled', 'Không thể liên lạc với khách hàng', '2025-03-11 15:38:19', '2025-03-11 15:38:34', 'COD'),
(14, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'completed', NULL, '2025-03-11 15:39:48', '2025-03-11 15:40:10', 'COD'),
(15, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', '8', 2000.00, 'canceled', 'Lý do khác', '2025-03-11 15:45:15', '2025-03-11 15:45:31', 'COD'),
(16, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', '9', 2000.00, 'completed', NULL, '2025-03-11 15:46:07', '2025-03-11 15:46:26', 'COD'),
(17, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'canceled', 'Khách hàng yêu cầu hủy', '2025-03-11 15:53:12', '2025-03-11 15:53:31', 'COD'),
(18, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'completed', NULL, '2025-03-11 15:53:58', '2025-03-11 15:54:09', 'COD'),
(19, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'completed', NULL, '2025-03-11 15:58:27', '2025-03-11 15:58:37', 'COD'),
(20, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', '9', 2000.00, 'canceled', 'Lý do khác', '2025-03-11 15:59:07', '2025-03-11 15:59:30', 'COD'),
(21, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', '1', 2000.00, 'canceled', 'Hết hàng', '2025-03-11 16:01:51', '2025-03-11 16:02:04', 'COD'),
(22, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'completed', NULL, '2025-03-11 16:02:48', '2025-03-11 16:02:57', 'COD'),
(23, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'completed', NULL, '2025-03-11 16:07:26', '2025-03-11 16:07:36', 'COD'),
(24, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', '8', 2000.00, 'canceled', 'Hết hàng', '2025-03-11 16:08:01', '2025-03-11 16:08:12', 'COD'),
(25, 1, 'admin', 'jericho.terryon@frontbridges.com', '0971099604', 'a', 2000.00, 'canceled', 'Hết hàng', '2025-03-11 16:23:03', '2025-03-11 16:23:17', 'COD'),
(26, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', '1', 2000.00, 'completed', NULL, '2025-03-11 16:23:48', '2025-03-11 16:23:57', 'COD'),
(27, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'canceled', 'Khách hàng yêu cầu hủy', '2025-03-11 16:24:17', '2025-03-11 16:24:28', 'COD'),
(28, 2, 'john hn', 'jericho.terryon@frontbridges.com', '0898657182', '1', 2000.00, 'canceled', 'Khách hàng yêu cầu hủy', '2025-03-11 16:32:15', '2025-03-11 16:32:33', 'COD'),
(29, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', '9', 2000.00, 'canceled', 'Hết hàng', '2025-03-12 08:07:01', '2025-03-12 08:08:07', 'COD'),
(30, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', '9', 12490000.00, 'completed', NULL, '2025-03-12 08:10:26', '2025-03-12 08:10:41', 'COD'),
(31, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', '1', 2000.00, 'completed', NULL, '2025-03-12 08:11:25', '2025-03-12 08:11:44', 'COD'),
(32, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 1290000.00, 'canceled', 'Khách hàng yêu cầu hủy', '2025-03-12 08:12:28', '2025-03-12 08:12:40', 'COD'),
(33, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'canceled', 'Hết hàng', '2025-03-12 08:13:01', '2025-03-12 08:13:11', 'COD'),
(34, 1, 'hưng', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'canceled', 'Hết hàng', '2025-03-12 08:17:42', '2025-03-12 08:17:52', 'COD'),
(35, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'completed', NULL, '2025-03-12 08:18:07', '2025-03-12 08:18:15', 'COD'),
(36, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'completed', NULL, '2025-03-12 08:24:08', '2025-03-12 08:26:49', 'COD'),
(37, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', '9', 2000.00, 'completed', NULL, '2025-03-12 08:31:11', '2025-03-12 08:31:31', 'COD'),
(38, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'canceled', 'Không thể liên lạc với khách hàng', '2025-03-12 08:31:55', '2025-03-12 08:32:07', 'COD'),
(39, 1, 'hưng', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'canceled', 'Lý do khác', '2025-03-12 10:59:55', '2025-03-12 11:00:22', 'COD'),
(40, 1, 'admin', 'jericho.terryon@frontbridges.com', '0971099604', 'o', 2000.00, 'completed', NULL, '2025-03-12 11:00:41', '2025-03-12 11:00:58', 'online'),
(41, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'pending', NULL, '2025-03-12 11:09:50', '2025-03-12 11:09:50', 'online'),
(42, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'pending', NULL, '2025-03-12 11:12:28', '2025-03-12 11:12:28', 'online'),
(43, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'canceled', 'Hết hàng', '2025-03-13 10:07:58', '2025-03-13 10:08:13', 'COD'),
(44, 1, 'hưng', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'canceled', 'Hết hàng', '2025-03-13 10:33:34', '2025-03-13 10:50:27', 'online'),
(45, 1, 'hưng', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 2000.00, 'canceled', 'Hết hàng', '2025-03-13 10:48:41', '2025-03-13 10:50:10', 'online'),
(46, 1, 'john hn', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 6000.00, 'completed', NULL, '2025-03-13 10:52:56', '2025-03-13 11:37:54', 'online'),
(47, 2, 'Giang', '19novemberrr@gmail.com', '0971099604', 'Hà Nội', 10590000.00, 'completed', NULL, '2025-03-13 17:03:51', '2025-03-13 17:09:24', 'online'),
(48, 1, 'hưng', '19novemberrr@gmail.com', '0898657182', 'a', 6000.00, 'canceled', 'Hết hàng', '2025-03-14 17:38:29', '2025-03-14 17:38:41', 'COD'),
(49, 2, 'Nguyễn Thanh Tùng', 'charlotte08@tlshops.luxury', '0989127413', 'a', 6000.00, 'completed', NULL, '2025-03-14 17:50:59', '2025-03-14 17:51:31', 'COD'),
(50, 1, 'admin', 'jericho.terryon@frontbridges.com', '0898657182', 'a', 1000.00, 'pending', NULL, '2025-03-15 09:57:04', '2025-03-15 09:57:04', 'COD');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `quantity`, `price`, `created_at`, `updated_at`) VALUES
(7, 7, 1, 1, 1290000.00, '2025-03-11 15:08:15', '2025-03-11 15:08:15'),
(30, 30, 2, 1, 12490000.00, '2025-03-12 08:10:26', '2025-03-12 08:10:26'),
(32, 32, 1, 1, 1290000.00, '2025-03-12 08:12:28', '2025-03-12 08:12:28'),
(46, 47, 3, 1, 10590000.00, '2025-03-13 17:03:51', '2025-03-13 17:03:51'),
(49, 50, 21, 1, 1000.00, '2025-03-15 09:57:04', '2025-03-15 09:57:04');

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `password_resets`
--

INSERT INTO `password_resets` (`email`, `token`, `created_at`) VALUES
('diachiao1123@gmail.com', '$2y$12$REZ0xpJtOOVR/O9VGN8DfexL4KzxG5qfggo3PQ6gzCa5KL7ZOgxIu', '2025-03-06 09:43:42');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(256) NOT NULL,
  `description` text NOT NULL DEFAULT 'Chưa có mô tả',
  `price` decimal(15,2) NOT NULL,
  `stock` int(11) NOT NULL,
  `category_id` bigint(20) UNSIGNED DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `sold_quantity` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `sold_quantity`, `created_at`, `updated_at`) VALUES
(1, 'Bộ vi xử lý AMD Athlon 3000G / 3.5GHz / 2 nhân 4 luồng / 5MB / AM4', 'Chưa có mô tả', 1290001.00, 19, 1, 'https://product.hstatic.net/200000722513/product/gearvn-amd-athlon-3000g_9a96ebfbbf3f43c7a61cdba59b00e5b5_fc7e2a8f09b24c55b154d39cf9ce96a7_grande.jpg', 1, '2025-03-08 19:28:37', '2025-03-15 07:09:50'),
(2, 'Bộ vi xử lý Intel Core i9 14900KF / Turbo up to 6.0GHz / 24 Nhân 32 Luồng / 36MB / LGA 1700', 'Chưa có mô tả', 12490000.00, 19, 1, 'https://product.hstatic.net/200000722513/product/n22362-001-rpl-i9kf_png_dd11cb3a2936423f8d4fa159a3061ad1_grande.png', 0, '2025-03-09 10:04:04', '2025-03-12 08:10:26'),
(3, 'Bộ vi xử lý AMD Ryzen 9 5950X / 3.4GHz Boost 4.9GHz / 16 nhân 32 luồng / 64MB / AM4', 'Chưa có mô tả', 10590000.00, 4, 1, 'https://product.hstatic.net/200000722513/product/-4ghz-boost-4-9ghz-16-nhan-32-luong-0_37079f5643be41e890c8536c970de2bf_4273966e3e2647daa11b1121b4d6d798_grande.jpg', 1, '2025-03-09 10:10:44', '2025-03-13 17:09:24'),
(5, 'Bộ vi xử lý AMD Ryzen Threadripper Pro 3955WX / 3.9GHz Boost 4.3GHz / 16 nhân 32 luồng / 64MB / sWRX8', 'Chưa có mô tả', 29890000.00, 20, 1, 'https://product.hstatic.net/200000722513/product/-amd-ryzen-threadripper-pro-3955wx-1s_56d0a61cbd6e468e8ed6166c911b9851_71adb9b0d1b04b3097825dbd5f15ca1b_grande.png', 0, '2025-03-14 09:33:54', '2025-03-14 09:33:54'),
(6, 'Bộ vi xử lý Intel Core i3 13100F / 3.4GHz Turbo 4.5GHz / 4 Nhân 8 Luồng / 12MB / LGA 1700', 'Chưa có mô tả', 3090000.00, 20, 1, 'https://product.hstatic.net/200000722513/product/13100f_b27fcb29892e4ec29981a79190289db0_3647022852e94b4c8303d3572b81ba41_grande.png', 0, '2025-03-14 09:39:14', '2025-03-14 09:39:14'),
(7, 'Card màn hình MSI GeForce RTX 4060 Ti VENTUS 2X BLACK 8G OC', 'Chưa có mô tả', 13490000.00, 15, 4, 'https://product.hstatic.net/200000722513/product/rtx_4060_ti_ventus_2x_black_8g_oc_a58f8c2f1e184e28b4554bf82a8b1ee7_grande.png', 0, '2025-03-14 09:46:27', '2025-03-14 09:46:27'),
(8, 'Card màn hình ASUS Dual GeForce RTX 3050 V2 OC Edition 8GB (DUAL-RTX3050-O8G-V2)', 'Chưa có mô tả', 5990000.00, 15, 4, 'https://product.hstatic.net/200000722513/product/8630_f7c417951e38d4d7e8f4856ea0f805d0_f0f3c1fd00a5423495c83ebd8b474050_29a08ad9f50d4b908e71cb6bdf11d3ad_grande.jpg', 0, '2025-03-14 09:47:25', '2025-03-14 09:47:25'),
(9, 'Card màn hình Leadtek NVIDIA QUADRO RTX A6000 48GB GDDR6 ECC', 'Chưa có mô tả', 150990000.00, 5, 4, 'https://product.hstatic.net/200000722513/product/1_a0ea3102d45f49f98f28a6d610c99f42_f3f5f687e9da4e04b6955353df2b96c5_grande.jpg', 0, '2025-03-14 09:49:04', '2025-03-14 09:49:04'),
(10, 'Card màn hình GIGABYTE Radeon RX 6600 EAGLE 8G (GV-R66EAGLE-8GD)', 'Chưa có mô tả', 5590000.00, 10, 4, 'https://product.hstatic.net/200000722513/product/radeon__rx_6600_eagle_8g-08_c3a4bfb8ba514f3a9d6f8c5edeb0d756_f9670f99867949fdb1658a2d9ca06bf7_grande.png', 0, '2025-03-14 09:49:47', '2025-03-14 09:49:47'),
(11, 'Card màn hình GIGABYTE GeForce RTX 4060 EAGLE OC 8G', 'Chưa có mô tả', 9390000.00, 10, 4, 'https://product.hstatic.net/200000722513/product/z4467044485040_9a09deef236a05de8179abdccd40f035_fd7e141a0a0a4464b78e0adf591b21c2_grande.jpg', 0, '2025-03-14 09:50:17', '2025-03-14 09:50:17'),
(12, 'RAM Corsair Dominator Titanium White 64GB (2x32GB) RGB 6600 DDR5 (CMP64GX5M2X6600C32W)', 'Chưa có mô tả', 9290000.00, 10, 2, 'https://product.hstatic.net/200000722513/product/dominator_titanium_rgb_ddr5_whit_ada5b98eea53441486b7bbecf785b4ce_grande.png', 0, '2025-03-14 11:10:34', '2025-03-14 11:10:34'),
(13, 'RAM Corsair Dominator Titanium White 32GB (2x16GB) RGB 7200 DDR5 (CMP32GX5M2X7200C34W)', 'Chưa có mô tả', 6190000.00, 10, 2, 'https://product.hstatic.net/200000722513/product/gearvn-ram-corsair-dominator-titanium-white_32gb-rgb-7200-ddr5-2_34aa0c56224e4147bbe5390397d16270_grande.png', 0, '2025-03-14 11:11:17', '2025-03-14 11:11:17'),
(14, 'RAM Corsair Dominator Titanium Black 32GB (2x16GB) RGB 6000 DDR5 (CMP32GX5M2B6000C30)', 'Chưa có mô tả', 5590000.00, 10, 2, 'https://product.hstatic.net/200000722513/product/dominator_titanium_rgb_black_render_07_0c54d733c3994b84acca6255bb9da961_grande.png', 0, '2025-03-14 11:12:11', '2025-03-14 11:12:11'),
(15, 'RAM Corsair Dominator Titanium White 32GB (2x16GB) RGB 6000 DDR5 (CMP32GX5M2B6000C30W)', 'Chưa có mô tả', 5890000.00, 10, 2, 'https://product.hstatic.net/200000722513/product/dominator_titanium_rgb_white_render_07_be238662082b4045b4cf3cb9ee4ef75c_grande.png', 0, '2025-03-14 11:12:32', '2025-03-14 11:12:32'),
(16, 'Bo mạch chủ ASUS TUF GAMING X570-PLUS WI-FI', 'Chưa có mô tả', 5590000.00, 10, 3, 'https://product.hstatic.net/200000722513/product/gearvn-tuf-gamingx570-plus-wifi-1_585ea00e534b4e5a90503720d9ef38e0_ea9c09adc7de4ccfad68fd21a0b077d1_grande.jpg', 0, '2025-03-14 11:15:32', '2025-03-14 11:15:32'),
(21, 'test thanh toán', 'Chưa có mô tả', 1000.00, 10, 3, NULL, 0, '2025-03-15 07:12:37', '2025-03-15 09:57:04');

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` between 1 and 5),
  `comment` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`id`, `product_id`, `user_id`, `rating`, `comment`, `created_at`, `updated_at`) VALUES
(3, 9, 1, 5, 'tuyệt', '2025-03-14 11:23:40', '2025-03-14 11:23:40'),
(4, 9, 1, 5, 'ok', '2025-03-14 11:25:42', '2025-03-14 11:25:42'),
(7, 21, 1, 5, 'còn hàng không ạ', '2025-03-15 08:56:19', '2025-03-15 08:56:19');

-- --------------------------------------------------------

--
-- Table structure for table `review_replies`
--

CREATE TABLE `review_replies` (
  `id` int(11) NOT NULL,
  `review_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `reply_content` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `statistics`
--

CREATE TABLE `statistics` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `report_date` date NOT NULL,
  `report_month` int(11) NOT NULL,
  `report_year` int(11) NOT NULL,
  `total_revenue` decimal(10,2) NOT NULL DEFAULT 0.00,
  `total_orders` int(11) NOT NULL DEFAULT 0,
  `completed_orders` int(11) DEFAULT 0,
  `canceled_orders` int(11) DEFAULT 0,
  `total_products_sold` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `statistics`
--

INSERT INTO `statistics` (`id`, `report_date`, `report_month`, `report_year`, `total_revenue`, `total_orders`, `completed_orders`, `canceled_orders`, `total_products_sold`, `created_at`, `updated_at`) VALUES
(1, '2025-03-11', 3, 2025, 10000000.00, 50, 45, 5, 150, '2025-03-11 10:41:41', '2025-03-11 10:41:41');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `username` varchar(50) NOT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','customer') NOT NULL DEFAULT 'customer',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `full_name`, `email`, `password`, `role`, `created_at`, `updated_at`) VALUES
(1, 'admin', 'admin', 'admin@gmail.com', '$2y$12$ZjKf4OlA5.MQ5DJo9ZdrJ.SqdY70gpe8rr9vHrzSh0Z5gdYw1g4uy', 'admin', '2025-03-05 04:50:38', '2025-03-05 04:50:38'),
(2, 'nth', 'nth', 'nth@gmail.com', '$2y$12$IyBVJTPdaIFpcT1M0.76l.C2ndjtvxQKtC7KjT0guM1ON9vOwmlS.', 'customer', '2025-03-05 08:26:21', '2025-03-06 08:56:00'),
(4, 'test1', NULL, 'diachiao1123@gmail.com', '$2y$12$rCk.pEZgVGo0TEwyyujqk.25JVKk.g0pnDeiwdZETWQKM0rxi53Qy', 'customer', '2025-03-06 09:30:22', '2025-03-06 09:30:22'),
(5, 'nthboy', 'nthboy', '19novemberrr@gmail.com', '$2y$12$66C3Xo64/N6P5L/V1e8a3OMyvHqbFODJKvH6tLcEeo9glpG5Gg6Tu', 'customer', '2025-03-06 09:45:20', '2025-03-06 18:32:32'),
(7, 'test11', 'DDoo', 'awdasd@gmail.com', '$2y$12$n5E8lOMuWpHD2l4u0pZ4iOKrPTcgr7uh0oXA1oGwwMAEBXHn/vz0q', 'customer', '2025-03-15 09:45:26', '2025-03-15 09:45:26');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cart_user_id_foreign` (`user_id`),
  ADD KEY `cart_product_id_foreign` (`product_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `categories_name_unique` (`name`),
  ADD UNIQUE KEY `categories_slug_unique` (`slug`);

--
-- Indexes for table `homepage_sections`
--
ALTER TABLE `homepage_sections`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orders_user_id_foreign` (`user_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_order` (`order_id`),
  ADD KEY `fk_product` (`product_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `products_category_id_foreign` (`category_id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `review_replies`
--
ALTER TABLE `review_replies`
  ADD PRIMARY KEY (`id`),
  ADD KEY `review_id` (`review_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `statistics`
--
ALTER TABLE `statistics`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_username_unique` (`username`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cart`
--
ALTER TABLE `cart`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `homepage_sections`
--
ALTER TABLE `homepage_sections`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `review_replies`
--
ALTER TABLE `review_replies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `statistics`
--
ALTER TABLE `statistics`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cart`
--
ALTER TABLE `cart`
  ADD CONSTRAINT `cart_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `homepage_sections`
--
ALTER TABLE `homepage_sections`
  ADD CONSTRAINT `homepage_sections_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `fk_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `review_replies`
--
ALTER TABLE `review_replies`
  ADD CONSTRAINT `review_replies_ibfk_1` FOREIGN KEY (`review_id`) REFERENCES `reviews` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `review_replies_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
