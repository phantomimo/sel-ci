<?php
class Bitacora_model extends CI_Model{

    public function __construct() {
        parent::__construct();
        $this->load->library('session');        
    }

    public function agregar_registro( $tabla , $accion , $detalle, $comentarios = NULL ){
        $sql = "CALL AGREGAR_BITACORA ( ? , ? , ? , ? , ? , @out_value )";
        $this->db->query($sql, array($tabla , $accion , $detalle , $comentarios , $this->session->userdata('usuario')['nombre_usuario']));
        $query = $this->db->query( "SELECT @out_value AS clave");
        return $query->row()->clave;
    }

    //Cambia el formato de date de firebird mm/dd/YYYY a date de mysql YYYY/mm/dd HH:mm:ss
    public function cambiar_formato_fecha( $fecha_firebird ){
        $fecha = substr( $fecha_firebird , 6 , 4 )."/".substr( $fecha_firebird , 3 , 2 )."/".substr( $fecha_firebird , 0 , 2 );
        return $fecha;
    }

    public function buscar_bitacora( $fecha_inicio, $fecha_fin, $sucursal, $usuario, $tabla, 
                                                        $detalle, $cantidad_movimientos ){
        $sql = "SELECT * FROM ( "
                        . "SELECT clave, tabla, accion, detalle, sucursal, usuario, fecha_umov "
                        . "FROM bitacora "
                        . "WHERE ".(is_null( $fecha_inicio ) &&  is_null( $fecha_fin )?"":("fecha_umov >= '".$fecha_inicio." 00:00:00' AND fecha_umov <= '".$fecha_fin." 23:59:59' "))
                        . (is_null( $sucursal )?"":("AND sucursal = '".$sucursal."' "))
                        . (is_null( $usuario )?"":("AND usuario LIKE '%".$usuario."%' "))
                        . (is_null( $tabla )?"":("AND tabla = '".$tabla."' "))
                        . (is_null( $detalle )?"":("AND detalle LIKE '%".str_replace(" " , "%" , addslashes($detalle))."%' "))
                        . "ORDER BY fecha_umov DESC "
                        . ( is_null($cantidad_movimientos)?"":"LIMIT ".$cantidad_movimientos )
                . ") bitacora ORDER BY fecha_umov, clave ASC ";
        $query = $this->db->query($sql);
        return $query->result();
    }

    public function get_tablas_bitacora(){
        $sql = "SELECT DISTINCT tabla FROM bitacora ORDER BY tabla ASC";
        $query = $this->db->query($sql);
        return $query->result();
    }
    
    public function get_fecha_ultimo_cambio( $tabla , $fecha_ultimo_cambio ){
        $sql = "SELECT * FROM ".$tabla." WHERE fecha_umov > ?";
        $query = $this->db->query($sql, array($fecha_ultimo_cambio));
        return $query->result();
    }

    public function agregar_bitacora( $clave, $tabla, $accion, $detalle, $comentarios, 
                                                        $usuario, $sucursal, $caja, $fecha_umov = NULL ){//Usado por el sincronizador
        $sql = "INSERT INTO bitacora( clave, tabla, accion, detalle, comentarios, "
                                                    . "usuario, sucursal, caja ".((is_null($fecha_umov))?(""):(", fecha_umov")).
                                                    ") "
                                . "VALUES( ?, ?, ?, ?, ?, "
                                                . "?, ?, ? ".((is_null($fecha_umov))?(""):(",'".$fecha_umov."'"))." )";
        $this->db->query($sql , array($clave, $tabla, $accion, $detalle, $comentarios, 
                                                    $usuario, $sucursal, $caja ));
    }

    public function editar_bitacora( $clave, $tabla, $accion, $detalle, $comentarios, 
                                                        $usuario, $sucursal, $caja, $fecha_umov = NULL ){//Usado por el sincronizador
        $sql = "UPDATE bitacora SET tabla = ?, accion = ?, detalle = ?, comentarios = ?, "
                                                . "usuario = ?, sucursal = ?, caja = ? ".((is_null($fecha_umov))?(""):(", fecha_umov = '".$fecha_umov."' "))
                . "WHERE clave = ? ";
        $this->db->query($sql , array($clave, $tabla, $accion, $detalle, $comentarios, 
                                                    $usuario, $sucursal, $caja ));
    }
}