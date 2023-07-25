<template>
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>        
        <div class="collapse navbar-collapse" id="navbarSupportedContent">
            <a class="navbar-brand" v-bind:href="base_url"> {{ nombre_aplicacion }} </a>            
            <ul class="navbar-nav mr-auto">
                <li class="nav-item active">
                    <a class="nav-link" v-bind:href="base_url">Inicio <span class="sr-only">(current)</span></a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        Catálogos
                    </a>
                    <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                        <a class="dropdown-item" v-bind:href="base_url + 'asignaturas'">Asignaturas</a>						
                        <a class="dropdown-item" v-bind:href="base_url + 'alumnos'">Alumnos</a>
                        <a class="dropdown-item" v-bind:href="base_url + 'docentes'">Docentes</a>
                        <a class="dropdown-item" v-bind:href="base_url + 'niveles'">Niveles</a>						
                    </div>
                </li>
                <li class="nav-item">
                    <a class="nav-link" v-bind:href="base_url + 'evaluaciones'">Evaluaciones</a>
                </li>
            </ul>
            <!-- <a v-bind:href="base_url">
                <img v-bind:src="base_url + imagen_menu" width="60" height="50" alt="">
            </a> -->
        </div>
    </nav>
</template>        
<script>
    export default {
        name: 'menu',
        props: {
            base_url: {
                type: String,
                require: true,
            },
            nombre_aplicacion: {
                type: String,
                require: true,
            },
            imagen_meu: {
                type: String,
                default: '',
            },
            items: {
                title: {
                    type: String
                },
                url: {
                    type: String
                }
            },
            primaryCallToAction: Object,
            secondaryCallToAction: Object,
        },        
    }
</script>