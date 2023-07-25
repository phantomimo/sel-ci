<html>
<head>
	<meta charset="utf-8" />
	<title> <?php echo APLICACION_NOMBRE ?> - Lista de grupos </title>
	<script  type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/jquery-3.7.0.min.js"></script>	
	<script  type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/bootstrap.min.js"></script>	
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap-responsive.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/sel.css?1.0.1.110620" />	
	<link rel="stylesheet" href="<?php echo base_url() ?>assets/css/open-iconic-bootstrap.min.css">	
	<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">			
</head>
<body>
	<div class="container" id="controlador_grupos" v-cloak>
		<menu-principal url_base="<?php echo base_url() ?>" nombre_aplicacion="<?php echo APLICACION_NOMBRE ?>"></menu-principal>		
		<h3> Grupos </h3>
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
					<th> Grado </th>																		
					<th class="operaciones-tabla"> <button class="btn btn-sm btn-primary" v-on:click="mostrarVentanaEdicion(grupo_nuevo, opInsertar)"> Nuevo </button> </th>
				</tr>
			</thead>
			<tbody>
				<tr v-for="grupo in gruposFiltro" @click="activarFila(grupo.id_grupo)" :class="{ active: filaActiva == grupo.id_grupo }">
					<td>{{ grupo.nombre }}</td>						
					<td>{{ grupo.clave }}</td>						
					<td>{{ grupo.nivel }}</td>																		
					<td>{{ grupo.grado }}</td>												
					<td class="operaciones-tabla">
						<button class="btn btn-sm" v-on:click="mostrarVentanaEdicion(grupo, opModificar)"> <span class="oi oi-pencil" title="Modificar" aria-hidden="true"></span> </button>
						<button class="btn btn-sm" v-on:click="eliminarGrupo(grupo)"> <span class="oi oi-trash" title="Eliminar" aria-hidden="true"> </button>
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
							<form @submit.native.prevent="guardarGrupo(grupo, operacion)" autocomplete="off">										
								<div class="form-group">
									<label for="nombreGrupo">Nombre:</label>
									<input type="text" class="form-control" v-model.lazy="grupo.nombre" id="nombreGrupo" placeholder="Nombre del grupo" v-focus/>
								</div>									
								<div class="form-group">
									<label for="clave">Clave:</label>
									<input type="text" class="form-control" v-model.lazy="grupo.clave" id="clave" placeholder="Clave interna"/>
								</div>			
								<div class="form-group">
									<label for="nivelGrupo">Nivel:</label>
									<select id="nivelGrupo" v-model.lazy="grupo.id_nivel" class="form-control">
										<option v-for="nivel in niveles" v-bind:value="nivel.id_nivel"> {{ nivel.nombre }} </option>
									</select>
								</div>	
								<div class="form-group">
									<label for="gradoGrupo">Grado:</label>
									<select id="gradoGrupo" v-model.lazy="grupo.id_grado" class="form-control">
										<option v-for="grado in grados" v-bind:value="grado.id_grado"> {{ grado.nombre }} </option>
									</select>
								</div>																						
								<div class="modal-footer">	
									<button class="btn btn-sm btn-primary" v-on:click="guardarGrupo(grupo, operacion)"> Guardar </button>
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
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/grupos.js"></script>

</body>
</html>