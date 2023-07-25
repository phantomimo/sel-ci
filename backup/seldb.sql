-- phpMyAdmin SQL Dump
-- version 4.9.5
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 24-05-2020 a las 17:26:10
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
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `AGREGAR_BITACORA` (IN `P_TABLA` VARCHAR(35), IN `P_ACCION` VARCHAR(35), IN `P_DETALLE` VARCHAR(600), IN `P_COMENTARIOS` VARCHAR(150), IN `P_USUARIO` VARCHAR(50), IN `P_SUCURSAL` VARCHAR(35), IN `P_CAJA` VARCHAR(20), OUT `P_CLAVE` INT)  BEGIN DECLARE iClave INT; CALL OBTENER_CLAVE( 'bitacora', @out_value_clave2 ); SELECT @out_value_clave2 INTO iClave; INSERT INTO bitacora ( clave, tabla , accion , detalle , comentarios , usuario , sucursal , caja ) VALUES ( iClave, P_TABLA , P_ACCION , P_DETALLE , P_COMENTARIOS , P_USUARIO , P_SUCURSAL , P_CAJA ); UPDATE claves_tablas SET clave = iClave WHERE tabla = 'bitacora'; SET P_CLAVE = iClave; END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `APLICAR_INVENTARIO_AREA_VENTA` (IN `P_CLAVE_AREA_VENTA` INT, IN `P_CLAVE_VENTA` INT, IN `P_OPERACION` VARCHAR(20), IN `P_DOCUMENTO` VARCHAR(35), IN `P_USUARIO` VARCHAR(20))  BEGIN


declare iClave_inventario bigint(20);
declare iArticulo int(11);
declare iAlmacen int(11);
declare iMoneda int(11);
declare iCantidad DECIMAL(12,4);
declare iCosto DECIMAL(15,6);
declare iPorcentaje_impuesto float;
declare iTipo_cambio float;
DECLARE iFecha TIMESTAMP;
declare iCompra int(11);
declare iMovimiento int(11);
declare iGastos DECIMAL(10,2);
DECLARE iLote VARCHAR(20);
DECLARE iFechaCaducidad DATE;
declare clave_articulos_utilizados bigint(20);
DECLARE es_primer_ciclo int(11);

DECLARE done INT DEFAULT FALSE;
DECLARE curs CURSOR FOR SELECT i.clave, i.articulo, c.almacen, c.moneda, c.cantidad, i.costo, i.porcentaje_impuesto, i.tipo_cambio, i.fecha, i.compra, i.movimiento, i.gastos, i.lote, i.fecha_caducidad FROM articulos_inventario AS i JOIN articulos_comprometidos AS c ON c.articulo_inventario = i.clave AND c.area_venta = P_CLAVE_AREA_VENTA;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

SET es_primer_ciclo = 1;

	OPEN curs;
	read_loop: LOOP

    	FETCH curs INTO iClave_inventario , iArticulo, iAlmacen, iMoneda, iCantidad, iCosto, iPorcentaje_impuesto, iTipo_cambio, iFecha, iCompra, iMovimiento, iGastos, iLote, iFechaCaducidad;

		IF done THEN
          LEAVE read_loop;
        END IF;

		IF ( P_OPERACION != 'cancelar' ) THEN
			CALL REGISTRAR_KARDEX(P_OPERACION, P_DOCUMENTO,
            iAlmacen, P_CLAVE_VENTA, null, null, iArticulo, iCantidad * -1, iCosto, iLote, iFechaCaducidad, iMoneda, iTipo_cambio, P_USUARIO);
		END IF;
        
		CALL OBTENER_CLAVE( 'articulos_utilizados', @out_value_clave );
		SELECT @out_value_clave INTO clave_articulos_utilizados;

		INSERT INTO articulos_utilizados(clave, articulo, cantidad, almacen, costo, fecha, fecha_utilizado, compra, movimiento, articulo_inventario, moneda, porcentaje_impuesto, tipo_cambio, gastos, lote, fecha_caducidad)VALUES( clave_articulos_utilizados, iArticulo, iCantidad, iAlmacen, iCosto, iFecha, CURRENT_TIMESTAMP, iCompra, iMovimiento, iClave_inventario, iMoneda, iPorcentaje_impuesto, iTipo_cambio, iGastos, iLote, iFechaCaducidad);
                                                                                   	UPDATE claves_tablas SET clave = clave_articulos_utilizados WHERE tabla = 'articulos_utilizados';


	IF ( es_primer_ciclo = 1 )THEN
        	SET es_primer_ciclo = 0;
			DELETE FROM articulos_comprometidos WHERE area_venta = P_CLAVE_AREA_VENTA;
        END IF;

	DELETE FROM articulos_inventario WHERE (SELECT SUM(cantidad) FROM articulos_utilizados
    WHERE articulo_inventario = iClave_inventario AND almacen = iAlmacen) = cantidad AND clave = iClave_inventario AND almacen = iAlmacen;

	END LOOP;
	CLOSE curs;

	DELETE FROM ventas_areas WHERE clave = P_CLAVE_AREA_VENTA;

END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `APLICAR_TRASPASO_EXISTENCIA` (IN `P_AREA_VENTA` INT, IN `P_ALMACEN_DESTINO` INT, IN `P_TRASPASO` INT, IN `P_USUARIO_NOMBRE` VARCHAR(45), IN `P_DOCUMENTO` VARCHAR(35), IN `P_COMPRA` INT)  BEGIN

DECLARE iArticulo INT;
DECLARE iAlmacen INT;
DECLARE iMoneda INT;
DECLARE iCosto DECIMAL(15,6);
DECLARE iPorcentaje_impuesto FLOAT;
DECLARE iTipo_cambio FLOAT;
DECLARE iCompra INT;
DECLARE iMovimiento INT;
DECLARE iCantidad DECIMAL(12,4);
DECLARE iGastos DECIMAL(10,2);
DECLARE iLote VARCHAR(20);
DECLARE iFechaCaducidad DATE;
DECLARE iClave INT;

DECLARE done INT DEFAULT FALSE;
DECLARE curs CURSOR FOR SELECT i.articulo , i.almacen , i.moneda , i.costo , i.porcentaje_impuesto , i.tipo_cambio , i.compra , i.movimiento , c.cantidad, i.gastos, i.lote, i.fecha_caducidad FROM articulos_inventario AS i JOIN articulos_comprometidos AS c ON c.articulo_inventario = i.clave AND c.area_venta = P_AREA_VENTA;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = true;

	OPEN curs;
	read_loop: LOOP

    	FETCH curs INTO iArticulo , iAlmacen , iMoneda , iCosto , iPorcentaje_impuesto , iTipo_cambio , iCompra , iMovimiento , iCantidad, iGastos, iLote, iFechaCaducidad;
		IF done THEN
          LEAVE read_loop;
        END IF;

		CALL REGISTRAR_EXISTENCIA(P_COMPRA , iArticulo , iCantidad , P_ALMACEN_DESTINO , null , P_TRASPASO , iMoneda , iCosto , iGastos, iLote, iFechaCaducidad, iPorcentaje_impuesto , iTipo_cambio , P_USUARIO_NOMBRE , "TRASPASO" , P_DOCUMENTO );

	END LOOP;
	CLOSE curs;

END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `CALCULAR_INVENTARIO` (IN `P_ALMACEN` INT, IN `P_FECHA` TIMESTAMP)  BEGIN

DECLARE iEntidad SMALLINT;
DECLARE iClaveArticulo INT;

DECLARE done INT DEFAULT FALSE;
DECLARE curs CURSOR FOR SELECT * FROM vw_myproc;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

		DELETE FROM inventario_calculado;

		OPEN curs;
		read_loop: LOOP

			FETCH curs INTO iClaveArticulo;
					IF done THEN
					  LEAVE read_loop;
					END IF;

					-- Procedimiento que calcula la existencia para un inventario basandose en uno anterior
					IF ( P_ALMACEN IS NULL ) THEN
							-- Inserta en el inventario destino la existencia actual sin las entradas posteriores a la fecha del inventario
									IF ( iClaveArticulo IS NULL ) THEN
											INSERT INTO inventario_calculado (almacen, articulo, cantidad, costo, gastos, fecha, fecha_umov)
																SELECT P_ALMACEN, articulo, cantidad - ( SELECT COALESCE( SUM(articulos_utilizados.cantidad), 0 ) FROM articulos_utilizados WHERE articulos_utilizados.articulo_inventario = articulos_inventario.clave ), costo, gastos, fecha, CURRENT_TIMESTAMP
																FROM articulos_inventario WHERE fecha < P_FECHA;
									ELSE
											INSERT INTO inventario_calculado (almacen, articulo, cantidad, costo, gastos, fecha, fecha_umov)
																SELECT P_ALMACEN, articulo, cantidad - ( SELECT COALESCE( SUM(articulos_utilizados.cantidad), 0 ) FROM articulos_utilizados WHERE articulos_utilizados.articulo_inventario = articulos_inventario.clave ), costo, gastos, fecha, CURRENT_TIMESTAMP
																FROM articulos_inventario WHERE articulo = iClaveArticulo AND fecha < P_FECHA;
									END IF;
							
					ELSE
							SELECT cajas.sucursal INTO iEntidad FROM cajas JOIN cajas_almacenes ON cajas.clave = cajas_almacenes.caja 
										WHERE cajas_almacenes.almacen = P_ALMACEN LIMIT 1;
							-- Inserta en el inventario destino la existencia actual sin las entradas posteriores a la fecha del inventario
									IF ( iClaveArticulo IS NULL ) THEN
											INSERT INTO inventario_calculado (articulo, cantidad, costo, gastos, fecha, almacen)
													SELECT articulo, cantidad - ( SELECT COALESCE( SUM(articulos_utilizados.cantidad), 0 ) FROM articulos_utilizados WHERE articulos_utilizados.articulo_inventario = articulos_inventario.clave ), costo, gastos, fecha, almacen
													FROM articulos_inventario WHERE fecha <= P_FECHA AND almacen = P_ALMACEN;
											-- Inserta las ventas posteriores a la fecha del inventario
											INSERT INTO inventario_calculado (articulo, cantidad, costo, gastos, fecha, almacen)
													SELECT ventas_detalle_inventario.articulo, ventas_detalle_inventario.cantidad, ventas_detalle_inventario.costo, ventas_detalle_inventario.gastos, ventas_detalle_inventario.fecha, ventas_detalle_inventario.almacen
													FROM ventas_detalle_inventario JOIN ventas ON ventas_detalle_inventario.venta = ventas.clave
													WHERE ventas.sucursal = iEntidad AND ventas_detalle_inventario.fecha < P_FECHA AND
													CONCAT(ventas.fecha , ' ', ventas.hora) > P_FECHA AND ventas_detalle_inventario.almacen = P_ALMACEN;
									ELSE
											INSERT INTO inventario_calculado (articulo, cantidad, costo, gastos, fecha, almacen)
													SELECT articulo, cantidad - ( SELECT COALESCE( SUM(articulos_utilizados.cantidad), 0 ) FROM articulos_utilizados WHERE articulos_utilizados.articulo_inventario = articulos_inventario.clave ), costo, gastos, fecha, almacen
													FROM articulos_inventario WHERE fecha <= P_FECHA AND almacen = P_ALMACEN AND articulo = iClaveArticulo;
											-- Inserta las ventas posteriores a la fecha del inventario
											INSERT INTO inventario_calculado (articulo, cantidad, costo, gastos, fecha, almacen)
													SELECT ventas_detalle_inventario.articulo, ventas_detalle_inventario.cantidad, ventas_detalle_inventario.costo, ventas_detalle_inventario.gastos, ventas_detalle_inventario.fecha, ventas_detalle_inventario.almacen
													FROM ventas_detalle_inventario JOIN ventas ON ventas_detalle_inventario.venta = ventas.clave
													WHERE ventas.sucursal = iEntidad AND ventas_detalle_inventario.fecha < P_FECHA AND
													CONCAT(ventas.fecha , ' ', ventas.hora) > P_FECHA AND ventas_detalle_inventario.almacen = P_ALMACEN AND ventas_detalle_inventario.articulo = iClaveArticulo;
									END IF;
					END IF;

		END LOOP;
		CLOSE curs;

		DROP VIEW vw_myproc;

END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `CANCELAR_VENTA_ACTUAL` (IN `P_CLAVE_AREA_VENTA` BIGINT)  BEGIN

declare iAreaVentaDetalle bigint(20);
declare iCantidad float;

DECLARE done INT DEFAULT FALSE;
DECLARE curs CURSOR FOR SELECT area_venta_detalle, cantidad FROM articulos_comprometidos WHERE area_venta = P_CLAVE_AREA_VENTA ORDER BY fecha DESC, clave DESC;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	OPEN curs;
	read_loop: LOOP

    	FETCH curs INTO iAreaVentaDetalle, iCantidad;

		IF done THEN
          LEAVE read_loop;
        END IF;

		CALL DESAPARTAR_EXISTENCIA(iAreaVentaDetalle, iCantidad);
	END LOOP;
	CLOSE curs;

	DELETE FROM ventas_areas WHERE clave = P_CLAVE_AREA_VENTA;

END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `CREAR_ARTICULO_VENTAS` ()  BEGIN

DECLARE clave_articulo INT;
DECLARE clave_unidad_medida INT;

SELECT MAX(clave) + 1 into clave_articulo FROM articulos WHERE clave < 100000;

SELECT clave into clave_unidad_medida FROM unidades_medida WHERE UPPER(nombre) = 'ACTIVIDAD' LIMIT 1;

	IF ( clave_unidad_medida IS NULL )THEN
		SELECT MAX(clave) + 1 into clave_unidad_medida FROM unidades_medida;

		INSERT INTO unidades_medida(clave,clave_sat, nombre, estatus, fecha_umov)VALUES(clave_unidad_medida, 'ACT', 'Actividad', 'A', CURRENT_TIMESTAMP);

	END IF;

INSERT INTO articulos (clave, articulo_generador, articulo, articulo_presentacion, marca, departamento, categoria, clasificacion, corrida, corrida_detalle, temporada, tipo, unidad_medida, color, impuesto, moneda, estilo, descripcion, descripcion_corta, ultimo_costo, costo_neto, observaciones, ultima_compra, ultima_venta, costo_automatico, permitir_modificar_precio, descripcion_automatica, se_vende, estatus, fecha_captura, fecha_umov) VALUES
(clave_articulo, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, NULL, 2, clave_unidad_medida, NULL, 1, 1, '', 'VENTAS', 'VENTAS', 0, 0, '', NULL, NULL, 'N', 'N', 'N', 'N', 'I', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO articulos_codigos( articulo, codigo, tipo ) VALUES( clave_articulo, 'A1A1A1A1', 'P');

UPDATE claves_tablas SET clave = clave_articulo WHERE tabla = 'articulos';

UPDATE claves_tablas SET clave = clave_unidad_medida WHERE tabla = 'unidades_medida';

DELETE FROM claves_tablas WHERE tabla IN ('articulos_codigos');

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DESAPARTAR_EXISTENCIA` (IN `P_CLAVE_AREA_VENTA_DETALLE` BIGINT, IN `P_CANTIDAD` FLOAT)  proc_label:BEGIN

DECLARE iCantidad_total float;
DECLARE iCantidad_apartada float;
DECLARE iCantidad_aplicada float;
DECLARE iInventario integer;
DECLARE iClave integer;

DECLARE bDone INT;
DECLARE curs CURSOR FOR SELECT clave, cantidad, articulo_inventario FROM
  				articulos_comprometidos WHERE area_venta_detalle = P_CLAVE_AREA_VENTA_DETALLE 
  			ORDER BY fecha DESC, clave DESC;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET bDone = 1;

	-- Elimina los apartados de los articulos registrados en las areas de venta
	SET iCantidad_total = P_CANTIDAD;
	-- Recupera los apartados
	OPEN curs;
	SET bDone = 0;

	REPEAT
    	FETCH curs INTO iClave, iCantidad_apartada, iInventario;
		
		IF(iCantidad_total = 0) THEN
			LEAVE proc_label;
		END IF;
		IF(iCantidad_total < iCantidad_apartada) THEN
			SET iCantidad_aplicada = iCantidad_total;
      			UPDATE articulos_comprometidos SET cantidad = cantidad - iCantidad_aplicada
      			WHERE clave = iClave;
		ELSE
			SET iCantidad_aplicada = iCantidad_apartada;
      			DELETE FROM articulos_comprometidos WHERE clave = iClave;

		END IF;
    		SET iCantidad_total = iCantidad_total - iCantidad_aplicada;

	UNTIL bDone END REPEAT;
	CLOSE curs;
END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `DESAPARTAR_EXISTENCIA_VENTA` (IN `P_CLAVE_VENTA` BIGINT, IN `P_VENTA_DETALLE` BIGINT, IN `P_ARTICULO` INT, IN `P_CANTIDAD` FLOAT)  proc_label:BEGIN

DECLARE iCantidad_total float;
DECLARE iCantidad_apartada float;
DECLARE iCantidad_aplicada float;
DECLARE iInventario integer;
DECLARE iClave integer;

DECLARE bDone INT;
DECLARE curs CURSOR FOR SELECT clave, cantidad, articulo_inventario FROM
  				articulos_comprometidos WHERE venta = P_CLAVE_VENTA AND venta_detalle = P_VENTA_DETALLE AND articulo = P_ARTICULO
  			ORDER BY fecha DESC, clave DESC;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET bDone = 1;

	-- Elimina los apartados de los articulos registrados en las areas de venta
	SET iCantidad_total = P_CANTIDAD;
	-- Recupera los apartados
	OPEN curs;
	SET bDone = 0;

	REPEAT
    	FETCH curs INTO iClave, iCantidad_apartada, iInventario;
		
		IF(iCantidad_total = 0) THEN
			LEAVE proc_label;
		END IF;
		IF(iCantidad_total < iCantidad_apartada) THEN
			SET iCantidad_aplicada = iCantidad_total;
      			UPDATE articulos_comprometidos SET cantidad = cantidad - iCantidad_aplicada
      			WHERE clave = iClave;
		ELSE
			SET iCantidad_aplicada = iCantidad_apartada;
      			DELETE FROM articulos_comprometidos WHERE clave = iClave;

		END IF;
    		SET iCantidad_total = iCantidad_total - iCantidad_aplicada;

	UNTIL bDone END REPEAT;
	CLOSE curs;
END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `DEVOLVER_EXISTENCIA` (IN `P_CLAVE_VENTA` INT, IN `P_ALMACEN` INT, IN `P_ORDEN` INT, IN `P_ARTICULO` INT, IN `P_CANTIDAD` FLOAT, IN `P_USUARIO_NOMBRE` VARCHAR(20), IN `P_OPERACION` VARCHAR(20), IN `P_DOCUMENTO` VARCHAR(35), OUT `EXCEPCION` VARCHAR(50))  proc_label:BEGIN

DECLARE iClave INT;
DECLARE iClaveInventario INT;
DECLARE iClaveKardex INT;
DECLARE iArticulo INT;
DECLARE iMoneda INT;
DECLARE iCantidad float;
DECLARE iCosto float;
DECLARE iPorcentajeImpuesto float;
DECLARE iTipoCambio float;
DECLARE iDteFecha TIMESTAMP;
DECLARE iCompra INT;
DECLARE iMovimiento INT;
DECLARE iGastos DECIMAL(10,2);
DECLARE iLote VARCHAR(20);
DECLARE iFechaCaducidad DATE;
DECLARE iCantidadTotal float;
DECLARE iCantidadAplicada float;
DECLARE i_existencia float;

DECLARE bDone INT;
DECLARE curs CURSOR FOR SELECT clave, articulo, moneda, cantidad, costo, porcentaje_impuesto, tipo_cambio, fecha, compra, movimiento, gastos, lote, fecha_caducidad  
  			FROM ventas_detalle_inventario WHERE venta = P_CLAVE_VENTA AND orden = P_ORDEN AND
  			articulo = P_ARTICULO ORDER BY fecha ASC;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET bDone = 1;

SET EXCEPCION = "EXITO";
-- Devuelve los articulos de la venta especificada
SET iCantidadTotal = P_CANTIDAD;

	-- Recupera los articulos de la
	OPEN curs;
	SET bDone = 0;

	REPEAT
    	FETCH curs INTO iClave, iArticulo, iMoneda, 
  			iCantidad, iCosto, iPorcentajeImpuesto, iTipoCambio, iDteFecha, iCompra, iMovimiento, iGastos, iLote, iFechaCaducidad;

		IF(iCantidadTotal = 0) THEN
			LEAVE proc_label;
		END IF;
		IF(iCantidadTotal < iCantidad) THEN
			SET iCantidadAplicada = iCantidadTotal;

				CALL REGISTRAR_KARDEX( P_OPERACION, P_DOCUMENTO, P_ALMACEN, P_CLAVE_VENTA, null, null, P_ARTICULO, iCantidadAplicada, iCosto, iLote, iFechaCaducidad, iMoneda, iTipoCambio, P_USUARIO_NOMBRE) ;

				CALL OBTENER_CLAVE( 'articulos_inventario', @out_value_clave );
				SELECT @out_value_clave INTO iClaveInventario;

      			INSERT INTO articulos_inventario (clave, articulo, almacen, moneda, cantidad, 
      				costo, porcentaje_impuesto, tipo_cambio, fecha, compra, 
					movimiento, gastos, lote, fecha_caducidad) VALUES(
      					iClaveInventario, iArticulo, P_ALMACEN, iMoneda, iCantidadAplicada,
      					 iCosto, iPorcentajeImpuesto, iTipoCambio, iDteFecha, iCompra, 
						 iMovimiento, iGastos, iLote, iFechaCaducidad);

				UPDATE claves_tablas SET clave = iClaveInventario WHERE tabla = 'articulos_inventario';
      
			UPDATE ventas_detalle_inventario SET cantidad = cantidad - iCantidadAplicada
      				WHERE clave = iClave;
		ELSE
			SET iCantidadAplicada = iCantidad;

				CALL REGISTRAR_KARDEX( P_OPERACION, P_DOCUMENTO, P_ALMACEN, P_CLAVE_VENTA, null, null, P_ARTICULO, iCantidadAplicada, iCosto, iLote, iFechaCaducidad, iMoneda, iTipoCambio, P_USUARIO_NOMBRE) ;

				CALL OBTENER_CLAVE( 'articulos_inventario', @out_value_clave );
				SELECT @out_value_clave INTO iClaveInventario;

      			INSERT INTO articulos_inventario (clave, articulo, almacen, moneda, cantidad, 
      				costo, porcentaje_impuesto, tipo_cambio, fecha, compra, 
					movimiento, gastos, lote, fecha_caducidad) VALUES(

      					iClaveInventario, iArticulo, P_ALMACEN, iMoneda, iCantidadAplicada,
      					 iCosto, iPorcentajeImpuesto, iTipoCambio, iDteFecha, iCompra, 
						 iMovimiento, iGastos, iLote, iFechaCaducidad);

				UPDATE claves_tablas SET clave = iClaveInventario WHERE tabla = 'articulos_inventario';
      
			DELETE FROM ventas_detalle_inventario WHERE clave = iClave;
		END IF;
		SET iCantidadTotal = iCantidadTotal - iCantidadAplicada;

	UNTIL bDone END REPEAT;
	CLOSE curs;
	
	IF(iCantidadTotal > 0) then
    		SET EXCEPCION = "ERROR";
	END IF;
END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `DEVOLVER_EXISTENCIA_VENTA` (IN `P_CLAVE_VENTA` BIGINT, IN `P_USUARIO_NOMBRE` VARCHAR(20), IN `P_OPERACION` VARCHAR(20), IN `P_DOCUMENTO` VARCHAR(35))  BEGIN

DECLARE iClave BIGINT;

DECLARE iClaveInventario INT;
DECLARE iArticulo INT;
DECLARE iAlmacen INT;
DECLARE iMoneda INT;
DECLARE iCantidad float;
DECLARE iCosto float;
DECLARE iPorcentajeImpuesto float;
DECLARE iTipoCambio float;
DECLARE iDteFecha TIMESTAMP;
DECLARE iCompra INT;
DECLARE iMovimiento INT;
DECLARE iGastos DECIMAL(10,2);
DECLARE iLote VARCHAR(20);
DECLARE iFechaCaducidad DATE;

DECLARE done INT DEFAULT FALSE;
DECLARE curs CURSOR FOR SELECT clave, articulo, almacen, moneda, cantidad, costo, porcentaje_impuesto, tipo_cambio, fecha, compra, movimiento, gastos, lote, fecha_caducidad  
  			FROM ventas_detalle_inventario WHERE venta = P_CLAVE_VENTA ORDER BY articulo ASC;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = true;

	OPEN curs;
	read_loop: LOOP

    	FETCH curs INTO iClave, iArticulo, iAlmacen, iMoneda, 
  			iCantidad, iCosto, iPorcentajeImpuesto, iTipoCambio, iDteFecha, iCompra, iMovimiento, iGastos, iLote, iFechaCaducidad;
			IF done THEN
			  LEAVE read_loop;

			END IF;

		CALL REGISTRAR_KARDEX( P_OPERACION, P_DOCUMENTO, iAlmacen, P_CLAVE_VENTA, null, null, iArticulo, iCantidad, iCosto, iLote, iFechaCaducidad, iMoneda, iTipoCambio, P_USUARIO_NOMBRE) ;

		CALL OBTENER_CLAVE( 'articulos_inventario', @out_value_clave );
		SELECT @out_value_clave INTO iClaveInventario;

		INSERT INTO articulos_inventario (clave, articulo, almacen, moneda, cantidad, 
			costo, porcentaje_impuesto, tipo_cambio, fecha, compra, 
			movimiento, gastos, lote, fecha_caducidad) VALUES(

				iClaveInventario, iArticulo, iAlmacen, iMoneda, iCantidad,
				 iCosto, iPorcentajeImpuesto, iTipoCambio, iDteFecha, iCompra, 
				 iMovimiento, iGastos, iLote, iFechaCaducidad);

		UPDATE claves_tablas SET clave = iClaveInventario WHERE tabla = 'articulos_inventario';


		DELETE FROM ventas_detalle_inventario WHERE clave = iClave;

	END LOOP;
	CLOSE curs;
END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `ESTABLECER_PARAMETRO` (IN `P_NOMBRE` VARCHAR(35), IN `P_VALOR` VARCHAR(100))  BEGIN

DECLARE sValor VARCHAR(100);

SELECT valor INTO sValor FROM parametros WHERE nombre = P_NOMBRE LIMIT 1;

	IF(sValor IS NULL) THEN
		INSERT INTO parametros (nombre, valor) VALUES(P_NOMBRE, P_VALOR);
	ELSE
		UPDATE parametros SET valor = P_VALOR WHERE nombre = P_NOMBRE;
	END IF;

END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `ESTABLECER_PREFERENCIA` (IN `P_USUARIO` INT, IN `P_NOMBRE` VARCHAR(50), IN `P_VALOR` VARCHAR(1500))  BEGIN

DECLARE sValor VARCHAR(1500);
DECLARE sClave INT;

SELECT valor, clave INTO sValor, sClave FROM preferencias WHERE usuario = P_USUARIO AND nombre = P_NOMBRE LIMIT 1;

	IF(sClave IS NULL) THEN
		INSERT INTO preferencias (usuario, nombre, valor) VALUES(P_USUARIO, P_NOMBRE, P_VALOR);
	ELSE
		UPDATE preferencias SET valor = P_VALOR WHERE clave = sClave;
	END IF;

END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `ESTABLECER_PREFERENCIA_USUARIO` (IN `P_CLAVE_USUARIO` INT, IN `P_CLAVE_SUCURSAL` INT, IN `P_NOMBRE` VARCHAR(45), IN `P_VALOR` VARCHAR(45))  BEGIN

DECLARE sValor VARCHAR(100);

SELECT valor INTO sValor FROM usuarios_preferencias WHERE usuario = P_CLAVE_USUARIO AND sucursal = P_CLAVE_SUCURSAL AND nombre = P_NOMBRE LIMIT 1;

	IF(sValor IS NULL) THEN
		INSERT INTO usuarios_preferencias (usuario, sucursal, nombre, valor) VALUES(P_CLAVE_USUARIO, P_CLAVE_SUCURSAL, P_NOMBRE, P_VALOR);
	ELSE
		UPDATE usuarios_preferencias SET valor = P_VALOR WHERE usuario = P_CLAVE_USUARIO AND sucursal = P_CLAVE_SUCURSAL AND nombre = P_NOMBRE LIMIT 1;
	END IF;

END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `IMPUESTOS_COMPRA_DETALLE` (IN `P_CLAVE_COMPRA` INT)  BLOCK1: BEGIN

DECLARE iClaveCompraDetalle bigint(20);
DECLARE iClaveDetalleImpuestos bigint(20);
DECLARE iClaveImpuesto int(11);
DECLARE rImporteNeto float;
DECLARE impuestoIncluido char(1);
DECLARE iOrdenImpuesto int(11);
DECLARE rPorcentajeImpuesto float;
DECLARE rImporteImpuesto float;

DECLARE rSubTotal float;
DECLARE sClave int(11);
DECLARE iClave int(11);
DECLARE sEsCompuesto CHAR(1);
DECLARE sEsLocal CHAR(1);
DECLARE sNombre VARCHAR(30);
DECLARE sPorcentaje float;
DECLARE sTipo char(1);

DECLARE xImporte float;

DECLARE done1 INT DEFAULT FALSE;
DECLARE curs1 CURSOR FOR SELECT compras_detalle.clave, compras_detalle.impuesto, ( compras_detalle.costo * compras_detalle.cantidad * (1 - compras_detalle.porcentaje_descuento / 100) ) AS importe, compras.impuesto_incluido FROM compras_detalle JOIN compras ON compras_detalle.compra = compras.clave WHERE compras_detalle.compra = P_CLAVE_COMPRA ORDER BY orden ASC;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done1 = TRUE;

DELETE FROM compras_detalle_impuestos WHERE compra = P_CLAVE_COMPRA;

	OPEN curs1;
	read_loop1: LOOP

    	FETCH curs1 INTO iClaveCompraDetalle, iClaveImpuesto, rImporteNeto, impuestoIncluido;

		IF done1 THEN
          LEAVE read_loop1;
        END IF;

		
		SELECT clave, es_compuesto, es_local, nombre, porcentaje INTO sClave, sEsCompuesto, sEsLocal, sNombre, sPorcentaje FROM impuestos
		WHERE clave = iClaveImpuesto LIMIT 1;
				IF(sEsCompuesto = 'S') THEN
				
				SET rSubtotal = rImporteNeto;

						BLOCK2: BEGIN
						
								DECLARE orden int(11);
								DECLARE porcentaje float;
								DECLARE impuesto_componente int(11);

								DECLARE done2 INT DEFAULT FALSE;
								DECLARE curs2 CURSOR FOR SELECT d.orden, SUM(i.porcentaje) AS porcentaje, d.impuesto_componente FROM impuestos_detalle d JOIN impuestos i ON d.impuesto_componente = i.clave
																			WHERE d.impuesto = iClaveImpuesto GROUP BY d.orden ORDER BY d.orden ASC;
								DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = TRUE;

								OPEN curs2;
								read_loop2: LOOP
								
								FETCH curs2 INTO orden, porcentaje, impuesto_componente;

										IF done2 THEN
											LEAVE read_loop2;
										END IF;
										
								SET rSubTotal = rSubTotal * (1 + porcentaje / 100);
								
										BLOCK3: BEGIN
										
												DECLARE clave_componente float;
												DECLARE porcentaje_componente float;

												DECLARE done3 INT DEFAULT FALSE;
												DECLARE curs3 CURSOR FOR SELECT i.clave, i.porcentaje FROM impuestos_detalle d JOIN impuestos i ON d.impuesto_componente = i.clave
																								WHERE d.impuesto = iClaveImpuesto AND d.orden = orden;
												DECLARE CONTINUE HANDLER FOR NOT FOUND SET done3 = TRUE;

												OPEN curs3;
												read_loop3: LOOP

												FETCH curs3 INTO clave_componente, porcentaje_componente;

														IF done3 THEN
															LEAVE read_loop3;
														END IF;
														
														SET xImporte = rSubTotal / (1 + porcentaje / 100);
										
														CALL OBTENER_CLAVE( 'compras_detalle_impuestos', @out_value_clave );
														SELECT @out_value_clave INTO iClave;

													    INSERT INTO compras_detalle_impuestos (clave, compra, compra_detalle, impuesto, orden_impuesto, porcentaje, importe, fecha_umov)
																											VALUES(iClave, P_CLAVE_COMPRA, iClaveCompraDetalle, clave_componente, orden, porcentaje_componente, rSubTotal - xImporte,
																															CURRENT_TIMESTAMP);

														UPDATE claves_tablas SET clave = iClave WHERE tabla = 'compras_detalle_impuestos';
														
														END LOOP read_loop3;
												CLOSE curs3;

										END BLOCK3;

								END LOOP read_loop2;
								CLOSE curs2;
						
						END BLOCK2;
						
				ELSE
						CALL OBTENER_CLAVE( 'compras_detalle_impuestos', @out_value_clave );
						SELECT @out_value_clave INTO iClave;

						INSERT INTO compras_detalle_impuestos (clave, compra, compra_detalle, impuesto, orden_impuesto, porcentaje, importe, fecha_umov)
																						   VALUES(iClave, P_CLAVE_COMPRA, iClaveCompraDetalle, iClaveImpuesto, 1, sPorcentaje, rImporteNeto * ( sPorcentaje / 100),
																										   CURRENT_TIMESTAMP);

						UPDATE claves_tablas SET clave = iClave WHERE tabla = 'compras_detalle_impuestos';
				END IF;

	END LOOP read_loop1;
	CLOSE curs1;

END BLOCK1$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `IMPUESTOS_VENTA_DETALLE` (IN `P_CLAVE_VENTA` BIGINT)  BLOCK1: BEGIN

DECLARE iClaveVentaDetalle bigint(20);
DECLARE iClaveDetalleImpuestos bigint(20);
DECLARE iClaveImpuesto int(11);
DECLARE rImporteNeto float;
DECLARE tipoImpuesto char(1);
DECLARE iOrdenImpuesto int(11);
DECLARE rPorcentajeImpuesto float;
DECLARE rImporteImpuesto float;

DECLARE rSubTotal float;
DECLARE sClave int(11);
DECLARE iClave int(11);
DECLARE sEsCompuesto CHAR(1);
DECLARE sEsLocal CHAR(1);
DECLARE sNombre VARCHAR(30);
DECLARE sPorcentaje float;
DECLARE sTipo char(1);

DECLARE xImporte float;

DECLARE done1 INT DEFAULT FALSE;
DECLARE curs1 CURSOR FOR SELECT clave, impuesto, ((cantidad - COALESCE(devolucion,0)) * precio * (1 - porcentaje_descuento / 100) ) AS importe, tipo
											FROM ventas_detalle WHERE venta = P_CLAVE_VENTA AND orden_juego = 0 ORDER BY orden ASC;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done1 = TRUE;

DELETE FROM ventas_detalle_impuestos WHERE venta = P_CLAVE_VENTA;

	OPEN curs1;
	read_loop1: LOOP

    	FETCH curs1 INTO iClaveVentaDetalle, iClaveImpuesto, rImporteNeto, tipoImpuesto;

		IF done1 THEN
          LEAVE read_loop1;
        END IF;

		
		SELECT clave, es_compuesto, es_local, nombre, porcentaje, tipo INTO sClave, sEsCompuesto, sEsLocal, sNombre, sPorcentaje, sTipo FROM impuestos
		WHERE clave = iClaveImpuesto LIMIT 1;
				IF(sEsCompuesto = 'S') THEN
				
				SET rSubtotal = rImporteNeto;

						BLOCK2: BEGIN
						
								DECLARE orden int(11);
								DECLARE porcentaje float;
								DECLARE impuesto_componente int(11);
								

								DECLARE done2 INT DEFAULT FALSE;
								DECLARE curs2 CURSOR FOR SELECT d.orden, SUM(i.porcentaje ) AS porcentaje, d.impuesto_componente FROM impuestos_detalle d JOIN impuestos i ON d.impuesto_componente = i.clave
																			WHERE d.impuesto = iClaveImpuesto GROUP BY d.orden ORDER BY d.orden DESC;
								DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = TRUE;

								OPEN curs2;
								read_loop2: LOOP

								FETCH curs2 INTO orden, porcentaje, impuesto_componente;

										IF done2 THEN
											LEAVE read_loop2;
										END IF;

								SET rSubTotal = rSubTotal / (1 + porcentaje / 100);
								
										BLOCK3: BEGIN
										
												DECLARE clave_componente float;
												DECLARE porcentaje_componente float;

												DECLARE done3 INT DEFAULT FALSE;
												DECLARE curs3 CURSOR FOR SELECT i.clave, i.porcentaje FROM impuestos_detalle d JOIN impuestos i ON d.impuesto_componente = i.clave
																								WHERE d.impuesto = iClaveImpuesto AND d.orden = orden;
												DECLARE CONTINUE HANDLER FOR NOT FOUND SET done3 = TRUE;

												OPEN curs3;
												read_loop3: LOOP

												FETCH curs3 INTO clave_componente, porcentaje_componente;

														IF done3 THEN
															LEAVE read_loop3;
														END IF;
														
														SET xImporte = rSubTotal * porcentaje_componente / 100;
										
														CALL OBTENER_CLAVE( 'ventas_detalle_impuestos', @out_value_clave );
														SELECT @out_value_clave INTO iClave;

														INSERT INTO ventas_detalle_impuestos (clave, venta, venta_detalle, impuesto, orden_impuesto, porcentaje, base_impuesto, importe, fecha_umov)
																										   VALUES(iClave, P_CLAVE_VENTA, iClaveVentaDetalle, clave_componente, orden, porcentaje_componente, rSubTotal, xImporte,
																														   CURRENT_TIMESTAMP);

														UPDATE claves_tablas SET clave = iClave WHERE tabla = 'ventas_detalle_impuestos';
														
														END LOOP read_loop3;
												CLOSE curs3;

										END BLOCK3;

								END LOOP read_loop2;
								CLOSE curs2;
						
						
						END BLOCK2;
						
				ELSE
						CALL OBTENER_CLAVE( 'ventas_detalle_impuestos', @out_value_clave );
						SELECT @out_value_clave INTO iClave;

						INSERT INTO ventas_detalle_impuestos (clave, venta, venta_detalle, impuesto, orden_impuesto, porcentaje, base_impuesto, importe, fecha_umov)
																		   VALUES(iClave, P_CLAVE_VENTA, iClaveVentaDetalle, iClaveImpuesto, 1, sPorcentaje, rImporteNeto, rImporteNeto - rImporteNeto / (1 + sPorcentaje / 100),
																						   CURRENT_TIMESTAMP);

						UPDATE claves_tablas SET clave = iClave WHERE tabla = 'ventas_detalle_impuestos';
				END IF;

	END LOOP read_loop1;
	CLOSE curs1;

END BLOCK1$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `NUMERO_COMPROBANTE_NUEVO` (IN `P_TIPO` VARCHAR(10), IN `P_COMPROBANTE` VARCHAR(15), IN `P_CLAVE_CAJA` INT, IN `P_CLAVE_SUCURSAL` INT, IN `P_CLAVE_SERIE_FOLIO` INT, IN `P_ES_FOLIO_DEFINITIVO` CHAR(1), OUT `O_NUMERO` INT)  BEGIN

DECLARE sCampoGlobal VARCHAR(30);
DECLARE sValor VARCHAR(30);
DECLARE sConsecutivoGlobal VARCHAR(30);
DECLARE sNombre VARCHAR(30);
DECLARE iEntidad SMALLINT;
DECLARE valor_parametro INT;
DECLARE valor_inicial INT;

SET iEntidad = P_CLAVE_SUCURSAL;

	IF ( P_CLAVE_SUCURSAL IS NULL ) THEN
		SELECT sucursal INTO iEntidad FROM cajas WHERE clave = P_CLAVE_CAJA LIMIT 1;
			IF ( iEntidad IS NULL) THEN
				SET iEntidad = 0;
			END IF;
	END IF;

		SET sConsecutivoGlobal = 'CONSECUTIVO GLOBAL';
	IF( P_TIPO = 'SALIDA' ) THEN
    	SET sCampoGlobal = CONCAT( 'VENTAS_' , P_COMPROBANTE);
	ELSEIF( P_TIPO = 'COBRANZA' ) THEN
    	SET sCampoGlobal = CONCAT( 'COBRANZA_' , P_COMPROBANTE);
	ELSE 
		SET sCampoGlobal = CONCAT( 'COMPRAS_' , P_COMPROBANTE);
	END IF;

CALL OBTENER_PARAMETRO(sCampoGlobal, sConsecutivoGlobal, @valor_parametro);

SELECT @valor_parametro INTO valor_parametro;

SET sNombre = CONCAT('NUMERO_', ( SUBSTRING(P_TIPO FROM 1 FOR 1) ) , '_' ,
P_COMPROBANTE , '_' , LPAD(iEntidad, 2, '0') );

SET valor_inicial = '0';
	IF ( P_CLAVE_SERIE_FOLIO IS NOT NULL ) THEN
		SET sNombre = CONCAT( sNombre , '_' , P_CLAVE_SERIE_FOLIO );

		SELECT CONCAT((numero_inicial-1), '') INTO valor_inicial FROM series_folios WHERE clave = P_CLAVE_SERIE_FOLIO LIMIT 1;
	END IF;

	IF( valor_parametro != sConsecutivoGlobal ) THEN
		SET sNombre = CONCAT( sNombre , '_' , P_CLAVE_CAJA );
	END IF;

CALL OBTENER_PARAMETRO(sNombre, valor_inicial , @valor_parametro2);

SELECT @valor_parametro2 INTO valor_parametro;

SET O_NUMERO = valor_parametro + 1;

	IF( P_ES_FOLIO_DEFINITIVO = 'S' )THEN
		CALL ESTABLECER_PARAMETRO( sNombre , CONCAT( '', O_NUMERO ) );
	END IF;

END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `NUMERO_MOVIMIENTO_CAJA_NUEVO` (IN `P_CAJA_TIPO` INT, IN `P_SUCURSAL` INT, IN `P_ES_FOLIO_DEFINITIVO` CHAR(1), OUT `O_NUMERO` INT)  BEGIN

DECLARE sNombre VARCHAR(30);
DECLARE valor_parametro INT;

SET sNombre = CONCAT('NUMERO_', P_CAJA_TIPO , '_' , LPAD(P_SUCURSAL, 2, '0') );

CALL OBTENER_PARAMETRO(sNombre, '0' , @valor_parametro3);

SELECT @valor_parametro3 INTO valor_parametro;

SET O_NUMERO = valor_parametro + 1;

	IF( P_ES_FOLIO_DEFINITIVO = 'S' )THEN
		CALL ESTABLECER_PARAMETRO( sNombre , CONCAT( '', O_NUMERO ) );
	END IF;

END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `OBTENER_CLAVE` (IN `P_NOMBRE_TABLA` VARCHAR(45), OUT `O_CLAVE` INT)  NO SQL
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

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `OBTENER_PREFERENCIA_USUARIO` (IN `P_CLAVE_USUARIO` INT, IN `P_CLAVE_SUCURSAL` INT, IN `P_NOMBRE` VARCHAR(45), IN `P_VALOR_DEFECTO` VARCHAR(45), OUT `O_VALOR` VARCHAR(45))  BEGIN

SELECT valor INTO O_VALOR FROM usuarios_preferencias WHERE usuario = P_CLAVE_USUARIO AND sucursal = P_CLAVE_SUCURSAL LIMIT 1;

  	IF(O_VALOR IS NULL) THEN
    INSERT INTO usuarios_preferencias (usuario, sucursal, nombre, valor) VALUES(P_CLAVE_USUARIO, P_CLAVE_SUCURSAL, P_NOMBRE, P_VALOR_DEFECTO);
    SET O_VALOR = P_VALOR_DEFECTO;
	END IF;

END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `RECALCULAR_IMPUESTOS_COMPRA` ()  BLOCK1: BEGIN

DECLARE iClaveCompra int(20);

DECLARE done1 INT DEFAULT FALSE;
DECLARE curs1 CURSOR FOR SELECT clave FROM compras ORDER BY clave ASC;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done1 = TRUE;



	OPEN curs1;
	read_loop1: LOOP

    	FETCH curs1 INTO iClaveCompra;

		IF done1 THEN
          LEAVE read_loop1;
        END IF;

		CALL IMPUESTOS_COMPRA_DETALLE(iClaveCompra);

	END LOOP read_loop1;
	CLOSE curs1;

END BLOCK1$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `RECALCULAR_IMPUESTOS_VENTA` ()  BLOCK1: BEGIN

DECLARE iClaveVenta bigint(20);

DECLARE done1 INT DEFAULT FALSE;
DECLARE curs1 CURSOR FOR SELECT clave FROM ventas ORDER BY clave ASC;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done1 = TRUE;



	OPEN curs1;
	read_loop1: LOOP

    	FETCH curs1 INTO iClaveVenta;

		IF done1 THEN
          LEAVE read_loop1;
        END IF;

		CALL IMPUESTOS_VENTA_DETALLE(iClaveVenta);

	END LOOP read_loop1;
	CLOSE curs1;

END BLOCK1$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `REGISTRAR_EXISTENCIA` (IN `P_CLAVE_COMPRA` INT, IN `P_CLAVE_ARTICULO` INT, IN `P_CANTIDAD` FLOAT, IN `P_CLAVE_ALMACEN` INT, IN `P_CLAVE_VENTA` BIGINT, IN `P_CLAVE_TRASPASO` BIGINT, IN `P_MONEDA` INT, IN `P_COSTO` FLOAT, IN `P_GASTOS` FLOAT, IN `P_LOTE` VARCHAR(20), IN `P_FECHA_CADUCIDAD` DATE, IN `P_PORCENTAJE_IMPUESTO` FLOAT, IN `P_TIPO_CAMBIO` FLOAT, IN `P_USUARIO_NOMBRE` VARCHAR(50), IN `P_OPERACION` VARCHAR(20), IN `P_DOCUMENTO` VARCHAR(35))  BEGIN

declare iTIPO SMALLINT;
DECLARE iCORRIDA_DETALLE INT;
declare iES_JUEGO char(1);
declare iNO_INVENTARIABLE char(1);
declare iTIENE_NUMERO_SERIE char(1);
declare iCOMPONENTE int(11);
declare iCANTIDAD_COMPONENTE float;
DECLARE iCOSTO_AUTOMATICO char(1);
declare iCOSTO float;
DECLARE iClave INT;

DECLARE bDone INT DEFAULT 0;
DECLARE curs CURSOR FOR SELECT articulos_juegos.componente, articulos_juegos.cantidad , articulos.tipo ,articulos.corrida_detalle FROM articulos_juegos JOIN articulos ON articulos_juegos.articulo = articulos.clave WHERE articulos_juegos.articulo = P_CLAVE_ARTICULO;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET bDone = 1;

SET @@max_sp_recursion_depth = 2 ;

SELECT CASE TIPO WHEN 1 THEN 'S' ELSE 'N' END,
      CASE TIPO WHEN 2 THEN 'S' ELSE 'N' END, costo_automatico
	  INTO iES_JUEGO, iNO_INVENTARIABLE, iCOSTO_AUTOMATICO 
FROM articulos WHERE clave = P_CLAVE_ARTICULO;

  IF (iES_JUEGO = 'S') THEN

    
	OPEN curs;
	FETCH curs INTO iCOMPONENTE, iCANTIDAD_COMPONENTE, iTIPO, iCORRIDA_DETALLE;

	WHILE bDone < 1 DO
    	SET iCOSTO = P_COSTO;
    	IF ( iCOSTO_AUTOMATICO = 'S' ) THEN

			SET iCOSTO = P_CANTIDAD * iCANTIDAD_COMPONENTE * P_COSTO * ( 1 / iCANTIDAD_COMPONENTE);
		END IF;		
		/*IF ( iTIPO = 1 AND iCORRIDA_DETALLE IS NOT NULL )THEN
			SET iCOSTO = 0;
			SET P_PORCENTAJE_IMPUESTO = 0;
		END IF;*/

		CALL REGISTRAR_EXISTENCIA( P_CLAVE_COMPRA, iCOMPONENTE, P_CANTIDAD * iCANTIDAD_COMPONENTE, P_CLAVE_ALMACEN, null , P_CLAVE_TRASPASO , P_MONEDA , iCOSTO , P_GASTOS, P_LOTE, P_FECHA_CADUCIDAD, P_PORCENTAJE_IMPUESTO , P_TIPO_CAMBIO , P_USUARIO_NOMBRE , P_OPERACION , P_DOCUMENTO );
		FETCH curs INTO iCOMPONENTE, iCANTIDAD_COMPONENTE, iTIPO, iCORRIDA_DETALLE;

	END WHILE;
	CLOSE curs;

  ELSE
		    IF(iNO_INVENTARIABLE = 'N') THEN

			CALL REGISTRAR_KARDEX( P_OPERACION , P_DOCUMENTO , P_CLAVE_ALMACEN , P_CLAVE_VENTA , P_CLAVE_COMPRA , P_CLAVE_TRASPASO , P_CLAVE_ARTICULO , P_CANTIDAD , P_COSTO , P_LOTE, P_FECHA_CADUCIDAD, P_MONEDA , P_TIPO_CAMBIO , P_USUARIO_NOMBRE );
			
			CALL OBTENER_CLAVE( 'articulos_inventario', @out_value_clave2 );
			SELECT @out_value_clave2 INTO iClave;
			
            INSERT INTO articulos_inventario (clave, articulo, almacen, moneda , cantidad, 
		costo , porcentaje_impuesto , tipo_cambio , fecha, compra , 
		movimiento , traspaso, gastos, lote, fecha_caducidad) VALUES( iClave , P_CLAVE_ARTICULO, P_CLAVE_ALMACEN, P_MONEDA , P_CANTIDAD,
        P_COSTO, P_PORCENTAJE_IMPUESTO , P_TIPO_CAMBIO , CURRENT_TIMESTAMP, P_CLAVE_COMPRA, P_CLAVE_COMPRA, P_CLAVE_TRASPASO, P_GASTOS, P_LOTE, P_FECHA_CADUCIDAD );
		
			UPDATE claves_tablas SET clave = iClave WHERE tabla = 'articulos_inventario';
			
    END IF;
  END IF;


END$$

CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `REGISTRAR_KARDEX` (IN `P_OPERACION` VARCHAR(20), IN `P_DOCUMENTO` VARCHAR(35), IN `P_ALMACEN` INT, IN `P_VENTA` BIGINT, IN `P_COMPRA` INT, IN `P_TRASPASO` BIGINT, IN `P_ARTICULO` INT, IN `P_CANTIDAD` FLOAT, IN `P_COSTO` FLOAT, IN `P_LOTE` VARCHAR(20), IN `P_FECHA_CADUCIDAD` DATE, IN `P_MONEDA` INT, IN `P_TIPO_CAMBIO` FLOAT, IN `P_USUARIO_NOMBRE` VARCHAR(45))  proc_label:BEGIN
DECLARE iTIPO SMALLINT;
DECLARE iCORRIDA_DETALLE INT;
DECLARE iES_JUEGO char(1);
DECLARE iNO_INVENTARIABLE char(1);
DECLARE iTIENE_NUMERO_SERIE char(1);
DECLARE iCOMPONENTE int(11);
DECLARE iCANTIDAD_COMPONENTE float;
DECLARE iCOSTO_AUTOMATICO char(1);
DECLARE iCOSTO float;
DECLARE i_existencia float;
DECLARE iClave INT;

DECLARE bDone INT DEFAULT 0;
DECLARE curs CURSOR FOR SELECT articulos_juegos.componente, articulos_juegos.cantidad , articulos.tipo ,articulos.corrida_detalle FROM articulos_juegos JOIN articulos ON articulos_juegos.articulo = articulos.clave WHERE articulos_juegos.articulo = P_ARTICULO;
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET bDone = 1;

SET @@max_sp_recursion_depth = 254 ;

	IF( P_CANTIDAD = 0 ) THEN
    LEAVE proc_label;
	END IF;
	
SELECT CASE TIPO WHEN 1 THEN 'S' ELSE 'N' END,
      CASE TIPO WHEN 2 THEN 'S' ELSE 'N' END,
	  costo_automatico  
	  INTO iES_JUEGO, iNO_INVENTARIABLE , iCOSTO_AUTOMATICO 
FROM articulos WHERE clave = P_ARTICULO;

  IF (iES_JUEGO = 'S') THEN

    
	OPEN curs;
	FETCH curs INTO iCOMPONENTE, iCANTIDAD_COMPONENTE, iTIPO, iCORRIDA_DETALLE;

	WHILE bDone < 1 DO
		SET iCOSTO = P_COSTO;
    	IF ( iCOSTO_AUTOMATICO = 'S' ) THEN

			SET iCOSTO = P_CANTIDAD * iCANTIDAD_COMPONENTE * P_COSTO * ( 1 / iCANTIDAD_COMPONENTE);
		END IF;		
		IF ( iTIPO = 1 AND iCORRIDA_DETALLE IS NOT NULL )THEN
			SET iCOSTO = 0;
		END IF;
		CALL REGISTRAR_KARDEX( P_OPERACION , P_DOCUMENTO , P_ALMACEN , 
						P_VENTA , P_COMPRA , P_TRASPASO , iCOMPONENTE , P_CANTIDAD * iCANTIDAD_COMPONENTE, iCOSTO , P_LOTE , P_FECHA_CADUCIDAD , P_MONEDA , P_TIPO_CAMBIO , P_USUARIO_NOMBRE );
		FETCH curs INTO iCOMPONENTE, iCANTIDAD_COMPONENTE, iTIPO, iCORRIDA_DETALLE;
	END WHILE;
	CLOSE curs;

  ELSE
		    IF(iNO_INVENTARIABLE = 'N') THEN
			SELECT COALESCE(SUM(cantidad), 0) - ( SELECT COALESCE(SUM(cantidad), 0) FROM articulos_utilizados
						WHERE articulo = P_ARTICULO AND almacen = P_ALMACEN ) FROM articulos_inventario
						WHERE articulo = P_ARTICULO AND almacen = P_ALMACEN INTO i_existencia;
			
			CALL OBTENER_CLAVE( 'articulos_kardex', @out_value_clave );
			SELECT @out_value_clave INTO iClave;

            INSERT INTO articulos_kardex (clave, fecha, operacion, documento, almacen, venta, compra, traspaso, articulo, cantidad, costo, lote, fecha_caducidad, moneda, tipo_cambio, existencia, usuario_nombre )
			VALUES ( iClave ,CURRENT_TIMESTAMP, P_OPERACION , P_DOCUMENTO , P_ALMACEN , P_VENTA , P_COMPRA , P_TRASPASO , P_ARTICULO , P_CANTIDAD , P_COSTO , P_LOTE, P_FECHA_CADUCIDAD, P_MONEDA , P_TIPO_CAMBIO , P_CANTIDAD + i_existencia , P_USUARIO_NOMBRE );
			
			UPDATE claves_tablas SET clave = iClave WHERE tabla = 'articulos_kardex';
			
			END IF;
  END IF;


END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alumnos`
--

CREATE TABLE `alumnos` (
  `id_alumno` smallint(11) NOT NULL,
  `numero_control` varchar(8) NOT NULL DEFAULT '0',
  `curp` varchar(18) NOT NULL,
  `nombre` varchar(60) NOT NULL DEFAULT '',
  `apellido_paterno` varchar(95) NOT NULL,
  `apellido_materno` varchar(95) NOT NULL,
  `id_nivel` int(11) NOT NULL,
  `id_grado` int(11) NOT NULL DEFAULT '0',
  `id_grupo` int(11) NOT NULL,
  `observaciones` varchar(50) NOT NULL DEFAULT '',
  `fecha_alta` datetime NOT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `alumnos`
--

INSERT INTO `alumnos` (`id_alumno`, `numero_control`, `curp`, `nombre`, `apellido_paterno`, `apellido_materno`, `id_nivel`, `id_grado`, `id_grupo`, `observaciones`, `fecha_alta`, `fecha_modificacion`) VALUES
(1, '10053', 'GUPJ52563689I23', 'Juan José', 'Pérez', 'Guillén', 1, 1, 2, '', '0000-00-00 00:00:00', '2020-05-17 19:10:15'),
(2, '10058', '', 'Juan', 'Pérez', 'Hernández', 1, 2, 2, '', '0000-00-00 00:00:00', '2020-05-17 19:10:12'),
(16, '10057', '', 'Andrés', 'Velasco', 'Gordillo', 2, 2, 2, '', '0000-00-00 00:00:00', '2020-05-24 14:06:36'),
(17, '10051', '', 'Jonathan', 'Culebro', 'Domínguez', 1, 1, 2, '', '0000-00-00 00:00:00', '2020-05-17 19:11:10'),
(18, '10052', '', 'Ana Patricia', 'Torres', 'Ventura', 2, 1, 2, '', '0000-00-00 00:00:00', '2020-05-16 15:03:54'),
(19, '10054', '', 'Javier ', 'Hernández', 'López', 1, 1, 2, '', '2020-05-02 14:03:54', '2020-05-17 19:11:00'),
(20, '10055', '', 'Guadalupe', 'Reyes', 'Abarca', 2, 1, 2, '', '2020-05-02 14:06:13', '2020-05-17 19:10:29'),
(21, '10056', 'VETA090126', 'Andrea', 'Velasco', 'Torres', 1, 1, 2, '', '2020-05-02 21:47:25', '2020-05-15 21:41:46');

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
(2, 'Ciencias Físico matemáticas', 'FS01', '0000-00-00 00:00:00', '2020-05-19 17:55:09'),
(3, 'Químico biólogos', 'QB03', '2020-05-12 16:32:55', '2020-05-19 16:33:37'),
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
(9, 3, 1, '2020-05-19 16:33:37'),
(17, 2, 1, '2020-05-19 17:55:09'),
(18, 2, 2, '2020-05-19 17:55:09'),
(21, 1, 1, '2020-05-23 23:31:02'),
(22, 1, 2, '2020-05-23 23:31:02');

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
(7, 'BL001', 'Biología', '', NULL, 3, '2020-05-21 11:22:50', '2020-05-22 03:17:01');

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
(5, 2, 2, '2020-05-22 03:36:08');

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
  `usuario` varchar(50) COLLATE latin1_spanish_ci NOT NULL,
  `sucursal` varchar(35) COLLATE latin1_spanish_ci NOT NULL,
  `caja` varchar(20) COLLATE latin1_spanish_ci NOT NULL,
  `fecha_umov` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
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
(2, '', 'Ana', 'Torres', '', '', '2020-05-02 18:40:16', '2020-05-17 19:50:02'),
(3, 'VETA090126', 'ANDREA', 'VELASCO', 'TORRES', '', '2020-05-02 22:01:38', '2020-05-03 03:01:38');

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
(9, 'PBBL012105', 'Célula (teoría celular) y Bioelementos', '2020-05-21 16:39:23', NULL, 2, NULL, 7, NULL, 2, 4, 0, 50, 'S', '2020-05-24 16:47:46');

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
(1, 9, 1, '2020-05-24 10:30:02', '2020-05-24 11:11:42', '', 2, 4, '00:41:40');

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
(151, 9, 45, 0, 4, '2020-05-21 18:18:24');

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
(7, 1, 43, 4, '2020-05-24 15:58:02'),
(8, 1, 44, 1, '2020-05-24 16:11:39'),
(9, 1, 45, 3, '2020-05-24 16:11:42');

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
(1, 1, 1, 'Único', 'PB1B', '0000-00-00 00:00:00', '2020-05-17 19:48:10'),
(2, 1, 1, 'Único', 'GR001', '2020-05-15 11:09:51', '2020-05-17 19:48:13');

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
(51, 7, 1, 10, '¿Cuál de las siguientes opciones no corresponde a una función del sodio?', 'transmisión del impulso nervioso', 'regula el volumen plasmático', 'regula la presión arterial', 'todas son correctas', 0, 0, '2020-05-23 07:39:09', '2020-05-23 12:39:09');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `nombre` char(20) NOT NULL DEFAULT '',
  `passwd` char(64) NOT NULL,
  `cargo` char(35) NOT NULL DEFAULT '',
  `es_visible` char(1) NOT NULL,
  `es_incognito` char(1) NOT NULL,
  `fecha_alta` datetime NOT NULL,
  `fecha_modificacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre`, `passwd`, `cargo`, `es_visible`, `es_incognito`, `fecha_alta`, `fecha_modificacion`) VALUES
(1, 'admin', '21232f297a57a5a743894a0e4a801fc3', 'catedratico', '', '', '2020-05-24 12:17:07', '2020-05-24 17:17:36');

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `asignaturas`
--
ALTER TABLE `asignaturas`
  MODIFY `id_asignatura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `asignaturas_niveles`
--
ALTER TABLE `asignaturas_niveles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
  MODIFY `id_examen` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `examenes_alumnos`
--
ALTER TABLE `examenes_alumnos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `examenes_preguntas`
--
ALTER TABLE `examenes_preguntas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=152;

--
-- AUTO_INCREMENT de la tabla `examenes_respuestas`
--
ALTER TABLE `examenes_respuestas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

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
  MODIFY `id_pregunta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

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
