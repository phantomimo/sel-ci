<html>
<head>
	<meta charset="utf-8" />
	<title> Exámenes - <?php echo APLICACION_NOMBRE ?> </title>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/jquery-3.7.0.min.js"></script>	
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/bootstrap.min.js"></script>	
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap-responsive.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/sel.css?1.0.1.110620" />	
	<link rel="stylesheet" href="<?php echo base_url() ?>assets/css/open-iconic-bootstrap.min.css">		
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/components/vue-multiselect.min.css" />	
</head>
<body>
	<div class="container" id="controlador_examenes" v-cloak>		
		<menu-principal url_base="<?php echo base_url() ?>" nombre_aplicacion="<?php echo APLICACION_NOMBRE ?>"></menu-principal>
		<h3> Exámenes <span v-if="asignatura.nombre">- [{{ asignatura.nombre }}] </span></h3>		
		<hr />
		<form>
			<div class="container-fluid row">
				<div class="col-md-1 col-sm-1">			
						<label for="nivel">Nivel:</label>
				</div>
				<div class="col-md-3 col-sm-3">													
					<select id="nivel-select" v-model="nivel" v-on:change="recuperarAreas(nivel)" @change="asignaturas = []; examenes = []" class="form-control" >
						<option v-for="nivel in niveles" v-bind:value="nivel"> {{ nivel.nombre }} </option>
					</select>											
				</div>	
				<div class="col-md-1 col-sm-1">			
					<label for="area">Área:</label>
				</div>
				<div class="col-md-3 col-sm-3">								
					<select id="area-select" v-model="area" v-on:change="recuperarAsignaturas(area, nivel)"  @change="examenes = []" class="form-control">
						<option v-for="area in areas" v-bind:value="area"> {{ area.nombre }} </option>
					</select>											
				</div>							
				<div class="col-md-1 col-sm-1">
					<label for="asignatura">Asignatura:</label>
				</div>
				<div class="col-md-3 col-sm-3">		
					<select id="asignatura-select" v-model="asignatura" v-on:change="recuperarExamenesAsignatura(asignatura, nivel)" class="form-control">
						<option v-for="asignatura in asignaturas" v-bind:value="asignatura"> {{ asignatura.nombre }} </option>
					</select>								
				</div>				
				<div class="col-md-1 col-sm-1">
					<a href="#" v-if="asignatura.id_asignatura" class="btn btn-primary" v-on:click="recuperarExamenesAsignatura(asignatura, nivel)"><span class="oi oi-reload"></span></a>										
				</div>
				<!-- <button class="btn btn-default btn-sm" v-on:click="recuperarExamenesAsignatura(asignatura, nivel)"><i class="oi oi-reload"></i> Test</button>					 -->
			</div>		
		</form>
		<hr />
		<div v-if="examenes.length" class="card bg-light">
			<input type="search" v-model="textoFiltro" class="form-control" placeholder="Buscar">
		</div>
		<div v-if="cargando_registros">
			Cargando registros...
		</div>					
		<table class="table table-hover" v-if="!cargando_registros">
			<thead>
				<tr>
					<th> Clave </th>													
					<th style="width:30%;"> Descripción </th>										
					<th style="width:10%"> Fecha vencimiento </th>						
					<th style="width:10%"> Total preguntas </th>											
					<th style="width:10%"> Tiempo límite </th>											
					<th style="width:15%; text-align:right;"> 
						<div class="scroll-visible"><button v-if="asignatura.id_asignatura" class="btn btn-sm btn-primary" v-on:click="mostrarVentanaEdicion(examen_nuevo, opInsertar)"> Nuevo </button></div>
					</th>
				</tr>
			</thead>
			<tbody v-if="examenes.length">
				<tr v-for="examen in examenesFiltro" @click="activarFila(examen.id_examen)" :class="{ active: filaActiva == examen.id_examen }">
					<td>{{ examen.clave }}</td>													
					<td>{{ examen.descripcion }}</td>						
					<td>{{ examen.fecha_vencimiento }}</td>
					<td>{{ examen.total_preguntas }}</td>					
					<td>{{ examen.tiempo_limite }} min.</td>					
					<td class="operaciones-tabla">
						<button class="btn btn-sm" v-on:click="editarExamen(examen)"><span class="oi oi-list-rich" title="Editar preguntas del examen" aria-hidden="true"></span></button>
						<button class="btn btn-sm" v-on:click="mostrarVentanaEdicion(examen, opModificar)"><span class="oi oi-pencil" title="Modificar" aria-hidden="true"></span></button>						
						<button class="btn btn-sm" v-on:click="eliminarExamen(examen)"><span class="oi oi-trash" title="Eliminar" aria-hidden="true"></span></button>
					</td>
				</tr>					
			</tbody>	
		</table>

		<div v-if="!examenes.length & !cargando_registros" style="text-align: center">Sin registros </div>			
	
		<!-- ventana de edición del registro -->
		<div v-if="modalEdicion" id="modal">
			<transition name="modal">
			<div class="modal-mask">
				<div class="modal-wrapper" style="overflow-y: scroll;">
				<div class="modal-dialog modal-lg modal-dialog-scrollable" role="document">
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
							<form @submit.native.prevent="guardarExamen(examen, operacion)" autocomplete="off">								
								<div class="container-fluid row">
									<div class="form-group col-md-6 col-sm-6">												
										<label for="claveExamen"><strong>Clave de examen:</strong></label>
										<input type="text" class="form-control" v-model.lazy="examen.clave" id="claveExamen" placeholder="Clave" v-focus />
									</div>							
									<div class="form-group col-md-6 col-sm-6">
										<label for="nivelExamen"><strong>Nivel:</strong></label>
										<select v-show="operacion == opInsertar" id="nivel-select-1" v-model="nivel" class="form-control">
											<option v-for="nivel in niveles" v-bind:value="nivel"> {{ nivel.nombre }} </option>
										</select>								
										<select v-show="operacion == opModificar" id="nivel-select-2" v-model.lazy="examen.id_nivel" class="form-control">
											<option v-for="nivel in niveles" v-bind:value="nivel.id_nivel"> {{ nivel.nombre }} </option>
										</select>								
									</div>							
								</div>
								<div class="form-group">
									<label for="descripcionExamen"><strong>Descripción:</strong></label>
									<textarea class="md-textarea form-control" rows="2" v-model.lazy="examen.descripcion" id="descripcionExamen" placeholder="Descripción del examen">{{examen.descripcion}}</textarea>
								</div>
								<div class="form-group container-fluid row">
									<div class="input-group col-md-6 col-sm-6">												
										<label for="opcion1"><strong>Fecha de vencimiento:</strong></label>
										<div class="input-group">	
											<vuejs-datepicker :bootstrap-styling="true" v-model.lazy="examen.fecha_vencimiento" name="fecha"></datepicker>											
										</div>
									</div>							
									<div class="input-group col-md-6 col-sm-6">
										<label for="tiempo-limite"><strong>Tiempo límite:</strong></label>										
										<div class="input-group">	
											<input type="text" class="form-control" v-model.lazy="examen.tiempo_limite" id="tiempo-limite" placeholder="Tiempo límite"/> min.
										</div>
									</div>							
								</div>
								<div class="form-group">
									<label for="docente"><strong>Docente:</strong></label>									
									<select id="docente" v-model="examen.id_docente" class="form-control">
										<option v-for="docente in docentes" v-bind:value="docente.id_docente"> {{ docente.nombre_completo }} </option>
									</select>									
								</div>		
								<div class="container-fluid row">
									<div class="form-group col-md-6 col-sm-6">												
										<label><strong>Opciones</strong></label><br/>
										<input type="checkbox" v-model.lazy="examen.mostrar_resultados" true-value="S" false-value="N" id="mostrarResultados"> 
										<label for="mostrarResultados">Mostrar resultados al finalizar</label>
									</div>							
									<div class="form-group col-md-6 col-sm-6">							
										<label for="intentos"><strong>Máximo de intentos por alumno:</strong></label>										
										<div class="input-group">	
											<input type="text" class="form-control" v-model.lazy="examen.intentos" id="intentos" placeholder="Intentos"/>
										</div>										
									</div>							
								</div>								
								<div class="modal-footer">	
									<button type="submit" class="btn btn-sm btn-primary" v-on:click="guardarExamen(examen, operacion)"> Guardar </button>
									<button class="btn btn-sm btn-secondary" v-on:click="cerrarModal()"> Cancelar </button>								
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

		
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/vue.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/vue-resource.min.js"></script>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/notifications/vue-toasted.min.js"></script>					
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/components/vuejs-datepicker.min.js"></script>								
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/components/vue-multiselect.min.js"></script>	
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/funciones.js?1.0.2"></script>				
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/examenes.js?1.0.2"></script>

</body>
</html>