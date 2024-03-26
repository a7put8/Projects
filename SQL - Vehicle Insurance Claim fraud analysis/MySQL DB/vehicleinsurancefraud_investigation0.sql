-- MySQL dump 10.13  Distrib 8.0.34, for Win64 (x86_64)
--
-- Host: localhost    Database: vehicleinsurancefraud
-- ------------------------------------------------------
-- Server version	8.0.35

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `investigation`
--

DROP TABLE IF EXISTS `investigation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `investigation` (
  `InvestigationID` int NOT NULL,
  `Days_Policy_Accident` text,
  `Days_Policy_Claim` text,
  `PoliceReportFiled` text,
  `WitnessPresent` text,
  PRIMARY KEY (`InvestigationID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `investigation`
--

LOCK TABLES `investigation` WRITE;
/*!40000 ALTER TABLE `investigation` DISABLE KEYS */;
INSERT INTO `investigation` VALUES (1,'more than 30','more than 30','No','No'),(2,'more than 30','more than 30','No','Yes'),(3,'more than 30','more than 30','Yes','No'),(4,'more than 30','more than 30','Yes','Yes'),(5,'more than 30','15 to 30','No','No'),(6,'more than 30','15 to 30','No','Yes'),(7,'more than 30','15 to 30','Yes','No'),(8,'more than 30','15 to 30','Yes','Yes'),(9,'more than 30','8 to 15','No','No'),(10,'more than 30','8 to 15','No','Yes'),(11,'more than 30','8 to 15','Yes','No'),(12,'more than 30','8 to 15','Yes','Yes'),(13,'more than 30','1 to 7','No','No'),(14,'more than 30','1 to 7','No','Yes'),(15,'more than 30','1 to 7','Yes','No'),(16,'more than 30','1 to 7','Yes','Yes'),(17,'more than 30','none','No','No'),(18,'more than 30','none','No','Yes'),(19,'more than 30','none','Yes','No'),(20,'more than 30','none','Yes','Yes'),(21,'15 to 30','more than 30','No','No'),(22,'15 to 30','more than 30','No','Yes'),(23,'15 to 30','more than 30','Yes','No'),(24,'15 to 30','more than 30','Yes','Yes'),(25,'15 to 30','15 to 30','No','No'),(26,'15 to 30','15 to 30','No','Yes'),(27,'15 to 30','15 to 30','Yes','No'),(28,'15 to 30','15 to 30','Yes','Yes'),(29,'15 to 30','8 to 15','No','No'),(30,'15 to 30','8 to 15','No','Yes'),(31,'15 to 30','8 to 15','Yes','No'),(32,'15 to 30','8 to 15','Yes','Yes'),(33,'15 to 30','1 to 7','No','No'),(34,'15 to 30','1 to 7','No','Yes'),(35,'15 to 30','1 to 7','Yes','No'),(36,'15 to 30','1 to 7','Yes','Yes'),(37,'15 to 30','none','No','No'),(38,'15 to 30','none','No','Yes'),(39,'15 to 30','none','Yes','No'),(40,'15 to 30','none','Yes','Yes'),(41,'8 to 15','more than 30','No','No'),(42,'8 to 15','more than 30','No','Yes'),(43,'8 to 15','more than 30','Yes','No'),(44,'8 to 15','more than 30','Yes','Yes'),(45,'8 to 15','15 to 30','No','No'),(46,'8 to 15','15 to 30','No','Yes'),(47,'8 to 15','15 to 30','Yes','No'),(48,'8 to 15','15 to 30','Yes','Yes'),(49,'8 to 15','8 to 15','No','No'),(50,'8 to 15','8 to 15','No','Yes'),(51,'8 to 15','8 to 15','Yes','No'),(52,'8 to 15','8 to 15','Yes','Yes'),(53,'8 to 15','1 to 7','No','No'),(54,'8 to 15','1 to 7','No','Yes'),(55,'8 to 15','1 to 7','Yes','No'),(56,'8 to 15','1 to 7','Yes','Yes'),(57,'8 to 15','none','No','No'),(58,'8 to 15','none','No','Yes'),(59,'8 to 15','none','Yes','No'),(60,'8 to 15','none','Yes','Yes'),(61,'1 to 7','more than 30','No','No'),(62,'1 to 7','more than 30','No','Yes'),(63,'1 to 7','more than 30','Yes','No'),(64,'1 to 7','more than 30','Yes','Yes'),(65,'1 to 7','15 to 30','No','No'),(66,'1 to 7','15 to 30','No','Yes'),(67,'1 to 7','15 to 30','Yes','No'),(68,'1 to 7','15 to 30','Yes','Yes'),(69,'1 to 7','8 to 15','No','No'),(70,'1 to 7','8 to 15','No','Yes'),(71,'1 to 7','8 to 15','Yes','No'),(72,'1 to 7','8 to 15','Yes','Yes'),(73,'1 to 7','1 to 7','No','No'),(74,'1 to 7','1 to 7','No','Yes'),(75,'1 to 7','1 to 7','Yes','No'),(76,'1 to 7','1 to 7','Yes','Yes'),(77,'1 to 7','none','No','No'),(78,'1 to 7','none','No','Yes'),(79,'1 to 7','none','Yes','No'),(80,'1 to 7','none','Yes','Yes'),(81,'none','more than 30','No','No'),(82,'none','more than 30','No','Yes'),(83,'none','more than 30','Yes','No'),(84,'none','more than 30','Yes','Yes'),(85,'none','15 to 30','No','No'),(86,'none','15 to 30','No','Yes'),(87,'none','15 to 30','Yes','No'),(88,'none','15 to 30','Yes','Yes'),(89,'none','8 to 15','No','No'),(90,'none','8 to 15','No','Yes'),(91,'none','8 to 15','Yes','No'),(92,'none','8 to 15','Yes','Yes'),(93,'none','1 to 7','No','No'),(94,'none','1 to 7','No','Yes'),(95,'none','1 to 7','Yes','No'),(96,'none','1 to 7','Yes','Yes'),(97,'none','none','No','No'),(98,'none','none','No','Yes'),(99,'none','none','Yes','No'),(100,'none','none','Yes','Yes');
/*!40000 ALTER TABLE `investigation` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-11-29 11:16:15
