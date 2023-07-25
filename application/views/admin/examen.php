<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	<title> <?php echo APLICACION_NOMBRE ?> - Editar examen </title>
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
	<div class="container" id="controlador_examen" v-cloak>		
		<menu-principal url_base="<?php echo base_url() ?>" nombre_aplicacion="<?php echo APLICACION_NOMBRE ?>"></menu-principal>
		<h3><span v-if="examen.clave">[{{ examen.clave }}] {{ examen.descripcion }} </span></h3>			
		<h6><span v-if="examen.clave">{{ nivel.nombre }} | {{ examen.asignatura }} </span></h3>					
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
					<!-- <th style="width:5%; text-align:center"> Unidad </th>										 -->
					<th style="width:45%"> Pregunta </th>						
					<th style="width:40%"> Opciones </th>
					<th class="operaciones-tabla">
						<button v-if="examen.id_examen" class="btn btn-sm btn-primary" v-on:click="mostrarVentanaBusqueda()"><span class="oi oi-search" title="Buscar en el banco de preguntas" aria-hidden="true"></span></button> 
						<button v-if="asignatura.id_asignatura" class="btn btn-sm btn-primary" v-on:click="mostrarVentanaEdicion(pregunta_nueva, asignatura, opInsertar)"> Nuevo </button>
					</th>
				</tr>
			</thead>
			<tbody v-if="preguntas.length">
				<tr v-for="pregunta in preguntasFiltro" @click="activarFila(pregunta.id_pregunta)" :class="{ active: filaActiva == pregunta.id_pregunta }">
					<td>{{ pregunta.numero }}</td>					
					<!-- <td style="text-align:center">{{ pregunta.unidad }}</td>						 -->
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
						<button class="btn btn-sm" v-on:click="eliminarPregunta(pregunta)"><span class="oi oi-trash" title="Eliminar" aria-hidden="true"></span></button>
					</td>
				</tr>					
			</tbody>	
		</table>

		<div v-if="!preguntas.length & !cargando_registros" style="text-align: center">Sin registros </div>
		<!-- <a href="#" v-if="asignatura.id_asignatura" class="float" v-on:click="mostrarVentanaBusqueda()"> <i class="oi oi-plus my-float"></i></a> -->
		<a href="#" v-if="asignatura.id_asignatura" class="float" v-on:click="mostrarVentanaEdicion(pregunta_nueva, asignatura, opInsertar)"> <i class="oi oi-plus my-float"></i></a>		
	
		<div v-if="modalEdicion" id="modal">
			<!-- <transition name="modal"> -->
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
									<div class="form-group col-md-6 col-sm-6">												
										<label for="numeroPregunta"><strong>Número:</strong></label>
										<input type="text" class="form-control" v-model.lazy="pregunta.numero" id="numeroPregunta" placeholder="Número"/>
									</div>												
									<div class="form-group col-md-5 col-sm-5">
										<label for="asignatura-select-1"><strong>Asignatura:</strong></label>										
										<select id="asignatura-select-1" v-model="pregunta.id_asignatura" class="form-control">
											<option v-for="asignatura in asignaturas" v-bind:value="asignatura.id_asignatura"> {{ asignatura.nombre }} </option>
										</select>																					 
									</div>										
								</div>
								<div class="form-group">
									<label for="textoPregunta"><strong>Pregunta:</strong></label>									
									<textarea class="md-textarea form-control" id="texto-pregunta" v-model.lazy="pregunta.pregunta" rows="6" v-focus></textarea>
									<a href="#" v-if="!editorAvanzado" class="btn btn-sm btn-primary" v-on:click="mostrarEditor()"> Editor avanzado!</a>
									<a href="#" v-if="editorAvanzado" class="btn btn-sm btn-primary" v-on:click="ocultarEditor()"> Ocultar Editor</a>									
								</div>		 
								<div class="form-group">									
									<label><strong>Respuestas:</strong></label>																		
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
											<label for="valor-reactivo"><strong>Valor del reactivo:<strong></label>
											<div class="input-group">																																
												<input type="text" id="valor-reactivo" class="form-control" v-model.lazy="pregunta.valor_reactivo" ref="valorReactivo" placeholder="Valor del reactivo"/>											
											</div>
										</div>							
									</div>								
								</div>
								<div class="modal-footer">	
									<small class="text-left">Esta pregunta se agregará automáticamente al banco de preguntas</small>
									<button type="submit" class="btn btn-sm btn-primary" v-on:click="guardarPregunta(pregunta, asignatura, operacion)"> Guardar </button>
									<button class="btn btn-sm btn-secondary" v-on:click="cerrarModal()"> Cancelar </button>								
								</div>	
							</form>
						</div>
					</div>
				</div>
				</div>
			</div>
			<!-- </transition>			 -->
		</div>

		<div v-if="modalBusqueda" id="modal">
			<transition name="modal">
			<div class="modal-mask">
				<div class="modal-wrapper" style="overflow-y: scroll;">
				<div class="modal-dialog modal-lg modal-dialog-scrollable" role="document">
					<div class="modal-content">
						<div class="modal-header">
							<h5 class="modal-title"> Búsqueda de preguntas </h5> <br/>
							<button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
								<span aria-hidden="true" @click="cerrarModalBusqueda()">&times;</span>
							</button>
						</div>
						<div class="modal-body">
							<form>								
								<div class="form-group">
									<label for="buscar">Buscar en el banco de preguntas:</label>
									<input type="text" class="form-control" v-model="textoPregunta" id="textoPregunta" ref="txtPregunta" v-focus/>
									<button class="btn btn-sm" v-on:click="buscarPreguntas(textoPregunta)"><i class="fa fa-search"></i></button>
								</div>	
								<div class="form-group">
									<table class="table table-hover" v-if="!cargando_registros">
									<thead>
										<tr>
											<th> No. </th>
											<th style="width:5%; text-align:center"> Asignatura </th>										
											<th style="width:90%"> Pregunta </th>						
											<th style="width:5%"> </th>
											<th class="operaciones-tabla">												
											</th>
										</tr>
									</thead>
									<tbody v-if="preguntas_busqueda.length">
										<tr v-for="pregunta in preguntas_busqueda" @click="activarFila(pregunta.id_pregunta)" :class="{ active: filaActiva == pregunta.id_pregunta }">
											<td style="text-align:center">{{ pregunta.numero }}</td>																	
											<td>{{ pregunta.asignatura }}</td>					
											<td v-html="pregunta.pregunta"></td>																						
											<td class="operaciones-tabla">
												<button class="btn btn-sm" v-on:click="agregarPregunta(pregunta)"><span class="oi oi-share" title="Agregar" aria-hidden="true"></span></button>
											</td>
										</tr>					
									</tbody>	
									</table>								
								</div>
								<div class="modal-footer">	
									<button class="btn btn-sm btn-secondary" v-on:click="cerrarModalBusqueda()"> Cancelar </button>	
								</div>							
							</form>
						</div>
					</div>
				</div>
				</div>
			</div>
			</transition>
		</div>		
	</div>

	<script>
		var id_examen = <?php echo $id_examen ?>
	</script>
	<!-- suneditor -->
	<script type="text/javascript" src="<?php echo base_url() ?>assets/editor/js/suneditor.min.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/editor/js/codemirror.min.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/editor/js/htmlmixed.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/editor/js/xml.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/editor/js/css.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/editor/js/katex.min.js"></script>	

	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/vue.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/vue-resource.min.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/notifications/vue-toasted.min.js"></script>											
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/funciones.js?1.0.2"></script>				
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/examen.js?1.0.2.200613"></script>	

</body>
</html>