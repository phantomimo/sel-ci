var controlador_niveles = new Vue({
	el: '#controlador_niveles',
	mixins: [funciones],			
	data: {
		cargando_registros: true,
		nivel_nuevo: {
			nombre: '',
			clave: ''
		},
		niveles: [],
		errors: [],
	},
	methods: {
		recuperarNiveles: function(){
			this.cargando_registros = true;
			this.$http.get('recuperar_niveles').then(function(respuesta){
				this.niveles = respuesta.body;
				this.cargando_registros = false;
			}, function(){
				alert('No se han podido recuperar los niveles.');
				this.cargando_registros = false; 	
			});	
		},
		guardarNivel: function(p_nivel, p_operacion){
			event.preventDefault()
			if (!this.validar(p_nivel))
				return false
			else {
				switch (p_operacion) {
					case this.opInsertar:
						this.crearNivel(p_nivel)
						break
					case this.opModificar:
						this.modificarNivel(p_nivel)
						break
				}
				this.modalEdicion = false
			}
		},			
		crearNivel: function(){
			this.$http.post('crear_nivel', this.nivel_nuevo).then(function(){
				this.nivel_nuevo.nombre = '';
				this.nivel_nuevo.clave = '';
				this.recuperarNiveles();
				this.notificacion('Registro agregado correctamente!')								
			}, function(){
				alert('No se ha podido crear el nivel.');
			});
		},
		modificarNivel: function(p_nivel){
			this.$http.post('modificar_nivel', p_nivel).then(function(){				
				this.notificacion('Registro modificado correctamente!')				
			}, function(){
				alert('No se ha podido modificar el nivel.');
			});
		},
		eliminarNivel: function(p_nivel){
			if(confirm("Desea eliminar el registro?")){
				this.$http.post('eliminar_nivel', p_nivel).then(function(){
					this.recuperarNiveles()
				}, function(){
					alert('No se ha podido eliminar el nivel.')
				})
			}
		},
		validar: function (p_nivel) {
			this.errors = [];			
			if (p_nivel.nombre === '') {
			  this.errors.push('El nombre del nivel es obligatorio.')
			}
			return this.errors.length == 0
		},
		mostrarVentanaEdicion(p_nivel, p_operacion) {
			event.preventDefault()			
			this.nivel = p_nivel
			this.modalEdicion = true
			this.operacion = p_operacion			
			this.errors = []	
			this.nivelAntesEditar = Object.assign({}, this.nivel)				
		},
		cerrarModal(){
			Object.assign(this.nivel, this.nivelAntesEditar)						
			this.modalEdicion = false
			event.preventDefault()								
        }	
	},
	created: function(){
		this.recuperarNiveles();		
	},		  
	computed: {
		nivelesFiltro () {
			filtro = this.textoFiltro.toLowerCase()			
			return this.textoFiltro
				? this.niveles.filter(nivel => this.removerAcentos(nivel.nombre).toLowerCase().includes(filtro) 
					|| this.removerAcentos(nivel.clave).toLowerCase().includes(filtro))
				: this.niveles
		}	
	}	
});
