<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
	DEP_Id=request("DEP_Id")	
	mode=request("mode")			
	
	if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2) then
		frmdepartamentos="frmdepartamentos"
		disabled="required"
		calendario="calendario"
		if(mode="add") then
			typeFrm="<i class='fas fa-plus ml-1'></i> Agregar"
			button="btn btn-success btn-md waves-effect"
			lblSelect=""
			action="/agregar-departamentos"			
		else	
			if(mode="mod") then
				typeFrm="<i class='fas fa-download ml-1'></i> Grabar"
				button="btn btn-warning btn-md waves-effect"
				lblSelect=""
				action="/modificar-departamentos"
			else
				typeFrm=""
				button=""
				action=""
				lblSelect=""
			end if
		end if
	else
		frmdepartamentos=""
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
		set rs = cnn.Execute("exec spDepartamento_Consultar " & DEP_Id)
		on error resume next	
		cnn.open session("DSN_WorkFlowv2")
		if cnn.Errors.Count > 0 then 
		   ErrMsg = cnn.Errors(0).description	   
		   cnn.close
		   response.Write("503\\Error Conexión:" & ErrMsg)
		   response.End() 			   
		end if	
		if not rs.eof then			
			DEP_Descripcion			= rs("DEP_Descripcion")
			DEP_Codigo				= rs("DEP_Codigo")
			DEP_NombreDependiente	= rs("DEP_NombreDependiente")
			DEP_DescripcionCorta	= rs("DEP_DescripcionCorta")
			DEP_TipoVista			= rs("DEP_TipoVista")
			DEP_Estado				= rs("DEP_Estado")
		end if		
		rs.Close		
	end if
	if(DEP_TipoVista=1) then
		TipoVista="checked"
	else
		TipoVista=""		
	end if

	if(DEP_Estado=1) then
		Estado="checked"
	else
		Estado=""		
	end if

	
	response.write("200\\")%>
	<div class="modal-dialog cascading-modal narrower modal-xl" role="document">  		
		<div class="modal-content">		
			<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
				<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-server"></i> Departamentos</div>				
			</div>				
			<div class="modal-body" style="padding:0px;">
				<div id="divfrmdepartamentos" class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
					<div class="px-4">						
						<form role="form" action="<%=action%>" method="POST" name="<%=frmdepartamentos%>" id="<%=frmdepartamentos%>" class="needs-validation">
							<div class="row">								
								<div class="col-sm-12 col-md-12 col-lg-6">
									<div class="md-form input-with-post-icon">
										<div class="error-message">
											<div class="select">
												<select name="DEP_Codigo" id="DEP_Codigo" class="select-text form-control" <%=ds%>><%
													if((DEP_Codigo="" or IsNULL(DEP_Codigo)) or (mode="add")) then%>
														<option value="" disabled selected></option><%
													end if
													set rs = cnn.Execute("exec spDepartamento_Listar 1")
													on error resume next					
													do While Not rs.eof
														if(rs("DEP_Id")>0) then
															if(DEP_Codigo = rs("DEP_Id")) then%>
																<option value="<%=rs("DEP_Id")%>" selected><%=rs("DEP_Descripcion")%></option><%
															else%>
																<option value="<%=rs("DEP_Id")%>"><%=rs("DEP_Descripcion")%></option><%
															end if
														end if
														rs.movenext						
													loop
													rs.Close%>
												</select>
												<i class="fas fa-tag input-prefix"></i>											
												<span class="select-highlight"></span>
												<span class="select-bar"></span>
												<label class="select-label <%=lblSelect%>">Departamento Dependiente</label>
											</div>
										</div>
									</div>
								</div>																
								<div class="col-sm-12 col-md-12 col-lg-6">
									<div class="md-form input-with-post-icon">
										<div class="error-message">								
											<i class="fas fa-tag input-prefix"></i><%
											if(DEP_Descripcion<>"") then
												lblClass="active"
											else
												lblClass=""
											end if%>
											<input type="text" id="DEP_Descripcion" name="DEP_Descripcion" class="form-control" <%=disabled%> value="<%=DEP_Descripcion%>">
											<span class="select-bar"></span>
											<label for="DEP_Descripcion" class="<%=lblClass%>">Departamento</label>
										</div>
									</div>
								</div>																
							</div>
							<div class="row align-items-center">
								<div class="col-sm-12 col-md-12 col-lg-6">
									<div class="md-form input-with-post-icon">
										<div class="error-message">								
											<i class="fas fa-tag input-prefix"></i><%
											if(DEP_DescripcionCorta<>"") then
												lblClass="active"
											else
												lblClass=""
											end if%>
											<input type="text" id="DEP_DescripcionCorta" name="DEP_DescripcionCorta" class="form-control" <%=disabled%> value="<%=DEP_DescripcionCorta%>">
											<span class="select-bar"></span>
											<label for="DEP_DescripcionCorta" class="<%=lblClass%>">Descripción Corta</label>
										</div>
									</div>
								</div>
								<div class="col-sm-12 col-md-12 col-lg-3">
									<div class="switch">
										<input type="checkbox" id="DEP_TipoVista" class="switch__input" <%=TipoVista%>>
										<label for="DEP_TipoVista" class="switch__label">Vista Global</label>
									</div>
								</div><%
								if(mode="mod") then%>
									<div class="col-sm-12 col-md-12 col-lg-3">
										<div class="switch">
											<input type="checkbox" id="DEP_Estado" class="switch__input" <%=Estado%>>
											<label for="DEP_Estado" class="switch__label">Estado</label>
										</div>
									</div><%
								end if%>
							</div><%
							if(mode="mod") then%>
								<input type="hidden" id="DEP_Id" name="DEP_Id" value="<%=DEP_Id%>"><%
							end if%>						
						</form>
						<!--form-->
					</div>
					<!--px-4-->
				</div>
				<!--divfrmdepartamentos-->												
			</div>
			<!--body-->
			<div class="modal-footer"><%
				if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2) then%>
					<div style="float:left;" class="btn-group" role="group" aria-label="">
						<button class="<%=button%>" type="button" data-url="" title="Modificar Departamento" id="btn_frmdepartamentos" name="btn_frmdepartamentos"><%=typeFrm%></button>
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
		
		$("#btn_frmdepartamentos").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			var mode='<%=mode%>';			
			if(mode=="add"){
				var msg="Departamento agregado exitosamente.";
			}else{
				if(mode=="mod"){
					var msg="Departamento modificado exitosamente.";
				}else{
					var msg="Sin modo.";
				}				
			}
			formValidate("#frmdepartamentos");			
			if($("#frmdepartamentos").valid()){	
				if($("#DEP_TipoVista").is(":checked")){
					var DEP_TipoVista = 1
				}else{
					var DEP_TipoVista = 0
				};			
				if($("#DEP_Estado").is(":checked")){
					var DEP_Estado = 1
				}else{
					var DEP_Estado = 0
				};			
				$.ajax({
					type: 'POST',
					url: $("#frmdepartamentos").attr("action"),
					data: $("#frmdepartamentos").serialize() + "&DEP_TipoVista=" + DEP_TipoVista + "&DEP_Estado=" + DEP_Estado,
					dataType: "json",
					success: function(data) {						
						if(data.state=="200"){
							if(mode=="add"){
								$("#frmdepartamentos")[0].reset();
							}
							Toast.fire({
							  icon: 'success',
							  title: msg
							});
						}else{
							swalWithBootstrapButtons.fire({
								icon:'error',
								title:'Ingreso/Modificación de Departamento Fallido',
								text:data.message
							});
						}
					},
					error: function(XMLHttpRequest, textStatus, errorThrown){						
						swalWithBootstrapButtons.fire({
							icon:'error',								
							title: 'Ups!, no pude cargar el menú del proyecto',					
						});				
					}
				})
			}
		})				
	})
</script>