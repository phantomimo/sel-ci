<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Examenes extends CI_Controller {

	public function __construct(){
		parent::__construct();
		$this->load->library('autenticacion');					
	}

	public function index(){
		if( $this->autenticacion->registrado() ) {		
			$this->load->view('admin/examenes');
		}		
		else {
			$this->load->view('login_admin');
		}			
	}

	public function editar($id_examen){
		if( $this->autenticacion->registrado() ) {				
			$data['id_examen'] = $id_examen;
			$this->load->view('admin/examen', $data);
		}
		else {
			$this->load->view('login_admin');
		}
	}

	public function imagenes($image_path, $image) {		
		redirect(base_url() . 'imagenes/' . $image_path . '/' . $image); 
	}


}