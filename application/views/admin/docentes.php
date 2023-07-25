<html>
<head>
	<meta charset="utf-8" />
	<title> <?php echo APLICACION_NOMBRE ?> - Lista de docentes </title>
	<script  type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/jquery-3.7.0.min.js"></script>	
	<script  type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/bootstrap.min.js"></script>	
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap-responsive.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/sel.css?1.0.1.110620" />	
	<link rel="stylesheet" href="<?php echo base_url() ?>assets/css/open-iconic-bootstrap.min.css">	
	<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">			
</head>
<body>
	<div class="container" id="controlador_docentes" v-cloak>
		<menu-principal url_base="<?php echo base_url() ?>" nombre_aplicacion="<?php echo APLICACION_NOMBRE ?>"></menu-principal>	
		<h3> Docentes </h3>
		<hr />

		<div class="card bg-light">
			<input type="search" v-model="textoFiltro" class="form-control" placeholder="Buscar">
		</div>			
		<div v-if="cargando_registros">
			Cargando registros...
		</div>				
		<table  class="table table-hover" v-if="!cargando_registros">
			<thead>
				<tr>
					<th> Nombre </th>
					<th> Apellido paterno </th>						
					<th> Apellido materno </th>
					<th> CURP </th>	
					<th class="operaciones-tabla"> <button class="btn btn-sm btn-primary" v-on:click="mostrarVentanaEdicion(docente_nuevo, opInsertar)"> Nuevo </button> </th>
				</tr>
			</thead>
			<tbody>
				<tr v-for="docente in docentesFiltro" @click="activarFila(docente.id_docente)" :class="{ active: filaActiva == docente.id_docente }">
					<td>{{ docente.nombre }}</td>
					<td>{{ docente.apellido_paterno }}</td>
					<td>{{ docente.apellido_materno }}</td>						
					<td>{{ docente.curp }}</td>
					<td class="operaciones-tabla">
						<button class="btn btn-sm" v-on:click="mostrarVentanaEdicion(docente, opModificar)"> <span class="oi oi-pencil" title="Modificar" aria-hidden="true"></span> </button>
						<button class="btn btn-sm" v-on:click="eliminarDocente(docente)"> <span class="oi oi-trash" title="Eliminar" aria-hidden="true"> </button>
					</td>
				</tr>					
			</tbody>
		</table>

		<div v-if="modalEdicion" id="modal">
			<transition name="modal">
			<div class="modal-mask">
				<div class="modal-wrapper">
				<div class="modal-dialog" role="document">
					<div class="modal-content">
						<div class="modal-header">
							<h5 class="modal-title"> {{ operacionTitulo() }}</h5>
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
							<form @submit.native.prevent="guardarDocente(docente, operacion)" autocomplete="off">								
								<div class="form-group">
									<label for="nombreDocente">Nombre:</label>
									<input type="text" class="form-control" v-model.lazy="docente.nombre" id="nombreDocente" placeholder="Nombre del docente" v-focus/>
								</div>
								<div class="form-group">
									<label for="apellidoPaterno">Apellido paterno:</label>
									<input type="text" class="form-control" v-model.lazy="docente.apellido_paterno" id="apellidoPaterno" placeholder="Apellido paterno"/>
								</div>							
								<div class="form-group">
									<label for="apellidoMaterno">Apellido materno:</label>
									<input type="text" class="form-control" v-model.lazy="docente.apellido_materno" id="apellidoMaterno" placeholder="Apellido materno"/>
								</div>	
								<div class="form-group">
									<label for="Curp">CURP:</label>
									<input type="text" class="form-control" v-model.lazy="docente.curp" id="Curp" placeholder="CURP"/>
								</div>																							
								<div class="modal-footer">	
									<button type="submit" class="btn btn-sm btn-primary" v-on:click="guardarDocente(docente, operacion)"> Guardar </button>
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
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/docentes.js"></script>

</body>
</html>