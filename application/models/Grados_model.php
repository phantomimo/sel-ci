<?php

class Grados_model extends CI_Model {

	public function __construct(){
		parent::__construct();
	}

	public function obtener_listado ($id_nivel) {
		$sql = 'grados.id_nivel = niveles.id_nivel';
		isset($id_nivel)? $sql .= ' AND grados.id_nivel = ' . $id_nivel: '';		
		return $this->db
			->select('grados.id_grado, grados.id_nivel, grados.nombre, grados.clave, niveles.nombre AS nivel')
			->from(TABLA_GRADOS)
			->join(TABLA_NIVELES, $sql)							
			->get()
			->result();
	}

	public function insertar($data) {
		$this->db->insert(TABLA_GRADOS, array(
			'nombre' => $data['nombre'],
			'clave' => $data['clave'],			
			'id_nivel' => $data['id_nivel'],			
			'fecha_alta' => OBTENER_FECHA_HORA,
			'fecha_modificacion' => OBTENER_FECHA_HORA
		));
	}

	public function modificar($data) {
		$this->db
			->where('id_grado', $data['id_grado'])
			->update(TABLA_GRADOS, array(
				'nombre' => $data['nombre'],	
				'clave' => $data['clave'],	
				'id_nivel' => $data['id_nivel'],							
				'fecha_modificacion' => OBTENER_FECHA_HORA,
			));
	}	

	public function eliminar($data) {
		$this->db
			->where('id_grado', $data['id_grado'])
			->delete(TABLA_GRADOS);
	}		
}