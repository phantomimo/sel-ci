<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Examenes_api extends CI_Controller {

	private $request;

	public function __construct(){
		parent::__construct();
		$this->load->model('examenes_model');
		$this->load->model('bitacora_model');				
		$this->request = json_decode(file_get_contents('php://input'));
	}

	public function recuperar_examenes($id_nivel = null) {
		$examenes = $this->examenes_model->obtener_listado($id_nivel);
		echo json_encode($examenes);
	}

	public function recuperar_examenes_grado($id_grado) {
		$examenes = $this->examenes_model->obtener_examenes_grado($id_grado);
		echo json_encode($examenes);
	}

	public function recuperar_examenes_asignatura($id_asignatura, $id_nivel = null) {
		$examenes = $this->examenes_model->obtener_examenes_asignatura($id_asignatura, $id_nivel);
		echo json_encode($examenes);
	}

	public function recuperar_examen($id_examen) {
		$examen = $this->examenes_model->obtener_datos_examen($id_examen);
		echo json_encode($examen);
	}

	public function crear_examen() {
		if ($this->examenes_model->insertar(array(
			'clave' => $this->request->clave,
			'descripcion' => $this->request->descripcion,
			'id_nivel' => $this->request->id_nivel,
			'id_grado' => $this->request->id_grado,	
			'id_asignatura' => $this->request->id_asignatura,
			'unidad' => $this->request->unidad,			
			'id_docente' => $this->request->id_docente,
			'total_preguntas' => $this->request->total_preguntas,
			'tiempo_limite' => $this->request->tiempo_limite,
			'fecha_vencimiento' => $this->request->fecha_vencimiento,
			'mostrar_resultados' => $this->request->mostrar_resultados, 
			'intentos' => $this->request->intentos,
			'fecha_alta' => OBTENER_FECHA_HORA,
			'fecha_modificacion' => OBTENER_FECHA_HORA
		))) {
			$this->bitacora_model->agregar_registro( "examenes" , ACCION_AGREGAR , $this->request->clave );			
		}
	}

	public function modificar_examen() {
		if ($this->examenes_model->modificar(array(
			'id_examen' => $this->request->id_examen,			
			'clave' => $this->request->clave,
			'descripcion' => $this->request->descripcion,
			'id_nivel' => $this->request->id_nivel,
			'id_grado' => $this->request->id_grado,	
			'id_asignatura' => $this->request->id_asignatura,
			'unidad' => $this->request->unidad,			
			'id_docente' => $this->request->id_docente,
			'total_preguntas' => $this->request->total_preguntas,
			'tiempo_limite' => $this->request->tiempo_limite,
			'fecha_vencimiento' => $this->request->fecha_vencimiento,
			'mostrar_resultados' => $this->request->mostrar_resultados,
			'intentos' => $this->request->intentos,
			'fecha_modificacion' => OBTENER_FECHA_HORA				
		))) {
			$this->bitacora_model->agregar_registro( "examenes" , ACCION_EDITAR , $this->request->clave );
		}
	}

	public function eliminar_examen (){
		if ($this->examenes_model->eliminar(array(
			'id_examen' => $this->request->id_examen
		))) {
			$this->bitacora_model->agregar_registro( "examenes" , ACCION_ELIMINAR , $this->request->clave );			
		}
	}

}