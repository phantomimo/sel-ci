var vm = new Vue({
	el: '#controlador_examen',
	mixins: [funciones],		
	data: {
		tituloModulo: 'Editar examen',
		tituloModuloSing: 'pregunta',
		cargando_registros: false,
		examen: {
			clave: '',
			descripcion: '',
			unidad: null,
			total_preguntas: 0,
			tiempo_limite: null,
			id_usuario: null,
			id_nivel: null,
			nivel: '',
			id_grado: null,
			grado: '',
			id_asignatura: null,
			asignatura: '',
			id_docente: null,
			docente: ''
		},
		pregunta_nueva: {
			numero: 0,			
			pregunta: '',
			opcion1: '',
			opcion2: '',			
			opcion3: '',
			opcion4: '',						
			respuesta: 0,			
			valor_reactivo: 0,
			id_asignatura: null,
			asignatura: null,
			id_nivel: null,
			nivel: null
		},		
		preguntas: [],		
		asignaturas: [],
		niveles: [],
		grados: [],		
		docentes: [],		
		nivel: {
			id_nivel: null,
			nombre: '',
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
		},
		respuestas: [
			{'clave': 'a', 'valor': 1},
			{'clave': 'b', 'valor': 2},
			{'clave': 'c', 'valor': 3},			
			{'clave': 'd', 'valor': 4},
		],
		textoPregunta: '',
		preguntas_busqueda: [],
		cargando_registros_busqueda: false,
		suneditor: null,
		editorAvanzado: false
	},
	methods: {
		recuperarExamen: function(id_examen){			
			this.$http.get('recuperar_examen/' + id_examen).then(function(respuesta){
				this.examen = respuesta.body[0]
				this.asignatura.id_asignatura = this.examen.id_asignatura
				this.asignatura.nombre = this.examen.asignatura
				this.asignatura.unidades = this.examen.unidades
				this.nivel.id_nivel = this.examen.id_nivel
				this.nivel.nombre = this.examen.nivel
				document.title = this.tituloModulo + ' [' + this.examen.clave + '] - ' + this.nombreAplicacion						
			}, function(){
				alert('No se han podido recuperar los datos del examen.')
			});	
		},
		recuperarPreguntas: function (id_examen){
			this.cargando_registros = true
			this.$http.get('recuperar_preguntas_examen/' + id_examen).then(function(respuesta){
				this.preguntas = respuesta.body
				this.cargando_registros = false
			}, function(){
				alert('No se han podido recuperar las preguntas del examen.')
				this.cargando_registros = false 	
			})	
		},			
		recuperarAsignaturas: function(p_nivel){
			this.$http.get('recuperar_asignaturas/' + p_nivel.id_nivel).then(function(respuesta){
				this.asignaturas = respuesta.body;
			}, function(){
				alert('No se han podido recuperar las asignaturas.')
			});
		},		
		obtenerNuevoNumero: function (p_pregunta) {
			this.$http.get('obtener_nuevo_numero_examen_pregunta/' + this.examen.id_examen).then(function(respuesta){
				p_pregunta.numero =  parseInt(respuesta.body)
			}, function(){
				alert('No se han podido recuperar el número consecutivo.')
			})
		},	
		buscarPreguntas: function (texto_pregunta){
			event.preventDefault() 				
			if (texto_pregunta.trim() == '')
				return
			this.cargando_registros_busqueda = true
			texto_pregunta = texto_pregunta.toLowerCase()
			this.$http.post('buscar_preguntas/', {texto_pregunta}).then(function(respuesta){
				this.preguntas_busqueda = respuesta.body
				this.cargando_registros_busqueda = false
			}, function(){
				alert('No se han podido recuperar las preguntas del examen.')
				this.cargando_registros_busqueda = false 	
			})	
		},					
		agregarPregunta: function (p_pregunta) {
			this.$http.get('obtener_nuevo_numero_examen_pregunta/' + this.examen.id_examen).then(function(respuesta){				
				p_pregunta.numero = parseInt(respuesta.body)
				p_pregunta.id_examen = this.examen.id_examen						
				this.$http.post('agregar_pregunta_examen', p_pregunta).then(function(){				
					this.notificacion('Pregunta agregada correctamente!')
					this.preguntas.push(p_pregunta)					
				}, function(){
					alert('Ocurrió un error al intentar agregar la pregunta al examen.')	
					return
				})			
			}, function(){
				alert('No se han podido recuperar el número consecutivo.')
			})			
			this.cerrarModalBusqueda()				
		},
		guardarPregunta: function(p_pregunta, p_asignatura, p_operacion){
			event.preventDefault()
			if (this.editorAvanzado)
				p_pregunta.pregunta = this.suneditor.getContents()	
			else {
				p_pregunta.pregunta = this.unicodeToChar(p_pregunta.pregunta).replace(/\\n|\\r|\\/g, '')
				p_pregunta.opcion1 = this.unicodeToChar(p_pregunta.opcion1).replace(/\\n|\\r|\\/g, '')
				p_pregunta.opcion2 = this.unicodeToChar(p_pregunta.opcion2).replace(/\\n|\\r|\\/g, '')
				p_pregunta.opcion3 = this.unicodeToChar(p_pregunta.opcion3).replace(/\\n|\\r|\\/g, '')
				p_pregunta.opcion4 = this.unicodeToChar(p_pregunta.opcion4).replace(/\\n|\\r|\\/g, '')
			}	
			p_pregunta.id_asignatura = p_asignatura.id_asignatura
			p_pregunta.valor_reactivo = parseFloat(p_pregunta.valor_reactivo)
			if (!this.validar(p_pregunta))
				return false
			else {
				switch (p_operacion) {
					case this.opInsertar: 
						this.crearPregunta(p_pregunta, p_asignatura)
						break
					case this.opModificar:
						this.modificarPregunta(p_pregunta)
						break
				}
				this.modalEdicion = false			
			}
			this.activarFila(p_pregunta.id_pregunta)
		},
		crearPregunta: function(p_pregunta, p_asignatura){
			this.$http.post('crear_pregunta', p_pregunta).then(function(response){
				p_pregunta.id_pregunta = response.data
				this.agregarPregunta(p_pregunta)	
				// this.recuperarPreguntas(this.examen)	
			}, function(){
				alert('Ocurrió un error al intentar guardar la pregunta en el banco de preguntas.')	
			})
		},
		modificarPregunta: function(p_pregunta){			
			this.$http.post('modificar_pregunta', p_pregunta).then(function(){				
				this.notificacion('Pregunta modificada correctamente!')
			}, function(){
				alert('Ocurrió un error al intentar guardar los cambios.')	
			})
		},
		eliminarPregunta: function(p_pregunta){
			if(confirm("Desea eliminar la pregunta del examen?")){
				p_pregunta.id_examen = this.examen.id_examen
				this.$http.post('eliminar_pregunta_examen', p_pregunta).then(function(){	
					this.$http.post('eliminar_pregunta', p_pregunta).then(function(){
						this.notificacion('Pregunta eliminada correctamente!')
						this.recuperarPreguntas(this.examen.id_examen)
					}, function(){
						alert('No se ha podido eliminar la pregunta del banco de preguntas')
					})									
				}, function(){
					alert('No se ha podido eliminar la pregunta del examen') 
				})
			}
		},
		modificarExamen: function(p_examen){
			this.$http.post('modificar_examen', p_examen).then(function(){				
				this.notificacion('Registro modificado correctamente!')				
			}, function(){
				alert('No se ha podido modificar el examen.')
			})
		},	
		inicializarPregunta: function (p_pregunta) {
			p_pregunta.numero = 0
			p_pregunta.pregunta = ''
			p_pregunta.opcion1 = ''
			p_pregunta.opcion2 = ''			
			p_pregunta.opcion3 = ''
			p_pregunta.opcion4 = ''
			p_pregunta.respuesta = 0
			p_pregunta.valor_reactivo = null
		},
		validar: function (p_pregunta) {
			this.errors = []			
			if (p_pregunta.pregunta === '') {
				this.errors.push('El texto de la pregunta es un dato requerido.')
			}
			else if (p_pregunta.id_asignatura <= 0) {
				this.errors.push('La asignatura es un dato requerido.')
			}			
			else if (p_pregunta.valor_reactivo == 0) {
				this.errors.push('El valor del reactivo es un dato requerido.')
			}		
			return this.errors.length == 0
		},
		sleep: function (ms) {
			return new Promise(resolve => setTimeout(resolve, ms));
		},
		mostrarVentanaEdicion (p_pregunta, p_asignatura, p_operacion) {
			event.preventDefault()					
			// this.pregunta = p_pregunta
			if (p_operacion == this.opInsertar) {
				//p_pregunta = this.pregunta_nueva
				// p_pregunta = Object.assign({}, this.pregunta_nueva)							
				this.obtenerNuevoNumero(p_pregunta)				
				this.sleep(300).then(() => { 					
					this.pregunta = Object.assign({}, p_pregunta)
					this.pregunta.id_asignatura = p_asignatura.id_asignatura
					this.pregunta.asignatura = p_asignatura.nombre
					this.asignatura = p_asignatura	
					this.operacion = p_operacion
					this.modalEdicion = true		
				})					
			}			
			else {
				this.pregunta = p_pregunta
				this.pregunta.id_asignatura = p_asignatura.id_asignatura
				this.pregunta.asignatura = p_asignatura.nombre
				this.asignatura = p_asignatura	
				this.operacion = p_operacion
				this.modalEdicion = true	
			}
			// this.$nextTick(function () {
			// 	this.mostrarEditor()									  			
			// })			
			this.errors = []
			this.preguntaAntesEditar = Object.assign({}, this.pregunta)				
			this.editorAvanzado = false						
		},
		mostrarVentanaBusqueda () {
			event.preventDefault()				
			this.preguntas_busqueda = []
			this.modalBusqueda = true
		},		
		cerrarModal(){
			Object.assign(this.pregunta, this.preguntaAntesEditar)	
			this.modalEdicion = false
			event.preventDefault()								
		},
		cerrarModalBusqueda(){
			this.modalBusqueda = false
			event.preventDefault()								
		},
		mostrarEditor()	{	
			event.preventDefault()
			this.editorAvanzado = true
			this.suneditor = SUNEDITOR.create('texto-pregunta', {
				display: 'block',
				width: '100%',
				height: 'auto',
				popupDisplay: 'full',
				charCounter: true,
				maxCharCount: 3000,
				charCounterLabel: 'Caracteres:',
				buttonList: [
					['undo', 'redo'],
					['font', 'fontSize', 'formatBlock'],
					['paragraphStyle', 'blockquote'],
					['bold', 'underline', 'italic', 'strike', 'subscript', 'superscript'],
					['fontColor', 'hiliteColor', 'textStyle'],
					['removeFormat'],
					['outdent', 'indent'],
					['align', 'horizontalRule', 'list', 'lineHeight'],
					['table', 'link', 'image', 'video', 'audio', 'math'],
					['fullScreen', 'showBlocks', 'codeView'],
					['preview', 'print'],
					['save', 'template'],
				],
				placeholder: 'Start typing something...',
				// templates: [
				// 	{
				// 		name: 'Template-1',
				// 		html: '<p>HTML source1</p>'
				// 	},
				// 	{
				// 		name: 'Template-2',
				// 		html: '<p>HTML source2</p>'
				// 	}
				// ],
				codeMirror: CodeMirror,
				katex: katex
			})
		},
		ocultarEditor() {
			event.preventDefault()
			this.suneditor.destroy()
			this.editorAvanzado = false
		}
	},
	created: function(){
		this.recuperarExamen(id_examen)
		this.recuperarPreguntas(id_examen)
		this.recuperarAsignaturas(this.nivel)
		document.title = this.tituloModulo + ' [' + this.examen.clave + '] - ' + this.nombreAplicacion		
	},
	mounted: function() {
		//
	},	
	computed: {
		preguntasFiltro () {
			filtro = this.textoFiltro.toLowerCase()			
			return this.textoFiltro
				? this.preguntas.filter(pregunta => this.removerAcentos(pregunta.pregunta).toLowerCase().includes(filtro) 
					|| this.removerAcentos(pregunta.asignatura).toLowerCase().includes(filtro))
				: this.preguntas
		}	
	}
});
