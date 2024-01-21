var controlador_usuarios = new Vue({
	el: '#controlador_usuarios',
	mixins: [funciones],		
	data: {		
		tituloModulo: 'Usuarios',		
		tituloModuloSing: 'usuario',
		cargando_registros: true,
		usuario_nuevo: {
			id_usuario: null,
			nombre_entrada: '',
			nombre: '',
			contrasenia: '',
			cargo: '',
			es_visible: 'S',
			modificar_contrasenia: false
		},			
		usuarios: [],
		indice: null		
	},
	methods: {
		recuperarUsuarios: function(){
			this.cargando_registros = true
			this.$http.get('recuperar_usuarios').then(function(respuesta){
				this.usuarios = respuesta.body
				this.cargando_registros = false
			}, function(){
				alert('No se han podido recuperar los usuarios.')
				this.cargando_registros = false 	
			})	
		},	
		guardarUsuario: function(p_usuario, p_operacion){
			event.preventDefault()
			if (p_usuario.modificar_contrasenia == this.VALOR_SI)
				p_usuario.contrasenia = CryptoJS.MD5(p_usuario.contrasenia).toString()
			if (!this.validar(p_usuario))
				return false
			else {
				switch (p_operacion) {
					case this.opInsertar:
						this.crearUsuario(p_usuario)
						break
					case this.opModificar:
						this.modificarUsuario(p_usuario)
						break
				}
				this.modalEdicion = false
			}
		},		
		crearUsuario: function(){
			this.$http.post('crear_usuario', this.usuario_nuevo).then(function(){
				this.usuario_nuevo.nombre = ''
				this.usuario_nuevo.contrasenia = ''
				this.usuario_nuevo.cargo = ''
				this.recuperarUsuarios()
				this.notificacion('Usuario agregado correctamente!')				
			}, function(){
				alert('No se ha podido crear el usuario.')
			})
		},
		modificarUsuario: function(p_usuario){
			this.$http.post('modificar_usuario', p_usuario).then(function(){	
				p_usuario.contrasenia = ''
				p_usuario.modificar_contrasenia = this.VALOR_NO							
				this.notificacion('Usuario modificado correctamente!')								
			}, function(){
				alert('No se ha podido modificar el usuario.')
			})
		},
		eliminarUsuario: function(p_usuario){
			if(confirm("Desea eliminar el registro?")){
				this.$http.post('eliminar_usuario', p_usuario).then(function(){
					this.recuperarUsuarios()
				}, function(){
					alert('No se ha podido eliminar el usuario.')
				})
			}
		},		
		obtenerDatosUsuario: function(p_usuario){
			this.$http.get('obtener_datos_usuario/' + p_usuario.id_usuario).then(function(respuesta){
				this.usuarios[this.indice] = respuesta.body
			}, function(){
				alert('No se han podido recuperar los datos del usuario.')
			})	
		},		
		validar: function (p_usuario) {
			this.errors = []			
			if (p_usuario.nombre === '') {
			  this.errors.push('El nombre del usuario es obligatorio.')
			}
			else
			if (p_usuario.contrasenia === '') {
				this.errors.push('La contraseña es un dato obligatorio.')
			}
			return this.errors.length == 0
		},
		mostrarVentanaEdicion(p_usuario, p_operacion) {
			event.preventDefault()				
			this.usuario = p_usuario
			this.operacion = p_operacion			
			this.modalEdicion = true
			this.errors = []		
			this.usuarioAntesEditar = Object.assign({}, this.usuario)						
		},
		cerrarModal(){
			event.stopPropagation
			Object.assign(this.usuario, this.usuarioAntesEditar)	
            this.modalEdicion = false            									
		},
		verificarCambiosContrasenia(p_usuario){
			if (p_usuario.contrasenia.length > 0)
				p_usuario.modificar_contrasenia = this.VALOR_SI
		}
	},
	created: function(){
		this.recuperarUsuarios()	
		document.title = this.tituloModulo + ' - ' + this.nombreAplicacion									
	},	  
	computed: {
		usuariosFiltro () {
			filtro = this.textoFiltro.toLowerCase()
			return this.textoFiltro
				? this.usuarios.filter(usuario => this.removerAcentos(usuario.nombre + ' ' + usuario.apellido_paterno + ' ' + usuario.apellido_materno).toLowerCase().includes(filtro) 
					|| this.removerAcentos(usuario.numero_control).toLowerCase().includes(filtro) || this.removerAcentos(usuario.curp).toLowerCase().includes(filtro))
				: this.usuarios
		}	
	}	
})
