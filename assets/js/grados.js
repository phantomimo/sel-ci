var controlador_grados = new Vue({
	el: '#controlador_grados',
	mixins: [funciones],			
	data: {
		cargando_registros: true,
		grado_nuevo: {
			nombre: '',
			clave: '',
			id_nivel: null
		},
		grados: [],
		niveles: [],		
		errors: [],
	},
	methods: {
		recuperarGrados: function(){
			this.cargando_registros = true;
			this.$http.get('recuperar_grados').then(function(respuesta){
				this.grados = respuesta.body;
				this.cargando_registros = false;
			}, function(){
				alert('No se han podido recuperar los grados.');
				this.cargando_registros = false; 	
			});	
		},
		recuperarNiveles: function(){
			this.$http.get('recuperar_niveles').then(function(respuesta){
				this.niveles = respuesta.body;
				this.cargando_registros = false;
			}, function(){
				alert('No se han podido recuperar los niveles.')
			});	
		},			
		guardarGrado: function(p_grado, p_operacion){
			event.preventDefault()
			if (!this.validar(p_grado))
				return false
			else {
				switch (p_operacion) {
					case this.opInsertar:
						this.crearGrado(p_grado)
						break
					case this.opModificar:
						this.modificarGrado(p_grado)
						break
				}
				this.modalEdicion = false
			}
		},			
		crearGrado: function(){
			this.$http.post('crear_grado', this.grado_nuevo).then(function(){
				this.grado_nuevo.nombre = '';
				this.grado_nuevo.clave = '';
				this.grado_nuevo.id_nivel = null;				
				this.recuperarGrados();
				this.notificacion('Registro agregado correctamente!')								
			}, function(){
				alert('No se ha podido crear el grado.');
			});
		},
		modificarGrado: function(p_grado){
			this.$http.post('modificar_grado', p_grado).then(function(){				
				this.notificacion('Registro modificado correctamente!')				
			}, function(){
				alert('No se ha podido modificar el grado.');
			});
		},
		eliminarGrado: function(p_grado){
			if(confirm("Desea eliminar el registro?")){
				this.$http.post('eliminar_grado', p_grado).then(function(){
					this.recuperarGrados()
				}, function(){
					alert('No se ha podido eliminar el grado.')
				})
			}
		},
		validar: function (p_grado) {
			this.errors = [];			
			if (p_grado.nombre === '') {
			  this.errors.push('El nombre del grado es obligatorio.')
			}
			return this.errors.length == 0
		},
		mostrarVentanaEdicion(p_grado, p_operacion) {
			event.preventDefault()			
			this.grado = p_grado
			this.modalEdicion = true
			this.operacion = p_operacion			
			this.errors = []	
			this.gradoAntesEditar = Object.assign({}, this.grado)				
		},
		cerrarModal(){
			Object.assign(this.grado, this.gradoAntesEditar)						
			this.modalEdicion = false
			event.preventDefault()								
        }	
	},
	created: function(){
		this.recuperarNiveles()		
		this.recuperarGrados()		
	},		  
	computed: {
		gradosFiltro () {
			filtro = this.textoFiltro.toLowerCase()			
			return this.textoFiltro
				? this.grados.filter(grado => this.removerAcentos(grado.nombre).toLowerCase().includes(filtro) 
					|| this.removerAcentos(grado.clave).toLowerCase().includes(filtro))
				: this.grados
		}	
	}	
});
