<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/*
| -------------------------------------------------------------------------
| URI ROUTING
| -------------------------------------------------------------------------
| This file lets you re-map URI requests to specific controller functions.
|
| Typically there is a one-to-one relationship between a URL string
| and its corresponding controller class/method. The segments in a
| URL normally follow this pattern:
|
|	example.com/class/method/id/
|
| In some instances, however, you may want to remap this relationship
| so that a different class/function is called than the one
| corresponding to the URL.
|
| Please see the user guide for complete details:
|
|	https://codeigniter.com/user_guide/general/routing.html
|
| -------------------------------------------------------------------------
| RESERVED ROUTES
| -------------------------------------------------------------------------
|
| There are three reserved routes:
|
|	$route['default_controller'] = 'welcome';
|
| This route indicates which controller class should be loaded if the
| URI contains no data. In the above example, the "welcome" class
| would be loaded.
|
|	$route['404_override'] = 'errors/page_missing';
|
| This route will tell the Router which controller/method to use if those
| provided in the URL cannot be matched to a valid route.
|
|	$route['translate_uri_dashes'] = FALSE;
|
| This is not exactly a route, but allows you to automatically route
| controller and method names that contain dashes. '-' isn't a valid
| class or method name character, so it requires translation.
| When you set this option to TRUE, it will replace ALL dashes in the
| controller and method URI segments.
|
| Examples:	my-controller/index	-> my_controller/index
|		my-controller/my-method	-> my_controller/my_method
*/


$route['default_controller'] = 'examen';
$route['404_override'] = '';
$route['translate_uri_dashes'] = FALSE;

$route['admin']['get'] = 'admin/principal';


$route['admin/recuperar_areas']['get'] = 'admin/areas_api/recuperar_areas';
$route['admin/recuperar_areas/(:any)']['get'] = 'admin/areas_api/recuperar_areas/$1';
$route['admin/crear_area']['post'] = 'admin/areas_api/crear_area';
$route['admin/modificar_area']['post'] = 'admin/areas_api/modificar_area';
$route['admin/eliminar_area']['post'] = 'admin/areas_api/eliminar_area';

$route['admin/recuperar_asignaturas']['get'] = 'admin/asignaturas_api/recuperar_asignaturas';
$route['admin/recuperar_asignaturas/(:any)']['get'] = 'admin/asignaturas_api/recuperar_asignaturas/$1';
$route['admin/recuperar_asignaturas/(:any)/(:any)']['get'] = 'admin/asignaturas_api/recuperar_asignaturas/$1/$2';
$route['admin/crear_asignatura']['post'] = 'admin/asignaturas_api/crear_asignatura';
$route['admin/modificar_asignatura']['post'] = 'admin/asignaturas_api/modificar_asignatura';
$route['admin/eliminar_asignatura']['post'] = 'admin/asignaturas_api/eliminar_asignatura';

$route['admin/recuperar_alumnos']['get'] = 'admin/alumnos_api/recuperar_alumnos';
$route['admin/crear_alumno']['post'] = 'admin/alumnos_api/crear_alumno';
$route['admin/modificar_alumno']['post'] = 'admin/alumnos_api/modificar_alumno';
$route['admin/eliminar_alumno']['post'] = 'admin/alumnos_api/eliminar_alumno';
$route['admin/obtener_datos_alumno/(:any)']['get'] = 'admin/alumnos_api/obtener_datos_alumno/$1';
$route['admin/obtener_nuevo_numero_control']['get'] = 'admin/alumnos_api/obtener_nuevo_numero_control';

$route['admin/recuperar_niveles']['get'] = 'admin/niveles_api/recuperar_niveles';
$route['admin/crear_nivel']['post'] = 'admin/niveles_api/crear_nivel';
$route['admin/modificar_nivel']['post'] = 'admin/niveles_api/modificar_nivel';
$route['admin/eliminar_nivel']['post'] = 'admin/niveles_api/eliminar_nivel';

$route['admin/recuperar_grados']['get'] = 'admin/grados_api/recuperar_grados';
$route['admin/recuperar_grados/(:any)']['get'] = 'admin/grados_api/recuperar_grados/$1';
$route['admin/crear_grado']['post'] = 'admin/grados_api/crear_grado';
$route['admin/modificar_grado']['post'] = 'admin/grados_api/modificar_grado';
$route['admin/eliminar_grado']['post'] = 'admin/grados_api/eliminar_grado';

$route['admin/recuperar_grupos']['get'] = 'admin/grupos_api/recuperar_grupos';
$route['admin/recuperar_grupos/(:any)']['get'] = 'admin/grupos_api/recuperar_grupos/$1';
$route['admin/crear_grupo']['post'] = 'admin/grupos_api/crear_grupo';
$route['admin/modificar_grupo']['post'] = 'admin/grupos_api/modificar_grupo';
$route['admin/eliminar_grupo']['post'] = 'admin/grupos_api/eliminar_grupo';

$route['admin/recuperar_docentes']['get'] = 'admin/docentes_api/recuperar_docentes';
$route['admin/crear_docente']['post'] = 'admin/docentes_api/crear_docente';
$route['admin/modificar_docente']['post'] = 'admin/docentes_api/modificar_docente';
$route['admin/eliminar_docente']['post'] = 'admin/docentes_api/eliminar_docente';

$route['admin/recuperar_preguntas']['get'] = 'admin/preguntas_api/recuperar_preguntas';
$route['admin/recuperar_preguntas/(:any)']['get'] = 'admin/preguntas_api/recuperar_preguntas/$1';
$route['admin/crear_pregunta']['post'] = 'admin/preguntas_api/crear_pregunta';
$route['admin/modificar_pregunta']['post'] = 'admin/preguntas_api/modificar_pregunta';
$route['admin/eliminar_pregunta']['post'] = 'admin/preguntas_api/eliminar_pregunta';
$route['admin/obtener_nuevo_numero/(:any)']['get'] = 'admin/preguntas_api/obtener_nuevo_numero/$1';

$route['admin/recuperar_examenes']['get'] = 'admin/examenes_api/recuperar_examenes';
$route['admin/recuperar_examenes_grado/(:any)']['get'] = 'admin/examenes_api/recuperar_examenes_grado/$1';
$route['admin/recuperar_examenes_asignatura/(:any)']['get'] = 'admin/examenes_api/recuperar_examenes_asignatura/$1';
$route['admin/recuperar_examenes_asignatura/(:any)/(:any)']['get'] = 'admin/examenes_api/recuperar_examenes_asignatura/$1/$2';
$route['admin/crear_examen']['post'] = 'admin/examenes_api/crear_examen';
$route['admin/modificar_examen']['post'] = 'admin/examenes_api/modificar_examen';
$route['admin/eliminar_examen']['post'] = 'admin/examenes_api/eliminar_examen';

$route['admin/examenes/recuperar_asignaturas/(:any)/(:any)']['get'] = 'admin/asignaturas_api/recuperar_asignaturas/$1/$2';
$route['admin/examenes/recuperar_areas/(:any)']['get'] = 'admin/areas_api/recuperar_areas/$1';
$route['admin/examenes/recuperar_docentes']['get'] = 'admin/docentes_api/recuperar_docentes';
$route['admin/examenes/recuperar_grados/(:any)']['get'] = 'admin/grados_api/recuperar_grados/$1';
$route['admin/examenes/recuperar_preguntas/(:any)']['get'] = 'admin/preguntas_api/recuperar_preguntas/$1';

$route['admin/examenes/imagenes/(:any)/(:any)']['get'] = 'admin/examenes/imagenes/$1/$2';
$route['admin/imagenes/(:any)/(:any)']['get'] = 'admin/principal/imagenes/$1/$2';
$route['admin/examenes/editar/imagenes/(:any)/(:any)']['get'] = 'admin/examenes/imagenes/$1/$2';

$route['admin/examenes/editar/recuperar_asignaturas/(:any)']['get'] = 'admin/asignaturas_api/recuperar_asignaturas/$1';
$route['admin/examenes/editar/recuperar_examen/(:any)']['get'] = 'admin/examenes_api/recuperar_examen/$1';
$route['admin/examenes/editar/recuperar_preguntas_examen/(:any)']['get'] = 'admin/preguntas_api/recuperar_preguntas_examen/$1';
$route['admin/examenes/editar/obtener_nuevo_numero/(:any)']['get'] = 'admin/preguntas_api/obtener_nuevo_numero/$1';
$route['admin/examenes/editar/obtener_nuevo_numero_examen_pregunta/(:any)']['get'] = 'admin/preguntas_api/obtener_nuevo_numero_examen_pregunta/$1';
$route['admin/examenes/editar/crear_pregunta']['post'] = 'admin/preguntas_api/crear_pregunta';
$route['admin/examenes/editar/modificar_pregunta']['post'] = 'admin/preguntas_api/modificar_pregunta';
$route['admin/examenes/editar/eliminar_pregunta']['post'] = 'admin/preguntas_api/eliminar_pregunta';
$route['admin/examenes/editar/eliminar_pregunta_examen']['post'] = 'admin/preguntas_api/eliminar_pregunta_examen';
$route['admin/examenes/editar/buscar_preguntas']['post'] = 'admin/preguntas_api/buscar_preguntas';
$route['admin/examenes/editar/agregar_pregunta_examen']['post'] = 'admin/preguntas_api/agregar_pregunta_examen';

$route['admin/examenes/crear_examen']['post'] = 'admin/examenes_api/crear_examen';
$route['admin/examenes/modificar_examen']['post'] = 'admin/examenes_api/modificar_examen';
$route['admin/examenes/eliminar_examen']['post'] = 'admin/examenes_api/eliminar_examen';

$route['admin/alumnos/editar/obtener_datos_alumno/(:any)']['get'] = 'admin/alumnos_api/obtener_datos_alumno/$1';
$route['admin/alumnos/editar/recuperar_niveles']['get'] = 'admin/niveles_api/recuperar_niveles';
$route['admin/alumnos/editar/recuperar_grados']['get'] = 'admin/grados_api/recuperar_grados';
$route['admin/alumnos/editar/recuperar_grados/(:any)']['get'] = 'admin/grados_api/recuperar_grados/$1';
$route['admin/alumnos/editar/recuperar_grupos']['get'] = 'admin/grupos_api/recuperar_grupos';
$route['admin/alumnos/editar/recuperar_grupos/(:any)']['get'] = 'admin/grupos_api/recuperar_grupos/$1';
$route['admin/alumnos/editar/modificar_alumno']['post'] = 'admin/alumnos_api/modificar_alumno';
$route['admin/alumnos/editar/obtener_examenes_alumno/(:any)']['get'] = 'admin/alumnos_api/obtener_examenes_alumno/$1';
$route['admin/alumnos/editar/obtener_respuestas_examen_alumno/(:any)']['get'] = 'admin/alumnos_api/obtener_respuestas_examen_alumno/$1';

$route['admin/recuperar_usuarios']['get'] = 'admin/usuarios_api/recuperar_usuarios';
$route['admin/crear_usuario']['post'] = 'admin/usuarios_api/crear_usuario';
$route['admin/modificar_usuario']['post'] = 'admin/usuarios_api/modificar_usuario';
$route['admin/eliminar_usuario']['post'] = 'admin/usuarios_api/eliminar_usuario';
$route['admin/obtener_datos_usuario/(:any)']['get'] = 'admin/usuarios_api/obtener_datos_usuario/$1';

$route['admin/autenticar']['post'] = 'admin/principal/autenticar';
$route['admin/cerrar_sesion'] = 'admin/principal/cerrar_sesion';

$route['obtener_examen_alumno/(:any)']['get'] = 'admin/alumnos_api/obtener_examen_alumno/$1';
$route['recuperar_examen/(:any)']['get'] = 'admin/examenes_api/recuperar_examen/$1';