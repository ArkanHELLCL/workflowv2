<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
	PRO_Id=request("PRO_Id")	
	mode=request("mode")			
	
	if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2) then
		frmproveedores="frmproveedores"
		disabled="required"
		calendario="calendario"
		if(mode="add") then
			typeFrm="<i class='fas fa-plus ml-1'></i> Agregar"
			button="btn btn-success btn-md waves-effect"
			lblSelect=""
			action="/agregar-proveedores"			
		else	
			if(mode="mod") then
				typeFrm="<i class='fas fa-download ml-1'></i> Grabar"
				button="btn btn-warning btn-md waves-effect"
				lblSelect=""
				action="/modificar-proveedores"
			else
				typeFrm=""
				button=""
				action=""
				lblSelect=""
			end if
		end if
	else
		frmproveedores=""
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
		set rs = cnn.Execute("exec spProveedores_Consultar " & PRO_Id)
		on error resume next	
		cnn.open session("DSN_WorkFlowv2")
		if cnn.Errors.Count > 0 then 
		   ErrMsg = cnn.Errors(0).description	   
		   cnn.close
		   response.Write("503\\Error Conexión:" & ErrMsg)
		   response.End() 			   
		end if	
		if not rs.eof then			
			PRO_RazonSocial	        = rs("PRO_RazonSocial")
			Rut		    	        = rs("PRO_Rut")
            PRO_DV			        = rs("PRO_DV")
            PRO_Rut = Rut & PRO_DV
			PRO_Direccion	        = rs("PRO_Direccion")
			PRO_Telefono	        = rs("PRO_Telefono")
			PRO_Mail		        = rs("PRO_Mail")
			ILD_Id			        = rs("PRO_Banco")
            TCU_Id			        = rs("TCU_Id")
            PRO_NumCuentaBancaria   = rs("PRO_NumCuentaBancaria")
            PRO_Estado              = rs("PRO_Estado")
			PRO_PAC					= rs("PRO_PAC")
		end if		
		rs.Close		
	end if	

	if(PRO_Estado=1) then
		Estado="checked"
	else
		Estado=""		
	end if

	if(PRO_PAC=1) then
		pac="checked"
	else
		pac=""		
	end if
	
	response.write("200\\")%>
	<div class="modal-dialog cascading-modal narrower modal-xl" role="document">  		
		<div class="modal-content">		
			<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
			<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-server"></i> Proveedores</div>				
			</div>				
			<div class="modal-body" style="padding:0px;">
				<div id="divfrmproveedores" class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
					<div class="px-4">						
						<form role="form" action="<%=action%>" method="POST" name="<%=frmproveedores%>" id="<%=frmproveedores%>" class="needs-validation">
							<div class="row">
                                <div class="col-sm-12 col-md-4 col-lg-5">
									<div class="md-form input-with-post-icon">
										<div class="error-message">								
											<i class="fas fa-user input-prefix"></i><%
											if(PRO_RazonSocial<>"") then
												lblClass="active"
											else
												lblClass=""
											end if%>
											<input type="text" id="PRO_RazonSocial" name="PRO_RazonSocial" class="form-control" <%=disabled%> value="<%=PRO_RazonSocial%>" data-msg="Debes ingresar una razon social">
											<span class="select-bar"></span>
											<label for="PRO_RazonSocial" class="<%=lblClass%>">Razon Social</label>
										</div>
									</div>
								</div>							
                                <div class="col-sm-12 col-md-4 col-lg-2">
									<div class="md-form input-with-post-icon">
										<div class="error-message">								
											<i class="fas fa-tag input-prefix"></i><%
											if(PRO_Rut<>"") then
												lblClass="active"
											else
												lblClass=""
											end if%>
											<input type="text" id="PRO_Rut" name="PRO_Rut" class="form-control" <%=disabled%> value="<%=PRO_Rut%>" data-msg="Debes ingresar un RUT válido">
											<span class="select-bar"></span>
											<label for="PRO_Rut" class="<%=lblClass%>">Rut</label>
										</div>
									</div>
								</div>
                                <div class="col-sm-12 col-md-4 col-lg-5">
									<div class="md-form input-with-post-icon">
										<div class="error-message">								
											<i class="fas fa-user input-prefix"></i><%
											if(PRO_Direccion<>"") then
												lblClass="active"
											else
												lblClass=""
											end if%>
											<input type="text" id="PRO_Direccion" name="PRO_Direccion" class="form-control" value="<%=PRO_Direccion%>">
											<span class="select-bar"></span>
											<label for="PRO_Direccion" class="<%=lblClass%>">Dirección</label>
										</div>
									</div>
								</div>
                            </div>
                            <div class="row">
                                <div class="col-sm-12 col-md-4 col-lg-4">
									<div class="md-form input-with-post-icon">
										<div class="error-message">								
											<i class="fas fa-phone input-prefix"></i><%
											if(PRO_Telefono<>"") then
												lblClass="active"
											else
												lblClass=""
											end if%>
											<input type="text" id="PRO_Telefono" name="PRO_Telefono" class="form-control"  value="<%=PRO_Telefono%>" pattern="^[0-9,$]{9}$" title="Debes ingresar un numero de 9 digitos">
											<span class="select-bar"></span>
											<label for="PRO_Telefono" class="<%=lblClass%>">Teléfono</label>
										</div>
									</div>
								</div>
                                <div class="col-sm-12 col-md-4 col-lg-8">
									<div class="md-form input-with-post-icon">
										<div class="error-message">								
											<i class="fas fa-envelope input-prefix"></i><%
											if(PRO_Mail<>"") then
												lblClass="active"
											else
												lblClass=""
											end if%>
											<input type="email" id="PRO_Mail" name="PRO_Mail" class="form-control" value="<%=PRO_Mail%>">
											<span class="select-bar"></span>
											<label for="PRO_Mail" class="<%=lblClass%>">Correo</label>
										</div>
									</div>
								</div>
                            </div>							
							<div class="row">								
								<div class="col-sm-12 col-md-12 col-lg-3 text-left">
									<div class="switch" style="max-width: 100px;">
										<input type="checkbox" id="PRO_PAC" class="switch__input" <%=pac%>>
										<label for="PRO_PAC" class="switch__label">PAC</label>
									</div>
								</div>
							</div><%
							style=""
							ds="required"
							disabled="required"
							if(PRO_PAC=1) then
								style="style='display:none;'"
								ds="disabled"
								disabled=""
							end if%>							
                            <div class="row" id="prodtobank" <%=style%>>
								<div class="col-sm-12 col-md-4 col-lg-4">
									<div class="md-form input-with-post-icon">
										<div class="error-message">
											<div class="select">
												<select name="ILD_Id" id="ILD_Id" class="select-text form-control" <%=ds%> data-msg="Debes ingresar un Banco"><%
													if((ILD_Id="" or IsNULL(ILD_Id)) or (mode="add")) then%>
														<option value="" disabled selected></option><%
													end if
													set rs = cnn.Execute("exec spItemListaDesplegable_Listar 2, 1")
													on error resume next					
													do While Not rs.eof
														if(rs("ILD_Id")>0) then
															if(ILD_Id = rs("ILD_Id")) then%>
																<option value="<%=rs("ILD_Id")%>" selected><%=rs("ILD_Descripcion")%></option><%
															else%>
																<option value="<%=rs("ILD_Id")%>"><%=rs("ILD_Descripcion")%></option><%
															end if
														end if
														rs.movenext						
													loop
													rs.Close%>
												</select>
												<i class="fas fa-tag input-prefix"></i>											
												<span class="select-highlight"></span>
												<span class="select-bar"></span>
												<label class="select-label <%=lblSelect%>">Banco</label>
											</div>
										</div>
									</div>
								</div>
                                <div class="col-sm-12 col-md-4 col-lg-4">
									<div class="md-form input-with-post-icon">
										<div class="error-message">
											<div class="select">
												<select name="TCU_Id" id="TCU_Id" class="select-text form-control" <%=ds%> data-msg="Debes ingresar un tipo de cuenta"><%
													if((TCU_Id="" or IsNULL(TCU_Id)) or (mode="add")) then%>
														<option value="" disabled selected></option><%
													end if
													set rs = cnn.Execute("exec spTipoCuenta_Listar 1")
													on error resume next					
													do While Not rs.eof
														if(rs("TCU_Id")>0) then
															if(TCU_Id = rs("TCU_Id")) then%>
																<option value="<%=rs("TCU_Id")%>" selected><%=rs("TCU_Descripcion")%></option><%
															else%>
																<option value="<%=rs("TCU_Id")%>"><%=rs("TCU_Descripcion")%></option><%
															end if
														end if
														rs.movenext						
													loop
													rs.Close%>
												</select>
												<i class="fas fa-tag input-prefix"></i>											
												<span class="select-highlight"></span>
												<span class="select-bar"></span>
												<label class="select-label <%=lblSelect%>">Tipo Cuenta</label>
											</div>
										</div>
									</div>
								</div>
                                <div class="col-sm-12 col-md-4 col-lg-4">
									<div class="md-form input-with-post-icon">
										<div class="error-message">								
											<i class="fas fa-envelope input-prefix"></i><%
											if(PRO_NumCuentaBancaria<>"") then
												lblClass="active"
											else
												lblClass=""
											end if%>
											<input type="text" id="PRO_NumCuentaBancaria" name="PRO_NumCuentaBancaria" class="form-control" value="<%=PRO_NumCuentaBancaria%>" <%=disabled%> data-msg="Debes ingresar un número de cuenta">
											<span class="select-bar"></span>
											<label for="PRO_NumCuentaBancaria" class="<%=lblClass%>">Número</label>
										</div>
									</div>
								</div>
							</div>	
							<div class="row align-items-center text-right float-right"><%
								if(mode="mod") then%>
									<div class="col-sm-12 col-md-12 col-lg-3">
										<div class="switch" style="max-width: 100px;">
											<input type="checkbox" id="PRO_Estado" class="switch__input" <%=Estado%>>
											<label for="PRO_Estado" class="switch__label">Estado</label>
										</div>
									</div><%
								end if%>
							</div><%
							if(mode="mod") then%>
								<input type="hidden" id="PRO_Id" name="PRO_Id" value="<%=PRO_Id%>"><%
							end if%>						
						</form>
						<!--form-->
					</div>
					<!--px-4-->
				</div>
				<!--divfrmproveedores-->												
			</div>
			<!--body-->
			<div class="modal-footer"><%
				if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2) then%>
					<div style="float:left;" class="btn-group" role="group" aria-label="">
						<button class="<%=button%>" type="button" data-url="" title="Modificar Proveedor" id="btn_frmproveedores" name="btn_frmproveedores"><%=typeFrm%></button>
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
	var rut = ( function rut_ch(){
        $('#PRO_Rut').Rut({
            format_on: 'keyup'				
        });			
    })		
    rut();

    $("#PRO_Rut").val($.Rut.formatear($("#PRO_Rut").val(),true));

	$(document).ready(function() {
		var ss = String.fromCharCode(47) + String.fromCharCode(47);		
		
		$("#PRO_PAC").on("click", function(e){
			if($("#PRO_PAC").is(":checked")){				
				$("#PRO_NumCuentaBancaria").removeAttr("required")
				$("#ILD_Id").removeAttr("required")
				$("#TCU_Id").removeAttr("required")
				$("#ILD_Id").attr("disabled","")
				$("#TCU_Id").attr("disabled","")
				$("#PRO_NumCuentaBancaria").attr("disabled","")
				$("#prodtobank").hide("slow");
				
			}else{
				$("#prodtobank").show("slow")
				$("#PRO_NumCuentaBancaria").attr("required","")
				$("#ILD_Id").attr("required","")
				$("#TCU_Id").attr("required","")

				$("#ILD_Id").removeAttr("disabled")
				$("#TCU_Id").removeAttr("disabled")
				$("#PRO_NumCuentaBancaria").removeAttr("disabled","")
			}			
		})
		
		$("#btn_frmproveedores").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			var mode='<%=mode%>';			
			if(mode=="add"){
				var msg="Proveedor agregado exitosamente.";
			}else{
				if(mode=="mod"){
					var msg="Proveedor modificado exitosamente.";
				}else{
					var msg="Sin modo.";
				}				
			}
			formValidate("#frmproveedores");			
			if($("#frmproveedores").valid()){				
				if($("#PRO_Estado").is(":checked")){
					var PRO_Estado = 1
				}else{
					var PRO_Estado = 0
				};
				if($("#PRO_PAC").is(":checked")){
					var PRO_PAC = 1
				}else{
					var PRO_PAC = 0
				};
				$.ajax({
					type: 'POST',
					url: $("#frmproveedores").attr("action"),
					data: $("#frmproveedores").serialize() + "&PRO_Estado=" + PRO_Estado + "&PRO_PAC=" + PRO_PAC,
					dataType: "json",
					success: function(data) {						
						if(data.state=="200"){
							if(mode=="add"){
								$("#frmproveedores")[0].reset();
							}
							Toast.fire({
							  icon: 'success',
							  title: msg
							});
						}else{
							if(data.state=="401"){
								swalWithBootstrapButtons.fire({
									icon:'warning',
									title:'Ingreso/Modificación de Proveedor Fallido',
									text:data.message + " " + data.data.PRO_RazonSocial
								});
							}else{
								swalWithBootstrapButtons.fire({
									icon:'error',
									title:'Ingreso/Modificación de Proveedor Fallido',
									text:data.message
								});
							}
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