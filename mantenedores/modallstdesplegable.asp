<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%	
	LID_Id=request("LID_Id")	
	mode=request("mode")			
	
	if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2) then
		frmlstdesplegable="frmlstdesplegable"
		disabled="required"
		calendario="calendario"
		if(mode="add") then
			typeFrm="<i class='fas fa-plus ml-1'></i> Agregar"
			button="btn btn-success btn-md waves-effect"
			lblSelect=""
			action="/agregar-lstdesplegable"			
		else	
			if(mode="mod") then
				typeFrm="<i class='fas fa-download ml-1'></i> Grabar"
				button="btn btn-warning btn-md waves-effect"
				lblSelect=""
				action="/modificar-lstdesplegable"
			else
				typeFrm=""
				button=""
				action=""
				lblSelect=""
			end if
		end if
	else
		frmlstdesplegable=""
		disabled="readonly"
		calendario=""
		typeFrm=""
		button=""
	end if
	
	if (session("wk2_usrperfil")>2) then
		ds = "disabled"
		lblSelect = "active"
	else
		if(mode="add") then
			ds="required"
		else
			ds = ""		
			lblSelect = ""
		end if
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
	
	if(mode="mod") then
		set rs = cnn.Execute("exec spListaDesplegable_Consultar " & LID_Id)
		on error resume next	
		cnn.open session("DSN_WorkFlowv2")
		if cnn.Errors.Count > 0 then 
		   ErrMsg = cnn.Errors(0).description	   
		   cnn.close
		   response.Write("503\\Error Conexión:" & ErrMsg)
		   response.End() 			   
		end if	
		if not rs.eof then			
			LID_Descripcion	= LimpiarUrl(rs("LID_Descripcion"))
			LID_Estado	= rs("LID_Estado")			
		end if		
		rs.Close		
	end if
	Estado=""
	if(IsNULL(LID_Estado)) then
		LID_Estado=0		
	end if
	if(CInt(LID_Estado)=1) then
		Estado = "checked"
	end if
	response.write("200\\")%>
	<div class="modal-dialog cascading-modal narrower modal-xl" role="document">  		
		<div class="modal-content">		
			<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
				<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-server"></i> Lista Desplegable</div>				
			</div>				
			<div class="modal-body" style="padding:0px;">
				<div id="divfrmlstdesplegable" class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
					<div class="px-4">						
						<form role="form" action="<%=action%>" method="POST" name="<%=frmlstdesplegable%>" id="<%=frmlstdesplegable%>" class="needs-validation">
							<div class="row align-items-center">								
								<div class="col-sm-12 col-md-12 col-lg-10">
									<div class="md-form input-with-post-icon">
										<div class="error-message">								
											<i class="fas fa-tag input-prefix"></i><%
											if(LID_Descripcion<>"") then
												lblClass="active"
											else
												lblClass=""
											end if%>
											<input type="text" id="LID_Descripcion" name="LID_Descripcion" class="form-control" <%=disabled%> value="<%=LID_Descripcion%>">
											<span class="select-bar"></span>
											<label for="LID_Descripcion" class="<%=lblClass%>">Descripción</label>
										</div>
									</div>
								</div>								
                                <div class="col-sm-12 col-md-12 col-lg-2">
									<div class="switch"><%
										if(mode="add") then%>
											<input type="checkbox" id="LID_Estado" class="switch__input" checked disabled><%
										else%>
											<input type="checkbox" id="LID_Estado" class="switch__input" <%=Estado%>><%
										end if%>
										<label for="LID_Estado" class="switch__label">Activado</label>
									</div>
								</div>																
							</div><%
							if(mode="mod") then%>
								<input type="hidden" id="LID_Id" name="LID_Id" value="<%=LID_Id%>"><%
							end if%>						
						</form>
						<!--form-->
					</div>
					<!--px-4-->
				</div>
				<!--divfrmlstdesplegable-->												
			</div>
			<!--body-->
			<div class="modal-footer"><%
				if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2) then%>
					<div style="float:left;" class="btn-group" role="group" aria-label="">
						<button class="<%=button%>" type="button" data-url="" title="Modificar Lista Desplegable" id="btn_frmlstdesplegable" name="btn_frmlstdesplegable"><%=typeFrm%></button>
					</div><%
				end if%>

				<div style="float:right;" class="btn-group" role="group" aria-label="">					
					<button type="button" class="btn btn-secondary btn-md waves-effect" data-dismiss="modal" data-toggle="tooltip" title="Salir"><i class="fas fa-sign-out-alt"></i> Salir</button>
				</div>					
			</div>		  
			<!--footer-->	
		</div>
	</div>

<script>    
	$(function () {
		$('[data-toggle="tooltip"]').tooltip({
			trigger : 'hover'
		})
		$('[data-toggle="tooltip"]').on('click', function () {
			$(this).tooltip('hide')
		})		
	});	
	$(document).ready(function() {
		var ss = String.fromCharCode(47) + String.fromCharCode(47);		
		
		$("#btn_frmlstdesplegable").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			var mode='<%=mode%>';			
			if(mode=="add"){
				var msg="Lista Desplegable agregado exitosamente.";
			}else{
				if(mode=="mod"){
					var msg="Lista Desplegable modificado exitosamente.";
				}else{
					var msg="Sin modo.";
				}				
			}
			formValidate("#frmlstdesplegable");			
			if($("#frmlstdesplegable").valid()){
				if($("#LID_Estado").is(":checked")){
					var LID_Estado = 1
				}else{
					var LID_Estado = 0
				}
				$.ajax({
					type: 'POST',
					url: $("#frmlstdesplegable").attr("action"),
					data: $("#frmlstdesplegable").serialize() + "&LID_Estado=" + LID_Estado,
					dataType: "json",
					success: function(data) {						
						if(data.state=="200"){
							if(mode=="add"){
								$("#frmlstdesplegable")[0].reset();
							}
							Toast.fire({
							  icon: 'success',
							  title: msg
							});
						}else{
							swalWithBootstrapButtons.fire({
								icon:'error',
								title:'Ingreso de Lista Desplegable Fallido',
								text:data.message
							});
						}
					},
					error: function(XMLHttpRequest, textStatus, errorThrown){						
						swalWithBootstrapButtons.fire({
							icon:'error',								
							title: 'Ups!, no pude cargar el menú del requerimiento',					
						});				
					}
				})
			}
		})				
	})
</script>