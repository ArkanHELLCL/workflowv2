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

	<h5>Informe de Aprobaciones por DAF</h5>
	<h6>Filtros</h6>
	<form role="form" action="<%=action%>" method="POST" name="frminfaprdaf" id="frminfaprdaf" class="needs-validation">
		<div class="row">
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
							<label for="INF_Anio" class="select-label">Año Aprobación</label>
						</div>	
					</div>
				</div>
			</div>
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
							<label for="INF_Mes" class="select-label">Mes Aprobación</label>
						</div>	
					</div>
				</div>
			</div>				          
		</div>
		<div class="row">
			<div class="col align-self-end">
                <button type="button" class="btn btn-success btn-md waves-effect waves-dark buttonExport" style="float: right;"><i class="fas fa-file-excel"></i>  Descargar Informe</button>
				<button type="button" class="btn btn-primary btn-md waves-effect waves-dark" id="btn_frminfaprdaf" name="btn_frminfaprdaf" style="float: right;"><i class="fas fa-filter"></i> Aplicar Filtros</button>                
			</div>
		</div>        
    </div>
	</form>
	
	<h6 style="margin-bottom:15px">Resultados del informe</h6>
	<div class="row"> 		
		<div class="col-12" style="overflow: auto;">
			<table id="tbl-infaprodaf" class="ts table table-striped table-bordered dataTable table-sm" data-id="infaprodaf" data-page="true" data-selected="true" data-keys="1"> 
				<thead> 
					<tr> 
						<th>Req</th>
						<th>Descripcón</th>                        
						<th>Creación</th>
						<th>Creado Por:</th>                        
                        <th>Estado</th>                        
                        <th>Dep.Origen</th> 
                        <th>Dep.Aprabación</th>
                        <th>Usr.Aprobación</th>
                        <th>Fec.Aprobación</th>
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
	function getFormData($form){
		var unindexed_array = $form.serializeArray();
		var indexed_array = {};        

		$.map(unindexed_array, function(n, i){
			indexed_array[n['name']] = n['value'];
		});

		return indexed_array;
	}
	$(document).ready(function() {		
		var bb = String.fromCharCode(92) + String.fromCharCode(92);			
		var infaprodafTable;        
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
		$('#tbl-infaprodaf').DataTable()
        $('#tbl-infaprodaf').css('width','100%')
		function tableinfaprodaf(data){			
			var tables = $.fn.dataTable.fnTables(true);
			$(tables).each(function () {
				$(this).dataTable().fnDestroy();
			});			
			infaprodafTable = $('#tbl-infaprodaf').DataTable({
				lengthMenu: [ 10,15,20 ],
				stateSave: true,
				ajax:{
					url:"/tbl-infaprodaf",
					type:"POST",
					data:data,
					dataSrc:function(json){												
						return json.data;
					}
				},				
			});
		}		
		
		$("#btn_frminfaprdaf").click(function(){
			formValidate("#frminfaprdaf")
			if($("#frminfaprdaf").valid()){				
				let INF_Anio = $("#INF_Anio").val()
                let INF_Mes = $("#INF_Mes").val()                
                
                /*if(PRO_RUT === "" && PRO_RazonSocial === "" && PAG_OC === "" && VRE_Id === ""){
                    swalWithBootstrapButtons.fire({
                        title: '¿Quieres mostrar TODOS los registos?',
                        text: "Al aceptar generar todos los registros podrías demorar la respuesta mas de lo normal.",
                        icon: 'question',
                        showCancelButton: true,
                        confirmButtonColor: '#3085d6',
                        cancelButtonColor: '#d33',
                        confirmButtonText: '<i class="fas fa-thumbs-up"></i> Si',
                        cancelButtonText: '<i class="fas fa-thumbs-down"></i> No'
                    }).then((result) => {
                        if (result.value) {
                            var data = {PRO_RUT:PRO_RUT,PRO_RazonSocial:PRO_RazonSocial,PAG_OC:PAG_OC,VRE_Id:VRE_Id}
				            tableinfaprodaf(data)	
                        }
                    })
                }else{*/
                    var data = {INF_Anio:INF_Anio,INF_Mes:INF_Mes}
				    tableinfaprodaf(data)	
                //}				
			}
		})
        
        $(".buttonExport").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
            formValidate("#frminfaprdaf")
			if($("#frminfaprdaf").valid()){
                var INF_Anio = $("#INF_Anio").val();
                var INF_Mes = $("#INF_Mes").val();
                var columns;
                columns = ["VRE_Id","VRE_Descripcion","REQ_Estado","ESR_DescripcionRequerimiento","REQ_Ano","REQ_IdUsuarioEdit","REQ_UsuarioEdit","REQ_AccionEdit","REQ_FechaEdit","VFF_Id","VFF_Estado","VFL_Id","VFL_Estado","FLU_Id","FLU_Descripcion","FLU_Estado","VFO_Id","VFO_Estado","FOR_Id","FOR_Descripcion","FOR_Estado","FLD_DiasLimites","ESR_IdFlujoDatos","ESR_DescripcionFlujoDatos","ESR_AccionFlujoDatos","ESR_EstadoFlujoDatos","ESR_IdDatoRequerimiento","ESR_DescripcionDatoRequerimiento","DEP_Id","DEP_Descripcion","DEP_Codigo","DEP_Estado","IdCreador","NombreCreador","ApellidoCreador","IdPerfilCreador","PerfilCreador","JefaturaCreador","UsuarioCreador","IdEditor","NombreEditor","ApellidoEditor","IdPerfilEditor","PerfilEditor","JefaturaEditor","UsuarioEditor","DEP_IdActual","DepDescripcionActual","DepEstadoActual","DepCodigoActual","DEP_IdOrigen","DepDescripcionOrigen","DepEstadoOrigen","DepCodigoOrigen","DRE_Estado","DRE_UsuarioEdit","DRE_FechaEdit","DRE_AccionEdit","DRE_DifDias"]

                wrk_informesgenerales("/prt-aprobacioesdaf","/wrk-informesgenerales",'infaprobdaf', columns, INF_Anio, INF_Mes, null, '<%=session("wk2_usrid")%>','<%=session("wk2_usrtoken")%>');            
            }
		});
        
	});
</script>