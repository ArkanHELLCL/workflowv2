<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
	COM_Id=request("COM_Id")	
	mode=request("mode")			
	
	if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2) then
		frmcomunas="frmcomunas"
		disabled="required"
		calendario="calendario"
		if(mode="add") then
			typeFrm="<i class='fas fa-plus ml-1'></i> Agregar"
			button="btn btn-success btn-md waves-effect"
			lblSelect=""
			action="/agregar-comunas"			
		else	
			if(mode="mod") then
				typeFrm="<i class='fas fa-download ml-1'></i> Grabar"
				button="btn btn-warning btn-md waves-effect"
				lblSelect=""
				action="/modificar-comunas"
			else
				typeFrm=""
				button=""
				action=""
				lblSelect=""
			end if
		end if
	else
		frmcomunas=""
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
		set rs = cnn.Execute("exec spComuna_Consultar " & COM_Id)
		on error resume next	
		cnn.open session("DSN_WorkFlowv2")
		if cnn.Errors.Count > 0 then 
		   ErrMsg = cnn.Errors(0).description	   
		   cnn.close
		   response.Write("503\\Error Conexión:" & ErrMsg)
		   response.End() 			   
		end if	
		if not rs.eof then			
			REG_Nombre	= rs("REG_Nombre")			
			COM_Nombre	= rs("COM_Nombre")
			COM_OrdenGeografico = rs("COM_OrdenGeografico")
			REG_Id = rs("REG_Id")
		end if		
		rs.Close		
	end if
	COM_OrdenGeografico = mid(COM_OrdenGeografico,len(REG_Id)+1,len(COM_OrdenGeografico))
	
	response.write("200\\")%>
	<div class="modal-dialog cascading-modal narrower modal-xl" role="document">  		
		<div class="modal-content">		
			<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
				<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-server"></i> Comunas</div>				
			</div>				
			<div class="modal-body" style="padding:0px;">
				<div id="divfrmcomunas" class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
					<div class="px-4">						
						<form role="form" action="<%=action%>" method="POST" name="<%=frmcomunas%>" id="<%=frmcomunas%>" class="needs-validation">
							<div class="row">								
								<div class="col-sm-12 col-md-12 col-lg-4">
									<div class="md-form input-with-post-icon">
										<div class="error-message"><%
											if(mode="mod") then
												if(REG_Nombre<>"") then
													lblClass="active"
												else
													lblClass=""
												end if%>
												<i class="fas fa-tag input-prefix"></i>											
												<input type="text" id="REG_Nombre" name="REG_Nombre" class="form-control" readonly value="<%=REG_Nombre%>">
												<span class="select-bar"></span>
												<label for="REG_Nombre" class="<%=lblClass%>">Región</label><%
											else%>
												<div class="select">
													<select name="REG_Id" id="REG_Id" class="select-text form-control" required><%
														if((REG_Id="") or (mode="add")) then%>
															<option value="" disabled selected></option><%
														end if
														set rs = cnn.Execute("exec spRegion_Listar")
														on error resume next					
														do While Not rs.eof
															if(REG_Id = rs("REG_Id")) then%>
																<option value="<%=rs("REG_Id")%>" selected><%=rs("REG_Nombre")%></option><%
															else%>
																<option value="<%=rs("REG_Id")%>"><%=rs("REG_Nombre")%></option><%
															end if
															rs.movenext						
														loop
														rs.Close%>
													</select>
													<i class="fas fa-tag input-prefix"></i>											
													<span class="select-highlight"></span>
													<span class="select-bar"></span>
													<label class="select-label <%=lblSelect%>">Región</label>
												</div><%												
											end if%>											
										</div>
									</div>
								</div>																
								<div class="col-sm-12 col-md-12 col-lg-4">
									<div class="md-form input-with-post-icon">
										<div class="error-message">								
											<i class="fas fa-tag input-prefix"></i><%
											if(COM_Nombre<>"") then
												lblClass="active"
											else
												lblClass=""
											end if%>
											<input type="text" id="COM_Nombre" name="COM_Nombre" class="form-control" <%=disabled%> value="<%=COM_Nombre%>">
											<span class="select-bar"></span>
											<label for="COM_Nombre" class="<%=lblClass%>">Comuna</label>
										</div>
									</div>
								</div>
								<div class="col-sm-12 col-md-12 col-lg-4">
									<div class="md-form input-with-post-icon">
										<div class="error-message">								
											<i class="fas fa-tag input-prefix"></i><%
											if(COM_OrdenGeografico<>"") then
												lblClass="active"
											else
												lblClass=""
											end if%>
											<input type="text" id="COM_OrdenGeografico" name="COM_OrdenGeografico" class="form-control" <%=disabled%> value="<%=COM_OrdenGeografico%>">
											<span class="select-bar"></span>
											<label for="COM_OrdenGeografico" class="<%=lblClass%>">Orden Geográfico</label>
										</div>
									</div>
								</div>
							</div><%
							if(mode="mod") then%>
								<input type="hidden" id="REG_Id" name="REG_Id" value="<%=REG_Id%>">
								<input type="hidden" id="COM_Id" name="COM_Id" value="<%=COM_Id%>"><%
							end if%>						
						</form>
						<!--form-->
					</div>
					<!--px-4-->
				</div>
				<!--divfrmcomunas-->												
			</div>
			<!--body-->
			<div class="modal-footer"><%
				if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2) then%>
					<div style="float:left;" class="btn-group" role="group" aria-label="">
						<button class="<%=button%>" type="button" data-url="" title="Modificar Región" id="btn_frmcomunas" name="btn_frmcomunas"><%=typeFrm%></button>
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
		
		$("#btn_frmcomunas").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			var mode='<%=mode%>';			
			if(mode=="add"){
				var msg="Comuna agregada exitosamente.";
			}else{
				if(mode=="mod"){
					var msg="Comuna modificada exitosamente.";
				}else{
					var msg="Sin modo.";
				}				
			}
			formValidate("#frmcomunas");			
			if($("#frmcomunas").valid()){				
				$.ajax({
					type: 'POST',
					url: $("#frmcomunas").attr("action"),
					data: $("#frmcomunas").serialize(),
					dataType: "json",
					success: function(data) {						
						if(data.state=="200"){
							if(mode=="add"){
								$("#frmcomunas")[0].reset();
							}
							Toast.fire({
							  icon: 'success',
							  title: msg
							});
						}else{
							swalWithBootstrapButtons.fire({
								icon:'error',
								title:'Ingreso de Comuna Fallido',
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