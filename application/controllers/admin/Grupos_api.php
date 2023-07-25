<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Grupos_api extends CI_Controller {

	private $request;

	public function __construct(){
		parent::__construct();
		$this->load->model('grupos_model');
		$this->request = json_decode(file_get_contents('php://input'));
	}

	public function recuperar_grupos($id_grado = null) {
		$grupos = $this->grupos_model->obtener_listado($id_grado);	
		echo json_encode($grupos);
	}

	public function crear_grupo() {
		$this->grupos_model->insertar(array(
			'nombre' => $this->request->nombre,
			'clave' => $this->request->clave,
			'id_grado' => $this->request->id_grado,
			'id_nivel' => $this->request->id_nivel
		));
	}

	public function modificar_grupo() {
		$this->grupos_model->modificar(array(
			'nombre' => $this->request->nombre,
			'clave' => $this->request->clave,
			'id_grado' => $this->request->id_grado,			
			'id_nivel' => $this->request->id_nivel,
			'id_grupo' => $this->request->id_grupo
		));
	}

	public function eliminar_grupo (){
		$this->grupos_model->eliminar(array(
			'id_grupo' => $this->request->id_grupo
		));
	}

}