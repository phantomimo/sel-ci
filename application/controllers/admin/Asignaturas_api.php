<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Asignaturas_api extends CI_Controller {

	private $request;

	public function __construct(){
		parent::__construct();
		$this->load->model('areas_model');
		$this->load->model('asignaturas_model');
		$this->request = json_decode(file_get_contents('php://input'));
	}

	public function recuperar_asignaturas($id_nivel = null, $id_area = null) {
		$asignaturas = $this->asignaturas_model->obtener_listado($id_nivel, $id_area);
		echo json_encode($asignaturas);
	}	

	public function crear_asignatura() {
		$this->asignaturas_model->insertar(array(
			'clave' => $this->request->clave,
			'nombre' => $this->request->nombre,
			'descripcion' => $this->request->descripcion,
			'unidades' => $this->request->unidades,
			'id_area' => $this->request->id_area,
			'niveles' => $this->request->niveles
		));
	}

	public function modificar_asignatura() {		
		$this->asignaturas_model->modificar(array(
			'id_asignatura' => $this->request->id_asignatura,
			'clave' => $this->request->clave,
			'nombre' => $this->request->nombre,
			'descripcion' => $this->request->descripcion,
			'unidades' => $this->request->unidades,			
			'id_area' => $this->request->id_area,
			'niveles' => $this->request->niveles						
		));
	}

	public function eliminar_asignatura (){
		$this->asignaturas_model->eliminar(array(
			'id_asignatura' => $this->request->id_asignatura
		));
	}

}