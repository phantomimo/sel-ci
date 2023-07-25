<?php

class Asignaturas_model extends CI_Model {

	public function __construct(){
		parent::__construct();
	}

	public function insertar($data) {
		$this->db->insert(TABLA_ASIGNATURAS, array(
			'nombre' => $data['nombre'],
			'clave' => $data['clave'],
			'descripcion' => $data['descripcion'],
			'unidades' => $data['unidades'],
			'id_area' => $data['id_area'],																	
			'fecha_alta' => OBTENER_FECHA_HORA,
			'fecha_modificacion' => OBTENER_FECHA_HORA
		));
		$this->actualizar_asignatura_niveles($this->db->insert_id(), $data['niveles']);		
	}

	public function modificar($data) {		
		$this->db
			->where('id_asignatura', $data['id_asignatura'])
			->update(TABLA_ASIGNATURAS, array(
				'nombre' => $data['nombre'],
				'clave' => $data['clave'],				
				'descripcion' => $data['descripcion'],
				'unidades' => $data['unidades'],
				'id_area' => $data['id_area'],											
				'fecha_modificacion' => OBTENER_FECHA_HORA,
		));
		$this->actualizar_asignatura_niveles($data['id_asignatura'], $data['niveles']);				
	}

	public function obtener_listado($id_nivel, $id_area) {
		$sql1 = 'asignaturas ON areas.id_area = asignaturas.id_area';
		isset($id_area)? $sql1 .= ' AND asignaturas.id_area = ' . $id_area: '';
		$asignaturas = 	$this->db
			->select('asignaturas.id_asignatura, asignaturas.nombre, asignaturas.descripcion, asignaturas.unidades, 
					asignaturas.id_area, asignaturas.clave, areas.nombre AS area')
			->from(TABLA_ASIGNATURAS)
			->join(TABLA_AREAS, $sql1)
			->order_by('asignaturas.nombre')
			->get()
			->result();			 
			foreach ($asignaturas as $asignatura) {
				$asignatura->niveles = $this->db
				->select('asignaturas_niveles.id_nivel, niveles.nombre')
				->from(TABLA_ASIGNATURAS_NIVELES, 'areas.id_area = areas_niveles.id_area')
				->join(TABLA_NIVELES, 'asignaturas_niveles.id_nivel = niveles.id_nivel')				
				->where('asignaturas_niveles.id_asignatura', $asignatura->id_asignatura)				
				->get()
				->result();
			}
		return $asignaturas;			
	}

	public function actualizar_asignatura_niveles ($id_asignatura, $niveles) {
		$this->db
		->where('id_asignatura', $id_asignatura)
		->delete(TABLA_ASIGNATURAS_NIVELES);

		foreach ($niveles as $nivel) {
			$this->db->insert(TABLA_ASIGNATURAS_NIVELES, array(
					'id_asignatura' => $id_asignatura,
					'id_nivel' => $nivel->id_nivel,
					'fecha_modificacion' => OBTENER_FECHA_HORA
			));
		}
	}	

	public function eliminar($data) {
		$this->db
			->where('id_asignatura', $data['id_asignatura'])
			->delete(TABLA_ASIGNATURAS);
	}

}