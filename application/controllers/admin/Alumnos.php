<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Alumnos extends CI_Controller {

	public function __construct(){
		parent::__construct();
		$this->load->library('autenticacion');		
	}

	public function index(){
		if( $this->autenticacion->registrado() ) {		
			$this->load->view('admin/alumnos');
		}		
		else {
			$this->load->view('login_admin');
		}			
	}

	public function editar($id_alumno){
		if( $this->autenticacion->registrado() ) {			
			$data['id_alumno'] = $id_alumno;
			$this->load->view('admin/alumno', $data);
		}		
		else {
			$this->load->view('login_admin');
		}					
	}	

}