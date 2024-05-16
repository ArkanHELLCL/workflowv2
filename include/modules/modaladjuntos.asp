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

	columnsDefsadjuntosreq="[]"
	response.write("200\\#adjuntosreqModal\\")%>
	<div class="modal-dialog cascading-modal narrower modal-full-height modal-bottom" role="document">  		
		<div class="modal-content">		
			<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
				<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-cloud-download-alt"></i> Adjuntos</div>				
			</div>				
			<div class="modal-body" style="padding:0px;">				
				<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">											
					<div class="px-4">
						<div class="table-wrapper col-sm-12" id="container-table-adjuntosreq">
							<!--Table-->
							<table id="tbl-adjuntosreq" class="table-striped table-bordered table-sm no-hover" cellspacing="0" width="100%" data-id="adjuntosreq" data-keys="1" data-key1="11" data-url="" data-edit="false" data-header="9" data-ajaxcallview="">
								<thead>										
										<th>Corr</th>										
										<th>Nombre</th>
										<th>Tamaño</th>											
										<th>Modificación</th>
										<th>VFO_Id</th>
										<th>DRE_Id</th>
										<th>Descarga</th>
									</tr>
								</thead>									
							</table>
						</div>
					</div>							
				</div>									
			</div>
			<!--body-->
			<div class="modal-footer">
				<div style="float:right;" class="btn-group" role="group" aria-label="">
					<button class="btn btn-default buttonExport btn-md waves-effect" data-toggle="tooltip" title="Descargar todos los adjuntos" data-id="adjuntosreq"><i class="fas fa-download ml-1"></i></button>
					<button type="button" class="btn btn-secondary btn-md waves-effect" data-dismiss="modal" data-toggle="tooltip" title="Salir"><i class="fas fa-sign-out-alt"></i></button>
				</div>					
			</div>		  
			<!--footer-->				
		</div>
	</div>
	<!--modal-dialogo-->

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
				
		var adjuntosreqTable;		
		var disabled={};
		var iTermGPACounter = 1;
		var DRE_Id = getparam(3);
		$("#adjuntosreqModal").on('show.bs.modal', function(e){					
			
		})		
					
		function loadTableadjuntosreq(){			
			if($.fn.DataTable.isDataTable( "#tbl-adjuntosreq")){				
				if(adjuntosreqTable!=undefined){
					adjuntosreqTable.destroy();
				}else{
					$('#tbl-adjuntosreq').dataTable().fnClearTable();
    				$('#tbl-adjuntosreq').dataTable().fnDestroy();
				}
			}	
			adjuntosreqTable = $('#tbl-adjuntosreq').DataTable({
				lengthMenu: [ 5,10,20 ],
				ajax:{
					url:"/adjuntos-requerimientos",
					type:"POST",
					data:{DRE_Id:DRE_Id}
				},
				dom: 'lBfrtip',
            	buttons: [					
					$.extend( true, {}, buttonCommon, {
						extend: 'excelHtml5'
					} )					
				],
				columnDefs: [{
					"targets": [4,5],
					"visible": false,
					"searchable": false,
					"orderable": false
				}],
				"order": [[0,"desc"]]
				
			});	
		}

		jQuery.fn.DataTable.Api.register( 'buttons.exportData()', function ( options ) {
            if ( this.context.length ) {
				var row = [];								
                var jsonResult = $.ajax({
                    url:"/adjuntos-requerimientos",
					data:{DRE_Id:DRE_Id},
                    success: function (result) {
                        //Do nothing
                    },
                    async: false,
					type:"POST"
                });				
				$("#tbl-adjuntosreq").DataTable().columns().header().each(function(e,i){			
					row.push(e.innerText.replace(/(\r\n|\n|\r)/gm, ""))
				});								
				return {body: JSON.parse(jsonResult.responseText).data, header: row};
            }
        } );
		var buttonCommon = {
			exportOptions: {
				format: {
					body: function ( data, row, column, node ) {
						// Strip $ from salary column to make it numeric
						//nothing
					}
				}
			}
		};
		
		$("#adjuntosreqModal").on('shown.bs.modal', function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();									
			
			$(document).off('focusin.modal');
			$("body").addClass("modal-open");
			loadTableadjuntosreq();			
			exportTable();
		});					
		
		$("#adjuntosreqModal").on('hidden.bs.modal', function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
            
            var modo = <%=modo%>;							
            var data = {modo:modo, DRE_Id:DRE_Id};

			$("body").removeClass("modal-open")			
			$('#container-table-adjuntosreq').animate({
				height: $('#container-table-adjuntosreq').get(0).scrollHeight
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

        $("table").on("click",".arcreq",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
        
            var INF_Arc = $(this).data("file");
            var VFO_Id = $(this).data("vfo");
			var DRE_Id = $(this).data("dre");
            var data = {VFO_Id:VFO_Id,DRE_Id,DRE_Id,INF_Arc:INF_Arc};
            
			downloadFile(data)
        })

		function downloadFile(data){
			const INF_Arc = data.INF_Arc;
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
		}
		
		function exportTable(){
			$(".buttonExport").click(function(e){				
				e.preventDefault();
				e.stopPropagation();
				var idTable = $(this).data("id")

				let title='';
				const totalFiles = $("#tbl-adjuntosreq").DataTable().context[0].aoData.length;				
				if(totalFiles > 1) {
					title = '¿Deseas descargar los ' + totalFiles + ' archivos adjuntos?'
				}else{
					title = '¿Deseas descargar el archivo adjunto?';
				}

				const inputValue=idTable + '.csv';
				const { value: csvFilename } = swalWithBootstrapButtons.fire({
					icon:'question',
					title: title,
					showCancelButton: true,
					confirmButtonText: '<i class="fas fa-download"></i> Descargar',
					cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar'
				}).then((result) => {
					if(result.value){											
						const files=$("#tbl-adjuntosreq").DataTable().context[0].aoData
						//console.log(files)
						files.map(item => {
							const data = {
								VFO_Id: item._aData[4],
								DRE_Id: item._aData[5],
								INF_Arc: item._aData[1]
							}
							//console.log(data)
							downloadFile(data)
						})
						//downloadFile(data)
					}

				});			
			})
		}		
		
		$("body").append("<button id='btn_modaladjuntosreq' name='btn_modaladjuntosreq' style='visibility:hidden;width:0;height:0'></button>");
		$("#btn_modaladjuntosreq").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			$("#adjuntosreqModal").modal("show");
			$("body").addClass("modal-open");
				
		});
		$("#btn_modaladjuntosreq").click();		
		$("#btn_modaladjuntosreq").remove();

		function getparam(id){
			var href = window.location.href;
			var newhref = href.substr(href.indexOf("/home")+6,href.length);
			var href_split = newhref.split("/")

			return href_split[id];			
		}
	})
	
</script>
