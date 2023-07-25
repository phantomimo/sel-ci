<?php

class Areas_model extends CI_Model {

	public function __construct(){
		parent::__construct();
	}

	public function obtener_listado ($id_nivel) {
		$sql = 'areas_niveles.id_nivel = niveles.id_nivel';
		isset($id_nivel)? $sql .= ' AND areas_niveles.id_nivel = ' . $id_nivel: '';		
		$areas = $this->db
			->select('areas.id_area, areas.nombre, areas.clave')
			->from(TABLA_AREAS)
			->get()
			->result();
			foreach ($areas as $area) {
				$area->niveles = $this->db
				->select('areas_niveles.id_nivel, niveles.nombre')
				->from(TABLA_AREAS)
				->join(TABLA_AREAS_NIVELES, 'areas.id_area = areas_niveles.id_area')
				->join(TABLA_NIVELES, $sql)				
				->where('areas.id_area', $area->id_area)				
				->get()
				->result();
			}
		return $areas;			
	}

	public function insertar($data) {
		$this->db->insert(TABLA_AREAS, array(
			'nombre' => $data['nombre'],
			'clave' => $data['clave'],			
			'fecha_alta' => OBTENER_FECHA_HORA,
			'fecha_modificacion' => OBTENER_FECHA_HORA
		));
		$this->actualizar_area_niveles($this->db->insert_id(), $data['niveles']);
	}

	public function modificar($data) {
		$this->db
			->where('id_area', $data['id_area'])
			->update(TABLA_AREAS, array(
				'nombre' => $data['nombre'],	
				'clave' => $data['clave'],	
				'fecha_modificacion' => OBTENER_FECHA_HORA,
			));
		$this->actualizar_area_niveles($data['id_area'], $data['niveles']);
	}	

	public function actualizar_area_niveles ($id_area, $niveles) {
		$this->db
		->where('id_area', $id_area)
		->delete(TABLA_AREAS_NIVELES);

		foreach ($niveles as $nivel) {
			$this->db->insert(TABLA_AREAS_NIVELES, array(
					'id_area' => $id_area,
					'id_nivel' => $nivel->id_nivel,
					'fecha_modificacion' => OBTENER_FECHA_HORA
			));
		}
	}

	public function eliminar($data) {
		$this->db
			->where('id_area', $data['id_area'])
			->delete(TABLA_AREAS);
	}		

}