<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
	USR_Id=request("USR_Id")	
	mode=request("mode")
	
	if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2) then
		frmusuarios="frmusuarios"
		disabled="required"
		telefono=""
		calendario="calendario"
		if(mode="add") then
			typeFrm="<i class='fas fa-plus ml-1'></i> Agregar"
			button="btn btn-success btn-md waves-effect"
			lblSelect=""
			action="/agregar-usuarios"

			columnsFLU="{data: ""VFL_Id""},{data: ""FLU_Descripcion""},{data: ""VFL_Estado""},{className: 'delflu',orderable: false,data: ""Del""}"
		else	
			if(mode="mod") then
				typeFrm="<i class='fas fa-download ml-1'></i> Grabar"
				button="btn btn-warning btn-md waves-effect"
				lblSelect=""
				action="/modificar-usuarios"
				columnsFLU="{data: ""VFL_Id""},{data: ""FLU_Descripcion""},{data: ""VFL_Estado""},{className: 'delflu',orderable: false,data: ""Del""}"
			else
				typeFrm=""
				button=""
				action=""
				lblSelect=""
				columnsFLU="{data: ""VFL_Id""},{data: ""FLU_Descripcion""},{data: ""VFL_Estado""}"
			end if
		end if
	else
		frmusuarios=""
		disabled="readonly"
		telefono="readonly"
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
			ds = "required"		
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
		set rs = cnn.Execute("exec spUsuario_Consultar " & USR_Id)
		on error resume next		
		if cnn.Errors.Count > 0 then 
		   ErrMsg = cnn.Errors(0).description	   
		   cnn.close
		   response.Write("503\\Error Conexión:" & ErrMsg)
		   response.End() 			   
		end if	
		if not rs.eof then
			USR_Identificador				= rs("USR_Identificador")
			PER_Id							= rs("PER_Id")
			PER_Nombre						= rs("PER_Nombre")
			USR_Estado         				= rs("USR_Estado")
			USR_Usuario 					= rs("USR_Usuario")
			USR_Telefono					= rs("USR_Telefono")			
			USR_Mail						= rs("USR_Mail")			
			USR_Nombre						= rs("USR_Nombre")
			USR_Apellido					= rs("USR_Apellido")
			Rut								= rs("USR_Rut")
			USR_Dv							= rs("USR_Dv")
			SEX_Id                          = rs("SEX_Id")			
			DEP_Id							= rs("DEP_Id")
			USR_Jefatura					= rs("USR_Jefatura")
			USR_Firma						= rs("USR_Firma")
		end if
		if SEX_Id=1 then
		  	Sexo="fa-venus"
	    else
			if SEX_Id=2 then
				Sexo="fa-mars"
			else
				Sexo="fa-venus-mars"
			end if
	    end if		
		USR_Rut=Rut & USR_Dv
		rs.Close		
	else		
		SEX_Id=0
		PER_Id=0
		USR_Estado=1	'Activado		
		DEP_Id=0
	end if
		
	if(USR_Estado=1) then
		Estado="checked"
	else
		Estado=""		
	end if

	if(USR_Jefatura=1) then
		EstadoJef="checked disabled"
		EstadoDep="disabled"
		lblDep="active"
	else
		EstadoJef=""		
		EstadoDep=""
		lblDep=""
	end if
	
	response.write("200\\")%>	
	<div class="modal-dialog cascading-modal narrower modal-xl" role="document">  		
		<div class="modal-content">		
			<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
				<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-server"></i> Usuarios</div>				
			</div>				
			<div class="modal-body" style="padding:0px;">
				<div class="mCustomScrollbar" style="padding-right:20px;padding-left:20px;padding-bottom:20px">
					<!--container-nav-->
					<div class="container-nav" name="man-usuarios" id="man-usuarios">
						<div class="header">				
							<div class="content-nav">

								<a id="tabusuario-tab" href="#tabusuario" class="<%=active%> tab"><i class="fas fa-id-card-alt"></i> Datos del Usuario</a><%
								if(mode="mod") then%>								
									<a id="tabusuarioflujo-tab" href="#tabusuarioflujo" class="<%=active%> tab"><i class="fas fa-sitemap"></i> Flujos asignados
										<span class="badge right blue badgeflu">0</span>
									</a><%
								end if%>
								<span class="yellow-bar"></span>
								
							</div>				
						</div>
					
						<!--tab-content-->
						<div class="tab-content">
							<div id="tabusuario">
								<div id="divfrmusuarios" class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
									<div class="px-4">						
										<form role="form" action="<%=action%>" method="POST" name="<%=frmusuarios%>" id="<%=frmusuarios%>" class="needs-validation">
											<div class="row">																							
												<div class="col-sm-12 col-md-12 col-lg-4">
													<div class="md-form input-with-post-icon">
														<div class="error-message">								
															<i class="fas fa-tag input-prefix"></i><%
															if(USR_Usuario<>"") then
																lblClass="active"
															else
																lblClass=""
															end if%>
															<input type="text" id="USR_Usuario" name="USR_Usuario" class="form-control" readonly required value="<%=USR_Usuario%>">
															<span class="select-bar"></span>
															<label for="USR_Usuario" class="<%=lblClass%>">Usuario</label>
														</div>
													</div><%
													if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2) then%>
														<i class="fas fa-search search usrSearch"></i><%
													end if%>
												</div>
												<div class="col-sm-12 col-md-12 col-lg-4">
													<div class="md-form input-with-post-icon">
														<div class="error-message">								
															<i class="fas fa-user input-prefix"></i><%
															if(USR_Nombre<>"") then
																lblClass="active"
															else
																lblClass=""
															end if%>
															<input type="text" id="USR_Nombre" name="USR_Nombre" class="form-control" <%=disabled%> value="<%=USR_Nombre%>">
															<span class="select-bar"></span>
															<label for="USR_Nombre" class="<%=lblClass%>">Nombres</label>
														</div>
													</div>
												</div>
												<div class="col-sm-12 col-md-12 col-lg-4">
													<div class="md-form input-with-post-icon">
														<div class="error-message">								
															<i class="fas fa-user input-prefix"></i><%
															if(USR_Apellido<>"") then
																lblClass="active"
															else
																lblClass=""
															end if%>
															<input type="text" id="USR_Apellido" name="USR_Apellido" class="form-control" <%=disabled%> value="<%=USR_Apellido%>">
															<span class="select-bar"></span>
															<label for="USR_Apellido" class="<%=lblClass%>">Apellidos</label>
														</div>
													</div>
												</div>
											</div>
											<div class="row">
												<div class="col-sm-12 col-md-12 col-lg-2">
													<div class="md-form input-with-post-icon">
														<div class="error-message">								
															<i class="fas fa-id-card input-prefix"></i><%
															if(USR_Rut<>"") then
																lblClass="active"
															else
																lblClass=""
															end if%>
															<input type="text" id="USR_Rut" name="USR_Rut" class="form-control" <%=disabled%> value="<%=USR_Rut%>">
															<span class="select-bar"></span>
															<label for="USR_Rut" class="<%=lblClass%>">Rut</label>
														</div>
													</div>
												</div>
												<div class="col-sm-12 col-md-12 col-lg-5">
													<div class="md-form input-with-post-icon">
														<div class="error-message">								
															<i class="fas fa-envelope input-prefix"></i><%
															if(USR_Mail<>"") then
																lblClass="active"
															else
																lblClass=""
															end if%>
															<input type="email" id="USR_Mail" name="USR_Mail" class="form-control" readonly value="<%=USR_Mail%>">
															<span class="select-bar"></span>
															<label for="USR_Mail" class="<%=lblClass%>">Email</label>
														</div>
													</div>
												</div>
												<div class="col-sm-12 col-md-12 col-lg-5">
													<div class="md-form input-with-post-icon">
														<div class="error-message">															
															<div class="select">
																<select name="DEP_Id" id="DEP_Id" class="select-text form-control" <%=ds%>><%
																	if((DEP_Id="") or (mode="add")) then%>
																		<option value="" disabled selected></option><%
																	end if
																	set rs = cnn.Execute("exec spDepartamento_Listar 1")
																	on error resume next					
																	do While Not rs.eof
																		if(DEP_Id = rs("DEP_Id")) then%>
																			<option value="<%=rs("DEP_Id")%>" selected><%=rs("DEP_Descripcion")%></option><%
																		else%>
																			<option value="<%=rs("DEP_Id")%>"><%=rs("DEP_Descripcion")%></option><%
																		end if
																		rs.movenext						
																	loop
																	rs.Close%>
																</select>
																<i class="fas fa-map-marker-alt input-prefix"></i>
																<span class="select-bar"></span>
																<label class="select-label <%=lblSelect%>">Departamento</label>
															</div>
														</div>
													</div>
												</div>
											</div>							
											<div class="row align-items-center">														
												<div class="col-sm-12 col-md-12 col-lg-3">
													<div class="md-form input-with-post-icon">
														<div class="error-message">								
															<i class="fas fa-mobile input-prefix"></i><%
															if(USR_Telefono<>"") then
																lblClass="active"
															else
																lblClass=""
															end if%>
															<input type="number" id="USR_Telefono" name="USR_Telefono" class="form-control" <%=telefono%> value="<%=USR_Telefono%>">
															<span class="select-bar"></span>
															<label for="USR_Telefono" class="<%=lblClass%>">Telefono</label>
														</div>
													</div>
												</div>								
												<div class="col-sm-12 col-md-12 col-lg-3">
													<div class="md-form input-with-post-icon">
														<div class="error-message">
															<div class="select">
																<select name="SEX_Id" id="SEX_Id" class="validate select-text form-control" <%=ds%>>
																	<option value="" disabled selected></option><%																	
																	set rs = cnn.Execute("exec spSexo_listar")
																	on error resume next					
																	do While Not rs.eof
																		if(SEX_Id=rs("SEX_Id")) then%>
																			<option value="<%=rs("SEX_Id")%>" selected><%=rs("SEX_Descripcion")%></option><%
																		else%>
																			<option value="<%=rs("SEX_Id")%>"><%=rs("SEX_Descripcion")%></option><%
																		end if
																		rs.movenext						
																	loop
																	rs.Close%>
																</select>									
																<i class="fas <%=sexo%> input-prefix"></i>
																<span class="select-highlight"></span>
																<span class="select-bar"></span>
																<label class="select-label <%=lblSelect%>">Género</label>
															</div>
														</div>	
													</div>
												</div>																						
												<div class="col-sm-12 col-md-12 col-lg-4">
													<div class="md-form input-with-post-icon">
														<div class="error-message"><%
															if(CInt(session("wk2_usrid"))=CInt(USR_Id)) then%>
																<i class="fas fa-mobile input-prefix"></i>
																<input type="text" id="PER_Nombre" name="PER_Nombre" class="form-control" readonly value="<%=PER_Nombre%>">
																<input type="hidden" id="PER_Id" name="PER_Id" value="<%=PER_Id%>">
																<span class="select-bar"></span>
																<label for="USR_Telefono" class="<%=lblClass%>">Perfil</label><%
															else%>
																<div class="select">
																	<select name="PER_Id" id="PER_Id" class="validate select-text form-control" <%=ds%>>
																		<option value="" disabled selected></option><%																	
																		set rs = cnn.Execute("exec spPerfil_listar -1")
																		on error resume next					
																		do While Not rs.eof
																			if(session("wk2_usrperfil")=1) then
																				if(PER_Id=rs("PER_Id")) then%>
																					<option value="<%=rs("PER_Id")%>" selected><%=rs("PER_Nombre")%></option><%
																				else%>
																					<option value="<%=rs("PER_Id")%>"><%=rs("PER_Nombre")%></option><%
																				end if
																			else
																				if(session("wk2_usrperfil")=2) then
																					if(PER_Id=1) then%>
																						<option value="1" selected>Super Administrador</option><%
																						exit do
																					else
																						if(rs("PER_Id")>1) then
																							if(PER_Id=rs("PER_Id")) then%>
																								<option value="<%=rs("PER_Id")%>" selected><%=rs("PER_Nombre")%></option><%
																							else
																								if(rs("PER_Id")>2) then%>
																									<option value="<%=rs("PER_Id")%>"><%=rs("PER_Nombre")%></option><%
																								end if
																							end if
																						end if
																					end if
																				end if
																			end if
																			rs.movenext						
																		loop
																		rs.Close%>
																	</select>									
																	<i class="fas fa-user-tie input-prefix"></i>
																	<span class="select-highlight"></span>
																	<span class="select-bar"></span>
																	<label class="select-label <%=lblSelect%>">Perfil</label>
																</div><%
															end if%>
														</div>	
													</div>
												</div>
												<div class="col-sm-12 col-md-12 col-lg-2">
													<div class="switch">
														<input type="checkbox" id="USR_Jefatura" class="switch__input" <%=EstadoJef%>>
														<label for="USR_Jefatura" class="switch__label">Jefatura</label>
													</div>
												</div>								
											</div>							
											<div class="row align-items-center">
												<div class="col-sm-12 col-md-12 col-lg-6">
													<div class="md-form input-with-post-icon">
														<div class="error-message">
															<!--<input id="inp" type='file'>-->
															<input type="text" id="inpX" name="inpX" class="form-control">
															<input type="file" id="inp" name="inp" readonly="" accept="image/png,image/x-png,image/jpg,image/jpeg,image/gif" style="display: none;width: 0;height: 0;">
															<i class="fas fa-upload input-prefix input-prefix"></i>
															<span class="select-highlight"></span>
															<span class="select-bar"></span>
															<label class="select-label">Firma</label>
														</div>
													</div>									
												</div>
												<div class="col-sm-12 col-md-12 col-lg-4">
												</div>
												<div class="col-sm-12 col-md-12 col-lg-2">
													<div class="switch">
														<input type="checkbox" id="USR_Estado" class="switch__input" <%=Estado%>>
														<label for="USR_Estado" class="switch__label">Activado</label>
													</div>
												</div>
											</div>
											<div class="row justify-content-begin" style="padding-bottom:20px;">
												<div class="col-sm-12 col-md-12 col-lg-4">
													<i class="far fa-times-circle delimg"></i>
													<img id="img" src="<%=trim(USR_Firma)%>" class="float-left" width="230px" height="120px">
													<input type="hidden" id="USR_Firma" name="USR_Firma" value="<%=USR_Firma%>">
												</div>
											</div><%
											if(mode="mod") then%>
												<input type="hidden" id="USR_Id" name="USR_Id" value="<%=USR_Id%>">	<%											
											end if%>						
										</form>
										<!--form-->
										<div class="row" style="justify-content: flex-end;"><%
											if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2) then%>
												<div style="float:left;" class="btn-group" role="group" aria-label="">
													<button class="<%=button%>" type="button" data-url="" title="Modificar Usuario" id="btn_frmusuarios" name="btn_frmusuarios"><%=typeFrm%></button>
												</div><%
											end if%>

											<div style="float:right;" class="btn-group" role="group" aria-label="">					
												<button type="button" class="btn btn-secondary btn-md waves-effect" id="btnSalirModalUsuarios" data-toggle="tooltip" title="Salir"><i class="fas fa-sign-out-alt"></i> Salir</button>
											</div>				
										</div>
									</div>
									<!--px-4-->
								</div>
								<!--divfrmusuarios-->
							</div>
							<div id="tabusuarioflujo"><%
								if(mode="mod") then%>
									<div id="usrflujos">									
										<form role="form" action="/agregar-flujo-usuario" method="POST" name="frm10s3_1" id="frm10s3_1" class="needs-validation">
											<div class="row">                                                                         
												<div class="col-sm-6 col-md-6 col-lg-6">
													<div class="md-form input-with-post-icon">
														<div class="error-message">
															<div class="select">
																<select name="VFL_Id" id="VFL_Id" class="validate select-text form-control" <%=disabled%>>
																	
																</select>
																<i class="fas fa-map-marker-alt input-prefix"></i>
																<span class="select-highlight"></span>
																<span class="select-bar"></span>
																<label class="select-label">Flujo</label>
															</div>
														</div>
													</div>							
												</div>

												<div class="col-sm-6 col-md-6 col-lg-6" style="padding-top: 23px;text-align:left;">
													<button type="button" class="btn btn-success btn-md waves-effect waves-dark" id="btn_frm10s3_1" name="btn_frm10s3_1"><i class="fas fa-plus"></i></button>	
												</div>						
											</div>
											<input type="hidden" name="USR_Id" id="USR_Id" value="<%=USR_Id%>">
										</form>
										
										<table id="tbl-usrflu" class="ts table table-striped table-bordered dataTable table-sm" data-id="usrflu" data-page="true" data-selected="true" data-keys="1"> 
											<thead> 
												<tr> 
													<th style="width:10px;">Id</th>
													<th>Flujo</th>
													<th>Estado</th>
													<%
													if(mode="mod") then%>
														<th>Eliminar</th><%
													end if%>
												</tr> 
											</thead>					
											<tbody> 
											<%											
												set rs=cnn.execute("exec spUsuarioVersionFlujo_Listar -1," & USR_Id)											
												on error resume next
												if cnn.Errors.Count > 0 then 
													ErrMsg = cnn.Errors(0).description
													'response.write ErrMsg & " strig= " & sq			
													cnn.close 			   
													Response.end()
												End If
												dataFlujosUsuario = "["
												do While Not rs.EOF
													flujo = false
													if (session("wk2_usrperfil")=1) then
														flujo = true
													end if
													set rt=cnn.execute("exec [spUsuarioVersionFlujoxUsuarioFlujo_Consultar] " & session("wk2_usrid") & "," & rs("VFL_Id"))
													on error resume next
													if not rt.eof then
														flujo = true
													end if
													Estado="Bloqueado"
													if(rs("VFL_Estado")=1) then
														Estado="Activo"
													end if
													if(mode="mod" and flujo) then
														dataFlujosUsuario = dataFlujosUsuario & "{""VFL_Id"":""" & rs("VFL_Id") & """,""FLU_Descripcion"":""" & rs("FLU_Descripcion") & "(V." & rs("VFL_Id") & ")" & """,""VFL_Estado"":""" & Estado & """,""Del"":""<i class='fas fa-trash-alt text-danger' data-uvf='" & rs("UVF_Id") & "'></i>"""
													else
														dataFlujosUsuario = dataFlujosUsuario & "{""VFL_Id"":""" & rs("VFL_Id") & """,""FLU_Descripcion"":""" & rs("FLU_Descripcion") & "(V." & rs("VFL_Id") & ")" & """,""VFL_Estado"":""" & Estado & """,""Del"":"""""
													end if
													dataFlujosUsuario = dataFlujosUsuario & "}"											
													rs.movenext
													if not rs.eof then
														dataFlujosUsuario = dataFlujosUsuario & ","
													end if
												loop
												dataFlujosUsuario=dataFlujosUsuario & "]"								
												rs.close											
											%>                	
											</tbody>
										</table>
									</div><%
								end if%>
							</div>
						</div>
					</div>
				</div>
			</div>
			<!--body-->
			<div class="modal-footer">	
			</div>		  
			<!--footer-->	
		</div>
	</div>

<script>
	//modalusuarios
	$(function () {
		$('[data-toggle="tooltip"]').tooltip({
			trigger : 'hover'
		})
		$('[data-toggle="tooltip"]').on('click', function () {
			$(this).tooltip('hide')
		})		
	});
	var ss = String.fromCharCode(47) + String.fromCharCode(47);
	var s = String.fromCharCode(47);
	var bb = String.fromCharCode(92) + String.fromCharCode(92);
	var b = String.fromCharCode(92);
	var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);

	$(document).ready(function() {		
		var UsuarioLDAPTable;		
		var rut = ( function rut_ch(){
			$('#USR_Rut').Rut({
				format_on: 'keyup'				
			});			
		})		
		rut();
		if($("#USR_Firma").val()!=""){
			$(".delimg").show();
		}
		$(".mCustomScrollbar").mCustomScrollbar({
			theme:scrollTheme,
			advanced:{
				autoExpandHorizontalScroll:true,
				updateOnContentResize:true,
				autoExpandVerticalScroll:true,
				scrollbarPosition:"outside"
			},
		});	
		
		$(".content-nav").tabsmaterialize({menumovil:false},function(){			
			/*var FLU_Id = $(this.toString()).data("flu");
					
			if ( ! $.fn.DataTable.isDataTable( '#tblreq-' + FLU_Id ) ) {
				tableRequerimientos(FLU_Id)					
			}else{
				requerimientosTable.ajax.reload();
			}*/
		});	

		$("#PER_Id").on("change",function(){			
		})
		$("#USR_Rut").val($.Rut.formatear($("#USR_Rut").val(),true));

		var flujosusuarioTable;		
		var mode='<%=mode%>';
				
		function loadTableFlujosUsuario(data) {
			$(".badgeflu").html(data.length);
			flujosusuarioTable = $('#tbl-usrflu').DataTable({				
				lengthMenu: [ 5,10,20 ],
				data:data,
				columnDefs: [ {
				  targets  : 'no-sort',
				  orderable: false,
				}],
				columns: [<%=columnsFLU%>],
				order: [
					[0, 'asc']
				]			
			});						
		};
		if(mode=="mod"){
			var dataFlujosUsuario = <%=dataFlujosUsuario%>
			loadTableFlujosUsuario(dataFlujosUsuario);
        	$('#tbl-usrflu').css('width','100%')
		}
		<%if(mode="mod") then %>
		loadUsuarioFlujos();
		function loadUsuarioFlujos(){
			$.ajax({
				type: 'POST',			
				url: '/listar-flujos-usuario',
				data:{USR_Id:<%=USR_Id%>},
				success: function(data) {					
					param=data.split(bb);									
					if(param[0]=="200"){
						$("#VFL_Id").html(param[1]);
					}else{
						swalWithBootstrapButtons.fire({
							icon:'error',								
							title: 'Ups!, no pude cargar los flujos',					
							text:param[1]
						});
					}
				},
				error: function(XMLHttpRequest, textStatus, errorThrown){
					swalWithBootstrapButtons.fire({
						icon:'error',								
						title: 'Ups!, error al cargar archivo'							
					});
				}
			});
		}
		<%end if%>
		$('select#SEX_Id').on('change', function(e){				
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();			
			if($(this).val()==1){
				$(this).siblings("i").removeClass("fa-genderless");
				$(this).siblings("i").removeClass("fa-mars");
				$(this).siblings("i").removeClass("fa-venus-mars");
				$(this).siblings("i").addClass("fa-venus");					
			}else{
				if($(this).val()==2){
					$(this).siblings("i").removeClass("fa-genderless");
					$(this).siblings("i").removeClass("fa-venus");
					$(this).siblings("i").removeClass("fa-venus-mars");
					$(this).siblings("i").addClass("fa-mars");						
				}
			};				
		});	
		
		$("#btn_frmusuarios").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();			
			if(mode=="add"){
				var msg="Usuario agregado exitosamente.";
			}else{
				if(mode=="mod"){
					var msg="Usuario modificado exitosamente.";
				}else{
					var msg="Sin modo.";
				}				
			}
			formValidate("#frmusuarios");			
			if($("#frmusuarios").valid()){

				if($("#USR_Estado").is(":checked")){
					var USR_Estado = 1
				}else{
					var USR_Estado = 0
				};
				if($("#USR_Jefatura").is(":checked")){
					var USR_Jefatura = 1
				}else{
					var USR_Jefatura = 0
				};
				if(parseInt(width)==230 && parseInt(height)==120 || !imgchange) {
					$.ajax({
						type: 'POST',
						url: $("#frmusuarios").attr("action"),
						data: $("#frmusuarios").serialize() + "&USR_Estado=" + USR_Estado + "&USR_Jefatura=" + USR_Jefatura,
						dataType: "json",
						success: function(data) {						
							if(data.state=="200"){
								if(mode=="add"){
									$("#frmusuarios")[0].reset();

									var USR_IdNew = parseInt(data.data)									
									var data={USR_Id:USR_IdNew,mode:'mod'}
									
									$.ajax( {
										type:'POST',
										url: '/modal-usuarios',
										data: data,
										success: function ( data ) {
											param = data.split(bb)
											if(param[0]==200){							
												$("#usuariosModal").html(param[1]);
												$("#usuariosModal").modal("show");
											}else{
												swalWithBootstrapButtons.fire({
													icon:'error',								
													title: 'Ups!, no pude cargar el menú del proyecto1',					
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
								}							
								Toast.fire({
									icon: 'success',
									title: msg
								});
							}else{
								swalWithBootstrapButtons.fire({
									icon:'error',
									title:'Ingreso de usuario Fallido',
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
				}else{
					imgchange=false;
					swalWithBootstrapButtons.fire({
						icon:'error',								
						title: 'La imagen cargada no cumple con el tamaño requerido (230x120)',					
					});				
					
				}
			}
		})					
		
		function tableUsuarioLDAP(){			
			var tables = $.fn.dataTable.fnTables(true);
			$(tables).each(function () {
				$(this).dataTable().fnDestroy();
			});			
			UsuarioLDAPTable = $('#tbl-usuariosldap').DataTable()
		}
		
		$("#btn_frm10s3_1").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();

			formValidate("#frm10s3_1")
			if($("#frm10s3_1").valid()){
				$.ajax({
					type: 'POST',			
					url: $("#frm10s3_1").attr("action"),
					data: $("#frm10s3_1").serialize(),
					success: function(data) {					
						param=data.split(bb);						
						flujosusuarioTable.clear().draw();
						flujosusuarioTable.rows.add(jQuery.parseJSON(param[1])).draw();
						
						$(".badgeflu").html(flujosusuarioTable.data().count());
						loadUsuarioFlujos();
						if(param[0]=="200"){
							Toast.fire({
							  icon: 'success',
							  title: 'Flujo asociado agregado correctamente'
							});							
						}else{
							swalWithBootstrapButtons.fire({
								icon:'error',								
								title: 'Ups!, no pude grabar los datos del Flujo',					
								text:param[1]
							});
						}
					},
					error: function(XMLHttpRequest, textStatus, errorThrown){
						swalWithBootstrapButtons.fire({
							icon:'error',								
							title: 'Ups!, no pude cargar el menú del requerimiento'							
						});
					}
				});
			}
		})

		<%if(mode="mod") then %>
		$("#tbl-usrflu").on("click",".delflu",function(e){
			e.preventDefault();
			e.stopPropagation();
			var UVF_Id = $(this).children().data("uvf");			
			
			swalWithBootstrapButtons.fire({
			  title: '¿Estas seguro?',
			  text: "Esta acción eliminará el flujo selecciondo al usuario",
			  icon: 'question',
			  showCancelButton: true,
			  confirmButtonColor: '#3085d6',
			  cancelButtonColor: '#d33',
			  confirmButtonText: '<i class="fas fa-thumbs-up"></i> Si',
			  cancelButtonText: '<i class="fas fa-thumbs-down"></i> No'
			}).then((result) => {
			  if (result.value) {
			
					$.ajax({
						type: 'POST',			
						url: '/eliminar-flujo-usuario',
						data: {UVF_Id:UVF_Id,USR_Id:<%=USR_Id%>},
						success: function(data) {					
							param=data.split(bb);

							flujosusuarioTable.clear().draw();
							flujosusuarioTable.rows.add(jQuery.parseJSON(param[1])).draw();
							
							$(".badgeflu").html(flujosusuarioTable.data().count());
							loadUsuarioFlujos();
							if(param[0]=="200"){
								Toast.fire({
								  icon: 'success',
								  title: 'Flujo asociado eliminado correctamente'
								});							
							}else{
								swalWithBootstrapButtons.fire({
									icon:'error',								
									title: 'Ups!, no pude eliminar los datos del flujo',					
									text:param[1]
								});
							}
						},
						error: function(XMLHttpRequest, textStatus, errorThrown){
							swalWithBootstrapButtons.fire({
								icon:'error',								
								title: 'Ups!, no pude cargar el menú del requerimiento'							
							});
						}
					});
				}
			})
			
		})
		<%end if%>

		$("#usuariosModal").on("click",".usrSearch",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			ajax_icon_handling('load','Creando listado de usuarios LDAP','','');			
			$.ajax({
				type: 'POST',								
				url:'/lista-usuario-ldap',				
				success: function(data) {
					var param=data.split("/@/");			
					if(param[0]=="200"){				
						ajax_icon_handling(true,'Listado de usuarios LDAP creado.','',param[1]);
						$(document).off('focusin.bs.modal');
						$(".swal2-popup").css("width","60rem");						
						tableUsuarioLDAP();												
						$("#tbl-usuariosldap").on("click","tr.usrline",function(){
							$(this).find("td").each(function(e){
								if([e]<5){
									$($("#usuariosModal input")[e]).val(this.innerText)
									$($("#usuariosModal input")[e]).siblings("label").addClass("active")
								}else{
									var DEP_Descripcion = this.innerText;									
									$.ajax({
										type: 'POST',								
										url:'/lista-departamento-por-nombre',
										datatype:'json',
										data:{DEP_Descripcion:DEP_Descripcion},
										success: function(data) {
											var result = JSON.parse((data))
											$("#DEP_Id").val(result.DEP_Id);								
										}
									})
								}
								$("#USR_Rut").val($.Rut.formatear($("#USR_Rut").val(),true));
							});																
							Swal.close();
							changedata=true;
							$(document).off('focusin.bs.modal');
						})
					}else{
						ajax_icon_handling(false,'No fue posible crear el listado de usuarios LDAP.','','');
					}						
				},
				error: function(XMLHttpRequest, textStatus, errorThrown){				
					ajax_icon_handling(false,'No fue posible crear el listado de usuarios LDAP.','','');	
				},
				complete: function(){	
					/*Swal.fire({
						title: "successfully deleted",
						type: "success"
					})*/												
				}
			})

		});
		var width;
		var height;
		$("#inpX").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			$("#inp").click();
		})		
		function readFile() {
			var fakepath_1 = "C:" + ss + "fakepath" + ss
			var fakepath_2 = "C:" + bb + "fakepath" + bb
			var fakepath_3 = "C:" + s + "fakepath" + s
			var fakepath_4 = "C:" + b + "fakepath" + b	

			imgchange = true;
			if (this.files && this.files[0]) {				
				var FR = new FileReader();
				var img = new Image();				
				FR.addEventListener("load", function(e) {
					img.src= e.target.result
					img.onload = function() {
						//alert(this.width + 'x' + this.height);						
						height = this.height;
						width = this.width;
						if((parseInt(width)>230 && parseInt(height)>120) || (parseInt(width)<230 && parseInt(height)<120)){
							Toast.fire({
								icon: 'error',
								title: 'Imagen no tiene las dimenciones requeridas (230x120)'
							});
						}else{
							document.getElementById("img").src = e.target.result;
							document.getElementById("USR_Firma").value = e.target.result;							
							$("#inpX").val($("#inp").val().replace(fakepath_4,""));
							$(".delimg").show();
						}
					}															
				});													
				FR.readAsDataURL( this.files[0] );				
			}			
		}
		var imgchange = false;
		document.getElementById("inp").addEventListener("change", readFile);

		$(".delimg").click(function(e){			
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();

			document.getElementById("img").src = "";
			document.getElementById("USR_Firma").value = "";
			$("#inpX").val("");

			$(".delimg").hide();
		})
		<%if(mode="add") then%>
			$("#btnSalirModalUsuarios").click(function(e){
				e.preventDefault();
				e.stopImmediatePropagation();
				e.stopPropagation();			
				$("#usuariosModal").modal("hide")
			})<%
		else%>
			$("#btnSalirModalUsuarios").click(function(e){
				e.preventDefault();
				e.stopImmediatePropagation();
				e.stopPropagation();			
				$.ajax({
					type: 'POST',								
					url:'/busca-flujos-asignados-usuario',
					data:{USR_Id:<%=USR_Id%>},
					success: function(data) {
						var param=data.split("/@/");			
						if(param[0]=="200"){
							if(param[1]!=1){
								swalWithBootstrapButtons.fire({
									icon:'error',
									title:'Usuario sin flujo(s) asignado(s)',
									text:'Debes asugnarle un flujo al usuario antes de terminar su grabación'
								});
							}else{
								$("#usuariosModal").modal("hide")
							}
						}else{
							swalWithBootstrapButtons.fire({
								icon:'error',
								title:'Obtención de Flujos del usuario',
								text:'No se pudo obtener los flujos del usuario actual'
							});
						}
					}
				})			
			})<%
		end if%>		

		$("#USR_Estado").on('click',function(){
			if($("#USR_Estado").is(":checked")){
				//nothing
			}else{
				if($("#USR_Jefatura").is(":checked")){
					swalWithBootstrapButtons.fire({
						icon:'error',
						title: 'Debes reasignar la opción Jefatura a otro usuario antes de desactivar usuario Jefatura'
					});	
					$("#USR_Estado").attr('checked','checked');
					$("#USR_Estado")[0].checked=true;
				}
			}
		})
		/*var DEP_IdOri = $("#DEP_Id").val();
		$("#DEP_Id").on('change',function(e){
			e.preventDefault();
			if(DEP_IdOri!=$("#DEP_Id").val()){
				console.log('cambio', DEP_IdOri, $("#DEP_Id").val());
			}
		})*/
	})
</script>