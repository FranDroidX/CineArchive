-- MySQL dump 10.13  Distrib 8.0.22, for Win64 (x86_64)
--
-- Host: localhost    Database: cinearchive_v2
-- ------------------------------------------------------
-- Server version	8.0.39

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
-- Table structure for table `alquiler`
--

DROP TABLE IF EXISTS `alquiler`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alquiler` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint NOT NULL,
  `contenido_id` bigint NOT NULL,
  `fecha_inicio` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_fin` timestamp NOT NULL,
  `periodo_alquiler` int NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `estado` enum('ACTIVO','FINALIZADO','CANCELADO') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVO',
  `visto` tinyint(1) DEFAULT '0',
  `fecha_vista` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_alquiler_usuario` (`usuario_id`),
  KEY `idx_alquiler_contenido` (`contenido_id`),
  KEY `idx_alquiler_estado` (`estado`),
  KEY `idx_alquiler_fechas` (`fecha_inicio`,`fecha_fin`),
  CONSTRAINT `fk_alquiler_contenido` FOREIGN KEY (`contenido_id`) REFERENCES `contenido` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_alquiler_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alquiler`
--

LOCK TABLES `alquiler` WRITE;
/*!40000 ALTER TABLE `alquiler` DISABLE KEYS */;
INSERT INTO `alquiler` VALUES (2,1,38,'2025-11-11 22:29:05','2025-11-14 19:29:05',3,0.00,'FINALIZADO',0,NULL),(3,1,39,'2025-11-11 22:29:25','2025-11-14 19:29:25',3,0.00,'FINALIZADO',0,NULL);
/*!40000 ALTER TABLE `alquiler` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categoria`
--

DROP TABLE IF EXISTS `categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categoria` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo` enum('GENERO','TAG','CLASIFICACION') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`),
  KEY `idx_categoria_tipo` (`tipo`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categoria`
--

LOCK TABLES `categoria` WRITE;
/*!40000 ALTER TABLE `categoria` DISABLE KEYS */;
INSERT INTO `categoria` VALUES (1,'Acción','GENERO','Películas y series de acción'),(2,'Comedia','GENERO','Contenido de comedia'),(3,'Drama','GENERO','Contenido dramático'),(4,'Ciencia Ficción','GENERO','Contenido de ciencia ficción'),(5,'Terror','GENERO','Películas y series de terror'),(6,'Familiar','TAG','Contenido apto para toda la familia'),(7,'Premio Oscar','TAG','Contenido galardonado'),(8,'ATP','CLASIFICACION','Apto para todo público'),(9,'+13','CLASIFICACION','Mayores de 13 años'),(10,'+18','CLASIFICACION','Solo mayores de edad');
/*!40000 ALTER TABLE `categoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contenido`
--

DROP TABLE IF EXISTS `contenido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contenido` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `titulo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `genero` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `anio` int DEFAULT NULL,
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `imagen_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `trailer_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tipo` enum('PELICULA','SERIE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `disponible_para_alquiler` tinyint(1) DEFAULT '1',
  `precio_alquiler` decimal(10,2) NOT NULL,
  `copias_disponibles` int DEFAULT '0',
  `copias_totales` int DEFAULT '0',
  `fecha_vencimiento_licencia` date DEFAULT NULL,
  `id_api_externa` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gestor_inventario_id` bigint DEFAULT NULL,
  `duracion` int DEFAULT NULL,
  `director` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `temporadas` int DEFAULT NULL,
  `capitulos_totales` int DEFAULT NULL,
  `en_emision` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_contenido_gestor` (`gestor_inventario_id`),
  KEY `idx_contenido_tipo` (`tipo`),
  KEY `idx_contenido_disponible` (`disponible_para_alquiler`),
  KEY `idx_contenido_genero` (`genero`),
  KEY `idx_contenido_titulo` (`titulo`),
  CONSTRAINT `fk_contenido_gestor` FOREIGN KEY (`gestor_inventario_id`) REFERENCES `usuario` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contenido`
--

LOCK TABLES `contenido` WRITE;
/*!40000 ALTER TABLE `contenido` DISABLE KEYS */;
INSERT INTO `contenido` VALUES (6,'Matrix','Ciencia ficcion',1999,'Un programador descubre la verdad sobre la realidad.','https://picsum.photos/seed/TheMatrix/300/450','','PELICULA',1,3.99,5,5,NULL,NULL,2,136,'Lana Wachowski',NULL,NULL,0),(7,'El origen','Ciencia ficcion',2010,'Robo de ideas mediante sueños compartidos.','https://picsum.photos/seed/Inception/300/450','','PELICULA',1,4.50,4,4,NULL,NULL,2,148,'Christopher Nolan',NULL,NULL,0),(8,'Interestelar','Ciencia ficcion',2014,'Viaje espacial para encontrar un nuevo hogar.','https://picsum.photos/seed/Interstellar/300/450','','PELICULA',1,4.99,3,3,NULL,NULL,2,169,'Christopher Nolan',NULL,NULL,0),(9,'El padrino','Drama',1972,'La historia de la familia Corleone.','https://picsum.photos/seed/TheGodfather/300/450','','PELICULA',1,2.99,2,2,NULL,NULL,2,175,'Francis Ford Coppola',NULL,NULL,0),(10,'Tiempos violentos','Crimen',1994,'Historias interconectadas en Los Angeles.','https://picsum.photos/seed/PulpFiction/300/450','','PELICULA',1,2.50,3,3,NULL,NULL,2,154,'Quentin Tarantino',NULL,NULL,0),(11,'Breaking Bad - Temporada 1','Drama',2008,'Profesor de quimica inicia una carrera criminal.','https://picsum.photos/seed/BreakingBadT1/300/450','','SERIE',1,0.00,10,10,NULL,NULL,2,NULL,NULL,1,7,0),(12,'Breaking Bad - Temporada 2','Drama',2009,'Continuacion de la historia de Walter White.','https://picsum.photos/seed/BreakingBadT2/300/450','','SERIE',1,0.00,8,8,NULL,NULL,2,NULL,NULL,2,13,0),(13,'Stranger Things - Temporada 1','Fantasia',2016,'Ninos y sucesos paranormales en Hawkins.','https://picsum.photos/seed/StrangerThingsT1/300/450','','SERIE',1,0.00,6,6,NULL,NULL,2,NULL,NULL,1,8,0),(14,'El caballero de la noche','Accion',2008,'Batman contra el Joker.','https://picsum.photos/seed/TheDarkKnight/300/450','','PELICULA',1,3.50,4,4,NULL,NULL,2,152,'Christopher Nolan',NULL,NULL,0),(15,'Forrest Gump','Drama',1994,'Relato de la vida de Forrest Gump.','https://picsum.photos/seed/ForrestGump/300/450','','PELICULA',1,2.00,5,5,NULL,NULL,2,142,'Robert Zemeckis',NULL,NULL,0),(16,'La La Land','Musical',2016,'Historia de amor en Los Angeles.','https://picsum.photos/seed/LaLaLand/300/450','','PELICULA',1,2.99,3,3,NULL,NULL,2,128,'Damien Chazelle',NULL,NULL,0),(17,'Sueño de fuga','Drama',1994,'La amistad en una prision.','https://picsum.photos/seed/ShawshankRedemption/300/450','','PELICULA',1,2.99,4,4,NULL,NULL,2,142,'Frank Darabont',NULL,NULL,0),(18,'Avatar','Ciencia ficcion',2009,'Aventura en Pandora.','https://picsum.photos/seed/Avatar/300/450','','PELICULA',1,3.99,6,6,NULL,NULL,2,162,'James Cameron',NULL,NULL,0),(19,'The Office - Temporada 1','Comedia',2005,'Vida en una oficina.','https://picsum.photos/seed/TheOfficeT1/300/450','','SERIE',1,0.00,7,7,NULL,NULL,2,NULL,NULL,1,6,0),(20,'Friends - Temporada 1','Comedia',1994,'Grupo de amigos en NY.','https://picsum.photos/seed/FriendsT1/300/450','','SERIE',1,0.00,9,9,NULL,NULL,2,NULL,NULL,1,24,0),(21,'Gladiador','Accion',2000,'Venganza de un general romano.','https://picsum.photos/seed/Gladiator/300/450','','PELICULA',1,2.99,3,3,NULL,NULL,2,155,'Ridley Scott',NULL,NULL,0),(22,'Mad Max: Furia en el camino','Accion',2015,'Carrera por supervivencia en el desierto.','https://picsum.photos/seed/MadMaxFuryRoad/300/450','','PELICULA',1,3.49,4,4,NULL,NULL,2,120,'George Miller',NULL,NULL,0),(23,'Toy Story','Animacion',1995,'Juguetes que cobran vida.','https://picsum.photos/seed/ToyStory/300/450','','PELICULA',1,1.99,5,5,NULL,NULL,2,81,'John Lasseter',NULL,NULL,0),(24,'The Witcher - Temporada 1','Fantasia',2019,'Cazador de monstruos en un mundo de fantasia.','https://picsum.photos/seed/TheWitcherT1/300/450','','SERIE',1,0.00,5,5,NULL,NULL,2,NULL,NULL,1,8,0),(25,'Chernobyl','Drama',2019,'Miniserie sobre el desastre nuclear.','https://picsum.photos/seed/Chernobyl/300/450','','SERIE',1,0.00,4,4,NULL,NULL,2,NULL,NULL,1,5,0),(26,'The Mandalorian - Temporada 1','Ciencia ficcion',2019,'Cazarrecompensas tras la caida del Imperio.','https://picsum.photos/seed/MandalorianT1/300/450','','SERIE',1,0.00,5,5,NULL,NULL,2,NULL,NULL,1,8,1),(27,'Los Vengadores','Accion',2012,'Heroes se unen contra amenaza mundial.','https://picsum.photos/seed/Avengers/300/450','','PELICULA',1,3.99,5,5,NULL,NULL,2,143,'Joss Whedon',NULL,NULL,0),(28,'Vengadores: Endgame','Accion',2019,'Batalla final contra Thanos.','https://picsum.photos/seed/Endgame/300/450','','PELICULA',1,4.99,6,6,NULL,NULL,2,181,'Anthony Russo',NULL,NULL,0),(29,'Piratas del Caribe','Aventura',2003,'Jack Sparrow y corsarios.','https://picsum.photos/seed/Pirates1/300/450','','PELICULA',1,2.99,5,5,NULL,NULL,2,143,'Gore Verbinski',NULL,NULL,0),(30,'Piratas del Caribe: El cofre del hombre muerto','Aventura',2006,'Davy Jones y el cofre maldito.','https://picsum.photos/seed/Pirates2/300/450','','PELICULA',1,2.99,5,5,NULL,NULL,2,150,'Gore Verbinski',NULL,NULL,0),(31,'Piratas del Caribe: En el fin del mundo','Aventura',2007,'Final de la trilogia inicial.','https://picsum.photos/seed/Pirates3/300/450','','PELICULA',1,2.99,5,5,NULL,NULL,2,168,'Gore Verbinski',NULL,NULL,0),(32,'John Wick','Accion',2014,'Ex asesino regresa.','https://picsum.photos/seed/JohnWick1/300/450','','PELICULA',1,3.49,4,4,NULL,NULL,2,101,'Chad Stahelski',NULL,NULL,0),(33,'John Wick: Capítulo 2','Accion',2017,'Reglas del gremio.','https://picsum.photos/seed/JohnWick2/300/450','','PELICULA',1,3.49,4,4,NULL,NULL,2,122,'Chad Stahelski',NULL,NULL,0),(34,'John Wick: Capítulo 3','Accion',2019,'Huida frenetica.','https://picsum.photos/seed/JohnWick3/300/450','','PELICULA',1,3.99,4,4,NULL,NULL,2,130,'Chad Stahelski',NULL,NULL,0),(35,'John Wick: Capítulo 4','Accion',2023,'Enfrentamiento final.','https://picsum.photos/seed/JohnWick4/300/450','','PELICULA',1,4.49,4,4,NULL,NULL,2,169,'Chad Stahelski',NULL,NULL,0),(36,'Juego de tronos - Temporada 1','Fantasia',2011,'Nobles combaten por el Trono de Hierro.','https://picsum.photos/seed/GameofThronesT1/300/450','','SERIE',1,0.00,8,8,NULL,NULL,2,NULL,NULL,1,10,0),(37,'Juego de tronos - Temporada 2','Fantasia',2012,'La guerra de los cinco reyes se intensifica.','https://picsum.photos/seed/GameofThronesT2/300/450','','SERIE',1,0.00,8,8,NULL,NULL,2,NULL,NULL,2,10,0),(38,'Black Mirror - Temporada 1','Ciencia ficcion',2011,'Antología sobre tecnología y sociedad.','https://picsum.photos/seed/BlackMirrorT1/300/450','','SERIE',1,0.00,6,6,NULL,NULL,2,NULL,NULL,1,3,0),(39,'Black Mirror - Temporada 2','Ciencia ficcion',2013,'Nuevos episodios de crítica tecnológica.','https://picsum.photos/seed/BlackMirrorT2/300/450','','SERIE',1,0.00,6,6,NULL,NULL,2,NULL,NULL,2,3,0),(40,'El conjuro','Terror',2013,'Investigadores paranormales enfrentan entidad.','https://picsum.photos/seed/Conjuring/300/450','','PELICULA',1,2.99,4,4,NULL,NULL,2,112,'James Wan',NULL,NULL,0),(41,'Parásitos','Crimen',2019,'Familia se infiltra en hogar adinerado.','https://picsum.photos/seed/Parasite/300/450','','PELICULA',1,3.49,5,5,NULL,NULL,2,132,'Bong Joon-ho',NULL,NULL,0),(42,'Joker','Drama',2019,'Origen oscuro de un icono de Gotham.','https://picsum.photos/seed/Joker/300/450','','PELICULA',1,3.99,5,5,NULL,NULL,2,122,'Todd Phillips',NULL,NULL,0),(43,'Intensa-mente','Animacion',2015,'Emociones guían a una niña en transición.','https://picsum.photos/seed/InsideOut/300/450','','PELICULA',1,2.49,6,6,NULL,NULL,2,95,'Pete Docter',NULL,NULL,0),(44,'Up: Una aventura de altura','Animacion',2009,'Aventura aérea con casa y globos.','https://picsum.photos/seed/Up/300/450','','PELICULA',1,2.49,6,6,NULL,NULL,2,96,'Pete Docter',NULL,NULL,0),(45,'Titanic','Romance',1997,'Historia de amor a bordo del Titanic.','https://picsum.photos/seed/Titanic/300/450','','PELICULA',1,2.99,5,5,NULL,NULL,2,194,'James Cameron',NULL,NULL,0),(46,'Diario de una pasión','Romance',2004,'Amor perdurable a través de los años.','https://picsum.photos/seed/Notebook/300/450','','PELICULA',1,2.50,4,4,NULL,NULL,2,123,'Nick Cassavetes',NULL,NULL,0),(47,'Se7en: Los siete pecados capitales','Thriller',1995,'Dos detectives persiguen asesino de pecados.','https://picsum.photos/seed/Se7en/300/450','','PELICULA',1,2.99,4,4,NULL,NULL,2,127,'David Fincher',NULL,NULL,0),(48,'Alien: El octavo pasajero','Terror',1979,'Tripulación enfrenta criatura desconocida.','https://picsum.photos/seed/Alien/300/450','','PELICULA',1,2.99,4,4,NULL,NULL,2,117,'Ridley Scott',NULL,NULL,0),(49,'El silencio de los corderos','Thriller',1991,'Agente del FBI busca asesino con ayuda peligrosa.','https://picsum.photos/seed/SilenceLambs/300/450','','PELICULA',1,2.99,4,4,NULL,NULL,2,118,'Jonathan Demme',NULL,NULL,0),(50,'El viaje de Chihiro','Animacion',2001,'Niña en mundo de espíritus y baños mágicos.','https://picsum.photos/seed/SpiritedAway/300/450','','PELICULA',1,2.99,5,5,NULL,NULL,2,125,'Hayao Miyazaki',NULL,NULL,0),(51,'Coco','Animacion',2017,'Niño viaja al Mundo de los Muertos por su música.','https://picsum.photos/seed/Coco/300/450','','PELICULA',1,2.99,6,6,NULL,NULL,2,105,'Lee Unkrich',NULL,NULL,0),(52,'El rey león','Animacion',1994,'Ciclo de la vida en la sabana africana.','https://picsum.photos/seed/LionKing/300/450','','PELICULA',1,2.49,6,6,NULL,NULL,2,88,'Roger Allers',NULL,NULL,0),(53,'Blade Runner 2049','Ciencia ficcion',2017,'Nueva investigación revela secretos ocultos.','https://picsum.photos/seed/BladeRunner2049/300/450','','PELICULA',1,3.99,4,4,NULL,NULL,2,164,'Denis Villeneuve',NULL,NULL,0),(54,'Duna','Ciencia ficcion',2021,'Casa Atreides lucha por Arrakis.','https://picsum.photos/seed/Dune/300/450','','PELICULA',1,4.99,5,5,NULL,NULL,2,155,'Denis Villeneuve',NULL,NULL,0),(55,'La llegada','Ciencia ficcion',2016,'Lingüista intenta comunicar con extraterrestres.','https://picsum.photos/seed/Arrival/300/450','','PELICULA',1,3.49,4,4,NULL,NULL,2,116,'Denis Villeneuve',NULL,NULL,0),(56,'Whiplash: Música y obsesión','Drama',2014,'Baterista enfrenta exigente mentor.','https://picsum.photos/seed/Whiplash/300/450','','PELICULA',1,2.99,4,4,NULL,NULL,2,106,'Damien Chazelle',NULL,NULL,0),(57,'Los miserables','Musical',2012,'Redención y revolución en Francia.','https://picsum.photos/seed/LesMiserables/300/450','','PELICULA',1,2.99,3,3,NULL,NULL,2,158,'Tom Hooper',NULL,NULL,0),(58,'Hamilton','Musical',2020,'Historia de Alexander Hamilton en formato teatral.','https://picsum.photos/seed/Hamilton/300/450','','PELICULA',1,3.99,3,3,NULL,NULL,2,160,'Thomas Kail',NULL,NULL,0),(59,'Misión: Imposible - Repercusión','Accion',2018,'Ethan Hunt salva al mundo otra vez.','https://picsum.photos/seed/MIFallout/300/450','','PELICULA',1,3.99,5,5,NULL,NULL,2,147,'Christopher McQuarrie',NULL,NULL,0),(60,'Al filo del mañana','Accion',2014,'Soldado revive batalla alienígena repetidamente.','https://picsum.photos/seed/EdgeTomorrow/300/450','','PELICULA',1,3.49,5,5,NULL,NULL,2,113,'Doug Liman',NULL,NULL,0),(61,'Sin lugar para los débiles','Thriller',2007,'Cartera con dinero desata persecución mortal.','https://picsum.photos/seed/NoCountry/300/450','','PELICULA',1,2.99,4,4,NULL,NULL,2,122,'Ethan Coen',NULL,NULL,0),(62,'Ella','Romance',2013,'Hombre se enamora de sistema operativo.','https://picsum.photos/seed/Her/300/450','','PELICULA',1,2.99,4,4,NULL,NULL,2,126,'Spike Jonze',NULL,NULL,0),(63,'The Walking Dead - Temporada 1','Terror',2010,'Supervivencia en apocalipsis zombi.','https://picsum.photos/seed/WalkingDeadT1/300/450','','SERIE',1,0.00,7,7,NULL,NULL,2,NULL,NULL,1,6,0),(64,'Sherlock - Temporada 1','Thriller',2010,'Detective moderno resuelve casos en Londres.','https://picsum.photos/seed/SherlockT1/300/450','','SERIE',1,0.00,6,6,NULL,NULL,2,NULL,NULL,1,3,0),(65,'Narcos - Temporada 1','Crimen',2015,'Ascenso de Pablo Escobar y lucha antidrogas.','https://picsum.photos/seed/NarcosT1/300/450','','SERIE',1,0.00,6,6,NULL,NULL,2,NULL,NULL,1,10,0),(66,'Stranger Things - Temporada 2','Fantasia',2017,'Nuevas amenazas desde el Otro Lado.','https://picsum.photos/seed/StrangerThingsT2/300/450','','SERIE',1,0.00,6,6,NULL,NULL,2,NULL,NULL,2,9,0);
/*!40000 ALTER TABLE `contenido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contenido_categoria`
--

DROP TABLE IF EXISTS `contenido_categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contenido_categoria` (
  `contenido_id` bigint NOT NULL,
  `categoria_id` bigint NOT NULL,
  PRIMARY KEY (`contenido_id`,`categoria_id`),
  KEY `fk_cc_categoria` (`categoria_id`),
  CONSTRAINT `fk_cc_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categoria` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cc_contenido` FOREIGN KEY (`contenido_id`) REFERENCES `contenido` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contenido_categoria`
--

LOCK TABLES `contenido_categoria` WRITE;
/*!40000 ALTER TABLE `contenido_categoria` DISABLE KEYS */;
/*!40000 ALTER TABLE `contenido_categoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lista`
--

DROP TABLE IF EXISTS `lista`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lista` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `usuario_id` bigint NOT NULL,
  `publica` tinyint(1) DEFAULT '0',
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_lista_usuario` (`usuario_id`),
  KEY `idx_lista_publica` (`publica`),
  CONSTRAINT `fk_lista_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lista`
--

LOCK TABLES `lista` WRITE;
/*!40000 ALTER TABLE `lista` DISABLE KEYS */;
INSERT INTO `lista` VALUES (1,'mi-lista','',1,0,'2025-11-11 01:08:24'),(2,'para-ver','',1,0,'2025-11-11 01:08:24');
/*!40000 ALTER TABLE `lista` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lista_contenido`
--

DROP TABLE IF EXISTS `lista_contenido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lista_contenido` (
  `lista_id` bigint NOT NULL,
  `contenido_id` bigint NOT NULL,
  `orden` int DEFAULT '0',
  `fecha_agregado` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`lista_id`,`contenido_id`),
  KEY `fk_lc_contenido` (`contenido_id`),
  KEY `idx_lista_contenido_orden` (`lista_id`,`orden`),
  KEY `idx_lista_contenido_lista` (`lista_id`),
  KEY `idx_lista_contenido_contenido` (`contenido_id`),
  CONSTRAINT `fk_lc_contenido` FOREIGN KEY (`contenido_id`) REFERENCES `contenido` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_lc_lista` FOREIGN KEY (`lista_id`) REFERENCES `lista` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lista_contenido`
--

LOCK TABLES `lista_contenido` WRITE;
/*!40000 ALTER TABLE `lista_contenido` DISABLE KEYS */;
INSERT INTO `lista_contenido` VALUES (1,11,0,'2025-11-11 22:31:03'),(1,18,0,'2025-11-11 22:27:12'),(2,18,0,'2025-11-11 22:27:16'),(2,53,0,'2025-11-11 22:31:01');
/*!40000 ALTER TABLE `lista_contenido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `metodo_pago`
--

DROP TABLE IF EXISTS `metodo_pago`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `metodo_pago` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint NOT NULL,
  `tipo` enum('TARJETA_CREDITO','TARJETA_DEBITO','MERCADOPAGO','PAYPAL','TRANSFERENCIA','EFECTIVO') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `alias` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `titular` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `numero_tarjeta` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Ultimos 4 digitos',
  `fecha_vencimiento` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Formato MM/YYYY',
  `tipo_tarjeta` enum('VISA','MASTERCARD','AMEX','OTRO') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_plataforma` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Email para MercadoPago, PayPal, etc',
  `preferido` tinyint(1) DEFAULT '0',
  `activo` tinyint(1) DEFAULT '1',
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_metodo_pago_usuario` (`usuario_id`),
  KEY `idx_metodo_pago_tipo` (`tipo`),
  KEY `idx_metodo_pago_activo` (`activo`),
  CONSTRAINT `fk_metodo_pago_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metodo_pago`
--

LOCK TABLES `metodo_pago` WRITE;
/*!40000 ALTER TABLE `metodo_pago` DISABLE KEYS */;
INSERT INTO `metodo_pago` VALUES (1,1,'TARJETA_CREDITO','Mi Visa Principal','Admin Sistema','1234','12/2025','VISA',NULL,1,1,'2025-11-16 03:40:33'),(2,1,'MERCADOPAGO','MercadoPago Personal',NULL,NULL,NULL,NULL,'admin@cinearchive.com',0,1,'2025-11-16 03:40:33'),(3,4,'TARJETA_DEBITO','Tarjeta Débito','María García','5678','06/2026','MASTERCARD',NULL,1,1,'2025-11-16 03:40:33');
/*!40000 ALTER TABLE `metodo_pago` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reporte`
--

DROP TABLE IF EXISTS `reporte`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reporte` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `analista_id` bigint NOT NULL,
  `titulo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `tipo_reporte` enum('MAS_ALQUILADOS','ANALISIS_DEMOGRAFICO','RENDIMIENTO_GENEROS','TENDENCIAS_TEMPORALES','COMPORTAMIENTO_USUARIOS') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parametros` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `resultados` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `fecha_generacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `periodo_inicio` date DEFAULT NULL,
  `periodo_fin` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_reporte_analista` (`analista_id`),
  KEY `idx_reporte_tipo` (`tipo_reporte`),
  KEY `idx_reporte_fecha` (`fecha_generacion`),
  CONSTRAINT `fk_reporte_analista` FOREIGN KEY (`analista_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reporte`
--

LOCK TABLES `reporte` WRITE;
/*!40000 ALTER TABLE `reporte` DISABLE KEYS */;
/*!40000 ALTER TABLE `reporte` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resena`
--

DROP TABLE IF EXISTS `resena`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resena` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint NOT NULL,
  `contenido_id` bigint NOT NULL,
  `calificacion` double NOT NULL,
  `titulo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `texto` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_modificacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_resena_usuario_contenido` (`usuario_id`,`contenido_id`),
  KEY `idx_resena_contenido` (`contenido_id`),
  KEY `idx_resena_usuario` (`usuario_id`),
  KEY `idx_resena_calificacion` (`calificacion`),
  CONSTRAINT `fk_resena_contenido` FOREIGN KEY (`contenido_id`) REFERENCES `contenido` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_resena_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_calificacion` CHECK (((`calificacion` >= 1.0) and (`calificacion` <= 5.0)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resena`
--

LOCK TABLES `resena` WRITE;
/*!40000 ALTER TABLE `resena` DISABLE KEYS */;
/*!40000 ALTER TABLE `resena` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaccion`
--

DROP TABLE IF EXISTS `transaccion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaccion` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint NOT NULL,
  `alquiler_id` bigint NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `metodo_pago_id` bigint DEFAULT NULL,
  `metodo_pago` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_transaccion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` enum('COMPLETADA','PENDIENTE','FALLIDA','REEMBOLSADA') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `referencia_externa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_transaccion_alquiler` (`alquiler_id`),
  KEY `idx_transaccion_usuario` (`usuario_id`),
  KEY `idx_transaccion_fecha` (`fecha_transaccion`),
  KEY `idx_transaccion_estado` (`estado`),
  KEY `fk_transaccion_metodo_pago` (`metodo_pago_id`),
  CONSTRAINT `fk_transaccion_alquiler` FOREIGN KEY (`alquiler_id`) REFERENCES `alquiler` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_transaccion_metodo_pago` FOREIGN KEY (`metodo_pago_id`) REFERENCES `metodo_pago` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_transaccion_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaccion`
--

LOCK TABLES `transaccion` WRITE;
/*!40000 ALTER TABLE `transaccion` DISABLE KEYS */;
/*!40000 ALTER TABLE `transaccion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contrasena` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `rol` enum('USUARIO_REGULAR','ADMINISTRADOR','GESTOR_INVENTARIO','ANALISTA_DATOS') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USUARIO_REGULAR',
  `fecha_registro` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `activo` tinyint(1) DEFAULT '1',
  `fecha_nacimiento` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_usuario_email` (`email`),
  KEY `idx_usuario_rol` (`rol`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (1,'Admin Sistema','admin@cinearchive.com','$2a$12$CQ.gB6fkdok4ThAKQXqOZeg8mpD9.nkjmemXFhNZaclomFsW0Uiy.','ADMINISTRADOR','2025-10-21 19:54:15',1,'1985-05-15'),(2,'Gestor Principal','gestor@cinearchive.com','$2a$12$qMgPs/St/FL/vqVPQEvJ/eYZ4iP8VWBj7gXsPZkYClFvYMi30VnNS','GESTOR_INVENTARIO','2025-10-21 19:54:15',1,'1990-08-22'),(3,'Analista Datos','analista@cinearchive.com','$2a$12$vDa1JJlVgbJCLMVJElIHpuUT10ig8KA41TSz2KGBd/pyLOoPoJBeC','ANALISTA_DATOS','2025-10-21 19:54:15',1,'1988-12-03'),(4,'María García','maria@example.com','$2a$12$OdNbQt7CQvSQ3UiajoYJH.J6cpjcwGltwZO4ZKyPSOFzs/39JCIaq','USUARIO_REGULAR','2025-10-21 19:54:15',1,'1995-03-15'),(9,'Francisco','franciscofchiminelli@hotmail.com','$2a$12$.3tRcDJIkWQcqaVyPGNflOOAaZtt.pxBBmTbV/OQ7mEE7W76SeLnu','USUARIO_REGULAR','2025-11-11 03:00:00',1,'2001-01-05');
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vista_alquileres_activos`
--

DROP TABLE IF EXISTS `vista_alquileres_activos`;
/*!50001 DROP VIEW IF EXISTS `vista_alquileres_activos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_alquileres_activos` AS SELECT 
 1 AS `alquiler_id`,
 1 AS `usuario_nombre`,
 1 AS `usuario_email`,
 1 AS `contenido_titulo`,
 1 AS `contenido_tipo`,
 1 AS `fecha_inicio`,
 1 AS `fecha_fin`,
 1 AS `precio`,
 1 AS `dias_restantes`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vista_contenido_popular`
--

DROP TABLE IF EXISTS `vista_contenido_popular`;
/*!50001 DROP VIEW IF EXISTS `vista_contenido_popular`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_contenido_popular` AS SELECT 
 1 AS `id`,
 1 AS `titulo`,
 1 AS `tipo`,
 1 AS `genero`,
 1 AS `total_alquileres`,
 1 AS `calificacion_promedio`,
 1 AS `total_resenas`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vista_ingresos_por_mes`
--

DROP TABLE IF EXISTS `vista_ingresos_por_mes`;
/*!50001 DROP VIEW IF EXISTS `vista_ingresos_por_mes`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_ingresos_por_mes` AS SELECT 
 1 AS `mes`,
 1 AS `total_transacciones`,
 1 AS `ingresos_totales`,
 1 AS `ticket_promedio`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vista_alquileres_activos`
--

/*!50001 DROP VIEW IF EXISTS `vista_alquileres_activos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_alquileres_activos` AS select `a`.`id` AS `alquiler_id`,`u`.`nombre` AS `usuario_nombre`,`u`.`email` AS `usuario_email`,`c`.`titulo` AS `contenido_titulo`,`c`.`tipo` AS `contenido_tipo`,`a`.`fecha_inicio` AS `fecha_inicio`,`a`.`fecha_fin` AS `fecha_fin`,`a`.`precio` AS `precio`,(to_days(`a`.`fecha_fin`) - to_days(now())) AS `dias_restantes` from ((`alquiler` `a` join `usuario` `u` on((`a`.`usuario_id` = `u`.`id`))) join `contenido` `c` on((`a`.`contenido_id` = `c`.`id`))) where ((`a`.`estado` = 'ACTIVO') and (`a`.`fecha_fin` > now())) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vista_contenido_popular`
--

/*!50001 DROP VIEW IF EXISTS `vista_contenido_popular`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_contenido_popular` AS select `c`.`id` AS `id`,`c`.`titulo` AS `titulo`,`c`.`tipo` AS `tipo`,`c`.`genero` AS `genero`,count(`a`.`id`) AS `total_alquileres`,avg(`r`.`calificacion`) AS `calificacion_promedio`,count(distinct `r`.`id`) AS `total_resenas` from ((`contenido` `c` left join `alquiler` `a` on((`c`.`id` = `a`.`contenido_id`))) left join `resena` `r` on((`c`.`id` = `r`.`contenido_id`))) group by `c`.`id`,`c`.`titulo`,`c`.`tipo`,`c`.`genero` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vista_ingresos_por_mes`
--

/*!50001 DROP VIEW IF EXISTS `vista_ingresos_por_mes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_ingresos_por_mes` AS select date_format(`t`.`fecha_transaccion`,'%Y-%m') AS `mes`,count(`t`.`id`) AS `total_transacciones`,sum(`t`.`monto`) AS `ingresos_totales`,avg(`t`.`monto`) AS `ticket_promedio` from `transaccion` `t` where (`t`.`estado` = 'COMPLETADA') group by date_format(`t`.`fecha_transaccion`,'%Y-%m') order by `mes` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-16  0:45:43
