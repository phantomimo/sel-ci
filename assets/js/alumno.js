Vue.use(VueTabs);

var controlador_alumnos = new Vue({
	el: '#controlador_alumnos',
	mixins: [funciones],		
	data: {		
		tituloModulo: 'Alumno',		
		tituloModuloSing: 'alumno',
		cargando_registros: true,
		alumno: {
			id_alumno: null,
			nombre: '',
			numero_control: null,
			apellido_paterno: '',
			apellido_materno: '',			
			curp: ''		},
		nivel: {
			id_nivel: null,
			nombre: ''
		},
		grado: {
			id_grado: null,
			nombre: ''
		},				
		grupo: {
			id_grupo: null,
			nombre: ''
		},				
		alumnos: [],
		niveles: [],
		grados: [],		
		grupos: [],
		examenes: [],
		examen: null,
		examen_alumno: null,
		modalResultados: false		
	},
	methods: {
		recuperarAlumno: function(p_alumno){
			this.cargando_registros = true
			this.$http.get('obtener_datos_alumno/' + p_alumno).then(function(respuesta){
				this.alumno = respuesta.body[0]
				this.nivel.id_nivel = this.alumno.id_nivel
				this.nivel.nombre = this.alumno.nivel
				document.title = this.tituloModulo + ' [' + this.alumno.numero_control + '] - ' + this.nombreAplicacion			
			}, function(){
				alert('No se han podido recuperar los datos del alumno.')
				this.cargando_registros = false 	
			})	
		},
		obtenerNuevoNumero: function (p_alumno) {
			this.$http.get('obtener_nuevo_numero_control').then(function(respuesta){
				p_alumno.numero_control =  respuesta.body
			}, function(){
				alert('No se han podido recuperar el número consecutivo.')
			})
		},			
		guardarAlumno: function(p_alumno){
			event.preventDefault()
			if (!this.validar(p_alumno))
				return false
			else {
				this.modificarAlumno(p_alumno)
			}
			window.location.href = window.location.origin + "/" + this.rutaAplicacion + "/admin/alumnos"
		},			
		modificarAlumno: function(p_alumno){
			this.$http.post('modificar_alumno', p_alumno).then(function(){				
				this.notificacion('Alumno modificado correctamente!')								
			}, function(){
				alert('No se ha podido modificar el alumno.')
			})
		},
		recuperarNiveles: function(){
			this.$http.get('recuperar_niveles').then(function(respuesta){
				this.niveles = respuesta.body
			}, function(){
				alert('No se han podido recuperar los niveles.')
			})
		},
		recuperarGrados: function(p_nivel){
			url = (p_nivel != null)?'recuperar_grados/' + p_nivel : 'recuperar_grados'
			this.$http.get(url).then(function(respuesta){
				this.grados = respuesta.body;
			}, function(){
				alert('No se han podido recuperar los grados.');
			});	
		},
		recuperarGrupos: function(p_grado){			
			url = (p_grado != null)?'recuperar_grupos/' + p_grado : 'recuperar_grupos'			
			this.$http.get(url).then(function(respuesta){
				this.grupos = respuesta.body;
			}, function(){
				alert('No se han podido recuperar los grupos.');
			});	
		},		
		recuperarExamenesAlumno: function(p_alumno){
			this.cargando_registros = true
			this.$http.get('obtener_examenes_alumno/' + p_alumno).then(function(respuesta){
				this.examenes = respuesta.body
				this.cargando_registros = false 					
			}, function(){
				alert('No se ha podido recuperar el historial de exámenes del alumno.')
				this.cargando_registros = false 	
			})	
		},				
		validar: function (p_alumno) {
			this.errors = []			
			if (p_alumno.numero_control === '') {
				this.errors.push('El número de contorl del alumno es un dato obligatorio.')
			  }
			else			
			if (p_alumno.nombre === '') {
			  this.errors.push('El nombre del alumno es obligatorio.')
			}
			else			
			if (p_alumno.apellido_paterno === '') {
				this.errors.push('El apellido paterno del alumno es obligatorio.')
			}
			return this.errors.length == 0
		},
		mostrarVentanaEdicion(p_alumno, p_operacion) {
			event.preventDefault()			
			if (p_operacion == this.opInsertar) {
				this.obtenerNuevoNumero(p_alumno)			
			}			
			this.alumno = p_alumno
			this.operacion = p_operacion			
			this.errors = []		
			this.alumnoAntesEditar = Object.assign({}, this.alumno)						
		},	
		cerrarVentanaEdicion(){
			window.location.href = window.location.origin + "/" + this.rutaAplicacion + "admin/alumnos"
		},
		mostrarVentanaResultados (p_examen) {
			event.preventDefault()
			this.examen = p_examen			
			this.modalResultados = true
			this.$http.get('obtener_respuestas_examen_alumno/' + p_examen.id).then(function(respuesta){
				this.examen_alumno = respuesta.body
				this.cargando_registros = false 	
				this.resultados = true				
			}, function(){
				alert('No se ha podido recuperar el resultado del examen.')
				this.cargando_registros = false 	
			})			
		},	
		cerrarVentanaResultados(){
			this.modalResultados = false
			this.examen_alumno = null
		},			
	},
	created: function(){
		this.recuperarNiveles()
		this.recuperarGrados()
		this.recuperarGrupos()
		this.recuperarAlumno(id_alumno)		
		this.recuperarExamenesAlumno(id_alumno)
		document.title = this.tituloModulo + ' - ' + this.nombreAplicacion									
		this.operacion = this.opModificar
	},	  
	computed: {
		Filtro () {
			filtro = this.textoFiltro.toLowerCase()
			return this.textoFiltro
				? this.alumnos.filter(alumno => this.removerAcentos(alumno.nombre + ' ' + alumno.apellido_paterno + ' ' + alumno.apellido_materno).toLowerCase().includes(filtro) 
					|| this.removerAcentos(alumno.numero_control).toLowerCase().includes(filtro) || this.removerAcentos(alumno.curp).toLowerCase().includes(filtro))
				: this.alumnos
		}	
	}	
})
