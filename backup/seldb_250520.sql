-- phpMyAdmin SQL Dump
-- version 4.9.5
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 26-05-2020 a las 03:09:02
-- Versión del servidor: 5.7.24
-- Versión de PHP: 7.2.19

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `seldb`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AGREGAR_BITACORA` (IN `P_TABLA` VARCHAR(35), IN `P_ACCION` VARCHAR(35), IN `P_DETALLE` VARCHAR(600), IN `P_COMENTARIOS` VARCHAR(150), IN `P_USUARIO` VARCHAR(50), OUT `P_CLAVE` INT)  BEGIN DECLARE iClave INT; CALL OBTENER_CLAVE( 'bitacora', @out_value_clave2 ); SELECT @out_value_clave2 INTO iClave; INSERT INTO bitacora ( clave, tabla , accion , detalle , comentarios , usuario ) VALUES ( iClave, P_TABLA , P_ACCION , P_DETALLE , P_COMENTARIOS , P_USUARIO ); UPDATE claves_tablas SET clave = iClave WHERE tabla = 'bitacora'; SET P_CLAVE = iClave; END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `OBTENER_CLAVE` (IN `P_NOMBRE_TABLA` VARCHAR(45), OUT `O_CLAVE` INT)  NO SQL
BEGIN

SET @@max_sp_recursion_depth = 1 ;

SELECT clave + 1 INTO O_CLAVE FROM claves_tablas WHERE tabla =  P_NOMBRE_TABLA  LIMIT 1;

	IF ( O_CLAVE IS NULL ) THEN	
		SET @iClave = 0;
		SET @query = CONCAT('SELECT COALESCE( MAX( clave ) + 1 , 1 ) INTO @iClave FROM ', P_NOMBRE_TABLA , ' WHERE clave <= 2147483647' );
		PREPARE st FROM @query;
		EXECUTE st;
		DEALLOCATE PREPARE st;

		INSERT INTO claves_tablas(tabla,clave) VALUES ( P_NOMBRE_TABLA , @iClave );
		SET O_CLAVE = @iClave;
	END IF;

END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `OBTENER_PARAMETRO` (IN `P_NOMBRE` VARCHAR(35), IN `P_VALOR_DEFECTO` VARCHAR(100), OUT `O_PARAMETRO` VARCHAR(100))  BEGIN

SELECT valor INTO O_PARAMETRO FROM parametros WHERE nombre = P_NOMBRE LIMIT 1;

  	IF(O_PARAMETRO IS NULL) THEN
    INSERT INTO parametros (nombre, valor) VALUES(P_NOMBRE, P_VALOR_DEFECTO);
    SET O_PARAMETRO = P_VALOR_DEFECTO;
	END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `OBTENER_PREFERENCIA_USUARIO` (IN `P_CLAVE_USUARIO` INT, IN `P_CLAVE_SUCURSAL` INT, IN `P_NOMBRE` VARCHAR(45), IN `P_VALOR_DEFECTO` VARCHAR(45), OUT `O_VALOR` VARCHAR(45))  BEGIN

SELECT valor INTO O_VALOR FROM usuarios_preferencias WHERE usuario = P_CLAVE_USUARIO AND sucursal = P_CLAVE_SUCURSAL LIMIT 1;

  	IF(O_VALOR IS NULL) THEN
    INSERT INTO usuarios_preferencias (usuario, sucursal, nombre, valor) VALUES(P_CLAVE_USUARIO, P_CLAVE_SUCURSAL, P_NOMBRE, P_VALOR_DEFECTO);
    SET O_VALOR = P_VALOR_DEFECTO;
	END IF;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alumnos`
--

CREATE TABLE `alumnos` (
  `id_alumno` smallint(11) NOT NULL,
  `numero_control` int(11) NOT NULL DEFAULT '0',
  `curp` varchar(18) NOT NULL,
  `nombre` varchar(60) NOT NULL DEFAULT '',
  `apellido_paterno` varchar(95) NOT NULL,
  `apellido_materno` varchar(95) NOT NULL,
  `id_nivel` int(11) NOT NULL,
  `id_grado` int(11) NOT NULL DEFAULT '0',
  `id_grupo` int(11) NOT NULL,
  `observaciones` varchar(50) NOT NULL DEFAULT '',
  `estatus` char(1) NOT NULL,
  `fecha_alta` datetime NOT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `alumnos`
--

INSERT INTO `alumnos` (`id_alumno`, `numero_control`, `curp`, `nombre`, `apellido_paterno`, `apellido_materno`, `id_nivel`, `id_grado`, `id_grupo`, `observaciones`, `estatus`, `fecha_alta`, `fecha_modificacion`) VALUES
(1, 10053, 'GUPJ52563689I23', 'Juan José', 'Pérez', 'Guillén', 1, 1, 2, '', '', '2020-05-25 11:12:19', '2020-05-25 18:58:48'),
(2, 10058, '', 'Juan', 'Pérez', 'Hernández', 1, 2, 2, '', '', '2020-05-25 11:12:19', '2020-05-17 19:10:12'),
(16, 10057, '', 'Andrés', 'Velasco', 'Gordillo', 1, 2, 2, '', '', '2020-05-25 11:12:19', '2020-05-25 18:43:57'),
(17, 10051, '', 'Jonathan', 'Culebro', 'Domínguez', 1, 1, 2, '', '', '2020-05-25 11:12:19', '2020-05-17 19:11:10'),
(18, 10052, '', 'Ana Patricia', 'Torres', 'Ventura', 2, 1, 1, '', '', '2020-05-25 11:12:19', '2020-05-25 18:50:33'),
(19, 10054, '', 'Javier ', 'Hernández', 'López', 1, 1, 2, '', '', '2020-05-02 14:03:54', '2020-05-17 19:11:00'),
(20, 10055, '', 'Guadalupe', 'Reyes', 'Abarca', 2, 1, 2, '', '', '2020-05-02 14:06:13', '2020-05-17 19:10:29'),
(21, 10056, 'VETA090126', 'Andrea', 'Velasco', 'Torres', 2, 2, 1, '', '', '2020-05-02 21:47:25', '2020-05-25 18:17:36');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `areas`
--

CREATE TABLE `areas` (
  `id_area` int(11) NOT NULL,
  `nombre` char(35) NOT NULL DEFAULT '',
  `clave` varchar(35) NOT NULL,
  `fecha_alta` datetime NOT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `areas`
--

INSERT INTO `areas` (`id_area`, `nombre`, `clave`, `fecha_alta`, `fecha_modificacion`) VALUES
(1, 'Ciencias sociales y administrativas', 'CS01', '0000-00-00 00:00:00', '2020-05-23 23:31:02'),
(2, 'Ciencias Físico matemáticas', 'FS01', '0000-00-00 00:00:00', '2020-05-24 23:31:58'),
(3, 'Químico biólogos', 'QB03', '2020-05-12 16:32:55', '2020-05-24 23:31:49'),
(4, 'Docencia', 'DC01', '2020-05-18 19:47:39', '2020-05-19 16:32:27'),
(5, 'Lengua y comunicación', 'LC01', '2020-05-18 19:49:10', '2020-05-19 16:33:30');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `areas_niveles`
--

CREATE TABLE `areas_niveles` (
  `id` int(11) NOT NULL,
  `id_area` int(11) NOT NULL,
  `id_nivel` int(11) NOT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `areas_niveles`
--

INSERT INTO `areas_niveles` (`id`, `id_area`, `id_nivel`, `fecha_modificacion`) VALUES
(5, 4, 1, '2020-05-19 16:32:27'),
(6, 4, 2, '2020-05-19 16:32:27'),
(7, 5, 1, '2020-05-19 16:33:30'),
(8, 5, 2, '2020-05-19 16:33:30'),
(21, 1, 1, '2020-05-23 23:31:02'),
(22, 1, 2, '2020-05-23 23:31:02'),
(23, 3, 1, '2020-05-24 23:31:49'),
(24, 3, 2, '2020-05-24 23:31:49'),
(26, 2, 1, '2020-05-24 23:31:58'),
(27, 2, 2, '2020-05-24 23:31:58');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asignaturas`
--

CREATE TABLE `asignaturas` (
  `id_asignatura` int(11) NOT NULL,
  `clave` varchar(35) NOT NULL,
  `nombre` char(35) NOT NULL DEFAULT '',
  `descripcion` varchar(135) NOT NULL,
  `unidades` int(11) DEFAULT NULL,
  `id_area` int(11) NOT NULL,
  `fecha_alta` datetime NOT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `asignaturas`
--

INSERT INTO `asignaturas` (`id_asignatura`, `clave`, `nombre`, `descripcion`, `unidades`, `id_area`, `fecha_alta`, `fecha_modificacion`) VALUES
(1, '', 'Pensamiento matemático', '', NULL, 2, '0000-00-00 00:00:00', '2020-05-19 17:03:07'),
(2, 'CL001', 'Comprensión lectora', '', NULL, 5, '0000-00-00 00:00:00', '2020-05-22 03:36:08'),
(3, '', 'Pensamiento analítico', '', NULL, 2, '0000-00-00 00:00:00', '2020-05-19 17:03:04'),
(4, '', 'Estructura de la lengua', '', NULL, 5, '0000-00-00 00:00:00', '2020-05-19 17:03:02'),
(5, '', 'Pensamiento lógico', '', NULL, 2, '2020-05-18 19:51:57', '2020-05-19 00:52:33'),
(7, 'BL001', 'Biología', '', NULL, 3, '2020-05-21 11:22:50', '2020-05-22 03:17:01'),
(8, 'QM001', 'Química', '', NULL, 3, '2020-05-24 20:16:36', '2020-05-25 01:16:41');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asignaturas_alumnos`
--

CREATE TABLE `asignaturas_alumnos` (
  `id` int(11) NOT NULL,
  `id_alumno` int(11) NOT NULL DEFAULT '0',
  `id_asignatura` int(11) NOT NULL DEFAULT '0',
  `estatus` char(1) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asignaturas_areas`
--

CREATE TABLE `asignaturas_areas` (
  `id` int(11) NOT NULL,
  `id_area` int(11) NOT NULL DEFAULT '0',
  `id_asignatura` int(11) NOT NULL DEFAULT '0',
  `estatus` char(1) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asignaturas_niveles`
--

CREATE TABLE `asignaturas_niveles` (
  `id` int(11) NOT NULL,
  `id_asignatura` int(11) NOT NULL,
  `id_nivel` int(11) NOT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `asignaturas_niveles`
--

INSERT INTO `asignaturas_niveles` (`id`, `id_asignatura`, `id_nivel`, `fecha_modificacion`) VALUES
(2, 7, 1, '2020-05-22 03:17:01'),
(3, 7, 2, '2020-05-22 03:17:01'),
(4, 2, 1, '2020-05-22 03:36:08'),
(5, 2, 2, '2020-05-22 03:36:08'),
(7, 8, 2, '2020-05-25 01:16:41'),
(8, 8, 1, '2020-05-25 01:16:41');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bitacora`
--

CREATE TABLE `bitacora` (
  `clave` bigint(20) NOT NULL,
  `tabla` varchar(35) COLLATE latin1_spanish_ci NOT NULL,
  `accion` varchar(35) COLLATE latin1_spanish_ci NOT NULL,
  `detalle` varchar(600) COLLATE latin1_spanish_ci NOT NULL,
  `comentarios` varchar(150) COLLATE latin1_spanish_ci DEFAULT NULL,
  `usuario` varchar(50) COLLATE latin1_spanish_ci DEFAULT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carreras`
--

CREATE TABLE `carreras` (
  `idcarrera` int(5) NOT NULL,
  `carrera` varchar(50) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `carreras`
--

INSERT INTO `carreras` (`idcarrera`, `carrera`) VALUES
(1, 'Licenciatura en Sistemas');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `claves_tablas`
--

CREATE TABLE `claves_tablas` (
  `tabla` varchar(30) CHARACTER SET utf8 NOT NULL,
  `clave` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `claves_tablas`
--

INSERT INTO `claves_tablas` (`tabla`, `clave`) VALUES
('bitacora', 18);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `docentes`
--

CREATE TABLE `docentes` (
  `id_docente` smallint(11) NOT NULL,
  `curp` varchar(18) NOT NULL,
  `nombre` varchar(60) NOT NULL DEFAULT '',
  `apellido_paterno` varchar(95) NOT NULL,
  `apellido_materno` varchar(95) NOT NULL,
  `observaciones` varchar(50) NOT NULL DEFAULT '',
  `fecha_alta` datetime NOT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `docentes`
--

INSERT INTO `docentes` (`id_docente`, `curp`, `nombre`, `apellido_paterno`, `apellido_materno`, `observaciones`, `fecha_alta`, `fecha_modificacion`) VALUES
(1, '', 'Andrés', 'Velasco', 'Gordillo', '', '2020-05-02 14:57:42', '2020-05-17 19:50:04'),
(2, '', 'Ana', 'Torres', '', '', '2020-05-02 18:40:16', '2020-05-17 19:50:02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `escuelas`
--

CREATE TABLE `escuelas` (
  `id_escuela` int(11) NOT NULL,
  `clave` varchar(35) COLLATE utf8_unicode_ci NOT NULL,
  `nombre` varchar(135) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `escuelas`
--

INSERT INTO `escuelas` (`id_escuela`, `clave`, `nombre`) VALUES
(1, 'CEIMB', 'Instituto Educativo Montebello');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `examenes`
--

CREATE TABLE `examenes` (
  `id_examen` int(11) NOT NULL,
  `clave` varchar(15) NOT NULL,
  `descripcion` varchar(135) NOT NULL,
  `fecha_alta` timestamp NULL DEFAULT NULL,
  `fecha_vencimiento` timestamp NULL DEFAULT NULL,
  `id_nivel` int(11) NOT NULL DEFAULT '0',
  `id_grado` int(11) DEFAULT '1',
  `id_asignatura` int(11) NOT NULL DEFAULT '0',
  `unidad` int(11) DEFAULT NULL,
  `id_docente` int(11) NOT NULL,
  `total_preguntas` int(11) NOT NULL,
  `secciones` int(11) NOT NULL,
  `tiempo_limite` int(11) DEFAULT NULL,
  `mostrar_resultados` char(1) NOT NULL DEFAULT 'N',
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `examenes`
--

INSERT INTO `examenes` (`id_examen`, `clave`, `descripcion`, `fecha_alta`, `fecha_vencimiento`, `id_nivel`, `id_grado`, `id_asignatura`, `unidad`, `id_docente`, `total_preguntas`, `secciones`, `tiempo_limite`, `mostrar_resultados`, `fecha_modificacion`) VALUES
(3, 'DIAG001', 'Diagnóstico general', '2020-04-14 05:00:00', '2020-05-28 19:32:00', 1, NULL, 1, 1, 2, 3, 4, 60, 'N', '2020-05-24 17:04:10'),
(4, 'UND002', 'Admisión', '2020-04-30 05:00:00', '2020-05-28 21:19:00', 1, NULL, 1, 1, 3, 4, 0, 50, 'N', '2020-05-24 17:03:46'),
(5, 'UND003', 'Examen de unidad', '2020-04-23 05:00:00', '2020-05-31 21:19:00', 1, NULL, 1, 3, 1, 2, 0, 25, 'N', '2020-05-24 17:04:24'),
(8, 'DG01CL', 'Diagnóstico General', '2020-05-18 22:25:35', '2020-06-01 03:23:00', 1, NULL, 2, 1, 2, 8, 0, 50, 'S', '2020-05-24 16:48:04'),
(9, 'PBBL012105', 'Célula (teoría celular) y Bioelementos', '2020-05-21 16:39:23', NULL, 2, NULL, 7, NULL, 2, 5, 0, 50, 'S', '2020-05-24 23:24:08'),
(10, 'QMPUSM01', 'Simulador de química', '2020-05-25 02:42:10', NULL, 2, NULL, 8, NULL, 1, 3, 0, 120, 'S', '2020-05-25 02:45:14');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `examenes_alumnos`
--

CREATE TABLE `examenes_alumnos` (
  `id` int(11) NOT NULL,
  `id_examen` int(11) NOT NULL DEFAULT '0',
  `id_alumno` int(11) NOT NULL DEFAULT '0',
  `fecha_hora_inicio` datetime NOT NULL,
  `fecha_hora_fin` datetime DEFAULT NULL,
  `id_sesion` varchar(20) NOT NULL DEFAULT '',
  `aciertos` int(11) NOT NULL DEFAULT '0',
  `contestadas` int(11) NOT NULL DEFAULT '0',
  `tiempo_total` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `examenes_alumnos`
--

INSERT INTO `examenes_alumnos` (`id`, `id_examen`, `id_alumno`, `fecha_hora_inicio`, `fecha_hora_fin`, `id_sesion`, `aciertos`, `contestadas`, `tiempo_total`) VALUES
(1, 9, 1, '2020-05-24 18:00:02', '2020-05-24 18:24:40', '', 2, 3, '00:24:38'),
(4, 3, 1, '2020-05-24 17:58:48', NULL, 'kla7fmfjuh5i989lk8t6', 0, 2, '00:00:00'),
(5, 10, 1, '2020-05-24 21:45:31', '2020-05-24 21:46:17', 'bfnrhsdu8u6b0gvql11r', 2, 3, '00:00:46');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `examenes_preguntas`
--

CREATE TABLE `examenes_preguntas` (
  `id` int(11) NOT NULL,
  `id_examen` int(11) NOT NULL,
  `id_pregunta` int(11) NOT NULL,
  `id_seccion` int(11) NOT NULL,
  `numero` smallint(6) NOT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `examenes_preguntas`
--

INSERT INTO `examenes_preguntas` (`id`, `id_examen`, `id_pregunta`, `id_seccion`, `numero`, `fecha_modificacion`) VALUES
(102, 3, 1, 0, 3, '2020-05-17 19:06:50'),
(103, 3, 2, 0, 1, '2020-05-17 19:06:50'),
(104, 3, 3, 0, 2, '2020-05-17 19:06:50'),
(105, 3, 4, 0, 4, '2020-05-17 19:06:50'),
(106, 3, 5, 0, 5, '2020-05-17 19:06:50'),
(107, 3, 6, 0, 6, '2020-05-17 19:06:50'),
(108, 3, 7, 0, 7, '2020-05-17 19:06:50'),
(109, 3, 8, 0, 8, '2020-05-17 19:06:50'),
(110, 3, 9, 0, 9, '2020-05-17 19:06:50'),
(111, 3, 10, 0, 10, '2020-05-17 19:06:50'),
(112, 3, 16, 0, 11, '2020-05-17 19:06:50'),
(113, 3, 17, 0, 13, '2020-05-17 19:06:50'),
(114, 3, 18, 0, 12, '2020-05-17 19:06:50'),
(115, 3, 19, 0, 14, '2020-05-17 19:06:50'),
(116, 3, 20, 0, 15, '2020-05-17 19:06:50'),
(117, 3, 21, 0, 16, '2020-05-17 19:06:50'),
(118, 3, 22, 0, 17, '2020-05-17 19:06:50'),
(119, 3, 23, 0, 18, '2020-05-17 19:06:50'),
(120, 3, 24, 0, 19, '2020-05-17 19:06:50'),
(121, 3, 25, 0, 20, '2020-05-17 19:06:50'),
(122, 3, 26, 0, 21, '2020-05-17 19:06:50'),
(123, 3, 27, 0, 22, '2020-05-17 19:06:50'),
(124, 3, 28, 0, 23, '2020-05-17 19:06:50'),
(125, 3, 29, 0, 24, '2020-05-17 19:06:50'),
(126, 3, 30, 0, 25, '2020-05-17 19:06:50'),
(133, 4, 31, 0, 1, '2020-05-17 20:30:31'),
(134, 4, 32, 0, 2, '2020-05-17 20:30:31'),
(135, 4, 33, 0, 3, '2020-05-17 20:30:31'),
(136, 4, 34, 0, 4, '2020-05-17 20:30:31'),
(137, 4, 36, 0, 5, '2020-05-17 20:30:31'),
(138, 4, 37, 0, 6, '2020-05-17 20:30:31'),
(139, 4, 38, 0, 7, '2020-05-17 20:30:31'),
(140, 8, 31, 0, 1, '2020-05-21 01:42:16'),
(141, 8, 32, 0, 2, '2020-05-21 01:44:12'),
(142, 8, 33, 0, 3, '2020-05-21 01:52:32'),
(143, 8, 34, 0, 4, '2020-05-21 02:51:01'),
(144, 8, 36, 0, 5, '2020-05-21 02:51:25'),
(145, 8, 37, 0, 6, '2020-05-21 02:56:41'),
(146, 8, 38, 0, 7, '2020-05-21 02:58:21'),
(147, 8, 39, 0, 8, '2020-05-21 15:19:10'),
(148, 9, 42, 0, 1, '2020-05-21 16:41:46'),
(149, 9, 43, 0, 2, '2020-05-21 16:43:49'),
(150, 9, 44, 0, 3, '2020-05-21 16:45:04'),
(151, 9, 45, 0, 4, '2020-05-21 18:18:24'),
(152, 9, 46, 0, 5, '2020-05-24 23:24:08'),
(153, 10, 52, 0, 1, '2020-05-25 02:44:51'),
(154, 10, 53, 0, 2, '2020-05-25 02:45:02'),
(155, 10, 54, 0, 3, '2020-05-25 02:45:14');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `examenes_respuestas`
--

CREATE TABLE `examenes_respuestas` (
  `id` int(11) NOT NULL,
  `id_examen_alumno` int(11) NOT NULL DEFAULT '0',
  `id_pregunta` int(11) NOT NULL,
  `respuesta` int(11) NOT NULL,
  `fecha_hora` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `examenes_respuestas`
--

INSERT INTO `examenes_respuestas` (`id`, `id_examen_alumno`, `id_pregunta`, `respuesta`, `fecha_hora`) VALUES
(1, 1, 42, 3, '2020-05-24 02:24:35'),
(10, 1, 43, 4, '2020-05-24 23:15:54'),
(13, 1, 44, 1, '2020-05-24 23:24:22'),
(16, 4, 2, 2, '2020-05-24 23:37:41'),
(17, 4, 3, 3, '2020-05-24 23:38:33'),
(18, 5, 52, 3, '2020-05-25 02:45:56'),
(19, 5, 53, 2, '2020-05-25 02:46:09'),
(20, 5, 54, 2, '2020-05-25 02:46:17');

--
-- Disparadores `examenes_respuestas`
--
DELIMITER $$
CREATE TRIGGER `CONTESTADAS_1` AFTER INSERT ON `examenes_respuestas` FOR EACH ROW UPDATE examenes_alumnos SET contestadas = 
(SELECT COUNT(examenes_respuestas.id_pregunta) FROM examenes_respuestas
 WHERE examenes_alumnos.id = examenes_respuestas.id_examen_alumno)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `CONTESTADAS_2` AFTER DELETE ON `examenes_respuestas` FOR EACH ROW UPDATE examenes_alumnos SET contestadas = 
(SELECT COUNT(examenes_respuestas.id_pregunta) FROM examenes_respuestas
 WHERE examenes_alumnos.id = examenes_respuestas.id_examen_alumno)
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `examenes_secciones`
--

CREATE TABLE `examenes_secciones` (
  `id` int(11) NOT NULL,
  `id_examen` int(11) NOT NULL,
  `nombre` varchar(35) COLLATE utf8_unicode_ci NOT NULL,
  `fecha_alta` datetime NOT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grados`
--

CREATE TABLE `grados` (
  `id_grado` int(11) NOT NULL,
  `id_nivel` int(11) NOT NULL,
  `nombre` char(35) NOT NULL DEFAULT '',
  `clave` varchar(35) NOT NULL,
  `fecha_alta` datetime NOT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `grados`
--

INSERT INTO `grados` (`id_grado`, `id_nivel`, `nombre`, `clave`, `fecha_alta`, `fecha_modificacion`) VALUES
(1, 1, 'General', 'PBG01', '2020-05-14 12:58:18', '2020-05-18 23:10:29'),
(2, 2, 'General', 'PUG01', '2020-05-15 07:59:56', '2020-05-18 23:10:48');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupos`
--

CREATE TABLE `grupos` (
  `id_grupo` int(11) NOT NULL,
  `id_grado` int(11) NOT NULL,
  `id_nivel` int(11) NOT NULL,
  `nombre` varchar(40) DEFAULT NULL,
  `clave` varchar(35) NOT NULL,
  `fecha_alta` datetime NOT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `grupos`
--

INSERT INTO `grupos` (`id_grupo`, `id_grado`, `id_nivel`, `nombre`, `clave`, `fecha_alta`, `fecha_modificacion`) VALUES
(1, 1, 1, 'Único PU', 'PB1B', '0000-00-00 00:00:00', '2020-05-25 19:18:25'),
(2, 2, 1, 'Único PB', 'GR001', '2020-05-15 11:09:51', '2020-05-25 19:18:32');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `niveles`
--

CREATE TABLE `niveles` (
  `id_nivel` int(11) NOT NULL,
  `clave` varchar(35) NOT NULL,
  `nombre` varchar(40) DEFAULT NULL,
  `fecha_alta` datetime NOT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `niveles`
--

INSERT INTO `niveles` (`id_nivel`, `clave`, `nombre`, `fecha_alta`, `fecha_modificacion`) VALUES
(1, 'PB005', 'Prebachillerato', '0000-00-00 00:00:00', '2020-05-02 19:02:59'),
(2, 'PU006', 'Preuniversitario', '0000-00-00 00:00:00', '2020-05-02 19:03:29');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `preguntas`
--

CREATE TABLE `preguntas` (
  `id_pregunta` int(11) NOT NULL,
  `id_asignatura` int(11) NOT NULL,
  `unidad` int(11) DEFAULT '1',
  `numero` int(11) NOT NULL,
  `pregunta` longtext CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `opcion1` varchar(255) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `opcion2` varchar(255) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `opcion3` varchar(255) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `opcion4` varchar(255) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `respuesta` tinyint(4) DEFAULT NULL,
  `valor_reactivo` float NOT NULL,
  `fecha_alta` datetime NOT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `preguntas`
--

INSERT INTO `preguntas` (`id_pregunta`, `id_asignatura`, `unidad`, `numero`, `pregunta`, `opcion1`, `opcion2`, `opcion3`, `opcion4`, `respuesta`, `valor_reactivo`, `fecha_alta`, `fecha_modificacion`) VALUES
(1, 1, 1, 3, 'El costo de colocar losetas en una casa se calcula con el cuadrado de la suma de <img src=\"imagenes/10000/1037_10023_0_1.jpg\"> del área del piso y 5 veces el número de trabajadores. Si se contratan 6 personas para poner losetas a 75 m<sup>2</sup>, ¿cuánto se debe pagar?', '$2,530', '$4,900', '$6,400', '$7,350', 4, 1, '0000-00-00 00:00:00', '2020-05-20 20:16:57'),
(2, 1, 1, 1, '<p>¿Cuál es el resultado de la operación?</p><p style=\'text-align: center;\'>5(6 - 2) - (4 - 2)</p>', '14', '18', '22', '26', 2, 1, '0000-00-00 00:00:00', '2020-05-20 20:16:05'),
(3, 1, 1, 2, '<p>La cantidad de litros de agua que cae durante una lluvia torrencial se calcula multiplicando los minutos transcurridos por <img src=\"imagenes/10000/1037_10022_0_1.jpg\"> del cuadrado del &#x00e1;rea de inter&#x00e9;s. Si llueve durante 1 hora en un patio de 4 m<sup>2</sup>, &#x00bf;cu&#x00e1;ntos litros caen?</p>', '60', '240', '3,600', '3,840', 2, 1, '0000-00-00 00:00:00', '2020-05-20 20:16:49'),
(4, 1, 1, 4, '<p>Un padre tiene 64 años, la edad de su hijo está basada en una razón de <img src=\"imagenes/10900/1037_10972_0_2.jpg\"> con relación a su edad. ¿Qué edad tenía cuando nació su hijo?</p>', '24', '32', '40', '48', 1, 0, '0000-00-00 00:00:00', '2020-04-26 19:04:28'),
(5, 1, 1, 5, '<p>&iquest;Cu&aacute;l es el n&uacute;mero primo com&uacute;n y menor en la descomposici&oacute;n de 9, 15 y 24?</p>', '<p>2</p>', '<p>3</p>', '<p>5</p>', '<p>9</p>', 2, 0, '0000-00-00 00:00:00', '2020-05-06 01:39:32'),
(6, 1, 1, 6, '<p>&iquest;Cu&aacute;l es el resultado de la expresi&oacute;n?<br /><br /></p><p style=\'text-align: center;\'><img src=\"imagenes/10000/1037_10026_0_4.jpg\"></p>', '<p>y<sup>2</sup></p>', '<p>y<sup>3</sup></p>', '<p>y<sup>4</sup></p>', '<p>y<sup>5</sup></p>', 3, 0, '0000-00-00 00:00:00', '2020-05-06 12:40:01'),
(7, 1, 1, 7, '<p>&iquest;Cu&aacute;l es el punto de intersecci&oacute;n de la funci&oacute;n con el eje <strong>x</strong>?</p><p style=\'text-align: center;\'>x<sup>2</sup> - x - 6 = 0</p>', '<p>3, -2</p>', '<p>-3, 2</p>', '<p>-3, -2</p>', '<p>3, 2</p>', 1, 0, '0000-00-00 00:00:00', '2020-05-06 12:41:15'),
(8, 1, 1, 8, '<p>&iquest;Cu&aacute;l gr&aacute;fica representa una funci&oacute;n?</p>', '<p><img src=\"imagenes/10000/1037_10030_1_2.jpg\"></p>', '<p><img src=\"imagenes/10000/1037_10030_2_2.jpg\"></p>', '<p><img src=\"imagenes/10000/1037_10030_3_2.jpg\"></p>', '<p><img src=\"imagenes/10000/1037_10030_4_2.jpg\"></p>', 3, 0, '0000-00-00 00:00:00', '2020-05-12 16:15:43'),
(9, 1, 1, 9, '¿Cuál es el resultado de la suma?<br /><br /></p><p style=\"text-align: center;\"><img src=\"imagenes/11000/1037_11037_0_1.jpg\">', '<p><img src=\"imagenes/11000/1037_11037_1_1.jpg\"></p>', '<p><img src=\"imagenes/11000/1037_11037_2_1.jpg\"></p>', '<p><img src=\"imagenes/11000/1037_11037_3_1.jpg\"></p>', '<p><img src=\"imagenes/11000/1037_11037_4_1.jpg\"></p>', 1, 0, '0000-00-00 00:00:00', '2020-05-07 00:52:22'),
(10, 1, 1, 10, '<p>¿Cuál es la distancia focal de una elipse cuya longitud del eje mayor es 26 cm y la del eje menor es 24 cm?</p>', '<p>2</p>', '<p>5</p>', '<p>10</p>', '<p>25</p>', 3, 0, '0000-00-00 00:00:00', '2020-05-07 01:29:28'),
(16, 1, 1, 11, 'Si la mediana de los datos es 20, entonces el _______ es 20.<br /><br /></p><p style=\'text-align: center;\'>6, 15, 20, 40, 0, 29, 12, 25, 56, 10, 25, 35, 5, 16, 50</p>', '<p>primer decil</p>', '<p>primer cuartil</p>', '<p>segundo decil</p>', '<p>segundo cuartil</p>', 4, 1, '0000-00-00 00:00:00', '2020-05-20 20:18:17'),
(17, 1, 1, 12, '<p>En un grupo de aspirantes a un empleo, 40% son casados. &iquest;Cu&aacute;ntos grados mide el sector que los representa en un diagrama circular?</p>', '<p>40</p>', '<p>72</p>', '<p>140</p>', '<p>144</p>', 4, 0, '0000-00-00 00:00:00', '2020-05-20 20:18:21'),
(18, 1, 1, 13, '<p>La suma de las probabilidades de 2 sucesos únicamente posibles y mutuamente excluyentes, <strong>A1</strong> y <strong>A2</strong>, que se denotan como P(A1) y P(A2), cumple la relación P(A1) + P(A2)...</p>', '<p>= 0</p>', '<p>= 1</p>', '<p>> 1</p>', '<p>< 1</p>', 2, 0, '0000-00-00 00:00:00', '2020-05-20 20:18:26'),
(19, 1, 1, 14, '<p>Se lanza un dado 80 veces y se registra la frecuencia en la que aparece cada cara. ¿Cuál gráfica representa la distribución de frecuencias?<br /><br /></p><table border=\"1\" cellpadding=\"0\" align=\"center\"><tbody><tr><td width=\"44\"><p style=\"text-align: center;\"><strong>Cara</strong></p></td><td width=\"112\"><p align=\"center\"><strong>Frecuencia</strong></p></td></tr><tr><td width=\"44\"><p align=\"center\">1</p></td><td width=\"112\"><p align=\"center\">8</p></td></tr><tr><td width=\"44\"><p align=\"center\">2</p></td><td width=\"112\"><p align=\"center\">12</p></td></tr><tr><td width=\"44\"><p align=\"center\">3</p></td><td width=\"112\"><p align=\"center\">15</p></td></tr><tr><td width=\"44\"><p align=\"center\">4</p></td><td width=\"112\"><p align=\"center\">17</p></td></tr><tr><td width=\"44\"><p align=\"center\">5</p></td><td width=\"112\"><p align=\"center\">16</p></td></tr><tr><td width=\"44\"><p align=\"center\">6</p></td><td width=\"112\"><p align=\"center\">12</p></td></tr></tbody></table></p>', '<p><img src=\"imagenes/10900/1037_10974_1_2.jpg\"></p>', '<p><img src=\"imagenes/10900/1037_10974_2_2.jpg\"></p>', '<p><img src=\"imagenes/10900/1037_10974_3_2.jpg\"></p>', '<p><img src=\"imagenes/10900/1037_10974_4_2.jpg\"></p>', 3, 0, '0000-00-00 00:00:00', '2020-05-20 20:18:30'),
(20, 1, 1, 15, '<p>Las calificaciones finales que obtuvieron los alumnos en un curso fueron: 90, 100, 90, 80, 70. &iquest;Cu&aacute;l es la moda de los datos?</p>', '<p>70</p>', '<p>86</p>', '<p>90</p>', '<p>100</p>', 3, 0, '0000-00-00 00:00:00', '2020-05-20 20:18:35'),
(21, 1, 1, 16, '¿Cuál es la distancia entre los puntos (4, -2) y (6, 2)?</p>', '<p><img src=\"imagenes/10900/1037_10975_1_1.jpg\"></p>', '<p><img src=\"imagenes/10900/1037_10975_2_1.jpg\"></p>', '<p><img src=\"imagenes/10900/1037_10975_3_1.jpg\"></p>', '<p><img src=\"imagenes/10900/1037_10975_4_1.jpg\"></p>', 1, 1, '0000-00-00 00:00:00', '2020-05-20 20:18:39'),
(22, 1, 1, 17, '<p>Relacione el signo de la pendiente de la recta Ax + By + C = 0 con su valor.<p><table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" align=\"center\"><tbody><tr><th style=\"width: 111px;\" scope=\"col\" align=\"center\" valign=\"top\" nowrap=\"nowrap\"><p align=\"center\">Signo</p></th><th style=\"width: 132px;\" scope=\"col\" align=\"center\" valign=\"top\" nowrap=\"nowrap\"><p align=\"center\">Valor</p></th></tr><tr><td valign=\"top\" width=\"111\"><p>1. Positivo<br />2. Negativo</p></td><td valign=\"top\" width=\"132\"><p>a) A &lt; 0 y B &lt; 0<br />b) A &gt; 0 y B &gt; 0<br />c) A &lt; 0 y B &gt; 0<br />d) A &gt; 0 y B &lt; 0</p></td></tr></tbody></table>', '<p>1ab, 2cd</p>', '<p>1ac, 2bd</p>', '<p>1bd, 2ac</p>', '<p>1cd, 2ab</p>', 4, 0, '0000-00-00 00:00:00', '2020-05-20 20:18:43'),
(23, 1, 1, 18, '¿Cuáles son las coordenadas del punto C que se localiza sobre el eje <strong>x</strong> y que es equidistante del punto<strong> </strong>A(-2, 5) y del punto<strong> </strong>B(4, 1)?</p>', '<p>(1, 0)</p>', '<p>(-1, 0)</p>', '<p>(3, 0)</p>', '<p>(-3, 0)</p>', 2, 1, '0000-00-00 00:00:00', '2020-05-20 20:18:47'),
(24, 1, 1, 19, '<p>Si la distancia entre el punto (3, y) y el punto (-1, 5) son 5 unidades, &iquest;cu&aacute;les son los posibles valores de <strong>y</strong>?</p>', '<p><img src=\"imagenes/10200/1037_10284_1_2.jpg\"></p>', '<p><img src=\"imagenes/10200/1037_10284_2_5.jpg\"></p>', '<p><img src=\"imagenes/10200/1037_10284_3_1.jpg\"></p>', '<p><img src=\"imagenes/10200/1037_10284_4_2.jpg\"></p>', 3, 1, '0000-00-00 00:00:00', '2020-05-20 20:18:52'),
(25, 1, 1, 20, '<p>De acuerdo con la gráfica, ¿cuál es la ecuación de la recta en su forma pendiente-ordenada en el origen?<br /><br /></p><p style=\'text-align: center;\'><img src=\"imagenes/10200/1037_10289_0_2.jpg\"></p>', '<p>y = 3/2x - 2</p>', '<p>y = 2/3x + 2</p>', '<p>y = 3/2x + 2</p>', '<p>y = 2/3x - 2</p>', 3, 1, '0000-00-00 00:00:00', '2020-05-20 20:18:56'),
(26, 1, 1, 21, '<p>Si <strong>a</strong>, <strong>b</strong> y <strong>c</strong> denotan los lados de un tri&aacute;ngulo cualquiera y <strong>&alpha;</strong> es el &aacute;ngulo que subtienden los lados <strong>b</strong> y <strong>c</strong>, &iquest;cu&aacute;l ecuaci&oacute;n representa la ley de cosenos?</p>', '<p>a<sup>2</sup> = b<sup>2</sup> + c<sup>2</sup> - 2bc cos(&alpha;)</p>', '<p>a<sup>2</sup> = b<sup>2</sup> - c<sup>2</sup> - 2bc cos(&alpha;)</p>', '<p>a<sup>2</sup> = -b<sup>2</sup> - c<sup>2</sup> - 2bc cos(&alpha;)</p>', '<p>a<sup>2</sup> = b<sup>2</sup> + c<sup>2</sup> + 2bc cos(&alpha;)</p>', 1, 1, '0000-00-00 00:00:00', '2020-05-20 20:19:01'),
(27, 1, 1, 22, '<p>&iquest;Cu&aacute;l es el periodo de la funci&oacute;n seno?</p>', '<p><img src=\"imagenes/10000/1037_10020_1_4.jpg\"></p>', '<p><img src=\"imagenes/10000/1037_10020_2_4.jpg\"></p>', '<p><img src=\"imagenes/10000/1037_10020_3_4.jpg\"></p>', '<p><img src=\"imagenes/10000/1037_10020_4_5.jpg\"></p>', 4, 1, '0000-00-00 00:00:00', '2020-05-20 20:19:04'),
(28, 1, 1, 23, 'Con base en la figura, ¿cuántos metros mide el lado <strong>x</strong>?<br /><br /></p><table border=\'2\' cellspacing=\'0\' align=\'center\'><tbody><tr><td style=\'text-align: center;\'><strong>Ángulo</strong></td><td style=\'text-align: center;\'><strong>Sen</strong></td><td style=\'text-align: center;\'><strong>Cos</strong></td><td style=\'text-align: center;\'><strong>Tan</strong></td></tr><tr><td style=\'text-align: center;\'>110°</td><td style=\'text-align: center;\'>0.9397</td><td style=\'text-align: center;\'>-0.3420</td><td style=\'text-align: center;\'>-27475</td></tr></tbody></table><p style=\'text-align: center;\'><img src=\"imagenes/10200/1037_10293_0_2.jpg\"></p>', '<p>9.56</p>', 'option\": \"<p>14.10</p>', '<p>17.35</p>', '<p>301.20</p>', 3, 0, '0000-00-00 00:00:00', '2020-05-20 20:19:08'),
(29, 1, 1, 24, '<p>Si <strong>?</strong> se encuentra en el segundo cuadrante y la tangente es ? = <img src=\"imagenes/10900/1037_10976_0_1.jpg\">, ¿cuál es el valor de coseno <strong>?</strong>?</p>', '<p><img src=\"imagenes/10900/1037_10976_1_1.jpg\"></p>', '<p><img src=\"imagenes/10900/1037_10976_2_1.jpg\"></p>', '<p><img src=\"imagenes/10900/1037_10976_3_1.jpg\"></p>', '<p><img src=\"imagenes/10900/1037_10976_4_1.jpg\"></p>', 1, 0, '2020-05-12 12:41:09', '2020-05-20 20:19:11'),
(30, 1, 1, 25, '<p>Si se sabe que<strong> ?</strong> es un ángulo del segundo cuadrante y su función tan es ? = <img src=\"imagenes/10300/1037_10300_0_1.jpg\">, ¿cuál es la función coseno para el mismo ángulo?</p>', '<p><img src=\"imagenes/10300/1037_10300_1_1.jpg\"></p>', '<p><img src=\"imagenes/10300/1037_10300_2_1.jpg\"></p>', '<p><img src=\"imagenes/10300/1037_10300_3_1.jpg\"></p>', '<p><img src=\"imagenes/10300/1037_10300_4_1.jpg\"></p>', 4, 0, '2020-05-12 13:35:06', '2020-05-20 20:19:15'),
(31, 2, 1, 1, '<p>¿Cuál es el significado de la frase en negritas?<br /><br /></p><p>Un lector crítico <strong>no se cree a pie juntillas</strong> todo lo que dicen los libros.</p>', '<p>Un lector iniciado no es ingenuo y es capaz de crear su propio criterio</p>', '<p>Los buenos lectores se creen todo lo que leen y no tienen criterio</p>', '<p>Los lectores deben acostumbrarse a reproducir la información literalmente</p>', '<p>Los lectores activos, en la mayoría de los casos, no son críticos</p>', 1, 0, '2020-05-12 13:42:32', '2020-05-21 01:49:51'),
(32, 2, 1, 2, '<p>¿Cuál parte del texto muestra la conclusión?</p><p style=\'text-align: center;\'><strong>Energía para el cerebro</strong><br /><br /></p></p><p>[<strong>1</strong>] Otra mutación que favoreció la demanda de energía del cerebro ocurrió en los genes que codifican las proteínas transportadoras de glucosa que se encuentran en las paredes de los vasos sanguíneos, [<strong>2</strong>] ya que la glucosa es su fuente básica de energía. [<strong>3</strong>] La comparación de los genomas del chimpancé y el humano muestran que en el último hay un mayor número de los genes (SLC2A1) que codifican los transportadores de glucosa hacia el cerebro y un número menor de los que la transportan al músculo (SCLA4). Al parecer, [<strong>4</strong>] perder eficiencia en la fuerza muscular fue el costo que tuvimos que pagar para desarrollar un cerebro más grande.</p><p style=\'text-align: right;\'><sub>Gertrudis Uruchurtu. <em>Genética de lo humano</em></sub></p>', '<p>1</p>', '<p>2</p>', '<p>3</p>', '<p>4</p>', 4, 1, '2020-05-12 13:43:45', '2020-05-20 20:25:50'),
(33, 2, 1, 3, '<p>Otra versi&oacute;n de la Odisea cuenta que la tripulaci&oacute;n se perdi&oacute; _______ Ulises hab&iacute;a ordenado a sus compa&ntilde;eros que se taparan los o&iacute;dos para no o&iacute;r el p&eacute;rfido _______ dulce canto de las sirenas, _______ olvid&oacute; indicarles que cerraran los ojos, y como adem&aacute;s las sirenas, de formas generosas, sab&iacute;an danzar...</p><p style=\'text-align: right;\'><sub>Jos&eacute; de la Colina. <em>Las sirenas</em></sub></p>', '<p>porque - mas - pero</p>', '<p>aunque - y - tambi&eacute;n</p>', '<p>cuando - si bien - pues</p>', '<p>primero - y - luego</p>', 1, 0, '2020-05-12 13:55:58', '2020-05-20 20:25:53'),
(34, 2, 1, 4, '<p>De acuerdo con el texto, quien cambió de rumbo fue el...<br /><br /></p><p>Dos acorazados en entrenamiento habían estado de maniobras en el mar con la tempestad durante varios días. La visibilidad era pobre debido a la niebla.<br />Poco después de que oscureciera, el vigía informó: Luz a estribor.<br />—¿Rumbo directo o se dirige hacia popa? –gritó el capitán.<br />—Directo, capitán –lo que significaba una colisión segura con aquel buque.<br />El capitán llamó al encargado de emitir las señales para que enviara el siguiente mensaje: \"Estamos a punto de chocar; aconsejamos cambiar 20 grados su rumbo\".<br />Llegó otra señal de respuesta: Aconsejamos que ustedes cambien de rumbo.<br />El capitán dijo: \"Contéstele; soy capitán, cambie su rumbo 20 grados\".<br />Respondieron: \"Soy marinero de segunda clase, cambie usted su rumbo\".<br />El capitán ya estaba hecho una furia. Espetó: \"Conteste; soy un acorazado. Cambie su rumbo 20 grados\".<br />El último mensaje recibido fue: \"Yo soy un faro\". <br />Cambiamos nuestro rumbo.</p><p align=\'right\'><sub>Stephen R. Covey. <em>Los 7 hábitos de la gente altamente efectiva</em></p>', '<p>vigía</p>', '<p>capitán</p>', '<p>marinero</p>', '<p>mensajero</p>', 2, 0, '2020-05-12 13:58:03', '2020-05-20 20:25:57'),
(36, 2, 1, 5, '<p>¿Cuál opción corresponde al sentido del refrán?<br /><br />Están más cerca mis dientes que mis parientes.</p>', '<p>Se recibe más apoyo de los conocidos que de los familiares</p>', '<p>Los parientes siempre están dispuestos a apoyarnos</p>', '<p>La familia siempre debe permanecer unida y en armonía</p>', '<p>Los parientes son numerosos y cercanos como los dientes</p>', 1, 0, '2020-05-12 14:05:56', '2020-05-21 02:56:10'),
(37, 2, 1, 6, '<p>¿Cuál es el propósito del texto? <br /><br />¿Por qué es tan importante la participación de los padres en la educación de los niños? Porque los padres son los primeros agentes del aprendizaje. Es en el hogar donde se genera la educación y donde el niño comienza a conocer sus primeras palabras y a relacionarse con otras personas; en un medio de aceptación y confianza, con características más personales y afectivas que la escuela, por los vínculos que existen entre padre e hijo.<br /><p>Esta relación afectiva, cercana y de confianza no existe en la escuela, no es su finalidad. La escuela abre el mundo del niño hacia otros espacios más amplios, pero también más impersonales, que requieren del apoyo de los padres para que el niño transite hacia la sociedad confiando en sus propios recursos.<br /><p>Es por eso que los padres deben considerar el aprendizaje como una modificación en la capacidad o en la conducta de un individuo que puede mantenerse en el tiempo y generar un nuevo repertorio de respuestas ante las exigencias externas o internas. Una tarea que escapa de la educación formal, de lo netamente intelectual.</p><p style=\'text-align: right;\'><sub>Claudia Mendoza. <em>Los padres vitales para la educación de sus hijos</sub></em></p>', '<p>Informar</p', '<p>Argumentar</p>', '<p>Exponer</p>', '<p>Narrar</p>', 2, 0, '2020-05-12 14:36:10', '2020-05-20 20:26:09'),
(38, 2, 1, 7, '<p>¿Cuál es el propósito del texto?</p><p style=\'text-align: center;\'><strong>El corazón delator</strong><br /><br /></p>¡Es cierto! Siempre he sido nervioso, muy nervioso, terriblemente nervioso. ¿Pero por qué afirman ustedes que estoy loco? La enfermedad había agudizado mis sentidos, en vez de destruirlos o embotarlos. Y mi oído era el más agudo de todos. Oía todo lo que puede oírse en la tierra y en el cielo. Muchas cosas oí en el infierno. ¿Cómo puedo estar loco, entonces? Escuchen... y observen con cuánta cordura, con cuánta tranquilidad les cuento mi historia. Me es imposible decir cómo aquella idea me entró en la cabeza por primera vez; pero, una vez concebida, me acosó noche y día. Yo no perseguía ningún propósito. Ni tampoco estaba colérico. Quería mucho al viejo. Jamás me había hecho nada malo. Jamás me insultó. Su dinero no me interesaba. Me parece que fue su ojo. ¡Sí, eso fue! Tenía un ojo semejante al de un buitre... Un ojo celeste, y velado por una tela. Cada vez que lo clavaba en mí se me helaba la sangre. Y así, poco a poco, muy gradualmente, me fui decidiendo a matar al viejo y librarme de aquel ojo para siempre.</p><p style=\'text-align: right;\'><sup>Edgar Allan Poe</sup></p>', '<p>Narrar</p>', '<p>Argumentar</p>', '<p>Exponer</p>', '<p>Describir</p>', 1, 0, '2020-05-16 12:48:17', '2020-05-20 21:22:57'),
(39, 2, 1, 8, '<p>En una sesión de creatividad en equipo no hay ideas buenas o malas. Cualquier _______, por extraña que parezca, puede ser interesante.</p><p align=\'right\'><sub>Franc Ponti. <em>La empresa creativa</em></sub></p>', '<p>inhibición</p>', '<p>intromisión</p>', '<p>abstención</p>', '<p>intervención</p>', 4, 1, '2020-05-21 10:18:10', '2020-05-21 15:18:43'),
(40, 2, 1, 9, '<p>¿Qué expone el texto?<br /><br />En los 20 años que tengo vinculado a la producción histórica, primero como estudiante y luego como profesor, nunca había visto a los historiadores académicos actuar como comunidad frente a los desafíos de la vida pública [...] extrañábamos la ausencia de una comunidad de discusión más allá de lo historiográfico, más allá de nuestras instituciones. [...] Confío en que estas acciones lleven a un creciente número de historiadores a la reflexión sobre el significado social de nuestro trabajo, así como a cerrar el camino a quienes han venido vaciando de contenido y significado nuestra historia. [...] ¡Saludamos al Observatorio Ci&#xdada;no de la Historia y al Seminario de Ética para Historiadores esperando que sean una campanada para enfrentar la crisis en que está sumida la ciencia histórica!<br /><br /></p><p style=\'text-align: right;\'><sub>Pedro Salmerón Sanginés. \'La historia que necesitamos para el país\'. <em>La Jornada</em></sub></p>', '<p>La visión de la relación historia-sociedad</p>', '<p>El punto de vista del autor sobre el tema</p>', '<p>Una referencia al trabajo de los historiadores</p>', '<p>Un balance sobre problemas históricos actuales</p>', 2, 0, '2020-05-21 11:19:23', '2020-05-23 12:56:07'),
(41, 2, 1, 10, '<p style=\'text-align: left;\'><strong>Lea el texto y conteste las preguntas.</strong><br /><br /></p><p style=\'text-align: center;\'><strong>Viven en la pobreza, 26 millones de niñas y niños en México</strong></p><p style=\'text-align: left;\'>[<strong>1</strong>] Casi 26 millones de niñas y niños en México experimentan pobreza y pobreza extrema, ya que sufren precariedad en el acceso a la salud, alimentación, educación, vivienda y seguridad social, reveló el Consejo Nacional de Evaluación de la Política de Desarrollo Social (CONEVAL).<br /><p>[<strong>2</strong>] Esta cifra representa el 53% de la población del país entre 0 y 17 años de edad, de acuerdo con el informe <em>Pobreza y derechos sociales de niñas, niños y adolescentes en México 2010-2012</em>, que realizaron el Fondo de las Naciones Unidas para la Infancia (UNICEF) y el CONEVAL y que fue presentado hoy en esta ciudad.<br /><p>[<strong>3</strong>] Cabe señalar que la población infantil en México es de 39.2 millones, de la cual más de la mitad son niñas, según datos del Instituto Nacional de Estadística y Geografía (INEGI).<br /><p>[<strong>4</strong>] Con base en los datos del informe, se estima que específicamente 21.2 millones de niñas, niños y adolescentes se encuentran en pobreza, y 4.7 millones en pobreza extrema, es decir, sin posibilidades de acceso a los servicios básicos para la subsistencia.<br /><p>[<strong>5</strong>] Estas cifras son mayores de acuerdo con el índice de pobreza a nivel nacional que es de 45.5%; pero apenas 2% menos en comparación con las obtenidas en 2010. Es decir, la pobreza extrema en menores de 17 años pasó de 11.3% a 12.1% en 2012. [...]<br /><p>[<strong>6</strong>] Además, 33.4% de los niños indígenas están en situaciones de vulnerabilidad y pobreza extremas; 93.5% tiene una o más carencias sociales, y 48.5% vive en hogares con ingresos inferiores a la línea de bienestar. [...]<br /><p>[<strong>7</strong>] La pobreza en la infancia, explicó Gonzalo Hernández Licona, secretario ejecutivo de CONEVAL, se mide de acuerdo con indicadores que no están relacionados únicamente al ingreso, por lo que para este estudio se valoró el índice de rezago educativo, acceso a los servicios de salud, seguridad social, calidad y espacios de la vivienda, y acceso a la alimentación. [...]</p><p style=\'text-align: right;\'><sup>Angélica Jocelyn Soto Espinosa. <em>Cimacnoticias.com.mx</em></sup></p><br><p>¿Cuál es el propósito del texto?</p>', '<p>Persuadir</p>', '<p>Describir</p>', '<p>Informar</p>', '<p>Categorizar</p>', 3, 0, '2020-05-21 11:21:59', '2020-05-23 12:56:29'),
(42, 7, 1, 1, '¿Qué rama de la biología estudia a los peces?', 'Herpetología          ', 'Entomología                    ', 'Ictiología                   ', 'Ornitología', 3, 0, '2020-05-21 11:26:28', '2020-05-22 18:54:46'),
(43, 7, 1, 2, '¿Qué rama de la biología estudia las funciones de los seres vivos?', 'Ecología                          ', 'Taxonomía                        ', 'Genética                    ', 'Fisiología ', 4, 0, '2020-05-21 11:27:40', '2020-05-22 18:54:51'),
(44, 7, 1, 3, 'Característica de los bioelementos secundarios:', 'Son indispensables para la formación de las biomoléculas orgánicas      ', 'Constituyen el 4.5 % de la materia viva                    ', 'Son C, H, O, N               ', 'Se encuentran en una proporción inferior al 0,1%', 0, 0, '2020-05-21 11:44:43', '2020-05-21 16:45:13'),
(45, 7, 1, 4, 'Científico que elabora la teoría celular:', 'T. Schwann               ', 'Antonie Leeuwenhoek      ', 'Robert Hooke             ', 'H. Dutrochet', 0, 0, '2020-05-21 13:17:32', '2020-05-23 12:20:06'),
(46, 7, 1, 5, 'Es un postulado de la teoría celular:', 'Todas las células están formadas de carbono', 'En las células se llevan a cabo todas las reacciones exotérmicas', 'Las nuevas células se forman de las muertas ', 'Todos los seres vivos están formados por células', 4, 0, '2020-05-23 07:21:46', '2020-05-23 12:21:46'),
(47, 7, 1, 6, 'Elige la opción que no pertenece a los elementos primarios', 'Calcio', 'Hidrogeno', 'Oxigeno  ', 'Todas son correctas', 0, 0, '2020-05-23 07:24:48', '2020-05-23 12:24:48'),
(48, 7, 1, 7, '¿Qué tipo de bioelementos forman a las biomoléculas orgánicas?', 'Primarios           ', 'Secundarios                            ', 'Oligoelementos        ', 'principios inmediatos ', 0, 0, '2020-05-23 07:26:35', '2020-05-23 12:26:35'),
(49, 7, 1, 8, '¿Cuál de las siguientes opciones corresponde al oligoelemento que forma parte de las hormonas de la tiroides?', 'Zinc', 'Sodio', 'Iodo ', 'Todas son incorrectas', 0, 0, '2020-05-23 07:31:37', '2020-05-23 12:31:37'),
(50, 7, 1, 9, 'Elige la opción que indique una de las funciones del elemento flúor (F)', 'componente de la hemoglobina', 'participa en acciones enzimáticas', 'transmisión del impulso nervioso', 'incrementa la dureza de huesos y dientes', 4, 0, '2020-05-23 07:36:12', '2020-05-23 12:36:12'),
(51, 7, 1, 10, '¿Cuál de las siguientes opciones no corresponde a una función del sodio?', 'transmisión del impulso nervioso', 'regula el volumen plasmático', 'regula la presión arterial', 'todas son correctas', 0, 0, '2020-05-23 07:39:09', '2020-05-23 12:39:09'),
(52, 8, 1, 1, 'Es la ciencia que estudia a la materia, sus propiedades, composición, reactividad y las transformaciones que experimentan, es:', 'CIENCIAS NATURALES         ', 'FISICA            ', 'QUIMICA    ', 'BIOQUIMICA ', 3, 0, '2020-05-24 20:55:48', '2020-05-25 01:55:48'),
(53, 8, 1, 2, 'Escriba el nombre de los siguientes elementos: \nFe________________ Au______________ K_________________ Pb________________ Na______________', 'Hierro, Oro, Cobalto, Tungsteno, Sodio', 'Hierro, Oro, Potasio, Plomo, Sodio', 'Plata, Oro, Cadmio, Plomo, Cloro', 'Hidrógeno, Oro, Potasio, Plomo, Cloro', 2, 0, '2020-05-24 20:59:42', '2020-05-25 01:59:42'),
(54, 8, 1, 3, 'Escriba el símbolo correcto del elemento en cada caso: \nCesio_________ Cadmio_________ Plomo__________ Xenón________ Rutenio_______ Antimonio_____ ', 'Cs, Ag, Pb, Xe, Ru, Sb', 'Cs, Cd, Pb, Xe, Ru, Sb', 'Ce, Cm, Pl, Xn, Ru, Sb', 'Cs, Ca, Pb, Xe, Rt, At', 1, 0, '2020-05-24 21:08:04', '2020-05-25 02:08:04');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `nombre_entrada` varchar(35) NOT NULL,
  `nombre` varchar(95) NOT NULL DEFAULT '',
  `contrasenia` varchar(32) NOT NULL,
  `cargo` varchar(35) NOT NULL DEFAULT '',
  `perfil` int(11) DEFAULT NULL,
  `estatus` char(1) DEFAULT 'A',
  `es_visible` char(1) NOT NULL,
  `fecha_alta` datetime NOT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre_entrada`, `nombre`, `contrasenia`, `cargo`, `perfil`, `estatus`, `es_visible`, `fecha_alta`, `fecha_modificacion`) VALUES
(1, 'admin', 'admin', '21232f297a57a5a743894a0e4a801fc3', 'administrador', 1, 'A', 'N', '2020-05-24 12:17:07', '2020-05-26 03:03:23'),
(2, 'ING', 'ING', 'd4408643ccbd7e83d0c54f42e405d618', '', NULL, 'A', 'S', '2020-05-25 22:05:32', '2020-05-26 03:07:54');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `alumnos`
--
ALTER TABLE `alumnos`
  ADD PRIMARY KEY (`id_alumno`);

--
-- Indices de la tabla `areas`
--
ALTER TABLE `areas`
  ADD PRIMARY KEY (`id_area`);

--
-- Indices de la tabla `areas_niveles`
--
ALTER TABLE `areas_niveles`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `asignaturas`
--
ALTER TABLE `asignaturas`
  ADD PRIMARY KEY (`id_asignatura`),
  ADD UNIQUE KEY `UC_subjectid` (`id_asignatura`);

--
-- Indices de la tabla `asignaturas_niveles`
--
ALTER TABLE `asignaturas_niveles`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `carreras`
--
ALTER TABLE `carreras`
  ADD PRIMARY KEY (`idcarrera`);

--
-- Indices de la tabla `docentes`
--
ALTER TABLE `docentes`
  ADD PRIMARY KEY (`id_docente`);

--
-- Indices de la tabla `escuelas`
--
ALTER TABLE `escuelas`
  ADD PRIMARY KEY (`id_escuela`);

--
-- Indices de la tabla `examenes`
--
ALTER TABLE `examenes`
  ADD PRIMARY KEY (`id_examen`),
  ADD KEY `id_usuario` (`id_nivel`),
  ADD KEY `id_asignatura` (`id_asignatura`),
  ADD KEY `id_grado` (`id_grado`),
  ADD KEY `id_docente` (`id_docente`);

--
-- Indices de la tabla `examenes_alumnos`
--
ALTER TABLE `examenes_alumnos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id_test` (`id`);

--
-- Indices de la tabla `examenes_preguntas`
--
ALTER TABLE `examenes_preguntas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_examen` (`id_examen`),
  ADD KEY `id_pregunta` (`id_pregunta`);

--
-- Indices de la tabla `examenes_respuestas`
--
ALTER TABLE `examenes_respuestas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UC_testid` (`id`),
  ADD KEY `id_examen_alumno` (`id_examen_alumno`),
  ADD KEY `id_pregunta` (`id_pregunta`);

--
-- Indices de la tabla `examenes_secciones`
--
ALTER TABLE `examenes_secciones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id_examen` (`id_examen`);

--
-- Indices de la tabla `grados`
--
ALTER TABLE `grados`
  ADD PRIMARY KEY (`id_grado`);

--
-- Indices de la tabla `grupos`
--
ALTER TABLE `grupos`
  ADD PRIMARY KEY (`id_grupo`);

--
-- Indices de la tabla `niveles`
--
ALTER TABLE `niveles`
  ADD PRIMARY KEY (`id_nivel`);

--
-- Indices de la tabla `preguntas`
--
ALTER TABLE `preguntas`
  ADD PRIMARY KEY (`id_pregunta`),
  ADD UNIQUE KEY `UC_questionid` (`id_pregunta`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `UC_adminid` (`id_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `alumnos`
--
ALTER TABLE `alumnos`
  MODIFY `id_alumno` smallint(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT de la tabla `areas`
--
ALTER TABLE `areas`
  MODIFY `id_area` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `areas_niveles`
--
ALTER TABLE `areas_niveles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT de la tabla `asignaturas`
--
ALTER TABLE `asignaturas`
  MODIFY `id_asignatura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `asignaturas_niveles`
--
ALTER TABLE `asignaturas_niveles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `carreras`
--
ALTER TABLE `carreras`
  MODIFY `idcarrera` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `docentes`
--
ALTER TABLE `docentes`
  MODIFY `id_docente` smallint(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `escuelas`
--
ALTER TABLE `escuelas`
  MODIFY `id_escuela` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `examenes`
--
ALTER TABLE `examenes`
  MODIFY `id_examen` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `examenes_alumnos`
--
ALTER TABLE `examenes_alumnos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `examenes_preguntas`
--
ALTER TABLE `examenes_preguntas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=156;

--
-- AUTO_INCREMENT de la tabla `examenes_respuestas`
--
ALTER TABLE `examenes_respuestas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `grados`
--
ALTER TABLE `grados`
  MODIFY `id_grado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `grupos`
--
ALTER TABLE `grupos`
  MODIFY `id_grupo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `preguntas`
--
ALTER TABLE `preguntas`
  MODIFY `id_pregunta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `examenes`
--
ALTER TABLE `examenes`
  ADD CONSTRAINT `examenes_ibfk_1` FOREIGN KEY (`id_nivel`) REFERENCES `niveles` (`id_nivel`) ON UPDATE CASCADE,
  ADD CONSTRAINT `examenes_ibfk_2` FOREIGN KEY (`id_asignatura`) REFERENCES `asignaturas` (`id_asignatura`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `examenes_preguntas`
--
ALTER TABLE `examenes_preguntas`
  ADD CONSTRAINT `examenes_preguntas_ibfk_2` FOREIGN KEY (`id_pregunta`) REFERENCES `preguntas` (`id_pregunta`) ON UPDATE CASCADE,
  ADD CONSTRAINT `examenes_preguntas_ibfk_3` FOREIGN KEY (`id_examen`) REFERENCES `examenes` (`id_examen`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `examenes_respuestas`
--
ALTER TABLE `examenes_respuestas`
  ADD CONSTRAINT `examenes_respuestas_ibfk_1` FOREIGN KEY (`id_examen_alumno`) REFERENCES `examenes_alumnos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `examenes_respuestas_ibfk_2` FOREIGN KEY (`id_pregunta`) REFERENCES `preguntas` (`id_pregunta`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
