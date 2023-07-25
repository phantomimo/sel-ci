<?php

class Niveles_model extends CI_Model {

	public function __construct(){
		parent::__construct();
	}

	public function obtener_listado () {
		return $this->db
			->select('id_nivel, nombre, clave')
			->from(TABLA_NIVELES)
			->get()
			->result();
	}

	public function insertar($data) {
		$this->db->insert(TABLA_NIVELES, array(
			'nombre' => $data['nombre'],
			'clave' => $data['clave'],			
			'fecha_alta' => OBTENER_FECHA_HORA,
			'fecha_modificacion' => OBTENER_FECHA_HORA
		));
	}

	public function modificar($data) {
		$this->db
			->where('id_nivel', $data['id_nivel'])
			->update(TABLA_NIVELES, array(
				'nombre' => $data['nombre'],	
				'clave' => $data['clave'],	
				'fecha_modificacion' => OBTENER_FECHA_HORA,
			));
	}	

	public function eliminar($data) {
		$this->db
			->where('id_nivel', $data['id_nivel'])
			->delete(TABLA_NIVELES);
	}	
}