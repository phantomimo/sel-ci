<html>
<head>
	<meta charset="utf-8" />
	<title> <?php echo APLICACION_NOMBRE ?> </title>
	<script  type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/jquery-3.7.0.min.js"></script>	
	<script  type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/bootstrap.min.js"></script>	
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap-responsive.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/sel.css?1.0.1.050623" />	
	<link rel="stylesheet" href="<?php echo base_url() ?>assets/css/open-iconic-bootstrap.min.css">	
</head>
<body>
	<div class="container" id="controlador_principal">
		<menu-principal url_base="<?php echo base_url() ?>" nombre_aplicacion="<?php echo APLICACION_NOMBRE ?>"></menu-principal>		
		<h3> Bienvenido! </h3>
		<div>
			Módulo de administración.
		</div>
		<hr />
		<div>
			<p><?php echo APLICACION_NOMBRE ?> es una aplicación diseñada para la elaboración y aplicación de evaluaciones en línea.</p>
			<p>Puede iniciar capturando las áreas, niveles y asignaturas así como la plantilla de docentes y posteriormente la lista de alumnos.</p>
			<p>Una vez determinados los valores iniciales iniciaremos con la captura de los exámenes clasificados por nivel, área y asignatura. 
				Puede utilizar el editor avanzado para cargar imágenes y fórmulas matématicas con la ayuda de <a href="https://katex.org/docs/supported.html">KaTeX</a>.</p>
		</div>		
	</div>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/vue.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/notifications/vue-toasted.min.js"></script>						
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/funciones.js?1.0.2"></script>					
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/principal.js"></script>							
</body>
</html>