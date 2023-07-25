var controlador_grupos = new Vue({
	el: '#controlador_grupos',
	mixins: [funciones],			
	data: {
		cargando_registros: true,
		grupo_nuevo: {
			nombre: '',
			clave: '',
			id_nivel: null,
			id_grado: null			
		},
		niveles: [],		
		grados: [],		
		grupos: [],				
		errors: [],
	},
	methods: {
		recuperarGrupos: function(){
			this.cargando_registros = true
			this.$http.get('recuperar_grupos').then(function(respuesta){
				this.grupos = respuesta.body
				this.cargando_registros = false
			}, function(){
				alert('No se han podido recuperar los grupos.')
				this.cargando_registros = false 	
			})	
		},		
		recuperarNiveles: function(){
			this.$http.get('recuperar_niveles').then(function(respuesta){
				this.niveles = respuesta.body
			}, function(){
				alert('No se han podido recuperar los niveles.')
			})	
		},			
		recuperarGrados: function(){
			this.$http.get('recuperar_grados').then(function(respuesta){
				this.grados = respuesta.body
			}, function(){
				alert('No se han podido recuperar los grados.')
			})	
		},			
		guardarGrupo: function(p_grupo, p_operacion){
			event.preventDefault()
			if (!this.validar(p_grupo))
				return false
			else {
				switch (p_operacion) {
					case this.opInsertar:
						this.crearGrupo(p_grupo)
						break
					case this.opModificar:
						this.modificarGrupo(p_grupo)
						break
				}
				this.modalEdicion = false
			}
		},			
		crearGrupo: function(){
			this.$http.post('crear_grupo', this.grupo_nuevo).then(function(){
				this.grupo_nuevo.nombre = ''
				this.grupo_nuevo.clave = ''
				this.grupo_nuevo.id_nivel = null				
				this.grupo_nuevo.id_grado = null								
				this.notificacion('Registro agregado correctamente!')								
				this.recuperarGrupos()				
			}, function(){
				alert('No se ha podido crear el grupo.')
			})
		},
		modificarGrupo: function(p_grupo){
			this.$http.post('modificar_grupo', p_grupo).then(function(){				
				this.notificacion('Registro modificado correctamente!')		
				this.recuperarGrupos()												
			}, function(){
				alert('No se ha podido modificar el grupo.')
			})
		},
		eliminarGrupo: function(p_grupo){
			if(confirm("Desea eliminar el grupo?")){
				this.$http.post('eliminar_grupo', p_grupo).then(function(){
					this.recuperarGrupos()
				}, function(){
					alert('No se ha podido eliminar el grupo.')
				})
			}
		},
		validar: function (p_grupo) {
			this.errors = []			
			if (p_grupo.nombre === '') {
			  this.errors.push('El nombre del grupo es obligatorio.')
			}
			return this.errors.length == 0
		},
		mostrarVentanaEdicion(p_grupo, p_operacion) {
			event.preventDefault()
			this.grupo = p_grupo
			this.modalEdicion = true
			this.operacion = p_operacion			
			this.errors = []	
			this.grupoAntesEditar = Object.assign({}, this.grupo)				
		},
		cerrarModal(){
			Object.assign(this.grupo, this.grupoAntesEditar)						
			this.modalEdicion = false
			event.preventDefault()								
        }	
	},
	created: function(){
		this.recuperarNiveles()		
		this.recuperarGrados()						
		this.recuperarGrupos()		
	},		  
	computed: {
		gruposFiltro () {
			filtro = this.textoFiltro.toLowerCase()			
			return this.textoFiltro
				? this.grupos.filter(grupo => this.removerAcentos(grupo.nombre).toLowerCase().includes(filtro) 
					|| this.removerAcentos(grupo.clave).toLowerCase().includes(filtro))
				: this.grupos
		}	
	}	
})
