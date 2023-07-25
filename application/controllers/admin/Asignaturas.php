<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Asignaturas extends CI_Controller {

	public function __construct(){
		parent::__construct();
		$this->load->library('autenticacion');		
	}

	public function index(){
		if( $this->autenticacion->registrado() ) {		
			$this->load->view('admin/asignaturas');
		}		
		else {
			$this->load->view('login_admin');
		}			
	}

}