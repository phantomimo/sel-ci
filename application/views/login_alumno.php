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
    <!-- <script type="javascript">
        document.querySelector('input[name="numero_control"]').setAttribute('autocomplete','none');
        document.querySelector('input[name="clave_examen"]').setAttribute('autocomplete','none');        
    </script> -->
</head>

<body class="text-center">
    <form class="form-signin" method="post" action="<?php echo base_url() ?>examen/autenticar/" autocomplete="off">        
        <img class="mb-4" src="<?php echo base_url() ?>assets/img/logo_instituto_montebello_med.png" alt="Instituto Montebello" width="264">
        <label for="numero_control" class="sr-only">Número de control</label>
        <input type="text" name="numero_control" class="form-control" placeholder="Número de control" autocomplete="false" required autofocus />
        <label for="clave_examen" class="sr-only">Clave de examen</label>
        <input type="password" name="clave_examen" class="form-control" placeholder="Clave de examen" autocomplete="new-password" required />            
        <br/>
        <button class="btn btn-lg btn-primary btn-block" type="submit">Iniciar examen</button>
        <div class="btn-warning"><?php if(isset($resultado)) echo $resultado->motivo; else echo ''; ?></div>        
        <div class="mt-5 mb-5 text-muted">&copy; 2020-2023 Instituto Educativo Montebello</div>
    </form>
</body>
</html>