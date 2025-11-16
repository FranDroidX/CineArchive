-- Script de migración para agregar soporte de métodos de pago
-- Fecha: 2025-01-16
-- Descripción: Agrega tabla metodo_pago y actualiza tabla transaccion

USE cinearchive_v2;

-- Crear tabla de métodos de pago
DROP TABLE IF EXISTS `metodo_pago`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertar métodos de pago de ejemplo
INSERT INTO `metodo_pago`
(`usuario_id`, `tipo`, `alias`, `titular`, `numero_tarjeta`, `fecha_vencimiento`, `tipo_tarjeta`, `email_plataforma`, `preferido`, `activo`)
VALUES
(1, 'TARJETA_CREDITO', 'Mi Visa Principal', 'Admin Sistema', '1234', '12/2025', 'VISA', NULL, 1, 1),
(1, 'MERCADOPAGO', 'MercadoPago Personal', NULL, NULL, NULL, NULL, 'admin@cinearchive.com', 0, 1),
(4, 'TARJETA_DEBITO', 'Tarjeta Débito', 'María García', '5678', '06/2026', 'MASTERCARD', NULL, 1, 1);

-- Actualizar tabla transaccion para agregar referencia a metodo_pago
-- Primero verificar si la columna ya existe
SET @exist := (SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'cinearchive_v2'
    AND TABLE_NAME = 'transaccion'
    AND COLUMN_NAME = 'metodo_pago_id');

SET @sqlstmt := IF(@exist = 0,
    'ALTER TABLE transaccion ADD COLUMN metodo_pago_id bigint DEFAULT NULL AFTER monto',
    'SELECT "La columna metodo_pago_id ya existe" AS mensaje');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Agregar la constraint de foreign key si no existe
SET @fk_exist := (SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE TABLE_SCHEMA = 'cinearchive_v2'
    AND TABLE_NAME = 'transaccion'
    AND CONSTRAINT_NAME = 'fk_transaccion_metodo_pago');

SET @fk_sqlstmt := IF(@fk_exist = 0,
    'ALTER TABLE transaccion ADD CONSTRAINT fk_transaccion_metodo_pago FOREIGN KEY (metodo_pago_id) REFERENCES metodo_pago(id) ON DELETE SET NULL ON UPDATE CASCADE',
    'SELECT "La foreign key fk_transaccion_metodo_pago ya existe" AS mensaje');

PREPARE fk_stmt FROM @fk_sqlstmt;
EXECUTE fk_stmt;
DEALLOCATE PREPARE fk_stmt;

SELECT 'Migración completada exitosamente' AS resultado;

