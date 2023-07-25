<?php

class Docentes_model extends CI_Model {

	public function __construct(){
		parent::__construct();
	}

	public function insertar($data) {
		$this->db->insert(TABLA_DOCENTES, array(
			'nombre' => $data['nombre'],
			'apellido_paterno' => $data['apellido_paterno'],
			'apellido_materno' => $data['apellido_materno'],
			'curp' => $data['curp'],						
			'fecha_alta' => OBTENER_FECHA_HORA,
			'fecha_modificacion' => OBTENER_FECHA_HORA
		));
	}

	public function modificar($data) {
		$this->db
			->where('id_docente', $data['id_docente'])
			->update(TABLA_DOCENTES, array(
				'nombre' => $data['nombre'],
				'apellido_paterno' => $data['apellido_paterno'],
				'apellido_materno' => $data['apellido_materno'],
				'curp' => $data['curp'],						
				'fecha_modificacion' => OBTENER_FECHA_HORA,
			));
	}

	public function obtener_listado() {
		return $this->db
			->select('docentes.id_docente, docentes.nombre, docentes.apellido_paterno, docentes.apellido_materno, docentes.curp,
				CONCAT(docentes.nombre, " ", docentes.apellido_paterno, " ", docentes.apellido_materno) AS nombre_completo')
			->from(TABLA_DOCENTES)
			->order_by('docentes.nombre')
			->get()
			->result();		
	}

	public function eliminar($data) {
		$this->db
			->where('id_docente', $data['id_docente'])
			->delete(TABLA_DOCENTES);
	}

}