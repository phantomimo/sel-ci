<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Principal extends CI_Controller {

	public function __construct(){
		parent::__construct();
		$this->load->library('autenticacion');
		$this->load->model('usuarios_model');			
	}

	public function index(){
		$resultado = $this->session->flashdata('resultado');
		if( $this->autenticacion->registrado() ) {		
			$this->load->view('admin/principal');
		}
		else {
			$data['resultado'] = $resultado;
			$this->load->view('login_admin', $data);
		}		
	}

	public function imagenes($image_path, $image) {		
		redirect(base_url() . 'imagenes/' . $image_path . '/' . $image); 
	}

	public function autenticar (){
		$usuario = $this->input->post("usuario");
		$contrasenia = $this->input->post('contrasena');		
	
		$resultado = $this->autenticacion->autenticar($usuario, md5($contrasenia));
		$this->session->set_flashdata('resultado', $resultado);
		redirect( 'admin', 'refresh' );

		// echo json_encode($resultado);
	}

	public function cerrar_sesion(){
		$this->autenticacion->cerrar_sesion();
		redirect( 'admin', 'refresh' );
	}		

}