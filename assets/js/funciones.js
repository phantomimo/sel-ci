Vue.use(Toasted, {
    iconPack : 'material'
})

Vue.component('menu-principal', {
    props: ['url_base', 'nombre_aplicacion'],
    template: `
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>          
        <div class="collapse navbar-collapse" id="navbarSupportedContent">
            <a class="navbar-brand" :href="url_base + 'admin'"> {{ nombre_aplicacion }} </a>        
            <ul class="navbar-nav mr-auto">
            <li class="nav-item">
                <a class="nav-link" :href="url_base + 'admin'">Inicio <span class="sr-only"></span></a>
            </li>
            <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    Catálogos generales
                </a>
                <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                    <a class="dropdown-item" :href="url_base + 'admin/areas'">Áreas</a>										                
                    <a class="dropdown-item" :href="url_base + 'admin/niveles'">Niveles</a>										
                    <a class="dropdown-item" :href="url_base + 'admin/grados'">Grados</a>										                    
                    <a class="dropdown-item" :href="url_base + 'admin/grupos'">Grupos</a>	
                    <a class="dropdown-item" :href="url_base + 'admin/alumnos'">Alumnos</a>                    									                                      
                    <a class="dropdown-item" :href="url_base + 'admin/asignaturas'">Asignaturas</a>						                    
                    <a class="dropdown-item" :href="url_base + 'admin/docentes'">Docentes</a>
                </div>
            </li>
            <li class="nav-item">
                <a class="nav-link" :href="url_base + 'admin/examenes'">Exámenes</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" :href="url_base + 'admin/usuarios'">Usuarios</a>
            </li>  
            <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    Sesión
                </a>
                <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                    <a class="nav-link" :href="url_base + 'admin/cerrar_sesion'">Cerrar sesión</a>
                </div>
            </li>            
            </ul>
            <a class="navbar-brand" href="#">
                <img :src="url_base + 'assets/img/logo.jpg'" width="60" height="50" alt="">
            </a>       
        </div>
    </nav>
    `  
})

Vue.component('html-textarea',{
    template:'<textarea id="texto-pregunta" @change="updateHTML"></textarea>',
    props:['value'],
    mounted: function () {
      this.$el.innerHTML = this.value;
    },
    methods: {
      updateHTML: function(e) {
        this.$emit('change', e.target.innerHTML);
      }
    }
})

var funciones = {
    // mixins: [config],
    data: {
        errors: [],
		opModificar: 1,
		opInsertar: 2,
		modalEdicion: false,
		textoFiltro: '',
		filaActiva: 0,
        errors: [],
        operacion: null,
        isFixed: false,
        nombreAplicacion: 'SEL-1.0',
        rutaAplicacion: '/',
        modalBusqueda: false,
        tituloModuloSing: 'registro',
        VALOR_SI: 'S',
        VALOR_NO: 'N'
    },
    methods: {
        removerAcentos(value) {
            return value
                .replace(/á/g, 'a')            
                .replace(/é/g, 'e')
                .replace(/í/g, 'i')
                .replace(/ó/g, 'o')
                .replace(/ú/g, 'u');
        },
        unicodeToChar(text) {
            return text.replace(/\\u[\dA-F]{4}/gi, 
                   function (match) {
                        return String.fromCharCode(parseInt(match.replace(/\\u/g, ''), 16));
                   });
        },
        activarFila: function(el) {
            this.filaActiva = el
		},
		inicializarErrores: function () {
			this.errors = []
		},
        operacionTitulo: function () {
            if (this.operacion == this.opModificar)
                return 'Modificar ' + this.tituloModuloSing
            else
                return 'Agregar ' + this.tituloModuloSing 
        }, 
        notificacion: function(mensaje) {
            this.$toasted.show(mensaje, { 
                theme: "toasted-primary", 
                position: "top-right", 
                closable: "yes",                 
                duration : 5000,
                icon : {
                    name : 'check'
                }                
            })
        }        
    },
    created: function () {
        const onKeyDown = (e) => {
            if (e.keyCode === 27) {        
			    if (this.modalEdicion) 
                    this.cerrarModal()
                else if (this.modalBusqueda)
                    this.cerrarModalBusqueda()
			}
		}
        document.addEventListener('keydown', onKeyDown)	
    },
	directives: {
		focus: {
		  inserted: function (el) {
            el.focus()
            // el.select()
		  }
        }        
    }
}