-- MySQL dump 10.13  Distrib 5.7.44, for Linux (x86_64)
--
-- Host: localhost    Database: eol_production
-- ------------------------------------------------------
-- Server version	5.7.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `agent_roles`
--

DROP TABLE IF EXISTS `agent_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agent_roles` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Identifies how agent is linked to data_object';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_roles`
--

LOCK TABLES `agent_roles` WRITE;
/*!40000 ALTER TABLE `agent_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agents`
--

DROP TABLE IF EXISTS `agents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agents` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `full_name` text NOT NULL,
  `given_name` varchar(255) DEFAULT NULL,
  `family_name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `homepage` text NOT NULL,
  `logo_url` varchar(255) CHARACTER SET ascii DEFAULT NULL,
  `logo_cache_url` bigint(20) unsigned DEFAULT NULL,
  `project` varchar(255) DEFAULT NULL,
  `organization` varchar(255) DEFAULT NULL,
  `account_name` varchar(255) DEFAULT NULL,
  `openid` varchar(255) DEFAULT NULL,
  `yahoo_id` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `full_name` (`full_name`(200))
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Agents are content partners and used for object attribution';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agents`
--

LOCK TABLES `agents` WRITE;
/*!40000 ALTER TABLE `agents` DISABLE KEYS */;
/*!40000 ALTER TABLE `agents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agents_data_objects`
--

DROP TABLE IF EXISTS `agents_data_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agents_data_objects` (
  `data_object_id` int(10) unsigned NOT NULL,
  `agent_id` int(10) unsigned NOT NULL,
  `agent_role_id` tinyint(3) unsigned NOT NULL,
  `view_order` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`data_object_id`,`agent_id`,`agent_role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Agents are associated with data objects in various roles';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agents_data_objects`
--

LOCK TABLES `agents_data_objects` WRITE;
/*!40000 ALTER TABLE `agents_data_objects` DISABLE KEYS */;
/*!40000 ALTER TABLE `agents_data_objects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agents_hierarchy_entries`
--

DROP TABLE IF EXISTS `agents_hierarchy_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agents_hierarchy_entries` (
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `agent_id` int(10) unsigned NOT NULL,
  `agent_role_id` tinyint(3) unsigned NOT NULL,
  `view_order` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`hierarchy_entry_id`,`agent_id`,`agent_role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Agents are associated with hierarchy entries in various role';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agents_hierarchy_entries`
--

LOCK TABLES `agents_hierarchy_entries` WRITE;
/*!40000 ALTER TABLE `agents_hierarchy_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `agents_hierarchy_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agents_synonyms`
--

DROP TABLE IF EXISTS `agents_synonyms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agents_synonyms` (
  `synonym_id` int(10) unsigned NOT NULL,
  `agent_id` int(10) unsigned NOT NULL,
  `agent_role_id` tinyint(3) unsigned NOT NULL,
  `view_order` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`synonym_id`,`agent_id`,`agent_role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Agents are associated with synonyms in various roles';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agents_synonyms`
--

LOCK TABLES `agents_synonyms` WRITE;
/*!40000 ALTER TABLE `agents_synonyms` DISABLE KEYS */;
/*!40000 ALTER TABLE `agents_synonyms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audiences`
--

DROP TABLE IF EXISTS `audiences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audiences` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Controlled list for determining the "expertise" of a data ob';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audiences`
--

LOCK TABLES `audiences` WRITE;
/*!40000 ALTER TABLE `audiences` DISABLE KEYS */;
/*!40000 ALTER TABLE `audiences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audiences_data_objects`
--

DROP TABLE IF EXISTS `audiences_data_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audiences_data_objects` (
  `data_object_id` int(10) unsigned NOT NULL,
  `audience_id` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`data_object_id`,`audience_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='A data object can have zero to many target audiences';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audiences_data_objects`
--

LOCK TABLES `audiences_data_objects` WRITE;
/*!40000 ALTER TABLE `audiences_data_objects` DISABLE KEYS */;
/*!40000 ALTER TABLE `audiences_data_objects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `canonical_forms`
--

DROP TABLE IF EXISTS `canonical_forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `canonical_forms` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `string` varchar(300) NOT NULL COMMENT 'a canonical form of a scientific name is the name parts without authorship, rank information, or anthing except the latinized name parts. These are for the most part algorithmically generated',
  `name_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `string` (`string`(255)),
  KEY `index_canonical_forms_on_name_id` (`name_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Every name string has one canonical form - a simplified vers';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `canonical_forms`
--

LOCK TABLES `canonical_forms` WRITE;
/*!40000 ALTER TABLE `canonical_forms` DISABLE KEYS */;
/*!40000 ALTER TABLE `canonical_forms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `changeable_object_types`
--

DROP TABLE IF EXISTS `changeable_object_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `changeable_object_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ch_object_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `changeable_object_types`
--

LOCK TABLES `changeable_object_types` WRITE;
/*!40000 ALTER TABLE `changeable_object_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `changeable_object_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ckeditor_assets`
--

DROP TABLE IF EXISTS `ckeditor_assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ckeditor_assets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data_file_name` varchar(255) NOT NULL,
  `data_content_type` varchar(255) DEFAULT NULL,
  `data_file_size` int(11) DEFAULT NULL,
  `assetable_id` int(11) DEFAULT NULL,
  `assetable_type` varchar(30) DEFAULT NULL,
  `type` varchar(30) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ckeditor_assetable_type` (`assetable_type`,`type`,`assetable_id`),
  KEY `idx_ckeditor_assetable` (`assetable_type`,`assetable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ckeditor_assets`
--

LOCK TABLES `ckeditor_assets` WRITE;
/*!40000 ALTER TABLE `ckeditor_assets` DISABLE KEYS */;
/*!40000 ALTER TABLE `ckeditor_assets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classification_curations`
--

DROP TABLE IF EXISTS `classification_curations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classification_curations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `exemplar_id` int(11) DEFAULT NULL,
  `source_id` int(11) NOT NULL,
  `target_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `forced` tinyint(1) DEFAULT NULL,
  `error` varchar(256) DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classification_curations`
--

LOCK TABLES `classification_curations` WRITE;
/*!40000 ALTER TABLE `classification_curations` DISABLE KEYS */;
/*!40000 ALTER TABLE `classification_curations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `collection_items`
--

DROP TABLE IF EXISTS `collection_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collection_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `collected_item_type` varchar(32) DEFAULT NULL,
  `collected_item_id` int(11) DEFAULT NULL,
  `collection_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `annotation` text,
  `added_by_user_id` int(11) unsigned DEFAULT NULL,
  `sort_field` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `collection_id_object_type_object_id` (`collection_id`,`collected_item_type`,`collected_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `collection_items`
--

LOCK TABLES `collection_items` WRITE;
/*!40000 ALTER TABLE `collection_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `collection_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `collection_items_collection_jobs`
--

DROP TABLE IF EXISTS `collection_items_collection_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collection_items_collection_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collection_item_id` int(11) NOT NULL,
  `collection_job_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `join_index` (`collection_item_id`,`collection_job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `collection_items_collection_jobs`
--

LOCK TABLES `collection_items_collection_jobs` WRITE;
/*!40000 ALTER TABLE `collection_items_collection_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `collection_items_collection_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `collection_items_refs`
--

DROP TABLE IF EXISTS `collection_items_refs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collection_items_refs` (
  `collection_item_id` int(11) NOT NULL,
  `ref_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `collection_items_refs`
--

LOCK TABLES `collection_items_refs` WRITE;
/*!40000 ALTER TABLE `collection_items_refs` DISABLE KEYS */;
/*!40000 ALTER TABLE `collection_items_refs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `collection_jobs`
--

DROP TABLE IF EXISTS `collection_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collection_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `command` varchar(8) NOT NULL,
  `user_id` int(11) NOT NULL,
  `collection_id` int(11) NOT NULL,
  `item_count` int(11) DEFAULT NULL,
  `all_items` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `finished_at` datetime DEFAULT NULL,
  `overwrite` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `collection_jobs`
--

LOCK TABLES `collection_jobs` WRITE;
/*!40000 ALTER TABLE `collection_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `collection_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `collection_jobs_collections`
--

DROP TABLE IF EXISTS `collection_jobs_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collection_jobs_collections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collection_id` int(11) DEFAULT NULL,
  `collection_job_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `collection_jobs_collections_index` (`collection_id`,`collection_job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `collection_jobs_collections`
--

LOCK TABLES `collection_jobs_collections` WRITE;
/*!40000 ALTER TABLE `collection_jobs_collections` DISABLE KEYS */;
/*!40000 ALTER TABLE `collection_jobs_collections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `collection_types`
--

DROP TABLE IF EXISTS `collection_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collection_types` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) NOT NULL,
  `lft` smallint(5) unsigned DEFAULT NULL,
  `rgt` smallint(5) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_id` (`parent_id`),
  KEY `lft` (`lft`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `collection_types`
--

LOCK TABLES `collection_types` WRITE;
/*!40000 ALTER TABLE `collection_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `collection_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `collection_types_collections`
--

DROP TABLE IF EXISTS `collection_types_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collection_types_collections` (
  `collection_type_id` smallint(5) unsigned NOT NULL,
  `collection_id` mediumint(8) unsigned NOT NULL,
  PRIMARY KEY (`collection_type_id`,`collection_id`),
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `collection_types_collections`
--

LOCK TABLES `collection_types_collections` WRITE;
/*!40000 ALTER TABLE `collection_types_collections` DISABLE KEYS */;
/*!40000 ALTER TABLE `collection_types_collections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `collection_types_hierarchies`
--

DROP TABLE IF EXISTS `collection_types_hierarchies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collection_types_hierarchies` (
  `collection_type_id` smallint(5) unsigned NOT NULL,
  `hierarchy_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`collection_type_id`,`hierarchy_id`),
  KEY `collection_id` (`hierarchy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `collection_types_hierarchies`
--

LOCK TABLES `collection_types_hierarchies` WRITE;
/*!40000 ALTER TABLE `collection_types_hierarchies` DISABLE KEYS */;
/*!40000 ALTER TABLE `collection_types_hierarchies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `collections`
--

DROP TABLE IF EXISTS `collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `special_collection_id` int(11) DEFAULT NULL,
  `published` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `logo_cache_url` bigint(20) unsigned DEFAULT NULL,
  `logo_file_name` varchar(255) DEFAULT NULL,
  `logo_content_type` varchar(255) DEFAULT NULL,
  `logo_file_size` int(10) unsigned DEFAULT '0',
  `description` text,
  `sort_style_id` int(11) DEFAULT NULL,
  `relevance` tinyint(4) DEFAULT '1',
  `view_style_id` int(11) DEFAULT NULL,
  `show_references` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `collections`
--

LOCK TABLES `collections` WRITE;
/*!40000 ALTER TABLE `collections` DISABLE KEYS */;
INSERT INTO `collections` VALUES (1,'1',NULL,0,NULL,'2013-09-16 00:57:48',NULL,NULL,NULL,0,'Last indexed September 16, 2013',NULL,1,NULL,1);
/*!40000 ALTER TABLE `collections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `collections_communities`
--

DROP TABLE IF EXISTS `collections_communities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collections_communities` (
  `collection_id` int(11) DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `collections_communities`
--

LOCK TABLES `collections_communities` WRITE;
/*!40000 ALTER TABLE `collections_communities` DISABLE KEYS */;
/*!40000 ALTER TABLE `collections_communities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `collections_users`
--

DROP TABLE IF EXISTS `collections_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collections_users` (
  `collection_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `collections_users`
--

LOCK TABLES `collections_users` WRITE;
/*!40000 ALTER TABLE `collections_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `collections_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `parent_id` int(11) NOT NULL,
  `parent_type` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `visible_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `from_curator` tinyint(1) NOT NULL,
  `hidden` tinyint(4) DEFAULT '0',
  `reply_to_type` varchar(32) DEFAULT NULL,
  `reply_to_id` int(11) DEFAULT NULL,
  `deleted` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_comments_on_parent_id` (`parent_id`),
  KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communities`
--

DROP TABLE IF EXISTS `communities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) DEFAULT NULL,
  `description` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `logo_cache_url` bigint(20) unsigned DEFAULT NULL,
  `logo_file_name` varchar(255) DEFAULT NULL,
  `logo_content_type` varchar(255) DEFAULT NULL,
  `logo_file_size` int(10) unsigned DEFAULT '0',
  `published` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communities`
--

LOCK TABLES `communities` WRITE;
/*!40000 ALTER TABLE `communities` DISABLE KEYS */;
/*!40000 ALTER TABLE `communities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_roles`
--

DROP TABLE IF EXISTS `contact_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_roles` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='For content partner agent_contacts';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_roles`
--

LOCK TABLES `contact_roles` WRITE;
/*!40000 ALTER TABLE `contact_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `contact_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_subjects`
--

DROP TABLE IF EXISTS `contact_subjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_subjects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recipients` varchar(255) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_subjects`
--

LOCK TABLES `contact_subjects` WRITE;
/*!40000 ALTER TABLE `contact_subjects` DISABLE KEYS */;
/*!40000 ALTER TABLE `contact_subjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contacts`
--

DROP TABLE IF EXISTS `contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_subject_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `comments` text,
  `ip_address` varchar(255) DEFAULT NULL,
  `referred_page` varchar(255) DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `taxon_group` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contacts`
--

LOCK TABLES `contacts` WRITE;
/*!40000 ALTER TABLE `contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_page_archives`
--

DROP TABLE IF EXISTS `content_page_archives`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_page_archives` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content_page_id` int(11) DEFAULT NULL,
  `page_name` varchar(255) NOT NULL DEFAULT '',
  `content_section_id` int(11) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT '1',
  `original_creation_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `open_in_new_window` tinyint(1) DEFAULT '0',
  `last_update_user_id` int(11) NOT NULL DEFAULT '2',
  `parent_content_page_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_page_archives`
--

LOCK TABLES `content_page_archives` WRITE;
/*!40000 ALTER TABLE `content_page_archives` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_page_archives` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_pages`
--

DROP TABLE IF EXISTS `content_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `page_name` varchar(255) NOT NULL DEFAULT '',
  `sort_order` int(11) NOT NULL DEFAULT '1',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `open_in_new_window` tinyint(1) DEFAULT '0',
  `last_update_user_id` int(11) NOT NULL DEFAULT '2',
  `parent_content_page_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `section_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_pages`
--

LOCK TABLES `content_pages` WRITE;
/*!40000 ALTER TABLE `content_pages` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_partner_agreements`
--

DROP TABLE IF EXISTS `content_partner_agreements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_partner_agreements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content_partner_id` int(10) unsigned NOT NULL,
  `template` text NOT NULL,
  `is_current` tinyint(1) NOT NULL DEFAULT '1',
  `number_of_views` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_viewed` datetime DEFAULT NULL,
  `mou_url` varchar(255) DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `signed_on_date` datetime DEFAULT NULL,
  `signed_by` varchar(255) DEFAULT NULL,
  `body` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_partner_agreements`
--

LOCK TABLES `content_partner_agreements` WRITE;
/*!40000 ALTER TABLE `content_partner_agreements` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_partner_agreements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_partner_contacts`
--

DROP TABLE IF EXISTS `content_partner_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_partner_contacts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `content_partner_id` int(10) unsigned NOT NULL,
  `contact_role_id` tinyint(3) unsigned NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `title` varchar(20) NOT NULL,
  `given_name` varchar(255) NOT NULL,
  `family_name` varchar(255) NOT NULL,
  `homepage` varchar(255) CHARACTER SET ascii NOT NULL,
  `email` varchar(75) NOT NULL,
  `telephone` varchar(30) CHARACTER SET ascii NOT NULL,
  `address` text NOT NULL,
  `email_reports_frequency_hours` int(11) DEFAULT '24',
  `last_report_email` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='For content partners, specifying people to contact (each one';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_partner_contacts`
--

LOCK TABLES `content_partner_contacts` WRITE;
/*!40000 ALTER TABLE `content_partner_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_partner_contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_partner_statuses`
--

DROP TABLE IF EXISTS `content_partner_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_partner_statuses` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_partner_statuses`
--

LOCK TABLES `content_partner_statuses` WRITE;
/*!40000 ALTER TABLE `content_partner_statuses` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_partner_statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_partners`
--

DROP TABLE IF EXISTS `content_partners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_partners` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `content_partner_status_id` tinyint(4) NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `full_name` text,
  `display_name` varchar(255) DEFAULT NULL,
  `acronym` varchar(20) DEFAULT NULL,
  `homepage` varchar(255) DEFAULT NULL,
  `description_of_data` text,
  `description` text NOT NULL,
  `notes` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `public` tinyint(1) NOT NULL DEFAULT '0',
  `admin_notes` text,
  `logo_cache_url` bigint(20) unsigned DEFAULT NULL,
  `logo_file_name` varchar(255) DEFAULT NULL,
  `logo_content_type` varchar(255) DEFAULT NULL,
  `logo_file_size` int(10) unsigned DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_partners`
--

LOCK TABLES `content_partners` WRITE;
/*!40000 ALTER TABLE `content_partners` DISABLE KEYS */;
INSERT INTO `content_partners` VALUES (1,0,0,NULL,NULL,NULL,NULL,NULL,'','','2014-08-21 03:59:57','0000-00-00 00:00:00',0,NULL,NULL,NULL,NULL,0),(2,0,0,'Biodiversity Heritage Library',NULL,NULL,NULL,NULL,'','','2014-11-03 01:48:17','0000-00-00 00:00:00',0,NULL,NULL,NULL,NULL,0),(3,0,0,'Catalogue of Life',NULL,NULL,NULL,NULL,'','','2014-11-03 01:48:17','0000-00-00 00:00:00',0,NULL,NULL,NULL,NULL,0);
/*!40000 ALTER TABLE `content_partners` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_table_items`
--

DROP TABLE IF EXISTS `content_table_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_table_items` (
  `content_table_id` int(11) NOT NULL,
  `toc_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_table_items`
--

LOCK TABLES `content_table_items` WRITE;
/*!40000 ALTER TABLE `content_table_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_table_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_tables`
--

DROP TABLE IF EXISTS `content_tables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_tables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_tables`
--

LOCK TABLES `content_tables` WRITE;
/*!40000 ALTER TABLE `content_tables` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_tables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_uploads`
--

DROP TABLE IF EXISTS `content_uploads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content_uploads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(100) DEFAULT NULL,
  `link_name` varchar(70) DEFAULT NULL,
  `attachment_cache_url` bigint(20) DEFAULT NULL,
  `attachment_extension` varchar(10) DEFAULT NULL,
  `attachment_content_type` varchar(255) DEFAULT NULL,
  `attachment_file_name` varchar(255) DEFAULT NULL,
  `attachment_file_size` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_uploads`
--

LOCK TABLES `content_uploads` WRITE;
/*!40000 ALTER TABLE `content_uploads` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_uploads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `curated_data_objects_hierarchy_entries`
--

DROP TABLE IF EXISTS `curated_data_objects_hierarchy_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `curated_data_objects_hierarchy_entries` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `data_object_id` int(10) unsigned NOT NULL,
  `data_object_guid` varchar(32) NOT NULL,
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `vetted_id` int(11) NOT NULL,
  `visibility_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `data_object_id` (`data_object_id`),
  KEY `data_object_id_hierarchy_entry_id` (`data_object_id`,`hierarchy_entry_id`),
  KEY `index_curated_data_objects_hierarchy_entries_on_data_object_guid` (`data_object_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `curated_data_objects_hierarchy_entries`
--

LOCK TABLES `curated_data_objects_hierarchy_entries` WRITE;
/*!40000 ALTER TABLE `curated_data_objects_hierarchy_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `curated_data_objects_hierarchy_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `curated_hierarchy_entry_relationships`
--

DROP TABLE IF EXISTS `curated_hierarchy_entry_relationships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `curated_hierarchy_entry_relationships` (
  `hierarchy_entry_id_1` int(10) unsigned NOT NULL,
  `hierarchy_entry_id_2` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned DEFAULT NULL,
  `equivalent` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`hierarchy_entry_id_1`,`hierarchy_entry_id_2`),
  KEY `hierarchy_entry_id_2` (`hierarchy_entry_id_2`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `curated_hierarchy_entry_relationships`
--

LOCK TABLES `curated_hierarchy_entry_relationships` WRITE;
/*!40000 ALTER TABLE `curated_hierarchy_entry_relationships` DISABLE KEYS */;
/*!40000 ALTER TABLE `curated_hierarchy_entry_relationships` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `curated_taxon_concept_preferred_entries`
--

DROP TABLE IF EXISTS `curated_taxon_concept_preferred_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `curated_taxon_concept_preferred_entries` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `taxon_concept_id` (`taxon_concept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `curated_taxon_concept_preferred_entries`
--

LOCK TABLES `curated_taxon_concept_preferred_entries` WRITE;
/*!40000 ALTER TABLE `curated_taxon_concept_preferred_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `curated_taxon_concept_preferred_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `curator_activity_logs_untrust_reasons`
--

DROP TABLE IF EXISTS `curator_activity_logs_untrust_reasons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `curator_activity_logs_untrust_reasons` (
  `curator_activity_log_id` int(11) NOT NULL,
  `untrust_reason_id` int(11) NOT NULL,
  PRIMARY KEY (`curator_activity_log_id`,`untrust_reason_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `curator_activity_logs_untrust_reasons`
--

LOCK TABLES `curator_activity_logs_untrust_reasons` WRITE;
/*!40000 ALTER TABLE `curator_activity_logs_untrust_reasons` DISABLE KEYS */;
/*!40000 ALTER TABLE `curator_activity_logs_untrust_reasons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `curator_levels`
--

DROP TABLE IF EXISTS `curator_levels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `curator_levels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) NOT NULL,
  `rating_weight` int(11) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `curator_levels`
--

LOCK TABLES `curator_levels` WRITE;
/*!40000 ALTER TABLE `curator_levels` DISABLE KEYS */;
/*!40000 ALTER TABLE `curator_levels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_object_data_object_tags`
--

DROP TABLE IF EXISTS `data_object_data_object_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_object_data_object_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data_object_id` int(11) NOT NULL,
  `data_object_tag_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `data_object_guid` varchar(32) CHARACTER SET ascii NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_data_object_data_object_tags_1` (`data_object_guid`,`data_object_tag_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_object_data_object_tags`
--

LOCK TABLES `data_object_data_object_tags` WRITE;
/*!40000 ALTER TABLE `data_object_data_object_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_object_data_object_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_object_tags`
--

DROP TABLE IF EXISTS `data_object_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_object_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  `is_public` tinyint(1) DEFAULT NULL,
  `total_usage_count` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_object_tags`
--

LOCK TABLES `data_object_tags` WRITE;
/*!40000 ALTER TABLE `data_object_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_object_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_object_translations`
--

DROP TABLE IF EXISTS `data_object_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_object_translations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `data_object_id` int(10) unsigned NOT NULL,
  `original_data_object_id` int(10) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `data_object_id` (`data_object_id`),
  KEY `original_data_object_id` (`original_data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_object_translations`
--

LOCK TABLES `data_object_translations` WRITE;
/*!40000 ALTER TABLE `data_object_translations` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_object_translations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_objects`
--

DROP TABLE IF EXISTS `data_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_objects` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `guid` varchar(32) CHARACTER SET ascii NOT NULL COMMENT 'this guid is generated by EOL. A 32 character hexadecimal',
  `identifier` varchar(255) DEFAULT NULL,
  `provider_mangaed_id` varchar(255) DEFAULT NULL,
  `data_type_id` smallint(5) unsigned NOT NULL,
  `data_subtype_id` smallint(5) unsigned DEFAULT NULL,
  `mime_type_id` smallint(5) unsigned NOT NULL,
  `object_title` varchar(255) NOT NULL COMMENT 'a string title for the object. Generally not used for images',
  `language_id` smallint(5) unsigned NOT NULL,
  `metadata_language_id` smallint(5) unsigned DEFAULT NULL,
  `license_id` tinyint(3) unsigned NOT NULL,
  `rights_statement` varchar(300) NOT NULL COMMENT 'a brief statement of the copyright protection for this object',
  `rights_holder` text NOT NULL COMMENT 'a string stating the owner of copyright for this object',
  `bibliographic_citation` text NOT NULL,
  `source_url` text COMMENT 'a url where users are to be redirected to learn more about this data object',
  `description` mediumtext NOT NULL,
  `description_linked` mediumtext,
  `object_url` text COMMENT 'recommended; the url which resolves to this data object. Generally used only for images, video, and other multimedia',
  `object_cache_url` bigint(20) unsigned DEFAULT NULL COMMENT 'an integer representation of the EOL local cache of the object. For example, a value may be 200902090812345 - that will be split by middleware into the parts 2009/02/09/08/12345 which represents the storage directory structure. The directory structure rep',
  `thumbnail_url` varchar(255) CHARACTER SET ascii NOT NULL COMMENT 'not required; the url which resolves to a thumbnail representation of this object. Generally used only for images, video, and other multimedia',
  `thumbnail_cache_url` bigint(20) unsigned DEFAULT NULL COMMENT 'an integer representation of the EOL local cache of the thumbnail',
  `location` varchar(255) NOT NULL,
  `latitude` double NOT NULL COMMENT 'the latitude at which the object was first collected/captured. We have no standard way of represdenting this. Usually measured in decimal values, but could also be degrees',
  `longitude` double NOT NULL COMMENT 'the longitude at which the object was first collected/captured',
  `altitude` double NOT NULL COMMENT 'the altitude at which the object was first collected/captured',
  `object_created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'date when the object was originally created. Information contained within the resource',
  `object_modified_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'date when the object was last modified. Information contained within the resource',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'date when the object was added to the EOL index',
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'date when the object was last modified within the EOL index. This should pretty much always equal the created_at date, therefore is likely not necessary',
  `available_at` timestamp NULL DEFAULT NULL,
  `data_rating` float NOT NULL DEFAULT '2.5',
  `published` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'required; boolean; set to 1 if the object is currently published',
  `curated` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'required; boolean; set to 1 if the object has ever been curated',
  `derived_from` text,
  `spatial_location` text,
  PRIMARY KEY (`id`),
  KEY `data_type_id` (`data_type_id`),
  KEY `index_data_objects_on_guid` (`guid`),
  KEY `index_data_objects_on_published` (`published`),
  KEY `created_at` (`created_at`),
  KEY `identifier` (`identifier`),
  KEY `object_url` (`object_url`(255))
) ENGINE=InnoDB AUTO_INCREMENT=175 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_objects`
--

LOCK TABLES `data_objects` WRITE;
/*!40000 ALTER TABLE `data_objects` DISABLE KEYS */;
INSERT INTO `data_objects` VALUES (173,'',NULL,NULL,0,NULL,0,'',0,NULL,0,'','','',NULL,'',NULL,'http://media.eol.org/content/2011/02/08/14/47197_580_360.jpg',201407220492048,'',NULL,'',0,0,0,'0000-00-00 00:00:00','0000-00-00 00:00:00','2014-07-22 07:48:55','0000-00-00 00:00:00',NULL,2.5,0,0,NULL,NULL),(174,'',NULL,NULL,0,NULL,0,'',0,NULL,0,'','','',NULL,'',NULL,NULL,NULL,'',NULL,'',0,0,0,'0000-00-00 00:00:00','0000-00-00 00:00:00','2014-07-22 07:48:57','0000-00-00 00:00:00',NULL,2.5,0,0,NULL,NULL);
/*!40000 ALTER TABLE `data_objects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_objects_harvest_events`
--

DROP TABLE IF EXISTS `data_objects_harvest_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_objects_harvest_events` (
  `harvest_event_id` int(10) unsigned NOT NULL,
  `data_object_id` int(10) unsigned NOT NULL,
  `guid` varchar(32) CHARACTER SET ascii NOT NULL,
  `status_id` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`harvest_event_id`,`data_object_id`),
  KEY `index_data_objects_harvest_events_on_guid` (`guid`),
  KEY `index_data_objects_harvest_events_on_data_object_id` (`data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_objects_harvest_events`
--

LOCK TABLES `data_objects_harvest_events` WRITE;
/*!40000 ALTER TABLE `data_objects_harvest_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_objects_harvest_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_objects_hierarchy_entries`
--

DROP TABLE IF EXISTS `data_objects_hierarchy_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_objects_hierarchy_entries` (
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `data_object_id` int(10) unsigned NOT NULL,
  `vetted_id` int(11) NOT NULL,
  `visibility_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`hierarchy_entry_id`,`data_object_id`),
  KEY `data_object_id` (`data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_objects_hierarchy_entries`
--

LOCK TABLES `data_objects_hierarchy_entries` WRITE;
/*!40000 ALTER TABLE `data_objects_hierarchy_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_objects_hierarchy_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_objects_info_items`
--

DROP TABLE IF EXISTS `data_objects_info_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_objects_info_items` (
  `data_object_id` int(10) unsigned NOT NULL,
  `info_item_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`data_object_id`,`info_item_id`),
  KEY `info_item_id` (`info_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_objects_info_items`
--

LOCK TABLES `data_objects_info_items` WRITE;
/*!40000 ALTER TABLE `data_objects_info_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_objects_info_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_objects_link_types`
--

DROP TABLE IF EXISTS `data_objects_link_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_objects_link_types` (
  `data_object_id` int(10) unsigned NOT NULL,
  `link_type_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`data_object_id`),
  KEY `data_type_id` (`link_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_objects_link_types`
--

LOCK TABLES `data_objects_link_types` WRITE;
/*!40000 ALTER TABLE `data_objects_link_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_objects_link_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_objects_refs`
--

DROP TABLE IF EXISTS `data_objects_refs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_objects_refs` (
  `data_object_id` int(10) unsigned NOT NULL,
  `ref_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`data_object_id`,`ref_id`),
  KEY `do_id_ref_id` (`data_object_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_objects_refs`
--

LOCK TABLES `data_objects_refs` WRITE;
/*!40000 ALTER TABLE `data_objects_refs` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_objects_refs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_objects_table_of_contents`
--

DROP TABLE IF EXISTS `data_objects_table_of_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_objects_table_of_contents` (
  `data_object_id` int(10) unsigned NOT NULL,
  `toc_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`data_object_id`,`toc_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_objects_table_of_contents`
--

LOCK TABLES `data_objects_table_of_contents` WRITE;
/*!40000 ALTER TABLE `data_objects_table_of_contents` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_objects_table_of_contents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_objects_taxon_concepts`
--

DROP TABLE IF EXISTS `data_objects_taxon_concepts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_objects_taxon_concepts` (
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `data_object_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`taxon_concept_id`,`data_object_id`),
  KEY `data_object_id` (`data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_objects_taxon_concepts`
--

LOCK TABLES `data_objects_taxon_concepts` WRITE;
/*!40000 ALTER TABLE `data_objects_taxon_concepts` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_objects_taxon_concepts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_objects_taxon_concepts_tmp`
--

DROP TABLE IF EXISTS `data_objects_taxon_concepts_tmp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_objects_taxon_concepts_tmp` (
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `data_object_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`taxon_concept_id`,`data_object_id`),
  KEY `data_object_id` (`data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_objects_taxon_concepts_tmp`
--

LOCK TABLES `data_objects_taxon_concepts_tmp` WRITE;
/*!40000 ALTER TABLE `data_objects_taxon_concepts_tmp` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_objects_taxon_concepts_tmp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_types`
--

DROP TABLE IF EXISTS `data_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_types` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `schema_value` varchar(255) CHARACTER SET ascii NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_types`
--

LOCK TABLES `data_types` WRITE;
/*!40000 ALTER TABLE `data_types` DISABLE KEYS */;
INSERT INTO `data_types` VALUES (1,'http://purl.org/dc/dcmitype/Sound'),(2,'http://purl.org/dc/dcmitype/StillImage'),(3,'YouTube'),(4,'Flash'),(5,'http://purl.org/dc/dcmitype/MovingImage'),(6,'Map'),(7,'http://purl.org/dc/dcmitype/Text');
/*!40000 ALTER TABLE `data_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eol_statistics`
--

DROP TABLE IF EXISTS `eol_statistics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `eol_statistics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `members_count` mediumint(9) DEFAULT NULL,
  `communities_count` mediumint(9) DEFAULT NULL,
  `collections_count` mediumint(9) DEFAULT NULL,
  `pages_count` int(11) DEFAULT NULL,
  `pages_with_content` int(11) DEFAULT NULL,
  `pages_with_text` int(11) DEFAULT NULL,
  `pages_with_image` int(11) DEFAULT NULL,
  `pages_with_map` mediumint(9) DEFAULT NULL,
  `pages_with_video` mediumint(9) DEFAULT NULL,
  `pages_with_sound` mediumint(9) DEFAULT NULL,
  `pages_without_text` mediumint(9) DEFAULT NULL,
  `pages_without_image` mediumint(9) DEFAULT NULL,
  `pages_with_image_no_text` mediumint(9) DEFAULT NULL,
  `pages_with_text_no_image` mediumint(9) DEFAULT NULL,
  `base_pages` int(11) DEFAULT NULL,
  `pages_with_at_least_a_trusted_object` int(11) DEFAULT NULL,
  `pages_with_at_least_a_curatorial_action` mediumint(9) DEFAULT NULL,
  `pages_with_BHL_links` mediumint(9) DEFAULT NULL,
  `pages_with_BHL_links_no_text` mediumint(9) DEFAULT NULL,
  `pages_with_BHL_links_only` mediumint(9) DEFAULT NULL,
  `content_partners` mediumint(9) DEFAULT NULL,
  `content_partners_with_published_resources` mediumint(9) DEFAULT NULL,
  `content_partners_with_published_trusted_resources` mediumint(9) DEFAULT NULL,
  `published_resources` mediumint(9) DEFAULT NULL,
  `published_trusted_resources` mediumint(9) DEFAULT NULL,
  `published_unreviewed_resources` mediumint(9) DEFAULT NULL,
  `newly_published_resources_in_the_last_30_days` mediumint(9) DEFAULT NULL,
  `data_objects` int(11) DEFAULT NULL,
  `data_objects_texts` int(11) DEFAULT NULL,
  `data_objects_images` int(11) DEFAULT NULL,
  `data_objects_videos` mediumint(9) DEFAULT NULL,
  `data_objects_sounds` mediumint(9) DEFAULT NULL,
  `data_objects_maps` mediumint(9) DEFAULT NULL,
  `data_objects_trusted` int(11) DEFAULT NULL,
  `data_objects_unreviewed` int(11) DEFAULT NULL,
  `data_objects_untrusted` mediumint(9) DEFAULT NULL,
  `data_objects_trusted_or_unreviewed_but_hidden` mediumint(9) DEFAULT NULL,
  `udo_published` mediumint(9) DEFAULT NULL,
  `udo_published_by_curators` mediumint(9) DEFAULT NULL,
  `udo_published_by_non_curators` mediumint(9) DEFAULT NULL,
  `rich_pages` mediumint(9) DEFAULT NULL,
  `hotlist_pages` mediumint(9) DEFAULT NULL,
  `rich_hotlist_pages` mediumint(9) DEFAULT NULL,
  `redhotlist_pages` mediumint(9) DEFAULT NULL,
  `rich_redhotlist_pages` mediumint(9) DEFAULT NULL,
  `pages_with_score_10_to_39` mediumint(9) DEFAULT NULL,
  `pages_with_score_less_than_10` mediumint(9) DEFAULT NULL,
  `curators` mediumint(9) DEFAULT NULL,
  `curators_assistant` mediumint(9) DEFAULT NULL,
  `curators_full` mediumint(9) DEFAULT NULL,
  `curators_master` mediumint(9) DEFAULT NULL,
  `active_curators` mediumint(9) DEFAULT NULL,
  `pages_curated_by_active_curators` mediumint(9) DEFAULT NULL,
  `objects_curated_in_the_last_30_days` mediumint(9) DEFAULT NULL,
  `curator_actions_in_the_last_30_days` mediumint(9) DEFAULT NULL,
  `lifedesk_taxa` mediumint(9) DEFAULT NULL,
  `lifedesk_data_objects` mediumint(9) DEFAULT NULL,
  `marine_pages` mediumint(9) DEFAULT NULL,
  `marine_pages_in_col` mediumint(9) DEFAULT NULL,
  `marine_pages_with_objects` mediumint(9) DEFAULT NULL,
  `marine_pages_with_objects_vetted` mediumint(9) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT '2013-04-16 12:06:26',
  PRIMARY KEY (`id`),
  KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eol_statistics`
--

LOCK TABLES `eol_statistics` WRITE;
/*!40000 ALTER TABLE `eol_statistics` DISABLE KEYS */;
/*!40000 ALTER TABLE `eol_statistics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `error_logs`
--

DROP TABLE IF EXISTS `error_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `error_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `exception_name` varchar(250) DEFAULT NULL,
  `backtrace` text,
  `url` varchar(250) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_agent` varchar(100) DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_error_logs_on_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `error_logs`
--

LOCK TABLES `error_logs` WRITE;
/*!40000 ALTER TABLE `error_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `error_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feed_data_objects`
--

DROP TABLE IF EXISTS `feed_data_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feed_data_objects` (
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `data_object_id` int(10) unsigned NOT NULL,
  `data_type_id` smallint(5) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`taxon_concept_id`,`data_object_id`),
  KEY `data_object_id` (`data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feed_data_objects`
--

LOCK TABLES `feed_data_objects` WRITE;
/*!40000 ALTER TABLE `feed_data_objects` DISABLE KEYS */;
/*!40000 ALTER TABLE `feed_data_objects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feed_item_types`
--

DROP TABLE IF EXISTS `feed_item_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feed_item_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feed_item_types`
--

LOCK TABLES `feed_item_types` WRITE;
/*!40000 ALTER TABLE `feed_item_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `feed_item_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feed_items`
--

DROP TABLE IF EXISTS `feed_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feed_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `thumbnail_url` varchar(255) DEFAULT NULL,
  `body` varchar(255) DEFAULT NULL,
  `feed_type` varchar(255) DEFAULT NULL,
  `feed_id` int(11) DEFAULT NULL,
  `subject_type` varchar(255) DEFAULT NULL,
  `subject_id` int(11) DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `feed_item_type_id` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feed_items`
--

LOCK TABLES `feed_items` WRITE;
/*!40000 ALTER TABLE `feed_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `feed_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forum_categories`
--

DROP TABLE IF EXISTS `forum_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `forum_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `view_order` int(11) NOT NULL DEFAULT '0',
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forum_categories`
--

LOCK TABLES `forum_categories` WRITE;
/*!40000 ALTER TABLE `forum_categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `forum_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forum_posts`
--

DROP TABLE IF EXISTS `forum_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `forum_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `forum_topic_id` int(11) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `text` text NOT NULL,
  `user_id` int(11) NOT NULL,
  `reply_to_post_id` int(11) DEFAULT NULL,
  `edit_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forum_posts`
--

LOCK TABLES `forum_posts` WRITE;
/*!40000 ALTER TABLE `forum_posts` DISABLE KEYS */;
/*!40000 ALTER TABLE `forum_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forum_topics`
--

DROP TABLE IF EXISTS `forum_topics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `forum_topics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `forum_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `number_of_posts` int(11) NOT NULL DEFAULT '0',
  `number_of_views` int(11) NOT NULL DEFAULT '0',
  `first_post_id` int(11) DEFAULT NULL,
  `last_post_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forum_topics`
--

LOCK TABLES `forum_topics` WRITE;
/*!40000 ALTER TABLE `forum_topics` DISABLE KEYS */;
/*!40000 ALTER TABLE `forum_topics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forums`
--

DROP TABLE IF EXISTS `forums`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `forums` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `forum_category_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `view_order` int(11) NOT NULL DEFAULT '0',
  `number_of_posts` int(11) NOT NULL DEFAULT '0',
  `number_of_topics` int(11) NOT NULL DEFAULT '0',
  `number_of_views` int(11) NOT NULL DEFAULT '0',
  `last_post_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forums`
--

LOCK TABLES `forums` WRITE;
/*!40000 ALTER TABLE `forums` DISABLE KEYS */;
/*!40000 ALTER TABLE `forums` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gbif_identifiers_with_maps`
--

DROP TABLE IF EXISTS `gbif_identifiers_with_maps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gbif_identifiers_with_maps` (
  `gbif_taxon_id` int(11) NOT NULL,
  PRIMARY KEY (`gbif_taxon_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gbif_identifiers_with_maps`
--

LOCK TABLES `gbif_identifiers_with_maps` WRITE;
/*!40000 ALTER TABLE `gbif_identifiers_with_maps` DISABLE KEYS */;
/*!40000 ALTER TABLE `gbif_identifiers_with_maps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `glossary_terms`
--

DROP TABLE IF EXISTS `glossary_terms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `glossary_terms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `term` varchar(255) DEFAULT NULL,
  `definition` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `term` (`term`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `glossary_terms`
--

LOCK TABLES `glossary_terms` WRITE;
/*!40000 ALTER TABLE `glossary_terms` DISABLE KEYS */;
/*!40000 ALTER TABLE `glossary_terms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `google_analytics_page_stats`
--

DROP TABLE IF EXISTS `google_analytics_page_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `google_analytics_page_stats` (
  `taxon_concept_id` int(10) unsigned NOT NULL DEFAULT '0',
  `year` smallint(4) NOT NULL,
  `month` tinyint(2) NOT NULL,
  `page_views` int(10) unsigned NOT NULL,
  `unique_page_views` int(10) unsigned NOT NULL,
  `time_on_page` time NOT NULL,
  KEY `month_year` (`month`,`year`),
  KEY `taxon_concept_id` (`taxon_concept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `google_analytics_page_stats`
--

LOCK TABLES `google_analytics_page_stats` WRITE;
/*!40000 ALTER TABLE `google_analytics_page_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `google_analytics_page_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `google_analytics_partner_summaries`
--

DROP TABLE IF EXISTS `google_analytics_partner_summaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `google_analytics_partner_summaries` (
  `year` smallint(4) NOT NULL DEFAULT '0',
  `month` tinyint(2) NOT NULL DEFAULT '0',
  `user_id` int(10) unsigned NOT NULL,
  `taxa_pages` int(11) DEFAULT NULL,
  `taxa_pages_viewed` int(11) DEFAULT NULL,
  `unique_page_views` int(11) DEFAULT NULL,
  `page_views` int(11) DEFAULT NULL,
  `time_on_page` float(11,2) DEFAULT NULL,
  PRIMARY KEY (`user_id`,`year`,`month`),
  KEY `year` (`year`),
  KEY `month` (`month`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `google_analytics_partner_summaries`
--

LOCK TABLES `google_analytics_partner_summaries` WRITE;
/*!40000 ALTER TABLE `google_analytics_partner_summaries` DISABLE KEYS */;
/*!40000 ALTER TABLE `google_analytics_partner_summaries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `google_analytics_partner_taxa`
--

DROP TABLE IF EXISTS `google_analytics_partner_taxa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `google_analytics_partner_taxa` (
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `year` smallint(4) NOT NULL,
  `month` tinyint(2) NOT NULL,
  KEY `concept_user_month_year` (`taxon_concept_id`,`user_id`,`month`,`year`),
  KEY `user_month` (`user_id`,`month`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `google_analytics_partner_taxa`
--

LOCK TABLES `google_analytics_partner_taxa` WRITE;
/*!40000 ALTER TABLE `google_analytics_partner_taxa` DISABLE KEYS */;
/*!40000 ALTER TABLE `google_analytics_partner_taxa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `google_analytics_summaries`
--

DROP TABLE IF EXISTS `google_analytics_summaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `google_analytics_summaries` (
  `year` smallint(4) NOT NULL,
  `month` tinyint(2) NOT NULL,
  `visits` int(11) DEFAULT NULL,
  `visitors` int(11) DEFAULT NULL,
  `pageviews` int(11) DEFAULT NULL,
  `unique_pageviews` int(11) DEFAULT NULL,
  `ave_pages_per_visit` float DEFAULT NULL,
  `ave_time_on_site` time DEFAULT NULL,
  `ave_time_on_page` time DEFAULT NULL,
  `per_new_visits` float DEFAULT NULL,
  `bounce_rate` float DEFAULT NULL,
  `per_exit` float DEFAULT NULL,
  `taxa_pages` int(11) DEFAULT NULL,
  `taxa_pages_viewed` int(11) DEFAULT NULL,
  `time_on_pages` int(11) DEFAULT NULL,
  PRIMARY KEY (`year`,`month`),
  KEY `year` (`year`),
  KEY `month` (`month`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `google_analytics_summaries`
--

LOCK TABLES `google_analytics_summaries` WRITE;
/*!40000 ALTER TABLE `google_analytics_summaries` DISABLE KEYS */;
/*!40000 ALTER TABLE `google_analytics_summaries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `harvest_events`
--

DROP TABLE IF EXISTS `harvest_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `harvest_events` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `resource_id` int(10) unsigned NOT NULL,
  `began_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` timestamp NULL DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `publish` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `resource_id` (`resource_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `harvest_events`
--

LOCK TABLES `harvest_events` WRITE;
/*!40000 ALTER TABLE `harvest_events` DISABLE KEYS */;
INSERT INTO `harvest_events` VALUES (1,1,'2013-09-16 03:45:54','2013-09-16 03:45:54',NULL,0),(2,1,'2013-09-16 03:47:31','2013-09-16 03:47:31',NULL,0),(3,1,'2013-09-16 04:57:48','2013-09-16 04:57:48',NULL,0);
/*!40000 ALTER TABLE `harvest_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `harvest_events_hierarchy_entries`
--

DROP TABLE IF EXISTS `harvest_events_hierarchy_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `harvest_events_hierarchy_entries` (
  `harvest_event_id` int(10) unsigned NOT NULL,
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `guid` varchar(32) CHARACTER SET ascii NOT NULL,
  `status_id` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`harvest_event_id`,`hierarchy_entry_id`),
  KEY `hierarchy_entry_id` (`hierarchy_entry_id`),
  KEY `guid` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `harvest_events_hierarchy_entries`
--

LOCK TABLES `harvest_events_hierarchy_entries` WRITE;
/*!40000 ALTER TABLE `harvest_events_hierarchy_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `harvest_events_hierarchy_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `harvest_process_logs`
--

DROP TABLE IF EXISTS `harvest_process_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `harvest_process_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `process_name` varchar(255) DEFAULT NULL,
  `began_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `harvest_process_logs`
--

LOCK TABLES `harvest_process_logs` WRITE;
/*!40000 ALTER TABLE `harvest_process_logs` DISABLE KEYS */;
INSERT INTO `harvest_process_logs` VALUES (1,'Force Harvest','2013-09-15 23:39:19',NULL),(2,'Force Harvest','2013-09-15 23:45:42','2013-09-15 23:45:56'),(3,'Force Harvest','2013-09-15 23:47:14','2013-09-15 23:47:31'),(4,'Publishing','2013-09-16 00:57:00','2013-09-16 00:57:00'),(5,'Denormalizing','2013-09-16 00:57:17','2013-09-16 00:57:19'),(6,'DataObjectsTaxonConcepts','2013-09-16 00:57:17','2013-09-16 00:57:17'),(7,'Flatten Hierarchies','2013-09-16 00:57:18','2013-09-16 00:57:18'),(8,'Top Images','2013-09-16 00:57:18','2013-09-16 00:57:19'),(9,'Force Harvest','2013-09-16 00:57:39','2013-09-16 00:57:48'),(10,'Update Connector Resources','2015-04-06 21:28:12','2015-04-06 21:28:12');
/*!40000 ALTER TABLE `harvest_process_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hierarchies`
--

DROP TABLE IF EXISTS `hierarchies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hierarchies` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `agent_id` int(10) unsigned NOT NULL COMMENT 'recommended; our internal id of the source agent responsible for the entire hierarchy',
  `label` varchar(255) NOT NULL COMMENT 'recommended; succinct title for the hierarchy (e.g. Catalogue of Life: Annual Checklist 2009)',
  `descriptive_label` varchar(255) DEFAULT NULL,
  `description` text NOT NULL COMMENT 'not required; a more verbose description describing the hierarchy. Could be a paragraph describing what it is and what it contains',
  `indexed_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'required; the date which we created and indexed the hierarchy',
  `hierarchy_group_id` int(10) unsigned NOT NULL COMMENT 'not required; there is no hierarchy_groups table, but this field was meant to identify hierarchies of the same source so they can be verioned and older versions retained but not presented',
  `hierarchy_group_version` tinyint(3) unsigned NOT NULL COMMENT 'not required; this is mean to uniquely identify hierarchies within the same group. This version number has been an internal incrementing value',
  `url` varchar(255) CHARACTER SET ascii NOT NULL COMMENT 'not required; a link back to a web page describing this hierarchy',
  `outlink_uri` varchar(255) DEFAULT NULL,
  `ping_host_url` varchar(255) DEFAULT NULL,
  `browsable` int(11) DEFAULT NULL,
  `complete` tinyint(3) unsigned DEFAULT '1',
  `request_publish` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='A container for hierarchy_entries. These are usually taxonom';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hierarchies`
--

LOCK TABLES `hierarchies` WRITE;
/*!40000 ALTER TABLE `hierarchies` DISABLE KEYS */;
INSERT INTO `hierarchies` VALUES (1,0,'1',NULL,'From resource 1 (1)','2013-09-16 03:45:54',0,0,'',NULL,NULL,NULL,0,0);
/*!40000 ALTER TABLE `hierarchies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hierarchies_content`
--

DROP TABLE IF EXISTS `hierarchies_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hierarchies_content` (
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `text` tinyint(3) unsigned NOT NULL,
  `text_unpublished` tinyint(3) unsigned NOT NULL,
  `image` tinyint(3) unsigned NOT NULL,
  `image_unpublished` tinyint(3) unsigned NOT NULL,
  `child_image` tinyint(3) unsigned NOT NULL,
  `child_image_unpublished` tinyint(3) unsigned NOT NULL,
  `flash` tinyint(3) unsigned NOT NULL,
  `youtube` tinyint(3) unsigned NOT NULL,
  `map` tinyint(3) unsigned NOT NULL,
  `content_level` tinyint(3) unsigned NOT NULL,
  `image_object_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`hierarchy_entry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Summarizes the data types available to a given hierarchy ent';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hierarchies_content`
--

LOCK TABLES `hierarchies_content` WRITE;
/*!40000 ALTER TABLE `hierarchies_content` DISABLE KEYS */;
/*!40000 ALTER TABLE `hierarchies_content` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hierarchy_entries`
--

DROP TABLE IF EXISTS `hierarchy_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hierarchy_entries` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `guid` varchar(32) CHARACTER SET ascii NOT NULL,
  `identifier` varchar(255) NOT NULL COMMENT 'recommended; a unique id from the provider for this node',
  `source_url` text,
  `name_id` int(10) unsigned NOT NULL COMMENT 'recommended; the name string for this node. It is possible that nodes have no names, but most of the time they will',
  `parent_id` int(10) unsigned NOT NULL COMMENT 'recommended; the parent_id references the hierarchy_entry_id of the parent of this node. Used to create trees. Root nodes will have a partent_id of 0',
  `hierarchy_id` smallint(5) unsigned NOT NULL COMMENT 'required; the id of the container hierarchy',
  `rank_id` smallint(5) unsigned NOT NULL COMMENT 'recommended; when available, this is the id of the rank string which defines the taxonomic rank of the node',
  `ancestry` varchar(500) CHARACTER SET ascii NOT NULL COMMENT 'not required; perhaps now obsolete. Used to store the materialized path of this node''s ancestors',
  `lft` int(10) unsigned NOT NULL COMMENT 'required; the left value of this node within the hierarchy''s nested set',
  `rgt` int(10) unsigned NOT NULL COMMENT 'required; the right value of this node within the hierarchy''s nested set',
  `depth` tinyint(3) unsigned NOT NULL COMMENT 'recommended; the depth of this node in within the hierarchy''s tree',
  `taxon_concept_id` int(10) unsigned NOT NULL COMMENT 'required; the id of the taxon_concept described by this hierarchy_entry',
  `vetted_id` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `published` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `visibility_id` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `taxon_remarks` text,
  PRIMARY KEY (`id`),
  KEY `name_id` (`name_id`),
  KEY `parent_id` (`parent_id`),
  KEY `lft` (`lft`),
  KEY `taxon_concept_id` (`taxon_concept_id`),
  KEY `vetted_id` (`vetted_id`),
  KEY `visibility_id` (`visibility_id`),
  KEY `published` (`published`),
  KEY `identifier` (`identifier`),
  KEY `hierarchy_parent` (`hierarchy_id`,`parent_id`),
  KEY `concept_published_visible` (`taxon_concept_id`,`published`,`visibility_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hierarchy_entries`
--

LOCK TABLES `hierarchy_entries` WRITE;
/*!40000 ALTER TABLE `hierarchy_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `hierarchy_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hierarchy_entries_flattened`
--

DROP TABLE IF EXISTS `hierarchy_entries_flattened`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hierarchy_entries_flattened` (
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `ancestor_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`hierarchy_entry_id`,`ancestor_id`),
  KEY `ancestor_id` (`ancestor_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hierarchy_entries_flattened`
--

LOCK TABLES `hierarchy_entries_flattened` WRITE;
/*!40000 ALTER TABLE `hierarchy_entries_flattened` DISABLE KEYS */;
/*!40000 ALTER TABLE `hierarchy_entries_flattened` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hierarchy_entries_flattened_tmp`
--

DROP TABLE IF EXISTS `hierarchy_entries_flattened_tmp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hierarchy_entries_flattened_tmp` (
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `ancestor_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`hierarchy_entry_id`,`ancestor_id`),
  KEY `ancestor_id` (`ancestor_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hierarchy_entries_flattened_tmp`
--

LOCK TABLES `hierarchy_entries_flattened_tmp` WRITE;
/*!40000 ALTER TABLE `hierarchy_entries_flattened_tmp` DISABLE KEYS */;
/*!40000 ALTER TABLE `hierarchy_entries_flattened_tmp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hierarchy_entries_refs`
--

DROP TABLE IF EXISTS `hierarchy_entries_refs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hierarchy_entries_refs` (
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `ref_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`hierarchy_entry_id`,`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hierarchy_entries_refs`
--

LOCK TABLES `hierarchy_entries_refs` WRITE;
/*!40000 ALTER TABLE `hierarchy_entries_refs` DISABLE KEYS */;
/*!40000 ALTER TABLE `hierarchy_entries_refs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hierarchy_entry_moves`
--

DROP TABLE IF EXISTS `hierarchy_entry_moves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hierarchy_entry_moves` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hierarchy_entry_id` int(11) NOT NULL,
  `classification_curation_id` int(11) NOT NULL,
  `error` varchar(256) DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `entry_and_curation_index` (`hierarchy_entry_id`,`classification_curation_id`),
  KEY `index_hierarchy_entry_moves_on_hierarchy_entry_id` (`hierarchy_entry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hierarchy_entry_moves`
--

LOCK TABLES `hierarchy_entry_moves` WRITE;
/*!40000 ALTER TABLE `hierarchy_entry_moves` DISABLE KEYS */;
/*!40000 ALTER TABLE `hierarchy_entry_moves` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hierarchy_entry_relationships`
--

DROP TABLE IF EXISTS `hierarchy_entry_relationships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hierarchy_entry_relationships` (
  `hierarchy_entry_id_1` int(10) unsigned NOT NULL,
  `hierarchy_entry_id_2` int(10) unsigned NOT NULL,
  `relationship` varchar(30) NOT NULL,
  `score` double NOT NULL,
  `extra` text NOT NULL,
  PRIMARY KEY (`hierarchy_entry_id_1`,`hierarchy_entry_id_2`),
  KEY `score` (`score`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hierarchy_entry_relationships`
--

LOCK TABLES `hierarchy_entry_relationships` WRITE;
/*!40000 ALTER TABLE `hierarchy_entry_relationships` DISABLE KEYS */;
/*!40000 ALTER TABLE `hierarchy_entry_relationships` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hierarchy_entry_stats`
--

DROP TABLE IF EXISTS `hierarchy_entry_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hierarchy_entry_stats` (
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `text_trusted` mediumint(8) unsigned NOT NULL,
  `text_untrusted` mediumint(8) unsigned NOT NULL,
  `image_trusted` mediumint(8) unsigned NOT NULL,
  `image_untrusted` mediumint(8) unsigned NOT NULL,
  `bhl` mediumint(8) unsigned NOT NULL,
  `all_text_trusted` mediumint(8) unsigned NOT NULL,
  `all_text_untrusted` mediumint(8) unsigned NOT NULL,
  `have_text` mediumint(8) unsigned NOT NULL,
  `all_image_trusted` mediumint(8) unsigned NOT NULL,
  `all_image_untrusted` mediumint(8) unsigned NOT NULL,
  `have_images` mediumint(8) unsigned NOT NULL,
  `all_bhl` int(10) unsigned NOT NULL,
  `total_children` int(10) unsigned NOT NULL,
  PRIMARY KEY (`hierarchy_entry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hierarchy_entry_stats`
--

LOCK TABLES `hierarchy_entry_stats` WRITE;
/*!40000 ALTER TABLE `hierarchy_entry_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `hierarchy_entry_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `image_crops`
--

DROP TABLE IF EXISTS `image_crops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image_crops` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data_object_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `original_object_cache_url` bigint(20) unsigned NOT NULL,
  `new_object_cache_url` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `data_object_id` (`data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `image_crops`
--

LOCK TABLES `image_crops` WRITE;
/*!40000 ALTER TABLE `image_crops` DISABLE KEYS */;
/*!40000 ALTER TABLE `image_crops` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `info_items`
--

DROP TABLE IF EXISTS `info_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `info_items` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `schema_value` varchar(255) CHARACTER SET ascii NOT NULL,
  `toc_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `info_items`
--

LOCK TABLES `info_items` WRITE;
/*!40000 ALTER TABLE `info_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `info_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item_pages`
--

DROP TABLE IF EXISTS `item_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_pages` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title_item_id` int(10) unsigned NOT NULL,
  `year` varchar(20) NOT NULL,
  `volume` varchar(20) NOT NULL,
  `issue` varchar(20) NOT NULL,
  `prefix` varchar(20) NOT NULL,
  `number` varchar(20) NOT NULL,
  `url` varchar(255) CHARACTER SET ascii NOT NULL,
  `page_type` varchar(20) CHARACTER SET ascii NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Used for BHL. The publication items have many pages';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_pages`
--

LOCK TABLES `item_pages` WRITE;
/*!40000 ALTER TABLE `item_pages` DISABLE KEYS */;
/*!40000 ALTER TABLE `item_pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `language_groups`
--

DROP TABLE IF EXISTS `language_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language_groups` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `representative_language_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `language_groups`
--

LOCK TABLES `language_groups` WRITE;
/*!40000 ALTER TABLE `language_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `language_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `languages`
--

DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `languages` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `iso_639_1` varchar(12) NOT NULL,
  `iso_639_2` varchar(12) NOT NULL,
  `iso_639_3` varchar(12) NOT NULL,
  `source_form` varchar(100) NOT NULL,
  `sort_order` tinyint(4) NOT NULL DEFAULT '1',
  `activated_on` timestamp NULL DEFAULT NULL,
  `language_group_id` smallint(5) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `iso_639_1` (`iso_639_1`),
  KEY `iso_639_2` (`iso_639_2`),
  KEY `iso_639_3` (`iso_639_3`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `languages`
--

LOCK TABLES `languages` WRITE;
/*!40000 ALTER TABLE `languages` DISABLE KEYS */;
INSERT INTO `languages` VALUES (1,'en','','','',1,'2013-04-15 16:24:45',NULL);
/*!40000 ALTER TABLE `languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `licenses`
--

DROP TABLE IF EXISTS `licenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `licenses` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `source_url` varchar(255) CHARACTER SET ascii NOT NULL,
  `version` varchar(6) CHARACTER SET ascii NOT NULL,
  `logo_url` varchar(255) CHARACTER SET ascii NOT NULL,
  `show_to_content_partners` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `title` (`title`),
  KEY `source_url` (`source_url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `licenses`
--

LOCK TABLES `licenses` WRITE;
/*!40000 ALTER TABLE `licenses` DISABLE KEYS */;
/*!40000 ALTER TABLE `licenses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `link_types`
--

DROP TABLE IF EXISTS `link_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `link_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `link_types`
--

LOCK TABLES `link_types` WRITE;
/*!40000 ALTER TABLE `link_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `link_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `members`
--

DROP TABLE IF EXISTS `members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `manager` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `members`
--

LOCK TABLES `members` WRITE;
/*!40000 ALTER TABLE `members` DISABLE KEYS */;
/*!40000 ALTER TABLE `members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mime_types`
--

DROP TABLE IF EXISTS `mime_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mime_types` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Type of data object. Controlled list used in the EOL schema';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mime_types`
--

LOCK TABLES `mime_types` WRITE;
/*!40000 ALTER TABLE `mime_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `mime_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `name_languages`
--

DROP TABLE IF EXISTS `name_languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `name_languages` (
  `name_id` int(10) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL COMMENT 'required; the language of the string. ''Scientific name'' is a language',
  `parent_name_id` int(10) unsigned NOT NULL COMMENT 'not required; associated a common name or surrogate with its proper scientific name',
  `preferred` tinyint(3) unsigned NOT NULL COMMENT 'not required; identifies if the common names is preferred for the given scientific name in the given language',
  PRIMARY KEY (`name_id`,`language_id`,`parent_name_id`),
  KEY `parent_name_id` (`parent_name_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Used mainly to identify which names are scientific names, an';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `name_languages`
--

LOCK TABLES `name_languages` WRITE;
/*!40000 ALTER TABLE `name_languages` DISABLE KEYS */;
/*!40000 ALTER TABLE `name_languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `names`
--

DROP TABLE IF EXISTS `names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `names` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `namebank_id` int(10) unsigned NOT NULL COMMENT 'required; this identifies the uBio NameBank id for this string so that we can stay in sync. Many newer names will have this set to 0 as it is unknown if the name is in NameBank',
  `string` varchar(300) NOT NULL COMMENT 'the actual name. This is unique - every unique sequence of characters has one and only one name_id (we should probably add a unique index to this field)',
  `clean_name` varchar(300) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT 'there is a one to one reltaionship between a name string and a clean name. The clean name takes the string and lowercases it (uncluding diacriticals), removes leading/trailing whitespace, removes some punctuation (periods and more), and pads remaining pun',
  `italicized` varchar(300) NOT NULL COMMENT 'required; this includes html <i> tags in the proper place to display the string in its italicized form. Generally only species and subspecific names are italizied. Usually algorithmically generated',
  `italicized_verified` tinyint(3) unsigned NOT NULL COMMENT 'required; if an editor verifies the italicized form is correct, or corrects it, this should be set to 1 so it is not algorithmically replaced if we change the algorithm',
  `canonical_form_id` int(10) unsigned NOT NULL COMMENT 'required; every name string has a canonical form',
  `ranked_canonical_form_id` int(10) unsigned DEFAULT NULL,
  `canonical_verified` tinyint(3) unsigned NOT NULL COMMENT 'required; same as with italicized form, if an editor verifies the canonical form we want to maintin their edits if we were to redo the canonical form algorithm',
  PRIMARY KEY (`id`),
  KEY `canonical_form_id` (`canonical_form_id`),
  KEY `clean_name` (`clean_name`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Represents the name of a taxon';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `names`
--

LOCK TABLES `names` WRITE;
/*!40000 ALTER TABLE `names` DISABLE KEYS */;
/*!40000 ALTER TABLE `names` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `news_items`
--

DROP TABLE IF EXISTS `news_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `news_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `page_name` varchar(255) DEFAULT NULL,
  `display_date` datetime DEFAULT NULL,
  `activated_on` datetime DEFAULT NULL,
  `last_update_user_id` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `news_items`
--

LOCK TABLES `news_items` WRITE;
/*!40000 ALTER TABLE `news_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `news_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_emailer_settings`
--

DROP TABLE IF EXISTS `notification_emailer_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notification_emailer_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `last_daily_emails_sent` datetime DEFAULT NULL,
  `last_weekly_emails_sent` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_emailer_settings`
--

LOCK TABLES `notification_emailer_settings` WRITE;
/*!40000 ALTER TABLE `notification_emailer_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_emailer_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_frequencies`
--

DROP TABLE IF EXISTS `notification_frequencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notification_frequencies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `frequency` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_frequencies`
--

LOCK TABLES `notification_frequencies` WRITE;
/*!40000 ALTER TABLE `notification_frequencies` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_frequencies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `reply_to_comment` int(11) DEFAULT '5',
  `comment_on_my_profile` int(11) DEFAULT '5',
  `comment_on_my_contribution` int(11) DEFAULT '5',
  `comment_on_my_collection` int(11) DEFAULT '5',
  `comment_on_my_community` int(11) DEFAULT '5',
  `made_me_a_manager` int(11) DEFAULT '5',
  `member_joined_my_community` int(11) DEFAULT '5',
  `comment_on_my_watched_item` int(11) DEFAULT '2',
  `curation_on_my_watched_item` int(11) DEFAULT '2',
  `new_data_on_my_watched_item` int(11) DEFAULT '2',
  `changes_to_my_watched_collection` int(11) DEFAULT '2',
  `changes_to_my_watched_community` int(11) DEFAULT '2',
  `member_joined_my_watched_community` int(11) DEFAULT '2',
  `member_left_my_community` int(11) DEFAULT '2',
  `new_manager_in_my_community` int(11) DEFAULT '2',
  `i_am_being_watched` int(11) DEFAULT '2',
  `eol_newsletter` tinyint(1) DEFAULT '1',
  `last_notification_sent_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_notifications_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `open_authentications`
--

DROP TABLE IF EXISTS `open_authentications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `open_authentications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `provider` varchar(255) NOT NULL,
  `guid` varchar(255) NOT NULL,
  `token` varchar(255) DEFAULT NULL,
  `secret` varchar(255) DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `provider_guid` (`provider`,`guid`),
  UNIQUE KEY `user_id_provider` (`user_id`,`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `open_authentications`
--

LOCK TABLES `open_authentications` WRITE;
/*!40000 ALTER TABLE `open_authentications` DISABLE KEYS */;
/*!40000 ALTER TABLE `open_authentications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `open_id_authentication_associations`
--

DROP TABLE IF EXISTS `open_id_authentication_associations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `open_id_authentication_associations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `issued` int(11) DEFAULT NULL,
  `lifetime` int(11) DEFAULT NULL,
  `handle` varchar(255) DEFAULT NULL,
  `assoc_type` varchar(255) DEFAULT NULL,
  `server_url` blob,
  `secret` blob,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `open_id_authentication_associations`
--

LOCK TABLES `open_id_authentication_associations` WRITE;
/*!40000 ALTER TABLE `open_id_authentication_associations` DISABLE KEYS */;
/*!40000 ALTER TABLE `open_id_authentication_associations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `open_id_authentication_nonces`
--

DROP TABLE IF EXISTS `open_id_authentication_nonces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `open_id_authentication_nonces` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` int(11) NOT NULL,
  `server_url` varchar(255) DEFAULT NULL,
  `salt` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `open_id_authentication_nonces`
--

LOCK TABLES `open_id_authentication_nonces` WRITE;
/*!40000 ALTER TABLE `open_id_authentication_nonces` DISABLE KEYS */;
/*!40000 ALTER TABLE `open_id_authentication_nonces` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_names`
--

DROP TABLE IF EXISTS `page_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_names` (
  `item_page_id` int(10) unsigned NOT NULL,
  `name_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`name_id`,`item_page_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Used for BHL. Links name strings to BHL page identifiers. Ma';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_names`
--

LOCK TABLES `page_names` WRITE;
/*!40000 ALTER TABLE `page_names` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_names` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_stats_dataobjects`
--

DROP TABLE IF EXISTS `page_stats_dataobjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_stats_dataobjects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `active` varchar(1) DEFAULT 'n',
  `taxa_count` int(11) DEFAULT NULL,
  `vetted_unknown_published_visible_uniqueGuid` int(11) DEFAULT NULL,
  `vetted_untrusted_published_visible_uniqueGuid` int(11) DEFAULT NULL,
  `vetted_unknown_published_notVisible_uniqueGuid` int(11) DEFAULT NULL,
  `vetted_untrusted_published_notVisible_uniqueGuid` int(11) DEFAULT NULL,
  `date_created` date DEFAULT NULL,
  `time_created` time DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `a_vetted_unknown_published_visible_uniqueGuid` longtext,
  `a_vetted_untrusted_published_visible_uniqueGuid` longtext,
  `a_vetted_unknown_published_notVisible_uniqueGuid` longtext,
  `a_vetted_untrusted_published_notVisible_uniqueGuid` longtext,
  `user_submitted_text` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_stats_dataobjects`
--

LOCK TABLES `page_stats_dataobjects` WRITE;
/*!40000 ALTER TABLE `page_stats_dataobjects` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_stats_dataobjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_stats_marine`
--

DROP TABLE IF EXISTS `page_stats_marine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_stats_marine` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `active` tinyint(1) DEFAULT '0',
  `names_from_xml` int(11) DEFAULT NULL,
  `names_in_eol` int(11) DEFAULT NULL,
  `marine_pages` int(11) DEFAULT NULL,
  `pages_with_objects` int(11) DEFAULT NULL,
  `pages_with_vetted_objects` int(11) DEFAULT NULL,
  `date_created` date DEFAULT NULL,
  `time_created` time DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_stats_marine`
--

LOCK TABLES `page_stats_marine` WRITE;
/*!40000 ALTER TABLE `page_stats_marine` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_stats_marine` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_stats_taxa`
--

DROP TABLE IF EXISTS `page_stats_taxa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_stats_taxa` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `taxa_count` int(11) DEFAULT NULL,
  `taxa_text` int(11) DEFAULT NULL,
  `taxa_images` int(11) DEFAULT NULL,
  `taxa_text_images` int(11) DEFAULT NULL,
  `taxa_BHL_no_text` int(11) DEFAULT NULL,
  `taxa_links_no_text` int(11) DEFAULT NULL,
  `taxa_images_no_text` int(11) DEFAULT NULL,
  `taxa_text_no_images` int(11) DEFAULT NULL,
  `vet_obj_only_1cat_inCOL` int(11) DEFAULT NULL,
  `vet_obj_only_1cat_notinCOL` int(11) DEFAULT NULL,
  `vet_obj_morethan_1cat_inCOL` int(11) DEFAULT NULL,
  `vet_obj_morethan_1cat_notinCOL` int(11) DEFAULT NULL,
  `vet_obj` int(11) DEFAULT NULL,
  `no_vet_obj2` int(11) DEFAULT NULL,
  `with_BHL` int(11) DEFAULT NULL,
  `vetted_not_published` int(11) DEFAULT NULL,
  `vetted_unknown_published_visible_inCol` int(11) DEFAULT NULL,
  `vetted_unknown_published_visible_notinCol` int(11) DEFAULT NULL,
  `pages_incol` int(11) DEFAULT NULL,
  `pages_not_incol` int(11) DEFAULT NULL,
  `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `lifedesk_taxa` int(11) DEFAULT NULL,
  `lifedesk_dataobject` int(11) DEFAULT NULL,
  `data_objects_count_per_category` text,
  `content_partners_count_per_category` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_stats_taxa`
--

LOCK TABLES `page_stats_taxa` WRITE;
/*!40000 ALTER TABLE `page_stats_taxa` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_stats_taxa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pending_notifications`
--

DROP TABLE IF EXISTS `pending_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pending_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `notification_frequency_id` int(11) DEFAULT NULL,
  `target_id` int(11) DEFAULT NULL,
  `target_type` varchar(64) DEFAULT NULL,
  `reason` varchar(64) DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pending_notifications_on_user_id` (`user_id`),
  KEY `index_pending_notifications_on_sent_at` (`sent_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pending_notifications`
--

LOCK TABLES `pending_notifications` WRITE;
/*!40000 ALTER TABLE `pending_notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `pending_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `users_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions_users`
--

DROP TABLE IF EXISTS `permissions_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permissions_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_permissions_users_on_permission_id_and_user_id` (`permission_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions_users`
--

LOCK TABLES `permissions_users` WRITE;
/*!40000 ALTER TABLE `permissions_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `permissions_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `publication_titles`
--

DROP TABLE IF EXISTS `publication_titles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `publication_titles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `marc_bib_id` varchar(40) NOT NULL,
  `marc_leader` varchar(40) NOT NULL,
  `title` varchar(300) NOT NULL,
  `short_title` varchar(300) NOT NULL,
  `details` varchar(300) NOT NULL,
  `call_number` varchar(40) NOT NULL,
  `start_year` varchar(10) NOT NULL,
  `end_year` varchar(10) NOT NULL,
  `language` varchar(10) NOT NULL,
  `author` varchar(150) NOT NULL,
  `abbreviation` varchar(150) NOT NULL,
  `url` varchar(255) CHARACTER SET ascii NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Used for BHL. The main publications';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `publication_titles`
--

LOCK TABLES `publication_titles` WRITE;
/*!40000 ALTER TABLE `publication_titles` DISABLE KEYS */;
/*!40000 ALTER TABLE `publication_titles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `random_hierarchy_images`
--

DROP TABLE IF EXISTS `random_hierarchy_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `random_hierarchy_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data_object_id` int(11) NOT NULL,
  `hierarchy_entry_id` int(11) DEFAULT NULL,
  `hierarchy_id` int(11) DEFAULT NULL,
  `taxon_concept_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `hierarchy_entry_id` (`hierarchy_entry_id`),
  KEY `hierarchy_id` (`hierarchy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `random_hierarchy_images`
--

LOCK TABLES `random_hierarchy_images` WRITE;
/*!40000 ALTER TABLE `random_hierarchy_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `random_hierarchy_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ranks`
--

DROP TABLE IF EXISTS `ranks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ranks` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `rank_group_id` smallint(6) NOT NULL COMMENT 'not required; there is no rank_groups table. This is used to group (reconcile) different strings for the same rank',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8 COMMENT='Stores taxonomic ranks (ex: phylum, order, class, family...)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ranks`
--

LOCK TABLES `ranks` WRITE;
/*!40000 ALTER TABLE `ranks` DISABLE KEYS */;
INSERT INTO `ranks` VALUES (1,0),(2,0),(3,0),(4,0),(5,0),(6,0),(7,0),(8,0),(9,0),(10,0),(11,0),(12,0),(13,0),(14,0),(15,0),(16,0),(17,0),(18,0),(19,0),(20,0),(21,0),(22,0),(23,0),(24,0),(25,0),(26,0);
/*!40000 ALTER TABLE `ranks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ref_identifier_types`
--

DROP TABLE IF EXISTS `ref_identifier_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ref_identifier_types` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `label` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `label` (`label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ref_identifier_types`
--

LOCK TABLES `ref_identifier_types` WRITE;
/*!40000 ALTER TABLE `ref_identifier_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `ref_identifier_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ref_identifiers`
--

DROP TABLE IF EXISTS `ref_identifiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ref_identifiers` (
  `ref_id` int(10) unsigned NOT NULL,
  `ref_identifier_type_id` smallint(5) unsigned NOT NULL,
  `identifier` varchar(255) CHARACTER SET ascii NOT NULL,
  PRIMARY KEY (`ref_id`,`ref_identifier_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ref_identifiers`
--

LOCK TABLES `ref_identifiers` WRITE;
/*!40000 ALTER TABLE `ref_identifiers` DISABLE KEYS */;
/*!40000 ALTER TABLE `ref_identifiers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refs`
--

DROP TABLE IF EXISTS `refs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `refs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `full_reference` text NOT NULL,
  `provider_mangaed_id` varchar(255) DEFAULT NULL,
  `authors` varchar(255) DEFAULT NULL,
  `editors` varchar(255) DEFAULT NULL,
  `publication_created_at` timestamp NULL DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `pages` varchar(255) DEFAULT NULL,
  `page_start` varchar(50) DEFAULT NULL,
  `page_end` varchar(50) DEFAULT NULL,
  `volume` varchar(50) DEFAULT NULL,
  `edition` varchar(50) DEFAULT NULL,
  `publisher` varchar(255) DEFAULT NULL,
  `language_id` smallint(5) unsigned DEFAULT NULL,
  `user_submitted` tinyint(1) NOT NULL DEFAULT '0',
  `visibility_id` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `published` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `full_reference` (`full_reference`(200))
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Stores reference full strings. References are linked to data';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refs`
--

LOCK TABLES `refs` WRITE;
/*!40000 ALTER TABLE `refs` DISABLE KEYS */;
/*!40000 ALTER TABLE `refs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource_statuses`
--

DROP TABLE IF EXISTS `resource_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COMMENT='The status of the resource in harvesting';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_statuses`
--

LOCK TABLES `resource_statuses` WRITE;
/*!40000 ALTER TABLE `resource_statuses` DISABLE KEYS */;
INSERT INTO `resource_statuses` VALUES (1,'2013-04-16 18:34:38','2013-04-16 18:34:38'),(2,'2013-09-15 23:45:54','2013-09-15 23:45:54'),(3,'2013-09-15 23:45:54','2013-09-15 23:45:54'),(4,'2015-04-06 21:28:12','2015-04-06 21:28:12'),(5,'2015-04-06 21:28:12','2015-04-06 21:28:12'),(6,'2015-04-06 21:28:12','2015-04-06 21:28:12'),(7,'2015-04-06 21:28:12','2015-04-06 21:28:12'),(8,'2015-04-06 21:28:12','2015-04-06 21:28:12'),(9,'2017-09-12 23:13:03','2017-09-12 23:13:03');
/*!40000 ALTER TABLE `resource_statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resources`
--

DROP TABLE IF EXISTS `resources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resources` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `content_partner_id` int(10) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `accesspoint_url` varchar(255) DEFAULT NULL COMMENT 'recommended; the url where the resource can be accessed. Not used when the resource is a file which was uploaded',
  `metadata_url` varchar(255) DEFAULT NULL,
  `dwc_archive_url` varchar(255) DEFAULT NULL,
  `service_type_id` int(11) NOT NULL DEFAULT '1' COMMENT 'recommended; if accesspoint_url is defined, this will indicate what kind of protocal can be expected to be found there. (this is perhaps misued right now)',
  `service_version` varchar(255) DEFAULT NULL,
  `resource_set_code` varchar(255) DEFAULT NULL COMMENT 'not required; if the resource contains several subsets (such as DiGIR providers) theis indicates the set we are to harvest',
  `description` varchar(255) DEFAULT NULL,
  `logo_url` varchar(255) DEFAULT NULL,
  `language_id` smallint(5) unsigned DEFAULT NULL COMMENT 'not required; the default language of the contents of the resource',
  `subject` varchar(255) NOT NULL,
  `bibliographic_citation` varchar(400) DEFAULT NULL COMMENT 'not required; the default bibliographic citation for all data objects whithin the resource',
  `license_id` tinyint(3) unsigned NOT NULL,
  `rights_statement` varchar(400) DEFAULT NULL,
  `rights_holder` varchar(255) DEFAULT NULL,
  `refresh_period_hours` smallint(5) unsigned DEFAULT NULL COMMENT 'recommended; if the resource is to be harvested regularly, this field indicates how frequent the updates are',
  `resource_modified_at` datetime DEFAULT NULL,
  `resource_created_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `harvested_at` datetime DEFAULT NULL COMMENT 'required; this field is updated each time the resource is harvested',
  `dataset_file_name` varchar(255) DEFAULT NULL,
  `dataset_content_type` varchar(255) DEFAULT NULL,
  `dataset_file_size` int(11) DEFAULT NULL,
  `resource_status_id` int(11) DEFAULT NULL,
  `auto_publish` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'required; boolean; indicates whether the resource is to be published immediately after harvesting',
  `vetted` tinyint(1) NOT NULL DEFAULT '0',
  `notes` text,
  `hierarchy_id` int(10) unsigned DEFAULT NULL,
  `dwc_hierarchy_id` int(10) unsigned DEFAULT NULL,
  `collection_id` int(11) DEFAULT NULL,
  `preview_collection_id` int(11) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `hierarchy_id` (`hierarchy_id`),
  KEY `content_partner_id` (`content_partner_id`)
) ENGINE=InnoDB AUTO_INCREMENT=737 DEFAULT CHARSET=utf8 COMMENT='Content parters supply resource files which contain data obj';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resources`
--

LOCK TABLES `resources` WRITE;
/*!40000 ALTER TABLE `resources` DISABLE KEYS */;
INSERT INTO `resources` VALUES (1,1,'1','1','1','1',1,'1','1','1','1',1,'1','1',1,NULL,NULL,NULL,NULL,NULL,'2013-04-18 01:00:11','2013-09-16 00:57:48',NULL,NULL,NULL,1,0,0,'',1,NULL,NULL,1,NULL),(71,1,'','http://localhost/~eolit/cp/wikimedia/commonswiki-latest-pages-articles.xml.bz2',NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,'',NULL,0,NULL,NULL,NULL,NULL,NULL,'2014-08-21 03:20:32',NULL,NULL,NULL,NULL,1,0,0,NULL,NULL,NULL,NULL,NULL,NULL),(736,1,'',NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,'',NULL,0,NULL,NULL,NULL,NULL,NULL,'2014-08-07 05:29:40',NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `resources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20090115212906'),('20090115213411'),('20120103141320'),('20120110075736'),('20120110103907'),('20120111211217'),('20120112191907'),('20120112200143'),('20120117213105'),('20120120205849'),('20120131212129'),('20120206154220'),('20120207203935'),('20120208221609'),('20120210202432'),('20120222032338'),('20120223204740'),('20120229152123'),('20120229170021'),('20120301041857'),('20120307204553'),('20120313030838'),('20120315225035'),('20120322050318'),('20120322201426'),('20120322203550'),('20120328143839'),('20120409142449'),('20120411135611'),('20120416134434'),('20120416205738'),('20120424162745'),('20120425185543'),('20120502204941'),('20120508144927'),('20120509164521'),('20120511145911'),('20120523132153'),('20120524195141'),('20120606174130'),('20120612185023'),('20120620180925'),('20120621170001'),('20120702161131'),('20120711180628'),('20120711191923'),('20120717195215'),('20120723173028'),('20120725174440'),('20120726181117'),('20120803133442'),('20120822130345'),('20120824212655'),('20120831194556'),('20120913212558'),('20120921163501'),('20121017193823'),('20121024195217'),('20121214213208'),('20121214213210'),('20121226211903'),('20130114173940'),('20130115161931'),('20130122175125'),('20130131151206'),('20130213150346'),('20130218224336'),('20130221155225'),('20130312205157'),('20130316220630');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_suggestions`
--

DROP TABLE IF EXISTS `search_suggestions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `search_suggestions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `term` varchar(255) NOT NULL DEFAULT '',
  `language_label` varchar(255) NOT NULL DEFAULT 'en',
  `taxon_id` varchar(255) NOT NULL DEFAULT '',
  `notes` text,
  `content_notes` varchar(255) NOT NULL DEFAULT '',
  `sort_order` int(11) NOT NULL DEFAULT '1',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_suggestions`
--

LOCK TABLES `search_suggestions` WRITE;
/*!40000 ALTER TABLE `search_suggestions` DISABLE KEYS */;
/*!40000 ALTER TABLE `search_suggestions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_types`
--

DROP TABLE IF EXISTS `service_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_types` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='What type of protocol the content partners are exposing';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_types`
--

LOCK TABLES `service_types` WRITE;
/*!40000 ALTER TABLE `service_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `service_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `data` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_configuration_options`
--

DROP TABLE IF EXISTS `site_configuration_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_configuration_options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parameter` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_site_configuration_options_on_parameter` (`parameter`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_configuration_options`
--

LOCK TABLES `site_configuration_options` WRITE;
/*!40000 ALTER TABLE `site_configuration_options` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_configuration_options` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sort_styles`
--

DROP TABLE IF EXISTS `sort_styles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sort_styles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sort_styles`
--

LOCK TABLES `sort_styles` WRITE;
/*!40000 ALTER TABLE `sort_styles` DISABLE KEYS */;
/*!40000 ALTER TABLE `sort_styles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `special_collections`
--

DROP TABLE IF EXISTS `special_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `special_collections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `special_collections`
--

LOCK TABLES `special_collections` WRITE;
/*!40000 ALTER TABLE `special_collections` DISABLE KEYS */;
/*!40000 ALTER TABLE `special_collections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `statuses`
--

DROP TABLE IF EXISTS `statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `statuses` (
  `id` smallint(6) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Generic status table designed to be used in several places. ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `statuses`
--

LOCK TABLES `statuses` WRITE;
/*!40000 ALTER TABLE `statuses` DISABLE KEYS */;
/*!40000 ALTER TABLE `statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_responses`
--

DROP TABLE IF EXISTS `survey_responses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `survey_responses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `taxon_id` varchar(255) DEFAULT NULL,
  `user_response` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_agent` varchar(100) DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_responses`
--

LOCK TABLES `survey_responses` WRITE;
/*!40000 ALTER TABLE `survey_responses` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_responses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `synonym_relations`
--

DROP TABLE IF EXISTS `synonym_relations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `synonym_relations` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `synonym_relations`
--

LOCK TABLES `synonym_relations` WRITE;
/*!40000 ALTER TABLE `synonym_relations` DISABLE KEYS */;
INSERT INTO `synonym_relations` VALUES (1);
/*!40000 ALTER TABLE `synonym_relations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `synonyms`
--

DROP TABLE IF EXISTS `synonyms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `synonyms` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name_id` int(10) unsigned NOT NULL,
  `synonym_relation_id` tinyint(3) unsigned NOT NULL COMMENT 'the relationship this synonym has with the preferred name for this node',
  `language_id` smallint(5) unsigned NOT NULL COMMENT 'generally only set when the synonym is a common name',
  `hierarchy_entry_id` int(10) unsigned NOT NULL COMMENT 'associated node in the hierarchy',
  `preferred` tinyint(3) unsigned NOT NULL COMMENT 'set to 1 if this is a common name and is the preferred common name for the node in its language',
  `hierarchy_id` smallint(5) unsigned NOT NULL COMMENT 'this is redundant as it can be found via the synonym''s hierarchy_entry. I think its here for legacy reasons, but we can probably get rid of it',
  `vetted_id` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `published` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `taxon_remarks` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_names` (`name_id`,`synonym_relation_id`,`language_id`,`hierarchy_entry_id`,`hierarchy_id`),
  KEY `hierarchy_entry_id` (`hierarchy_entry_id`),
  KEY `name_id` (`name_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Used to assigned taxonomic synonyms and common names to hier';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `synonyms`
--

LOCK TABLES `synonyms` WRITE;
/*!40000 ALTER TABLE `synonyms` DISABLE KEYS */;
/*!40000 ALTER TABLE `synonyms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `table_of_contents`
--

DROP TABLE IF EXISTS `table_of_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `table_of_contents` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` smallint(5) unsigned NOT NULL COMMENT 'refers to the parent taxon_of_contents id. Our table of content is only two levels deep',
  `view_order` smallint(5) unsigned DEFAULT '0' COMMENT 'used to organize the view of the table of contents on the species page in order of priority, not alphabetically',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `table_of_contents`
--

LOCK TABLES `table_of_contents` WRITE;
/*!40000 ALTER TABLE `table_of_contents` DISABLE KEYS */;
INSERT INTO `table_of_contents` VALUES (1,0,1);
/*!40000 ALTER TABLE `table_of_contents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxon_classifications_locks`
--

DROP TABLE IF EXISTS `taxon_classifications_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxon_classifications_locks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `taxon_concept_id` (`taxon_concept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxon_classifications_locks`
--

LOCK TABLES `taxon_classifications_locks` WRITE;
/*!40000 ALTER TABLE `taxon_classifications_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `taxon_classifications_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxon_concept_content`
--

DROP TABLE IF EXISTS `taxon_concept_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxon_concept_content` (
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `text` tinyint(3) unsigned NOT NULL,
  `text_unpublished` tinyint(3) unsigned NOT NULL,
  `image` tinyint(3) unsigned NOT NULL,
  `image_unpublished` tinyint(3) unsigned NOT NULL,
  `child_image` tinyint(3) unsigned NOT NULL,
  `child_image_unpublished` tinyint(3) unsigned NOT NULL,
  `flash` tinyint(3) unsigned NOT NULL,
  `youtube` tinyint(3) unsigned NOT NULL,
  `map` tinyint(3) unsigned NOT NULL,
  `content_level` tinyint(3) unsigned NOT NULL,
  `image_object_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`taxon_concept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxon_concept_content`
--

LOCK TABLES `taxon_concept_content` WRITE;
/*!40000 ALTER TABLE `taxon_concept_content` DISABLE KEYS */;
/*!40000 ALTER TABLE `taxon_concept_content` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxon_concept_exemplar_articles`
--

DROP TABLE IF EXISTS `taxon_concept_exemplar_articles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxon_concept_exemplar_articles` (
  `taxon_concept_id` int(11) NOT NULL AUTO_INCREMENT,
  `data_object_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`taxon_concept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxon_concept_exemplar_articles`
--

LOCK TABLES `taxon_concept_exemplar_articles` WRITE;
/*!40000 ALTER TABLE `taxon_concept_exemplar_articles` DISABLE KEYS */;
/*!40000 ALTER TABLE `taxon_concept_exemplar_articles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxon_concept_exemplar_images`
--

DROP TABLE IF EXISTS `taxon_concept_exemplar_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxon_concept_exemplar_images` (
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `data_object_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`taxon_concept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxon_concept_exemplar_images`
--

LOCK TABLES `taxon_concept_exemplar_images` WRITE;
/*!40000 ALTER TABLE `taxon_concept_exemplar_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `taxon_concept_exemplar_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxon_concept_metrics`
--

DROP TABLE IF EXISTS `taxon_concept_metrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxon_concept_metrics` (
  `taxon_concept_id` int(11) NOT NULL DEFAULT '0',
  `image_total` mediumint(9) DEFAULT NULL,
  `image_trusted` mediumint(9) DEFAULT NULL,
  `image_untrusted` mediumint(9) DEFAULT NULL,
  `image_unreviewed` mediumint(9) DEFAULT NULL,
  `image_total_words` mediumint(9) DEFAULT NULL,
  `image_trusted_words` mediumint(9) DEFAULT NULL,
  `image_untrusted_words` mediumint(9) DEFAULT NULL,
  `image_unreviewed_words` mediumint(9) DEFAULT NULL,
  `text_total` mediumint(9) DEFAULT NULL,
  `text_trusted` mediumint(9) DEFAULT NULL,
  `text_untrusted` mediumint(9) DEFAULT NULL,
  `text_unreviewed` mediumint(9) DEFAULT NULL,
  `text_total_words` mediumint(9) DEFAULT NULL,
  `text_trusted_words` mediumint(9) DEFAULT NULL,
  `text_untrusted_words` mediumint(9) DEFAULT NULL,
  `text_unreviewed_words` mediumint(9) DEFAULT NULL,
  `video_total` mediumint(9) DEFAULT NULL,
  `video_trusted` mediumint(9) DEFAULT NULL,
  `video_untrusted` mediumint(9) DEFAULT NULL,
  `video_unreviewed` mediumint(9) DEFAULT NULL,
  `video_total_words` mediumint(9) DEFAULT NULL,
  `video_trusted_words` mediumint(9) DEFAULT NULL,
  `video_untrusted_words` mediumint(9) DEFAULT NULL,
  `video_unreviewed_words` mediumint(9) DEFAULT NULL,
  `sound_total` mediumint(9) DEFAULT NULL,
  `sound_trusted` mediumint(9) DEFAULT NULL,
  `sound_untrusted` mediumint(9) DEFAULT NULL,
  `sound_unreviewed` mediumint(9) DEFAULT NULL,
  `sound_total_words` mediumint(9) DEFAULT NULL,
  `sound_trusted_words` mediumint(9) DEFAULT NULL,
  `sound_untrusted_words` mediumint(9) DEFAULT NULL,
  `sound_unreviewed_words` mediumint(9) DEFAULT NULL,
  `flash_total` mediumint(9) DEFAULT NULL,
  `flash_trusted` mediumint(9) DEFAULT NULL,
  `flash_untrusted` mediumint(9) DEFAULT NULL,
  `flash_unreviewed` mediumint(9) DEFAULT NULL,
  `flash_total_words` mediumint(9) DEFAULT NULL,
  `flash_trusted_words` mediumint(9) DEFAULT NULL,
  `flash_untrusted_words` mediumint(9) DEFAULT NULL,
  `flash_unreviewed_words` mediumint(9) DEFAULT NULL,
  `youtube_total` mediumint(9) DEFAULT NULL,
  `youtube_trusted` mediumint(9) DEFAULT NULL,
  `youtube_untrusted` mediumint(9) DEFAULT NULL,
  `youtube_unreviewed` mediumint(9) DEFAULT NULL,
  `youtube_total_words` mediumint(9) DEFAULT NULL,
  `youtube_trusted_words` mediumint(9) DEFAULT NULL,
  `youtube_untrusted_words` mediumint(9) DEFAULT NULL,
  `youtube_unreviewed_words` mediumint(9) DEFAULT NULL,
  `iucn_total` tinyint(3) DEFAULT NULL,
  `iucn_trusted` tinyint(3) DEFAULT NULL,
  `iucn_untrusted` tinyint(3) DEFAULT NULL,
  `iucn_unreviewed` tinyint(3) DEFAULT NULL,
  `iucn_total_words` tinyint(3) DEFAULT NULL,
  `iucn_trusted_words` tinyint(3) DEFAULT NULL,
  `iucn_untrusted_words` tinyint(3) DEFAULT NULL,
  `iucn_unreviewed_words` tinyint(3) DEFAULT NULL,
  `data_object_references` smallint(6) DEFAULT NULL,
  `info_items` smallint(6) DEFAULT NULL,
  `BHL_publications` smallint(6) DEFAULT NULL,
  `content_partners` smallint(6) DEFAULT NULL,
  `outlinks` smallint(6) DEFAULT NULL,
  `has_GBIF_map` tinyint(1) DEFAULT NULL,
  `has_biomedical_terms` tinyint(1) DEFAULT NULL,
  `user_submitted_text` smallint(6) DEFAULT NULL,
  `submitted_text_providers` smallint(6) DEFAULT NULL,
  `common_names` smallint(6) DEFAULT NULL,
  `common_name_providers` smallint(6) DEFAULT NULL,
  `synonyms` smallint(6) DEFAULT NULL,
  `synonym_providers` smallint(6) DEFAULT NULL,
  `page_views` mediumint(9) DEFAULT NULL,
  `unique_page_views` mediumint(9) DEFAULT NULL,
  `richness_score` float DEFAULT NULL,
  `map_total` mediumint(9) DEFAULT NULL,
  `map_trusted` mediumint(9) DEFAULT NULL,
  `map_untrusted` mediumint(9) DEFAULT NULL,
  `map_unreviewed` mediumint(9) DEFAULT NULL,
  PRIMARY KEY (`taxon_concept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxon_concept_metrics`
--

LOCK TABLES `taxon_concept_metrics` WRITE;
/*!40000 ALTER TABLE `taxon_concept_metrics` DISABLE KEYS */;
/*!40000 ALTER TABLE `taxon_concept_metrics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxon_concept_names`
--

DROP TABLE IF EXISTS `taxon_concept_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxon_concept_names` (
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `name_id` int(10) unsigned NOT NULL,
  `source_hierarchy_entry_id` int(10) unsigned NOT NULL COMMENT 'recommended; if the name came from a certain hierarchy entry or its associated synonyms, the id of the entry will be listed here. This can be used to track down the source or attribution for a given name',
  `language_id` int(10) unsigned NOT NULL,
  `vern` tinyint(3) unsigned NOT NULL COMMENT 'boolean; if this is a common name, set this field to 1',
  `preferred` tinyint(3) unsigned NOT NULL,
  `synonym_id` int(11) NOT NULL DEFAULT '0',
  `vetted_id` int(11) DEFAULT '0',
  PRIMARY KEY (`taxon_concept_id`,`name_id`,`source_hierarchy_entry_id`,`language_id`,`synonym_id`),
  KEY `vern` (`vern`),
  KEY `name_id` (`name_id`),
  KEY `source_hierarchy_entry_id` (`source_hierarchy_entry_id`),
  KEY `index_taxon_concept_names_on_synonym_id` (`synonym_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxon_concept_names`
--

LOCK TABLES `taxon_concept_names` WRITE;
/*!40000 ALTER TABLE `taxon_concept_names` DISABLE KEYS */;
/*!40000 ALTER TABLE `taxon_concept_names` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxon_concept_preferred_entries`
--

DROP TABLE IF EXISTS `taxon_concept_preferred_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxon_concept_preferred_entries` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `taxon_concept_id` (`taxon_concept_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxon_concept_preferred_entries`
--

LOCK TABLES `taxon_concept_preferred_entries` WRITE;
/*!40000 ALTER TABLE `taxon_concept_preferred_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `taxon_concept_preferred_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxon_concept_preferred_entries_tmp`
--

DROP TABLE IF EXISTS `taxon_concept_preferred_entries_tmp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxon_concept_preferred_entries_tmp` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `taxon_concept_id` (`taxon_concept_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxon_concept_preferred_entries_tmp`
--

LOCK TABLES `taxon_concept_preferred_entries_tmp` WRITE;
/*!40000 ALTER TABLE `taxon_concept_preferred_entries_tmp` DISABLE KEYS */;
/*!40000 ALTER TABLE `taxon_concept_preferred_entries_tmp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxon_concept_stats`
--

DROP TABLE IF EXISTS `taxon_concept_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxon_concept_stats` (
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `text_trusted` mediumint(8) unsigned NOT NULL,
  `text_untrusted` mediumint(8) unsigned NOT NULL,
  `image_trusted` mediumint(8) unsigned NOT NULL,
  `image_untrusted` mediumint(8) unsigned NOT NULL,
  `bhl` mediumint(8) unsigned NOT NULL,
  PRIMARY KEY (`taxon_concept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxon_concept_stats`
--

LOCK TABLES `taxon_concept_stats` WRITE;
/*!40000 ALTER TABLE `taxon_concept_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `taxon_concept_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxon_concepts`
--

DROP TABLE IF EXISTS `taxon_concepts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxon_concepts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `supercedure_id` int(10) unsigned NOT NULL COMMENT 'if concepts are at first thought to be distinct, there will be two concepts with two different ids. When they are confirmed to be the same one will be superceded by the other, and that replacement is kept track of so that older URLs can be redirected to t',
  `split_from` int(10) unsigned NOT NULL,
  `vetted_id` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'some concepts come from untrusted resources and are left untrusted until the resources become trusted',
  `published` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'some concepts come from resource left unpublished until the resource becomes published',
  PRIMARY KEY (`id`),
  KEY `supercedure_id` (`supercedure_id`),
  KEY `published` (`published`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='This table is poorly named. Used to group similar hierarchy ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxon_concepts`
--

LOCK TABLES `taxon_concepts` WRITE;
/*!40000 ALTER TABLE `taxon_concepts` DISABLE KEYS */;
/*!40000 ALTER TABLE `taxon_concepts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxon_concepts_flattened`
--

DROP TABLE IF EXISTS `taxon_concepts_flattened`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxon_concepts_flattened` (
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `ancestor_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`taxon_concept_id`,`ancestor_id`),
  KEY `ancestor_id` (`ancestor_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxon_concepts_flattened`
--

LOCK TABLES `taxon_concepts_flattened` WRITE;
/*!40000 ALTER TABLE `taxon_concepts_flattened` DISABLE KEYS */;
/*!40000 ALTER TABLE `taxon_concepts_flattened` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxon_concepts_flattened_tmp`
--

DROP TABLE IF EXISTS `taxon_concepts_flattened_tmp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taxon_concepts_flattened_tmp` (
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `ancestor_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`taxon_concept_id`,`ancestor_id`),
  KEY `ancestor_id` (`ancestor_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxon_concepts_flattened_tmp`
--

LOCK TABLES `taxon_concepts_flattened_tmp` WRITE;
/*!40000 ALTER TABLE `taxon_concepts_flattened_tmp` DISABLE KEYS */;
/*!40000 ALTER TABLE `taxon_concepts_flattened_tmp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `title_items`
--

DROP TABLE IF EXISTS `title_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `title_items` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `publication_title_id` int(10) unsigned NOT NULL,
  `bar_code` varchar(50) NOT NULL,
  `marc_item_id` varchar(50) NOT NULL,
  `call_number` varchar(100) NOT NULL,
  `volume_info` varchar(100) NOT NULL,
  `url` varchar(255) CHARACTER SET ascii NOT NULL COMMENT 'url for the description page for this item',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Used for BHL. Publications can have different volumes, versi';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `title_items`
--

LOCK TABLES `title_items` WRITE;
/*!40000 ALTER TABLE `title_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `title_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `top_concept_images`
--

DROP TABLE IF EXISTS `top_concept_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `top_concept_images` (
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `data_object_id` int(10) unsigned NOT NULL,
  `view_order` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`taxon_concept_id`,`data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `top_concept_images`
--

LOCK TABLES `top_concept_images` WRITE;
/*!40000 ALTER TABLE `top_concept_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `top_concept_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `top_images`
--

DROP TABLE IF EXISTS `top_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `top_images` (
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `data_object_id` int(10) unsigned NOT NULL COMMENT 'data object id of the image',
  `view_order` smallint(5) unsigned NOT NULL COMMENT 'order in which to show the images, lower values shown first',
  PRIMARY KEY (`hierarchy_entry_id`,`data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='caches the top 300 or so best images for a particular hierar';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `top_images`
--

LOCK TABLES `top_images` WRITE;
/*!40000 ALTER TABLE `top_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `top_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `top_images_tmp`
--

DROP TABLE IF EXISTS `top_images_tmp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `top_images_tmp` (
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `data_object_id` int(10) unsigned NOT NULL COMMENT 'data object id of the image',
  `view_order` smallint(5) unsigned NOT NULL COMMENT 'order in which to show the images, lower values shown first',
  PRIMARY KEY (`hierarchy_entry_id`,`data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='caches the top 300 or so best images for a particular hierar';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `top_images_tmp`
--

LOCK TABLES `top_images_tmp` WRITE;
/*!40000 ALTER TABLE `top_images_tmp` DISABLE KEYS */;
/*!40000 ALTER TABLE `top_images_tmp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `top_species_images`
--

DROP TABLE IF EXISTS `top_species_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `top_species_images` (
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `data_object_id` int(10) unsigned NOT NULL COMMENT 'data object id of the image',
  `view_order` smallint(5) unsigned NOT NULL COMMENT 'order in which to show the images, lower values shown first',
  PRIMARY KEY (`hierarchy_entry_id`,`data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='caches the top 300 or so best images for a particular hierar';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `top_species_images`
--

LOCK TABLES `top_species_images` WRITE;
/*!40000 ALTER TABLE `top_species_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `top_species_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `top_unpublished_concept_images`
--

DROP TABLE IF EXISTS `top_unpublished_concept_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `top_unpublished_concept_images` (
  `taxon_concept_id` int(10) unsigned NOT NULL,
  `data_object_id` int(10) unsigned NOT NULL,
  `view_order` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`taxon_concept_id`,`data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `top_unpublished_concept_images`
--

LOCK TABLES `top_unpublished_concept_images` WRITE;
/*!40000 ALTER TABLE `top_unpublished_concept_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `top_unpublished_concept_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `top_unpublished_images`
--

DROP TABLE IF EXISTS `top_unpublished_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `top_unpublished_images` (
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `data_object_id` int(10) unsigned NOT NULL,
  `view_order` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`hierarchy_entry_id`,`data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='cache the top 300 or so images which are unpublished - for c';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `top_unpublished_images`
--

LOCK TABLES `top_unpublished_images` WRITE;
/*!40000 ALTER TABLE `top_unpublished_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `top_unpublished_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `top_unpublished_images_tmp`
--

DROP TABLE IF EXISTS `top_unpublished_images_tmp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `top_unpublished_images_tmp` (
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `data_object_id` int(10) unsigned NOT NULL,
  `view_order` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`hierarchy_entry_id`,`data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='cache the top 300 or so images which are unpublished - for c';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `top_unpublished_images_tmp`
--

LOCK TABLES `top_unpublished_images_tmp` WRITE;
/*!40000 ALTER TABLE `top_unpublished_images_tmp` DISABLE KEYS */;
/*!40000 ALTER TABLE `top_unpublished_images_tmp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `top_unpublished_species_images`
--

DROP TABLE IF EXISTS `top_unpublished_species_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `top_unpublished_species_images` (
  `hierarchy_entry_id` int(10) unsigned NOT NULL,
  `data_object_id` int(10) unsigned NOT NULL,
  `view_order` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`hierarchy_entry_id`,`data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='cache the top 300 or so images which are unpublished - for c';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `top_unpublished_species_images`
--

LOCK TABLES `top_unpublished_species_images` WRITE;
/*!40000 ALTER TABLE `top_unpublished_species_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `top_unpublished_species_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_agent_roles`
--

DROP TABLE IF EXISTS `translated_agent_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_agent_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agent_role_id` tinyint(3) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `agent_role_id` (`agent_role_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_agent_roles`
--

LOCK TABLES `translated_agent_roles` WRITE;
/*!40000 ALTER TABLE `translated_agent_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_agent_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_audiences`
--

DROP TABLE IF EXISTS `translated_audiences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_audiences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `audience_id` tinyint(3) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `audience_id` (`audience_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_audiences`
--

LOCK TABLES `translated_audiences` WRITE;
/*!40000 ALTER TABLE `translated_audiences` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_audiences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_collection_types`
--

DROP TABLE IF EXISTS `translated_collection_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_collection_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collection_type_id` smallint(5) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `collection_type_id` (`collection_type_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_collection_types`
--

LOCK TABLES `translated_collection_types` WRITE;
/*!40000 ALTER TABLE `translated_collection_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_collection_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_contact_roles`
--

DROP TABLE IF EXISTS `translated_contact_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_contact_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_role_id` tinyint(3) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(255) NOT NULL,
  `phonetic_label` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `agent_contact_role_id` (`contact_role_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_contact_roles`
--

LOCK TABLES `translated_contact_roles` WRITE;
/*!40000 ALTER TABLE `translated_contact_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_contact_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_contact_subjects`
--

DROP TABLE IF EXISTS `translated_contact_subjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_contact_subjects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_subject_id` int(10) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `phonetic_action_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `contact_subject_id` (`contact_subject_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_contact_subjects`
--

LOCK TABLES `translated_contact_subjects` WRITE;
/*!40000 ALTER TABLE `translated_contact_subjects` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_contact_subjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_content_page_archives`
--

DROP TABLE IF EXISTS `translated_content_page_archives`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_content_page_archives` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `translated_content_page_id` int(11) DEFAULT NULL,
  `content_page_id` int(11) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `left_content` text,
  `main_content` text,
  `meta_keywords` varchar(255) DEFAULT NULL,
  `meta_description` varchar(255) DEFAULT NULL,
  `original_creation_date` date DEFAULT NULL,
  `created_at` date DEFAULT NULL,
  `updated_at` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_content_page_archives`
--

LOCK TABLES `translated_content_page_archives` WRITE;
/*!40000 ALTER TABLE `translated_content_page_archives` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_content_page_archives` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_content_pages`
--

DROP TABLE IF EXISTS `translated_content_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_content_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content_page_id` int(11) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `left_content` text,
  `main_content` text,
  `meta_keywords` varchar(255) DEFAULT NULL,
  `meta_description` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `active_translation` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `content_page_id` (`content_page_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_content_pages`
--

LOCK TABLES `translated_content_pages` WRITE;
/*!40000 ALTER TABLE `translated_content_pages` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_content_pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_content_partner_statuses`
--

DROP TABLE IF EXISTS `translated_content_partner_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_content_partner_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content_partner_status_id` tinyint(3) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `agent_status_id` (`content_partner_status_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_content_partner_statuses`
--

LOCK TABLES `translated_content_partner_statuses` WRITE;
/*!40000 ALTER TABLE `translated_content_partner_statuses` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_content_partner_statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_content_tables`
--

DROP TABLE IF EXISTS `translated_content_tables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_content_tables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content_table_id` int(11) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `phonetic_label` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_content_tables`
--

LOCK TABLES `translated_content_tables` WRITE;
/*!40000 ALTER TABLE `translated_content_tables` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_content_tables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_data_types`
--

DROP TABLE IF EXISTS `translated_data_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_data_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data_type_id` smallint(5) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `data_type_id` (`data_type_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_data_types`
--

LOCK TABLES `translated_data_types` WRITE;
/*!40000 ALTER TABLE `translated_data_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_data_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_info_items`
--

DROP TABLE IF EXISTS `translated_info_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_info_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `info_item_id` smallint(5) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `info_item_id` (`info_item_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_info_items`
--

LOCK TABLES `translated_info_items` WRITE;
/*!40000 ALTER TABLE `translated_info_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_info_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_languages`
--

DROP TABLE IF EXISTS `translated_languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `original_language_id` smallint(5) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `original_language_id` (`original_language_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_languages`
--

LOCK TABLES `translated_languages` WRITE;
/*!40000 ALTER TABLE `translated_languages` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_licenses`
--

DROP TABLE IF EXISTS `translated_licenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_licenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `license_id` smallint(5) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `description` varchar(400) NOT NULL,
  `phonetic_description` varchar(400) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `license_id` (`license_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_licenses`
--

LOCK TABLES `translated_licenses` WRITE;
/*!40000 ALTER TABLE `translated_licenses` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_licenses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_link_types`
--

DROP TABLE IF EXISTS `translated_link_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_link_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `link_type_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `label` varchar(255) NOT NULL,
  `phonetic_label` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `link_type_id` (`link_type_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_link_types`
--

LOCK TABLES `translated_link_types` WRITE;
/*!40000 ALTER TABLE `translated_link_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_link_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_mime_types`
--

DROP TABLE IF EXISTS `translated_mime_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_mime_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mime_type_id` smallint(5) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mime_type_id` (`mime_type_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_mime_types`
--

LOCK TABLES `translated_mime_types` WRITE;
/*!40000 ALTER TABLE `translated_mime_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_mime_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_news_items`
--

DROP TABLE IF EXISTS `translated_news_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_news_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `news_item_id` int(10) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `body` text NOT NULL,
  `title` varchar(255) DEFAULT '',
  `active_translation` tinyint(4) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `news_item_id` (`news_item_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_news_items`
--

LOCK TABLES `translated_news_items` WRITE;
/*!40000 ALTER TABLE `translated_news_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_news_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_permissions`
--

DROP TABLE IF EXISTS `translated_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `language_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_translated_permissions_on_permission_id_and_language_id` (`permission_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_permissions`
--

LOCK TABLES `translated_permissions` WRITE;
/*!40000 ALTER TABLE `translated_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_ranks`
--

DROP TABLE IF EXISTS `translated_ranks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_ranks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rank_id` smallint(5) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rank_id` (`rank_id`,`language_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_ranks`
--

LOCK TABLES `translated_ranks` WRITE;
/*!40000 ALTER TABLE `translated_ranks` DISABLE KEYS */;
INSERT INTO `translated_ranks` VALUES (1,1,1,'kingdom',NULL),(2,2,1,'regn.',NULL),(3,3,1,'phylum',NULL),(4,4,1,'phyl.',NULL),(5,5,1,'class',NULL),(6,6,1,'cl.',NULL),(7,7,1,'order',NULL),(8,8,1,'ord.',NULL),(9,9,1,'family',NULL),(10,10,1,'fam.',NULL),(11,11,1,'genus',NULL),(12,12,1,'gen.',NULL),(13,13,1,'species',NULL),(14,14,1,'sp.',NULL),(15,15,1,'sp',NULL),(16,16,1,'subspecies',NULL),(17,17,1,'subsp',NULL),(18,18,1,'subsp.',NULL),(19,19,1,'variety',NULL),(20,20,1,'var',NULL),(21,21,1,'var.',NULL),(22,22,1,'infraspecies',NULL),(23,23,1,'form',NULL),(24,24,1,'nothospecies',NULL),(25,25,1,'nothosubspecies',NULL),(26,26,1,'nothovariety',NULL);
/*!40000 ALTER TABLE `translated_ranks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_resource_statuses`
--

DROP TABLE IF EXISTS `translated_resource_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_resource_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `resource_status_id` int(11) NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resource_status_id` (`resource_status_id`,`language_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_resource_statuses`
--

LOCK TABLES `translated_resource_statuses` WRITE;
/*!40000 ALTER TABLE `translated_resource_statuses` DISABLE KEYS */;
INSERT INTO `translated_resource_statuses` VALUES (1,1,1,'Force Harvest',NULL),(2,2,1,'Being Processed',NULL),(3,3,1,'Processed',NULL),(4,4,1,'Validated',NULL),(5,5,1,'Validation Failed',NULL),(6,6,1,'Processing Failed',NULL),(7,7,1,'Upload Failed',NULL),(8,8,1,'Published',NULL),(9,9,1,'Harvest Requested',NULL);
/*!40000 ALTER TABLE `translated_resource_statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_service_types`
--

DROP TABLE IF EXISTS `translated_service_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_service_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `service_type_id` smallint(5) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `service_type_id` (`service_type_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_service_types`
--

LOCK TABLES `translated_service_types` WRITE;
/*!40000 ALTER TABLE `translated_service_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_service_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_sort_styles`
--

DROP TABLE IF EXISTS `translated_sort_styles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_sort_styles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) DEFAULT NULL,
  `language_id` int(11) NOT NULL,
  `sort_style_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_sort_styles`
--

LOCK TABLES `translated_sort_styles` WRITE;
/*!40000 ALTER TABLE `translated_sort_styles` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_sort_styles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_statuses`
--

DROP TABLE IF EXISTS `translated_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status_id` smallint(5) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `status_id` (`status_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_statuses`
--

LOCK TABLES `translated_statuses` WRITE;
/*!40000 ALTER TABLE `translated_statuses` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_synonym_relations`
--

DROP TABLE IF EXISTS `translated_synonym_relations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_synonym_relations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `synonym_relation_id` smallint(5) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `synonym_relation_id` (`synonym_relation_id`,`language_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_synonym_relations`
--

LOCK TABLES `translated_synonym_relations` WRITE;
/*!40000 ALTER TABLE `translated_synonym_relations` DISABLE KEYS */;
INSERT INTO `translated_synonym_relations` VALUES (1,1,1,'synonym',NULL);
/*!40000 ALTER TABLE `translated_synonym_relations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_table_of_contents`
--

DROP TABLE IF EXISTS `translated_table_of_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_table_of_contents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `table_of_contents_id` smallint(5) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `table_of_contents_id` (`table_of_contents_id`,`language_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_table_of_contents`
--

LOCK TABLES `translated_table_of_contents` WRITE;
/*!40000 ALTER TABLE `translated_table_of_contents` DISABLE KEYS */;
INSERT INTO `translated_table_of_contents` VALUES (1,1,1,'Relevance',NULL);
/*!40000 ALTER TABLE `translated_table_of_contents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_untrust_reasons`
--

DROP TABLE IF EXISTS `translated_untrust_reasons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_untrust_reasons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `untrust_reason_id` int(10) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `untrust_reason_id` (`untrust_reason_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_untrust_reasons`
--

LOCK TABLES `translated_untrust_reasons` WRITE;
/*!40000 ALTER TABLE `translated_untrust_reasons` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_untrust_reasons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_user_identities`
--

DROP TABLE IF EXISTS `translated_user_identities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_user_identities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_identity_id` smallint(5) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_identity_id` (`user_identity_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_user_identities`
--

LOCK TABLES `translated_user_identities` WRITE;
/*!40000 ALTER TABLE `translated_user_identities` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_user_identities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_vetted`
--

DROP TABLE IF EXISTS `translated_vetted`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_vetted` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vetted_id` int(10) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `vetted_id` (`vetted_id`,`language_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_vetted`
--

LOCK TABLES `translated_vetted` WRITE;
/*!40000 ALTER TABLE `translated_vetted` DISABLE KEYS */;
INSERT INTO `translated_vetted` VALUES (1,1,1,'Untrusted',NULL),(2,2,1,'Trusted',NULL),(3,3,1,'Unknown',NULL);
/*!40000 ALTER TABLE `translated_vetted` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_view_styles`
--

DROP TABLE IF EXISTS `translated_view_styles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_view_styles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) DEFAULT NULL,
  `language_id` int(11) NOT NULL,
  `view_style_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_view_styles`
--

LOCK TABLES `translated_view_styles` WRITE;
/*!40000 ALTER TABLE `translated_view_styles` DISABLE KEYS */;
/*!40000 ALTER TABLE `translated_view_styles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translated_visibilities`
--

DROP TABLE IF EXISTS `translated_visibilities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translated_visibilities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `visibility_id` int(10) unsigned NOT NULL,
  `language_id` smallint(5) unsigned NOT NULL,
  `label` varchar(300) NOT NULL,
  `phonetic_label` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `visibility_id` (`visibility_id`,`language_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translated_visibilities`
--

LOCK TABLES `translated_visibilities` WRITE;
/*!40000 ALTER TABLE `translated_visibilities` DISABLE KEYS */;
INSERT INTO `translated_visibilities` VALUES (1,1,1,'Preview',NULL),(2,2,1,'Invisible',NULL),(3,3,1,'Visible',NULL);
/*!40000 ALTER TABLE `translated_visibilities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `unique_visitors`
--

DROP TABLE IF EXISTS `unique_visitors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unique_visitors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `count` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `unique_visitors`
--

LOCK TABLES `unique_visitors` WRITE;
/*!40000 ALTER TABLE `unique_visitors` DISABLE KEYS */;
/*!40000 ALTER TABLE `unique_visitors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `untrust_reasons`
--

DROP TABLE IF EXISTS `untrust_reasons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `untrust_reasons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `class_name` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `untrust_reasons`
--

LOCK TABLES `untrust_reasons` WRITE;
/*!40000 ALTER TABLE `untrust_reasons` DISABLE KEYS */;
/*!40000 ALTER TABLE `untrust_reasons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_identities`
--

DROP TABLE IF EXISTS `user_identities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_identities` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `sort_order` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_identities`
--

LOCK TABLES `user_identities` WRITE;
/*!40000 ALTER TABLE `user_identities` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_identities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_infos`
--

DROP TABLE IF EXISTS `user_infos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_infos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `areas_of_interest` varchar(255) DEFAULT NULL,
  `heard_of_eol` varchar(128) DEFAULT NULL,
  `interested_in_contributing` tinyint(1) DEFAULT NULL,
  `interested_in_curating` tinyint(1) DEFAULT NULL,
  `interested_in_advisory_forum` tinyint(1) DEFAULT NULL,
  `show_information` tinyint(1) DEFAULT NULL,
  `age_range` varchar(16) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_primary_role_id` int(11) DEFAULT NULL,
  `interested_in_development` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_infos`
--

LOCK TABLES `user_infos` WRITE;
/*!40000 ALTER TABLE `user_infos` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_infos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_primary_roles`
--

DROP TABLE IF EXISTS `user_primary_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_primary_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_primary_roles`
--

LOCK TABLES `user_primary_roles` WRITE;
/*!40000 ALTER TABLE `user_primary_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_primary_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `remote_ip` varchar(24) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `given_name` varchar(255) DEFAULT NULL,
  `family_name` varchar(255) DEFAULT NULL,
  `identity_url` varchar(255) DEFAULT NULL,
  `username` varchar(32) DEFAULT NULL,
  `hashed_password` varchar(32) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `notes` text,
  `curator_approved` tinyint(1) NOT NULL DEFAULT '0',
  `curator_verdict_by_id` int(11) DEFAULT NULL,
  `curator_verdict_at` datetime DEFAULT NULL,
  `credentials` text NOT NULL,
  `validation_code` varchar(255) DEFAULT '',
  `failed_login_attempts` int(11) DEFAULT '0',
  `curator_scope` text NOT NULL,
  `remember_token` varchar(255) DEFAULT NULL,
  `remember_token_expires_at` datetime DEFAULT NULL,
  `recover_account_token` char(40) DEFAULT NULL,
  `recover_account_token_expires_at` datetime DEFAULT NULL,
  `agent_id` int(10) unsigned DEFAULT NULL,
  `email_reports_frequency_hours` int(11) DEFAULT '24',
  `last_report_email` datetime DEFAULT NULL,
  `api_key` char(40) DEFAULT NULL,
  `logo_url` varchar(255) CHARACTER SET ascii DEFAULT NULL,
  `logo_cache_url` bigint(20) unsigned DEFAULT NULL,
  `logo_file_name` varchar(255) DEFAULT NULL,
  `logo_content_type` varchar(255) DEFAULT NULL,
  `logo_file_size` int(10) unsigned DEFAULT '0',
  `tag_line` varchar(255) DEFAULT NULL,
  `agreed_with_terms` tinyint(1) DEFAULT NULL,
  `bio` text,
  `curator_level_id` int(11) DEFAULT NULL,
  `requested_curator_level_id` int(11) DEFAULT NULL,
  `requested_curator_at` datetime DEFAULT NULL,
  `admin` tinyint(1) DEFAULT NULL,
  `hidden` tinyint(4) DEFAULT '0',
  `last_notification_at` datetime DEFAULT '2013-04-09 12:06:23',
  `last_message_at` datetime DEFAULT '2013-04-09 12:06:24',
  `disable_email_notifications` tinyint(1) DEFAULT '0',
  `news_in_preferred_language` tinyint(1) DEFAULT '0',
  `number_of_forum_posts` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_agent_id` (`agent_id`),
  UNIQUE KEY `unique_username` (`username`),
  KEY `index_users_on_created_at` (`created_at`),
  KEY `index_users_on_api_key` (`api_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_data_objects`
--

DROP TABLE IF EXISTS `users_data_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_data_objects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `data_object_id` int(11) DEFAULT NULL,
  `taxon_concept_id` int(11) DEFAULT NULL,
  `vetted_id` int(11) NOT NULL,
  `visibility_id` int(11) DEFAULT NULL,
  `created_at` date DEFAULT NULL,
  `updated_at` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_users_data_objects_on_data_object_id` (`data_object_id`),
  KEY `index_users_data_objects_on_taxon_concept_id` (`taxon_concept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_data_objects`
--

LOCK TABLES `users_data_objects` WRITE;
/*!40000 ALTER TABLE `users_data_objects` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_data_objects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_data_objects_ratings`
--

DROP TABLE IF EXISTS `users_data_objects_ratings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_data_objects_ratings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `data_object_id` int(11) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `data_object_guid` varchar(32) CHARACTER SET ascii NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `weight` int(11) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_users_data_objects_ratings_1` (`data_object_guid`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_data_objects_ratings`
--

LOCK TABLES `users_data_objects_ratings` WRITE;
/*!40000 ALTER TABLE `users_data_objects_ratings` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_data_objects_ratings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_user_identities`
--

DROP TABLE IF EXISTS `users_user_identities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_user_identities` (
  `user_id` int(10) unsigned NOT NULL,
  `user_identity_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`user_identity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_user_identities`
--

LOCK TABLES `users_user_identities` WRITE;
/*!40000 ALTER TABLE `users_user_identities` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_user_identities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vetted`
--

DROP TABLE IF EXISTS `vetted`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vetted` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `view_order` tinyint(4) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='Vetted statuses';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vetted`
--

LOCK TABLES `vetted` WRITE;
/*!40000 ALTER TABLE `vetted` DISABLE KEYS */;
INSERT INTO `vetted` VALUES (1,'2013-09-16 00:57:18','2013-09-16 00:57:18',3),(2,'2013-09-16 00:57:18','2013-09-16 00:57:18',1),(3,'2013-09-16 00:57:18','2013-09-16 00:57:18',2);
/*!40000 ALTER TABLE `vetted` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `view_styles`
--

DROP TABLE IF EXISTS `view_styles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `view_styles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `max_items_per_page` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `view_styles`
--

LOCK TABLES `view_styles` WRITE;
/*!40000 ALTER TABLE `view_styles` DISABLE KEYS */;
/*!40000 ALTER TABLE `view_styles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visibilities`
--

DROP TABLE IF EXISTS `visibilities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visibilities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visibilities`
--

LOCK TABLES `visibilities` WRITE;
/*!40000 ALTER TABLE `visibilities` DISABLE KEYS */;
INSERT INTO `visibilities` VALUES (1,'2013-09-15 23:45:55','2013-09-15 23:45:55'),(2,'2013-09-15 23:45:55','2013-09-15 23:45:55'),(3,'2013-09-16 00:57:18','2013-09-16 00:57:18');
/*!40000 ALTER TABLE `visibilities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `whats_this`
--

DROP TABLE IF EXISTS `whats_this`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whats_this` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) DEFAULT NULL,
  `url` varchar(128) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `whats_this`
--

LOCK TABLES `whats_this` WRITE;
/*!40000 ALTER TABLE `whats_this` DISABLE KEYS */;
/*!40000 ALTER TABLE `whats_this` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wikipedia_queue`
--

DROP TABLE IF EXISTS `wikipedia_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wikipedia_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `revision_id` int(11) NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `harvested_at` timestamp NULL DEFAULT NULL,
  `harvest_succeeded` tinyint(3) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wikipedia_queue`
--

LOCK TABLES `wikipedia_queue` WRITE;
/*!40000 ALTER TABLE `wikipedia_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `wikipedia_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `worklist_ignored_data_objects`
--

DROP TABLE IF EXISTS `worklist_ignored_data_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `worklist_ignored_data_objects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `data_object_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_worklist_ignored_data_objects_on_data_object_id` (`data_object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `worklist_ignored_data_objects`
--

LOCK TABLES `worklist_ignored_data_objects` WRITE;
/*!40000 ALTER TABLE `worklist_ignored_data_objects` DISABLE KEYS */;
/*!40000 ALTER TABLE `worklist_ignored_data_objects` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-05-10 11:47:53
