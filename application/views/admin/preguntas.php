<html>
<head>
	<meta charset="utf-8" />
	<title> <?php echo APLICACION_NOMBRE ?> - Banco de preguntas </title>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/jquery-3.7.0.min.js"></script>	
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/bootstrap.min.js"></script>	
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap-responsive.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/sel.css?1.0.1.110620" />	
	<link rel="stylesheet" href="<?php echo base_url() ?>assets/css/open-iconic-bootstrap.min.css">		
	<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">	

    <!-- suneditor -->
    <link rel="stylesheet" href="<?php echo base_url() ?>assets/editor/css/suneditor.min.css" >
    <link rel="stylesheet" href="<?php echo base_url() ?>assets/editor/css/codemirror.min.css">
    <link rel="stylesheet" href="<?php echo base_url() ?>assets/editor/css/katex.min.css">	

</head>
<body>
	<div class="container" id="controlador_preguntas" v-cloak>		
		<menu-principal url_base="<?php echo base_url() ?>" nombre_aplicacion="<?php echo APLICACION_NOMBRE ?>"></menu-principal>
		<h3> Banco de preguntas <span v-if="asignatura.nombre">- [{{ asignatura.nombre }}] </span></h3>		
		<hr />	
		<div class="container-fluid row">
				<div class="col-md-1 col-sm-1">			
						<label for="nivel">Nivel:</label>
				</div>
				<div class="col-md-3 col-sm-3">													
					<select id="nivel-select" v-model="nivel" v-on:change="recuperarAreas(nivel)" @change="asignaturas = []; preguntas = []" class="form-control" >
						<option v-for="nivel in niveles" v-bind:value="nivel"> {{ nivel.nombre }} </option>
					</select>											
				</div>	
				<div class="col-md-1 col-sm-1">			
					<label for="area">Área:</label>
				</div>
				<div class="col-md-3 col-sm-3">								
					<select id="area-select" v-model="area" v-on:change="recuperarAsignaturas(area, nivel)"  @change="preguntas = []" class="form-control">
						<option v-for="area in areas" v-bind:value="area"> {{ area.nombre }} </option>
					</select>											
				</div>							
				<div class="col-md-1 col-sm-1">
					<label for="asignatura">Asignatura:</label>
				</div>
				<div class="col-md-3 col-sm-3">		
					<select id="asignatura-select" v-model="asignatura" v-on:change="recuperarPreguntas(asignatura)" class="form-control">
						<option v-for="asignatura in asignaturas" v-bind:value="asignatura"> {{ asignatura.nombre }} </option>
					</select>								
				</div>				
				<!-- <button class="btn btn-default btn-sm" v-on:click="recuperarExamenesAsignatura(asignatura, nivel)"><i class="oi oi-reload"></i> Test</button>					 -->
			</div>	
			<div class="col-md-1 col-sm-1">
				<a href="#" v-if="asignatura.id_asignatura" class="btn btn-primary" v-on:click="recuperarPreguntas(asignatura)"><span class="oi oi-reload"></span></a>										
			</div>						
		<hr />
		<div v-if="preguntas.length" class="card bg-light">
			<input type="search" v-model="textoFiltro" class="form-control" placeholder="Buscar">
		</div>
		<div v-if="cargando_registros">
			Cargando registros...
		</div>					
		<table class="table table-hover" v-if="!cargando_registros">
			<thead>
				<tr>
					<th> No. </th>
					<!-- <th> Asignatura </th> -->
					<th style="width:45%"> Pregunta </th>						
					<th style="width:40%"> Opciones </th>
					<th class="operaciones-tabla">
						<div class="scroll-visible"><button v-if="asignatura.id_asignatura" class="btn btn-sm btn-primary" v-on:click="mostrarVentanaEdicion(pregunta_nueva, asignatura, opInsertar)"> Nuevo </button></div>
					</th>
				</tr>
			</thead>
			<tbody v-if="preguntas.length">
				<tr v-for="pregunta in preguntasFiltro" @click="activarFila(pregunta.id_pregunta)" :class="{ active: filaActiva == pregunta.id_pregunta }">
					<td>{{ pregunta.numero }}</td>					
					<!-- <td>{{ pregunta.asignatura }}</td>					 -->
					<td v-html="pregunta.pregunta"></td>
					<td>
						<div class="container-fluid row">
							<div class="card">
								<div class="card-body">
									<span class="card-subtitle">a)</span>
									<span class="card-text" v-html="pregunta.opcion1"></span>
								</div>
							</div>							
							<div class="card">
								<div class="card-body">
									<span class="card-subtitle">b)</span>
									<span class="card-text" v-html="pregunta.opcion2"></span>
								</div>
							</div>							
							<div class="card">
								<div class="card-body">
									<span class="card-subtitle">c)</span>
									<span class="card-text" v-html="pregunta.opcion3"></span>
								</div>
							</div>												
							<div class="card">
								<div class="card-body">
									<span class="card-subtitle">c)</span>
									<span class="card-text" v-html="pregunta.opcion4"></span>
								</div>
							</div>																
						</div>
					</td>													
					<td class="operaciones-tabla">
						<button class="btn btn-sm" v-on:click="mostrarVentanaEdicion(pregunta, asignatura, opModificar)"><span class="oi oi-pencil" title="Modificar" aria-hidden="true"></span></button>
						<button class="btn btn-sm" v-on:click="eliminarPregunta(pregunta, asignatura)"><span class="oi oi-trash" title="Eliminar" aria-hidden="true"></span></button>
					</td>
				</tr>					
			</tbody>	
		</table>

		<div v-if="!preguntas.length & !cargando_registros" style="text-align: center">Sin registros </div>			

		<a href="#" v-if="asignatura.id_asignatura" class="float" v-on:click="mostrarVentanaEdicion(pregunta_nueva, asignatura, opInsertar)"> <i class="oi oi-plus my-float"></i></a>
	
		<div v-if="modalEdicion" id="modal">
			<div class="modal-mask">
				<div class="modal-wrapper" style="overflow-y: scroll;">
				<div class="modal-dialog modal-xl modal-dialog-scrollable" role="document">
					<div class="modal-content">
						<div class="modal-header">
							<h6 class="modal-title"> {{ operacionTitulo() }}</h6>
							<button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
								<span aria-hidden="true" @click="cerrarModal()">&times;</span>
							</button>
						</div>
						<div class="modal-body">
							<div v-if="errors.length">
								<b>Por favor, corrija el(los) siguiente(s) error(es):</b>
								<ul>
									<li v-for="error in errors">{{ error }}</li>
								</ul>
								<button class="btn btn-warning" v-on:click="inicializarErrores()">Aceptar</button>
							</div>							
							<form @submit.native.prevent="guardarPregunta(pregunta, asignatura, operacion)" autocomplete="off">								
								<div class="container-fluid row">
									<div class="form-group col-md-5 col-sm-5">												
										<label for="numeroPregunta"><strong>Número:</strong></label>
										<input type="text" class="form-control" v-model.lazy="pregunta.numero" id="numeroPregunta" placeholder="Número"/>
									</div>							
									<div class="form-group col-md-5 col-sm-5">
										<label for="asignatura-select-1"><strong>Asignatura:</strong></label>										
										<select v-show="operacion == opModificar" id="asignatura-select-1" v-model="pregunta.id_asignatura" class="form-control">
											<option v-for="asignatura in asignaturas" v-bind:value="asignatura.id_asignatura"> {{ asignatura.nombre }} </option>
										</select>		
										<select v-show="operacion == opInsertar" id="asignatura-select-2" v-model="asignatura" class="form-control">
											<option v-for="asignatura in asignaturas" v-bind:value="asignatura"> {{ asignatura.nombre }} </option>
										</select>																				
									</div>							
								</div>
								<div class="form-group">
									<label for="textoPregunta"><strong>Pregunta:</strong></label>
									<!-- <textarea class="md-textarea form-control" rows="6" v-html="pregunta.pregunta" v-model.lazy="pregunta.pregunta" id="textoPregunta" placeholder="Texto de la pregunta" v-focus></textarea> -->
									<textarea class="md-textarea form-control" id="texto-pregunta" v-model.lazy="pregunta.pregunta" rows="6"></textarea>
									<a href="#" v-if="!editorAvanzado" class="btn btn-sm btn-primary" v-on:click="mostrarEditor()"> Editor avanzado!</a>
									<a href="#" v-if="editorAvanzado" class="btn btn-sm btn-primary" v-on:click="ocultarEditor()"> Ocultar Editor</a>									
								</div>									
								<div class="form-group">									
									<label for="textoPregunta"><strong>Respuestas:</strong></label>																		
									<div class="container-fluid row">
										<div class="form-group col-md-6 col-sm-6">																						
											<label for="opcion1"><strong>a) </strong></label>										
											<div class="input-group">	
												<input type="text" class="form-control" v-bind:class="{correcta: pregunta.respuesta == 1}" v-model.lazy="pregunta.opcion1" ref="opcion1" placeholder="Opción 1"/>
												<i v-if="pregunta.respuesta == 1" class="oi oi-circle-check"></i>											
											</div>
										</div>							
										<div class="form-group col-md-6 col-sm-6">
											<label for="opcion1"><strong>b) </strong></label>																					
											<div class="input-group">	
												<input type="text" class="form-control" v-bind:class="{correcta: pregunta.respuesta == 2}" v-model.lazy="pregunta.opcion2" ref="opcion2" placeholder="Opción 2"/>
												<i v-if="pregunta.respuesta == 2" class="oi oi-circle-check"></i>											
											</div>
										</div>							
									</div>
									<div class="container-fluid row">
										<div class="form-group col-md-6 col-sm-6">
											<label for="opcion1"><strong>c) </strong></label>																					
											<div class="input-group">									
												<input type="text" class="form-control" v-bind:class="{correcta: pregunta.respuesta == 3}" v-model.lazy="pregunta.opcion3" ref="opcion3" placeholder="Opción 3"/>
												<i v-if="pregunta.respuesta == 3" class="oi oi-circle-check"></i>											
											</div>
										</div>							
										<div class="form-group col-md-6 col-sm-6">
											<label for="opcion1"><strong>d) </strong></label>												
											<div class="input-group">																																								
												<input type="text" class="form-control" v-bind:class="{correcta: pregunta.respuesta == 4}" v-model.lazy="pregunta.opcion4" ref="opcion4" placeholder="Opción 4"/>
												<i v-if="pregunta.respuesta == 4" class="oi oi-circle-check"></i>
											</div>
										</div>							
									</div>
									<div class="container-fluid row">
										<div class="form-group col-md-6 col-sm-4">
											<label for="respuesta"><strong>Respuesta correcta:</strong></label>									
											<select id="respuesta" v-model="pregunta.respuesta" class="form-control">
												<option v-for="respuesta in respuestas" :value="respuesta.valor"> {{ respuesta.clave }} </option>
											</select>									
										</div>							
										<div class="form-group col-md-6 col-sm-6">
											<label for="valorReactivo"><strong>Valor del reactivo:<strong></label>
											<div class="input-group">																																
												<input type="text" class="form-control" v-model="pregunta.valor_reactivo" ref="valorReactivo" placeholder="Valor del reactivo"/>											
											</div>
										</div>							
									</div>								
								</div>															
								<div class="modal-footer">	
									<button type="submit" class="btn btn-sm btn-primary" v-on:click="guardarPregunta(pregunta, asignatura, operacion)"> Guardar </button>
									<button class="btn btn-sm btn-secondary" v-on:click="cerrarModal()"> Cancelar </button>								
								</div>								
							</form>
						</div>
					</div>
				</div>
				</div>
			</div>
		</div>		
	</div>

		
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/vue.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/vue-resource.min.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/notifications/vue-toasted.min.js"></script>					
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/vue-router.js"></script>						
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/funciones.js?1.0.2"></script>				
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/preguntas.js?1.0.1.110620"></script>
	<!-- suneditor -->
	<script type="text/javascript" src="<?php echo base_url() ?>assets/editor/js/suneditor.min.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/editor/js/codemirror.min.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/editor/js/htmlmixed.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/editor/js/xml.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/editor/js/css.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/editor/js/katex.min.js"></script>	

</body>
</html>