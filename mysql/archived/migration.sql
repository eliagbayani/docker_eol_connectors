/*
 Navicat MySQL Data Transfer

 Source Server         : docker_mysql_port_4001
 Source Server Type    : MySQL
 Source Server Version : 80403
 Source Host           : localhost
 Source Database       : Employees

 Target Server Type    : MySQL
 Target Server Version : 80403
 File Encoding         : utf-8

 Date: 11/27/2024 00:18:54 AM
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `employees_tbl`
-- ----------------------------
DROP TABLE IF EXISTS `employees_tbl`;
CREATE TABLE `employees_tbl` (
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `emp_id` int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`emp_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
--  Records of `employees_tbl`
-- ----------------------------
BEGIN;
INSERT INTO `employees_tbl` VALUES ('Jen', 'Hammock', '1'), ('Katja', 'Schulz', '2'), ('Jeremy', 'Rice', '3'), ('Eli', 'Agbayani', '4');
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
