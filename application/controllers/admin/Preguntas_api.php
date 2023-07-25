<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Preguntas_api extends CI_Controller {

	private $request;

	public function __construct(){
		parent::__construct();
		$this->load->model('preguntas_model');
		$this->load->model('bitacora_model');		
		$this->load->library('autenticacion');	
		$this->request = json_decode(file_get_contents('php://input'));
	}

	public function recuperar_preguntas ($id_asignatura = null) {
		if( $this->autenticacion->registrado() ) {
			$preguntas = $this->preguntas_model->obtener_listado($id_asignatura);
			echo json_encode($preguntas);
		}
		else
			echo json_encode(ERROR_AUTENTICACION);		
	}

	public function recuperar_preguntas_examen ($id_examen) {
		if( $this->autenticacion->registrado() ) {
			$preguntas = $this->preguntas_model->obtener_preguntas_examen($id_examen);
			echo json_encode($preguntas);
		}
		else
			echo json_encode(ERROR_AUTENTICACION);
	}	

	public function recuperar_pregunta ($id_pregunta = null) {
		if( $this->autenticacion->registrado() ) {		
			$pregunta = $this->preguntas_model->obtener_datos_pregunta($id_pregunta);
			echo json_encode($pregunta);
		}
		else
			echo json_encode(ERROR_AUTENTICACION);
	}		

	public function obtener_nuevo_numero ($id_asignatura) {
		$numero = $this->preguntas_model->obtener_nuevo_numero($id_asignatura);
		echo json_encode($numero);
	}

	public function obtener_nuevo_numero_examen_pregunta ($id_examen) {
		$numero = $this->preguntas_model->obtener_nuevo_numero_examen_pregunta($id_examen);
		echo json_encode($numero);
	}	

	public function buscar_preguntas () {
		if( $this->autenticacion->registrado() ) {
			$preguntas = $this->preguntas_model->buscar_preguntas($this->request->texto_pregunta);
			echo json_encode($preguntas);
		}
		else
			echo json_encode(ERROR_AUTENTICACION);			
	}	

	public function crear_pregunta () {
		if( $this->autenticacion->registrado() ) {
			if ($res = $this->preguntas_model->insertar(array(
				// 'pregunta' => preg_replace('/u([\da-fA-F]{4})/', '&#x\1;', $this->request->pregunta),
				// 'opcion1' => preg_replace('/u([\da-fA-F]{4})/', '&#x\1;', $this->request->opcion1),
				// 'opcion2' => preg_replace('/u([\da-fA-F]{4})/', '&#x\1;', $this->request->opcion2),
				// 'opcion3' => preg_replace('/u([\da-fA-F]{4})/', '&#x\1;', $this->request->opcion3),
				// 'opcion4' => preg_replace('/u([\da-fA-F]{4})/', '&#x\1;', $this->request->opcion4),
				'pregunta' => $this->request->pregunta,
				'opcion1' => $this->request->opcion1,
				'opcion2' => $this->request->opcion2,
				'opcion3' => $this->request->opcion3,
				'opcion4' => $this->request->opcion4,

				'respuesta' => $this->request->respuesta,					
				'valor_reactivo' => $this->request->valor_reactivo,						
				'numero' => $this->request->numero,									
				'id_asignatura' => $this->request->id_asignatura			
			))) {
				$this->bitacora_model->agregar_registro( "preguntas" , ACCION_AGREGAR , substr($this->request->pregunta, 0, 35) . '...' );			
				echo json_encode($res);
			}
		}
		else
			echo json_encode(ERROR_AUTENTICACION);			
	}

	public function modificar_pregunta () {
		if( $this->autenticacion->registrado() ) {		
			if ($this->preguntas_model->modificar(array(
				'id_pregunta' => $this->request->id_pregunta,
				'id_examen' => $this->request->id_examen,				
				'numero' => $this->request->numero,			
				// 'pregunta' => preg_replace('/u([\da-fA-F]{4})/', '&#x\1;', $this->request->pregunta),
				// 'opcion1' => preg_replace('/u([\da-fA-F]{4})/', '&#x\1;', $this->request->opcion1),
				// 'opcion2' => preg_replace('/u([\da-fA-F]{4})/', '&#x\1;', $this->request->opcion2),
				// 'opcion3' => preg_replace('/u([\da-fA-F]{4})/', '&#x\1;', $this->request->opcion3),
				// 'opcion4' => preg_replace('/u([\da-fA-F]{4})/', '&#x\1;', $this->request->opcion4),
				'pregunta' => $this->request->pregunta,
				'opcion1' => $this->request->opcion1,
				'opcion2' => $this->request->opcion2,
				'opcion3' => $this->request->opcion3,
				'opcion4' => $this->request->opcion4,
				'respuesta' => $this->request->respuesta,
				'valor_reactivo' => $this->request->valor_reactivo,						
				'id_asignatura' => $this->request->id_asignatura
			))) {
				$this->bitacora_model->agregar_registro( "preguntas" , ACCION_EDITAR , substr($this->request->pregunta, 0, 35) . '...' );						
			}
		}
		else
			echo json_encode(ERROR_AUTENTICACION);			
	}

	public function eliminar_pregunta (){
		if( $this->autenticacion->registrado() ) {
			if ($this->preguntas_model->eliminar(array(
				'id_pregunta' => $this->request->id_pregunta
			))) {
				$this->bitacora_model->agregar_registro( "preguntas" , ACCION_ELIMINAR , substr($this->request->pregunta, 0, 35) . '...' );						
			}
		}
		else
			echo json_encode(ERROR_AUTENTICACION);			
	}

	public function agregar_pregunta_examen () {
		if( $this->autenticacion->registrado() ) {		
			if ($this->preguntas_model->insertar_pregunta_examen (array(
				'numero' => $this->request->numero,												
				'id_examen' => $this->request->id_examen,												
				'id_pregunta' => $this->request->id_pregunta,									
				'id_seccion' => 0			
			))) {
				$this->bitacora_model->agregar_registro( "examen_preguntas" , ACCION_AGREGAR , $this->request->id_examen . '=>' . $this->request->id_pregunta);						
			}
		}
		else
			echo json_encode(ERROR_AUTENTICACION);			
	}	

	public function eliminar_pregunta_examen (){
		if( $this->autenticacion->registrado() ) {
			if ($this->preguntas_model->eliminar_pregunta_examen (array(
				'id_pregunta' => $this->request->id_pregunta,
				'id_examen' => $this->request->id_examen			
			))) {
				$this->bitacora_model->agregar_registro( "examen_preguntas" , ACCION_ELIMINAR , $this->request->id_examen . '=>' . $this->request->id_pregunta);									
			}
		}
		else
			echo json_encode(ERROR_AUTENTICACION);			
	}

}