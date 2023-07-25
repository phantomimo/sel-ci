var vm = new Vue({
	el: '#controlador_preguntas',
	mixins: [funciones],
	data: {
		tituloModulo: 'Banco de preguntas',
		tituloModuloSing: 'pregunta',
		cargando_registros: false,
		pregunta_nueva: {
			numero: 0,			
			pregunta: '',
			opcion1: '',
			opcion2: '',			
			opcion3: '',
			opcion4: '',						
			respuesta: 0,			
			valor_reactivo: null
		},
		preguntas: [],		
		asignaturas: [],
		niveles: [],
		areas: [],
		nivel: {
			id_nivel: null,
			nombre: ''
		},
		area: {
			id_area: null,
			nombre: ''
		},		
		asignatura: {
			id_asignatura: null,
			nombre: '',
			unidades: 0
		},
		respuestas: [
			{'clave': 'a', 'valor': 1},
			{'clave': 'b', 'valor': 2},
			{'clave': 'c', 'valor': 3},			
			{'clave': 'd', 'valor': 4},
		],
		suneditor: null,
		editorAvanzado: false		
	},
	methods: {
		recuperarPreguntas: function (p_asignatura){
			this.cargando_registros = true
			this.$http.get('recuperar_preguntas/' + p_asignatura.id_asignatura).then(function(respuesta){
				this.preguntas = respuesta.body
				this.asignatura = p_asignatura
				this.cargando_registros = false
			}, function(){
				alert('No se han podido recuperar las preguntas.')
				this.cargando_registros = false 	
			})	
		},
		recuperarAsignaturas: function(p_nivel){
			this.$http.get('recuperar_asignaturas/' + p_nivel.id_nivel).then(function(respuesta){
				this.asignaturas = respuesta.body
			}, function(){
				alert('No se han podido recuperar las asignaturas.')
			})
		},		
		recuperarNiveles: function(){
			this.$http.get('recuperar_niveles').then(function(respuesta){
				this.niveles = respuesta.body
			}, function(){
				alert('No se han podido recuperar los niveles.')
			})
		},		
		recuperarAreas: function(p_nivel){
			this.$http.get('recuperar_areas/' + p_nivel.id_nivel).then(function(respuesta){
				this.areas = respuesta.body;
			}, function(){
				alert('No se han podido recuperar las areas.')
			});
		},				
		obtenerNuevoNumero: function (p_pregunta, p_asignatura) {
			this.$http.get('obtener_nuevo_numero/' + p_asignatura.id_asignatura).then(function(respuesta){
				p_pregunta.numero =  parseInt(respuesta.body)
			}, function(){
				alert('No se han podido recuperar el número consecutivo.')
			})
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
		},
		crearPregunta: function(p_pregunta){
			this.$http.post('crear_pregunta', p_pregunta).then(function(){
				this.notificacion('Pregunta agregada correctamente!')
				this.preguntas.push(p_pregunta)					
				this.pregunta_nueva = {}								
			}, function(){
				alert('Ocurrió un error al intentar guardar los cambios.')	
			})
		},
		modificarPregunta: function(p_pregunta){			
			this.$http.post('modificar_pregunta', p_pregunta).then(function(){				
				this.notificacion('Pregunta modificada correctamente!')
			}, function(){
				alert('Ocurrió un error al intentar guardar los cambios.')	
			})
		},
		eliminarPregunta: function(p_pregunta, p_asignatura){
			if(confirm("Desea eliminar la pregunta?")){
				this.$http.post('eliminar_pregunta', p_pregunta).then(function(){
					this.notificacion('Pregunta eliminada correctamente!')
					this.recuperarPreguntas(p_asignatura)
				}, function(){
					alert('No se ha podido eliminar la pregunta.')
				})
			}
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
		mostrarVentanaEdicion (p_pregunta, p_asignatura, p_operacion) {
			event.preventDefault()
			if (p_operacion == this.opInsertar) {
				this.obtenerNuevoNumero(p_pregunta, p_asignatura)			
			}
			this.pregunta = p_pregunta
			this.asignatura = p_asignatura
			this.operacion = p_operacion
			this.modalEdicion = true
			this.errors = []
			this.preguntaAntesEditar = Object.assign({}, this.pregunta)		
			this.editorAvanzado = false		
		},
		cerrarModal(){
			Object.assign(this.pregunta, this.preguntaAntesEditar)						
			this.modalEdicion = false
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
		this.recuperarNiveles()  
		document.title = this.tituloModulo + ' - ' + this.nombreAplicacion							
	},
	mounted: function() {
		//  console.log(this.$route.params) // outputs 
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
})
