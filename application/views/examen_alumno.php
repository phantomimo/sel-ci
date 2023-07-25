<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	<title> Módulo de Examen - <?php echo APLICACION_NOMBRE ?></title>
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/sel.css?1.0.1.110620" />		
    <link rel="stylesheet" href="<?php echo base_url() ?>assets/editor/css/katex.min.css">	
    <meta http-equiv="Expires" content="0" />
	<meta http-equiv="Pragma" content="no-cache" />		
</head>
<body>
	<div class="container" id="controlador_examen">
		<div style="padding: 10px; ">
			<img style="float: right;" src="<?php base_url() ?>assets/img/logo_instituto_montebello_med2.jpg">
			<h1>Instituto Educativo Montebello</h1>			
			<h3>Módulo de examen</h3>							
	<?php
	if ($alumno_registrado) { 	
			if (!$examen) { ?>
				<a href=index.php>Examen no registrado</a>
			<?php exit; 
			}	?>
			<table class="table" style="margin-bottom: 0;">
			<tr>
				<td style="width: 50%;">
					<b>Alumno:   </b><?php echo $alumno->nombre . " " . $alumno->apellido_paterno . " " . $alumno->apellido_materno ?><br>
					<b>Materia:  </b><?php echo $examen->asignatura ?><br>
				</td>
				<td>
					<b>Inicio: </b><?php echo $examen->fecha_hora_inicio->format('d/m/Y H:i:s') ?><br>
					<b>Docente: </b><?php echo $examen->docente . " " . $examen->docente_apellido_paterno ?><br>
				</td>
			</tr>
			<tr>
				<td style="width: 50%;">
					<b>Clave de examen:   </b><?php echo $clave_examen ?>
				</td>
				<td>
					<b>Intento:   </b><?php echo $examen->intento ?>				
				</td>
			</tr>			
		<?php			
		if ($examen->tiempo_limite > 0) {
			if ($examen->tiempo_finalizado) { ?>
				<tr>
					<td colspan="2" class="text-center bg-info text-white">
			<b><?php if ($examen->prueba_finalizada) { ?> Prueba finalizada! <?php } else { ?> ¡El tiempo ha finalizado! <?php } ?></b></td>				
				</tr>				 
	<?php  	}
			else { ?>
				<input type="hidden" v-bind:value="<?php echo "segundosTotales = ".$segundos ?>">					
				<tr>
					<td><b>Tiempo límite: </b><?php echo $examen->tiempo_limite ?><span> min.<span></td>				
					<td>
						<div id="timer" ref="timer" v-cloak>
							<div class="clock-wrapper">
								<b>Tiempo restante:</b>								
								<span ref="hours" v-bind:class="{ red: runningOut }">{{ horas }}</span>
								<span class="dots" v-bind:class="{ red: runningOut }">:</span>
								<span ref="minutes" v-bind:class="{ red: runningOut }">{{ minutos }}</span>
								<span class="dots" v-bind:class="{ red: runningOut }">:</span>
								<span ref="seconds" v-bind:class="{ red: runningOut }">{{ segundos }}</span>
							</div>
						</div>				
					</td>
				</tr>
	<?php	}	
		}		
		else { 	?>
			<tr>
				<td colspan="2" class="text-center bg-info text-white">
				<b><?php if ($examen->prueba_finalizada) { ?> Prueba finalizada! <?php } ?></b></td>				
			</tr>				 
	<?php  	}	?>
		</table>
	<?php  			
		if ($examen->prueba_finalizada) {	?>				
			<div id="resultados"> 
				<h5>Gracias por contestar la evaluación</h5>				
				<a href="<?php base_url()?>examen/cerrar_sesion" class="btn btn-primary btn-exam">Finalizar sesión</a>
				<a href="#" @click="mostrarResultados()" class="btn btn-primary btn-exam">Mostrar resultados</a></p>
				<input type="hidden" v-bind:value="pruebaFinalizada = <?php echo $examen->prueba_finalizada ?>">
			</div>
		<?php
		}
		else {
			if ($examen->pregunta_actual) {	
				$pregunta = $examen->pregunta_actual; ?>
				<div id="contenedor_pregunta" class="card">
					<form name="form_pregunta" method="post" action="<?php $_SERVER['PHP_SELF'] ?>">										
					<div class="pregunta">
						<span style="font-weight:bold;"><?php echo $pregunta->numero . " de " . $examen->total_preguntas ?>. </span> 
							<div><?php echo $pregunta->pregunta ?></div><br/><br/>
						<input type="hidden" name="id_pregunta" value="<?php echo $pregunta->id_pregunta ?>"></div>
						<div style="margin: 10px; padding:10px; font-size:large; border-bottom: 4px solid #a87c11; ">
							<div class="radio">
								<label><input type="radio" name="respuesta_alumno" value="1"> <?php echo $pregunta->opcion1 ?></label>
							</div>
							<div class="radio">
								<label><input type="radio" name="respuesta_alumno" value="2"> <?php echo $pregunta->opcion2 ?></label>
							</div>
							<div class="radio">
								<label><input type="radio" name="respuesta_alumno" value="3"> <?php echo $pregunta->opcion3 ?></label>
							</div>
							<div class="radio">
								<label><input type="radio" name="respuesta_alumno" value="4"> <?php echo $pregunta->opcion4 ?></label>
							</div>
						</div>
					<br/>
					<div style="padding: 10px;">
						<input type="hidden" name="numero_control" value="<?php echo $numero_control ?>">
						<input type="button" name="Siguiente" value="Siguiente" @click="validar()">
						<!-- <input type="reset" name="Limpiar" value="Limpiar"> -->
					</div>
					</form>
				</div>		
		<?php } 
		}	?>

			<input type="hidden" name="id_examen" v-bind:value="id_examen = <?php echo $examen->id_examen ?>">								
			<input type="hidden" name="id_examen_alumno" v-bind:value="id_examen_alumno = <?php echo $id_examen_alumno ?>">	

<?php }	else { ?>
		<div><a href="index.php">Alumno No registrado</a></div>
<?php } ?>
	</div>	
		<div id="resultados" v-if="resultados" class="container" v-cloak>
			<div class="row">
				<div class="col-md-12">
					<h5 class="mt-5 font-weight-bold text-center">Resultados</h5>
				</div>
			</div>
			<div class="row mt-3 pt-3" style="background-color: #eeeeee">
				<div class="col-md-12">
					<div class="card-group">
						<div class="card mb-4">
							<div class="card-body">
								<h6 class="card-title text-center">Clave examen</h6>									
								<p class="card-text blue-text text-center"><span class="ml-2" style="font-size: 20px;">{{ examen.clave }}</span>
									<?php if($examen->intento > 1){ ?><br/>Intento: {{examen.intento}} <?php } ?></p>
							</div>
						</div>
						<div class="card mb-4">
							<div class="card-body">
								<h6 class="card-title text-center">Inicio</h6>									
								<p class="card-text blue-text text-center">
									<span class="ml-2" style="font-size: 20px;">{{ examen.fecha_hora_inicio }}</span>
									<!-- <span class="ml-2" style="font-size: 20px;"> Total: {{ examen.tiempo_total }}</span> -->
								</p>								
							</div>
						</div>
						<div class="card mb-4">
							<div class="card-body">
								<h6 class="card-title text-center">Fin</h6>									
								<p class="card-text blue-text text-center"><span class="ml-2" style="font-size: 20px;">{{ examen.fecha_hora_fin }}</span></p>
							</div>
						</div>		
						<div class="card mb-4">
							<div class="card-body">
								<h6 class="card-title text-center">Total preguntas</h6>									
								<p class="card-text blue-text text-center"><span class="ml-2" style="font-size: 30px;">{{ examen.total_preguntas }}</span></p>
							</div>
						</div>	
						<div class="card mb-4">
							<div class="card-body">
								<h6 class="card-title text-center">Contestadas</h6>									
								<p class="card-text blue-text text-center"><span class="ml-2" style="font-size: 30px;">{{ examen.contestadas }}</span></p>
							</div>
						</div>						
						<div class="card mb-4">
							<div class="card-body">
								<h6 class="card-title text-center">Total aciertos</h6>									
								<p class="card-text blue-text text-center"><span class="ml-2" style="font-size: 30px;">{{ examen.aciertos }}</span></p>
							</div>
						</div>																		
					</div>
				</div>
			</div>													
		</div>
	</div>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/editor/js/katex.min.js"></script>	
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/vue.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/vue-resource.min.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/notifications/vue-toasted.min.js"></script>												
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/examen_alumno.js?1.0.1"></script>	
	
</body>
</html> 