<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Docentes_api extends CI_Controller {

	private $request;

	public function __construct(){
		parent::__construct();
		$this->load->model('docentes_model');
		$this->request = json_decode(file_get_contents('php://input'));
	}

	public function recuperar_docentes() {
		$docentes = $this->docentes_model->obtener_listado();
		echo json_encode($docentes);
	}

	public function crear_docente() {
		$this->docentes_model->insertar(array(
			'nombre' => $this->request->nombre,
			'apellido_paterno' => $this->request->apellido_paterno,
			'apellido_materno' => $this->request->apellido_materno,			
			'curp' => $this->request->curp
		));
	}

	public function modificar_docente() {
		$this->docentes_model->modificar(array(
			'id_docente' => $this->request->id_docente,
			'nombre' => $this->request->nombre,
			'apellido_paterno' => $this->request->apellido_paterno,
			'apellido_materno' => $this->request->apellido_materno,			
			'curp' => $this->request->curp
		));
	}

	public function eliminar_docente (){
		$this->docentes_model->eliminar(array(
			'id_docente' => $this->request->id_docente
		));
	}

}