<html>
<head>
	<meta charset="utf-8" />
	<title> <?php echo APLICACION_NOMBRE ?> - Lista de usuarios </title>
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/jquery-3.7.0.min.js"></script>	
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/bootstrap.min.js"></script>	
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/md5.js"></script>	   	
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/bootstrap-responsive.min.css" />
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/sel.css?1.0.1.110620" />	
	<link rel="stylesheet" href="<?php echo base_url() ?>assets/css/open-iconic-bootstrap.min.css">	
	<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">		
	<link rel="stylesheet" type="text/css" href="<?php echo base_url() ?>assets/css/components/vue-multiselect.min.css" />	
</head>
<body>
	<div class="container" id="controlador_usuarios" v-cloak>
		<menu-principal url_base="<?php echo base_url() ?>" nombre_aplicacion="<?php echo APLICACION_NOMBRE ?>"></menu-principal>		
		<h3> Usuarios </h3>
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
					<th> Cargo </th>						
					<th class="operaciones-tabla"> <button class="btn btn-sm btn-primary" v-on:click="mostrarVentanaEdicion(usuario_nuevo, opInsertar)"> Nuevo </button> </th>
				</tr>
			</thead>
			<tbody>
				<tr v-for="usuario in usuariosFiltro" @click="activarFila(usuario.id_usuario)" :class="{ active: filaActiva == usuario.id_usuario }">
					<td>{{ usuario.nombre }}</td>						
					<td>{{ usuario.cargo }}</td>						
					<td class="operaciones-tabla">
						<button class="btn btn-sm" v-on:click="mostrarVentanaEdicion(usuario, opModificar)"> <span class="oi oi-pencil" title="Modificar" aria-hidden="true"></span> </button>
						<button class="btn btn-sm" v-on:click="eliminarUsuario(usuario)"> <span class="oi oi-trash" title="Eliminar" aria-hidden="true"> </button>
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
							<form @submit.native.prevent="guardarUsuario(usuario, operacion)">								
								<div class="form-group">
									<label for="nombreusuario">Nombre:</label>
									<input type="text" class="form-control" v-model.lazy="usuario.nombre" id="nombreusuario" placeholder="Nombre del usuario" v-focus/>
								</div>									
								<div class="form-group">
									<label for="contrasenia">Contraseña:</label>
									<input type="password" class="form-control" v-model="usuario.contrasenia" @input="verificarCambiosContrasenia(usuario)" id="contrasenia" placeholder="Contraseña"/>
								</div>	
								<div class="form-group">
									<label for="cargo">Cargo:</label>
									<input type="text" class="form-control" v-model.lazy="usuario.cargo" id="cargo" placeholder="Cargo/Puesto del usuario"/>
								</div>																
								<div class="modal-footer">	
									<button class="btn btn-sm btn-primary" v-on:click="guardarUsuario(usuario, operacion)"> Guardar </button>
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
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/funciones.js?1.0.3"></script>				
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/usuarios.js?1.0.2"></script>

</body>
</html>