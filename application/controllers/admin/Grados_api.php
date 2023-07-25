<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Grados_api extends CI_Controller {

	private $request;

	public function __construct(){
		parent::__construct();
		$this->load->model('grados_model');
		$this->request = json_decode(file_get_contents('php://input'));
	}

	public function recuperar_grados($id_nivel = null) {
		$grados = $this->grados_model->obtener_listado($id_nivel);	
		echo json_encode($grados);
	}

	public function crear_grado() {
		$this->grados_model->insertar(array(
			'nombre' => $this->request->nombre,
			'clave' => $this->request->clave,			
			'id_nivel' => $this->request->id_nivel
		));
	}

	public function modificar_grado() {
		$this->grados_model->modificar(array(
			'nombre' => $this->request->nombre,
			'clave' => $this->request->clave,
			'id_nivel' => $this->request->id_nivel,			
			'id_grado' => $this->request->id_grado
		));
	}

	public function eliminar_grado (){
		$this->grados_model->eliminar(array(
			'id_grado' => $this->request->id_grado
		));
	}

}