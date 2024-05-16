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

	<h5>Informe de Boletas de Garantías</h5>
	<h6>Filtros</h6>
	<form role="form" action="<%=action%>" method="POST" name="frm10s4" id="frm10s4" class="needs-validation">
		<div class="row"> 
			<div class="col-xs-12 col-sm-3 col-md-3 col-lg-3">
				<div class="md-form input-with-post-icon">
					<div class="error-message">											
						<div class="select">
							<select name="REQ_Estado" id="REQ_Estado" class="validate select-text form-control" required>
								<option value="-1">Todos</option>
								<option value="1" selected>Pendientes</option>
								<option value="6">Cerrados</option>
							</select>							
							<i class="fas fa-map-marker-alt input-prefix"></i>
							<span class="select-highlight"></span>
							<span class="select-bar"></span>
							<label for="REQ_Estado" class="select-label">Estado del requerimiento</label>
						</div>	
					</div>
				</div>
			</div>					
		</div>
		<div class="row">
			<div class="col align-self-end">
				<button type="button" class="btn btn-primary btn-md waves-effect waves-dark buttonExport" id="btn_frm10s4" name="btn_frm10s4" style="float: right;"><i class="fas fa-filter"></i> Generar Informe</button>
			</div>
		</div>		
	</form>			
	
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
		var infdiasusrTable;
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

        $(".buttonExport").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();			
			var idTable = $(this).data("id");
			var FLU_Id = $(this).data("flu");			
			var Tipo = $(this).data("tpo");
            var columns;
            columns = ["ID","Razón Social","RUT","DV","Año","Tipo Documento","Documento","Programa","Llamado","Línea","Garantía","Banco","Monto","Moneda","Emisión","Vencimiento","Estado","Detalle","Entrega","Estado Requerimiento","Versión"]

			wrk_informesgenerales("/prt-boletasdegarantias","/wrk-informesgenerales",'boletasdegarantias', columns, null, null, $("#REQ_Estado").val(),<%=session("wk2_usrid")%>,'<%=session("wk2_usrtoken")%>');            
		});	
				
	});
</script>