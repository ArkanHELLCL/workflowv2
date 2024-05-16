<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%
	splitruta=split(ruta,"/")
	DRE_Id=splitruta(7)			
	xm=splitruta(5)
		
	if(xm="modificar") then
		modo=2		
	end if
	if(xm="visualizar") or session("wk2_usrperfil")=5 then
		modo=4		
	end if

	if(DRE_Id="" or DRE_Id=0) then
		ErrMsg="No fue posible encontrar el registro del detalle del requerimiento"
		response.Write("404/@/Error : " & ErrMsg)
		response.End()
	end if
	
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503\\Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if	
	
	ssql="exec spDatoRequerimiento_Consultar " & DRE_Id		
	set rs = cnn.Execute(ssql)		
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 2:" & ErrMsg)
		response.End()		
	end if

	if not rs.eof then
		FLD_Id								= rs("FLD_Id")
		ESR_DescripcionFlujoDatos 			= rs("ESR_DescripcionFlujoDatos")
		ESR_IdFlujoDatos					= rs("ESR_IdFlujoDatos")
		ESR_AccionFlujoDatos				= rs("ESR_AccionFlujoDatos")
		VFO_Id 								= rs("VFO_Id")
		VerFor 								= "V." & VFO_Id		
		REQ_Descripcion 					= rs("REQ_Descripcion")
		IdEditor							= rs("IdEditor")			
		USR_JefaturaCreador					= rs("USR_JefaturaCreador")
		NombreEditor						= rs("NombreEditor")
		ApellidoEditor						= rs("ApellidoEditor")
		USR_JefaturaEditor					= rs("USR_JefaturaEditor")
		DEP_IdActual						= rs("DEP_IdActual")
		DepDescripcionActual				= rs("DepDescripcionActual")
		ESR_IdDatoRequerimiento				= rs("ESR_IdDatoRequerimiento")
		ESR_DescripcionDatoRequerimiento	= rs("ESR_DescripcionDatoRequerimiento")
		ESR_AccionDatoRequerimiento			= rs("ESR_AccionDatoRequerimiento")
		VFL_Id								= rs("VFL_Id")
		REQ_Id								= rs("REQ_Id")
		FLD_Prioridad						= rs("FLD_Prioridad")
		DRE_SubEstado						= rs("DRE_SubEstado")
		FLD_InicioTermino					= rs("FLD_InicioTermino")
		FLD_IdHijoSi						= rs("FLD_IdHijoSi")
		VRE_Id								= rs("VRE_Id")
		FLU_Id								= rs("FLU_Id")
		REQ_Estado							= rs("REQ_Estado")

		accion								= ESR_AccionFlujoDatos
		estado								= ESR_DescripcionFlujoDatos
		if(IsNULL(IdEditor)) then
			IdEditor=0
		end if		
		if(ESR_IdDatoRequerimiento=1 or ESR_IdDatoRequerimiento=7 or ESR_IdDatoRequerimiento=5) then
			'Creacion, Cierre y Rechazo
			accion								= ESR_AccionDatoRequerimiento
			estado								= ESR_DescripcionDatoRequerimiento
		end if		
	else
		ErrMsg="No fue posible encontrar el registro del detalle del requerimiento"
		response.Write("404/@/Error : " & ErrMsg)
		response.End()
	end if
	If(IsNULL(ESR_IdDatoRequerimiento) or ESR_IdDatoRequerimiento=5 or ESR_IdDatoRequerimiento=7) then
		modo=4
	end if

	'Preguntar si el perfil actual tiene permiso para el flujo actual
    FLU_IdPerfil=false
    tl="exec [spUsuarioVersionFlujo_Listar] 1," & session("wk2_usrid")       'Todos flujos asociados al usuario actual
    set tr = cnn.Execute(tl)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error [spUsuarioVersionFlujo_Listar]")
		cnn.close 		
		response.end
	End If	
    do while not tr.eof
        if(FLU_Id=tr("FLU_Id")) then
            'tiene asignado este flujo
            FLU_IdPerfil=true
            exit do
        end if
        tr.movenext
    loop

	response.write("200\\#mediosgraficosModal\\")%>
	<div class="modal-dialog cascading-modal narrower modal-xl modal-bottom" role="document">  		
		<div class="modal-content">		
			<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
				<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-file-signature"></i> Medios Gráficos</div>				
			</div>
			<!--form-->
			<form id="mediosgraficosupload" class="fileupload" action="" method="POST" enctype="multipart/form-data" data-upload-template-id="template-upload-1" data-download-template-id="template-download-1">
				<div class="modal-body">			
					<div class="row px-4">
						<div class="col-sm-12 col-md-12 col-lg-12">									
							<noscript><input type="hidden" name="redirect" value=""></noscript>							
							<div class="row fileupload-buttonbar">
								<div class="col-lg-12"><%
									if(session("wk2_usrperfil")=1 and (REQ_Estado<>5 and REQ_Estado<>7)) or (IdEditor=session("wk2_usrid") and REQ_Estado<>5 and REQ_Estado<>7) or (session("wk2_usrperfil")=2 and (REQ_Estado<>5 and REQ_Estado<>7) and FLU_IdPerfil) then%>
										<span class="btn btn-rounded btn-sm waves-effect btn-success fileinput-button">
											<i class="glyphicon glyphicon-plus"></i>
											<span>Agregar archivos...</span>
											<input type="file" name="files[]" multiple accept="image/x-png,image/jpg,image/jpeg,image/gif,application/x-msmediaview,application/vnd.openxmlformats-officedocument.presentationml.presentation, 	application/vnd.openxmlformats-officedocument.wordprocessingml.document, audio/mp4,video/mp4,application/mp4,application/pdf, application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,video/quicktime,application/msword,application/vnd.ms-powerpoint,video/x-msvideo">
										</span>
										<button type="submit" class="btn btn-rounded btn-sm waves-effect btn-primary start">
											<i class="glyphicon glyphicon-upload"></i>
											<span>Subir archivos</span>
										</button>						
										<button type="reset" class="btn btn-rounded btn-sm waves-effect btn-warning cancel">
											<i class="glyphicon glyphicon-ban-circle"></i>
											<span>Cancelar subida</span>
										</button>						

										<button type="button" class="btn btn-rounded btn-sm waves-effect btn-danger delete">
											<i class="glyphicon glyphicon-trash"></i>
											<span>Borrar archivos</span>
										</button>						

										<div class="rkmd-checkbox checkbox-rotate checkbox-ripple" style="display: contents;">
											<label class="input-checkbox checkbox-lightBlue">
												<input type="checkbox" id="VPM_Comprometida" name="VPM_Comprometida" class="toggle">
												<span class="checkbox"></span>
											</label>
										</div><%
									end if%>									
									<input type="hidden" id="DRE_Id" name="DRE_Id" value="<%=DRE_Id%>" />											
									<!-- The global file processing state -->
									<span class="fileupload-process"></span>
								</div>
								<div class="col-lg-5 fileupload-progress fade">
									<div class="progress progress-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100">
										<div class="progress-bar progress-bar-success" style="width:0%;"></div>
									</div>
									<div class="progress-extended">&nbsp;</div>
								</div>								
							</div>							
							<table role="presentation" class="table table-striped"><tbody class="files"></tbody></table>							
						</div>			
					</div>
					<div class="row">																	
						<div class="footer">				
							<button type="button" class="btn btn-danger btn-md waves-effect waves-dark" style="float:right;" data-dismiss="modal"><i class="fas fa-sign-out-alt"></i> Salir</button>
						</div>
					</div>				
				</div>
				<!--modal-body-->
			</form>
			<!--form-->
		</div>
		<!--modal-cotent-->
	</div>
	<!--modal-dialogo-->			

<script>
	//Medios Graficos
    var mediosgraficosTable;
	var tablamediosgraficosAlto;
	var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);
	var DRE_Id = getparam(3);
	
	$(function () {
		$('[data-toggle="tooltip"]').tooltip({
			trigger : 'hover'
		})
		$('[data-toggle="tooltip"]').on('click', function () {
			$(this).tooltip('hide')
		})		
	});
	$("#mediosgraficosModal").on('hidden.bs.modal', function(e){
		e.preventDefault();
		e.stopImmediatePropagation();
		e.stopPropagation();
		var modo = <%=modo%>;							
		var data = {modo:modo, DRE_Id:DRE_Id};
		$.ajax( {
			type:'POST',					
			url: '/menu-flujo',
			data: data,
			success: function ( data ) {
				param = data.split(sas)
				if(param[0]==200){						
					$("#pry-menucontent").html(param[1]);										
					moveMark(false);
				}else{
					swalWithBootstrapButtons.fire({
						icon:'error',								
						title: 'Ups!, no pude cargar el menú del proyecto',					
						text:param[1]
					});				
				}
			},
			error: function(XMLHttpRequest, textStatus, errorThrown){					
				swalWithBootstrapButtons.fire({
					icon:'error',								
					title: 'Ups!, no pude cargar el menú del proyecto',					
				});				
			}
		});
	})
	
	$(document).ready(function() {		
		$("body").append("<button id='btn_modalmediosgraficos' name='btn_modalmediosgraficos' style='visibility:hidden;width:0;height:0'></button>");
		$("#btn_modalmediosgraficos").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			$("#mediosgraficosModal").modal("show");
			$("body").addClass("modal-open");
			$(".modal-open #mediosgraficosModal").mCustomScrollbar({
				theme:scrollTheme,
			})
				
		});
		$("#btn_modalmediosgraficos").click();		
		$("#btn_modalmediosgraficos").remove();
	})

	function getparam(id){
		var href = window.location.href;
		var newhref = href.substr(href.indexOf("/home")+6,href.length);
		var href_split = newhref.split("/")

		return href_split[id];			
	}
</script>