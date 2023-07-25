var controlador_examenes = new Vue({
	el: '#controlador_examenes',
	mixins: [funciones],		
	data: {
		tituloModulo: 'Exámenes',
		tituloModuloSing: 'examen',
		cargando_registros: false,
		examen_nuevo: {
			clave: '',
			descripcion: '',
			unidad: null,
			total_preguntas: 0,
			tiempo_limite: null,
			fecha_vencimiento: null,
			id_usuario: null,
			id_asignatura: null,
			id_docente: null,
			mostrar_resultados: 'N'
		},
		examenes: [],	
		preguntas: [],					
		niveles: [],
		areas: [],				
		asignaturas: [],		
		grados: [],		
		docentes: [],
		nivel: {
			id_nivel: null,
			nombre: '',
		},
		area: {
			id_area: null,
			nombre: ''
		},
		grado: {
			id_grado: null,
			nombre: ''
		},
		asignatura: {
			id_asignatura: null,
			nombre: '',
			unidades: 0
		},
		docente: {
			id_docente: null,
			nombre: ''
		}
	},
	methods: {
		recuperarExamenesGrado: function(p_grado){
			this.cargando_registros = true;
			this.$http.get('recuperar_examenes_grado/' + p_grado.id_grado).then(function(respuesta){
				this.examenes = respuesta.body
				this.cargando_registros = false
			}, function(){
				alert('No se han podido recuperar los examenes.')
				this.cargando_registros = false 	
			});	
		},
		recuperarExamenesAsignatura: function(p_asignatura, p_nivel){
			event.preventDefault()
			this.cargando_registros = true;
			this.$http.get('recuperar_examenes_asignatura/' + p_asignatura.id_asignatura + '/' + p_nivel.id_nivel).then(function(respuesta){
				this.examenes = respuesta.body
				this.cargando_registros = false
			}, function(){
				alert('No se han podido recuperar los examenes.')
				this.cargando_registros = false 	
			});	
		},
		recuperarNiveles: function(){
			this.$http.get('recuperar_niveles').then(function(respuesta){
				this.niveles = respuesta.body;
			}, function(){
				alert('No se han podido recuperar los niveles.')
			});	
		},			
		recuperarAreas: function(p_nivel){
			this.$http.get('recuperar_areas/' + p_nivel.id_nivel).then(function(respuesta){
				this.areas = respuesta.body;
			}, function(){
				alert('No se han podido recuperar las areas.')
			});
		},			
		recuperarAsignaturas: function(p_area, p_nivel){
			this.$http.get('recuperar_asignaturas/' + p_nivel.id_nivel + '/' + p_area.id_area).then(function(respuesta){
				this.asignaturas = respuesta.body;
			}, function(){
				alert('No se han podido recuperar las asignaturas.')
			});
		},	
		recuperarDocentes: function(){
			this.$http.get('recuperar_docentes').then(function(respuesta){
				this.docentes = respuesta.body;
			}, function(){
				alert('No se han podido recuperar los docentes.');
			});	
		},		
		recuperarGrados: function(p_nivel){
			this.$http.get('recuperar_grados/' + p_nivel.id_nivel).then(function(respuesta){
				this.grados = respuesta.body;
			}, function(){
				alert('No se han podido recuperar los grados.')
			});	
			this.recuperarAsignaturas(p_nivel)			
		},					
		guardarExamen: function(p_examen, p_operacion){
			event.preventDefault()
			// p_examen.nivel = p_nivel.nombre
			p_examen.id_grado = this.grado.id_grado
			p_examen.id_asignatura = this.asignatura.id_asignatura	
			if (!this.validar(p_examen))
				return false
			else {
				switch (p_operacion) {
					case this.opInsertar:
						p_examen.id_nivel = this.nivel.id_nivel												
						this.crearExamen(p_examen)
						break
					case this.opModificar:
						this.modificarExamen(p_examen)
						break
				}
				this.modalEdicion = false
			}
		},
		crearExamen: function(p_examen){
			this.$http.post('crear_examen', p_examen).then(function(){
				this.recuperarExamenesAsignatura(this.asignatura, this.nivel)
				this.notificacion('Registro agregado correctamente!')								
				// this.preguntas.push(p_pregunta)					
				this.examen_nuevo = {}					
			}, function(){
				alert('No se ha podido crear el examen.')
			});
		},
		modificarExamen: function(p_examen){
			this.$http.post('modificar_examen', p_examen).then(function(){				
				this.notificacion('Registro modificado correctamente!')				
			}, function(){
				alert('No se ha podido modificar el examen.')
			});
		},
		eliminarExamen: function(p_examen){
			if(confirm("Desea eliminar el examen?")){
				this.$http.post('eliminar_examen', p_examen).then(function(){
					this.recuperarExamenesAsignatura(this.asignatura, this.nivel)
				}, function(){
					alert('No se ha podido eliminar el examen.')
				})
			}
		},		
		validar: function (p_examen) {
			this.errors = []			
			if (p_examen.clave === '') {
			  this.errors.push('La clave de examen es un dato requerido.')
			}
			else if (p_examen.descripcion === '') {
				this.errors.push('La descripción del examen es un dato requerido.')
			}  
			else if (p_examen.id_asignatura <= 0) {
				this.errors.push('La asignatura del examen es un dato obligatorio.')
			}									
			else if (p_examen.id_docente <= 0) {
				this.errors.push('El docente del examen es un dato obligatorio.')
			}				
			return this.errors.length == 0
		},
		mostrarVentanaEdicion(p_examen, p_operacion) {
			event.preventDefault()
			this.examen = p_examen
			this.operacion = p_operacion
			this.modalEdicion = true
			this.errors = []
			this.examenAntesEditar = Object.assign({}, this.examen)				
		},
		cerrarModal(){
			Object.assign(this.examen, this.examenAntesEditar)						
			this.modalEdicion = false
			event.preventDefault()								
		},
		editarExamen: function (p_examen) { 
			window.open("examenes/editar/" + p_examen.id_examen, "_blank");    			
		}
	},
	created: function(){
		this.recuperarNiveles()  	
		this.recuperarDocentes()	
		if (this.id_examen > 0)
			recuperarPreguntas(id_examen)
		document.title = this.tituloModulo + ' - ' + this.nombreAplicacion					
	},		  
	computed: {
		examenesFiltro () {
			filtro = this.textoFiltro.toLowerCase()			
			return this.textoFiltro
				? this.examenes.filter(examen => this.removerAcentos(examen.clave).toLowerCase().includes(filtro) 
					|| this.removerAcentos(examen.descripcion).toLowerCase().includes(filtro) 
					|| this.removerAcentos(examen.docente).toLowerCase().includes(filtro))
				: this.examenes
		}	
	},	
	components: {
		vuejsDatepicker,
		Multiselect: window.VueMultiselect.default		
	}	
});
