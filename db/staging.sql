-- phpMyAdmin SQL Dump
-- version 2.11.3deb1ubuntu1.3
-- http://www.phpmyadmin.net
--
-- Host: db1.ctlgcwacozgl.us-east-1.rds.amazonaws.com
-- Generation Time: Nov 02, 2011 at 02:01 PM
-- Server version: 5.1.57
-- PHP Version: 5.2.4-2ubuntu5.18

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
--
-- Database: `artfully_staging`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE IF NOT EXISTS `admins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `encrypted_password` varchar(128) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `failed_attempts` int(11) DEFAULT '0',
  `unlock_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `reset_password_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_admins_on_email` (`email`),
  UNIQUE KEY `index_admins_on_unlock_token` (`unlock_token`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=2;
--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `email`, `encrypted_password`, `sign_in_count`, `current_sign_in_at`, `last_sign_in_at`, `current_sign_in_ip`, `last_sign_in_ip`, `failed_attempts`, `unlock_token`, `locked_at`, `created_at`, `updated_at`, `reset_password_token`) VALUES
(1, 'admin@fracturedatlas.org', '$2a$10$wV3ERHqFZnTKwjreVwqSw.EtAXg9bbejceOH8uWJ4shOLNhNnIEHi', 25, '2011-10-20 16:51:45', '2011-10-20 16:03:12', '24.105.157.6', '24.105.157.6', 0, NULL, NULL, '2011-09-09 01:22:01', '2011-10-20 16:51:45', NULL);
-- --------------------------------------------------------

--
-- Table structure for table `admin_stats`
--

CREATE TABLE IF NOT EXISTS `admin_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `users` int(11) DEFAULT NULL,
  `logged_in_more_than_once` int(11) DEFAULT NULL,
  `organizations` int(11) DEFAULT NULL,
  `fa_connected_orgs` int(11) DEFAULT NULL,
  `active_fafs_projects` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ticketing_kits` int(11) DEFAULT NULL,
  `donation_kits` int(11) DEFAULT NULL,
  `tickets` int(11) DEFAULT NULL,
  `tickets_sold` int(11) DEFAULT NULL,
  `donations` int(11) DEFAULT NULL,
  `fafs_donations` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=29;
--
-- Dumping data for table `admin_stats`
--

INSERT INTO `admin_stats` (`id`, `users`, `logged_in_more_than_once`, `organizations`, `fa_connected_orgs`, `active_fafs_projects`, `created_at`, `updated_at`, `ticketing_kits`, `donation_kits`, `tickets`, `tickets_sold`, `donations`, `fafs_donations`) VALUES
(1, 30, 22, 22, 8, 8, '2011-10-08 18:19:19', '2011-10-08 18:19:19', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 30, 22, 22, 8, 8, '2011-10-09 18:19:20', '2011-10-09 18:19:20', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 30, 22, 22, 8, 8, '2011-10-10 18:19:23', '2011-10-10 18:19:23', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 30, 22, 22, 8, 8, '2011-10-11 18:19:22', '2011-10-11 18:19:22', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 30, 22, 22, 8, 8, '2011-10-12 18:19:20', '2011-10-12 18:19:20', NULL, NULL, NULL, NULL, NULL, NULL),
(6, 30, 22, 22, 8, 8, '2011-10-13 18:19:21', '2011-10-13 18:19:21', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 30, 22, 22, 8, 8, '2011-10-13 23:02:19', '2011-10-13 23:02:19', 21, 11, 0, 88, 95, 0),
(8, 30, 22, 22, 8, 8, '2011-10-14 18:19:21', '2011-10-14 18:19:21', 21, 11, 0, 88, 95, 0),
(9, 30, 22, 22, 8, 8, '2011-10-15 18:19:19', '2011-10-15 18:19:19', 21, 11, 0, 88, 95, 0),
(10, 30, 22, 22, 8, 8, '2011-10-16 18:19:19', '2011-10-16 18:19:19', 21, 11, 0, 88, 95, 0),
(11, 30, 22, 22, 8, 8, '2011-10-17 18:19:19', '2011-10-17 18:19:19', 21, 11, 0, 88, 95, 0),
(12, 30, 22, 22, 8, 8, '2011-10-18 18:19:21', '2011-10-18 18:19:21', 21, 11, 0, 88, 95, 0),
(13, 30, 22, 22, 8, 8, '2011-10-19 18:19:17', '2011-10-19 18:19:17', 21, 11, 0, 88, 97, 0),
(14, 30, 22, 22, 8, 8, '2011-10-20 16:56:22', '2011-10-20 16:56:22', 21, 11, 0, 102, 98, 84),
(15, 30, 22, 22, 8, 8, '2011-10-20 17:03:19', '2011-10-20 17:03:19', 21, 11, 0, 102, 14, 84),
(16, 30, 22, 22, 8, 8, '2011-10-20 18:19:32', '2011-10-20 18:19:32', 21, 11, 0, 102, 14, 84),
(17, 30, 22, 22, 8, 8, '2011-10-21 18:19:28', '2011-10-21 18:19:28', 21, 11, 0, 102, 14, 84),
(18, 30, 22, 22, 8, 8, '2011-10-22 18:19:25', '2011-10-22 18:19:25', 21, 11, 0, 102, 14, 84),
(19, 30, 22, 22, 8, 8, '2011-10-23 18:19:17', '2011-10-23 18:19:17', 21, 11, 0, 102, 14, 84),
(20, 30, 22, 22, 8, 8, '2011-10-24 18:19:17', '2011-10-24 18:19:17', 21, 11, 0, 102, 14, 84),
(21, 30, 22, 22, 8, 8, '2011-10-25 18:19:23', '2011-10-25 18:19:23', 21, 11, 0, 102, 14, 84),
(22, 30, 22, 22, 8, 8, '2011-10-26 18:19:25', '2011-10-26 18:19:25', 21, 11, 0, 102, 17, 84),
(23, 30, 22, 22, 8, 8, '2011-10-27 18:19:29', '2011-10-27 18:19:29', 21, 11, 0, 102, 17, 84),
(24, 30, 22, 22, 8, 8, '2011-10-28 18:19:21', '2011-10-28 18:19:21', 21, 11, 0, 102, 17, 84),
(25, 30, 22, 22, 8, 8, '2011-10-29 18:19:24', '2011-10-29 18:19:24', 21, 11, 0, 102, 17, 84),
(26, 30, 22, 22, 8, 8, '2011-10-30 18:19:26', '2011-10-30 18:19:26', 21, 11, 0, 102, 17, 84),
(27, 30, 22, 22, 8, 8, '2011-10-31 18:19:18', '2011-10-31 18:19:18', 21, 11, 0, 102, 17, 84),
(28, 30, 22, 22, 8, 8, '2011-11-01 18:19:29', '2011-11-01 18:19:29', 21, 11, 0, 102, 17, 84);
-- --------------------------------------------------------

--
-- Table structure for table `bank_accounts`
--

CREATE TABLE IF NOT EXISTS `bank_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `routing_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `account_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=10;
--
-- Dumping data for table `bank_accounts`
--

INSERT INTO `bank_accounts` (`id`, `routing_number`, `number`, `account_type`, `name`, `address`, `city`, `state`, `zip`, `phone`, `organization_id`, `created_at`, `updated_at`) VALUES
(1, '123456789', '1234567891', 'Business Checking', 'Bank Account', 'Some Bank', 'New york', 'NY', '12345', '123-123-1234', 3, '2011-07-20 18:05:03', '2011-07-20 18:05:03'),
(2, '111111118', '0123456789', 'Personal Checking', 'Bank of America', '186 UNDERHILL AVE', 'BROOKLYN', 'IN', '11238', '571-241-7836', 4, '2011-07-21 13:18:07', '2011-09-02 19:24:14'),
(3, '012345678', '0123456789', 'Personal Savings', 'Square Money', '1000 Somewhere Rd', 'Manhattan', 'NY', '10101', '555-555-5555', 5, '2011-07-21 15:14:45', '2011-07-21 15:14:45'),
(4, '012345678', '0123456789', 'Business Checking', 'Windows < Doors, LLC', '100 Entry RD', 'Manhattan', 'NY', '10101', '571-241-7836', 6, '2011-07-22 15:06:33', '2011-07-25 16:59:29'),
(5, '111111118', '1234567890', 'Personal Checking', 'Fractured Atlas', '111 Funny Lane', 'Balboa', 'AK', '11238', '444-444-4444', 1, '2011-07-22 15:35:03', '2011-07-22 15:35:03'),
(6, '111111118', '394848484884', 'Personal Checking', 'F', '444 fFFFF', 'FFFF', 'AK', '33333', '343-333-3333', 8, '2011-09-15 20:50:03', '2011-09-26 22:44:37'),
(7, '111111118', '1234567890', 'Personal Checking', 'Gary', '109 w 34 st', 'Ebert', 'AK', '11111', '222-222-2222', 15, '2011-10-03 14:34:41', '2011-10-03 14:34:41'),
(8, '111111118', '2', 'Personal Checking', 'Gary Moore', '186 underhill ave', 'Brooklyn', 'NY', '11238', '571-241-7836', 16, '2011-10-06 13:14:53', '2011-10-06 13:15:00'),
(9, '111111118', '555666555', 'Personal Checking', 'Foobald', '186 UNDERHILL AVE', 'PM', 'NY', '11238', '571-241-7836', 21, '2011-10-13 23:05:29', '2011-10-13 23:08:51');
-- --------------------------------------------------------

--
-- Table structure for table `delayed_jobs`
--

CREATE TABLE IF NOT EXISTS `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` text COLLATE utf8_unicode_ci,
  `last_error` text COLLATE utf8_unicode_ci,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `delayed_jobs_priority` (`priority`,`run_at`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=485;
--
-- Dumping data for table `delayed_jobs`
--


-- --------------------------------------------------------

--
-- Table structure for table `donations`
--

CREATE TABLE IF NOT EXISTS `donations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `amount` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=21;
--
-- Dumping data for table `donations`
--

INSERT INTO `donations` (`id`, `amount`, `order_id`, `organization_id`, `created_at`, `updated_at`) VALUES
(1, 500, 7, 5, '2011-07-21 19:55:54', '2011-07-21 19:55:54'),
(2, 10000, 10, 5, '2011-07-21 20:04:01', '2011-07-21 20:04:01'),
(3, 20000, 17, 5, '2011-07-21 21:05:31', '2011-07-21 21:05:31'),
(4, 5000, 53, 3, '2011-07-25 20:57:30', '2011-07-25 20:57:30'),
(5, 5000, 54, 3, '2011-07-25 21:00:30', '2011-07-25 21:00:30'),
(7, 3600, 62, 1, '2011-07-25 22:11:59', '2011-07-25 22:11:59'),
(8, 100000, 79, 1, '2011-09-05 20:24:40', '2011-09-05 20:24:40'),
(9, 4000, 80, 1, '2011-09-08 02:08:26', '2011-09-08 02:08:26'),
(10, 95000, 88, 8, '2011-09-26 22:26:57', '2011-09-26 22:26:57'),
(11, 5000, 92, 1, '2011-09-26 22:36:51', '2011-09-26 22:36:51'),
(12, 10000, 96, 15, '2011-10-03 14:14:46', '2011-10-03 14:14:46');
-- --------------------------------------------------------

--
-- Table structure for table `fiscally_sponsored_projects`
--

CREATE TABLE IF NOT EXISTS `fiscally_sponsored_projects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fs_project_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fa_member_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `profile` text COLLATE utf8_unicode_ci,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `applied_on` datetime DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=23;
--
-- Dumping data for table `fiscally_sponsored_projects`
--

INSERT INTO `fiscally_sponsored_projects` (`id`, `fs_project_id`, `fa_member_id`, `name`, `category`, `profile`, `website`, `applied_on`, `status`, `organization_id`, `created_at`, `updated_at`) VALUES
(15, '1', '23333', 'Futurepoem', 'Publishing', 'Futurepoem publishes innovative poetry, prose and cross-genre literature by both emerging and important underpublished authors.  A rotating editorial board ensures the diversity of editorial decision-making, while consistent artistic and visual direction ensures consistent artistic quality.   In addition, our regular open call for manuscripts offers new writers the all too rare opportunity to submit their work for consideration to a quality small press publisher without a reading fee.  We are currently on our eighth title, publishing two perfect-bound commercial format poetry books per year, and have national distribution through Small Press Distribution (www.spdbooks.org) in Berkeley California and Amazon.com.  Recent successes include the Asian American Literature Award for Shanxing Wang''s book; a prominent article on the press in Poets and Writers magazine, funding from The New York State Council on the Arts Literature Program and National Endowment for the Arts Literature program and two consequitive awards for one of the 50 best book covers in 2004 by AIGA (American Institute of Graphic Arts).  More information about our press is available at www.futurepoem.com.', 'http://www.futurepoem.org', '2002-06-24 00:00:00', 'Active', 15, '2011-10-03 01:21:25', '2011-10-04 14:05:14'),
(16, '4579', '23335', 'Sponsored By Nobody', 'Theatre', 'SPONSORED BY NOBODY is a Brooklyn-based theatre company committed to developing original work that is relevant to contemporary America. Founded in 2005, SBN has established a reputation in New York and Europe for presenting abrasive, engaging theatre while refusing to relinquish the idea of art as a catalyst for social change. While rooted in theatre, SBN incorporates multiple disciplines in our work -- borrowing from dance, film, music and installation art -- while employing both found-texts and original writing. SBN remains committed to a collaborative development process and operates with a sense of urgency on each project undertaken as a company. The goal of maintaining a sense of relevance and immediacy to our contemporary reality remains the foundation to the company’s approach.\n\n\nSPONSORED BY NOBODY have since developed seven original works of theatre -- Behind The Bullseye -- Compression of a Casualty -- FOX(y) FRIENDS -- The Position -- not from canada -- The Amputated Years -- and -- W.M.D. (just the low points). Our inaugural work The Position received three productions in New York City and Massachusetts -- including the smash hit at Soho Think Tank’s ICE FACTORY ’05 festival at the Ohio Theatre. The complete text of The Position was published in the New York anthology Plays and Playwrights 2006 and The Best Men’s Stages Monologues 2006. SPONSORED BY NOBODY has presented work in New York at the original Collective Unconscious; BAX/Brooklyn Arts Exchange; 3LD Technology Center; HERE; the Brick Theater; the Ontological Theater; the New York International Fringe Festival and a second appearance at Soho Think Tank’s ICE FACTORY ’08 festival at the Ohio Theatre.\n\n\nSPONSORED BY NOBODY presented two world premieres on two different continents in 2009. The first was the long-awaited world premiere of W.M.D. (just the low points) at the international arts festival -- The Game Is Up! “How to Save the World in 10 Days” -- at the Vooruit Arts Center in Ghent, Belgium on March 4-5, 2009. The second was Behind The Bullseye at the Ontological Theater for a successful two-week run in July. Developed under a Swing Space grant from the Lower Manhattan Cultural Council and an INCUBATOR residency, Behind The Bullseye fuses elements of journalism, film and installation art to examine the shopping habits of Brooklyn residents from diverse ethnic and class backgrounds.\n\n\nIn addition to touring their previous work, SPONSORED BY NOBODY have been invited back to Belgium to present the world premiere of their next major work -- ATM or this is [not] new york -- in November 2010 at the Monty Arts Center (Antwerp). Development of ATM will continue in New York with the support of the 2010 Mabou Mines/Suite Resident Artist program; 2010 Artist-in-Residence at Robert Wilson’s Watermill Center; and a 2010 Residency @ Chashama. "ATM or this is [not] new york" is a new play for interdisciplinary theater that uses New Yorkers’ interactions with the city’s homeless population as a means to investigate shifting demographics and values under the ongoing financial crisis. It scheduled to receive its New York premiere in Fall 2011.', 'http://www.sponsoredbynobody.com', '2011-04-27 00:00:00', 'Active', 16, '2011-10-03 02:28:42', '2011-10-03 20:36:48'),
(17, '1', '23333', 'Futurepoem', 'Publishing', 'Futurepoem publishes innovative poetry, prose and cross-genre literature by both emerging and important underpublished authors.  A rotating editorial board ensures the diversity of editorial decision-making, while consistent artistic and visual direction ensures consistent artistic quality.   In addition, our regular open call for manuscripts offers new writers the all too rare opportunity to submit their work for consideration to a quality small press publisher without a reading fee.  We are currently on our eighth title, publishing two perfect-bound commercial format poetry books per year, and have national distribution through Small Press Distribution (www.spdbooks.org) in Berkeley California and Amazon.com.  Recent successes include the Asian American Literature Award for Shanxing Wang''s book; a prominent article on the press in Poets and Writers magazine, funding from The New York State Council on the Arts Literature Program and National Endowment for the Arts Literature program and two consequitive awards for one of the 50 best book covers in 2004 by AIGA (American Institute of Graphic Arts).  More information about our press is available at www.futurepoem.com.', 'http://www.futurepoem.org', '2002-06-24 00:00:00', 'Active', 20, '2011-10-03 21:17:11', '2011-10-04 14:05:30'),
(18, '4579', '23335', 'Sponsored By Nobody', 'Theatre', 'SPONSORED BY NOBODY is a Brooklyn-based theatre company committed to developing original work that is relevant to contemporary America. Founded in 2005, SBN has established a reputation in New York and Europe for presenting abrasive, engaging theatre while refusing to relinquish the idea of art as a catalyst for social change. While rooted in theatre, SBN incorporates multiple disciplines in our work -- borrowing from dance, film, music and installation art -- while employing both found-texts and original writing. SBN remains committed to a collaborative development process and operates with a sense of urgency on each project undertaken as a company. The goal of maintaining a sense of relevance and immediacy to our contemporary reality remains the foundation to the company’s approach.\n\n\nSPONSORED BY NOBODY have since developed seven original works of theatre -- Behind The Bullseye -- Compression of a Casualty -- FOX(y) FRIENDS -- The Position -- not from canada -- The Amputated Years -- and -- W.M.D. (just the low points). Our inaugural work The Position received three productions in New York City and Massachusetts -- including the smash hit at Soho Think Tank’s ICE FACTORY ’05 festival at the Ohio Theatre. The complete text of The Position was published in the New York anthology Plays and Playwrights 2006 and The Best Men’s Stages Monologues 2006. SPONSORED BY NOBODY has presented work in New York at the original Collective Unconscious; BAX/Brooklyn Arts Exchange; 3LD Technology Center; HERE; the Brick Theater; the Ontological Theater; the New York International Fringe Festival and a second appearance at Soho Think Tank’s ICE FACTORY ’08 festival at the Ohio Theatre.\n\n\nSPONSORED BY NOBODY presented two world premieres on two different continents in 2009. The first was the long-awaited world premiere of W.M.D. (just the low points) at the international arts festival -- The Game Is Up! “How to Save the World in 10 Days” -- at the Vooruit Arts Center in Ghent, Belgium on March 4-5, 2009. The second was Behind The Bullseye at the Ontological Theater for a successful two-week run in July. Developed under a Swing Space grant from the Lower Manhattan Cultural Council and an INCUBATOR residency, Behind The Bullseye fuses elements of journalism, film and installation art to examine the shopping habits of Brooklyn residents from diverse ethnic and class backgrounds.\n\n\nIn addition to touring their previous work, SPONSORED BY NOBODY have been invited back to Belgium to present the world premiere of their next major work -- ATM or this is [not] new york -- in November 2010 at the Monty Arts Center (Antwerp). Development of ATM will continue in New York with the support of the 2010 Mabou Mines/Suite Resident Artist program; 2010 Artist-in-Residence at Robert Wilson’s Watermill Center; and a 2010 Residency @ Chashama. "ATM or this is [not] new york" is a new play for interdisciplinary theater that uses New Yorkers’ interactions with the city’s homeless population as a means to investigate shifting demographics and values under the ongoing financial crisis. It scheduled to receive its New York premiere in Fall 2011.', 'http://www.sponsoredbynobody.com', '2011-04-27 00:00:00', 'Active', 19, '2011-10-03 21:19:29', '2011-10-03 21:19:29'),
(19, '1', '23333', 'Futurepoem', 'Publishing', 'Futurepoem publishes innovative poetry, prose and cross-genre literature by both emerging and important underpublished authors.  A rotating editorial board ensures the diversity of editorial decision-making, while consistent artistic and visual direction ensures consistent artistic quality.   In addition, our regular open call for manuscripts offers new writers the all too rare opportunity to submit their work for consideration to a quality small press publisher without a reading fee.  We are currently on our eighth title, publishing two perfect-bound commercial format poetry books per year, and have national distribution through Small Press Distribution (www.spdbooks.org) in Berkeley California and Amazon.com.  Recent successes include the Asian American Literature Award for Shanxing Wang''s book; a prominent article on the press in Poets and Writers magazine, funding from The New York State Council on the Arts Literature Program and National Endowment for the Arts Literature program and two consequitive awards for one of the 50 best book covers in 2004 by AIGA (American Institute of Graphic Arts).  More information about our press is available at www.futurepoem.com.', 'http://www.futurepoem.org', '2002-06-24 00:00:00', 'Active', 1, '2011-10-04 14:02:49', '2011-10-04 14:05:04'),
(20, '1', '23333', 'Futurepoem', 'Publishing', 'Futurepoem publishes innovative poetry, prose and cross-genre literature by both emerging and important underpublished authors.  A rotating editorial board ensures the diversity of editorial decision-making, while consistent artistic and visual direction ensures consistent artistic quality.   In addition, our regular open call for manuscripts offers new writers the all too rare opportunity to submit their work for consideration to a quality small press publisher without a reading fee.  We are currently on our eighth title, publishing two perfect-bound commercial format poetry books per year, and have national distribution through Small Press Distribution (www.spdbooks.org) in Berkeley California and Amazon.com.  Recent successes include the Asian American Literature Award for Shanxing Wang''s book; a prominent article on the press in Poets and Writers magazine, funding from The New York State Council on the Arts Literature Program and National Endowment for the Arts Literature program and two consequitive awards for one of the 50 best book covers in 2004 by AIGA (American Institute of Graphic Arts).  More information about our press is available at www.futurepoem.com.', 'http://www.futurepoem.org', '2002-06-24 00:00:00', 'Active', 18, '2011-10-04 14:21:01', '2011-10-04 14:21:01'),
(21, '18', '23336', 'Women of Mystery - Belinda Sinclair', 'Other', 'Writing and publishing a book on women of mystery, primarily female magicians, from antiquity into the 21st century. Each volume depicts their time period, what they did, how they did it, to overcome the obstacles as women performing or practicing magic.', NULL, '2002-12-19 00:00:00', 'Active', 21, '2011-10-05 17:40:46', '2011-10-05 17:40:46'),
(22, '9', '23337', 'Vessel', 'Theatre', 'Vessel is working on several projects this summer. \n\n1. Vessel presents ARCANA, their new work for the Ontological Downstairs Series @11pm.\nA girl named Arcana, with telepathic powers, struggles to find her place in a world filled with self-help gurus, tourists and charlatan psychiatrists. We travel through time and logic to a cross-road between chaos and order, where the surreal is real and reality is absurd. Vessel brings this world to you through poetry and dance, combined with acrobatics, masks, stilts, multi-media video and over the top characters, creating a topsy-turvy, mystical universe where anything is possible.\n\n2. Vessel performs TRANSFIX for the New York International Fringe Festival\nAug 4th at Central Park Bethesda Fountain\nAug 7th a Rush Hour Tour with Speed Levitch at Grand Central to Times Square', NULL, '2002-08-02 00:00:00', 'Active', 22, '2011-10-05 17:56:27', '2011-10-05 17:56:27');
-- --------------------------------------------------------

--
-- Table structure for table `kits`
--

CREATE TABLE IF NOT EXISTS `kits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=47;
--
-- Dumping data for table `kits`
--

INSERT INTO `kits` (`id`, `state`, `type`, `organization_id`, `created_at`, `updated_at`) VALUES
(1, 'activated', 'TicketingKit', 3, '2011-07-20 17:13:52', '2011-07-20 18:05:14'),
(2, 'activated', 'TicketingKit', 4, '2011-07-21 01:18:14', '2011-07-21 13:21:03'),
(3, 'activated', 'RegularDonationKit', 5, '2011-07-21 15:12:39', '2011-07-21 15:14:56'),
(4, 'activated', 'RegularDonationKit', 3, '2011-07-21 15:27:35', '2011-07-21 15:32:39'),
(5, 'activated', 'TicketingKit', 5, '2011-07-21 15:43:21', '2011-07-21 15:44:16'),
(6, 'activated', 'TicketingKit', 6, '2011-07-22 15:00:57', '2011-07-22 15:09:02'),
(7, 'activated', 'TicketingKit', 1, '2011-07-25 21:44:29', '2011-07-25 21:46:15'),
(8, 'activated', 'RegularDonationKit', 1, '2011-07-25 21:44:47', '2011-07-25 21:46:19'),
(9, 'activated', 'TicketingKit', 3, '2011-09-13 18:19:20', '2011-09-13 18:19:20'),
(10, 'pending', 'TicketingKit', 7, '2011-09-14 16:24:10', '2011-09-14 16:24:10'),
(11, 'activated', 'TicketingKit', 8, '2011-09-15 20:47:47', '2011-09-15 20:50:43'),
(15, 'activated', 'TicketingKit', 10, '2011-09-30 14:56:34', '2011-09-30 14:56:34'),
(16, 'activated', 'TicketingKit', 11, '2011-09-30 14:56:34', '2011-09-30 14:56:34'),
(17, 'activated', 'TicketingKit', 12, '2011-09-30 14:56:35', '2011-09-30 14:56:35'),
(20, 'activated', 'TicketingKit', 13, '2011-09-30 15:24:03', '2011-09-30 15:24:03'),
(22, 'activated', 'TicketingKit', 14, '2011-09-30 15:31:35', '2011-09-30 15:31:35'),
(24, 'activated', 'TicketingKit', 15, '2011-10-01 02:33:03', '2011-10-01 02:33:03'),
(26, 'activated', 'TicketingKit', 16, '2011-10-01 02:40:37', '2011-10-01 02:40:37'),
(27, 'activated', 'TicketingKit', 17, '2011-10-01 02:43:17', '2011-10-01 02:43:17'),
(28, 'activated', 'TicketingKit', 18, '2011-10-01 02:43:45', '2011-10-01 02:43:45'),
(30, 'activated', 'TicketingKit', 19, '2011-10-01 02:55:09', '2011-10-01 02:55:09'),
(32, 'activated', 'TicketingKit', 20, '2011-10-01 02:58:56', '2011-10-01 02:58:56'),
(34, 'activated', 'TicketingKit', 21, '2011-10-01 03:14:57', '2011-10-01 03:14:57'),
(35, 'activated', 'TicketingKit', 22, '2011-10-01 03:14:57', '2011-10-01 03:14:57'),
(36, 'activated', 'TicketingKit', 23, '2011-10-01 03:14:57', '2011-10-01 03:14:57'),
(39, 'activated', 'SponsoredDonationKit', 15, '2011-10-03 01:21:25', '2011-10-04 14:05:14'),
(40, 'activated', 'SponsoredDonationKit', 16, '2011-10-03 02:28:42', '2011-10-03 20:36:48'),
(41, 'activated', 'SponsoredDonationKit', 20, '2011-10-03 21:17:11', '2011-10-04 14:05:30'),
(42, 'activated', 'SponsoredDonationKit', 19, '2011-10-03 21:19:29', '2011-10-03 21:19:29'),
(43, 'activated', 'SponsoredDonationKit', 1, '2011-10-04 14:02:49', '2011-10-04 14:05:04'),
(44, 'activated', 'SponsoredDonationKit', 18, '2011-10-04 14:21:01', '2011-10-04 14:21:01'),
(45, 'activated', 'SponsoredDonationKit', 21, '2011-10-05 17:40:46', '2011-10-05 17:40:46'),
(46, 'activated', 'SponsoredDonationKit', 22, '2011-10-05 17:56:27', '2011-10-05 17:56:27');
-- --------------------------------------------------------

--
-- Table structure for table `memberships`
--

CREATE TABLE IF NOT EXISTS `memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=31;
--
-- Dumping data for table `memberships`
--

INSERT INTO `memberships` (`id`, `user_id`, `organization_id`) VALUES
(1, 1, 1),
(3, 3, 3),
(5, 6, 4),
(6, 12, 5),
(8, 13, 5),
(9, 10, 6),
(10, 14, 4),
(11, 15, 4),
(12, 16, 1),
(13, 18, 7),
(14, 19, 8),
(16, 17, 9),
(17, 20, 10),
(18, 21, 11),
(19, 22, 12),
(20, 23, 13),
(21, 24, 14),
(22, 25, 15),
(23, 26, 16),
(24, 26, 17),
(25, 27, 18),
(26, 28, 19),
(27, 29, 20),
(28, 30, 21),
(29, 31, 22),
(30, 32, 23);
-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE IF NOT EXISTS `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transaction_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=114;
--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `state`, `transaction_id`, `created_at`, `updated_at`) VALUES
(1, 'started', NULL, '2011-07-20 17:48:26', '2011-07-20 17:48:26'),
(2, 'started', NULL, '2011-07-21 13:39:22', '2011-07-21 13:39:22'),
(3, 'started', NULL, '2011-07-21 13:47:22', '2011-07-21 13:47:22'),
(4, 'started', NULL, '2011-07-21 14:59:49', '2011-07-21 14:59:49'),
(5, 'approved', NULL, '2011-07-21 18:48:31', '2011-07-21 19:42:11'),
(6, 'started', NULL, '2011-07-21 19:36:25', '2011-07-21 19:36:25'),
(7, 'approved', NULL, '2011-07-21 19:36:30', '2011-07-21 19:56:57'),
(8, 'started', NULL, '2011-07-21 19:42:12', '2011-07-21 19:42:12'),
(9, 'approved', NULL, '2011-07-21 19:56:58', '2011-07-21 20:01:45'),
(10, 'approved', NULL, '2011-07-21 20:01:46', '2011-07-21 20:04:56'),
(12, 'started', NULL, '2011-07-21 20:07:10', '2011-07-21 20:07:10'),
(15, 'approved', NULL, '2011-07-21 20:18:21', '2011-07-21 20:19:26'),
(16, 'approved', NULL, '2011-07-21 20:19:26', '2011-07-21 20:38:47'),
(17, 'approved', NULL, '2011-07-21 20:38:48', '2011-07-21 21:06:17'),
(18, 'started', NULL, '2011-07-21 20:41:01', '2011-07-21 20:41:01'),
(19, 'started', NULL, '2011-07-21 21:03:22', '2011-07-21 21:03:22'),
(20, 'started', NULL, '2011-07-21 21:03:41', '2011-07-21 21:03:41'),
(21, 'started', NULL, '2011-07-21 21:06:18', '2011-07-21 21:06:18'),
(22, 'started', NULL, '2011-07-21 21:09:19', '2011-07-21 21:09:19'),
(23, 'started', NULL, '2011-07-21 21:09:28', '2011-07-21 21:09:28'),
(24, 'approved', NULL, '2011-07-21 23:41:01', '2011-07-22 13:58:38'),
(25, 'approved', NULL, '2011-07-22 13:58:39', '2011-07-22 17:37:13'),
(26, 'started', NULL, '2011-07-22 14:55:02', '2011-07-22 14:55:02'),
(27, 'approved', NULL, '2011-07-22 14:55:18', '2011-07-22 14:56:23'),
(28, 'approved', NULL, '2011-07-22 14:56:24', '2011-07-22 14:59:36'),
(29, 'approved', NULL, '2011-07-22 14:59:37', '2011-07-22 15:17:41'),
(30, 'approved', NULL, '2011-07-22 15:17:42', '2011-07-22 15:19:41'),
(31, 'approved', NULL, '2011-07-22 15:19:42', '2011-07-22 15:21:49'),
(32, 'approved', NULL, '2011-07-22 15:21:50', '2011-07-22 15:26:53'),
(33, 'approved', NULL, '2011-07-22 15:26:54', '2011-07-22 15:28:59'),
(34, 'started', NULL, '2011-07-22 15:29:01', '2011-07-22 15:29:01'),
(35, 'approved', NULL, '2011-07-22 17:37:14', '2011-07-22 18:24:16'),
(36, 'approved', NULL, '2011-07-22 18:24:17', '2011-07-22 18:44:03'),
(37, 'approved', NULL, '2011-07-22 18:44:04', '2011-07-22 19:19:28'),
(38, 'approved', NULL, '2011-07-22 19:19:29', '2011-07-22 20:01:23'),
(39, 'approved', NULL, '2011-07-22 20:01:24', '2011-07-22 20:03:48'),
(40, 'started', NULL, '2011-07-22 20:03:49', '2011-07-22 20:03:49'),
(41, 'started', NULL, '2011-07-25 16:08:22', '2011-07-25 16:08:22'),
(42, 'approved', NULL, '2011-07-25 16:24:48', '2011-07-25 20:55:39'),
(43, 'started', NULL, '2011-07-25 19:20:46', '2011-07-25 19:20:46'),
(44, 'approved', NULL, '2011-07-25 19:20:52', '2011-07-25 19:24:31'),
(45, 'started', NULL, '2011-07-25 19:24:31', '2011-07-25 19:24:31'),
(46, 'started', NULL, '2011-07-25 19:24:44', '2011-07-25 19:24:44'),
(47, 'approved', NULL, '2011-07-25 19:26:10', '2011-07-25 19:27:24'),
(48, 'started', NULL, '2011-07-25 19:27:25', '2011-07-25 19:27:25'),
(49, 'started', NULL, '2011-07-25 20:47:45', '2011-07-25 20:47:45'),
(50, 'started', NULL, '2011-07-25 20:51:10', '2011-07-25 20:51:10'),
(51, 'approved', NULL, '2011-07-25 20:51:36', '2011-07-25 20:52:30'),
(52, 'approved', NULL, '2011-07-25 20:52:31', '2011-07-25 21:22:25'),
(53, 'approved', NULL, '2011-07-25 20:55:39', '2011-07-25 20:58:01'),
(54, 'approved', NULL, '2011-07-25 20:58:02', '2011-07-25 21:00:59'),
(56, 'started', NULL, '2011-07-25 21:02:12', '2011-07-25 21:02:12'),
(57, 'approved', NULL, '2011-07-25 21:22:25', '2011-07-25 21:31:20'),
(58, 'started', NULL, '2011-07-25 21:31:21', '2011-07-25 21:31:21'),
(59, 'started', NULL, '2011-07-25 22:02:12', '2011-07-25 22:02:12'),
(60, 'started', NULL, '2011-07-25 22:05:27', '2011-07-25 22:05:27'),
(61, 'approved', NULL, '2011-07-25 22:05:38', '2011-07-25 22:06:40'),
(62, 'approved', NULL, '2011-07-25 22:06:41', '2011-07-25 22:12:58'),
(63, 'approved', NULL, '2011-07-25 22:12:58', '2011-07-25 22:42:10'),
(66, 'approved', NULL, '2011-07-26 01:28:23', '2011-07-26 02:08:27'),
(68, 'started', NULL, '2011-07-26 16:05:34', '2011-07-26 16:05:34'),
(69, 'started', NULL, '2011-07-26 16:06:24', '2011-07-26 16:06:24'),
(70, 'started', NULL, '2011-07-26 16:13:40', '2011-07-26 16:13:40'),
(71, 'approved', NULL, '2011-07-26 20:38:38', '2011-07-26 20:39:25'),
(72, 'started', NULL, '2011-07-26 20:39:27', '2011-07-26 20:39:27'),
(73, 'started', NULL, '2011-09-02 18:51:05', '2011-09-02 18:51:05'),
(74, 'started', NULL, '2011-09-05 20:08:22', '2011-09-05 20:08:22'),
(75, 'started', NULL, '2011-09-05 20:10:44', '2011-09-05 20:10:44'),
(76, 'started', NULL, '2011-09-05 20:12:10', '2011-09-05 20:12:10'),
(77, 'approved', NULL, '2011-09-05 20:12:55', '2011-09-05 20:15:28'),
(78, 'approved', NULL, '2011-09-05 20:15:29', '2011-09-05 20:18:40'),
(79, 'approved', NULL, '2011-09-05 20:18:41', '2011-09-05 20:25:16'),
(80, 'approved', NULL, '2011-09-05 20:25:17', '2011-09-08 02:09:17'),
(81, 'started', NULL, '2011-09-08 02:09:18', '2011-09-08 02:09:18'),
(82, 'approved', NULL, '2011-09-15 20:54:40', '2011-09-15 21:02:35'),
(83, 'started', NULL, '2011-09-15 21:02:36', '2011-09-15 21:02:36'),
(84, 'started', NULL, '2011-09-15 21:14:03', '2011-09-15 21:14:03'),
(85, 'approved', NULL, '2011-09-15 21:14:08', '2011-09-15 21:15:19'),
(86, 'started', NULL, '2011-09-15 21:15:19', '2011-09-15 21:15:19'),
(87, 'started', NULL, '2011-09-26 22:19:56', '2011-09-26 22:19:56'),
(88, 'approved', NULL, '2011-09-26 22:26:50', '2011-09-26 22:28:45'),
(89, 'started', NULL, '2011-09-26 22:28:51', '2011-09-26 22:28:51'),
(90, 'started', NULL, '2011-09-26 22:33:53', '2011-09-26 22:33:53'),
(91, 'approved', NULL, '2011-09-26 22:33:57', '2011-09-26 22:34:10'),
(92, 'approved', NULL, '2011-09-26 22:34:12', '2011-09-26 22:37:27'),
(93, 'approved', NULL, '2011-09-26 22:37:30', '2011-10-04 14:09:37'),
(94, 'approved', NULL, '2011-09-30 03:39:28', '2011-09-30 03:41:58'),
(95, 'approved', NULL, '2011-09-30 03:42:07', '2011-09-30 03:44:41'),
(96, 'approved', NULL, '2011-09-30 03:44:48', '2011-10-03 14:16:11'),
(97, 'started', NULL, '2011-10-03 14:11:17', '2011-10-03 14:11:17'),
(98, 'approved', NULL, '2011-10-03 14:16:22', '2011-10-03 20:44:17'),
(99, 'approved', NULL, '2011-10-03 20:44:23', '2011-10-03 20:54:42'),
(100, 'started', NULL, '2011-10-03 20:54:47', '2011-10-03 20:54:47'),
(101, 'approved', NULL, '2011-10-04 14:09:42', '2011-10-04 14:12:37'),
(102, 'approved', NULL, '2011-10-04 14:12:39', '2011-10-04 14:25:41'),
(103, 'approved', NULL, '2011-10-04 14:25:46', '2011-10-07 20:06:43'),
(104, 'started', NULL, '2011-10-07 20:06:50', '2011-10-07 20:06:50'),
(105, 'started', NULL, '2011-10-13 18:43:16', '2011-10-13 18:43:16'),
(106, 'approved', NULL, '2011-10-13 18:43:22', '2011-10-13 18:44:12'),
(107, 'approved', NULL, '2011-10-13 18:44:18', '2011-10-13 18:52:11'),
(108, 'approved', NULL, '2011-10-13 18:52:16', '2011-10-20 15:14:37'),
(109, 'started', NULL, '2011-10-20 15:14:45', '2011-10-20 15:14:45'),
(110, 'started', NULL, '2011-10-20 15:49:56', '2011-10-20 15:49:56'),
(111, 'approved', NULL, '2011-10-20 15:56:13', '2011-10-20 15:57:45'),
(112, 'approved', NULL, '2011-10-20 15:57:50', '2011-10-20 16:00:49'),
(113, 'started', NULL, '2011-10-20 16:01:03', '2011-10-20 16:01:03');
-- --------------------------------------------------------

--
-- Table structure for table `organizations`
--

CREATE TABLE IF NOT EXISTS `organizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `time_zone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `legal_organization_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ein` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fa_member_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=24;
--
-- Dumping data for table `organizations`
--

INSERT INTO `organizations` (`id`, `name`, `time_zone`, `legal_organization_name`, `ein`, `fa_member_id`, `website`, `created_at`, `updated_at`) VALUES
(1, 'Fractured Atlas', 'Eastern Time (US & Canada)', 'Dashboard Organization', '25-9658966', '23333', NULL, '2011-07-19 17:48:22', '2011-10-04 14:02:49'),
(3, 'The Other Side', 'Eastern Time (US & Canada)', 'Fractured Atlas', '111-2251', NULL, NULL, '2011-07-20 17:13:31', '2011-07-21 15:27:32'),
(4, 'Artfully staging', 'Eastern Time (US & Canada)', NULL, NULL, NULL, NULL, '2011-07-21 01:17:46', '2011-10-03 01:15:16'),
(5, 'Squares Inc.', 'Eastern Time (US & Canada)', 'Squares Inc.', '0123456789', NULL, NULL, '2011-07-21 14:50:07', '2011-07-21 15:12:34'),
(6, 'Doors Unlimited', 'Hawaii', NULL, NULL, NULL, NULL, '2011-07-22 14:42:28', '2011-07-22 14:42:28'),
(7, 'ATHENA Productions', 'Eastern Time (US & Canada)', NULL, NULL, NULL, NULL, '2011-09-14 16:23:58', '2011-09-14 16:23:58'),
(8, 'Flying Leiderman', 'Eastern Time (US & Canada)', NULL, NULL, NULL, NULL, '2011-09-15 20:47:39', '2011-10-03 01:15:16'),
(9, 'Events', 'Eastern Time (US & Canada)', NULL, NULL, NULL, NULL, '2011-09-15 21:06:17', '2011-09-15 21:06:17'),
(10, 'Arts collective', 'Eastern Time (US & Canada)', NULL, NULL, NULL, NULL, '2011-09-30 14:56:34', '2011-10-03 01:15:16'),
(11, 'Arts collective', 'Eastern Time (US & Canada)', NULL, NULL, NULL, NULL, '2011-09-30 14:56:34', '2011-10-03 01:15:16'),
(12, 'Arts collective', 'Eastern Time (US & Canada)', NULL, NULL, NULL, NULL, '2011-09-30 14:56:34', '2011-10-03 01:15:16'),
(13, 'Biborg', 'Eastern Time (US & Canada)', NULL, NULL, NULL, NULL, '2011-09-30 15:24:01', '2011-10-03 01:15:16'),
(14, 'Bib2org', 'Eastern Time (US & Canada)', NULL, NULL, NULL, NULL, '2011-09-30 15:31:34', '2011-10-03 01:15:16'),
(15, 'Halpert', 'Eastern Time (US & Canada)', NULL, NULL, '23333', NULL, '2011-10-01 02:33:02', '2011-10-03 01:21:25'),
(16, 'Halpert2', 'Eastern Time (US & Canada)', NULL, NULL, '23335', NULL, '2011-10-01 02:40:37', '2011-10-03 02:28:42'),
(17, 'Halpert2', 'Eastern Time (US & Canada)', NULL, NULL, NULL, NULL, '2011-10-01 02:43:17', '2011-10-01 02:43:17'),
(18, 'Halpert3', 'Eastern Time (US & Canada)', NULL, NULL, '23333', NULL, '2011-10-01 02:43:45', '2011-10-04 14:21:01'),
(19, 'Halpert4', 'Eastern Time (US & Canada)', NULL, NULL, '23335', NULL, '2011-10-01 02:55:08', '2011-10-03 21:19:29'),
(20, 'Halpert5', 'Eastern Time (US & Canada)', NULL, NULL, '23333', NULL, '2011-10-01 02:58:55', '2011-10-03 21:17:11'),
(21, 'Utah', 'Eastern Time (US & Canada)', NULL, NULL, '23336', NULL, '2011-10-01 03:14:56', '2011-10-05 17:40:46'),
(22, 'Utah 2', 'Eastern Time (US & Canada)', NULL, NULL, '23337', NULL, '2011-10-01 03:14:57', '2011-10-05 17:56:27'),
(23, 'Utah 3', 'Eastern Time (US & Canada)', NULL, NULL, NULL, NULL, '2011-10-01 03:14:57', '2011-10-01 03:14:57');
-- --------------------------------------------------------

--
-- Table structure for table `purchasable_tickets`
--

CREATE TABLE IF NOT EXISTS `purchasable_tickets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) DEFAULT NULL,
  `ticket_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lock_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=152;
--
-- Dumping data for table `purchasable_tickets`
--

INSERT INTO `purchasable_tickets` (`id`, `order_id`, `ticket_id`, `lock_id`, `created_at`, `updated_at`) VALUES
(5, 5, '4e2828a3258b9be2a4daf59b', 'b14860b5-d0f5-4ead-bc6c-f73fc878fc06', '2011-07-21 19:41:42', '2011-07-21 19:41:42'),
(6, 7, '4e284b72258b9be2a4daf703', 'f7c7f6fc-f3a3-476e-9e00-94c6ac1ad7e4', '2011-07-21 19:55:44', '2011-07-21 19:55:44'),
(7, 9, '4e284b72258b9be2a4daf6fe', '9368977c-0d2a-4e84-a0f9-498f8eaa0448', '2011-07-21 20:00:22', '2011-07-21 20:00:22'),
(8, 9, '4e284b73258b9be2a4daf705', '228f0191-9091-4e85-9349-80c7966c7ba7', '2011-07-21 20:00:32', '2011-07-21 20:00:32'),
(9, 9, '4e284b72258b9be2a4daf704', '228f0191-9091-4e85-9349-80c7966c7ba7', '2011-07-21 20:00:32', '2011-07-21 20:00:32'),
(10, 9, '4e284b73258b9be2a4daf70c', '228f0191-9091-4e85-9349-80c7966c7ba7', '2011-07-21 20:00:32', '2011-07-21 20:00:32'),
(11, 9, '4e284b73258b9be2a4daf706', '5406a168-ff7a-4516-b24e-f5bfef09cdcd', '2011-07-21 20:00:38', '2011-07-21 20:00:38'),
(27, 15, '4e283e18258b9be2a4daf61f', 'fb4fe16b-86cc-4163-aec4-fe2581628e22', '2011-07-21 20:18:25', '2011-07-21 20:18:25'),
(28, 15, '4e283e17258b9be2a4daf619', 'fb4fe16b-86cc-4163-aec4-fe2581628e22', '2011-07-21 20:18:25', '2011-07-21 20:18:25'),
(29, 16, '4e288e17258b9be2a4daf744', '1f748fed-ecbc-4b46-a42b-91adad1a6991', '2011-07-21 20:37:57', '2011-07-21 20:37:57'),
(30, 17, '4e283e3a258b9be2a4daf656', '4f0af839-15fd-4a9d-9e53-da0cfd435a62', '2011-07-21 21:05:14', '2011-07-21 21:05:14'),
(31, 23, '4e28955b258b9be2a4daf78a', 'fe0e501e-317b-40e6-b059-129293949b78', '2011-07-21 21:09:28', '2011-07-21 21:09:28'),
(32, 24, '4e297fce258b9be2a4daf798', 'b747cfab-b592-4b4b-8583-5b8b209012ad', '2011-07-22 13:57:58', '2011-07-22 13:57:58'),
(33, 24, '4e297fce258b9be2a4daf79e', 'b747cfab-b592-4b4b-8583-5b8b209012ad', '2011-07-22 13:57:58', '2011-07-22 13:57:58'),
(34, 24, '4e297fd0258b9be2a4daf7b4', 'b747cfab-b592-4b4b-8583-5b8b209012ad', '2011-07-22 13:57:58', '2011-07-22 13:57:58'),
(35, 24, '4e297fcd258b9be2a4daf794', 'b747cfab-b592-4b4b-8583-5b8b209012ad', '2011-07-22 13:57:58', '2011-07-22 13:57:58'),
(36, 24, '4e297fce258b9be2a4daf7a3', 'b747cfab-b592-4b4b-8583-5b8b209012ad', '2011-07-22 13:57:58', '2011-07-22 13:57:58'),
(37, 27, '4e298f15258b9be2a4daf85d', '0055a5c0-09ff-4d3a-b911-f16e761ba3e1', '2011-07-22 14:55:18', '2011-07-22 14:55:18'),
(38, 28, '4e298f13258b9be2a4daf846', '1840bfee-7b7d-47de-aead-c417f22d4bf6', '2011-07-22 14:58:57', '2011-07-22 14:58:57'),
(39, 29, '4e2993af258b9be2a4daf8a6', 'ae0dfb70-43ae-4ac8-898c-4a15a06fc448', '2011-07-22 15:16:43', '2011-07-22 15:16:43'),
(40, 30, '4e2993ae258b9be2a4daf8a0', '4d46cc6e-e9b7-4660-84b7-266002994aaf', '2011-07-22 15:18:35', '2011-07-22 15:18:35'),
(41, 31, '4e2993ae258b9be2a4daf89b', 'a7d6e21c-7772-4c36-8344-df90b9bed4d4', '2011-07-22 15:20:41', '2011-07-22 15:20:42'),
(42, 32, '4e2993ab258b9be2a4daf878', 'ffa19bf5-29ec-440a-97a2-4ef7a86eb249', '2011-07-22 15:22:23', '2011-07-22 15:22:23'),
(43, 33, '4e2993ae258b9be2a4daf89e', 'bab38551-6e23-4400-968b-6c5acc7352f3', '2011-07-22 15:27:24', '2011-07-22 15:27:24'),
(45, 25, '4e297fcd258b9be2a4daf795', '8175e044-0841-4025-9ae8-bbd072c08d86', '2011-07-22 17:36:35', '2011-07-22 17:36:35'),
(46, 35, '4e297fd1258b9be2a4daf7c1', 'eae8556e-19aa-467b-8cb9-ac45726a000d', '2011-07-22 18:22:23', '2011-07-22 18:22:23'),
(47, 36, '4e297fcf258b9be2a4daf7ad', '75ce4f6a-a9ec-4e4c-ad00-acd893013c18', '2011-07-22 18:43:06', '2011-07-22 18:43:06'),
(48, 37, '4e297fd0258b9be2a4daf7b6', '8c9fb345-ccd7-4f58-9423-e16d299514c3', '2011-07-22 19:18:34', '2011-07-22 19:18:34'),
(49, 38, '4e297fcf258b9be2a4daf7a6', 'cc624798-9191-4378-87b4-4d506fb85952', '2011-07-22 20:00:50', '2011-07-22 20:00:50'),
(50, 39, '4e297fd0258b9be2a4daf7ba', '410028fe-adcb-4073-95ad-ece19358dd90', '2011-07-22 20:03:20', '2011-07-22 20:03:20'),
(51, 8, '4e270f5563c7c4f90ad01b13', 'ef1c5f71-4b77-4e67-9e74-d0d597993167', '2011-07-25 16:08:49', '2011-07-25 16:08:49'),
(53, 44, '4e2993ad258b9be2a4daf88c', '122d75d0-2917-4102-a6c9-eb1d2b15f7b9', '2011-07-25 19:20:52', '2011-07-25 19:20:52'),
(54, 47, '4e2993ae258b9be2a4daf8a5', '232d3219-939c-4702-a862-793396fbf33d', '2011-07-25 19:26:10', '2011-07-25 19:26:10'),
(55, 51, '4e2dd190cad0f3572dd66544', '38dbb169-9f97-4d53-b062-8606684205a1', '2011-07-25 20:51:37', '2011-07-25 20:51:37'),
(56, 51, '4e2dd18ecad0f3572dd6652d', '38dbb169-9f97-4d53-b062-8606684205a1', '2011-07-25 20:51:37', '2011-07-25 20:51:37'),
(57, 42, '4e270f5563c7c4f90ad01b10', 'd7a918b2-4b65-4e9c-9180-438368b1e5a4', '2011-07-25 20:54:58', '2011-07-25 20:54:58'),
(58, 54, '4e270f5563c7c4f90ad01b11', 'e3b7d2a6-51f5-4101-839f-0edc94723770', '2011-07-25 21:00:34', '2011-07-25 21:00:34'),
(60, 52, '4e2ddde3cad0f3572dd6657a', '299a8115-d68a-425d-bdde-154e8028d98f', '2011-07-25 21:21:17', '2011-07-25 21:21:17'),
(61, 52, '4e2ddde3cad0f3572dd6657e', '299a8115-d68a-425d-bdde-154e8028d98f', '2011-07-25 21:21:17', '2011-07-25 21:21:17'),
(62, 52, '4e2ddde3cad0f3572dd6657b', '299a8115-d68a-425d-bdde-154e8028d98f', '2011-07-25 21:21:17', '2011-07-25 21:21:17'),
(63, 52, '4e2ddde2cad0f3572dd66574', '299a8115-d68a-425d-bdde-154e8028d98f', '2011-07-25 21:21:17', '2011-07-25 21:21:17'),
(64, 57, '4e2dd18dcad0f3572dd6651f', '2fb3118d-a921-463b-84cc-b6cecbdf3931', '2011-07-25 21:27:11', '2011-07-25 21:27:11'),
(65, 57, '4e2dd18dcad0f3572dd66523', '2fb3118d-a921-463b-84cc-b6cecbdf3931', '2011-07-25 21:27:11', '2011-07-25 21:27:11'),
(66, 57, '4e2dd191cad0f3572dd6654c', '2fb3118d-a921-463b-84cc-b6cecbdf3931', '2011-07-25 21:27:11', '2011-07-25 21:27:11'),
(67, 57, '4e2dd190cad0f3572dd66541', '2fb3118d-a921-463b-84cc-b6cecbdf3931', '2011-07-25 21:27:11', '2011-07-25 21:27:11'),
(68, 57, '4e2dd18ecad0f3572dd6652a', '2fb3118d-a921-463b-84cc-b6cecbdf3931', '2011-07-25 21:27:11', '2011-07-25 21:27:11'),
(69, 57, '4e2dd18fcad0f3572dd6653d', '2fb3118d-a921-463b-84cc-b6cecbdf3931', '2011-07-25 21:27:11', '2011-07-25 21:27:11'),
(70, 61, '4e2de892cad0f3572dd66624', '25e6f5b3-a151-45dd-9747-fd307570e6d5', '2011-07-25 22:05:38', '2011-07-25 22:05:38'),
(71, 63, '4e25e9fa63c7c4f90ad01af7', '1a00d246-6691-4df6-9604-11ccd77dac52', '2011-07-25 22:41:55', '2011-07-25 22:41:55'),
(72, 63, '4e25e9fa63c7c4f90ad01af6', '1a00d246-6691-4df6-9604-11ccd77dac52', '2011-07-25 22:41:55', '2011-07-25 22:41:55'),
(91, 66, '4e2e0d1acad0738641aa9759', '8bb4f5d7-3923-4386-a56a-1d795b8de30b', '2011-07-26 02:07:53', '2011-07-26 02:07:53'),
(92, 66, '4e2e0d1dcad0738641aa976f', '8bb4f5d7-3923-4386-a56a-1d795b8de30b', '2011-07-26 02:07:53', '2011-07-26 02:07:53'),
(93, 66, '4e2e0d1acad0738641aa9753', '8bb4f5d7-3923-4386-a56a-1d795b8de30b', '2011-07-26 02:07:53', '2011-07-26 02:07:53'),
(95, 70, '4e2993ac258b9be2a4daf885', '0536d0f2-4ae8-4d7a-94f0-f696f31d4ed3', '2011-07-26 16:13:41', '2011-07-26 16:13:41'),
(96, 69, '4e2993ac258b9be2a4daf880', '640ec205-0b83-481e-b45d-2224502f674b', '2011-07-26 16:19:23', '2011-07-26 16:19:23'),
(99, 71, '4e2f25afcad0738641aa9968', '469533a1-2a91-4647-9860-79536b0b03e7', '2011-07-26 20:38:52', '2011-07-26 20:38:52'),
(100, 77, '4e652cf90703a98626703b62', 'd8f8a1c5-43d9-4b9c-a218-a720a2da06de', '2011-09-05 20:12:55', '2011-09-05 20:12:55'),
(101, 77, '4e652cf80703a98626703b5b', 'd8f8a1c5-43d9-4b9c-a218-a720a2da06de', '2011-09-05 20:12:55', '2011-09-05 20:12:55'),
(102, 78, '4e652a5c0703a98626703b4a', 'a200cf85-f66f-4728-9266-c8b01824cd04', '2011-09-05 20:17:45', '2011-09-05 20:17:45'),
(103, 78, '4e652a5b0703a98626703b45', 'a200cf85-f66f-4728-9266-c8b01824cd04', '2011-09-05 20:17:45', '2011-09-05 20:17:45'),
(104, 78, '4e652a5b0703a98626703b46', 'a200cf85-f66f-4728-9266-c8b01824cd04', '2011-09-05 20:17:45', '2011-09-05 20:17:45'),
(105, 78, '4e652a5c0703a98626703b4c', 'a200cf85-f66f-4728-9266-c8b01824cd04', '2011-09-05 20:17:45', '2011-09-05 20:17:45'),
(106, 80, '4e6822fa0703a98626703b89', 'c0f7911c-3464-47d9-ab54-f51610f7d8c0', '2011-09-08 02:08:28', '2011-09-08 02:08:28'),
(107, 81, '4e6964c80703a98626703bc3', '8a7c2013-2bc7-44b5-8edd-7091c4c14d54', '2011-09-09 00:59:16', '2011-09-09 00:59:16'),
(108, 81, '4e6964c80703a98626703bbb', '8a7c2013-2bc7-44b5-8edd-7091c4c14d54', '2011-09-09 00:59:16', '2011-09-09 00:59:16'),
(109, 82, '4e7266040703a98626703caf', 'a97d1902-b4b3-4586-a9c6-49397ea1e6d8', '2011-09-15 20:54:45', '2011-09-15 20:54:45'),
(110, 85, '4e726a1d0703a98626703ced', '2c33499a-5308-4c05-a534-0521aadba14e', '2011-09-15 21:14:08', '2011-09-15 21:14:08'),
(111, 88, '4e80fa630703151e28414002', '7c1bd5fe-6e7c-4edc-a801-d7ec4ef86a61', '2011-09-26 22:27:21', '2011-09-26 22:27:21'),
(112, 88, '4e80fa600703151e28413fec', '1037ce01-acc6-4ac0-a8d1-af12e48f4497', '2011-09-26 22:27:25', '2011-09-26 22:27:26'),
(113, 88, '4e80fa610703151e28413fef', '1037ce01-acc6-4ac0-a8d1-af12e48f4497', '2011-09-26 22:27:26', '2011-09-26 22:27:26'),
(114, 91, '4e80fdcb0703151e28414087', '3ce2464f-1e47-4bf4-afa6-4fa8a12f565c', '2011-09-26 22:33:57', '2011-09-26 22:33:57'),
(115, 92, '4e80fe640703151e28414099', '215d7b4b-2666-4512-a937-3f109a96eae5', '2011-09-26 22:36:55', '2011-09-26 22:36:56'),
(116, 94, '4e8539c60703151e284140b3', '7a05ca79-3d70-4a5d-bebc-a243248362a0', '2011-09-30 03:39:58', '2011-09-30 03:39:58'),
(117, 94, '4e8539c60703151e284140b2', '7a05ca79-3d70-4a5d-bebc-a243248362a0', '2011-09-30 03:39:58', '2011-09-30 03:39:58'),
(118, 94, '4e8539c60703151e284140b0', 'fa3c3664-4593-4d2a-90fd-1125c90c1369', '2011-09-30 03:41:23', '2011-09-30 03:41:23'),
(119, 94, '4e8539c60703151e284140b7', 'fa3c3664-4593-4d2a-90fd-1125c90c1369', '2011-09-30 03:41:23', '2011-09-30 03:41:23'),
(120, 95, '4e8539c60703151e284140b5', 'f7ffbe55-23f8-4d2b-b7ba-578ea77ed908', '2011-09-30 03:43:12', '2011-09-30 03:43:12'),
(121, 96, '4e89c18e0703151e28414143', '3156cca0-edf1-445e-8dad-9a4b3ed402d4', '2011-10-03 14:14:27', '2011-10-03 14:14:28'),
(122, 96, '4e89c18f0703151e28414148', '3156cca0-edf1-445e-8dad-9a4b3ed402d4', '2011-10-03 14:14:28', '2011-10-03 14:14:28'),
(123, 96, '4e89c1a20703151e28414154', '6c795db4-83ef-4f67-a600-48b6a09319fd', '2011-10-03 14:14:36', '2011-10-03 14:14:37'),
(124, 96, '4e89c1a20703151e28414155', '6c795db4-83ef-4f67-a600-48b6a09319fd', '2011-10-03 14:14:37', '2011-10-03 14:14:37'),
(125, 98, '4e89c1a10703151e28414150', '84ed6576-772b-44ae-bc79-6320c01b35ff', '2011-10-03 20:43:12', '2011-10-03 20:43:12'),
(126, 99, '4e89c1a10703151e2841414f', '959b3d7e-e0be-4168-9dec-f020fb5a33ca', '2011-10-03 20:54:02', '2011-10-03 20:54:02'),
(127, 93, '4e8b135a0703151e284141b0', '21ee225e-3b47-43d1-8230-7f8a31e312ac', '2011-10-04 14:08:50', '2011-10-04 14:08:50'),
(128, 93, '4e8b135a0703151e284141a7', '21ee225e-3b47-43d1-8230-7f8a31e312ac', '2011-10-04 14:08:50', '2011-10-04 14:08:50'),
(129, 102, '4e8b170f0703151e284141cd', 'b8defd79-1c32-40a3-a80f-7262603d4a7c', '2011-10-04 14:25:10', '2011-10-04 14:25:10'),
(130, 103, '4e8f5a782b039dff53e7b9f0', 'e8133ca7-1dde-46ee-b19b-15bc47534cbd', '2011-10-07 20:05:32', '2011-10-07 20:05:32'),
(131, 103, '4e8f5a782b039dff53e7ba1a', 'e8133ca7-1dde-46ee-b19b-15bc47534cbd', '2011-10-07 20:05:32', '2011-10-07 20:05:32'),
(132, 106, '4e972dfe2b039dff53e7bc9b', '7dd08de3-7019-440b-a267-e5e5a74f288a', '2011-10-13 18:43:26', '2011-10-13 18:43:26'),
(133, 106, '4e972dfe2b039dff53e7bcaa', '82ec309a-3e0a-43ba-adf5-9f6523fba25d', '2011-10-13 18:43:28', '2011-10-13 18:43:28'),
(134, 106, '4e972dfe2b039dff53e7bcae', '8a57b556-6188-4a31-a283-6e4f401697db', '2011-10-13 18:43:31', '2011-10-13 18:43:31'),
(135, 107, '4e9731992b039dff53e7c1e0', '23774d09-724c-4b20-a469-089ade4e4ea9', '2011-10-13 18:51:31', '2011-10-13 18:51:31'),
(136, 107, '4e9731a62b039dff53e7c574', '23774d09-724c-4b20-a469-089ade4e4ea9', '2011-10-13 18:51:31', '2011-10-13 18:51:31'),
(137, 107, '4e9731a72b039dff53e7c7ed', '23774d09-724c-4b20-a469-089ade4e4ea9', '2011-10-13 18:51:31', '2011-10-13 18:51:31'),
(138, 108, '4ea03a092b039dff53e7c927', '66c416c8-37cf-4f67-a874-1e8ed18b72b6', '2011-10-20 15:12:13', '2011-10-20 15:12:13'),
(139, 108, '4ea03a092b039dff53e7c92b', '66c416c8-37cf-4f67-a874-1e8ed18b72b6', '2011-10-20 15:12:13', '2011-10-20 15:12:14'),
(140, 111, '4ea03a092b039dff53e7c924', 'df7e2168-9bfc-4e93-96fb-ded0674d2078', '2011-10-20 15:56:13', '2011-10-20 15:56:14'),
(141, 111, '4ea03a092b039dff53e7c928', '53e3187b-5251-4208-b6b9-e4e306111969', '2011-10-20 15:56:19', '2011-10-20 15:56:19'),
(142, 111, '4ea03a092b039dff53e7c92e', 'c2dd7f07-ae18-4abe-a34d-79b7fdd308a1', '2011-10-20 15:56:27', '2011-10-20 15:56:27'),
(143, 111, '4ea03a092b039dff53e7c904', '442841e5-0164-4c41-a119-30660b0b63ae', '2011-10-20 15:56:36', '2011-10-20 15:56:36'),
(144, 112, '4ea043662b039dff53e7c9b5', 'f3dad5a8-5ef0-48bf-aebf-31a9468ad306', '2011-10-20 15:58:35', '2011-10-20 15:58:36'),
(145, 112, '4ea043662b039dff53e7c9b2', 'f3dad5a8-5ef0-48bf-aebf-31a9468ad306', '2011-10-20 15:58:35', '2011-10-20 15:58:36'),
(146, 112, '4ea043662b039dff53e7c9a4', 'f3dad5a8-5ef0-48bf-aebf-31a9468ad306', '2011-10-20 15:58:35', '2011-10-20 15:58:36'),
(147, 112, '4ea043662b039dff53e7c9a5', 'f3dad5a8-5ef0-48bf-aebf-31a9468ad306', '2011-10-20 15:58:35', '2011-10-20 15:58:36'),
(148, 112, '4ea043662b039dff53e7c9b7', 'f3dad5a8-5ef0-48bf-aebf-31a9468ad306', '2011-10-20 15:58:36', '2011-10-20 15:58:36'),
(149, 112, '4ea043622b039dff53e7c971', '7fa332b0-b231-432d-b523-f9b71d064c44', '2011-10-20 15:59:39', '2011-10-20 15:59:39'),
(150, 112, '4ea043622b039dff53e7c967', '7fa332b0-b231-432d-b523-f9b71d064c44', '2011-10-20 15:59:39', '2011-10-20 15:59:39'),
(151, 112, '4ea043622b039dff53e7c980', '7fa332b0-b231-432d-b523-f9b71d064c44', '2011-10-20 15:59:39', '2011-10-20 15:59:39');
-- --------------------------------------------------------

--
-- Table structure for table `schema_migrations`
--

CREATE TABLE IF NOT EXISTS `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
--
-- Dumping data for table `schema_migrations`
--

INSERT INTO `schema_migrations` (`version`) VALUES
('20101004161930'),
('20101028154253'),
('20101124172701'),
('20101213210740'),
('20110126165254'),
('20110131185735'),
('20110209200819'),
('20110613201820'),
('20110711152214'),
('20110721183401'),
('20110823202046'),
('20110824141943'),
('20110826135112'),
('20110907173649'),
('20110909211149'),
('20110912200828'),
('20110912204231'),
('20111004232140'),
('20111007155926');
-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `encrypted_password` varchar(128) COLLATE utf8_unicode_ci DEFAULT '',
  `reset_password_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remember_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `customer_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `suspended_at` datetime DEFAULT NULL,
  `suspension_reason` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `invitation_token` varchar(60) COLLATE utf8_unicode_ci DEFAULT NULL,
  `invitation_sent_at` datetime DEFAULT NULL,
  `invited_by_id` int(11) DEFAULT NULL,
  `invited_by_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  KEY `index_users_on_invitation_token` (`invitation_token`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=33;
--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `encrypted_password`, `reset_password_token`, `remember_token`, `remember_created_at`, `sign_in_count`, `current_sign_in_at`, `last_sign_in_at`, `current_sign_in_ip`, `last_sign_in_ip`, `created_at`, `updated_at`, `customer_id`, `suspended_at`, `suspension_reason`, `invitation_token`, `invitation_sent_at`, `invited_by_id`, `invited_by_type`) VALUES
(1, 'demo@fracturedatlas.org', '$2a$10$hNnWWP3NZN1lSUmwAic3O.7BTUvTs4tmSZe9V59uPxPrFOjfWET2G', NULL, NULL, NULL, 19, '2011-10-04 14:41:30', '2011-09-26 22:34:34', '24.105.157.6', '24.105.157.6', '2011-07-19 17:47:46', '2011-10-04 14:41:30', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(3, 'micah.frost@fracturedatlas.org', '$2a$10$pR42dX14z5a4tcOM2.g/pOFebEcT73Z0.AtewP1oGLEm.N7bhcSWO', NULL, NULL, NULL, 6, '2011-07-25 16:06:52', '2011-07-21 15:41:39', '67.242.82.192', '67.242.82.192', '2011-07-20 15:46:31', '2011-07-25 16:06:52', NULL, NULL, NULL, NULL, '2011-07-20 15:46:31', NULL, NULL),
(5, 'gary.moore@fracturedatlas.org', '$2a$10$w4ighv3RM.9k/v9MjnxvquF99vmkmrmAMCqTKewdotFCkyD7mF7Za', NULL, NULL, NULL, 7, '2011-07-29 18:49:29', '2011-07-25 21:45:47', '24.105.157.6', '24.105.157.6', '2011-07-20 16:12:07', '2011-07-29 18:49:29', NULL, NULL, NULL, NULL, '2011-07-20 16:12:07', NULL, NULL),
(6, 'gary.moore@gmail.com', '$2a$10$LfId7FBT7LBcoyuLwvahYevk8jpYKjjNlLrqOW96AshvfsvTU3WZO', NULL, NULL, NULL, 15, '2011-10-11 13:57:42', '2011-09-30 03:35:27', '24.105.157.6', '173.3.206.188', '2011-07-20 16:14:33', '2011-10-11 13:57:42', NULL, NULL, NULL, NULL, '2011-07-20 16:14:33', NULL, NULL),
(7, 'test@test.com', '$2a$10$MBCmCq0pf91zSYusEqqsk.t0v10To/c4mKEHVOrcnAO1AL9OM5HOO', NULL, NULL, NULL, 1, '2011-07-20 20:59:31', '2011-07-20 20:59:31', '67.242.82.192', '67.242.82.192', '2011-07-20 20:59:08', '2011-07-20 20:59:31', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(8, 'ian.guffy@fracturedatlas.org', '$2a$10$AU8q8I0hqAJKLNadwDX3XObS2jxtA.dvnndNeI7t5vKtrnkYCtONu', NULL, NULL, NULL, 7, '2011-07-25 16:58:42', '2011-07-22 15:04:51', '24.105.157.6', '24.215.246.251', '2011-07-21 14:37:46', '2011-07-25 16:58:42', NULL, NULL, NULL, NULL, '2011-07-21 14:37:46', NULL, NULL),
(9, 'ian.guffy+ubuntu@example.com', '', NULL, NULL, NULL, 1, '2011-09-26 23:18:24', '2011-09-26 23:18:24', '24.105.157.6', '24.105.157.6', '2011-07-21 14:41:23', '2011-09-26 23:18:24', NULL, NULL, NULL, 'Nkoj3ea6qwrzyVey6qd6', '2011-07-21 14:41:23', NULL, NULL),
(10, 'ian.guffy+xp@gmail.com', '$2a$10$jEsSR61y65k7LJZLHX8yU.YWqzpXkRfgF8OeUM3wpgUf6GNcaX2mO', NULL, NULL, NULL, 10, '2011-07-26 17:08:35', '2011-07-26 15:07:36', '24.105.157.6', '24.105.157.6', '2011-07-21 14:41:44', '2011-07-26 17:08:35', NULL, NULL, NULL, NULL, '2011-07-21 14:41:44', NULL, NULL),
(11, 'ian.guffy+ubuntu2@example.com', '', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '2011-07-21 14:42:01', '2011-07-21 14:42:01', NULL, NULL, NULL, 'BgLlJdDd7PrjKuri26yg', '2011-07-21 14:42:01', NULL, NULL),
(12, 'ian.guffy+ubuntu@gmail.com', '$2a$10$R8KSx2EBDIDYPaMrWlE/cexmghXzcDYXHmEcl72psQcD5.iPBEb1W', NULL, NULL, NULL, 2, '2011-07-21 15:41:55', '2011-07-21 14:45:53', '24.105.157.6', '24.105.157.6', '2011-07-21 14:44:59', '2011-07-21 15:41:55', NULL, NULL, NULL, NULL, '2011-07-21 14:44:59', NULL, NULL),
(13, 'ian.guffy+ubuntu2@gmail.com', '$2a$10$dWtPDbNzMp75chGQz49veu4xJ1jzffTUAGAWQcdf1left2KDcHqoK', NULL, NULL, NULL, 2, '2011-07-21 15:21:13', '2011-07-21 15:16:27', '24.105.157.6', '24.105.157.6', '2011-07-21 14:45:14', '2011-07-21 15:38:47', NULL, '2011-07-21 15:38:47', 'Suspension needs testing', NULL, '2011-07-21 14:45:14', NULL, NULL),
(14, 'kara.petraglia@fracturedatlas.org', '$2a$10$e8R/bsh58ibro92lWpv3kuNES/ilDYyrWV4OSpvRN6DpCtJHP0F0K', NULL, NULL, NULL, 1, '2011-07-29 18:52:02', '2011-07-29 18:52:02', '24.105.157.6', '24.105.157.6', '2011-07-29 18:51:08', '2011-07-29 18:52:02', NULL, NULL, NULL, NULL, '2011-07-29 18:51:08', NULL, NULL),
(15, 'tara.ocon@fracturedatlas.org', '$2a$10$NhK7HoKKJ5oo3hSoSJzhl.IFC0PyuzLbjHCWDQ3lg9DOv237YUi5m', NULL, NULL, NULL, 1, '2011-08-01 14:00:34', '2011-08-01 14:00:34', '24.105.157.6', '24.105.157.6', '2011-07-29 18:51:21', '2011-08-01 14:00:34', NULL, NULL, NULL, NULL, '2011-07-29 18:51:21', NULL, NULL),
(16, 'demosubordinate@fracturedatlas.org', '', NULL, NULL, NULL, 2, '2011-10-04 14:45:29', '2011-09-26 22:45:43', '24.105.157.6', '24.105.157.6', '2011-09-02 19:17:47', '2011-10-04 14:45:29', NULL, NULL, NULL, 'ODHH2excDV0PSRyullvI', '2011-09-02 19:22:53', NULL, NULL),
(17, 'gary.moore+noorg@gmail.com', '', NULL, NULL, NULL, 3, '2011-09-26 22:33:02', '2011-09-15 21:05:44', '24.105.157.6', '24.105.157.6', '2011-09-10 21:48:50', '2011-09-26 22:33:02', NULL, NULL, NULL, 'Uit4eODDZgY0zg3ZyLyx', '2011-09-10 21:48:50', NULL, NULL),
(18, 'emailtest@fracturedatlas.org', '', NULL, NULL, NULL, 1, '2011-09-14 16:23:49', '2011-09-14 16:23:49', '24.105.157.6', '24.105.157.6', '2011-09-14 16:21:26', '2011-09-14 16:23:49', NULL, NULL, NULL, 'ZwDQV1Wano8OayvXZycd', '2011-09-14 16:21:26', NULL, NULL),
(19, 'gary.moore+5@gmail.com', '$2a$10$KxfFyc/cVu/Rbkixv2zmeO822WzP3865UXDLUrusawhwe.I.mcK4q', NULL, NULL, NULL, 4, '2011-09-26 22:18:45', '2011-09-15 20:47:08', '24.105.157.6', '24.105.157.6', '2011-09-15 14:22:59', '2011-09-26 22:18:45', NULL, NULL, NULL, NULL, '2011-09-15 14:22:59', NULL, NULL),
(20, 'user10@artfullyhq.com', '$2a$10$ca36RW9IPPtNwa5cJheSe.esNMc7EUtH7W6ZLbDgicJIkMg5rVkHW', NULL, NULL, NULL, 2, '2011-09-30 15:19:59', '2011-09-30 14:57:04', '173.3.206.188', '173.3.206.188', '2011-09-30 14:56:33', '2011-09-30 15:19:59', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(21, 'user11@artfullyhq.com', '$2a$10$.eGYNlIL0MM2SH8/mCvn0u/FSkljRfYfp3dSPvpSZq7EQND5OOicW', NULL, NULL, NULL, 2, '2011-09-30 15:18:21', '2011-09-30 15:12:24', '173.3.206.188', '173.3.206.188', '2011-09-30 14:56:34', '2011-09-30 15:18:21', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(22, 'user12@artfullyhq.com', '$2a$10$jy6zuoIP3XmCMjMBeuHb7eXB7uWKnu4OPDOmGdAo9kXjePDrFF8Mm', NULL, NULL, NULL, 2, '2011-09-30 15:29:34', '2011-09-30 15:16:30', '173.3.206.188', '173.3.206.188', '2011-09-30 14:56:34', '2011-09-30 15:29:34', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(23, 'bib@artfullyhq.com', '$2a$10$s20RcJZMhkO0J2S5PLRdsO4xA1hRO8O1VfAQEhmhdK9rg3k.zkSk2', NULL, NULL, NULL, 3, '2011-09-30 15:34:12', '2011-09-30 15:31:22', '173.3.206.188', '173.3.206.188', '2011-09-30 15:24:01', '2011-09-30 15:34:12', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(24, 'bib2@artfullyhq.com', '$2a$10$AQw7ZE8rHZHe/yDLUBI7hu2sF8Wfo3qFQwxFkXxua7g36Hzkwjsae', NULL, NULL, NULL, 1, '2011-09-30 15:31:49', '2011-09-30 15:31:49', '173.3.206.188', '173.3.206.188', '2011-09-30 15:31:34', '2011-09-30 15:31:49', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(25, 'jim@artfullyhq.com', '$2a$10$cMojCADgOjGSYd2wG0lXo.NyDSb/dQ0fbGcdVfZlbaqKeeUN8hL96', NULL, NULL, NULL, 6, '2011-10-13 18:25:15', '2011-10-06 18:06:22', '24.105.157.6', '24.105.157.6', '2011-10-01 02:33:02', '2011-10-13 18:25:15', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(26, 'jim2@artfullyhq.com', '$2a$10$s1yECpxFjhcJI1hvGvc5Q.SBp0Y9wkQEkGibOeARYbMyiXzZlxSIO', NULL, NULL, NULL, 2, '2011-10-03 02:26:34', '2011-10-03 02:25:30', '173.3.206.188', '173.3.206.188', '2011-10-01 02:40:37', '2011-10-03 02:26:34', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(27, 'jim3@artfullyhq.com', '$2a$10$6SNwuMuBxSkhWMwMWNfGAuPrPLaeOz8Rz2/2wKVtQsKLUAC3g8G7W', NULL, NULL, NULL, 2, '2011-10-04 14:20:22', '2011-10-01 02:43:58', '24.105.157.6', '68.48.23.180', '2011-10-01 02:43:45', '2011-10-04 14:20:22', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(28, 'jim4@artfullyhq.com', '$2a$10$.aBkOFFJ61k8P2WVEU9NFuxnlP0T2ndM8E4HNgoTzcUJLaIbuKt5e', NULL, NULL, NULL, 2, '2011-10-03 21:18:03', '2011-10-01 02:55:30', '173.3.206.188', '68.48.23.180', '2011-10-01 02:55:08', '2011-10-03 21:18:03', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(29, 'jim5@artfullyhq.com', '$2a$10$NZGzwvYxtrnN/oCITg2bpOgdaonzoE5RiPE3PtJQkjfUVHVzVxrEC', NULL, NULL, NULL, 2, '2011-10-03 21:16:31', '2011-10-01 03:00:25', '173.3.206.188', '68.48.23.180', '2011-10-01 02:58:55', '2011-10-03 21:16:31', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(30, 'utah@artfullyhq.com', '$2a$10$hA.UE9KmCJxfMa7.0hFAHuYPCYecMZ9b1kR2/m0FyZTyTT2x1vtou', NULL, NULL, NULL, 5, '2011-10-26 14:34:01', '2011-10-13 23:07:16', '173.3.206.188', '24.105.157.6', '2011-10-01 03:14:56', '2011-10-26 14:34:02', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(31, 'utah2@artfullyhq.com', '$2a$10$ISfFLDgQnJyndQI.MC6kM.9.JHfDyqQbhMqPBzerI.qc1dLsOp/W.', NULL, NULL, NULL, 2, '2011-10-05 17:56:11', '2011-10-01 03:31:24', '24.105.157.6', '68.48.23.180', '2011-10-01 03:14:57', '2011-10-05 17:56:11', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(32, 'utah3@artfullyhq.com', '$2a$10$CkkbOsdutcqimqtOcT0Yvel1l9m6SvQ7FDyLEsybtUS6EhO15eZNO', NULL, NULL, NULL, 1, '2011-10-11 13:55:54', '2011-10-11 13:55:54', '24.105.157.6', '24.105.157.6', '2011-10-01 03:14:57', '2011-10-11 13:55:54', NULL, NULL, NULL, NULL, NULL, NULL, NULL)