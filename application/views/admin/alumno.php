<html>
<head>
	<meta charset="utf-8" />
	<title> <?php echo APLICACION_NOMBRE ?> - Alumno </title>
	<script  type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/jquery-3.7.0.min.js"></script>	
	<script  type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/bootstrap.min.js"></script>	
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap-responsive.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/sel.css?1.0.1.110620" />	
	<link rel="stylesheet" href="<?php echo base_url() ?>assets/css/open-iconic-bootstrap.min.css">			
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/components/vue-tabs.css" />	
    <link rel="stylesheet" href="<?php echo base_url() ?>assets/editor/css/katex.min.css">		
</head>
<body>
	<div class="container" id="controlador_alumnos" v-cloak>
		<menu-principal url_base="<?php echo base_url() ?>" nombre_aplicacion="<?php echo APLICACION_NOMBRE ?>"></menu-principal>		
		<h3> Alumno [ {{ alumno.numero_control + ' - ' + alumno.nombre  + ' ' + alumno.apellido_paterno + ' ' + alumno.apellido_materno }} ]</h3>
		<hr />
		<vue-tabs>
			<v-tab title="Datos del alumno">
				<div class="content">
					<div class="modal-body">
						<div v-if="errors.length">
							<b>Por favor, corrija el(los) siguiente(s) error(es):</b>
							<ul>
								<li v-for="error in errors">{{ error }}</li>
							</ul>
							<button class="btn btn-warning" v-on:click="inicializarErrores()">Aceptar</button>
						</div>							
						<form @submit.native.prevent="guardarAlumno(alumno)">								
							<div class="form-group">
								<label for="numeroControl">Número de control:</label>
								<input type="text" class="form-control" v-model.lazy="alumno.numero_control" id="numeroControl" placeholder="Número de control" readonly="true" />
							</div>								
							<div class="form-group">
								<label for="nombreAlumno">Nombre:</label>
								<input type="text" class="form-control" v-model.lazy="alumno.nombre" id="nombreAlumno" placeholder="Nombre del alumno" v-focus/>
							</div>
							<div class="form-group">
								<label for="apellidoPaterno">Apellido paterno:</label>
								<input type="text" class="form-control" v-model.lazy="alumno.apellido_paterno" id="apellidoPaterno" placeholder="Apellido paterno"/>
							</div>							
							<div class="form-group">
								<label for="apellidoMaterno">Apellido materno:</label>
								<input type="text" class="form-control" v-model.lazy="alumno.apellido_materno" id="apellidoMaterno" placeholder="Apellido materno"/>
							</div>	
							<div class="form-group">
								<label for="Curp">CURP:</label>
								<input type="text" class="form-control" v-model.lazy="alumno.curp" id="Curp" placeholder="CURP"/>
							</div>						
							<div class="container-fluid row">
								<div class="form-group col-md-4 col-sm-6">
									<label for="nivelAlumno">Nivel:</label>
									<select id="nivel-select-1" v-model="alumno.id_nivel" v-on:change="recuperarGrados(alumno.id_nivel)" @change="grados = []; grupos = []" class="form-control">
										<option v-for="nivel in niveles" v-bind:value="nivel.id_nivel"> {{ nivel.nombre }} </option>											
									</select>		
								</div>							
								<div class="form-group col-md-4 col-sm-6">
									<label for="gradoAlumno">Grado:</label>
									<select ref="grado" id="grado-select-1" v-model="alumno.id_grado" v-on:change="recuperarGrupos(grado.id_grado)" @change="grupos = []" class="form-control">
										<option v-for="grado in grados" v-bind:value="grado.id_grado"> {{ grado.nombre }} </option>											
									</select>		
								</div>							
								<div class="form-group col-md-4 col-sm-6">
									<label for="grupoAlumno">Grupo:</label>
									<select  ref="grupo" id="grupoAlumno" v-model="alumno.id_grupo"class="form-control" >
										<option v-for="grupo in grupos" v-bind:value="grupo.id_grupo"> {{ grupo.nombre }} </option>
									</select>								
								</div>							
							</div>																
							<div class="modal-footer">	
								<button type="submit" class="btn btn-sm btn-primary" v-on:click="guardarAlumno(alumno)"> Guardar </button>
								<button type="reset" class="btn btn-sm btn-secondary" v-on:click="cerrarVentanaEdicion()"> Cancelar </button>								
							</div>								
						</form>
					</div>
				</div>
			</v-tab>
			<v-tab title="Historial de exámenes">
				<div class="content">
					<div v-if="cargando_registros">
						Cargando registros...
					</div>				
					<table  class="table table-hover" v-if="!cargando_registros">
						<thead>
							<tr>
								<th> No. control </th>
								<th> Clave examen </th>
								<th> Inicio </th>						
								<th> Fin </th>
								<th> Intento </th>	
								<th> Preguntas </th>																				
								<th> Contestadas </th>												
								<th> Aciertos </th>																		
								<th> Tiempo total </th>																								
								<th class="operaciones-tabla"></th>
							</tr>
						</thead>
						<tbody>
							<tr v-for="examen in examenes" @click="activarFila(examen.id_examen)" :class="{ active: filaActiva == examen.id }">
								<td>{{ examen.numero_control }}</td>						
								<td>{{ examen.clave }}</td>
								<td>{{ examen.fecha_hora_inicio }}</td>
								<td>{{ (examen.fecha_hora_fin == null)?'En proceso':examen.fecha_hora_fin }}</td>						
								<td>{{ examen.intento }}</td>
								<td>{{ examen.total_preguntas }}</td>														
								<td>{{ examen.contestadas }}</td>						
								<td>{{ examen.aciertos }}</td>												
								<td>{{ examen.tiempo_total }}</td>																		
								<td class="operaciones-tabla">
									<button class="btn btn-sm" v-on:click="mostrarVentanaResultados(examen)"><span class="oi oi-eye" title="Mostrar resultados" aria-hidden="true"></span></button>
									<button class="btn btn-sm" v-on:click="editarExamenAlumno(examen)"><span class="oi oi-task" title="Autorizar intento" aria-hidden="true"></span></button>									
								</td>
							</tr>					
						</tbody>
					</table>
				</div>
			</v-tab>
			<v-tab title="Reporte de calificaciones">
				
			</v-tab>
		</vue-tabs>	

		<div v-if="modalResultados" id="modal">
			<transition name="modal">
			<div class="modal-mask">
				<div class="modal-wrapper" style="overflow-y: scroll;">
				<div class="modal-dialog modal-lg modal-dialog-scrollable" role="document">
					<div class="modal-content">
						<div class="modal-header">
							<h5 class="modal-title">[{{ examen.clave }}] {{ examen.descripcion }}</h5> 
							<button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
								<span aria-hidden="true" @click="cerrarVentanaResultados()">&times;</span>
							</button>							
						</div>
						<div class="modal-body">
							<h6 class="modal-title">Resultado del examen</h6>								
							<table class="table table-hover" v-if="!cargando_registros">
							<thead>
								<tr>
									<th class="text-left">  No. </th>
									<th class="text-left" style="width:65%"> Pregunta </th>						
									<th class="text-center" style="width:10%"> Respuesta correcta </th>
									<th class="text-center" style="width:10%"> Respuesta alumno</th>		
									<th></th>							
								</tr>
							</thead>
							<tbody>
								<tr v-for="pregunta in examen_alumno" @click="activarFila(pregunta.id_pregunta)" :class="{ active: filaActiva == pregunta.id_pregunta }">
									<td>{{ pregunta.numero }}</td>					
									<td v-html="pregunta.pregunta"></td>
									<td>
										<div class="container-fluid text-center">
											<span v-html="pregunta.respuesta"></span>
										</div>
									</td>													
									<td>
										<div class="container-fluid text-center">
											<span :class="{ red: pregunta.respuesta != pregunta.respuesta_alumno, green: pregunta.respuesta == pregunta.respuesta_alumno }" v-html="pregunta.respuesta_alumno"></span>
										</div>
									</td>
									<td class="text-center">
										<span v-if="pregunta.respuesta == pregunta.respuesta_alumno" class="oi oi-check" aria-hidden="true"></span>
										<span v-if="pregunta.respuesta != pregunta.respuesta_alumno" class="oi oi-x" aria-hidden="true"></span>
									</td>
								</tr>					
							</tbody>	
						</table>
							<div class="modal-footer">	
								<button class="btn btn-sm btn-primary" v-on:click="cerrarVentanaResultados()"> Aceptar </button>	
							</div>							
						</div>
					</div>
				</div>
				</div>
			</div>
			</transition>
		</div>		
	</div>

	<script>
		var id_alumno = <?php echo $id_alumno ?>
	</script>			

	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/vue.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/vue-resource.min.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/notifications/vue-toasted.min.js"></script>						
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/components/vue-tabs.js"></script>		
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/funciones.js?1.0.2"></script>			
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/alumno.js?1.0.4"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/editor/js/katex.min.js"></script>		
</body>
</html>