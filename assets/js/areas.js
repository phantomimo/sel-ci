var controlador_areas = new Vue({
	el: '#controlador_areas',
	mixins: [funciones],			
	data: {
		tituloModulo: 'Áreas',		
		cargando_registros: true,
		area_nueva: {
			nombre: '',
			clave: ''
		},
		areas: [],
		niveles: [],
		errors: [],		
	},
	methods: {
		recuperarAreas: function(){
			this.cargando_registros = true;
			this.$http.get('recuperar_areas').then(function(respuesta){
				this.areas = respuesta.body;				
				this.cargando_registros = false;
			}, function(){
				alert('No se han podido recuperar las áreas.');
				this.cargando_registros = false; 	
			});	
		},
		recuperarNiveles: function(){
			this.$http.get('recuperar_niveles').then(function(respuesta){
				this.niveles = respuesta.body;
			}, function(){
				alert('No se han podido recuperar los niveles.')
			});	
		},			
		guardarArea: function(p_area, p_operacion){
			event.preventDefault()
			if (!this.validar(p_area))
				return false
			else {
				switch (p_operacion) {
					case this.opInsertar:
						this.crearArea(p_area)
						break
					case this.opModificar:
						this.modificarArea(p_area)
						break
				}
				this.modalEdicion = false
			}
		},			
		crearArea: function(){
			this.$http.post('crear_area', this.area_nueva).then(function(){
				this.area_nueva.nombre = ''
				this.area_nueva.clave = ''
				this.recuperarAreas()
				this.notificacion('Registro agregado correctamente!')
			}, function(){
				alert('No se ha podido crear el area.')
			});
		},
		modificarArea: function(p_area){
			this.$http.post('modificar_area', p_area).then(function(){				
				this.recuperarAreas()
				this.notificacion('Registro modificado correctamente!')				
			}, function(){
				alert('No se ha podido modificar el area.');
			});
		},
		eliminarArea: function(p_area){
			if(confirm("Desea eliminar el area?")){
				this.$http.post('eliminar_area', p_area).then(function(){
					this.recuperarAreas()
				}, function(){
					alert('No se ha podido eliminar el area.')
				})
			}
		},
		validar: function (p_area) {
			this.errors = [];			
			if (p_area.nombre === '') {
			  this.errors.push('El nombre del area es obligatorio.')
			}
			return this.errors.length == 0
		},
		mostrarVentanaEdicion(p_area, p_operacion) {
			event.preventDefault()			
			this.area = p_area
			this.modalEdicion = true
			this.operacion = p_operacion			
			this.errors = []	
			this.areaAntesEditar = Object.assign({}, this.area)				
		},
		cerrarModal(){
			Object.assign(this.area, this.areaAntesEditar)						
			this.modalEdicion = false
			event.preventDefault()								
        }	
	},
	created: function(){
		this.recuperarNiveles()
		this.recuperarAreas()
		document.title = this.tituloModulo + ' - ' + this.nombreAplicacion					
	},		  
	computed: {
		areasFiltro () {
			filtro = this.textoFiltro.toLowerCase()			
			return this.textoFiltro
				? this.areas.filter(area => this.removerAcentos(area.nombre).toLowerCase().includes(filtro) 
					|| this.removerAcentos(area.clave).toLowerCase().includes(filtro))
				: this.areas
		}	
	},
	components: {
		Multiselect: window.VueMultiselect.default
	}

});
