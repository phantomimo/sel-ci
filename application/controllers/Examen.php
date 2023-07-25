<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Examen extends CI_Controller {

	var $examen;
	var $alumno;
	var $id_examen_alumno;
	var $respuesta_alumno;
	var $pregunta_contestada;
	var $examen_preguntas;

	public function __construct(){
		parent::__construct();
		$this->load->library('autenticacion_alumno');
		$this->load->model('examenes_model');		
		$this->load->model('preguntas_model');				
	}

	public function index(){
		$resultado = $this->session->flashdata('resultado');
		if( $this->autenticacion_alumno->registrado() ) {
			if(isset($_POST['respuesta_alumno']))
				$this->respuesta_alumno = $_POST['respuesta_alumno'];
			else	
				$this->respuesta_alumno = 0;
			if(isset($_POST['id_pregunta']))
				$this->pregunta_contestada = $_POST['id_pregunta'];		
			else	
				$this->pregunta_contestada = 0;				
			$this->load->model('alumnos_model');
			$data['numero_control'] = $this->session->userdata('alumno')['numero_control'];	//'10053'
			$data['clave_examen'] = $this->session->userdata('alumno')['clave_examen'];	//'PBBL012105'			
			//recuper los datos datos del alumno
			if ($alumno = $this->alumnos_model->obtener_datos_alumno(null, $data['numero_control'])) {
				$this->alumno = $alumno[0];
				$data['alumno_registrado'] = true;
				$data['alumno'] = $this->alumno;
				$data['fecha_hora'] = date("Y-m-d H:i:s");	

				//verificar que el examen exista
				if ($examen = $this->examenes_model->obtener_datos_examen(null, $data['clave_examen'])) {			
					$this->examen = $examen[0]; 
					$this->examen->intentos_agotados = false;
					$this->examen->tiempo_finalizado = false;

					//registrar el alumno en el examen y recuper los datos del examen
					if ($this->registrar_examen_alumno()) {
						$data['id_examen_alumno'] = $this->id_examen_alumno;						

						// si el examen tiene un timpo límite, establecer el temporizador					
						if ($this->examen->tiempo_limite > 0) {
							$this->examen->fecha_hora_limite = new DateTime();
							$this->examen->fecha_hora_limite = clone $this->examen->fecha_hora_inicio;
							$this->examen->fecha_hora_limite = $this->examen->fecha_hora_limite->modify('+'.$this->examen->tiempo_limite.' minutes');
							$this->examen->tiempo_restante = $this->examen->fecha_hora_servidor->diff($this->examen->fecha_hora_limite);				
							if (!is_null($this->examen->tiempo_restante) ) {
								$segundos = $this->examen->tiempo_restante->d * 24 * 60 * 60;
								$segundos += $this->examen->tiempo_restante->h * 60 * 60;
								$segundos += $this->examen->tiempo_restante->i * 60;
								$segundos += $this->examen->tiempo_restante->s;
							}						
							$data['segundos'] = $segundos;				
							if ($this->examen->fecha_hora_servidor >= $this->examen->fecha_hora_limite){
								$this->examen->tiempo_finalizado = true;
							}
						}				

						//registrar la última respuesta del alumno enviada por POST
						if ($this->pregunta_contestada > 0 && !$this->examen->tiempo_finalizado) {
							$this->examenes_model->guardar_respuesta($this->id_examen_alumno, $this->pregunta_contestada, $this->respuesta_alumno);
						}	

						//recuperar el total de preguntas contestadas
						$this->examen->contestadas = $this->examenes_model->obtener_total_preguntas_contestadas($this->id_examen_alumno);						

						//finalizar examen y calcular resultados	
						if ($this->examen->intentos_agotados) 
							$this->examen->prueba_finalizada = true;
						else
							$this->examen->prueba_finalizada = false;
						if ($this->examen->contestadas >= $this->examen->total_preguntas || $this->examen->tiempo_finalizado || $this->examen->prueba_finalizada)  {
							$sql = "SELECT fecha_hora_fin FROM examenes_alumnos WHERE id = '$this->id_examen_alumno'";			
							$res = $this->db->query($sql);							
							if (is_null($res->row()->fecha_hora_fin)) { 
								$sql = "UPDATE examenes_alumnos SET contestadas = 0, aciertos = 0 WHERE id ='$this->id_examen_alumno'";
								$this->db->query($sql);	   	
								if (!$this->db->query($sql)) {
									echo ("Ocurrió un error al inicializar el cálculo de los resultados: ");
								}		
								$sql = "SELECT r.id_pregunta, r.respuesta, p.respuesta AS respuesta_correcta 
										FROM examenes_respuestas r JOIN preguntas p ON r.id_pregunta = p.id_pregunta
										WHERE r.id_examen_alumno = '$this->id_examen_alumno'";
								$res = $this->db->query($sql);			
								foreach ($res->result() as $row){
									$sql = "UPDATE examenes_alumnos SET contestadas = contestadas + 1
											WHERE id = '$this->id_examen_alumno'";	
									if (!$this->db->query($sql)) {
										echo ("Ocurrió un error al calcular los resultados");
									}							
									if ($row->respuesta == $row->respuesta_correcta) {
										$sql = "UPDATE examenes_alumnos SET aciertos = aciertos + 1
												WHERE id = '$this->id_examen_alumno'";	
										if (!$this->db->query($sql)) {
											echo ("Ocurrió un error al calcular los resultados");
										}
									}
								}
								$res->free_result();						
								$sql = "UPDATE examenes_alumnos e SET e.fecha_hora_fin = now() WHERE e.id ='$this->id_examen_alumno'";						
								$this->db->query($sql);	   	
								if (!$this->db->query($sql)) {
									echo ("Ocurrió un error al calcular la hora final de los resultados");
								}		
								$sql = "UPDATE examenes_alumnos e SET e.tiempo_total = SEC_TO_TIME(TIMESTAMPDIFF(SECOND, e.fecha_hora_inicio, e.fecha_hora_fin)) 
										WHERE e.id ='$this->id_examen_alumno'";
								$this->db->query($sql);	   	
								if (!$this->db->query($sql)) {
									echo ("Ocurrió un error al calcular la hora final de los resultados");
								}			
							}
							$res->free_result();			
							$this->examen->prueba_finalizada = true;				
						}	
						else {									
							// recuperar la siguiente pregunta
							$this->examen->pregunta_actual = $this->examenes_model->obtener_siguiente_pregunta($this->examen->id_examen, $this->id_examen_alumno);
						}				
					}
					$data['examen'] = $this->examen;
				}
				else {
					$data['examen'] = null;					
				}	
			}		
			else { 
				$data['alumno_registrado'] = false;				
			}						
			// cargar la vista
			$this->load->view('examen_alumno', $data);
		}
		else {
			$data['resultado'] = $resultado;
			$this->load->view('login_alumno', $data);
		}
	}

	public function imagenes($image_path, $image) {		
		redirect(base_url() . 'imagenes/' . $image_path . '/' . $image); 
	}

	public function img($image_path, $image) {		
		redirect(base_url() . 'assets/img/' . $image_path . '/' . $image); 
	}

	private function registrar_examen_alumno($intento = 0)
	{		
		$id_alumno = $this->alumno->id_alumno;
		$id_examen = $this->examen->id_examen;		
		$sql = "SELECT COUNT(id) AS intento FROM examenes_alumnos WHERE id_examen = '$id_examen' AND id_alumno = '$id_alumno'
			AND fecha_hora_fin > 0";			
		$res = $this->db->query($sql);			
		if ($row = $res->row()) 
			$intento = $row->intento + 1;
		else
			$intento++;
		$sql = "SELECT id, fecha_hora_inicio, fecha_hora_fin, now() AS fecha_hora_servidor, intento FROM examenes_alumnos 
		WHERE id_examen = '$id_examen' AND id_alumno = '$id_alumno' AND intento = '$intento'";			
		$res = $this->db->query($sql);			
		if ($row = $res->row()) { 
			$this->id_examen_alumno = $row->id;	
			$this->examen->fecha_hora_inicio = new DateTime($row->fecha_hora_inicio);
			$this->examen->fecha_hora_servidor = new DateTime($row->fecha_hora_servidor);
			$this->examen->intento = $row->intento;
			$this->examen->fecha_hora_fin = $row->fecha_hora_fin;			
		}
		else {
			if ($intento <= $this->examen->intentos) {
				$total_preguntas = $this->examen->total_preguntas;			
				$sql = "INSERT INTO examenes_alumnos (id_examen, fecha_hora_inicio, id_alumno, total_preguntas, intento, 
				id_sesion) VALUES($id_examen, now(), $id_alumno, $total_preguntas, $intento, '". strval($this->session->session_id) . "')";
				if (!$this->db->query($sql)) {
					echo ("Ocurrió un error al registrar el alumno en el examen");
					return false;
					exit;
				}
				$this->id_examen_alumno = $this->db->insert_id();		
				$sql = "SELECT id, fecha_hora_inicio, now() AS fecha_hora_servidor FROM examenes_alumnos 
						WHERE id = '$this->id_examen_alumno'";
				$res = $this->db->query($sql);			
				if ($row = $res->row()) { 
					$this->examen->fecha_hora_inicio = new DateTime($row->fecha_hora_inicio);
					$this->examen->fecha_hora_servidor = new DateTime($row->fecha_hora_servidor);
				}					
			}
			else {
				$sql = "SELECT id, fecha_hora_inicio, fecha_hora_fin, now() AS fecha_hora_servidor, intento FROM examenes_alumnos 
				WHERE id_examen = '$id_examen' AND id_alumno = '$id_alumno' ORDER BY fecha_hora_fin DESC LIMIT 1";			
				$res = $this->db->query($sql);			
				if ($row = $res->row()) { 
					$this->id_examen_alumno = $row->id;	
					$this->examen->fecha_hora_inicio = new DateTime($row->fecha_hora_inicio);
					$this->examen->fecha_hora_servidor = new DateTime($row->fecha_hora_servidor);
					$this->examen->intento = $row->intento;
					$this->examen->fecha_hora_fin = $row->fecha_hora_fin;			
				}		
				$res->free_result();		
				$this->examen->intentos_agotados = true;
				$intento--;
			}				
		}
		$this->examen->intento = $intento;		
		$res->free_result();
		return true;		
	}	

	public function autenticar (){
		$numero_control = $this->input->post("numero_control");
		$clave_examen = $this->input->post('clave_examen');		
	
		$resultado = $this->autenticacion_alumno->autenticar($numero_control, $clave_examen);
		$this->session->set_flashdata('resultado', $resultado);
		redirect( 'examen', 'refresh' );

		// echo json_encode($resultado);
	}

	function cerrar_sesion(){
		$this->autenticacion_alumno->cerrar_sesion();
		redirect( 'examen', 'refresh' );
	}	

}