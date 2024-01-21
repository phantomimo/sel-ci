<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="/docs/4.0/assets/img/favicons/favicon.ico">
    <title>Módulo de administración</title>
    <script type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/jquery-3.7.0.min.js"></script>	
	<script type="text/javascript" src="<?php echo base_url() ?>assets/js/lib/md5.js"></script>	        
    <link href="<?php echo base_url() ?>assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="<?php echo base_url() ?>assets/css/signin.css" rel="stylesheet">
</head>

<body class="text-center">
    <form class="form-signin" method="post" action="<?php echo base_url() ?>admin/autenticar/">
        <img class="mb-4" src="<?php echo base_url() ?>assets/img/logo_instituto_montebello_med.png" alt="" width="264">
        <!-- <h6>Módulo de examen</h6> -->
        <label for="usuario" class="sr-only">Usuario</label>
        <input type="text" name="usuario" class="form-control" placeholder="Usuario" required autofocus>
        <label for="contrasena" class="sr-only">Contraseña</label>
        <input type="password" name="contrasena" class="form-control" placeholder="Contraseña" required>
        <br/>
        <button class="btn btn-lg btn-primary btn-block" type="submit">Iniciar sesión</button>
        <div class="btn-warning"><?php if(isset($resultado)) echo $resultado->motivo; else echo ''; ?></div>        
        <p class="mt-5 mb-3 text-muted">&copy; 2020-2023 Instituto Educativo Montebello</p>
    </form>
</body>
</html>