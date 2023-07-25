<html>
<head>
	<meta charset="utf-8" />
	<title> <?php echo APLICACION_NOMBRE ?> - Lista de alumnos </title>
	<script  type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/jquery-3.7.0.min.js"></script>	
	<script  type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/bootstrap.min.js"></script>	
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap-responsive.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/sel.css?1.0.1.110620" />	
	<link rel="stylesheet" href="<?php echo base_url() ?>assets/css/open-iconic-bootstrap.min.css">	
	<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">		
</head>
<body>
	<div class="container" id="controlador_alumnos" v-cloak>
		<menu-principal url_base="<?php echo base_url() ?>" nombre_aplicacion="<?php echo APLICACION_NOMBRE ?>"></menu-principal>		
		<h3> Alumnos </h3>
		<hr />
		<form action="javascript:void(0);" novalidate="true">	
			<div class="card bg-light">
				<input type="search" v-model="textoFiltro" class="form-control" placeholder="Buscar">
			</div>			
			<div v-if="cargando_registros">
				Cargando registros...
			</div>				
			<table  class="table table-hover" v-if="!cargando_registros">
				<thead>
					<tr>
						<th> No. control </th>
						<th> Nombre </th>
						<th> Apellido paterno </th>						
						<th> Apellido materno </th>
						<th> CURP </th>	
						<th> Nivel </th>												
						<th> Grado </th>																		
						<th> Grupo </th>																								
						<th class="operaciones-tabla"> <button class="btn btn-sm btn-primary" v-on:click="mostrarVentanaEdicion(alumno_nuevo, opInsertar)"> Nuevo </button> </th>
					</tr>
				</thead>
				<tbody>
					<tr v-for="alumno in alumnosFiltro" @click="activarFila(alumno.id_alumno)" :class="{ active: filaActiva == alumno.id_alumno }">
						<td>{{ alumno.numero_control }}</td>						
						<td>{{ alumno.nombre }}</td>
						<td>{{ alumno.apellido_paterno }}</td>
						<td>{{ alumno.apellido_materno }}</td>						
						<td>{{ alumno.curp }}</td>
						<td>{{ alumno.nivel }}</td>						
						<td>{{ alumno.grado }}</td>												
						<td>{{ alumno.grupo }}</td>																		
						<td class="operaciones-tabla">
							<button class="btn btn-sm" v-on:click="editarAlumno(alumno)"><span class="oi oi-pencil" title="Editar alumno" aria-hidden="true"></span></button>							
							<!-- <button class="btn btn-sm" v-on:click="mostrarVentanaEdicion(alumno, opModificar)"> <span class="oi oi-pencil" title="Modificar" aria-hidden="true"></span> </button> -->
							<button class="btn btn-sm" v-on:click="eliminarAlumno(alumno)"> <span class="oi oi-trash" title="Eliminar" aria-hidden="true"> </button>
						</td>
					</tr>					
				</tbody>
			</table>
		</form>
		<div v-if="modalEdicion" id="modal">
			<transition name="modal">
			<div class="modal-mask">
				<div class="modal-wrapper">
				<div class="modal-dialog modal-lg" role="document">
					<div class="modal-content">
						<div class="modal-header">
							<h5 class="modal-title"> {{ operacionTitulo() }} </h5>
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
							<form @submit.native.prevent="guardarAlumno(alumno, operacion)">								
							<div class="form-group">
									<label for="numeroControl">Número de control:</label>
									<input type="text" class="form-control" v-model.lazy="alumno.numero_control" id="numeroControl" placeholder="Número de control" />
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
										<select v-show="operacion == opModificar" id="nivel-select-1" v-model="alumno.id_nivel" v-on:change="recuperarGrados(alumno.id_nivel)" @change="grados = []; grupos = []" class="form-control">
											<option v-for="nivel in niveles" v-bind:value="nivel.id_nivel"> {{ nivel.nombre }} </option>											
										</select>		
										<select v-show="operacion == opInsertar" id="nivel-select-2" v-model="nivel" v-on:change="recuperarGrados(nivel.id_nivel)" @change="grados = []; grupos = []" class="form-control">
											<option v-for="nivel in niveles" v-bind:value="nivel"> {{ nivel.nombre }} </option>
										</select>											
									</div>							
									<div class="form-group col-md-4 col-sm-6">
										<label for="gradoAlumno">Grado:</label>
										<select v-show="operacion == opModificar" ref="grado" id="grado-select-1" v-model="alumno.id_grado" v-on:change="recuperarGrupos(grado.id_grado)" @change="grupos = []" class="form-control">
											<option v-for="grado in grados" v-bind:value="grado.id_grado"> {{ grado.nombre }} </option>											
										</select>		
										<select v-show="operacion == opInsertar" ref="grado" id="grado-select-2" v-model="grado" v-on:change="recuperarGrupos(grado.id_grado)" @change="grupos = []" class="form-control">
											<option v-for="grado in grados" v-bind:value="grado"> {{ grado.nombre }} </option>																						
										</select>											
									</div>							
									<div class="form-group col-md-4 col-sm-6">
										<label for="grupoAlumno">Grupo:</label>
										<select  ref="grupo" id="grupoAlumno" v-model="alumno.id_grupo"class="form-control" >
											<option v-for="grupo in grupos" v-bind:value="grupo.id_grupo"> {{ grupo.nombre }} </option>
										</select>								
									</div>							
								</div>																
								</div>																								
								<div class="modal-footer">	
									<button type="submit" class="btn btn-sm btn-primary" v-on:click="guardarAlumno(alumno, operacion)"> Guardar </button>
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
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/funciones.js?1.0.2"></script>			
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/alumnos.js"></script>

</body>
</html>