<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Alumnos_api extends CI_Controller {

	private $request;

	public function __construct(){
		parent::__construct();
		$this->load->model('alumnos_model');
		$this->load->model('bitacora_model');				
		$this->request = json_decode(file_get_contents('php://input'));
	}

	public function recuperar_alumnos() {
		$alumnos = $this->alumnos_model->obtener_listado();
		echo json_encode($alumnos);
	}

	public function obtener_datos_alumno($id) {
		$alumno = $this->alumnos_model->obtener_datos_alumno($id);
		echo json_encode($alumno);
	}	

	public function obtener_nuevo_numero_control () {
		$numero = $this->alumnos_model->obtener_nuevo_numero_control();
		echo json_encode($numero);
	}

	public function obtener_examenes_alumno($id) {
		$examenes = $this->alumnos_model->obtener_examenes_alumno($id);
		echo json_encode($examenes);
	}	
	
	public function obtener_examen_alumno($id) {
		$examenes = $this->alumnos_model->obtener_examen_alumno($id);
		echo json_encode($examenes);
	}	

	public function obtener_respuestas_examen_alumno($id) {
		$examen = $this->alumnos_model->obtener_respuestas_examen_alumno($id);
		echo json_encode($examen);
	}	

	public function crear_alumno() {
		if ($this->alumnos_model->insertar(array(
			'nombre' => $this->request->nombre,
			'apellido_paterno' => $this->request->apellido_paterno,
			'apellido_materno' => $this->request->apellido_materno,			
			'numero_control' => $this->request->numero_control,			
			'curp' => $this->request->curp,						
			'id_nivel' => $this->request->id_nivel,
			'id_grado' => $this->request->id_grado,
			'id_grupo' => $this->request->id_grupo
		))) {
			$this->bitacora_model->agregar_registro( "alumnos" , ACCION_AGREGAR , $this->request->nombre );
		}
	}

	public function modificar_alumno() {
		if ($this->alumnos_model->modificar(array(
			'id_alumno' => $this->request->id_alumno,
			'nombre' => $this->request->nombre,
			'apellido_paterno' => $this->request->apellido_paterno,
			'apellido_materno' => $this->request->apellido_materno,			
			'numero_control' => $this->request->numero_control,			
			'curp' => $this->request->curp,									
			'id_nivel' => $this->request->id_nivel,
			'id_grado' => $this->request->id_grado,
			'id_grupo' => $this->request->id_grupo			
		))) {
			$this->bitacora_model->agregar_registro( "alumnos" , ACCION_EDITAR , $this->request->nombre );			
		}
	}

	public function eliminar_alumno (){
		if ($this->alumnos_model->eliminar(array(
			'id_alumno' => $this->request->id_alumno
		))) {
			$this->bitacora_model->agregar_registro( "alumnos" , ACCION_ELIMINAR , $this->request->nombre );			
		}

	}

}