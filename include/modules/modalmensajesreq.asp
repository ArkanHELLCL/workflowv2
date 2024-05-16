<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
	splitruta=split(ruta,"/")		
	DRE_Id=splitruta(7)
	xm=splitruta(5)
	
	if(xm="modificar") then
		modo=2		
		required="required"
	end if
	if(xm="visualizar") or (session("wk2_usrperfil")=5) then
		modo=4		
		required="disabled"
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
		REQ_Identificador					= rs("REQ_Identificador")
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

	columnsDefsmensajesreq="[]"
	response.write("200\\#mensajesreqModal\\")%>
	<div class="modal-dialog cascading-modal narrower modal-full-height modal-bottom" role="document">  		
		<div class="modal-content">		
			<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
				<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-comments"></i> Mensajes Requerimiento</div>				
			</div>				
			<div class="modal-body" style="padding:0px;">				
				<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">											
					<div class="px-4">
						<div class="table-wrapper col-sm-12" id="container-table-mensajesreq">
							<!--Table-->
							<table id="tbl-mensajesreq" class="table-striped table-bordered table-sm no-hover" cellspacing="0" width="100%" data-id="mensajesreq" data-keys="1" data-key1="11" data-url="" data-edit="false" data-header="9" data-ajaxcallview="">
								<thead>										
										<th>id</th>										
										<th>Remitente</th>
										<th>Tipo</th>											
										<th>Mensaje</th>
										<th>Fecha</th>										
										<th class="no-sort">&nbsp;</th>
									</tr>
								</thead>									
							</table>
						</div>
					</div>							
				</div>									
			</div>
			<!--body-->
			<div class="modal-footer"><%
				if (REQ_Estado=1) then%>
					<div style="float:left;" class="btn-group" role="group" aria-label="">
						<button class="btn btn-success btn-md waves-effect" type="button" data-url="" title="Crear nuevo mensaje" id="btn_creaconsultapry" name="btn_creaconsultapry"><i class="fas fa-plus ml-1"></i></button>
					</div><%
				end if%>

				<div style="float:right;" class="btn-group" role="group" aria-label="">
					<button class="btn btn-default buttonExport btn-md waves-effect" data-toggle="tooltip" title="Exportar datos de la tabla" data-id="mensajesreq"><i class="fas fa-download ml-1"></i></button>
					<button type="button" class="btn btn-secondary btn-md waves-effect" data-dismiss="modal" data-toggle="tooltip" title="Salir"><i class="fas fa-sign-out-alt"></i></button>
				</div>					
			</div>		  
			<!--footer-->				
		</div>
	</div>
	<!--modal-dialogo-->
	<%
	if (REQ_Estado=1) then%>
		<!-- Formulario para crear un nuevo mensaje -->
		<div class="modal fade in" id="nuevoMensajepryModal" tabindex="-1" role="dialog" aria-labelledby="nuevoMensajepryModalLabel" aria-hidden="true">
			<div class="modal-dialog cascading-modal narrower modal-lg" role="document">  		
				<div class="modal-content">		
					<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
						<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-comments"></i> Ingresa tu consulta</div>				
					</div>
					<form role="form" action="" method="POST" name="frmcreamensajereq" id="frmcreamensajereq" class="needs-validation">
						<div class="modal-body">
							<div class="row">							
								<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
									<div class="md-form">
										<div class="error-message">								
											<i class="fas fa-comment prefix"></i>										
											<textarea id="MEN_TextoConsulta" name="MEN_TextoConsulta" class="md-textarea form-control" rows="3" required></textarea>
											<span class="select-bar"></span>
											<label for="MEN_TextoConsulta" class="">Consulta</label>									
										</div>
									</div>
								</div>					
							</div>
						</div>				
						<div class="modal-footer">
							<button type="button" class="btn btn-secondary btn-md waves-effect" id="btn_creamsjprycerrar" name="btn_creamsjprycerrar"><i class="fas fa-times"></i> Cerrar</button>
							<button type="button" class="btn btn-primary btn-md waves-effect" id="btn_creamsjpry" name="btn_creamsjpry"><i class="fas fa-paper-plane"></i> Enviar</button>
						</div>
						<input type="hidden" id="MEN_IdConsulta" value="" name="MEN_IdConsulta">
					</form>
				</div>
			</div>
		</div>
		<!-- Formulario para crear un nuevo mensaje -->

		<!-- Formulario pra responder a una consulta -->
		<div class="modal fade in" id="nuevaRespuestapryModal" tabindex="-1" role="dialog" aria-labelledby="nuevaRespuestapryModalLabel" aria-hidden="true">
			<div class="modal-dialog cascading-modal narrower modal-lg" role="document">  		
				<div class="modal-content">		
					<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
						<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-comments"></i> Ingresa tu respuesta</div>				
					</div>
					<form role="form" action="" method="POST" name="frmcrearespuestareq" id="frmcrearespuestareq" class="needs-validation">
						<div class="modal-body">
							<div class="row">					
								<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
									<div class="md-form">
										<div class="error-message">								
											<i class="fas fa-comment prefix"></i>										
											<textarea id="MEN_TextoRespuesta" name="MEN_TextoRespuesta" class="md-textarea form-control" rows="3" required></textarea>
											<span class="select-bar"></span>
											<label for="MEN_TextoRespuesta" class="">Respuesta</label>
										</div>						
									</div>	
								</div>					
							</div>
						</div>				
						<div class="modal-footer">
							<button type="button" class="btn btn-secondary btn-md waves-effect" id="btn_respuestareqcerrar" name="btn_respuestareqcerrar"><i class="fas fa-times"></i> Cerrar</button>
							<button type="button" id="btn_respuestareq" name="btn_respuestareq" class="btn btn-primary btn-md waves-effect"><i class="fas fa-paper-plane"></i> Responder</button>
						</div>
						<input type="hidden" id="MEN_IdRespuesta" value="" name="MEN_IdRespuesta">					
					</form>
				</div>
			</div>
		</div>
		<!-- Formulario pra responder a una consulta --><%
	end if%>

<script>
    //Mensajes Requerimiento
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
		var bb = String.fromCharCode(92) + String.fromCharCode(92);
		var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);
		var s  = String.fromCharCode(47);
		var b  = String.fromCharCode(92);						
				
		var mensajesreqTable;		
		var disabled={};
		var iTermGPACounter = 1;
		var DRE_Id = getparam(3);
		$("#mensajesreqModal").on('show.bs.modal', function(e){					
			
		})		
					
		function loadTablemensajesreq(){			
			if($.fn.DataTable.isDataTable( "#tbl-mensajesreq")){				
				if(mensajesreqTable!=undefined){
					mensajesreqTable.destroy();
				}else{
					$('#tbl-mensajesreq').dataTable().fnClearTable();
    				$('#tbl-mensajesreq').dataTable().fnDestroy();
				}
			}	
			mensajesreqTable = $('#tbl-mensajesreq').DataTable({
				lengthMenu: [ 5,10,20 ],
				ajax:{
					url:"/mensajes-requerimientos",
					type:"POST",
					data:{DRE_Id:DRE_Id}
				},				
				"columnDefs": <%=columnsDefsmensajesreq%>,
				"order": [[0,"desc"]]
				
			});	
		}								
		
		$("#mensajesreqModal").on('shown.bs.modal', function(e){		
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();									
			
			$(document).off('focusin.modal');
			$("body").addClass("modal-open");
			loadTablemensajesreq();			
			exportTable();
		});					
		
		$("#mensajesreqModal").on('hidden.bs.modal', function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();

            //var DRE_Id=<%=DRE_Id%>;
            var modo = <%=modo%>;							
            var data = {modo:modo, DRE_Id:DRE_Id};

			$("body").removeClass("modal-open")			
			$('#container-table-mensajesreq').animate({
				height: $('#container-table-mensajesreq').get(0).scrollHeight
			}, 700, function(){
				$(this).height('auto');
			});			            
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
                            title: 'Ups!, no pude cargar el menú del requerimiento',					
                            text:param[1]
                        });				
                    }
                },
                error: function(XMLHttpRequest, textStatus, errorThrown){					
                    swalWithBootstrapButtons.fire({
                        icon:'error',								
                        title: 'Ups!, no pude cargar el menú del requerimiento',					
                    });				
                }
            });
		});						
		
		$("#mensajesreqModal").on("click", ".verrespry", function(e) {
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			
			var tr = $(this).closest('tr');
			var row = mensajesreqTable.row(tr);			
			var id=$(this).data("id");			
			
			$(this).toggleClass('openmenu');			
			
			if (row.child.isShown()) {				  
			  $('div.slider', row.child()).slideUp( function () {
				 row.child.hide();
				 tr.removeClass('shown');				 
			  } );
			  $(this).parent().find(".vermod").toggleClass("collapsed")			  
			} else {
			  // Open this row			  
			  row.child(formatRespuesta(row.data(),"tbl-menpryRES_" + iTermGPACounter )).show();
			  tr.addClass('shown');
			  $('div.slider', row.child()).slideDown();			  
			  $(this).parent().find(".vermod").toggleClass("collapsed")				 			  

			  iTermGPACounter += 1;						 
			}			
	  	});
		
		$("body").on("click", ".resppry",function(e){		
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
						
			$("#nuevaRespuestapryModal").modal("show");
			$("#MEN_IdRespuesta").val($(this).data("id"));			
		});
		
		$("body").on("click", "#btn_respuestareqcerrar",function(e){			
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			
			$("#nuevaRespuestapryModal").modal("hide")
		});
		
		
		$("body").on("click", "#btn_respuestareq",function(e){			
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			
			formValidate("#frmcrearespuestareq");						
			if($("#frmcrearespuestareq").valid()){
				var data = {REQ_Id:<%=REQ_Id%>,REQ_Identificador:'<%=REQ_Identificador%>',MEN_Id:$("#MEN_IdRespuesta").val(),MEN_Texto:$("#MEN_TextoRespuesta").val()}                
				$.ajax( {
					type:'POST',
					url: '/enviar-respuestas-requerimiento',
					data: data,
					dataType: "json",
					success: function ( data ) {
						if(data.state=200){
							$("#frmcrearespuestareq")[0].reset();
							mensajesreqTable.ajax.reload();
							$("#nuevaRespuestapryModal").modal("hide")
							Toast.fire({
							  icon: 'success',
							  title: 'Respuesta enviada exitosamente.'
							});
						}else{
							swalWithBootstrapButtons.fire({
								icon:'error',
								title:'Envío de respuesta Fallido',
								text:data.message
							});
						}
					},
					error: function(XMLHttpRequest, textStatus, errorThrown){				
						swalWithBootstrapButtons.fire({
							icon:'error',
							title:'Envío de respuesta Fallido'							
						});
					}
				});
											
			}
			
		})
		
		$("body").on("click", "#btn_creamsjpry",function(e){			
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			
			formValidate("#frmcreamensajereq");						
			if($("#frmcreamensajereq").valid()){
				var data = {REQ_Id:<%=REQ_Id%>,REQ_Identificador:'<%=REQ_Identificador%>',MEN_Id:$("#MEN_IdConsulta").val(),MEN_Texto:$("#MEN_TextoConsulta").val()}
				$.ajax( {
					type:'POST',
					url: '/enviar-consulta-requerimiento',
					data: data,
					dataType: "json",
					success: function ( data ) {
						if(data.state=200){
							$("#frmcreamensajereq")[0].reset();
							mensajesreqTable.ajax.reload();
							$("#nuevoMensajepryModal").modal("hide")
							Toast.fire({
							  icon: 'success',
							  title: 'Consulta enviada exitosamente.'
							});
						}else{
							swalWithBootstrapButtons.fire({
								icon:'error',
								title:'Envío de consulta Fallido',
								text:data.message
							});
						}
					},
					error: function(XMLHttpRequest, textStatus, errorThrown){				
						swalWithBootstrapButtons.fire({
							icon:'error',
							title:'Envío de consulta Fallido'							
						});
					}
				});
											
			}
			
		})
		
		$("body").on("click", "#btn_creamsjprycerrar",function(e){			
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			
			$("#nuevoMensajepryModal").modal("hide")
		});					
		$("#nuevoMensajepryModal").on('hidden.bs.modal', function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			
			mensajesreqTable.ajax.reload();			
		})
		
		$("#nuevaRespuestapryModal").on('shown.bs.modal', function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
		})
		$("#nuevoMensajepryModal").on('shown.bs.modal', function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();															
		})
		
		$("body").on("click", "#btn_creaconsultapry",function(e){		
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
						
			$("#nuevoMensajepryModal").modal("show");
			$("#MEN_IdConsulta").val($(this).data("id"));			
		});				
		
		$("#nuevaRespuestapryModal").on('hidden.bs.modal', function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			
			mensajesreqTable.ajax.reload();
		})
		
		function formatRespuesta(rowData,table_id) {	
			var div = $('<div class="slider"/>')
				.addClass( 'loading' )
				.text( 'Loading...' );
			var data = {MEN_Id: rowData[0],table: table_id,REQ_Id:<%=REQ_Id%>,REQ_Identificador:'<%=REQ_Identificador%>'};
			$.ajax( {
				type:'POST',
				url: '/ver-respuestas-requerimiento',
				data: data,
				success: function ( data ) {					
					div
						.html( data )
						.removeClass( 'loading' );
						if ( $.fn.DataTable.isDataTable( "#" + table_id) ) {
							$("#" + table_id).dataTable().fnDestroy();
						}
						$("#" + table_id).DataTable({								
							lengthMenu: [ 4, 6, 10 ],
							order: [[ 0, 'desc' ]]
						});											
				},
				error: function(XMLHttpRequest, textStatus, errorThrown){				

				}
			} );

			return div;
		}								
		
		function exportTable(){			
			$(".buttonExport").click(function(e){
				e.preventDefault();
				e.stopPropagation();
				var idTable = $(this).data("id")

				const inputValue=idTable + '.csv';
				const { value: csvFilename } = swalWithBootstrapButtons.fire({
					icon:'info',
					title: 'Ingresa el nombre del archivo',
					input: 'text',
					inputValue: inputValue,
					showCancelButton: true,
					confirmButtonText: '<i class="fas fa-sync-alt"></i> Generar',
					cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar',
					inputValidator: (value) => {
					if (!value) {
					return 'Debes escribir un nombre de archivo!';
					}
				}
				}).then((result) => {
					if(result.value){						
						$.ajax( {
							type:'POST',
							url: '/requerimiento-preguntas-y-respuestas',
							data: {REQ_Id:<%=REQ_Id%>},					
							success: function ( data ) {
								var param = data.split(sas)
								if(param[0]=="200"){
									var tableRes = $(param[1]);								
									tableRes.exporttocsv({
										fileName  : result.value,
										separator : ';',
										table	  : 'ndt'
									});
								}else{												
								}
							},
							error: function(XMLHttpRequest, textStatus, errorThrown){				
								swalWithBootstrapButtons.fire({
									icon:'error',
									title:'Envío de consulta Fallido'							
								});
							}
						});
					}

				});			
			})
		}				
		
		
		$("body").append("<button id='btn_modalmensajesreq' name='btn_modalmensajesreq' style='visibility:hidden;width:0;height:0'></button>");
		$("#btn_modalmensajesreq").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			$("#mensajesreqModal").modal("show");
			$("body").addClass("modal-open");
				
		});
		$("#btn_modalmensajesreq").click();		
		$("#btn_modalmensajesreq").remove();

		function getparam(id){
			var href = window.location.href;
			var newhref = href.substr(href.indexOf("/home")+6,href.length);
			var href_split = newhref.split("/")

			return href_split[id];			
		}
	})
	
</script>
