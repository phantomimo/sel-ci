<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="/docs/4.0/assets/img/favicons/favicon.ico">
    <title>Módulo de examen</title>
    <link href="<?php echo base_url() ?>assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="<?php echo base_url() ?>assets/css/signin.css" rel="stylesheet">
</head>

<body class="text-center">
    <form class="form-signin" method="post" action="<?php echo base_url() ?>examen/autenticar/" autocomplete="off">
        <img class="mb-4" src="<?php echo base_url() ?>assets/img/logo_instituto_montebello_med.png" alt="" width="264">
        <!-- <h6>Módulo de examen</h6> -->
        <label for="numero_control" class="sr-only">Número de control</label>
        <input type="text" name="numero_control" class="form-control" placeholder="Número de control" required autofocus>
        <label for="clave_examen" class="sr-only">Clave de examen</label>
        <input type="password" name="clave_examen" class="form-control" placeholder="Clave de examen" required>
        <br/>
        <button class="btn btn-lg btn-primary btn-block" type="submit">Iniciar examen</button>
        <div class="btn-warning"><?php if(isset($resultado)) echo $resultado->motivo; else echo ''; ?></div>        
        <p class="mt-5 mb-3 text-muted">&copy; 2020 Instituto Educativo Montebello</p>
    </form>
</body>
</html>