var controlador_alumnos = new Vue({
	el: '#controlador_alumnos',
	mixins: [funciones],		
	data: {		
		tituloModulo: 'Alumnos',		
		tituloModuloSing: 'alumno',
		cargando_registros: true,
		alumno_nuevo: {
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
		indice: null		
	},
	methods: {
		recuperarAlumnos: function(){
			this.cargando_registros = true
			this.$http.get('recuperar_alumnos').then(function(respuesta){
				this.alumnos = respuesta.body
				this.cargando_registros = false
			}, function(){
				alert('No se han podido recuperar los alumnos.')
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
		guardarAlumno: function(p_alumno, p_operacion){
			event.preventDefault()			
			if (!this.validar(p_alumno))
				return false
			else {
				switch (p_operacion) {
					case this.opInsertar:
						p_alumno.id_nivel = this.nivel.id_nivel
						p_alumno.id_grado = this.grado.id_grado
						this.crearAlumno(p_alumno)
						break
					case this.opModificar:
						this.modificarAlumno(p_alumno)
						break
				}
				// p_alumno.nivel = this.$refs.nivel[this.$refs.nivel.selectedIndex].text				
				// p_alumno.grado = this.$refs.grado[this.$refs.grado.selectedIndex].text
				// p_alumno.grupo = this.$refs.grupo[this.$refs.grupo.selectedIndex].text
				// Vue.set(this.alumnos, this.indice, p_alumno)
				this.modalEdicion = false
			}
		},		
		crearAlumno: function(){
			this.$http.post('crear_alumno', this.alumno_nuevo).then(function(){
				this.alumno_nuevo.nombre = ''
				this.alumno_nuevo.numero_control = ''
				this.alumno_nuevo.apellido_paterno = ''
				this.alumno_nuevo.curp = ''
				this.recuperarAlumnos()
				this.notificacion('Alumno agregado correctamente!')				
			}, function(){
				alert('No se ha podido crear el alumno.')
			})
		},
		modificarAlumno: function(p_alumno){
			this.$http.post('modificar_alumno', p_alumno).then(function(){				
				this.notificacion('Alumno modificado correctamente!')								
			}, function(){
				alert('No se ha podido modificar el alumno.')
			})
		},
		eliminarAlumno: function(p_alumno){
			if(confirm("Desea eliminar el registro?")){
				this.$http.post('eliminar_alumno', p_alumno).then(function(){
					this.recuperarAlumnos()
				}, function(){
					alert('No se ha podido eliminar el alumno.')
				})
			}
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
		obtenerDatosAlumno: function(p_alumno){
			this.$http.get('obtener_datos_alumno/' + p_alumno.id_alumno).then(function(respuesta){
				this.alumnos[this.indice] = respuesta.body
			}, function(){
				alert('No se han podido recuperar los datos del alumno.')
			})	
		},		
		validar: function (p_alumno) {
			this.errors = []			
			if (p_alumno.nombre === '') {
			  this.errors.push('El nombre del alumno es obligatorio.')
			}
			else
			if (p_alumno.apellido_paterno === '') {
				this.errors.push('El apellido paterno del alumno es obligatorio.')
			}
			else
			if (p_alumno.id_nivel <= 0) {
				this.errors.push('El nivel es un dato requerido.')
			}			
			else
			if (p_alumno.id_grado <= 0) {
				this.errors.push('El grado es un dato requerido.')
			}			
			else
			if (p_alumno.id_grupo <= 0) {
				this.errors.push('El grupo es un dato requerido.')
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
			this.modalEdicion = true
			this.errors = []		
			this.alumnoAntesEditar = Object.assign({}, this.alumno)						
		},
		editarAlumno: function (p_alumno) { 
			window.open("alumnos/editar/" + p_alumno.id_alumno, "_self");
		},		
		cerrarModal(){
			event.stopPropagation
			Object.assign(this.alumno, this.alumnoAntesEditar)	
            this.modalEdicion = false            									
        }
	},
	created: function(){
		this.recuperarNiveles()
		this.recuperarGrados()
		this.recuperarGrupos()
		this.recuperarAlumnos()	
		document.title = this.tituloModulo + ' - ' + this.nombreAplicacion									
	},	  
	computed: {
		alumnosFiltro () {
			filtro = this.textoFiltro.toLowerCase()
			return this.textoFiltro
				? this.alumnos.filter(alumno => this.removerAcentos(alumno.nombre + ' ' + alumno.apellido_paterno + ' ' + alumno.apellido_materno).toLowerCase().includes(filtro) 
					|| this.removerAcentos(alumno.numero_control).toLowerCase().includes(filtro) || this.removerAcentos(alumno.curp).toLowerCase().includes(filtro))
				: this.alumnos
		}	
	}	
})
