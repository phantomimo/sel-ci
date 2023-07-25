<?php

class Preguntas_model extends CI_Model {

	public function __construct(){
		parent::__construct();
	}

	public function insertar($data) {
		$this->db->insert(TABLA_PREGUNTAS, array(
			'numero' => $data['numero'],			
			'pregunta' => $data['pregunta'],
			'opcion1' => $data['opcion1'],
			'opcion2' => $data['opcion2'],
			'opcion3' => $data['opcion3'],
			'opcion4' => $data['opcion4'],									
			'respuesta' => $data['respuesta'],			
			'valor_reactivo' => $data['valor_reactivo'],			
			'id_asignatura' => $data['id_asignatura'],		
			'fecha_alta' => OBTENER_FECHA_HORA,
			'fecha_modificacion' => OBTENER_FECHA_HORA
		));
		return $this->db->insert_id();	
	}

	public function modificar($data) {
		if($this->db
			->where('id_pregunta', $data['id_pregunta'])
			->update(TABLA_PREGUNTAS, array(
				'numero' => $data['numero'],				
				'pregunta' => $data['pregunta'],
				'opcion1' => $data['opcion1'],
				'opcion2' => $data['opcion2'],
				'opcion3' => $data['opcion3'],
				'opcion4' => $data['opcion4'],										
				'respuesta' => $data['respuesta'],	
				'valor_reactivo' => $data['valor_reactivo'],													
				'id_asignatura' => $data['id_asignatura'],				
				'fecha_modificacion' => OBTENER_FECHA_HORA,
			))) {
				if ($this->modificar_pregunta_examen($data))
					return true;
		}
	}

	public function obtener_listado($id_asignatura) {
		$sql = 'preguntas.id_asignatura = asignaturas.id_asignatura';
		isset($id_asignatura)? $sql.= ' AND asignaturas.id_asignatura = ' . $id_asignatura: '';		
		return $this->db
			->select('preguntas.id_pregunta, preguntas.numero, preguntas.pregunta, preguntas.opcion1, preguntas.opcion2, 
				preguntas.opcion3, preguntas.opcion4, preguntas.respuesta, preguntas.unidad, preguntas.id_asignatura, 
				preguntas.valor_reactivo, asignaturas.nombre AS asignatura')
			->from(TABLA_PREGUNTAS)
			->join(TABLA_ASIGNATURAS, $sql)
			->order_by('preguntas.unidad, preguntas.id_asignatura, preguntas.numero')
			->get()
			->result();		
	}

	public function obtener_datos_pregunta($id_pregunta) {
		return $this->db
			->select('preguntas.id_pregunta, preguntas.numero, preguntas.pregunta, preguntas.opcion1, preguntas.opcion2, 
				preguntas.opcion3, preguntas.opcion4, preguntas.respuesta, preguntas.unidad, preguntas.id_asignatura, 
				preguntas.valor_reactivo, asignaturas.nombre AS asignatura')
			->from(TABLA_PREGUNTAS)
			->join(TABLA_ASIGNATURAS, 'preguntas.id_asignatura = asignaturas.id_asignatura', 'LEFT')
			->where('preguntas.id_pregunta', $id_pregunta)
			->get()
			->result();			
	}

	public function obtener_preguntas_examen($id_examen) {
		return $this->db
			->select('examenes_preguntas.id_pregunta, examenes_preguntas.id_examen, examenes_preguntas.numero, preguntas.pregunta, 
			preguntas.opcion1, preguntas.opcion2, preguntas.opcion3, preguntas.opcion4, preguntas.respuesta, preguntas.unidad, 
			preguntas.id_asignatura, preguntas.valor_reactivo, asignaturas.nombre AS asignatura')
			->from(TABLA_EXAMENES_PREGUNTAS)
			->join(TABLA_PREGUNTAS, 'preguntas.id_pregunta = examenes_preguntas.id_pregunta')
			->join(TABLA_ASIGNATURAS, 'preguntas.id_asignatura = asignaturas.id_asignatura', 'LEFT')			
			->where('examenes_preguntas.id_examen = '. $id_examen)
			->order_by('preguntas.numero')
			->get()
			->result();		
	}

	public function eliminar($data) {
		if ($this->db
			->where('id_pregunta', $data['id_pregunta'])
			->delete(TABLA_PREGUNTAS)) {
				$this->calcular_total_preguntas_examen($data['id_examen']);
				return true;		
			}
	}
	
	public function obtener_nuevo_numero($id_asignatura) {		
		$result = $this->db
			->select_max('preguntas.numero', 'numero')
			->from(TABLA_PREGUNTAS)
			->where('preguntas.id_asignatura = ' . $id_asignatura)
			->get();		
			if($result->num_rows() > 0)
				return $result->row()->numero + 1;        
			else
				return 1;
		;		 
	}
	
	public function buscar_preguntas($texto) {
		$sql = 'preguntas.id_pregunta, preguntas.numero, preguntas.pregunta, preguntas.opcion1, preguntas.opcion2, 
				preguntas.opcion3, preguntas.opcion4, preguntas.respuesta, preguntas.unidad, preguntas.id_asignatura, 
				preguntas.valor_reactivo, asignaturas.nombre AS asignatura	FROM ' . TABLA_PREGUNTAS . ' LEFT JOIN ' . 
				TABLA_ASIGNATURAS . ' ON preguntas.id_asignatura = asignaturas.id_asignatura WHERE LOWER(preguntas.pregunta) 
				LIKE "%' . str_replace(' ', '%', $texto) . '%" ORDER BY preguntas.numero';
			
		return $this->db
			->select( $sql )				
			->get()
			->result();		
	}	

	public function obtener_nuevo_numero_examen_pregunta($id_examen) {		
		$result = $this->db
			->select_max('examenes_preguntas.numero', 'numero')
			->from(TABLA_EXAMENES_PREGUNTAS)
			->where('examenes_preguntas.id_examen = ' . $id_examen)
			->get();		
		if($result->num_rows() > 0)
			return $result->row()->numero + 1;        
		else
			return 1;
	}

	public function calcular_total_preguntas_examen ($id_examen) {		
		$result = $this->db
			->select('examenes_preguntas.numero')
			->from(TABLA_EXAMENES_PREGUNTAS)
			->where('examenes_preguntas.id_examen = ' . $id_examen)
			->get();		
		$total = $result->num_rows();
		
		$this->db
			->where('id_examen', $id_examen)
			->update(TABLA_EXAMENES, array(
				'total_preguntas' => $total,				
				'fecha_modificacion' => OBTENER_FECHA_HORA
			));				
	}	

	public function insertar_pregunta_examen ($data) {
		if ($this->db->insert(TABLA_EXAMENES_PREGUNTAS, array(
			'numero' =>  $data['numero'],			
			'id_pregunta' => $data['id_pregunta'],
			'id_examen' => $data['id_examen'],
			'id_seccion' => $data['id_seccion'],			
			'fecha_modificacion' => OBTENER_FECHA_HORA
		))) {
			$this->calcular_total_preguntas_examen($data['id_examen']);
			return true;					
		}
	}

	public function modificar_pregunta_examen ($data) {
		if ($this->db
			->where('id_examen', $data['id_examen'])
			->where('id_pregunta', $data['id_pregunta'])			
			->update(TABLA_EXAMENES_PREGUNTAS, array(
			'numero' =>  $data['numero'],			
			'id_seccion' => $data['id_seccion'],			
			'fecha_modificacion' => OBTENER_FECHA_HORA
		))) {
			return true;					
		}
		else	
			return false;		
	}	

	public function eliminar_pregunta_examen ($data) {
		if ($this->db
			->where('id_pregunta', $data['id_pregunta'])
			->where('id_examen', $data['id_examen'])			
			->delete(TABLA_EXAMENES_PREGUNTAS)) {
				$this->calcular_total_preguntas_examen($data['id_examen']);
				return true;		
		}
		else	
			return false;
	}	


}