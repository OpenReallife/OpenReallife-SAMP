-- phpMyAdmin SQL Dump
-- version 4.9.1
-- https://www.phpmyadmin.net/
--
-- Host: ms2480.gamedata.io:3306
-- Generation Time: Oct 28, 2021 at 07:43 AM
-- Server version: 10.4.15-MariaDB-1:10.4.15+maria~focal
-- PHP Version: 7.1.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ni6595017_1_DB`
--
CREATE DATABASE IF NOT EXISTS `ni6595017_1_DB` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `ni6595017_1_DB`;

-- --------------------------------------------------------

--
-- Table structure for table `carshop`
--

CREATE TABLE `carshop` (
  `id` int(11) NOT NULL,
  `isOnPosition` int(11) NOT NULL,
  `model` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  `odometer` int(11) NOT NULL,
  `fuel` int(11) NOT NULL,
  `vPosX` float NOT NULL,
  `vPosY` float NOT NULL,
  `vPosZ` float NOT NULL,
  `vPosR` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `carshop`
--

INSERT INTO `carshop` (`id`, `isOnPosition`, `model`, `price`, `odometer`, `fuel`, `vPosX`, `vPosY`, `vPosZ`, `vPosR`) VALUES
(1, 0, 560, 50000, 1000, 0, 2135.52, -1126.77, 25.2357, 84.1668),
(2, 0, 560, 50000, 1000, 0, 2135.63, -1130.91, 25.3754, 89.0451),
(3, 1, 560, 0, 0, 0, 2135.58, -1135.63, 25.4011, 90.5257),
(4, 0, 560, 0, 0, 0, 2135.49, -1140.53, 24.989, 88.9194),
(5, 1, 555, 19000, 2100, 0, 2135.18, -1145.92, 24.4007, 85.6138),
(6, 1, 560, 0, 0, 0, 2121.6, -1155.39, 23.7609, 8.2532),
(7, 0, 560, 15000, 5200, 0, 2117.17, -1157.28, 24.0522, 352.57),
(8, 1, 459, 10000, 4321, 0, 2119.45, -1123.94, 25.4244, 319.469),
(9, 0, 560, 5000, 2231, 0, 2119.02, -1132.99, 25.3226, 302.549),
(10, 0, 560, 50000, 1000, 0, 2119.09, -1142.2, 24.901, 296.512);

-- --------------------------------------------------------

--
-- Table structure for table `faction`
--

CREATE TABLE `faction` (
  `id` int(11) NOT NULL,
  `name` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  `PosX` float NOT NULL,
  `PosY` float NOT NULL,
  `PosZ` float NOT NULL,
  `PosR` float NOT NULL,
  `interior` tinyint(1) NOT NULL,
  `world` int(11) NOT NULL,
  `color` int(11) NOT NULL,
  `money` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `isAdmin` tinyint(1) NOT NULL,
  `username` varchar(35) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(35) COLLATE utf8_unicode_ci NOT NULL,
  `skinID` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `cashMoney` int(11) NOT NULL,
  `bankMoney` int(11) NOT NULL,
  `factionID` int(11) NOT NULL,
  `factionRank` int(11) NOT NULL,
  `lastPosX` float NOT NULL,
  `lastPosY` float NOT NULL,
  `lastPosZ` float NOT NULL,
  `interiorID` int(11) NOT NULL,
  `lastLogin` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `registerDate` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `playerIP` varchar(16) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id`, `isAdmin`, `username`, `password`, `skinID`, `level`, `cashMoney`, `bankMoney`, `factionID`, `factionRank`, `lastPosX`, `lastPosY`, `lastPosZ`, `interiorID`, `lastLogin`, `registerDate`, `playerIP`) VALUES
(1, 1, 'TestUser', 'e10adc3949ba59abbe56e057f20f883e', 29, 0, 0, 0, 1, 0, 1573.89, -1629.51, 13.3828, 0, '27/10/2021', '15/04/2021', '79.224.54.240');

-- --------------------------------------------------------

--
-- Table structure for table `vehicle`
--

CREATE TABLE `vehicle` (
  `id` int(11) NOT NULL,
  `isSpawned` tinyint(1) NOT NULL,
  `serverVehID` int(11) NOT NULL,
  `modelID` int(11) NOT NULL,
  `fuel` int(11) NOT NULL,
  `odometer` int(11) NOT NULL,
  `isLocked` tinyint(1) NOT NULL,
  `isPrivateVehicle` tinyint(1) NOT NULL,
  `ownerFactionID` int(11) NOT NULL,
  `ownerPlayerID` int(11) NOT NULL,
  `parkPosX` float NOT NULL,
  `parkPosY` float NOT NULL,
  `parkPosZ` float NOT NULL,
  `parkPosR` float NOT NULL,
  `lastPosX` float NOT NULL,
  `lastPosY` float NOT NULL,
  `lastPosZ` float NOT NULL,
  `lastPosR` float NOT NULL,
  `color1` int(11) NOT NULL,
  `color2` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `vehicle`
--

INSERT INTO `vehicle` (`id`, `isSpawned`, `serverVehID`, `modelID`, `fuel`, `odometer`, `isLocked`, `isPrivateVehicle`, `ownerFactionID`, `ownerPlayerID`, `parkPosX`, `parkPosY`, `parkPosZ`, `parkPosR`, `lastPosX`, `lastPosY`, `lastPosZ`, `lastPosR`, `color1`, `color2`) VALUES
(1, 1, 1, 596, 32, 532, 0, 0, 1, -1, 1571.33, -1622.91, 13.1874, 91.2418, 1560.6, -1622.99, 13.1827, 91.2418, 0, 1),
(2, 1, 2, 596, 44, 44353, 0, 0, 1, -1, 1559.28, -1623.29, 13.1812, 88.8789, 1559.28, -1623.29, 13.1812, 88.8789, 0, 1),
(3, 1, 3, 596, 100, 10, 0, 0, 1, -1, 1556.26, -1615.19, 13.1028, 319.715, 1555.05, -1614.86, 13.1013, 152.157, 0, 1),
(4, 1, 4, 437, 100, 10, 0, 0, 1, -1, 1601.57, -1605.94, 13.6147, 90.6967, 1601.57, -1605.94, 13.6147, 90.6967, 0, 1),
(5, 1, 5, 490, 100, 10, 0, 0, 1, -1, 1546.36, -1612.93, 13.5084, 299.638, 1546.36, -1612.93, 13.5084, 299.638, 0, 1),
(6, 1, 6, 490, 100, 10, 0, 0, 1, -1, 1544.38, -1606.73, 13.5113, 270.311, 1544.38, -1606.73, 13.5113, 270.311, 0, 1),
(7, 1, 7, 596, 100, 10, 0, 0, 1, -1, 1562.54, -1615.13, 13.104, 320.897, 1562.53, -1615.12, 13.1024, 320.808, 0, 1),
(8, 1, 8, 596, 100, 10, 0, 0, 1, -1, 1568.93, -1614.68, 13.106, 326.081, 1568.93, -1614.68, 13.106, 326.081, 0, 1),
(9, 1, 9, 596, 100, 10, 0, 0, 1, -1, 1574.8, -1615.19, 13.105, 324.878, 1574.8, -1615.19, 13.105, 324.878, 0, 1),
(10, 1, 10, 427, 100, 10, 0, 0, 1, -1, 1602.94, -1614.2, 13.6289, 91.9781, 1602.94, -1614.2, 13.6289, 91.9781, 0, 1),
(14, 1, 11, 601, 100, 0, 0, 0, 1, -1, 1531.22, -1645.33, 5.6494, 180.359, 1531.22, -1645.33, 5.6494, 180.359, 0, 1),
(15, 0, 16, 560, 100, 5200, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `carshop`
--
ALTER TABLE `carshop`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `faction`
--
ALTER TABLE `faction`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `vehicle`
--
ALTER TABLE `vehicle`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `carshop`
--
ALTER TABLE `carshop`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `faction`
--
ALTER TABLE `faction`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `vehicle`
--
ALTER TABLE `vehicle`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
