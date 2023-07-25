<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Niveles_api extends CI_Controller {

	private $request;

	public function __construct(){
		parent::__construct();
		$this->load->model('niveles_model');
		$this->request = json_decode(file_get_contents('php://input'));
	}

	public function recuperar_niveles() {
		$niveles = $this->niveles_model->obtener_listado();	
		echo json_encode($niveles);
	}

	public function crear_nivel() {
		$this->niveles_model->insertar(array(
			'nombre' => $this->request->nombre,
			'clave' => $this->request->clave,
		));
	}

	public function modificar_nivel() {
		$this->niveles_model->modificar(array(
			'nombre' => $this->request->nombre,
			'clave' => $this->request->clave,
			'id_nivel' => $this->request->id_nivel
		));
	}

	public function eliminar_nivel (){
		$this->niveles_model->eliminar(array(
			'id_nivel' => $this->request->id_nivel
		));
	}

}