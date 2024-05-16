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

	<h5>Informe de Pagos</h5>
	<h6>Filtros</h6>
	<form role="form" action="<%=action%>" method="POST" name="frminfpagos" id="frminfpagos" class="needs-validation">
		<div class="row"> 			
			<div class="col-sm-12 col-md-6 col-lg-2">
                <div class="md-form input-with-post-icon">
                    <div class="error-message">								
                        <i class="fas fa-tag input-prefix"></i>
                        <input type="number" id="PRO_RUT" name="PRO_RUT" class="form-control" min="100000">
                        <span class="select-bar"></span>
                        <label for="PRO_RUT">RUT Proveedor</label>
                    </div>
                </div>
            </div>
			<div class="col-sm-12 col-md-6 col-lg-4">
                <div class="md-form input-with-post-icon">
                    <div class="error-message">								
                        <i class="fas fa-tag input-prefix"></i>
                        <input type="text" id="PRO_RazonSocial" name="PRO_RazonSocial" class="form-control">
                        <span class="select-bar"></span>
                        <label for="PRO_RazonSocial">Razon Social</label>
                    </div>
                </div>
            </div>
            <div class="col-sm-12 col-md-6 col-lg-2">
                <div class="md-form input-with-post-icon">
                    <div class="error-message">								
                        <i class="fas fa-tag input-prefix"></i>
                        <input type="text" id="PAG_OC" name="PAG_OC" class="form-control">
                        <span class="select-bar"></span>
                        <label for="PAG_OC">O.C.</label>
                    </div>
                </div>
            </div>
            <div class="col-sm-12 col-md-6 col-lg-2">
                <div class="md-form input-with-post-icon">
                    <div class="error-message">								
                        <i class="fas fa-tag input-prefix"></i>
                        <input type="number" id="VRE_Id" name="VRE_Id" class="form-control">
                        <span class="select-bar"></span>
                        <label for="VRE_Id">Nro.Req.</label>
                    </div>
                </div>
            </div>
            <!--<div class="col-sm-12 col-md-6 col-lg-2">
                <div class="md-form input-with-post-icon">
                    <div class="error-message">								
                        <i class="fas fa-tag input-prefix"></i>
                        <input type="text" id="DRE_FechaEdit" name="DRE_FechaEdit" class="form-control calendar" readonly>
                        <span class="select-bar"></span>
                        <label for="DRE_FechaEdit">Fecha de Creación</label>
                    </div>
                </div>
            </div>-->
		</div>
		<div class="row">
			<div class="col align-self-end">
                <button type="button" class="btn btn-success btn-md waves-effect waves-dark buttonExport" style="float: right;"><i class="fas fa-file-excel"></i>  Descargar Informe</button>
				<button type="button" class="btn btn-primary btn-md waves-effect waves-dark" id="btn_frminfpagos" name="btn_frminfpagos" style="float: right;"><i class="fas fa-filter"></i> Aplicar Filtros</button>                
			</div>
		</div>        
    </div>
	</form>
	
	<h6 style="margin-bottom:15px">Resultados del informe</h6>
	<div class="row"> 		
		<div class="col-12" style="overflow: auto;">
			<table id="tbl-infpagos" class="ts table table-striped table-bordered dataTable table-sm" data-id="infpagos" data-page="true" data-selected="true" data-keys="1"> 
				<thead> 
					<tr> 
						<th>Req</th>
						<th>Descripcón</th>								 
						<th>Creación</th>
						<th>Creado Por:</th>
                        <th>Paso</th>
                        <th>Estado</th>
                        <th>Editor</th>
                        <th>Dependencia</th>
                        <th>RUT Pro.</th>
                        <th>Razon Social</th>
                        <th>O.C.</th>                        
						<th>T.Doc.</th>
                        <th>Ver+</th>
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
		var infpagosTable;
        var iTermGPACounter = 1;
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
		$('#tbl-infpagos').DataTable()
        $('#tbl-infpagos').css('width','100%')
		function tableinfpagos(data){			
			var tables = $.fn.dataTable.fnTables(true);
			$(tables).each(function () {
				$(this).dataTable().fnDestroy();
			});			
			infpagosTable = $('#tbl-infpagos').DataTable({
				lengthMenu: [ 10,15,20 ],
				stateSave: true,
				ajax:{
					url:"/tbl-infpagos",
					type:"POST",
					data:data,
					dataSrc:function(json){												
						return json.data;
					}
				},				
				columnDefs: [{
					"targets": [0,4,8,11],"width":"20px"
				},
				{
					"targets": [1],"width":"300px"
				}]
			});
		}		
		
		$("#btn_frminfpagos").click(function(){
			formValidate("#frminfpagos")
			if($("#frminfpagos").valid()){				
				let PRO_RUT = $("#PRO_RUT").val().toString()
                let PRO_RazonSocial = $("#PRO_RazonSocial").val()
                let PAG_OC = $("#PAG_OC").val()
                let VRE_Id = $("#VRE_Id").val().toString()
                
                if(PRO_RUT === "" && PRO_RazonSocial === "" && PAG_OC === "" && VRE_Id === ""){
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
				            tableinfpagos(data)	
                        }
                    })
                }else{
                    var data = {PRO_RUT:PRO_RUT,PRO_RazonSocial:PRO_RazonSocial,PAG_OC:PAG_OC,VRE_Id:VRE_Id}
				    tableinfpagos(data)	
                }				
			}
		})
        
        $(".buttonExport").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();			
			var idTable = $(this).data("id");
			var FLU_Id = $(this).data("flu");			
			var Tipo = $(this).data("tpo");
            var columns;
            columns = ["F.Generación","R.Id","R.Descripción","R.Estado","R.Creación","Creador","Id.Flujo","Paso","Id.V.Flujo","Id.Form","Flujo","D.Limite","Estado Paso","Editor","Dependencia","Observaciones","F.Aprobación","F.Publicación","F.Emisión","N.Documento","O.C.","Folio Comp.","M.Total","A.Digital","F.Devengo","Razón Social","Pro.RUT","T.Documento","Moneda","U.RC.","Per.Pagado","T.Servicio","T.Pago"]

			wrk_informesgenerales("/prt-infopagos","/wrk-informesgenerales",'infopagos', columns, null, null, null, '<%=session("wk2_usrid")%>','<%=session("wk2_usrtoken")%>');            
		});


        //Detalle del requerimiento
        $("#tbl-infpagos").on("click",".verdetalle",function(e){			
			var tr  = $(this).closest("tr");
			var row = infpagosTable.row(tr);			
			var id  = $(this).data("id");			

			$(this) .toggleClass("openmenu");
			var TAD_Id = $(this) .parent().parent().find("td")[3].innerHTML;

			if (row.child.isShown()) {				  
			  $("div.slider", row.child()).slideUp( function () {
				 row.child.hide();
				 tr.removeClass("shown");				 
			  } );
			  $(this).parent().toggleClass("collapsed")			  
			} else {
			  // Open this row			  
			  row.child(formatRespuesta(row.data(),"tbl-reqDETALLE_" + iTermGPACounter ,TAD_Id)).show();
			  tr.addClass("shown");
			  $("div.slider", row.child()).slideDown();			  
			  $(this).parent().toggleClass("collapsed")				 			  

			  iTermGPACounter += 1;						 
			}			
		});

        function formatRespuesta(rowData,table_id,TAD_Id) {	
			var div = $('<div class="slider"/>')
				.addClass( 'loading' )
				.text( 'Loading...' );

			$.ajax( {
				type:'POST',
				url: '/ver-detalle-requerimiento',
				data: {VRE_Id: rowData[0],table: table_id,},
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
	});
</script>