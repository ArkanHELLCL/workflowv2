<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!DOCTYPE html>
<html xmlns="https://www.w3.org/1999/xhtml">
	<head>
		<title>Ingreso - Sistema WorkFlow</title>
		<!--head-->
		<!-- #INCLUDE FILE="include\template\meta.inc" -->
		<!-- #INCLUDE FILE="include\template\loginhead.inc" -->
		<!--head-->
	</head>
	<%
	'Response.AddHeader "Refresh",CStr(CInt(Session.Timeout + 1) * 60)
	Response.AddHeader "cache-control", "private"
	Response.AddHeader "Pragma","No-Cache"
	Response.Buffer = TRUE
	Response.Expires = 0
	Response.ExpiresAbsolute = 0
	'Session.Contents.Removeall()  
    Session.Abandon

	servername=Request.ServerVariables("SERVER_NAME")
	if(servername="www.workflow2dev.gob.cl") then	'Desarrollo
	%>
	<div class="alert alert-danger" role="alert" style="position: absolute;top: 0;width: 100%;padding: 0.02rem 1.25rem;">
		Máquina de desarrollo Servidor:<%=servername%>
	</div>
	<%end if%>
	<body class="text-center justify-content-center">
		<!-- form container -->
		<div class="form-container">
			<!-- form login -->
			<div class="form-login">
				<!-- Table with panel -->					
				<div class="card card-cascade narrower">
					<!--Card image-->
					<div class="view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center">						
						<div class="text-left">Ingresa tus</div>
						<div id="UsrPhoto"></div>
						<div class="text-right">Credenciales</div>					
					</div>
					<!--/Card image-->
					<i class="fas fa-question-circle text-primary help login fa-2x" title="Descarga manual de uso"></i>
					<form role="form" action="/valida-usuario" method="POST" name="login" id="login" class="form-signin needs-validation">			
						<div>
							<div id="UsrPhoto"></div>
							<div>					
								<div class="md-form" style="text-align:initial;">
									<div class="error-message input-field">						
										<i class="material-icons prefix">account_circle</i>							
										<input type="text" id="USR_Cod" name="USR_Cod" class="form-control validate" autofocus required>
										<span class="select-bar"></span>
										<label for="USR_Cod">Usuario</label>							
									</div>						
								</div>								
								<div class="md-form " style="text-align:initial;">
									<div class="error-message input-field">
										<i class="material-icons prefix">vpn_key</i>										
										<input type="password" id="USR_Pass" name="USR_Pass" class="form-control validate" required autocomplete="on">
										<i class="far fa-eye-slash viewpass" data-key="#USR_Pass"></i>
										<span class="select-bar"></span>
										<label for="USR_Pass">Contraseña</label>							
									</div>						
								</div>
							</div>
						</div>
						<a class="text-muted" id="legacy" href="http://v1.workflow.subtrab.gob.cl/" target="new">Ir a versión anterior</a>
						<br/>
						<br/>
						
						<button class="btn btn-primary animated waves-effect" type="submit"><i class="fas fa-sign-in-alt"></i> Ingresar</button>				
						<div class="card-footer text-muted text-center mt-4">			  
							<p class="text-muted" id="copyright">Sistema WorkFlow v3.10.2023<br/>Subsecretaría del Trabajo</p>
							<div class="bicolor bottom ">
								<span class="azul"></span>
								<span class="rojo"></span>
							</div>
						</div>

					</form>			  	
				</div>
				<!-- Table with panel -->
			</div>
			<!-- form login -->			
		</div>
		<!-- form container -->
		
	</body>
</html>
<script>
	var help = setInterval(function() {
		$(".help").addClass("show")
		clearInterval(help)
		var shake =	setInterval(function() {
			$(".help").addClass("shake")
			clearInterval(shake)
		}, 1000);
	}, 3000);	
	$(".help").click(function(){
		var INF_Arc = 'login.pdf';							
		var data = {SIS_Id:3,INF_Arc:INF_Arc};
		$.ajax({
			url: "/bajar-archivo",
			method: 'POST',
			data:data,
			xhrFields: {
				responseType: 'blob'
			},
			success: function (data) {
				var a = document.createElement('a');
				var url = window.URL.createObjectURL(data);
				a.href = url;
				a.download = INF_Arc;
				document.body.append(a);
				a.click();
				a.remove();
				window.URL.revokeObjectURL(url);
			}
		});			
	})
</script>