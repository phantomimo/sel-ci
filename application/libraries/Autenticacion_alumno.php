<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/**
 * autenticacion class
 * Provee las funciones para sesión de examen
 *
 */
class Autenticacion_alumno {

        public function __construct(){
            $this->CI =& get_instance();
            $this->CI->load->library('session');
            $this->CI->load->database();            
        }         

        function autenticar($numero_control, $clave_examen){
            $resultado = (object) array("acceso" => false, 
                                        "motivo" => null );
            $this->CI->load->model('login_alumno_model');            
            $result = $this->CI->login_alumno_model->autenticar($numero_control, $clave_examen);
            if ( $result != false ){
                $data = array(
                                    'id_alumno' => $result->id_alumno, 
                                    'nombre_alumno' => $result->nombre,
                                    'numero_control' => $result->numero_control,                                    
                                    'id_examen' => $result->id_examen,
                                    'clave_examen' => $result->clave_examen,
                                    'alumno_registrado' => VALOR_SI
                            );
                $this->CI->session->set_userdata('alumno', $data);
                $resultado->acceso = true;
            } else { //Clave de examen o contraseña incorrectos
                $resultado->acceso = false;
                $resultado->motivo = "Número de control y/o clave de examen incorrectos";
                return $resultado;
            }
        }

        function cerrar_sesion(){
            if( $this->registrado() ){                
                // $this->CI->load->model('bitacora_model');                            
                // $this->CI->bitacora_model->agregar_registro( "sesion" , ACCION_SALIR , "Salió ".$this->CI->session->userdata('alumno')['nombre_alumno']);          
                $this->CI->session->unset_userdata('alumno');
                if (!$this->CI->session->userdata('usuario'))
                    $this->CI->session->sess_destroy();
            }
            return true;
        }

        function registrado(){
            return $this->CI->session->userdata('alumno');
        } 

}