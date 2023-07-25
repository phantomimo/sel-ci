var controlador_docentes = new Vue({
	el: '#controlador_docentes',
	mixins: [funciones],		
	data: {
		cargando_registros: true,
		docente_nuevo: {
			nombre: '',
			apellido_paterno: '',
			apellido_materno: '',			
			curp: '',			
		},
		docentes: []
	},
	methods: {
		recuperarDocentes: function(){
			this.cargando_registros = true;
			this.$http.get('recuperar_docentes').then(function(respuesta){
				this.docentes = respuesta.body;
				this.cargando_registros = false;
			}, function(){
				alert('No se han podido recuperar los docentes.');
				this.cargando_registros = false; 	
			});	
		},
		guardarDocente: function(p_docente, p_operacion){
			event.preventDefault()
			if (!this.validar(p_docente))
				return false
			else {
				switch (p_operacion) {
					case this.opInsertar:
						this.crearDocente(p_docente)
						break
					case this.opModificar:
						this.modificarDocente(p_docente)
						break
				}
				this.modalEdicion = false
			}
		},		
		crearDocente: function(){
			this.$http.post('crear_docente', this.docente_nuevo).then(function(){
				this.docente_nuevo.nombre = '';
				this.docente_nuevo.numero_control = '';
				this.docente_nuevo.apellido_paterno = '';
				this.recuperarDocentes();
				this.notificacion('Registro agregado correctamente!')								
			}, function(){
				alert('No se ha podido crear el docente.');
			});
		},
		modificarDocente: function(p_docente){
			this.$http.post('modificar_docente', p_docente).then(function(){				
				this.notificacion('Registro modificado correctamente!')				
			}, function(){
				alert('No se ha podido modificar el docente.');
			});
		},
		eliminarDocente: function(p_docente){
			if(confirm("Desea eliminar el docente?")){
				this.$http.post('eliminar_docente', p_docente).then(function(){
					this.recuperarDocentes()
				}, function(){
					alert('No se ha podido eliminar el docente.')
				})
			}
		},
		validar: function (p_docente) {
			this.errors = [];			
			if (p_docente.nombre === '') {
			  this.errors.push('El nombre del docente es obligatorio.')
			}
			else
			if (p_docente.apellido_paterno === '') {
				this.errors.push('El apellido paterno del docente es obligatorio.')
			}
			return this.errors.length == 0
		},
		mostrarVentanaEdicion(p_docente, p_operacion) {
			event.preventDefault()			
			this.docente = p_docente
			this.operacion = p_operacion			
			this.modalEdicion = true
			this.errors = []		
			this.docenteAntesEditar = Object.assign({}, this.docente)					
		},
		cerrarModal(){
			Object.assign(this.docente, this.docenteAntesEditar)				
			this.modalEdicion = false
			event.preventDefault()										
        }				
	},
	created: function(){
		this.recuperarDocentes()				
	},	  
	computed: {
		docentesFiltro () {
			filtro = this.textoFiltro.toLowerCase()					
			return this.textoFiltro
				? this.docentes.filter(docente => this.removerAcentos(docente.nombre + ' ' + docente.apellido_paterno + ' ' + docente.apellido_materno).toLowerCase().includes(filtro)
					|| this.removerAcentos(docente.curp).toLowerCase().includes(filtro))
				: this.docentes
		}	
	}	
});
