<?php
defined('BASEPATH') OR exit('No direct script access allowed');

date_default_timezone_set ('America/Mexico_City');

defined('APLICACION_NOMBRE') OR define('APLICACION_NOMBRE', 'SEL-1.0');
defined('OBTENER_FECHA_HORA') OR define('OBTENER_FECHA_HORA', date('Y-m-d H:i:s'));
defined('TABLA_AREAS') OR define('TABLA_AREAS', 'areas');
defined('TABLA_ASIGNATURAS') OR define('TABLA_ASIGNATURAS', 'asignaturas');
defined('TABLA_ALUMNOS') OR define('TABLA_ALUMNOS', 'alumnos');
defined('TABLA_DOCENTES') OR define('TABLA_DOCENTES', 'docentes');
defined('TABLA_NIVELES') OR define('TABLA_NIVELES', 'niveles');
defined('TABLA_PREGUNTAS') OR define('TABLA_PREGUNTAS', 'preguntas');
defined('TABLA_EXAMENES') OR define('TABLA_EXAMENES', 'examenes');
defined('TABLA_GRADOS') OR define('TABLA_GRADOS', 'grados');
defined('TABLA_GRUPOS') OR define('TABLA_GRUPOS', 'grupos');
defined('TABLA_EXAMENES_PREGUNTAS') OR define('TABLA_EXAMENES_PREGUNTAS', 'examenes_preguntas');
defined('TABLA_AREAS_NIVELES') OR define('TABLA_AREAS_NIVELES', 'areas_niveles');
defined('TABLA_ASIGNATURAS_NIVELES') OR define('TABLA_ASIGNATURAS_NIVELES', 'asignaturas_niveles');
defined('TABLA_USUARIOS') OR define('TABLA_USUARIOS', 'usuarios');
defined('TABLA_EXAMENES_ALUMNOS') OR define('TABLA_EXAMENES_ALUMNOS', 'examenes_alumnos');
defined('TABLA_EXAMENES_RESPUESTAS') OR define('TABLA_EXAMENES_RESPUESTAS', 'examenes_respuestas');

defined('VALOR_SI') OR define('VALOR_SI', 'S');
defined('VALOR_NO') OR define('VALOR_NO', 'N');

defined('ACCION_AGREGAR') OR define('ACCION_AGREGAR', 'agregar');
defined('ACCION_EDITAR') OR define( 'ACCION_EDITAR' , 'editar');
defined('ACCION_ELIMINAR') OR define( 'ACCION_ELIMINAR' , 'eliminar');
defined('ACCION_CANCELAR') OR define( 'ACCION_CANCELAR' , 'cancelar' );
defined('ACCION_CONFIRMAR') OR define( 'ACCION_CONFIRMAR' , 'confirmar' );
defined('ACCION_RESPALDAR') OR define( 'ACCION_RESPALDAR' , 'respaldar' );
defined('ACCION_VERIFICAR') OR define( 'ACCION_VERIFICAR' , 'verificar' );
defined('ACCION_DETALLE') OR define( 'ACCION_DETALLE' , 'detalle' );
defined('ACCION_CONSULTAR') OR define( 'ACCION_CONSULTAR' , 'consultar' );
defined('ACCION_FINALIZAR') OR define( 'ACCION_FINALIZAR', 'finalizar' );
defined('ACCION_INICIAR') OR define( 'ACCION_INICIAR' , 'iniciar' );
defined('ACCION_ENVIAR') OR define( 'ACCION_ENVIAR' , 'enviar' );
defined('ACCION_SALIR') OR define( 'ACCION_SALIR' , 'salir' );

defined('ERROR_AUTENTICACION') OR define( 'ERROR_AUTENTICACION' , 'error de autenticación');
