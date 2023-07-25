<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Areas_api extends CI_Controller {

	private $request;

	public function __construct(){
		parent::__construct();
		$this->load->model('areas_model');
		$this->request = json_decode(file_get_contents('php://input'));
	}

	public function recuperar_areas($id_nivel = null) {
		$areas = $this->areas_model->obtener_listado($id_nivel);
		echo json_encode($areas);
	}	

	public function crear_area() {
		$this->areas_model->insertar(array(
			'nombre' => $this->request->nombre,
			'clave' => $this->request->clave,
		));
	}

	public function modificar_area() {
		$this->areas_model->modificar(array(
			'nombre' => $this->request->nombre,
			'clave' => $this->request->clave,
			'niveles' => $this->request->niveles,			
			'id_area' => $this->request->id_area
		));
	}

	public function eliminar_area (){
		$this->areas_model->eliminar(array(
			'id_area' => $this->request->id_area
		));
	}

}