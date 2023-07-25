<?php

class Alumnos_model extends CI_Model {

	public function __construct(){
		parent::__construct();
	}

	public function insertar($data) {
		return $this->db->insert(TABLA_ALUMNOS, array(
			'nombre' => $data['nombre'],
			'apellido_paterno' => $data['apellido_paterno'],
			'apellido_materno' => $data['apellido_materno'],
			'numero_control' => $data['numero_control'],			
			'curp' => $data['curp'],						
			'id_nivel' => $data['id_nivel'],							
			'id_grado' => $data['id_grado'],
			'id_grupo' => $data['id_grupo'],
			'fecha_alta' => OBTENER_FECHA_HORA,
			'fecha_modificacion' => OBTENER_FECHA_HORA
		));
	}

	public function modificar($data) {
		return $this->db
			->where('id_alumno', $data['id_alumno'])
			->update(TABLA_ALUMNOS, array(
				'nombre' => $data['nombre'],
				'apellido_paterno' => $data['apellido_paterno'],
				'apellido_materno' => $data['apellido_materno'],
				'numero_control' => $data['numero_control'],			
				'curp' => $data['curp'],						
				'id_nivel' => $data['id_nivel'],
				'id_grado' => $data['id_grado'],
				'id_grupo' => $data['id_grupo'],				
				'fecha_modificacion' => OBTENER_FECHA_HORA,
			));
	}

	public function obtener_listado() {
		return $this->db
			->select('alumnos.id_alumno, alumnos.nombre, alumnos.apellido_paterno, alumnos.apellido_materno, alumnos.numero_control, 
				alumnos.curp, alumnos.id_nivel, alumnos.id_grado, alumnos.id_grupo, niveles.nombre AS nivel, grados.nombre AS grado, 
				grupos.nombre AS grupo')
			->from(TABLA_ALUMNOS)
			->join(TABLA_NIVELES, 'alumnos.id_nivel = niveles.id_nivel', 'LEFT')
			->join(TABLA_GRADOS, 'alumnos.id_grado = grados.id_grado', 'LEFT')			
			->join(TABLA_GRUPOS, 'alumnos.id_grupo = grupos.id_grupo', 'LEFT')						
			->order_by('alumnos.numero_control')
			->get()
			->result();		
	}

	public function eliminar($data) {
		return $this->db
			->where('id_alumno', $data['id_alumno'])
			->delete(TABLA_ALUMNOS);
	}

	public function obtener_nuevo_numero_control() {		
		$result = $this->db
			->select_max('alumnos.numero_control', 'numero')
			->from(TABLA_ALUMNOS)
			->get();		
			if($result->num_rows() > 0)
				return $result->row()->numero + 1;        
			else
				return 1;
		;		 
	}

	public function obtener_datos_alumno($id, $numero_control = null) {
		isset($numero_control)? $campo_busqueda = $numero_control : $campo_busqueda = $id;
		isset($numero_control)? $sql = 'alumnos.numero_control' : $sql = 'alumnos.id_alumno';		
		return $this->db
			->select('alumnos.id_alumno, alumnos.nombre, alumnos.apellido_paterno, alumnos.apellido_materno, alumnos.numero_control, 
				alumnos.curp, alumnos.id_nivel, alumnos.id_grado, alumnos.id_grupo, niveles.nombre AS nivel, grados.nombre AS grado, 
				grupos.nombre AS grupo')
			->from(TABLA_ALUMNOS)
			->join(TABLA_NIVELES, 'alumnos.id_nivel = niveles.id_nivel', 'LEFT')
			->join(TABLA_GRADOS, 'alumnos.id_grado = grados.id_grado', 'LEFT')			
			->join(TABLA_GRUPOS, 'alumnos.id_grupo = grupos.id_grupo', 'LEFT')						
			->where($sql, $campo_busqueda)						
			->order_by('alumnos.nombre')
			->get()
			->result();		
	}	

	public function obtener_examenes_alumno($id) {
		return $this->db
			->select('examenes_alumnos.id, alumnos.numero_control, examenes.clave, examenes.descripcion, examenes_alumnos.total_preguntas, 
				examenes_alumnos.fecha_hora_inicio, examenes_alumnos.fecha_hora_fin, examenes_alumnos.intento, examenes_alumnos.contestadas, 
				examenes_alumnos.aciertos, examenes_alumnos.tiempo_total')
			->from(TABLA_EXAMENES_ALUMNOS)
			->join(TABLA_ALUMNOS, 'alumnos.id_alumno = examenes_alumnos.id_alumno')
			->join(TABLA_EXAMENES, 'examenes.id_examen = examenes_alumnos.id_examen')
			->where('alumnos.id_alumno', $id)						
			->order_by('examenes_alumnos.fecha_hora_inicio')
			->get()
			->result();		
	}		

	public function obtener_examen_alumno($id) {
		return $this->db
			->select('examenes_alumnos.id, alumnos.numero_control, examenes.clave, examenes_alumnos.total_preguntas, examenes_alumnos.fecha_hora_inicio, 
				examenes_alumnos.fecha_hora_fin, examenes_alumnos.intento, examenes_alumnos.contestadas, examenes_alumnos.aciertos, 
				examenes_alumnos.tiempo_total')
			->from(TABLA_EXAMENES_ALUMNOS)
			->join(TABLA_ALUMNOS, 'alumnos.id_alumno = examenes_alumnos.id_alumno')
			->join(TABLA_EXAMENES, 'examenes.id_examen = examenes_alumnos.id_examen')
			->where('examenes_alumnos.id', $id)						
			->order_by('examenes_alumnos.fecha_hora_inicio')
			->get()
			->result();		
	}	


	public function obtener_respuestas_examen_alumno ($id) {			
		return 	$this->db
				->select('preguntas.id_pregunta, preguntas.numero, preguntas.pregunta, 
					CASE preguntas.respuesta 
						WHEN 1 THEN preguntas.opcion1
						WHEN 2 THEN preguntas.opcion2
						WHEN 3 THEN preguntas.opcion3
						ELSE preguntas.opcion4 
					END AS respuesta, 
					CASE examenes_respuestas.respuesta 
						WHEN 1 THEN preguntas.opcion1
						WHEN 2 THEN preguntas.opcion2
						WHEN 3 THEN preguntas.opcion3
						WHEN 4 THEN preguntas.opcion4 
						ELSE "--"  
					END AS respuesta_alumno', FALSE)
				->from(TABLA_EXAMENES_PREGUNTAS)
				->join(TABLA_PREGUNTAS, 'preguntas.id_pregunta = examenes_preguntas.id_pregunta')	
				->join(TABLA_EXAMENES, 'examenes.id_examen = examenes_preguntas.id_examen')							
				->join(TABLA_EXAMENES_ALUMNOS, 'examenes_alumnos.id_examen = examenes.id_examen')								
				->join(TABLA_EXAMENES_RESPUESTAS, 'examenes_respuestas.id_pregunta = examenes_preguntas.id_pregunta AND examenes_respuestas.id_examen_alumno = examenes_alumnos.id', 'LEFT')						
				->where('examenes_alumnos.id', $id)								
				->order_by('preguntas.numero')
				->get()
				->result();				 
	}	

}