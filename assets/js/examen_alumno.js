Vue.use(Toasted, {
    iconPack : 'material'
})

var vm = new Vue({
	el: '#controlador_examen',
	data: {
		tituloModulo: 'Módulo de examen',
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
		preguntas: [],		
		respuestas: [
			{'clave': 'a', 'valor': 1},
			{'clave': 'b', 'valor': 2},
			{'clave': 'c', 'valor': 3},			
			{'clave': 'd', 'valor': 4},
		],
		id_examen: null,
		id_examen_alumno: null,
		textoPregunta: '',
		segundosTotales: 0,
		interval: null,
		pruebaFinalizada: false,
		runningOut: false,
		hours: 0,
		minutes: 0,			
		seconds: 0,
		horas: '00',
		minutos: '00',
		segundos: '00',
		timer: null,
		clockType: 'countdown',
		hasStarted: false,
		hasEnded: false,
		resultados: false
	},
	methods: {
		recuperarExamen: function(id_examen_alumno){			
			this.$http.get('obtener_examen_alumno/' + id_examen_alumno).then(function(respuesta){
				this.examen = respuesta.body[0]
				document.title = this.tituloModulo + ' [' + this.examen.clave + '] - ' + this.nombreAplicacion						
			}, function(){
				alert('No se han podido recuperar los datos del examen.')
			});	
		},		
		validar: function () {
			var ninguna = true		
			for (i=0; i<document.form_pregunta.respuesta_alumno.length; i++){
				if (document.form_pregunta.respuesta_alumno[i].checked){
					document.form_pregunta.submit()				
					ninguna = false
					break				
				}	
			}
			if (ninguna) 
				this.notificacion("Debes elegir una opción para continuar!")
		},		
        notificacion: function(mensaje) {
            this.$toasted.show(mensaje, { 
				theme: "bubble", 
				type: 'error',
                position: "bottom-center", 
                closable: "yes",                 
                duration : 3000              
            })
        },   		
		cerrarModal(){
			Object.assign(this.pregunta, this.preguntaAntesEditar)						
			this.modalEdicion = false
			event.preventDefault()								
		},	
		mostrarResultados () {
			this.resultados = !this.resultados
			if (this.resultados) {
				this.cargando_registros = true
				this.$http.get('obtener_examen_alumno/' + this.id_examen_alumno).then(function(respuesta){
					this.examen = respuesta.body[0]
					this.cargando_registros = false 	
				}, function(){
					alert('No se ha podido recuperar el resultado del examen.')
					this.cargando_registros = false 	
				})	
			}
		},
		pad: function (d) {
			return (d < 10) ? '0' + d.toString() : d.toString()
		},
		countdown: function (measure, ammount) {			
			this.startClock(measure, ammount);  	
			if (this.hours == 0 && this.minutes == 0 && this.seconds == 0 && this.hasStarted == true) {
				this.hasEnded = true
			}	
			this.hasStarted = true
			if (this.hasEnded)
				this.refreshClock()  
			else
				this.interval = setInterval(() => {
					if(this.hasEnded == false) {
						if (this.seconds <= 60 && this.minutes == 0 && this.hours == 0) {								
							this.runningOut = true
						}

						if(this.seconds == 0 && this.minutes == 0 || (this.hours > 0  && this.minutes == 0 && this.seconds == 0)) {
							this.hours--
							this.minutes = 59
							this.seconds = 60
							this.refreshClock()
						}

						if(this.seconds > 0) {
							this.seconds--
							this.refreshClock()
						}
						else if (this.seconds == 0) {
							this.minutes--
							this.seconds = 59
							this.refreshClock()
						}
					}
					else {
						clearInterval(this.interval);   
						this.refreshClock()
					}
				}, 1000)            
							
		},	
		startClock: function(measure, ammount) {
			this.hasStarted = false
			this.hasEnded = false
			switch (measure) {
				case 's':
					if (ammount > 3599) {
						this.hours = Math.floor(ammount / 3600)							
						this.minutes = Math.floor((ammount - (this.hours * 3600)) / 60)							
						this.seconds = (ammount - (this.hours * 3600)) - (this.minutes * 60)
					}
					else if (ammount > 59) {
						this.minutes = Math.floor(ammount / 60)							
						this.seconds = ammount - (this.minutes * 60)
					}
					else {
						this.seconds = ammount
					}
					break
				case 'm':
					if (ammount > 59) {
						this.hours = Math.floor(ammount / 60)
						this.minutes = ammount - (this.hours * 60)							
					}
					else {
						this.minutes = ammount
					}
					break
				case 'h':
					this.hours = ammount
					break
				default:
					break
			}
			this.refreshClock()
		},
		refreshClock: function () {
			this.timer =  this.$refs.timer
			const s = this.$refs.seconds
			const m = this.$refs.minutes
			const h = this.$refs.hours     	

			if (this.hasEnded) {  
				if (this.timer) {
					this.timer.remove()                                                            					
					location.reload()
				}
			}    
			else {
				if (this.hours < 0) {
					this.seconds = 0
					this.minutes = 0
					this.hours = 0
				} else {
					this.horas = this.pad(this.hours)
				}       
				if (this.seconds < 60 && this.minutes == 0 && this.hours == 0) {
					this.runningOut = true
				}
				if (this.hours == 0 && this.minutes == 0 && this.seconds == 0 && this.hasStarted == true) {
					this.hasEnded = true
				}
				this.minutos = this.pad(this.minutes)				
				this.segundos = this.pad(this.seconds)
			}
		},				
		stopClock: function () {
			clearInterval(this.interval)
			if (this.$refs.timer)
				this.$refs.timer.remove()			
		}
	},
	created: function(){
		if(history.forward(1))
			location.replace(history.forward(1))			
	},
	mounted: function() {
		// this.recuperarExamen(this.id_examen_alumno)
		this.countdown('s', this.segundosTotales)					
		if (this.prueba_finalizada)
			this.stopClock()
	},	
	watch:{
		'pruebaFinalizada': function (){
			if (this.pruebaFinalizada)
				this.stopClock()
		}
	}
});
