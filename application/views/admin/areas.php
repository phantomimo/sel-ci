<html>
<head>
	<meta charset="utf-8" />
	<title> <?php echo APLICACION_NOMBRE ?> - Lista de areas </title>
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
	<div class="container" id="controlador_areas" v-cloak>
		<menu-principal url_base="<?php echo base_url() ?>" nombre_aplicacion="<?php echo APLICACION_NOMBRE ?>"></menu-principal>		
		<h3> Áreas </h3>
		<hr />
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
					<th> Nivel </th>											
					<th class="operaciones-tabla"> <button class="btn btn-sm btn-primary" v-on:click="mostrarVentanaEdicion(area_nueva, opInsertar)"> Nuevo </button> </th>
				</tr>
			</thead>
			<tbody>
				<tr v-for="area in areasFiltro" @click="activarFila(area.id_area)" :class="{ active: filaActiva == area.id_area }">
					<td>{{ area.nombre }}</td>						
					<td>{{ area.clave }}</td>						
					<td><span v-for="(nivel, index) in area.niveles"><span v-if="index != 0">, </span>{{ nivel.nombre }}</span></td>											
					<td class="operaciones-tabla">
						<button class="btn btn-sm" v-on:click="mostrarVentanaEdicion(area, opModificar)"> <span class="oi oi-pencil" title="Modificar" aria-hidden="true"></span> </button>
						<button class="btn btn-sm" v-on:click="eliminarArea(area)"> <span class="oi oi-trash" title="Eliminar" aria-hidden="true"> </button>
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
							<form @submit.native.prevent="guardarArea(area, operacion)">								
								<div class="form-group">
									<label for="nombrearea">Nombre:</label>
									<input type="text" class="form-control" v-model.lazy="area.nombre" id="nombrearea" placeholder="Nombre del area" v-focus/>
								</div>									
								<div class="form-group">
									<label for="clave">Clave:</label>
									<input type="text" class="form-control" v-model.lazy="area.clave" id="clave" placeholder="Clave interna"/>
								</div>								
								<div class="form-group">
									<label for="nivel">Nivel:</label>									
									<multiselect v-model.lazy="area.niveles" placeholder="Elegir nivel" :options="niveles" label="nombre" track-by="nombre" :multiple="true"></multiselect>
								</div>
								<div class="modal-footer">	
									<button class="btn btn-sm btn-primary" v-on:click="guardarArea(area, operacion)"> Guardar </button>
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
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/areas.js"></script>

</body>
</html>