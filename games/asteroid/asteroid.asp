<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!doctype html>
<html>
<head>

<meta charset="utf-8">
<title>Error 404 - Sistema de Dialogo Social</title>
</head>

<body>

<div id="info">
  <h1>Asteroids:</h1>
  <p>Usa [A][S][W][D] o [&larr;][&uarr;][&darr;][&rarr;] para MOVERTE</p>
  <p>Usa [SPACE] o [K] para DISPARA</p>
</div>
<div id="error">
	<div id="cod">404</div>
	<div id="text">Los siento, no hemos podido encontrar la página solicitada</div>
	<a href="\home">Si quieres volver al sitio solo presiona aqui, si no, solo espera ;-)</a>
</div>
<canvas id="canvas"></canvas>
</body>
</html>

<script type="text/javascript" src="<%=HostName%>/games/asteroid/asteroid.js"></script>
<link rel="stylesheet" href="<%=HostName%>/games/asteroid/asteroid.css" />
