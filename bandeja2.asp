<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="include\template\session.min.inc" -->
<%
	tpo=request("tpo")
	if(tpo="") then
		tpo=0
	end if
	titulo="Mis Requerimientos"
	gradiente="blue-gradient"
	DRE_Estado=1		'Pendiente
	color="white-text"
	if(tpo=2) then	
		DRE_Estado=14
		titulo="Requerimientos Archivados"
		gradiente="aqua-gradient"
		color="darkblue-text"
	end if
	if(tpo=3) then
		'DRE_Estado=14
		titulo="Requerimientos Enviados"
		gradiente="aqua-gradient"
		color="darkblue-text"
	end if
	if(tpo=4) then
		'DRE_Estado=14
		titulo="Requerimientos Finalizados"
		gradiente="aqua-gradient"
		color="darkblue-text"
	end if	

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description	   
		cnn.close
		response.Write("503/@/Error Conexión:" & ErrMsg)
		response.End() 			   
	end if			

	response.write("200/@/")
%>
<div class="row container-header">

</div>
<div class="row container-body mCustomScrollbar">
	<!--container-nav-->
	<div class="container-nav">
		<div class="header">
			<div class="content-nav"><%
				if(session("wk2_usrperfil")=1 or session("wk2_usrperfil")=5) then
					'Super ADM y Auditor
					sql="exec spFlujo_Listar 1"
				else
					'El resto de los perfiles
					'sql="exec spUsuarioVersionFlujo_Listar -1," & session("wk2_usrid")
					sql = "exec [spUsuarioFlujo_Listar] " & session("wk2_usrid")
				end if
				set rs = cnn.Execute(sql)
				if cnn.Errors.Count > 0 then 
				   ErrMsg = cnn.Errors(0).description	   
				   cnn.close
				   response.Write("503/@/Error Ejecucion:" & ErrMsg)
				   response.End() 			   
				end if
				cont=1
				prynuevos=0
				if rs.eof then
					if cont=1 then
						active="active"
					else
						active=""
					end if												
					cont=cont+1%>
					<a id="tab0-tab" href="#tab0" class="<%=active%> tab" data-flu="0"><i class="fas fa-sitemap"></i> Sin Flujos asignados</a><%
				end if
				do while not rs.eof					
					if cont=1 then
						active="active"
					else
						active=""
					end if								
					cont=cont+1%>
					<a id="tab<%=rs("FLU_Id")%>-tab" href="#tab<%=rs("FLU_Id")%>" class="<%=active%> tab" data-flu="<%=rs("FLU_Id")%>"><i class="fas fa-sitemap"></i> <%=UCAse(rs("FLU_Descripcion"))%><%
					if prynuevos>0 then%>
						<span class="badge right red"><%=prynuevos%></span><%
					end if%>
					</a><%
					rs.movenext
				loop%>
				<span class="yellow-bar"></span>				
			</div>				
		</div>	
		<!--tab-content-->
		<div class="tab-content"><%
			cont=0					
			rs.movefirst
			if rs.eof then%>
				<div id="tab0" data-flu="0">
					<!--wrapper-editor-->
					<div class="wrapper-editor">						
						<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">						
							<!-- Table with panel -->					
							<div class="card card-cascade narrower">
								<!--Card image-->
								<div class="view view-cascade gradient-card-header <%=gradiente%> narrower py-2 mx-4 mb-3 d-flex justify-content-between align-items-center">
									<div>									
									</div>
									<a href="" class="<%=color%> mx-3"><i class="fas fa-book"></i> Sin requerimientos asignados</a>
									<div>
									</div>
								</div>
								<!--/Card image-->
								<div class="px-4">
									<div class="table-wrapper col-sm-12 mCustomScrollbar" id="container-table-1">
										<!--Table-->										
										<table id="tblreq-0" class="ts table table-striped table-bordered dataTable table-sm" cellspacing="0" data-id="0" style="width:99%">
											<thead>
												<tr>													
													<th>Id</th>
													<th>Ver.</th>
													<th>Paso</th>
													<th>Descripción Versión Requerimiento</th>													
													<th>Req.</th>
													<th>Req.Identificador</th>
													<th>Requerimiento</th>													
													<th>Id.Estado Requerimiento</th>
													<th>Subestado</th>													
													<th>Id Versión Flujo Formulario</th>
													<th>V.FLujo</th>
													<th>Id Flujo</th>													
													<th>Flujo</th>												
													<th>Año</th>
													<th>V.Form.</th>
													<th>Id Formulario</th>
													<th>Descripción Formulario</th>													
													<th>Id.Creador</th>													
													<th>Creador</th>
													<th>Id Perfil Creadorr</th>
													<th>Descripción Perfil Creador</th>													
													<th>Id Editor</th>
													<th>Editor</th>
													<th>Id.Perfil Editor</th>
													<th>Descripcion Perfil Editor</th>
													<th>Id Dependencia Actual</th>
													<th>Dep. Editor</th>
													<th>Id Dependencia Padre Actual</th>
													<th>Id Dependencia Origen</th>
													<th>Dep. Creación</th>
													<th>Id Dependencia Padre Origen</th>													
													<th>Estado Registro</th>
													<th>Sub Estado del registro</th>
													<th>Usuario Creador Registro</th>
													<th>Última Actualización</th>
													<th>Acción realizada</th>
													<th>Creación Requerimiento</th>
													<th>Estado</th>
													
													<th>Dias</th>
													<th>Acciones</th>
													<th>Atraso</th>
												</tr>
											</thead>
											<tbody>
											</tbody>
										</table>
									</div>
								</div>
							</div>
							<!-- Table with panel -->		
						</div>	  
					</div>
					<!--wrapper-editor-->
				</div><%
			end if				
			do while not rs.eof%>
				<div id="tab<%=rs("FLU_Id")%>" data-flu="<%=rs("FLU_Id")%>">
					<!--wrapper-editor-->
					<div class="wrapper-editor">						
						<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">						
							<!-- Table with panel -->					
							<div class="card card-cascade narrower">
								<!--Card image-->
								<div class="view view-cascade gradient-card-header <%=gradiente%> narrower py-2 mx-4 mb-3 d-flex justify-content-between align-items-center">
									<div><%
										if (session("wk2_usrperfil")<>5 and tpo=0) then%>
											<button class="btn btn-success btn-rounded btn-sm waves-effect buttonAdd" title="Crear un nuevo requerimiento" type="button" data-url="" data-toggle="tooltip" data-id="<%=rs("FLU_Id")%>">Agregar<i class="fas fa-plus ml-1"></i></button><%
										end if%>										
									</div>
									<a href="" class="<%=color%> mx-3"><i class="fas fa-book"></i> <%=titulo%></a>
									<div><%
										if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2 or session("wk2_usrjefatura")=1) and (rs("FLU_Id")=4) and tpo=0 then	'Solo para el flujo de pagos por ahora%>
											<button class="btn btn-primary btn-rounded buttonVisado btn-sm waves-effect" data-toggle="tooltip" title="Visar requerimientos" data-flu="<%=rs("FLU_Id")%>">Visar<i class="fas fa-clipboard-check ml-1"></i></button><%
										end if
										if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2) and tpo=0 then%>
											<button class="btn btn-danger btn-rounded buttonArchive btn-sm waves-effect" data-toggle="tooltip" title="Archivar requerimiento" data-flu="<%=rs("FLU_Id")%>">Archivar<i class="fas fa-archive ml-1"></i></button><%
										else
											if (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2) and tpo=2 then%>
												<button class="btn btn-primary btn-rounded buttonUnArchive btn-sm waves-effect" data-toggle="tooltip" title="Desarchivar requerimiento" data-flu="<%=rs("FLU_Id")%>">Desarchivar<i class="fas fa-box-open ml-1"></i></button><%
											end if
										end if%>
										<button class="btn btn-secondary btn-rounded buttonExport btn-sm waves-effect" data-toggle="tooltip" title="Exportar datos de la tabla" data-id="tblreq-<%=rs("FLU_Id")%>" data-tpo="<%=tpo%>" data-flu="<%=rs("FLU_Id")%>">Exportar<i class="fas fa-download ml-1"></i></button>
									</div>
								</div>
								<!--/Card image-->
								<div class="px-4">
									<div class="table-wrapper col-sm-12 mCustomScrollbar" id="container-table-bandeja">
										<!--Table-->										
										<table id="tblreq-<%=rs("FLU_Id")%>" class="ts table table-striped table-bordered dataTable table-sm" cellspacing="0" data-id="<%=rs("FLU_Id")%>" style="width:99%">
											<thead>
												<tr>													
													<th>Id</th>
													<th>Ver.</th>
													<th>Paso</th> 
													<th>Descripción Versión Requerimiento</th>													
													<th>Req.</th>
													<th>Req.Identificador</th>
													<th>Requerimiento</th>													
													<th>Id.Estado Requerimiento</th>
													<th>Subestado</th>													
													<th>Id Versión Flujo Formulario</th>
													<th>V.FLujo</th>
													<th>Id Flujo</th>													
													<th>Flujo</th>												
													<th>Año</th>
													<th>V.Form.</th>
													<th>Id Formulario</th>
													<th>Descripción Formulario</th>													
													<th>Id.Creador</th>													
													<th>Creador</th>
													<th>Id Perfil Creadorr</th>
													<th>Descripción Perfil Creador</th>													
													<th>Id Editor</th>
													<th>Editor</th>
													<th>Id.Perfil Editor</th>
													<th>Descripcion Perfil Editor</th>
													<th>Id Dependencia Actual</th>
													<th>Dep. Editor</th>
													<th>Id Dependencia Padre Actual</th>
													<th>Id Dependencia Origen</th>
													<th>Dep. Creación</th>
													<th>Id Dependencia Padre Origen</th>													
													<th>Estado Registro</th>
													<th>Sub Estado del registro</th>
													<th>Usuario Creador Registro</th>
													<th>Última Actualización</th>
													<th>Acción realizada</th>
													<th>Creación Requerimiento</th>
													<th>Estado</th>
													
													<th>Dias</th>
													<th>Acciones</th>
													<th>Atraso</th>
												</tr>
											</thead>
											<tbody>
											</tbody>
										</table>
									</div>
								</div>
							</div>
							<!-- Table with panel -->		
						</div>	  
					</div>
					<!--wrapper-editor-->

				</div><%
				rs.movenext
			loop%>
		</div>
		<!--tab-content-->
	</div>
	<!--container-nav-->	
</div>
<!--container-body-->

<%if session("wk2_usrperfil")=1 or (session("wk2_usrperfil")<>5 and tpo=0) then%>
<!-- Formulario para crear un nuevo Requerimiento -->
<div class="modal fade in modalAdd" id="modalAdd-Requerimiento" tabindex="-1" role="dialog" aria-labelledby="modalAdd-RequerimientoLabel" aria-hidden="true" data-id="10">
	<div class="modal-dialog cascading-modal narrower modal-lg" role="document">  		
    	<div class="modal-content">		
      		<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
        		<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-edit"></i> Selecciona versión del Flujo</div>				
      		</div>
			<form role="form" action="" method="POST" name="frmseleclinea-10" id="frmseleclinea-10" class="needs-validation">
				<div class="modal-body">
					<div class="row">
						<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
							<div class="md-form input-with-post-icon">
								<div class="error-message">									
									<div class="select" id="creaLinea-10">
										
									</div>
								</div>
							</div>
						</div>								
					</div>
				</div>				
		  		<div class="modal-footer">
					<button type="button" class="btn btn-secondary btn-md waves-effect" data-dismiss="modal"><i class="fas fa-times"></i> Cerrar</button>
					<button type="button" class="btn btn-primary btn-md waves-effect" id="btn_crealinea-10" name="btn_crealinea-10"><i class="fas fa-plus"></i> Crear</button>
				</div>
			</form>
		</div>
	</div>
</div>
<!-- Formulario para crear un nuevo Requerimiento -->
<%End if%>

<!-- Formulario para cambio de editor -->
<div class="modal fade in" id="cambioEditor" tabindex="-1" role="dialog" aria-labelledby="cambioEditorLabel" aria-hidden="true">
	<div class="modal-dialog cascading-modal narrower modal-lg" role="document">  		
    	<div class="modal-content">		
      		<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
        		<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-user"></i> Selecciona un nuevo editor</div>				
      		</div>
			<form role="form" action="" method="POST" name="frmbtn_cmbeditor" id="frmbtn_cmbeditor" class="needs-validation">
				<div class="modal-body">
					<div class="row">
						<div class="col-sm-12 col-md-12 col-lg-12">
							<div class="md-form input-with-post-icon">
								<div class="error-message">								
									<i class="fas fa-building input-prefix"></i>															
									<input type="text" class="form-control" readonly="" id="DepartamentoActual">
									<input type="hidden" id="DEP_IdActual">
									<span class="select-bar"></span>
									<label for="DepartamentoActual" class="select-label active">Departamento Actual</label>
								</div>
							</div>
						</div>
					</div>
					<div class="row">
						<div class="col-sm-12 col-md-12 col-lg-12">
							<div class="md-form input-with-post-icon">
								<div class="error-message">								
									<i class="fas fa-user input-prefix"></i>															
									<input type="text" class="form-control" readonly="" id="EditorActual">
									<input type="hidden" id="USR_OldEditor">
									<span class="select-bar"></span>
									<label for="EditorActual" class="select-label active">Editor Actual</label>
								</div>
							</div>
						</div>
					</div>
					<div class="row">
						<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
							<div class="md-form input-with-post-icon">
								<div class="error-message">									
									<div class="select" id="USR_NewEditor">
									</div>
								</div>
							</div>
						</div>
					</div>
					<!--<div class="row">
						<div class="col-sm-12 col-md-12 col-lg-12">
							<div class="md-form input-with-post-icon">
								<div class="error-message">								
									<i class="fas fa-indent input-prefix"></i>
									<textarea class="md-textarea form-control" rows="3" id="DRE_ObservacionesEditor" name="DRE_ObservacionesEditor"></textarea>
									<span class="select-bar"></span>
									<label for="dta-ComJustificacion" class="select-label active">Observaciones</label>
								</div>
							</div>
						</div>
					</div>-->				
				</div>				
		  		<div class="modal-footer">
					<button type="button" class="btn btn-secondary btn-md waves-effect" data-dismiss="modal"><i class="fas fa-times"></i> Cerrar</button>
					<button type="button" class="btn btn-primary btn-md waves-effect" id="btn_cmbeditor" name="btn_cmbeditor"><i class="fas fa-plus"></i> Cambiar</button>
				</div>
				<input type="hidden" id="VRE_IdSelected" name="VRE_IdSelected">
				<input type="hidden" id="DRE_IdActual" name="DRE_IdActual">
				<input type="hidden" id="DRE_ObservacionesActual" name="DRE_ObservacionesActual">
				<input type="hidden" id="FLU_Id" name="FLU_Id">
			</form>
		</div>
	</div>
</div>
<!-- Formulario para cambio de editor -->

<!-- Formulario para cambio de nombre del requerimiento -->
<div class="modal fade in" id="cambioNombre" tabindex="-1" role="dialog" aria-labelledby="cambioNombreLabel" aria-hidden="true">
	<div class="modal-dialog cascading-modal narrower modal-lg" role="document">  		
    	<div class="modal-content">		
      		<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
        		<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-edit"></i> Escribe un nuevo nombre del Requerimiento <span id="REQ_IdActual"></span></div>				
      		</div>
			<form role="form" action="" method="POST" name="frm_cmbnombre" id="frm_cmbnombre" class="needs-validation">
				<div class="modal-body">
					<div class="row">
						<div class="col-sm-12 col-md-12 col-lg-12">
							<div class="md-form input-with-post-icon">
								<div class="error-message">								
									<i class="fas fa-building input-prefix"></i>															
									<input type="text" class="form-control" readonly="" id="NombreActual" name="NombreActual">									
									<span class="select-bar"></span>
									<label for="NombreActual" class="select-label active">Nombre del Requerimiento Actual</label>
								</div>
							</div>
						</div>
					</div>
					<div class="row">
						<div class="col-sm-12 col-md-12 col-lg-12">
							<div class="md-form input-with-post-icon">
								<div class="error-message">								
									<i class="fas fa-user input-prefix"></i>															
									<input type="text" class="form-control" id="NuevoNombre" name="NuevoNombre" required data-msg="Debes ingresar un nuevo nombre de requerimiento">									
									<span class="select-bar"></span>
									<label for="NuevoNombre" class="select-label">Nuevo Nombre del Requerimiento</label>
								</div>
							</div>
						</div>
					</div>							
				</div>				
		  		<div class="modal-footer">
					<button type="button" class="btn btn-secondary btn-md waves-effect" data-dismiss="modal"><i class="fas fa-times"></i> Cerrar</button>
					<button type="button" class="btn btn-primary btn-md waves-effect" id="btn_cmbnombre" name="btn_cmbnombre"><i class="fas fa-plus"></i> Cambiar</button>
				</div>				
				<input type="hidden" id="REQ_IdCmbNombre" name="REQ_IdCmbNombre">				
				<input type="hidden" id="FLU_IdActual" name="FLU_IdActual">
				<input type="hidden" id="DRE_IdActualNom" name="DRE_IdActualNom">				
			</form>
		</div>
	</div>
</div>
<!-- Formulario para cambio de editor -->

<script>
	//bandeja
	$(function () {
		$('[data-toggle="tooltip"]').tooltip({
			trigger : 'hover'
		})
		$('[data-toggle="tooltip"]').on('click', function () {
			$(this).tooltip('hide')
		})		
	});
	var FLU_Id=0;
	$(document).ready(function() {
		var bb = String.fromCharCode(92) + String.fromCharCode(92);
		var ss = String.fromCharCode(47) + String.fromCharCode(47);	
		var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);
		var requerimientosTable = {};
		var tables = $.fn.dataTable.fnTables(true);			
		$(tables).each(function () {
			$(this).dataTable().fnDestroy();			
		});		

		$(".mCustomScrollbar").mCustomScrollbar({
			theme:scrollTheme,
			advanced:{				
				autoExpandHorizontalScroll:true,
				updateOnContentResize:true,
				autoExpandVerticalScroll:true,
				scrollbarPosition:"outside"			
			},
			//axis:"yx"
		});	
		
		$(".content-nav").tabsmaterialize({},function(){			
			var FLU_Id = $(this.toString()).data("flu");
			var tabId = this.toString();			
			if ( ! $.fn.DataTable.isDataTable( '#tblreq-' + FLU_Id ) ) {
				tableRequerimientos(FLU_Id, tabId)					
			}else{
				requerimientosTable[FLU_Id].ajax.reload();
			}			
		});				
		
		//Observaciones
		const obsmsg = (formid,_callback) => {
			var resp=false,respTXT='Error en la ejecución';
			//Ingresar Observación
			//console.log("observacion")
			swalWithBootstrapButtons.fire({
				target: document.getElementById(formid),
				icon:'info',
				title: 'Ingresa una Observación',
				input: 'textarea',
				inputValue: "",
				showCancelButton: true,
				confirmButtonText: '<i class="fas fa-check"></i> Agregar Observacion',
				cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar',
				inputValidator: (value) => {
					if (!value) {
						return 'Debes escribir una observación';
					}
				}
			}).then((result) => {
				if(result.value){	
					respTXT = result.value
					resp = true;
				}else{
					respTXT = 'Proceso cancelado'
					resp = false;
				}
				return _callback(null, {
					error: resp,
					value: respTXT
				});
			})			
		}

		const obs = (ESR_Id, _callback) => {
			var resp=false,respTXT='Error en la ejecución';
			$.ajax( {				
				type:'POST',					
				url: '/observaciones',
				data: {ESR_Id:ESR_Id},				
				success: function ( data ) {
					param = data.split(sas);
					if(param[0]==200){
						if(param[1]==1){							
							resp = true;
							respTXT = 'Obligatorio'
						}else{
							resp = false;
							respTXT = 'Opcional'
						}
					}else{
						resp = false;
						respTXT = 'Condición no encontrada'
					}
				},
				complete: function(){
					return _callback(null, {
						error: resp,
						value: respTXT
					});
				}
			})						
		}
		//Observaciones
		
		//Requerimientos		
		function tableRequerimientos(FLU_Id, tabId){
			requerimientosTable[FLU_Id] = $('#tblreq-' + FLU_Id).DataTable({
				lengthMenu: [ 10,15,20 ],
				stateSave: true,
				processing: true,
        		serverSide: true,
				ajax:{
					url:"/reqphp",
					type:"POST",
					data:{tpo:<%=tpo%>,FLU_Id:FLU_Id},
					dataSrc:function(json){
                        console.log(json.data)
						return json.data;					
					}
				},	
				columnDefs: [{
						"targets": [1,3,5,7,9,11,12,15,16,17,19,20,21,23,24,25,27,28,30,31,32,33,35,40],
						"visible": false,
						"searchable": false,
					},{
						"targets": [0,2,3,6,9,12,15,18],
						"width":"20px"					
					},{
						"targets": [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40],
						"orderable": false
					}
				],
				//scrollX: true,
				autoWidth: false,				
				//order:[[1,"desc"]],
				fnRowCallback: function( nRow, aData, iDisplayIndex, iDisplayIndexFull ) {					
					var atraso = parseInt($(aData)[40]);				
					if(atraso==2){
						$(nRow).find("td").eq(15).css("background", "rgba(217, 83, 79, .3)");
					}else{
						if(atraso==1){
							if($(nRow).find("td").eq(15).html()!=""){
								$(nRow).find("td").eq(15).css("background", "rgba(240, 173, 78, .3)");
							}
						}else{
							if(atraso==0){
								$(nRow).find("td").eq(15).css("background", "rgba(92, 184, 92, .3)");									
							}else{	
								$(nRow).find("td").eq(15).css("background", "rgba(91, 192, 222, .3)");
							}	
						}
					}										
					$("td:not(:last)",nRow).click(function(e){
						e.preventDefault();
						e.stopImmediatePropagation();
						e.stopPropagation();						
						//var FLD_Id=$(this).find("td")[0].innerText;
						var DRE_Id=$($(this).parent()).find("td")[0].innerText;
						var VFL_Id=$($(this).parent()).find("td")[6].innerText;
						var VFO_Id=$($(this).parent()).find("td")[8].innerText;
						//console.log($($(this).parent()).find("td")[1].innerText)
						if(VFO_Id!=0){
							var url='/bandeja-de-entrada/modificar';
							var accion = 'modificar'
						}else{
							var url='/bandeja-de-entrada/agregar';
							var accion = 'agregar'
						}
						
						$.ajax( {
							type:'POST',					
							url: url,
							data: {key2:DRE_Id,tabId:tabId},
							success: function ( data ) {
								param = data.split(sas)
								if(param[0]==200){						
									$("#contenbody").html(param[1]);
									var href = window.location.href;
									var newhref = href.substr(href.indexOf("/home")+6,href.length);
									var href_split = newhref.split("/")

									href_split[1]=accion;
									href_split[2]=VFL_Id;
									href_split[3]=DRE_Id;									
									var newurl="/home"
									$.each(href_split, function(i,e){
										newurl=newurl + "/" + e
									});
									window.history.replaceState(null, "", newurl);
									cargabreadcrumb("/breadcrumbs",{tabId:tabId});
								}
							},
							error: function(XMLHttpRequest, textStatus, errorThrown){

							}
						});	
					});
					
				}
			});			
		}				
		
		$(".buttonExport").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();			
			var idTable = $(this).data("id");
			var FLU_Id = $(this).data("flu");			
			var Tipo = $(this).data("tpo");

			wrk_reportes("/wrk-requerimientos",idTable, Tipo, FLU_Id, <%=session("wk2_usrid")%>,'<%=session("wk2_usrtoken")%>');			
		});	
		
		$(".buttonArchive").click(function(e){
			e.preventDefault();
			e.stopPropagation();
			var FLU_Id = $(this).data("flu")			
			//Observaciones					
			obs(14,(err, result)=>{
				//console.log(result)
				if(result.error){
					//console.log("si")
					obsmsg('',(err, result) =>{								
						//console.log("si2")
						if(result.error){
							ajax_icon_handling('load','Generando listado de Requerimientos...','','');
							$.ajax({
								type: 'POST',								
								url:'/listar-requerimientos',
								data:{FLU_Id:FLU_Id},
								success: function(data) {
									var param=data.split(sas);
									var jus=result.value;
									if(param[0]=="200"){				
										ajax_icon_handling(true,'Listado de Requerimientos creado.','',param[1]);
										$(".swal2-popup").css("width","60rem");
										var listRequerimientos=$("#tbl-listrequerimientos").DataTable({
											columnDefs: [ {
												targets: 0,
												data: null,
												defaultContent: '',
												orderable: false,
												className: 'select-checkbox',
												width:"50px"
											} ],
											select: {
												style:    'multi',
												selector: 'td:first-child'

											},
											order: [[ 1, 'desc' ]],
											lengthMenu: [ 5,10,20 ]								
										});

										$("#btn_cancelapry").click(function(e){
											e.preventDefault();
											e.stopImmediatePropagation();
											e.stopPropagation();

											Swal.close();
										});
										$("#btn_archivapry").click(function(e){
											e.preventDefault();
											e.stopImmediatePropagation();
											e.stopPropagation();

											if(listRequerimientos.rows(".selected").data().length>0){									
												ajax_icon_handling('load','Archivando Requerimiento(s)...','','');
												listRequerimientos.rows(".selected").data().each(function(i){										
													$.ajax({
														type: 'POST',								
														url:'/archivar-requerimiento',
														data:{DRE_Id:i[1],DRE_Observacion:jus},
														success: function(data) {
															var param=data.split(sas);
															if(param[0]==200){
																ajax_icon_handling(true,'Requerimiento(s) Archivado(s).','','');
																var pryarc = setInterval(function(){													
																	Swal.close();
																	clearInterval(pryarc)
																},1300);
																requerimientosTable[FLU_Id].ajax.reload();
															}else{
																Swal.close();
																clearInterval(pryarc)
																swalWithBootstrapButtons.fire({
																	icon:'error',								
																	title: 'ERROR',
																	text:'No fue podible de realizar el archivado del(los) Requerimiento(s)'
																});														
															}
														}											
													});										
												});
																						
											}else{									
												shake($('#btn_archivapry'));									
											}								

										});
									}else{
										ajax_icon_handling(false,'No fue posible crear el listado de Requerimientos.','','');
									}						
								},
								error: function(XMLHttpRequest, textStatus, errorThrown){				
									ajax_icon_handling(false,'No fue posible crear el listado de Requerimientos.','','');	
								},
								complete: function(){																		
								}
							})
						}
					})
					console.log(result)
				}else{
					ajax_icon_handling('load','Generando listado de Requerimientos...','','');
					$.ajax({
						type: 'POST',								
						url:'/listar-requerimientos',
						data:{FLU_Id:FLU_Id},
						success: function(data) {
							var param=data.split(sas);
							var jus=result.value;
							if(param[0]=="200"){				
								ajax_icon_handling(true,'Listado de Requerimientos creado.','',param[1]);
								$(".swal2-popup").css("width","60rem");
								var listRequerimientos=$("#tbl-listrequerimientos").DataTable({
									columnDefs: [ {
										targets: 0,
										data: null,
										defaultContent: '',
										orderable: false,
										className: 'select-checkbox',
										width:"50px"
									} ],
									select: {
										style:    'multi',
										selector: 'td:first-child'

									},
									order: [[ 1, 'desc' ]],
									lengthMenu: [ 5,10,20 ]								
								});

								$("#btn_cancelapry").click(function(e){
									e.preventDefault();
									e.stopImmediatePropagation();
									e.stopPropagation();

									Swal.close();
								});
								$("#btn_archivapry").click(function(e){
									e.preventDefault();
									e.stopImmediatePropagation();
									e.stopPropagation();

									if(listRequerimientos.rows(".selected").data().length>0){									
										ajax_icon_handling('load','Archivando Requerimiento(s)...','','');
										listRequerimientos.rows(".selected").data().each(function(i){										
											$.ajax({
												type: 'POST',								
												url:'/archivar-requerimiento',
												data:{DRE_Id:i[1]},
												success: function(data) {
													var param=data.split(sas);
													if(param[0]==200){
														ajax_icon_handling(true,'Requerimiento(s) Archivado(s).','','');
														var pryarc = setInterval(function(){													
															Swal.close();
															clearInterval(pryarc)
														},1300);
														requerimientosTable[FLU_Id].ajax.reload();
													}else{
														Swal.close();
														clearInterval(pryarc)
														swalWithBootstrapButtons.fire({
															icon:'error',								
															title: 'ERROR',
															text:'No fue podible de realizar el archivado del(los) Requerimiento(s)'
														});														
													}
												}											
											});										
										});
																				
									}else{									
										shake($('#btn_archivapry'));									
									}								

								});
							}else{
								ajax_icon_handling(false,'No fue posible crear el listado de Requerimientos.','','');
							}						
						},
						error: function(XMLHttpRequest, textStatus, errorThrown){				
							ajax_icon_handling(false,'No fue posible crear el listado de Requerimientos.','','');	
						},
						complete: function(){																		
						}
					})
				}
			})										
		});		
		
		$(".buttonUnArchive").click(function(e){
			e.preventDefault();
			e.stopPropagation();
			var FLU_Id = $(this).data("flu");			
			obs(18,(err, result)=>{						
				if(result.error){
					obsmsg('',(err, result) =>{								
						if(result.error){
							ajax_icon_handling('load','Generando listado de Requerimientos...','','');
							$.ajax({
								type: 'POST',								
								url:'/listar-requerimientos-archivados',
								data:{FLU_Id:FLU_Id},
								success: function(data) {
									var param=data.split(sas);
									var jus=result.value;
									if(param[0]=="200"){				
										ajax_icon_handling(true,'Listado de Requerimientos creado.','',param[1]);
										$(".swal2-popup").css("width","60rem");
										var listRequerimientos=$("#tbl-listrequerimientos").DataTable({
											columnDefs: [ {
												targets: 0,
												data: null,
												defaultContent: '',
												orderable: false,
												className: 'select-checkbox',
												width:"50px"
											} ],
											select: {
												/*style:    'os',*/
												style:    'multi',
												selector: 'td:first-child'
											},
											order: [[ 1, 'desc' ]],
											lengthMenu: [ 5,10,20 ]								
										});

										$("#btn_cancelapry").click(function(e){
											e.preventDefault();
											e.stopImmediatePropagation();
											e.stopPropagation();

											Swal.close();
										});
										$("#btn_desarchivapry").click(function(e){
											e.preventDefault();
											e.stopImmediatePropagation();
											e.stopPropagation();

											if(listRequerimientos.rows(".selected").data().length>0){									
												ajax_icon_handling('load','Desarchivando Requerimiento(s)...','','');
												listRequerimientos.rows(".selected").data().each(function(i){										
													$.ajax({
														type: 'POST',								
														url:'/desarchivar-requerimiento',
														data:{DRE_Id:i[1],DRE_Observacion:jus},
														success: function(data) {
															var param=data.split(sas);
															if(param[0]==200){
																ajax_icon_handling(true,'Requerimiento(s) desarchivado(s).','','');
																var pryarc = setInterval(function(){													
																	Swal.close();
																	clearInterval(pryarc)																				
																},1300);
																var url="/bandeja-de-archivados";
																cargacomponente(url,"");
																window.history.replaceState(null, "", "/home"+url);	
																cargabreadcrumb("/breadcrumbs","");
															}else{
																Swal.close();
																clearInterval(pryarc)
																swalWithBootstrapButtons.fire({
																	icon:'error',								
																	title: 'ERROR',
																	text:'No fue podible de realizar el desarchivado del(los) Requerimiento(s)'
																});
															}
														}											
													});
												})
												
											}else{									
												shake($('#btn_archivapry'));									
											}								

										});
									}else{
										ajax_icon_handling(false,'No fue posible crear el listado de Requerimientos.','','');
									}						
								},
								error: function(XMLHttpRequest, textStatus, errorThrown){				
									ajax_icon_handling(false,'No fue posible crear el listado de Requerimientos.','','');	
								},
								complete: function(){																		
								}
							})
						}
					})
				}else{
					ajax_icon_handling('load','Generando listado de Requerimientos...','','');
					$.ajax({
						type: 'POST',								
						url:'/listar-requerimientos-archivados',
						data:{FLU_Id:FLU_Id},
						success: function(data) {
							var param=data.split(sas);
							var jus=result.value;
							if(param[0]=="200"){				
								ajax_icon_handling(true,'Listado de Requerimientos creado.','',param[1]);
								$(".swal2-popup").css("width","60rem");
								var listRequerimientos=$("#tbl-listrequerimientos").DataTable({
									columnDefs: [ {
										targets: 0,
										data: null,
										defaultContent: '',
										orderable: false,
										className: 'select-checkbox',
										width:"50px"
									} ],
									select: {
										/*style:    'os',*/
										style:    'multi',
										selector: 'td:first-child'
									},
									order: [[ 1, 'desc' ]],
									lengthMenu: [ 5,10,20 ]								
								});

								$("#btn_cancelapry").click(function(e){
									e.preventDefault();
									e.stopImmediatePropagation();
									e.stopPropagation();

									Swal.close();
								});
								$("#btn_desarchivapry").click(function(e){
									e.preventDefault();
									e.stopImmediatePropagation();
									e.stopPropagation();

									if(listRequerimientos.rows(".selected").data().length>0){									
										ajax_icon_handling('load','Desarchivando Requerimiento(s)...','','');
										listRequerimientos.rows(".selected").data().each(function(i){										
											$.ajax({
												type: 'POST',								
												url:'/desarchivar-requerimiento',
												data:{DRE_Id:i[1]},
												success: function(data) {
													var param=data.split(sas);
													if(param[0]==200){
														ajax_icon_handling(true,'Requerimiento(s) desarchivado(s).','','');
														var pryarc = setInterval(function(){													
															Swal.close();
															clearInterval(pryarc)																				
														},1300);
														var url="/bandeja-de-archivados";
														cargacomponente(url,"");
														window.history.replaceState(null, "", "/home"+url);	
														cargabreadcrumb("/breadcrumbs","");
													}else{
														Swal.close();
														clearInterval(pryarc)
														swalWithBootstrapButtons.fire({
															icon:'error',								
															title: 'ERROR',
															text:'No fue podible de realizar el desarchivado del(los) Requerimiento(s)'
														});
													}
												}											
											});
										})
										
									}else{									
										shake($('#btn_archivapry'));									
									}								

								});
							}else{
								ajax_icon_handling(false,'No fue posible crear el listado de Requerimientos.','','');
							}						
						},
						error: function(XMLHttpRequest, textStatus, errorThrown){				
							ajax_icon_handling(false,'No fue posible crear el listado de Requerimientos.','','');	
						},
						complete: function(){																		
						}
					})
				}
			})			
		});

		function tableVersionesFlujo(){
			if ( ! $.fn.DataTable.isDataTable( '#tbl-versionflujos' ) ) {
				VersionesFlujosTable = $('#tbl-versionflujos').DataTable();
			}else{
				VersionesFlujosTable.ajax.reload();
			}
		}
		
		<%if(session("wk2_usrperfil")<>5) then%>
			$(".buttonAdd").on("click",function(e){
				e.preventDefault();
				e.stopImmediatePropagation();
				e.stopPropagation();
				var FLU_Id = $(this).data("id")			

				<%if(session("wk2_usrperfil")=1) then%>
					ajax_icon_handling('load','Creando listado de versiones de Flujos','','');			
					$.ajax({
						type: 'POST',								
						url:'/lista-versiones-flujos',
						data:{FLU_Id:FLU_Id},
						success: function(data) {
							var param=data.split(sas);
							if(param[0]=="200"){
								ajax_icon_handling(true,'Listado de versiones de Flujos creado.','',param[1]);
								$(document).off('focusin.bs.modal');
								$(".swal2-popup").css("width","60rem");
								tableVersionesFlujo();												
								$("#tbl-versionflujos").on("click","tr.verfluline",function(){
									$(this).find("td").each(function(e){								
										if([e]==0){
											VFL_Id=this.innerText;
										}
									});								
									Swal.close();
									changedata=true;
									$(document).off('focusin.bs.modal');

									//llamar a desglose requerimiento
									if(VFL_Id!=0){
										var objeto={key1:VFL_Id, modo:1};
										var url='/bandeja-de-entrada/agregar';				
										cargacomponente(url,objeto);
										window.history.replaceState(null, "", "/home"+url+"/"+VFL_Id);
										cargabreadcrumb("/breadcrumbs","");
									}
								})
							}else{
								ajax_icon_handling(false,'No fue posible crear el listado de versiones de Flujos.','','');
							}						
						},
						error: function(XMLHttpRequest, textStatus, errorThrown){				
							ajax_icon_handling(false,'No fue posible crear el listado de versiones de Flujos.','','');	
						},
						complete: function(){															
						}
					})
				<%else%>
					var objeto={key3:FLU_Id, modo:1};
					var url='/bandeja-de-entrada/agregar';					
					cargacomponente(url,objeto);					
					window.history.replaceState(null, "", "/home"+url+"/");
					cargabreadcrumb("/breadcrumbs","");
				<%end if%>
			});
		<%end if%>

		$("table").on("click",".dowadj",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
						
			var VFO_Id = $(this).data("vfo");
			var DRE_Id = $(this).data("dre");
		
			ajax_icon_handling('load','Buscando adjuntos','','');
			$.ajax({
				type: 'POST',								
				url:'/listar-adjuntos',				
				data:{VFO_Id:VFO_Id,DRE_Id,DRE_Id},
				success: function(data) {
					var param=data.split(bb);			
					if(param[0]=="200"){				
						ajax_icon_handling(true,'Listado de adjuntos creado.','',param[1]);
						$(".swal2-popup").css("width","60rem");
						loadtables("#tbl-adjuntos");
						$(".arcreq").click(function(){
							var INF_Arc = $(this).data("file");							
							var data = {VFO_Id:VFO_Id,DRE_Id,DRE_Id,INF_Arc:INF_Arc};
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
					}else{
						ajax_icon_handling(false,'No fue posible crear el listado de adjuntos.','','');
					}						
				},
				error: function(XMLHttpRequest, textStatus, errorThrown){				
					ajax_icon_handling(false,'No fue posible crear el listado de verificadores.','','');	
				},
				complete: function(){																		
				}
			})
		})

		$("table").on("click",".verobs",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			
			var VRE_Id = $(this).data("vre");
			ajax_icon_handling('load','Buscando observaciones','','');			
			$.ajax( {				
				type:'POST',					
				url: '/observaciones-requerimiento',
				data: {VRE_Id:VRE_Id},				
				success: function ( data ) {
					param = data.split(sas);
					if(param[0]==200){						
						ajax_icon_handling(true,'Listado de observaciones creado.','',param[1]);
						$(".swal2-popup").css("width","60rem");
						loadtables("#tbl-observaciones");
					}else{
						ajax_icon_handling(false,'No fue posible crear el listado de observaciones.','','');
					}
				}
			})			
		})

		$("table").on("click",".cmbedit",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();

			var VRE_Id = $(this).data("vre");
			var VFL_Id = $(this).data("vfl");
			var DEP_Id = $(this).data("dep");
			var USR_Id = $(this).data("usr");
			var DRE_Id = $(this).data("dre");
			var FLU_Id = $(this).data("flu");

			$("#cambioEditor").modal("show");
			$("#VRE_IdSelected").val(VRE_Id);
			$("#DEP_IdActual").val(DEP_Id);
			$("#DRE_IdActual").val(DRE_Id);
			$("#DRE_ObservacionesEditor").val("");
			$("#FLU_Id").val(FLU_Id);
			$.ajax({
				type: 'POST',								
				url:'/departamento',
				data:{DEP_Id:DEP_Id},
				success: function(data) {
					var param=data.split(sas);
					if(param[0]=="200"){
						$("#DepartamentoActual").val(param[1]);						
					}
				}
			})

			$.ajax({
				type: 'POST',								
				url:'/usuario',
				data:{USR_Id:USR_Id},
				success: function(data) {
					var param=data.split(sas);
					if(param[0]=="200"){
						$("#EditorActual").val(param[1])
					}
				}
			})
			
			$.ajax({
				type: 'POST',								
				url:'/listar-usuarios',
				data:{DEP_Id:DEP_Id, VFL_Id:VFL_Id},
				success: function(data) {
					var param=data.split(sas);
					if(param[0]=="200"){
						$("#USR_NewEditor").html(param[1])
					}
				}
			})
		})

		$("body").on("click", "#btn_cmbeditor", function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();

			var FLU_Id = $("#FLU_Id").val();
			formValidate("#frmbtn_cmbeditor")
			if($("#frmbtn_cmbeditor").valid()){
				obs(17,(err, result)=>{					
					if(result.error){
						obsmsg('frmbtn_cmbeditor',(err, result) =>{								
							if(result.error){
								$("body").removeClass("modal-open");
								$("#DRE_ObservacionesActual").val(result.value);
								$.ajax({
									type: 'POST',								
									url:'/cambiar-editor',
									data:$("#frmbtn_cmbeditor").serialize(),
									success: function(data) {
										var param=data.split(sas);
										if(param[0]=="200"){
											requerimientosTable[FLU_Id].ajax.reload();
											swalWithBootstrapButtons.fire({
												icon:'info',								
												title: 'Exitoso',
												text:'El cambio de editor se ha realizado de manera exitosa'
											}).then(() => {
												$("#cambioEditor").modal("hide");
											});	
										}else{
											swalWithBootstrapButtons.fire({
												icon:'error',								
												title: 'ERROR',
												text:'No fue podible de realizar el cambio de editor'
											});
										}
									},
									error: function(){
										swalWithBootstrapButtons.fire({
											icon:'error',								
											title: 'ERROR',
											text:'No fue podible de realizar el cambio de editor'
										});
									}
								})
							}
						})
					}else{
						$.ajax({
							type: 'POST',								
							url:'/cambiar-editor',
							data:$("#frmbtn_cmbeditor").serialize(),
							success: function(data) {
								var param=data.split(sas);
								console.log(FLU_Id);
								if(param[0]=="200"){
									requerimientosTable[FLU_Id].ajax.reload();
									swalWithBootstrapButtons.fire({
										icon:'info',								
										title: 'Exitoso',
										text:'El cambio de editor se ha realizado de manera exitosa'
									}).then(() => {
										requerimientosTable[FLU_Id].ajax.reload();
										$("#cambioEditor").modal("hide");
									});	
								}else{
									swalWithBootstrapButtons.fire({
										icon:'error',								
										title: 'ERROR',
										text:'No fue podible de realizar el cambio de editor'
									});
								}
							},
							error: function(){
								swalWithBootstrapButtons.fire({
									icon:'error',								
									title: 'ERROR',
									text:'No fue podible de realizar el cambio de editor'
								});
							}
						})
					}
				})
			}			
		})

		$("table").on("click",".edtname",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();

			var REQ_Id = $(this).data("req");
			var DRE_Id = $(this).data("dre");						
			//Buscar nombre del requerimiento
			$.ajax({
				type: 'POST',								
				url:'/requerimiento',
				data:{REQ_Id:REQ_Id},
				dataType: 'json',
				success: function(data) {
					//console.log(data,data.data[0].code)
					//var param=data.split(sas);
					if(data.data[0].code=="200"){
						$("#REQ_IdCmbNombre").val(data.REQ_Id);
						$("#REQ_IdActual").html(data.REQ_Id);
						$("#FLU_IdActual").val(data.FLU_Id);
						$("#NombreActual").val(data.data[0].response);
						$("#DRE_IdActualNom").val(DRE_Id);
					}
				}
			})			
			$("#cambioNombre").modal("show");			
		})

		$("body").on("click", "#btn_cmbnombre", function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();

			var FLU_Id = $("#FLU_IdActual").val();
			var DRE_Id = $("#DRE_IdActual").val();
			console.log
			formValidate("#frm_cmbnombre")
			if($("#frm_cmbnombre").valid()){
				swalWithBootstrapButtons.fire({
					title: 'Cambio de nombre de requerimiento',
					text: "Al confirmar esta acción se cambiará el nombre del requerimiento " + $("#REQ_IdCmbNombre").val() + " por : " + $("#NuevoNombre").val() + ". ¿Deseas continuar?",
					icon: 'question',
					showCancelButton: true,
					confirmButtonColor: '#3085d6',
					cancelButtonColor: '#d33',
					confirmButtonText: '<i class="fas fa-thumbs-up"></i> Confirmar',
					cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar'
				}).then((result) => {
					if (result.value) {			
						//Grabar cambio de nombre
						$.ajax({
							type: 'POST',								
							url:'/cambio-nombre-requerimiento',
							data:$("#frm_cmbnombre").serialize(),
							dataType: 'json',
							success: function(data) {								
								if(data.data[0].code=="200"){
									swalWithBootstrapButtons.fire({
										icon:'success',								
										title: 'Exitoso',
										text:'El cambio de nombre se ha realizado de manera exitosa'
									}).then(() => {
										$("#frm_cmbnombre")[0].reset();
										$("#cambioNombre").modal("hide");
										requerimientosTable[FLU_Id].ajax.reload();
									});									
								}else{
									swalWithBootstrapButtons.fire({
										icon:'error',								
										title: 'ERROR',
										text:'No fue podible de realizar el cambio de nombre'
									}).then(() => {
										$("#frm_cmbnombre")[0].reset();
										$("#cambioNombre").modal("hide");
									});				
								}								
							},
							error: function(){
								swalWithBootstrapButtons.fire({
									icon:'error',								
									title: 'ERROR',
									text:'No fue podible de realizar el cambio de nombre'
								}).then(() => {
									$("#frm_cmbnombre")[0].reset();
									$("#cambioNombre").modal("hide");
								});	
							}
						})																			
					}
				})
				
			}else{
			}
		})
		
		$(".buttonVisado").click(function(e){		
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			var FLU_Id = $(this).data("flu");

			ajax_icon_handling('load','Creando listado Requerimientos a Visar','','');			
			$.ajax({
				type: 'POST',								
				url:'/listar-requerimientos-visar',
				data:{FLU_Id:FLU_Id},
				success: function(data) {						
					var param=data.split(sas);						
					if(param[0]=="200"){
						ajax_icon_handling(true,'Listado de Requerimientos a Visar creado.','',param[1]);
						$(document).off('focusin.bs.modal');
						$(".swal2-popup").css("width","60rem");				
						/*														
						$("#tbl-reqparavisar").on("click","tr.rv",function(){							
							
							$(this).find("td").each(function(e){								
								if([e]==5){
									OC=this.innerText;
									$("#PAG_OrdenCompra").val(OC);
									$("#PAG_OrdenCompra").siblings("label").addClass("active");
									//$("#PAG_OrdenCompra").siblings("i.fas").addClass("active");
								}
							});
							Swal.close();
							changedata=true;
							$(document).off('focusin.bs.modal');								
						})*/
					}else{
						ajax_icon_handling(false,'No fue posible crear el listado Requerimientos a Visar.','','');
					}						
				},
				error: function(XMLHttpRequest, textStatus, errorThrown){				
					ajax_icon_handling(false,'No fue posible crear el listado Requerimientos a Visar.','','');	
				},
				complete: function(){															
				}
			})
		})

		$("body").on("click","#btn_visarautomatico",function(){
			var FLU_Id = $(this).data("flu");
			swalWithBootstrapButtons.fire({
				title: 'Visado Automático de Requerimientos',
				text: "Al confirmar esta acción se visaran todos los requerimientos que se encuentren en el ultimo paso de este flujo " + ". ¿Deseas continuar?",
				icon: 'question',
				showCancelButton: true,
				confirmButtonColor: '#3085d6',
				cancelButtonColor: '#d33',
				confirmButtonText: '<i class="fas fa-thumbs-up"></i> Confirmar',
				cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar'
			}).then((result) => {
				if (result.value) {					
					$.ajax({
						type: 'POST',								
						url:'/visado-automatico',
						data:{FLU_Id:FLU_Id},
						dataType: 'json',
						success: function(data) {								
							if(data.data[0].code=="200"){
								swalWithBootstrapButtons.fire({
									icon:'success',								
									title: 'Exitoso',
									text:'El visado autmático se ha realizado de manera exitosa'
								}).then(() => {									
									requerimientosTable[FLU_Id].ajax.reload();
								});									
							}else{
								swalWithBootstrapButtons.fire({
									icon:'error',								
									title: 'ERROR',
									text:'No fue podible de realizar el visado autmático'
								}).then(() => {									
								});				
							}								
						},
						error: function(){
							swalWithBootstrapButtons.fire({
								icon:'error',								
								title: 'ERROR',
								text:'No fue podible de realizar el visado autmático'
							}).then(() => {								
							});	
						}
					})																			
				}
			})
		})
	});		
</script>