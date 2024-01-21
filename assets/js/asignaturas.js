var controlador_asignaturas = new Vue({
	el: '#controlador_asignaturas',
	mixins: [funciones],		
	data: {
		tituloModulo: 'Asignaturas',		
		cargando_registros: true,
		asignatura_nueva: {
			nombre: '',
			clave: '',			
			descripcion: '',
			unidades: null,
			id_area: null,
			id_nivel: null,
			id_grado: null,
			niveles: []
		},
		asignaturas: [],		
		areas: [],
		niveles: []
	},
	methods: {
		recuperarAsignaturas: function(){
			this.cargando_registros = true;
			this.$http.get('recuperar_asignaturas').then(function(respuesta){
				this.asignaturas = respuesta.body
				this.cargando_registros = false
			}, function(){
				alert('No se han podido recuperar las asignaturas.')
				this.cargando_registros = false 	
			});	
		},
		guardarAsignatura: function(p_asignatura, p_operacion){
			event.preventDefault()
			if (!this.validar(p_asignatura))
				return false
			else {
				switch (p_operacion) {
					case this.opInsertar:
						this.crearAsignatura(p_asignatura)
						break
					case this.opModificar:
						this.modificarAsignatura(p_asignatura)
						break
				}
				this.modalEdicion = false
			}
		},
		crearAsignatura: function(p_asignatura){
			this.$http.post('crear_asignatura', p_asignatura).then(function(){
				p_asignatura.nombre = ''
				p_asignatura.clave = ''				
				p_asignatura.descripcion = ''
				p_asignatura.unidades = null
				p_asignatura.id_area = null
				p_asignatura.id_nivel = null				
				this.recuperarAsignaturas()
				this.notificacion('Registro agregado correctamente!')								
			}, function(){
				alert('No se ha podido crear la asignatura.')
			});
		},
		modificarAsignatura: function(p_asignatura){
			this.$http.post('modificar_asignatura', p_asignatura).then(function(){				
				this.notificacion('Registro modificado correctamente!')								
			}, function(){
				alert('No se ha podido modificar la asignatura.')
			});
		},
		eliminarAsignatura: function(p_asignatura){
			if(confirm("Desea eliminar la registro?")){
				this.$http.post('eliminar_asignatura', p_asignatura).then(function(){
					this.recuperarAsignaturas()
				}, function(){
					alert('No se ha podido eliminar la asignatura.')
				})
			}
		},
		recuperarAreas: function(){
			this.$http.get('recuperar_areas').then(function(respuesta){
				this.areas = respuesta.body;
			}, function(){
				alert('No se han podido recuperar las areas.')
			});
		},		
		recuperarNiveles: function(){
			this.$http.get('recuperar_niveles').then(function(respuesta){
				this.niveles = respuesta.body;				
			}, function(){
				alert('No se han podido recuperar los niveles.')
			});	
		},		
		validar: function (p_asignatura) {
			this.errors = []			
			if (p_asignatura.nombre === '') {
			  this.errors.push('El nombre de la asignatura es obligatorio.')
			}
			else if (p_asignatura.clave === '') {
				this.errors.push('La clave de la asignatura es obligatorio.')
			  }			
			else if (p_asignatura.id_area <= 0) {
				this.errors.push('El área de la asignatura es obligatorio.')
			}			
			return this.errors.length == 0
		},
		mostrarVentanaEdicion(p_asignatura, p_operacion) {
			event.preventDefault()			
			this.asignatura = p_asignatura
			this.operacion = p_operacion
			this.modalEdicion = true
			this.errors = []
			this.asignaturaAntesEditar = Object.assign({}, this.asignatura)				
		},
		cerrarModal(){
			Object.assign(this.asignatura, this.asignaturaAntesEditar)						
			this.modalEdicion = false
			event.preventDefault()								
        }
	},
	created: function(){
		this.recuperarAreas()
		this.recuperarNiveles()
		this.recuperarAsignaturas()		
		document.title = this.tituloModulo + ' - ' + this.nombreAplicacion								
	},		  
	computed: {
		asignaturasFiltro () {
			filtro = this.textoFiltro.toLowerCase()			
			return this.textoFiltro
				? this.asignaturas.filter(asignatura => this.removerAcentos(asignatura.nombre).toLowerCase().includes(filtro) 
					|| this.removerAcentos(asignatura.clave).toLowerCase().includes(filtro) 				
					|| this.removerAcentos(asignatura.descripcion).toLowerCase().includes(filtro) 
					|| this.removerAcentos(asignatura.area).toLowerCase().includes(filtro)
					|| this.removerAcentos(asignatura.nivel).toLowerCase().includes(filtro))
				: this.asignaturas
		}	
	},
	components: {
		Multiselect: window.VueMultiselect.default
	}
});
