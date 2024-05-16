<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
	disabled="required"	
	if mode="add" then
		mode="mod"		
	end if
	if mode="mod" then
		modo=2		
	end if
	if(session("wk2_usrperfil")>2) then	'Solo Super y Adminsitrador puede modificar, el resto solo visualizar
		mode="vis"
		modo=4		
	end if	
	if mode="vis" then
		modo=4		
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
	'response.write("PRY_Id-" & PRY_Id)
%>
	<!--wrapper-editor-->
	<div class="wrapper-editor">		
		<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">			
			<!-- Table with panel -->					
			<div class="card card-cascade narrower">
				<!--Card image-->
				<div class="view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-between align-items-center" style="height:3rem;">
					<div><%
						if session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2 then%>
							<button class="btn btn-success btn-rounded btn-sm waves-effect" title="Crear un nuevo departamento" type="button" data-url="" data-toggle="tooltip" data-id="10" id="btn_addproveedoresModal" name="btn_addproveedoresModal">Agregar<i class="fas fa-plus ml-1"></i></button><%
						end if%>
					</div>
					<a href="" class="white-text mx-3"><i class="fas fa-server"></i> Mantenedor de Proveedores</a>
					<div>						
						<!--<button class="btn btn-secondary btn-rounded buttonExport btn-sm waves-effect" data-toggle="tooltip" title="Exportar datos de la tabla" data-id="proveedores">Exportar<i class="fas fa-download ml-1"></i></button>-->
					</div>
				</div>
				<!--/Card image-->
					
					<div class="table-wrapper col-sm-12">						
						<!--Table-->
						<table id="tbl-proveedores" class="table-striped table-bordered dataTable table-sm" cellspacing="0" width="100%" data-id="proveedores" >
							<thead>
								<tr> 
									<th>#</th>                         
									<th>Razon Social</th>
									<th>RUT</th>
									<th>Direccion</th>
									<th>Teléfono</th>
									<th>Email</th>
									<th>PAC</th>
                                    <th>Banco</th>
                                    <th>Tipo de Cuenta</th>
                                    <th>Número de Cuenta</th>
                                    <th>Estado</th>
								</tr> 
							</thead>
							<tbody>
							</tbody>
						</table>						
					</div>
				
			</div>
			<!-- Table with panel -->		
		</div>	  
	</div>
	<!--wrapper-editor-->
<script>
	$(document).ready(function(e) {
		var proveedoresTable;
		var bb = String.fromCharCode(92) + String.fromCharCode(92);
		$(function () {
			$('[data-toggle="tooltip"]').tooltip({
				trigger : 'hover'
			})
			$('[data-toggle="tooltip"]').on('click', function () {
				$(this).tooltip('hide')
			})		
		});
		$('#tbl-proveedores tbody').on( 'click', 'td', function (e) {
			e.stopImmediatePropagation();
			e.stopPropagation();
		} );							
		function tableproveedores(){			
			var tables = $.fn.dataTable.fnTables(true);
			$(tables).each(function () {
				$(this).dataTable().fnDestroy();
			});	            
			proveedoresTable = $('#tbl-proveedores').DataTable({
				lengthMenu: [ 10,15,20 ],
				stateSave: true,
				processing: true,
        		serverSide: true,
				ajax:{
					url:"/tbl-proveedores",
					type:"POST",				
					dataSrc:function(json){					
						return json.data;					
					}
				},
                dom: 'lBfrtip',
            	buttons: [					
					$.extend( true, {}, buttonCommon, {
						extend: 'excelHtml5'
					} )					
				],
                columnDefs: [{
                    "targets": [0,1,2,3,4,5,6,7,8,9],
                    "orderable": false,
                }],                
				autoWidth: false,
				fnRowCallback: function( nRow, aData, iDisplayIndex, iDisplayIndexFull ) {					
					$(nRow).click(function(e){						
						e.preventDefault();
						e.stopImmediatePropagation();
						e.stopPropagation();
						
						var PRO_Id = $(this).find("td")[0].innerText;
						var data={PRO_Id:PRO_Id,mode:'mod'}
						
						$.ajax( {
							type:'POST',
							url: '/modal-proveedores',
							data: data,
							success: function ( data ) {
								param = data.split(bb)
								if(param[0]==200){							
									$("#proveedoresModal").html(param[1]);
									$("#proveedoresModal").modal("show");
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
					});
				}
			});
		}
		
		$("#proveedoresModal").on('hidden.bs.modal', function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation()
			tableproveedores();
		})
		
		tableproveedores();				
	
		
		$("#btn_addproveedoresModal").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();						
			$.ajax( {
				type:'POST',					
				url: '/modal-proveedores',
				data: {mode:'add'},
				success: function ( data ) {
					param = data.split(bb)
					if(param[0]==200){							
						$("#proveedoresModal").html(param[1]);
						$("#proveedoresModal").modal("show");
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
		})

        jQuery.fn.DataTable.Api.register( 'buttons.exportData()', function ( options ) {
            if ( this.context.length ) {
				var row = [];
				var INF_Fecha = $("#INF_Fecha").val();
				var INF_Mes = $("#INF_Mes").val();
				var INF_Anio = $("#INF_Anio").val();
				var INF_Usuario = $("#INF_Usuario").val();

                var INF_NroDoc = $("#INF_NroDoc").val();
                var INF_Proveedor = $("#INF_Proveedor").val();
                var INF_NroOC = $("#INF_NroOC").val();

				var data = {INF_Fecha:INF_Fecha, INF_Mes: INF_Mes, INF_Anio: INF_Anio, INF_Usuario:INF_Usuario,INF_NroDoc:INF_NroDoc,INF_Proveedor:INF_Proveedor,INF_NroOC:INF_NroOC,search: $("#search").val(),start:0}
                var jsonResult = $.ajax({
                    url:"/print-proveedores",                    
					data:data,
                    success: function (result) {
                        //Do nothing
                    },
                    async: false,
					type:"POST"
                });				
				$("#tbl-proveedores").DataTable().columns().header().each(function(e,i){			
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
	})
</script>