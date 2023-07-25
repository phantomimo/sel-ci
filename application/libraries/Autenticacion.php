<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/**
 * autenticacion class
 * Provee las funciones para login y sesión de usuario
 *
 */
class Autenticacion {

        public function __construct(){
            $this->CI =& get_instance();
            $this->CI->load->library('session');
        }            

        function autenticar($usuario, $contrasenia){
            $resultado = (object) array("resultado" => false, 
                                        "motivo" => null );

            $this->CI->load->model('login_model');
            $this->CI->load->model('bitacora_model');

            $result = $this->CI->login_model->autenticar($usuario,$contrasenia);
            if ( $result != false ){//Usuario y contraseña correctos
                $data = array(
                                'id_usuario' => $result->id_usuario, 
                                'nombre_usuario' => $result->nombre,
                                'perfil_usuario' => $result->perfil,                                    
                                "es_visible" => $result->es_visible,
                                "es_incognito" => $result->es_incognito
                            );
                $this->CI->session->set_userdata('usuario',$data);
                // $permisos = $this->obtener_permisos();
            //    if ( count( $permisos ) > 0 ){//Tiene permisos para entrar a la nube                          
            //     }else{//No tiene permisos para entrar a la nube
            //         $resultado->resultado = false;
            //         $resultado->motivo = "Acceso denegado";
            //         return $resultado;
            //     }
                if ( $this->CI->session->userdata('usuario')['es_visible'] == VALOR_SI && $this->CI->session->userdata('usuario')['es_incognito'] == VALOR_NO ){
                    $this->CI->load->model('bitacora_model');
                    $this->CI->bitacora_model->agregar_registro( "sesion" , ACCION_INICIAR , "Ingresó ".$this->CI->session->userdata('usuario')['nombre_usuario']);
                }
                
            } else {//Usuario y contraseña incorrectos
                $resultado->resultado = false;
                $resultado->motivo = "Usuario y/o contraseña inválido";
                return $resultado;
            }
        }

        function cerrar_sesion(){
            if( $this->registrado() ){
                if ( $this->CI->session->userdata('usuario')['es_visible'] == VALOR_SI && $this->CI->session->userdata('usuario')['es_incognito'] == VALOR_NO ){
                    $this->CI->load->model('bitacora_model');
                    $this->CI->bitacora_model->agregar_registro( "sesion" , ACCION_SALIR , "Salió ".$this->CI->session->userdata('usuario')['nombre_usuario']);
                }
                $this->CI->session->unset_userdata('usuario');
                if (!$this->CI->session->userdata('alumno'))                
                    $this->CI->session->sess_destroy();
            }
            return true;
        }

        function registrado(){
            return $this->CI->session->userdata('usuario');
        } 

        function obtener_permisos($ventana = NULL){
            $this->CI->load->model('/catalogos/perfiles_model');
            $permisos = array();
            $result = $this->CI->perfiles_model->get_permisos_ventana( $this->CI->session->userdata('usuario')['perfil_usuario'] , $ventana );
                    for ( $x = 0 ; $x < count($result) ;$x++){
                            $permisos[] = $result[$x]->nombre_accion;
                    }
            return $permisos;
        }
}