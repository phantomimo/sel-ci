<?php
class Login_alumno_model extends CI_Model{

    public function __construct() {
        parent::__construct();
    }

    public function autenticar($numero_control = NULL , $clave_examen = NULL){
            if ( !is_null($numero_control) && !is_null($clave_examen)){
                $sql = "SELECT alumnos.id_alumno, alumnos.numero_control, alumnos.estatus, alumnos.nombre, alumnos.apellido_paterno, 
                    alumnos.apellido_materno, examenes.id_examen, examenes.clave AS clave_examen FROM alumnos JOIN examenes 
                    ON examenes.clave = ? AND alumnos.numero_control = ? LIMIT 1";
                $query = $this->db->query($sql, array($clave_examen, $numero_control));
                    if($query->num_rows() > 0){
                        return $query->row();
                    }else{
                        return false;
                    }
            }
    }

}