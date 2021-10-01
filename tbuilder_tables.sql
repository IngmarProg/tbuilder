-- phpMyAdmin SQL Dump
-- version 5.1.1
-- Author: Ingmar Tammevali www.stiig.com
-- Serveri versioon: 10.4.19-MariaDB-log


SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Andmebaas: `d74889_tbuilder`
--
CREATE DATABASE IF NOT EXISTS `d74889_tbuilder` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `d74889_tbuilder`;

-- --------------------------------------------------------

--
-- Tabeli struktuur tabelile `assets`
--

CREATE TABLE `assets` (
  `id` int(11) NOT NULL,
  `asset_name` varchar(255) DEFAULT NULL,
  `asset_code` varchar(110) DEFAULT NULL,
  `type_classificator_id` int(11) DEFAULT NULL,
  `sp_employee_id` int(11) DEFAULT NULL,
  `base_warehouse_id` int(11) DEFAULT NULL,
  `status_classificator_id` int(11) DEFAULT NULL,
  `model_name` varchar(45) DEFAULT NULL,
  `manufact_clf_id` int(11) DEFAULT NULL,
  `manufact_name` varchar(60) DEFAULT NULL,
  `serial_nr` varchar(85) DEFAULT NULL,
  `purchase_date` datetime DEFAULT NULL,
  `warranty_expiration_date` datetime DEFAULT NULL,
  `seller_name` varchar(150) DEFAULT NULL,
  `next_maintenance_date` datetime DEFAULT NULL,
  `maintenance_interval_clf_id` int(11) DEFAULT NULL,
  `comments` mediumtext DEFAULT NULL,
  `booking_start` datetime DEFAULT NULL,
  `booking_end` datetime DEFAULT NULL,
  `bookedby_employee_id` int(11) DEFAULT NULL,
  `available_units` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `row_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `changed_by` int(11) DEFAULT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabeli struktuur tabelile `classificators`
--

CREATE TABLE `classificators` (
  `id` int(11) NOT NULL,
  `cf_type` varchar(5) NOT NULL,
  `cf_name` varchar(255) DEFAULT NULL,
  `cf_descr` mediumtext DEFAULT NULL,
  `cf_misc` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `row_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `changed_by` int(11) DEFAULT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `cf_value` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabeli struktuur tabelile `department`
--

CREATE TABLE `department` (
  `id` int(11) NOT NULL,
  `departmentname` varchar(120) DEFAULT NULL,
  `comments` mediumtext DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `country_id` int(11) NOT NULL DEFAULT 0,
  `country` varchar(55) NOT NULL DEFAULT '',
  `county_id` int(11) NOT NULL DEFAULT 0,
  `county` varchar(55) NOT NULL DEFAULT '',
  `city_id` int(11) NOT NULL DEFAULT 0,
  `city` varchar(55) NOT NULL DEFAULT '',
  `street_id` int(11) NOT NULL DEFAULT 0,
  `street` varchar(55) NOT NULL DEFAULT '',
  `house_nr` varchar(40) NOT NULL DEFAULT '',
  `flat_nr` varchar(40) NOT NULL DEFAULT '',
  `row_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `changed_by` int(11) DEFAULT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabeli struktuur tabelile `employee`
--

CREATE TABLE `employee` (
  `id` int(11) NOT NULL,
  `firstname` varchar(35) DEFAULT NULL,
  `lastname` varchar(55) DEFAULT NULL,
  `reg_nr` varchar(24) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(120) DEFAULT NULL,
  `occupation` varchar(120) DEFAULT NULL,
  `group_clf_id` int(11) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `department_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `row_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `changed_by` int(11) DEFAULT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabeli struktuur tabelile `pobject`
--

CREATE TABLE `pobject` (
  `id` int(11) NOT NULL,
  `objectname` varchar(255) NOT NULL DEFAULT '',
  `objectcode` varchar(135) DEFAULT NULL,
  `latitude` double NOT NULL DEFAULT 0,
  `longitude` double NOT NULL DEFAULT 0,
  `allowedrangediff` double NOT NULL DEFAULT 0,
  `projectmanager_id` int(11) DEFAULT NULL,
  `projectmanager` varchar(85) NOT NULL DEFAULT '',
  `objectmanager_id` int(11) DEFAULT NULL,
  `objectmanager` varchar(85) NOT NULL DEFAULT '',
  `status_clf_id` int(11) DEFAULT NULL,
  `comments` mediumtext DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `country_id` int(11) NOT NULL DEFAULT 0,
  `country` varchar(55) NOT NULL DEFAULT '',
  `county_id` int(11) NOT NULL DEFAULT 0,
  `county` varchar(55) NOT NULL DEFAULT '',
  `city_id` int(11) NOT NULL DEFAULT 0,
  `city` varchar(55) NOT NULL DEFAULT '',
  `street_id` int(11) NOT NULL DEFAULT 0,
  `street` varchar(55) NOT NULL DEFAULT '',
  `house_nr` varchar(40) NOT NULL DEFAULT '',
  `flat_nr` varchar(40) NOT NULL DEFAULT '',
  `row_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `changed_by` int(11) DEFAULT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabeli struktuur tabelile `profileitem`
--

CREATE TABLE `profileitem` (
  `id` int(11) NOT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `ordernr` int(11) NOT NULL DEFAULT 0,
  `parent_id` int(11) NOT NULL DEFAULT 0,
  `level_nr` int(11) NOT NULL DEFAULT 1,
  `item_name` varchar(120) NOT NULL DEFAULT '',
  `item_descr` mediumtext DEFAULT NULL,
  `related_item_id` int(11) NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `flags` int(11) NOT NULL DEFAULT 0,
  `row_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `changed_by` int(11) DEFAULT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `item_type` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabeli struktuur tabelile `profileitemattr`
--

CREATE TABLE `profileitemattr` (
  `id` int(11) NOT NULL,
  `profileitem_id` int(11) NOT NULL,
  `ordernr` int(11) NOT NULL DEFAULT 0,
  `valuerequired` bit(1) NOT NULL DEFAULT b'0',
  `addamount` bit(1) DEFAULT NULL,
  `amountrequired` bit(1) NOT NULL DEFAULT b'0',
  `subitemrequired` bit(1) NOT NULL DEFAULT b'0',
  `previtemrequired` bit(1) NOT NULL DEFAULT b'0',
  `timemsrequired` tinyint(1) NOT NULL DEFAULT 0,
  `timems2required` bit(1) NOT NULL DEFAULT b'0',
  `timemsrequired2` bit(1) NOT NULL DEFAULT b'0',
  `addcomments` bit(1) NOT NULL DEFAULT b'0',
  `commentsrequired` tinyint(1) NOT NULL DEFAULT 0,
  `addpicture` bit(1) NOT NULL DEFAULT b'0',
  `picturerequired` tinyint(1) NOT NULL DEFAULT 0,
  `active` bit(1) NOT NULL DEFAULT b'1',
  `row_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `changed_by` int(11) DEFAULT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabeli struktuur tabelile `profileitemattrdef`
--

CREATE TABLE `profileitemattrdef` (
  `id` int(11) NOT NULL,
  `profileitemattrid` int(11) NOT NULL,
  `ordernr` int(11) NOT NULL DEFAULT 0,
  `attrname` varchar(85) DEFAULT NULL,
  `attrvalue` varchar(512) DEFAULT NULL,
  `active` bit(1) NOT NULL DEFAULT b'1',
  `row_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `changed_by` int(11) DEFAULT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabeli struktuur tabelile `profileitemgrouping`
--

CREATE TABLE `profileitemgrouping` (
  `id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  `profile_item_id` int(11) DEFAULT NULL,
  `order_no` int(11) DEFAULT 0,
  `clf_id` int(11) DEFAULT NULL,
  `row_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `changed_by` int(11) DEFAULT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabeli struktuur tabelile `profileitemvalue`
--

CREATE TABLE `profileitemvalue` (
  `id` int(11) NOT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `profileitem_id` int(11) DEFAULT NULL,
  `employee_id` int(11) DEFAULT NULL,
  `start` datetime DEFAULT NULL,
  `stop` datetime DEFAULT NULL,
  `related_item_id` int(11) DEFAULT NULL,
  `related_item_name` varchar(255) DEFAULT NULL,
  `ordernr` int(11) NOT NULL DEFAULT 0,
  `picturecommonid` int(11) DEFAULT NULL,
  `commonguid` varchar(130) DEFAULT NULL,
  `comments` mediumtext DEFAULT NULL,
  `attrdefid` int(11) DEFAULT NULL,
  `attrdefval` varchar(85) DEFAULT NULL,
  `attrdefid2` int(11) DEFAULT NULL,
  `attrdefval2` varchar(85) DEFAULT NULL,
  `attrdefid3` int(11) DEFAULT NULL,
  `attrdefval3` varchar(85) DEFAULT NULL,
  `row_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `changed_by` int(11) DEFAULT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `valuepath` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabeli struktuur tabelile `profiles`
--

CREATE TABLE `profiles` (
  `id` int(11) NOT NULL,
  `profile_code` varchar(15) NOT NULL,
  `profile_name` varchar(255) DEFAULT NULL,
  `profile_descr` mediumtext DEFAULT NULL,
  `profile_type` varchar(5) DEFAULT NULL,
  `pobject_id` int(11) NOT NULL DEFAULT 0,
  `employee_group_clf_id` int(11) NOT NULL DEFAULT 0,
  `department_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `row_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `changed_by` int(11) DEFAULT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `is_template` bit(1) NOT NULL DEFAULT b'0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Indeksid tõmmistatud tabelitele
--

--
-- Indeksid tabelile `assets`
--
ALTER TABLE `assets`
  ADD PRIMARY KEY (`id`);

--
-- Indeksid tabelile `classificators`
--
ALTER TABLE `classificators`
  ADD PRIMARY KEY (`id`);

--
-- Indeksid tabelile `department`
--
ALTER TABLE `department`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `IDX_department_company` (`departmentname`,`company_id`);

--
-- Indeksid tabelile `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`id`);

--
-- Indeksid tabelile `pobject`
--
ALTER TABLE `pobject`
  ADD PRIMARY KEY (`id`);

--
-- Indeksid tabelile `profileitem`
--
ALTER TABLE `profileitem`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_profileitem_prof_id` (`profile_id`,`ordernr`);

--
-- Indeksid tabelile `profileitemattr`
--
ALTER TABLE `profileitemattr`
  ADD PRIMARY KEY (`id`);

--
-- Indeksid tabelile `profileitemattrdef`
--
ALTER TABLE `profileitemattrdef`
  ADD PRIMARY KEY (`id`);

--
-- Indeksid tabelile `profileitemgrouping`
--
ALTER TABLE `profileitemgrouping`
  ADD PRIMARY KEY (`id`);

--
-- Indeksid tabelile `profileitemvalue`
--
ALTER TABLE `profileitemvalue`
  ADD PRIMARY KEY (`id`);

--
-- Indeksid tabelile `profiles`
--
ALTER TABLE `profiles`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT tõmmistatud tabelitele
--

--
-- AUTO_INCREMENT tabelile `assets`
--
ALTER TABLE `assets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT tabelile `classificators`
--
ALTER TABLE `classificators`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT tabelile `department`
--
ALTER TABLE `department`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT tabelile `employee`
--
ALTER TABLE `employee`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT tabelile `pobject`
--
ALTER TABLE `pobject`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT tabelile `profileitem`
--
ALTER TABLE `profileitem`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT tabelile `profileitemattr`
--
ALTER TABLE `profileitemattr`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT tabelile `profileitemattrdef`
--
ALTER TABLE `profileitemattrdef`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT tabelile `profileitemgrouping`
--
ALTER TABLE `profileitemgrouping`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT tabelile `profileitemvalue`
--
ALTER TABLE `profileitemvalue`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT tabelile `profiles`
--
ALTER TABLE `profiles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
