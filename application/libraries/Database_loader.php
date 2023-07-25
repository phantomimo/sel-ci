<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Database_loader {
        private $db;
        private $data = array();      
        
        public function __construct(Array $params) {  
                $this->data = $params;
                if (isset( $this->data['base_datos'] )) {
                    $this->db = $this->data['base_datos'];                    
                }
                else {
                    $this->db = 'default';
                }   
                $CI =& get_instance();
                $CI->db = $CI->load->database($this->db, TRUE);     
         }
}       
