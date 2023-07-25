<?php

class Grupos_model extends CI_Model {

	public function __construct(){
		parent::__construct();
	}

	public function obtener_listado ($id_grado) {
		$sql = 'grupos.id_grado = grados.id_grado';
		isset($id_grado)? $sql .= ' AND grupos.id_grado = ' . $id_grado: '';		
		return $this->db
			->select('grupos.id_grupo, grupos.id_grado, grupos.id_nivel, grupos.nombre, 
				grupos.clave, grados.nombre AS grado, niveles.nombre AS nivel')
			->from(TABLA_GRUPOS)
			->join(TABLA_NIVELES, 'grupos.id_nivel = niveles.id_nivel', 'LEFT')										
			->join(TABLA_GRADOS, $sql, 'LEFT')							
			->get()
			->result();
	}

	public function insertar($data) {
		$this->db->insert(TABLA_GRUPOS, array(
			'nombre' => $data['nombre'],
			'clave' => $data['clave'],			
			'id_nivel' => $data['id_nivel'],
			'id_grado' => $data['id_grado'],			
			'fecha_alta' => OBTENER_FECHA_HORA,
			'fecha_modificacion' => OBTENER_FECHA_HORA
		));
	}

	public function modificar($data) {
		$this->db
			->where('id_grupo', $data['id_grupo'])
			->update(TABLA_GRUPOS, array(
				'nombre' => $data['nombre'],	
				'clave' => $data['clave'],	
				'id_nivel' => $data['id_nivel'],				
				'id_grado' => $data['id_grado'],							
				'fecha_modificacion' => OBTENER_FECHA_HORA,
			));
	}	

	public function eliminar($data) {
		$this->db
			->where('id_grupo', $data['id_grupo'])
			->delete(TABLA_GRUPOS);
	}	
		
}