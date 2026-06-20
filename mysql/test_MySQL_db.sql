/*
 Navicat MySQL Data Transfer

 Source Server         : k8s_mysql_port_30306_copy
 Source Server Type    : MySQL
 Source Server Version : 80403
 Source Host           : localhost
 Source Database       : test_MySQL_db

 Target Server Type    : MySQL
 Target Server Version : 80403
 File Encoding         : utf-8

 Date: 06/21/2026 01:06:59 AM
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `employees_tbl`
-- ----------------------------
CREATE TABLE IF NOT EXISTS `employees_tbl` (
  `emp_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  PRIMARY KEY (`emp_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SET FOREIGN_KEY_CHECKS = 1;

