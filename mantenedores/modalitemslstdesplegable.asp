<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%    
	ILD_Id=request("ILD_Id")	
	mode=request("mode")			
	
	if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2) then
		frmlitemslstdesplegable="frmlitemslstdesplegable"
		disabled="required"
		calendario="calendario"
		if(mode="add") then
			typeFrm="<i class='fas fa-plus ml-1'></i> Agregar"
			button="btn btn-success btn-md waves-effect"
			lblSelect=""
			action="/agregar-itemslistadesplegable"			
		else	
			if(mode="mod") then
				typeFrm="<i class='fas fa-download ml-1'></i> Grabar"
				button="btn btn-warning btn-md waves-effect"
				lblSelect=""
				action="/modificar-itemslistadesplegable"
			else
				typeFrm=""
				button=""
				action=""
				lblSelect=""
			end if
		end if
	else
		frmlitemslstdesplegable=""
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
		set rs = cnn.Execute("exec spItemListaDesplegable_Consultar " & ILD_Id)
		on error resume next	
		cnn.open session("DSN_WorkFlowv2")
		if cnn.Errors.Count > 0 then 
		   ErrMsg = cnn.Errors(0).description	   
		   cnn.close
		   response.Write("503\\Error Conexión:" & ErrMsg)
		   response.End() 			   
		end if	
		if not rs.eof then	
            LID_Id = rs("LID_Id")		
			ILD_Descripcion	= LimpiarUrl(rs("ILD_Descripcion"))
			ILD_Estado	= rs("ILD_Estado")			
		end if		
		rs.Close		
	end if
	Estado=""
	if(IsNULL(ILD_Estado)) then
		ILD_Estado=0		
	end if
	if(CInt(ILD_Estado)=1) then
		Estado = "checked"
	end if
	response.write("200\\")%>
	<div class="modal-dialog cascading-modal narrower modal-xl" role="document">  		
		<div class="modal-content">		
			<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
				<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-server"></i> Item de Lista Desplegable</div>				
			</div>				
			<div class="modal-body" style="padding:0px;">
				<div id="divfrmlitemslstdesplegable" class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
					<div class="px-4">						
						<form role="form" action="<%=action%>" method="POST" name="<%=frmlitemslstdesplegable%>" id="<%=frmlitemslstdesplegable%>" class="needs-validation">
							<div class="row align-items-center">
                                <div class="col-sm-12 col-md-12 col-lg-5">
									<div class="md-form input-with-post-icon">
										<div class="error-message">
											<div class="select">
												<select name="LID_Id" id="LID_Id" class="select-text form-control" <%=ds%>><%
													if((LID_Id="") or (mode="add")) then%>
														<option value="" disabled selected></option><%
													end if
													set rs = cnn.Execute("exec spListaDesplegable_Listar -1")
													on error resume next					
													do While Not rs.eof
														if(LID_Id = rs("LID_Id")) then%>
															<option value="<%=rs("LID_Id")%>" selected><%=rs("LID_Descripcion")%></option><%
														else%>
															<option value="<%=rs("LID_Id")%>"><%=rs("LID_Descripcion")%></option><%
														end if
														rs.movenext						
													loop
													rs.Close%>
												</select>
												<i class="fas fa-tag input-prefix"></i>											
												<span class="select-highlight"></span>
												<span class="select-bar"></span>
												<label class="select-label <%=lblSelect%>">Lista Desplegable</label>
											</div>
										</div>
									</div>
								</div>								
								<div class="col-sm-12 col-md-12 col-lg-5">
									<div class="md-form input-with-post-icon">
										<div class="error-message">								
											<i class="fas fa-tag input-prefix"></i><%
											if(ILD_Descripcion<>"") then
												lblClass="active"
											else
												lblClass=""
											end if%>
											<input type="text" id="ILD_Descripcion" name="ILD_Descripcion" class="form-control" <%=disabled%> value="<%=ILD_Descripcion%>">
											<span class="select-bar"></span>
											<label for="ILD_Descripcion" class="<%=lblClass%>">Descripción Item</label>
										</div>
									</div>
								</div>								
                                <div class="col-sm-12 col-md-12 col-lg-2">
									<div class="switch"><%
										if(mode="add") then%>
											<input type="checkbox" id="ILD_Estado" class="switch__input" checked disabled><%
										else%>
											<input type="checkbox" id="ILD_Estado" class="switch__input" <%=Estado%>><%
										end if%>
										<label for="ILD_Estado" class="switch__label">Activado</label>
									</div>
								</div>																
							</div><%
							if(mode="mod") then%>
								<input type="hidden" id="ILD_Id" name="ILD_Id" value="<%=ILD_Id%>"><%                            
							end if%>						
						</form>
						<!--form-->
					</div>
					<!--px-4-->
				</div>
				<!--divfrmlitemslstdesplegable-->												
			</div>
			<!--body-->
			<div class="modal-footer"><%
				if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2) then%>
					<div style="float:left;" class="btn-group" role="group" aria-label="">
						<button class="<%=button%>" type="button" data-url="" title="Modificar Item Lista Desplegable" id="btn_frmlitemslstdesplegable" name="btn_frmlitemslstdesplegable"><%=typeFrm%></button>
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
		
		$("#btn_frmlitemslstdesplegable").click(function(e){
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
			formValidate("#frmlitemslstdesplegable");			
			if($("#frmlitemslstdesplegable").valid()){
				if($("#ILD_Estado").is(":checked")){
					var ILD_Estado = 1
				}else{
					var ILD_Estado = 0
				}
				$.ajax({
					type: 'POST',
					url: $("#frmlitemslstdesplegable").attr("action"),
					data: $("#frmlitemslstdesplegable").serialize() + "&ILD_Estado=" + ILD_Estado,
					dataType: "json",
					success: function(data) {						
						if(data.state=="200"){
							if(mode=="add"){
								$("#frmlitemslstdesplegable")[0].reset();
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