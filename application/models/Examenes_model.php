<?php

class Examenes_model extends CI_Model {

	public function __construct(){
		parent::__construct();
		$this->load->model('preguntas_model');
	}

	public function insertar($data) {
		return $this->db->insert(TABLA_EXAMENES, array(
			'clave' => $data['clave'],
			'descripcion' => $data['descripcion'],
			'id_nivel' => $data['id_nivel'],		
			'id_grado' => $data['id_grado'],
			'id_asignatura' => $data['id_asignatura'],
			'unidad' => $data['unidad'],							
			'id_docente' => $data['id_docente'],																
			'total_preguntas' => $data['total_preguntas'],
			'tiempo_limite' => $data['tiempo_limite'],
			'fecha_vencimiento' => $data['fecha_vencimiento'],		
			'mostrar_resultados' => $data['mostrar_resultados'], 
			'intentos' => $data['intentos'],
			'fecha_alta' => OBTENER_FECHA_HORA,
			'fecha_modificacion' => OBTENER_FECHA_HORA
		));
	}

	public function modificar($data) {
		if ($this->db
			->where('id_examen', $data['id_examen'])
			->update(TABLA_EXAMENES, array(
				'clave' => $data['clave'],
				'descripcion' => $data['descripcion'],
				'id_nivel' => $data['id_nivel'],		
				'id_grado' => $data['id_grado'],
				'id_asignatura' => $data['id_asignatura'],
				'unidad' => $data['unidad'],				
				'id_docente' => $data['id_docente'],																
				'total_preguntas' => $data['total_preguntas'],
				'tiempo_limite' => $data['tiempo_limite'],
				'fecha_vencimiento' => $data['fecha_vencimiento'],			
				'mostrar_resultados' => $data['mostrar_resultados'], 				
				'intentos' => $data['intentos'],				
				'fecha_modificacion' => OBTENER_FECHA_HORA
			))) {
			$this->preguntas_model->calcular_total_preguntas_examen($data['id_examen']);			
			return true;
		}
	}

	public function obtener_listado($id_asignatura) {
		$sql = 'examenes.id_asignatura = asignaturas.id_asignatura';
		isset($id_asignatura)? $sql .= ' AND examenes.id_asignatura = ' . $id_asignatura: '';
		return 	$this->db
				->select('examenes.id_examen, examenes.clave, examenes.descripcion, examenes.id_asignatura, asignaturas.nombre AS asignatura, 
					examenes.unidad, examenes.id_docente, docentes.nombre AS docente, examenes.total_preguntas, examenes.tiempo_limite, 
					examenes.fecha_vencimiento, examenes.id_nivel, niveles.nombre AS nivel, examenes.id_grado, grados.nombre AS grado,
					examenes.mostrar_resultados, examenes.intentos')
				->from(TABLA_EXAMENES)
				->join(TABLA_DOCENTES, 'examenes.id_docente = docentes.id_docente', 'LEFT')
				->join(TABLA_NIVELES, 'examenes.id_nivel = niveles.id_nivel', 'LEFT')				
				->join(TABLA_GRADOS, 'examenes.id_grado = grados.id_grado', 'LEFT')								
				->join(TABLA_ASIGNATURAS, $sql)				
				->order_by('examenes.clave')
				->get()
				->result();				 
	}

	public function obtener_examenes_grado($id_grado) {
		$sql = 'examenes.id_grado = grados.id_grado';
		isset($id_grado)? $sql .= ' AND examenes.id_grado = ' . $id_grado: '';
		return 	$this->db
				->select('examenes.id_examen, examenes.clave, examenes.descripcion, examenes.id_asignatura, asignaturas.nombre AS asignatura, 
					examenes.unidad, examenes.id_docente, docentes.nombre AS docente, examenes.total_preguntas, examenes.tiempo_limite, 
					examenes.fecha_vencimiento, examenes.id_nivel, niveles.nombre AS nivel, examenes.id_grado, grados.nombre AS grado,
					examenes.mostrar_resultados, examenes.intentos')
				->from(TABLA_EXAMENES)
				->join(TABLA_DOCENTES, 'examenes.id_docente = docentes.id_docente', 'LEFT')
				->join(TABLA_NIVELES, 'examenes.id_nivel = niveles.id_nivel', 'LEFT')				
				->join(TABLA_ASIGNATURAS, 'examenes.id_asignatura = asignaturas.id_asignatura', 'LEFT')								
				->join(TABLA_GRADOS, $sql)								
				->order_by('examenes.clave')
				->get()
				->result();		
	 
	}	

	public function obtener_examenes_asignatura($id_asignatura, $id_nivel) {
		$sql = 'examenes.id_asignatura = asignaturas.id_asignatura';
		isset($id_asignatura)? $sql .= ' AND examenes.id_asignatura = ' . $id_asignatura: '';
		$sql2 = 'examenes.id_nivel = niveles.id_nivel';		
		isset($id_nivel)? $sql2 .= ' AND examenes.id_nivel = ' . $id_nivel: '';		
		return 	$this->db
				->select('examenes.id_examen, examenes.clave, examenes.descripcion, examenes.id_asignatura, asignaturas.nombre AS asignatura, 
					examenes.unidad, examenes.id_docente, docentes.nombre AS docente, examenes.total_preguntas, examenes.tiempo_limite, 
					examenes.fecha_vencimiento, examenes.id_nivel, niveles.nombre AS nivel, examenes.id_grado, grados.nombre AS grado,
					examenes.mostrar_resultados, examenes.intentos')
				->from(TABLA_EXAMENES)
				->join(TABLA_DOCENTES, 'examenes.id_docente = docentes.id_docente', 'LEFT')
				->join(TABLA_GRADOS, 'examenes.id_grado = grados.id_grado', 'LEFT')								
				->join(TABLA_NIVELES, $sql2)								
				->join(TABLA_ASIGNATURAS, $sql)				
				->order_by('examenes.clave')
				->get()
				->result();				 
	}	

	public function obtener_datos_examen($id_examen, $clave_examen = null) {
		isset($clave_examen)? $campo_busqueda = $clave_examen : $campo_busqueda = $id_examen;
		isset($clave_examen)? $sql = 'examenes.clave' : $sql = 'examenes.id_examen';		
		return 	$this->db
				->select('examenes.id_examen, examenes.clave, examenes.descripcion, examenes.id_asignatura, asignaturas.nombre AS asignatura, 
					asignaturas.unidades, examenes.unidad, examenes.id_docente, docentes.nombre AS docente, examenes.total_preguntas, 
					examenes.tiempo_limite, examenes.fecha_vencimiento, examenes.id_nivel, niveles.nombre AS nivel, examenes.id_grado, 
					grados.nombre AS grado, examenes.mostrar_resultados, docentes.apellido_paterno AS docente_apellido_paterno,
					examenes.intentos')
				->from(TABLA_EXAMENES)
				->join(TABLA_DOCENTES, 'examenes.id_docente = docentes.id_docente', 'LEFT')
				->join(TABLA_NIVELES, 'examenes.id_nivel = niveles.id_nivel', 'LEFT')				
				->join(TABLA_GRADOS, 'examenes.id_grado = grados.id_grado', 'LEFT')								
				->join(TABLA_ASIGNATURAS, 'examenes.id_asignatura = asignaturas.id_asignatura', 'LEFT')
				->where($sql, $campo_busqueda)
				->order_by('examenes.clave')
				->get()
				->result();				 
	}	

	public function eliminar($data) {
		return $this->db
			->where('id_examen', $data['id_examen'])
			->delete(TABLA_EXAMENES);
	}

	public function guardar_respuesta($id_examen_alumno, $id_pregunta_contestada, $respuesta_alumno) {
		$sql = "SELECT id FROM examenes_respuestas WHERE id_examen_alumno = '$id_examen_alumno' 
		AND id_pregunta = '$this->pregunta_contestada'";
		$res = $this->db->query($sql);			
		if (!$res->row()){
			$sql = "INSERT INTO examenes_respuestas (id_examen_alumno, id_pregunta, respuesta) ";
			$sql.= "VALUES('$id_examen_alumno','$id_pregunta_contestada','$respuesta_alumno')";
			$this->db->query($sql);				
		}
		$res->free_result();		
	}

	public function obtener_total_preguntas_contestadas($id_examen_alumno) {
		$sql = 'SELECT COUNT(id_pregunta) AS contestadas FROM examenes_respuestas WHERE id_examen_alumno = '. $id_examen_alumno;			
		$res = $this->db->query($sql);			
		if ($row = $res->row()) { 
			return $row->contestadas;	
		}
		$res->free_result();			
	}	

	public function obtener_siguiente_pregunta($id_examen, $id_examen_alumno) {
		$sql = 'SELECT examenes_preguntas.id_pregunta, examenes_preguntas.numero, preguntas.pregunta, 
			preguntas.opcion1, preguntas.opcion2, preguntas.opcion3, preguntas.opcion3, 
			preguntas.opcion4, preguntas.respuesta FROM examenes_preguntas JOIN preguntas ON 
			preguntas.id_pregunta = examenes_preguntas.id_pregunta WHERE examenes_preguntas.id_examen = ' .
			$id_examen .' AND examenes_preguntas.id_pregunta NOT IN (SELECT id_pregunta FROM examenes_respuestas 
			WHERE id_examen_alumno = ' . $id_examen_alumno . ') ORDER BY examenes_preguntas.numero LIMIT 1';
		$res = $this->db->query($sql);
		if ($row = $res->row()) { 
			return $row;
		}	
	}		
}