<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%
    disabled="required"	
	if mode="add" then
		mode="mod"		
	end if	
	if(session("wk2_usrperfil")>2) then	'Solo Super y Adminsitrador puede modificar, el resto solo visualizar
		mode="vis"
		modo=4		
	end if	
	disabled="required"		
	if mode="mod" then
		modo=2		
	end if
	if(session("wk2_usrperfil")=3 or session("wk2_usrperfil")=4) then
		mode="vis"
		modo=4
		disabled="readonly disabled"				
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
	
	lblClass=""
	if(mode="mod" or mode="vis") then				
	end if	
	rs.close

    AnoDesde=2022
	AnoActual=year(date())	'Ano actual
	MesActual=month(date())	'Mes Actual

	response.write("200/@/")%>

	<h5>Informe de Ordenes de Compra</h5>	
	<h6 style="margin-bottom:15px">Resultados del informe</h6>
    
    <h6>Filtros</h6>
	<form role="form" action="<%=action%>" method="POST" name="frmsegpagos" id="frmsegpagos" class="needs-validation">
		<div class="row"> 			
			<div class="col-xs-12 col-sm-3 col-md-3 col-lg-3">
				<div class="md-form input-with-post-icon">
					<div class="error-message">											
						<div class="select">
							<select name="INF_Mes" id="INF_Mes" class="validate select-text form-control" required>
								<option value="" selected disabled></option>
								<option value="1">Enero</option>
								<option value="2">Febrero</option>
								<option value="3">Marzo</option>
								<option value="4">Abril</option>
								<option value="5">Mayo</option>
								<option value="6">Junio</option>
								<option value="7">Julio</option>
								<option value="8">Agosto</option>
								<option value="9">Septiembre</option>
								<option value="10">Octubre</option>
								<option value="11">Noviembre</option>
								<option value="12">Diciembre</option>
							</select>							
							<i class="fas fa-map-marker-alt input-prefix"></i>
							<span class="select-highlight"></span>
							<span class="select-bar"></span>
							<label for="INF_Mes" class="select-label">Mes Creación</label>
						</div>	
					</div>
				</div>
			</div>	
			<div class="col-xs-12 col-sm-3 col-md-3 col-lg-3">
				<div class="md-form input-with-post-icon">
					<div class="error-message">											
						<div class="select">
							<select name="INF_Anio" id="INF_Anio" class="validate select-text form-control" required>
								<option value="" selected disabled></option><%
								do while AnoDesde<=AnoActual%>										
									<option value="<%=AnoDesde%>"><%=AnoDesde%></option><%									
									AnoDesde=AnoDesde+1
								loop%>
							</select>							
							<i class="fas fa-map-marker-alt input-prefix"></i>
							<span class="select-highlight"></span>
							<span class="select-bar"></span>
							<label for="INF_Anio" class="select-label">Año Creación</label>
						</div>	
					</div>
				</div>
			</div>	
			<div class="col-xs-12 col-sm-3 col-md-3 col-lg-3">
				<div class="md-form input-with-post-icon">
					<div class="error-message">											
						<div class="select">
							<select name="INF_Usuario" id="INF_Usuario" class="validate select-text form-control" required>
								<option value="" selected disabled></option>
								<option value="0">Todos</option><%
								zql="exec spUsuario_Listar -1"
								set rz = cnn.Execute(zql)		
								on error resume next
								do while not rz.eof%>										
									<option value="<%=rz("USR_Id")%>"><%=rz("USR_Usuario")%></option><%									
									rz.movenext
								loop%>
							</select>							
							<i class="fas fa-map-marker-alt input-prefix"></i>
							<span class="select-highlight"></span>
							<span class="select-bar"></span>
							<label for="INF_Usuario" class="select-label">Usuario Creador</label>
						</div>	
					</div>
				</div>
			</div>				
		</div>
		<div class="row">
            <div class="col-xs-12 col-sm-3 col-md-3 col-lg-3">
				<div class="md-form input-with-post-icon">
					<div class="error-message">
                        <input type="number" name="INF_NroDoc" id="INF_NroDoc" class="form-control validate">
                        <i class="fas fa-id-badge input-prefix"></i>
                        <span class="select-highlight"></span>
                        <span class="select-bar"></span>
                        <label for="INF_NroDoc" class="select-label">Número Documento</label>
                    </div>	
                </div>
            </div>
            <div class="col-xs-12 col-sm-3 col-md-3 col-lg-3">
				<div class="md-form input-with-post-icon">
					<div class="error-message">											
						<div class="select">
							<select name="INF_Proveedor" id="INF_Proveedor" class="validate select-text form-control" required>
								<option value="" selected disabled></option>
								<option value="0">Todos</option><%
								zql="exec spProveedores_Listar -1"
								set rz = cnn.Execute(zql)		
								on error resume next
								do while not rz.eof%>										
									<option value="<%=rz("PRO_Id")%>"><%=rz("PRO_RazonSocial")%></option><%									
									rz.movenext
								loop%>
							</select>							
							<i class="fas fa-map-marker-alt input-prefix"></i>
							<span class="select-highlight"></span>
							<span class="select-bar"></span>
							<label for="INF_Proveedor" class="select-label">Proveedor</label>
						</div>	
					</div>
				</div>
            </div>
            <div class="col-xs-12 col-sm-3 col-md-3 col-lg-3">
				<div class="md-form input-with-post-icon">
					<div class="error-message">
                        <input type="text" name="INF_NroOC" id="INF_NroOC" class="form-control validate">
                        <i class="fas fa-id-badge input-prefix"></i>
                        <span class="select-highlight"></span>
                        <span class="select-bar"></span>
                        <label for="INF_NroOC" class="select-label">Número OC</label>
                    </div>	
                </div>
            </div>
        </div>
        <div class="row">        
			<div class="col align-self-end">
				<button type="button" class="btn btn-primary btn-md waves-effect waves-dark" id="btn_frmsegpagos" name="btn_frmsegpagos" style="float: right;"><i class="fas fa-filter"></i> Aplicar Filtros</button>
			</div>
		</div>		
	</form>	
    
	<div class="row"> 		
		<div class="col-12" style="overflow: auto;">
			<table id="tbl-seguimientopagos" class="ts table table-striped table-bordered dataTable table-sm" data-id="seguimientopagos" data-page="true" data-selected="true" data-keys="1" width="99%"> 
				<thead> 
					<tr>                    
						<th>Req</th>
						<th>Descripcón</th>
                        <th>Fecha Creación</th>
						<th>Creador</th>
						<th>Editor</th>

                        <th>Num.Doc</th>
                        <th>Proveedor</th>
                        <th>OC</th>
                        <th>Dif.Dias</th>
						                        
						<th>Flujo</th>
                        <th>V.Flujo</th>
						<th>Estado Pago</th>
						<th>Pagado por:</th>
						<th>Fecha Pago</th>
					</tr> 
				</thead>					
				<tbody>				   	
				</tbody>
			</table>
		</div>
	</div>		
	
	<div class="row">		
		<div class="footer">		
		</div>
	</div>
	
<script>	
	$(document).ready(function() {		
		var bb = String.fromCharCode(92) + String.fromCharCode(92);			
		var seguimientopagosTable;
		var titani = setInterval(function(){				
			$("h5").slideDown("slow",function(){
				$("h6").slideDown("slow",function(){
					clearInterval(titani)
				});
			})
		},2300);

		$(function () {
			$('[data-toggle="tooltip"]').tooltip({
				trigger : 'hover'
			})
			$('[data-toggle="tooltip"]').on('click', function () {
				$(this).tooltip('hide')
			})		
		});
		$('#tbl-seguimientopagos').DataTable()        
		function tableseguimientopagos(data){			
			var tables = $.fn.dataTable.fnTables(true);
			$(tables).each(function () {
				$(this).dataTable().fnDestroy();
			});			
			seguimientopagosTable = $('#tbl-seguimientopagos').DataTable({
				lengthMenu: [ 10,15,20 ],
				stateSave: true,
				ajax:{
					url:"/tbl-seguimientopagos",
					type:"POST",		
                    data:data,			
					dataSrc:function(json){												
						return json.data;
					}
				},
				dom: 'lBfrtip',
            	buttons: [					
					$.extend( true, {}, buttonCommon, {
						extend: 'excelHtml5'
					} ),
					/*$.extend( true, {}, buttonCommon, {
						extend: 'pdfHtml5'
					} )*/
				],
				columnDefs: [{
					"targets": [0,1],"width":"20px"
				},
				{
					"targets": [2],"width":"200px"
				}]
			});
		}		
		
		$("#btn_frmsegpagos").click(function(){
			formValidate("#frmsegpagos")
			if($("#frmsegpagos").valid()){				
				var INF_Fecha = $("#INF_Fecha").val();
				var INF_Mes = $("#INF_Mes").val();
				var INF_Anio = $("#INF_Anio").val();
				var INF_Usuario = $("#INF_Usuario").val();

                var INF_NroDoc = $("#INF_NroDoc").val();
                var INF_Proveedor = $("#INF_Proveedor").val();
                var INF_NroOC = $("#INF_NroOC").val();

				var data = {INF_Fecha:INF_Fecha, INF_Mes: INF_Mes, INF_Anio: INF_Anio, INF_Usuario:INF_Usuario,INF_NroDoc:INF_NroDoc,INF_Proveedor:INF_Proveedor,INF_NroOC:INF_NroOC}				
				tableseguimientopagos(data)	
			}
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
                    url:"/tbl-seguimientopagos",                    
					data:data,
                    success: function (result) {
                        //Do nothing
                    },
                    async: false,
					type:"POST"
                });				
				$("#tbl-seguimientopagos").DataTable().columns().header().each(function(e,i){			
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
	});
</script>