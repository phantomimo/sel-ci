<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Usuarios_api extends CI_Controller {

	private $request;

	public function __construct(){
		parent::__construct();
		$this->load->model('usuarios_model');
		$this->load->model('bitacora_model');				
		$this->request = json_decode(file_get_contents('php://input'));
	}

	public function recuperar_usuarios() {
		$usuarios = $this->usuarios_model->obtener_listado();
		echo json_encode($usuarios);
	}

	public function obtener_datos_usuario($id) {
		$usuario = $this->usuarios_model->obtener_datos_usuario($id);
		echo json_encode($usuario);
	}	

	public function crear_usuario() {
		if ($this->usuarios_model->insertar(array(
			'nombre' => $this->request->nombre,
			'nombre_entrada' => $this->request->nombre,
			'contrasenia' => $this->request->contrasenia,
			'cargo' => $this->request->cargo,
			'es_visible' => $this->request->es_visible
		))) {
			$this->bitacora_model->agregar_registro( "usuarios" , ACCION_AGREGAR , "Agregado ".$this->request->nombre );
		}
	}

	public function modificar_usuario() {
		// $this->output->enable_profiler(TRUE);
		if ($this->usuarios_model->modificar(array(
			'id_usuario' => $this->request->id_usuario,
			'nombre' => $this->request->nombre,
			'nombre_entrada' => $this->request->nombre,
			'contrasenia' => $this->request->contrasenia,
			'cargo' => $this->request->cargo,
			'es_visible' => $this->request->es_visible,
			'modificar_contrasenia' => $this->request->modificar_contrasenia
		))) {
			$this->bitacora_model->agregar_registro( "usuarios" , ACCION_EDITAR , "Editado ".$this->request->nombre );
		}
	}

	public function eliminar_usuario (){
		if ($this->usuarios_model->eliminar(array(
			'id_usuario' => $this->request->id_usuario
		))) {
			$this->bitacora_model->agregar_registro( "usuarios" , ACCION_ELIMINAR , "Eliminado ".$this->request->id_usuario );
		}
	}

}