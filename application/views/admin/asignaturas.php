<html>
<head>
	<meta charset="utf-8" />
	<title> <?php echo APLICACION_NOMBRE ?> - Lista de asignaturas </title>
	<script  type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/jquery-3.7.0.min.js"></script>	
	<script  type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/bootstrap.min.js"></script>	
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap-responsive.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/sel.css?1.0.1.110620" />	
	<link rel="stylesheet" href="<?php echo base_url() ?>assets/css/open-iconic-bootstrap.min.css">	
	<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">		
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/components/vue-multiselect.min.css" />			
</head>
<body>
	<div class="container" id="controlador_asignaturas" v-cloak>
		<menu-principal url_base="<?php echo base_url() ?>" nombre_aplicacion="<?php echo APLICACION_NOMBRE ?>"></menu-principal>		
		<h3> Asignaturas </h3>		
		<hr />
		<form action="javascript:void(0);" novalidate="true">			
			<div class="card bg-light">
				<input type="search" v-model="textoFiltro" class="form-control" placeholder="Buscar">
			</div>			
			<div v-if="cargando_registros">
				Cargando registros...
			</div>				
			<table class="table table-hover" v-if="!cargando_registros">
				<thead>
					<tr>
						<th> Nombre </th>
						<th> Clave </th>						
						<th> Descripción </th>
						<th> Unidades </th>						
						<th> Área </th>
						<th> Nivel </th>						
						<th class="operaciones-tabla"> <button class="btn btn-sm btn-primary" v-on:click="mostrarVentanaEdicion(asignatura_nueva, opInsertar)"> Nuevo </button> </th>
					</tr>
				</thead>
				<tbody>
					<tr v-for="asignatura in asignaturasFiltro" @click="activarFila(asignatura.id_asignatura)" :class="{ active: filaActiva == asignatura.id_asignatura }">
						<td>{{ asignatura.nombre }}</td>
						<td>{{ asignatura.clave }}</td>											
						<td>{{ asignatura.descripcion }}</td>
						<td>{{ asignatura.unidades }}</td>						
						<td>{{ asignatura.area }}</td>
						<td><span v-for="(nivel, index) in asignatura.niveles"><span v-if="index != 0">, </span>{{ nivel.nombre }}</span></td>						
						<td class="operaciones-tabla">
							<button class="btn btn-sm" v-on:click="mostrarVentanaEdicion(asignatura, opModificar)"> <span class="oi oi-pencil" title="Modificar" aria-hidden="true"></span> </button>
							<button class="btn btn-sm" v-on:click="eliminarAsignatura(asignatura)"> <span class="oi oi-trash" title="Eliminar" aria-hidden="true"> </button>
						</td>
					</tr>					
				</tbody>
			</table>
		</form>
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
							<form @submit.native.prevent="guardarAsignatura(asignatura, operacion)">
								<div class="form-group">
									<label for="nombreAsignatura">Nombre:</label>
									<input type="text" class="form-control" v-model.lazy="asignatura.nombre" id="nombreAsignatura" placeholder="Nombre de la asignatura" v-focus />
								</div>
								<div class="form-group">
									<label for="claveAsignatura">Clave:</label>
									<input type="text" class="form-control" v-model.lazy="asignatura.clave" id="claveAsignatura" placeholder="Clave de la asignatura" />
								</div>								
								<div class="form-group">
									<label for="descripcionAsignatura">Descripción:</label>
									<input type="text" class="form-control" v-model.lazy="asignatura.descripcion" id="descripcionAsignatura" placeholder="Descripción de la asignatura"/>
								</div>							
								<div class="form-group">
									<label for="unidadesAsignatura">Unidades:</label>
									<input type="text" class="form-control" v-model.lazy="asignatura.unidades" id="unidadesAsignatura" placeholder="Unidades de la asignatura"/>
								</div>							
								<div class="form-group">
									<label for="areaAsignatura">Área:</label>
									<select id="areaAsignatura" v-model.lazy="asignatura.id_area" class="form-control">
										<option v-for="area in areas" v-bind:value="area.id_area"> {{ area.nombre }} </option>
									</select>
								</div>	
								<div class="form-group">
									<label for="nivel">Nivel:</label>									
									<multiselect v-model.lazy="asignatura.niveles" placeholder="Elegir nivel" :options="niveles" label="nombre" track-by="nombre" :multiple="true"></multiselect>																
								</div>																
								<div class="modal-footer">
									<button type="submit" class="btn btn-sm btn-primary" v-on:click="guardarAsignatura(asignatura, operacion)"> Guardar </button>
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
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/vue/components/vue-multiselect.min.js"></script>					
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/funciones.js?1.0.2"></script>	
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/asignaturas.js?1.0.2"></script>

</body>
</html>