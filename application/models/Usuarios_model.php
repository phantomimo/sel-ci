<?php

class Usuarios_model extends CI_Model {

	public function __construct(){
		parent::__construct();
	}

	public function insertar($data) {
		return $this->db->insert(TABLA_USUARIOS, array(
			'nombre' => $data['nombre'],
			'nombre_entrada' => $data['nombre_entrada'],							
			'contrasenia' => $data['contrasenia'],
			'cargo' => $data['cargo'],
			'es_visible' => $data['es_visible'],			
			'fecha_alta' => OBTENER_FECHA_HORA,
			'fecha_modificacion' => OBTENER_FECHA_HORA
		));
	}

	public function modificar($data) {
		$datos = array(
			'nombre' => $data['nombre'],
			'nombre_entrada' => $data['nombre_entrada'],				
			'cargo' => $data['cargo'],
			'es_visible' => $data['es_visible'],						
			'fecha_modificacion' => OBTENER_FECHA_HORA
		);
		if ($data['modificar_contrasenia'] == VALOR_SI)
			$datos = array_merge($datos, array('contrasenia' => $data['contrasenia']));		
		return $this->db
			->where('id_usuario', $data['id_usuario'])
			->update(TABLA_USUARIOS, $datos);
	}

	public function obtener_listado() {
		return $this->db
			->select('usuarios.id_usuario, usuarios.nombre, usuarios.cargo, usuarios.es_visible, "N" AS modificar_contrasenia')
			->from(TABLA_USUARIOS)
			->order_by('usuarios.nombre')
			->get()
			->result();		
	}

	public function eliminar($data) {
		return $this->db
			->where('id_usuario', $data['id_usuario'])
			->delete(TABLA_USUARIOS);
	}

	public function obtener_datos_usuario($id) {
		return $this->db
			->select('usuarios.id_usuario, usuarios.nombre, usuarios.cargo, usuarios.es_visible')				
			->from(TABLA_USUARIOS)
			->where('usuarios.id_usuario', $id)			
			->order_by('usuarios.nombre')
			->get()
			->result();		
	}	

}