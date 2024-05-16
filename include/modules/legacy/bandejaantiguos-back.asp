<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<%
titulo="Requerimientos Archivados"
gradiente="aqua-gradient"
color="darkblue-text"

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
			<div class="content-nav">
				<a id="sistab1-tab" href="#sistab1" class="active tab" data-sis="1"><i class="fas fa-sitemap"></i> Sistema de Compras</a>
                <a id="sistab2-tab" href="#sistab2" class="active tab" data-sis="2"><i class="fas fa-sitemap"></i> Sistema WorkFlow v1</a>
				<span class="yellow-bar"></span>				
			</div>				
		</div>
	
		<!--tab-content-->
		<div class="tab-content">
            <div id="sistab1" data-sis="1">
                <!--wrapper-editor-->
                <div class="wrapper-editor">                    						
                    <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
                        <!-- Table with panel -->					
                        <div class="card card-cascade narrower">
                            <!--Card image-->
                            <div class="view view-cascade gradient-card-header <%=gradiente%> narrower py-2 mx-4 mb-3 d-flex justify-content-between align-items-center">
                                <div>									
                                </div>
                                <a href="" class="<%=color%> mx-3"><i class="fas fa-book"></i> Sistema de Compras (12/2010 al 05/2013)</a>
                                <div>
                                </div>                                
                            </div>
                            <!--/Card image-->
                            <div class="px-4">
                                <div class="table-wrapper col-sm-12 mCustomScrollbar" id="container-table-1">
                                    <!--Filtros-->
                                    <div class="row">
                                        <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
                                            <h5>Filtros</h5>
                                            <form role="form" method="POST" name="frmcompras" id="frmcompras" class="needs-validation" style="padding-bottom:20px">
                                                <div class="row">                                                
                                                    <div class="col-xs-12 col-sm-3 col-md-3 col-lg-3">                                                
                                                        <div class="md-form input-with-post-icon">
                                                            <div class="error-message">											
                                                                <div class="select">
                                                                    <select name="INFCompras_Mes" id="INFCompras_Mes" class="validate select-text form-control" required>
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
                                                                        <option value="-1">Todos</option>
                                                                    </select>							
                                                                    <i class="fas fa-map-marker-alt input-prefix"></i>
                                                                    <span class="select-highlight"></span>
                                                                    <span class="select-bar"></span>
                                                                    <label for="INFCompras_Mes" class="select-label">Mes Creación</label>
                                                                </div>	
                                                            </div>
                                                        </div>
                                                    </div>	
                                                    <div class="col-xs-12 col-sm-3 col-md-3 col-lg-3">
                                                        <div class="md-form input-with-post-icon">
                                                            <div class="error-message">											
                                                                <div class="select">
                                                                    <select name="INFCompras_Anio" id="INFCompras_Anio" class="validate select-text form-control" required>
                                                                        <option value="" selected disabled></option><%
                                                                        AnoDesde=2010
                                                                        AnoActual=2013
                                                                        do while AnoDesde<=AnoActual%>										
                                                                            <option value="<%=AnoDesde%>"><%=AnoDesde%></option><%									
                                                                            AnoDesde=AnoDesde+1
                                                                        loop%>
                                                                    </select>							
                                                                    <i class="fas fa-map-marker-alt input-prefix"></i>
                                                                    <span class="select-highlight"></span>
                                                                    <span class="select-bar"></span>
                                                                    <label for="INFCompras_Anio" class="select-label">Año Creación</label>
                                                                </div>	
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-xs-12 col-sm-3 col-md-3 col-lg-3">
                                                        <div class="md-form input-with-post-icon">
                                                            <div class="error-message">											
                                                                <div class="select"><%
                                                                    if(session("wk2_usrperfil")=4) then%>
                                                                        <select name="DEPCompras_Id" id="DEPCompras_Id" class="validate select-text form-control" required>
                                                                            <option value="" selected disabled></<option><%
                                                                            set rx = cnn.Execute("exec [spRelDependenciasSistemaxDepartamento_Consultar] " & session("wk2_usrdepid") & ", 1")
                                                                            on error resume next
                                                                            if rx.eof then%>
                                                                                <option value="">No existe unidad</option><%
                                                                            end if
                                                                            do while not rx.eof%>										
                                                                                <option value="<%=rx("id_dependencia")%>"><%=rx("descripcion")%></option><%
                                                                                rx.movenext
                                                                            loop%>                                                                            
                                                                        </select><%
                                                                    else%>
                                                                        <select name="DEPCompras_Id" id="DEPCompras_Id" class="validate select-text form-control" required>
                                                                            <option value="" selected disabled></<option><%
                                                                            set rx = cnn.Execute("exec [spDependenciasCompras_Listar]")
                                                                            on error resume next
                                                                            do while not rx.eof%>										
                                                                                <option value="<%=rx("id_dependencia")%>"><%=rx("descripcion")%></option><%
                                                                                rx.movenext
                                                                            loop%>
                                                                            <option value="-1">Todas</option>
                                                                        </select><%
                                                                    end if%>
                                                                    <i class="fas fa-map-marker-alt input-prefix"></i>
                                                                    <span class="select-highlight"></span>
                                                                    <span class="select-bar"></span>
                                                                    <label for="DEPCompras_Id" class="select-label">Departamento Creador</label>
                                                                </div>	
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-xs-12 col-sm-3 col-md-3 col-lg-3 align-self-end">
                                                        <button type="button" class="btn btn-primary btn-md waves-effect waves-dark" id="btn_frmcompras" name="btn_frmcompras" style="float: left;"><i class="fas fa-filter"></i> Aplicar Filtros</button>
                                                    </div>
                                                </div>
                                                <input type="hidden" id="SISCompras_Id" name="SISCompras_Id" value="1">
                                            </form>                                            
                                        </div>
                                    </div>
                                    <!--Table-->										
                                    <table id="tblreq-1" class="ts table table-striped table-bordered dataTable table-sm" cellspacing="0" data-id="1" style="width:99%">
                                        <thead>
                                            <tr>													
                                                <th>#</th>
                                                <th>Ver.</th>
                                                <th>Descripción Versión Requerimiento</th>													
                                                <th>#Req.</th>
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
            </div>
            <div id="sistab2" data-sis="2">
                <!--wrapper-editor-->
                <div class="wrapper-editor">						
                    <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">						
                        <!-- Table with panel -->					
                        <div class="card card-cascade narrower">
                            <!--Card image-->
                            <div class="view view-cascade gradient-card-header <%=gradiente%> narrower py-2 mx-4 mb-3 d-flex justify-content-between align-items-center">
                                <div>									
                                </div>
                                <a href="" class="<%=color%> mx-3"><i class="fas fa-book"></i> Sistema WorkFlow v1 (07/2013 - 04/2022)</a>
                                <div>
                                </div>
                            </div>
                            <!--/Card image-->
                            <div class="px-4">
                                <div class="table-wrapper col-sm-12 mCustomScrollbar" id="container-table-2">
                                    <!--Filtros-->
                                    <div class="row">
                                        <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
                                            <h5>Filtros</h5>
                                            <form role="form" method="POST" name="frmwrkflowv1" id="frmwrkflowv1" class="needs-validation" style="padding-bottom:20px">
                                                <div class="row">
                                                    <div class="col-xs-12 col-sm-2 col-md-2 col-lg-2">                                                
                                                        <div class="md-form input-with-post-icon">
                                                            <div class="error-message">											
                                                                <div class="select">
                                                                    <select name="INFWorkflowv1_Flu" id="INFWorkflowv1_Flu" class="validate select-text form-control" required>
                                                                        <option value="" selected disabled></option>
                                                                        <option value="1">Compras</option>
                                                                        <option value="2">Boletas<option>                                                                        
                                                                    </select>							
                                                                    <i class="fas fa-map-marker-alt input-prefix"></i>
                                                                    <span class="select-highlight"></span>
                                                                    <span class="select-bar"></span>
                                                                    <label for="INFWorkflowv1_Flu" class="select-label">Flujo</label>
                                                                </div>	
                                                            </div>
                                                        </div>
                                                    </div>	
                                                    <div class="col-xs-12 col-sm-2 col-md-2 col-lg-2">
                                                        <div class="md-form input-with-post-icon">
                                                            <div class="error-message">											
                                                                <div class="select">
                                                                    <select name="INFWorkflowv1_Mes" id="INFWorkflowv1_Mes" class="validate select-text form-control" required>
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
                                                                        <option value="-1">Todos</option>
                                                                    </select>							
                                                                    <i class="fas fa-map-marker-alt input-prefix"></i>
                                                                    <span class="select-highlight"></span>
                                                                    <span class="select-bar"></span>
                                                                    <label for="INFWorkflowv1_Mes" class="select-label">Mes Creación</label>
                                                                </div>	
                                                            </div>
                                                        </div>
                                                    </div>	
                                                    <div class="col-xs-12 col-sm-2 col-md-2 col-lg-2">
                                                        <div class="md-form input-with-post-icon">
                                                            <div class="error-message">											
                                                                <div class="select">
                                                                    <select name="INFWorkflowv1_Anio" id="INFWorkflowv1_Anio" class="validate select-text form-control" required>
                                                                        <option value="" selected disabled></option><%
                                                                        AnoDesde=2013
                                                                        AnoActual=2022
                                                                        do while AnoDesde<=AnoActual%>										
                                                                            <option value="<%=AnoDesde%>"><%=AnoDesde%></option><%									
                                                                            AnoDesde=AnoDesde+1
                                                                        loop%>
                                                                    </select>							
                                                                    <i class="fas fa-map-marker-alt input-prefix"></i>
                                                                    <span class="select-highlight"></span>
                                                                    <span class="select-bar"></span>
                                                                    <label for="INFWorkflowv1_Anio" class="select-label">Año Creación</label>
                                                                </div>	
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-xs-12 col-sm-3 col-md-3 col-lg-3">
                                                        <div class="md-form input-with-post-icon">
                                                            <div class="error-message">											
                                                                <div class="select"><%
                                                                    if(session("wk2_usrperfil")=4) then%>
                                                                        <select name="DEPWorkflowv1_Id" id="DEPWorkflowv1_Id" class="validate select-text form-control" required>
                                                                            <option value="" selected disabled></<option><%
                                                                            set rz = cnn.Execute("exec [spRelDependenciasSistemaxDepartamento_Consultar] " & session("wk2_usrdepid") & ", 2")
                                                                            on error resume next
                                                                            if rz.eof then%>
                                                                                <option value="">No existe unidad</option><%
                                                                            end if
                                                                            do while not rz.eof%>										
                                                                                <option value="<%=rz("Uni_Cod")%>"><%=rz("Uni_Des")%></option><%
                                                                                rz.movenext
                                                                            loop%>                                                                            
                                                                        </select><%
                                                                    else%>
                                                                        <select name="DEPWorkflowv1_Id" id="DEPWorkflowv1_Id" class="validate select-text form-control" required>
                                                                            <option value="" selected disabled></<option><%
                                                                            set rz = cnn.Execute("exec [spDependenciasWorkFlowv1_Listar]")
                                                                            on error resume next
                                                                            do while not rz.eof%>										
                                                                                <option value="<%=rz("Uni_Cod")%>"><%=rz("Uni_Des")%></option><%
                                                                                rz.movenext
                                                                            loop%>
                                                                            <option value="-1">Todas</option>
                                                                        </select><%
                                                                    end if%>
                                                                    <i class="fas fa-map-marker-alt input-prefix"></i>
                                                                    <span class="select-highlight"></span>
                                                                    <span class="select-bar"></span>
                                                                    <label for="DEPWorkflowv1_Id" class="select-label">Departamento Creador</label>
                                                                </div>	
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-xs-12 col-sm-2 col-md-2 col-lg-2 align-self-end">
                                                        <button type="button" class="btn btn-primary btn-md waves-effect waves-dark" id="btn_frmWorkflowv1" name="btn_frmWorkflowv1" style="float: left;"><i class="fas fa-filter"></i> Aplicar Filtros</button>
                                                    </div>
                                                </div>
                                                <input type="hidden" id="SISWorkflowv1_Id" name="SISWorkflowv1_Id" value="2">
                                            </form>                                            
                                        </div>
                                    </div>
                                    <!--Table-->										
                                    <table id="tblreq-2" class="ts table table-striped table-bordered dataTable table-sm" cellspacing="0" data-id="2" style="width:99%">
                                        <thead>
                                            <tr>													
                                                <th>#</th>
                                                <th>Ver.</th>
                                                <th>Descripción Versión Requerimiento</th>													
                                                <th>#Req.</th>
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
            </div>
		</div>
		<!--tab-content-->
	</div>
	<!--container-nav-->	
</div>
<!-- Formulario compras -->
<div class="modal fade in" id="formularioCompras" tabindex="-1" role="dialog" aria-labelledby="formularioCompras" aria-hidden="true">
	<div class="modal-dialog cascading-modal narrower modal-lg" role="document" style="max-height:600px"> 
    	<div class="modal-content">		
      		<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
        		<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-user"></i> Datos del requerimeinto (Compras)</div>				
      		</div>
			<form role="form" action="" method="POST" name="frmbtn_compras" id="frmbtn_compras" class="needs-validation" style="overflow-y:auto;max-height: 600px;">
			</form>
		</div>
	</div>
</div>
<!-- Formulario compras -->
<!-- Formulario workflowv1 -->
<div class="modal fade in" id="formularioWorkFlowv1" tabindex="-1" role="dialog" aria-labelledby="formularioWorkFlowv1" aria-hidden="true">
	<div class="modal-dialog cascading-modal narrower modal-lg" role="document" style="max-height:600px">  		
    	<div class="modal-content">		
      		<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
        		<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-user"></i> Datos del formulario (WorkFlowv1)</div>				
      		</div>
			<form role="form" action="" method="POST" name="frmbtn_workflowv1" id="frmbtn_workflowv1" class="needs-validation" style="overflow-y:auto;max-height: 600px;">
			</form>
		</div>
	</div>
</div>
<!-- Formulario workflowv1 -->
<!-- Datos workflowv1 -->
<div class="modal fade in" id="datosWorkFlowv1" tabindex="-1" role="dialog" aria-labelledby="datosWorkFlowv1" aria-hidden="true">
	<div class="modal-dialog cascading-modal narrower modal-lg" role="document" style="max-height:600px">  		
    	<div class="modal-content">		
      		<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
        		<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-user"></i> Datos del requerimeinto (WorkFlowv1)</div>				
      		</div>
			<form role="form" action="" method="POST" name="frmbtn_datosworkflowv1" id="frmbtn_datosworkflowv1" class="needs-validation" style="overflow-y:auto;max-height: 600px;">
			</form>
		</div>
	</div>
</div>
<!-- Datos workflowv1 -->
<script>
//bandeja antiguos
    $(function () {
		$('[data-toggle="tooltip"]').tooltip({
			trigger : 'hover'
		})
		$('[data-toggle="tooltip"]').on('click', function () {
			$(this).tooltip('hide')
		})		
	});
    $(document).ready(function() {
        var b = String.fromCharCode(92);
		var bb = String.fromCharCode(92) + String.fromCharCode(92);
		var ss = String.fromCharCode(47) + String.fromCharCode(47);	
		var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);
		
        var titani = setInterval(function(){				
            $("h5").slideDown("slow",function(){
                $("h6").slideDown("slow",function(){                   
                    clearInterval(titani)
                });
            })
        },2300);

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
		
        var requerimientosComprasTable;
        var requerimientosWorkFlowv1Table;
        $('#tblreq-1, #tblreq-2').DataTable({
            lengthMenu: [ 10,15,20 ],
            columnDefs: [{
                "targets": [2,4,6,8,10,11,14,15,16,18,19,20,22,23,24,26,27,29,30,31,32,34,39],
                "visible": false,
                "searchable": false,
                },{
                "targets": [0,2,3,6,9,12,15,18],"width":"20px"
                },{
                "targets": [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39],
                "orderable": false
                },{
                "targets": [5],"width":"300px"
                }
            ],
            autoWidth: false,
        })                

		function tableRequerimientos(data){            
            if(data.SIS_Id==1){
                var url='/formulario-compras'
                var frmid="#frmbtn_compras"
                var modalid="#formularioCompras"
            }
            if(data.SIS_Id==2){
                var url='/formulario-workflowv1'
                var frmid="#frmbtn_workflowv1"
                var modalid="#formularioWorkFlowv1"
            }
			$("#tblreq-" + data.SIS_Id).dataTable().fnDestroy();
			requerimientosTable = $('#tblreq-' + data.SIS_Id).DataTable({
				lengthMenu: [ 10,15,20 ],
				processing: true,
        		serverSide: true,
				ajax:{
					url:"/requerimientos-antiguos",
                    data:data,
					type:"POST",					
					dataSrc:function(json){					
						return json.data;					
					}
				},
                dom: 'lBfrtip',
            	buttons: [					
					$.extend( true, {}, buttonCommon, {
						extend: 'excelHtml5',
                        data: data
					}),					
				],
				columnDefs: [{
					"targets": [2,4,6,8,10,11,14,15,16,18,19,20,22,23,24,26,27,29,30,31,32,34,39],
					"visible": false,
					"searchable": false,
					},{
					"targets": [0,2,3,6,9,12,15,18],"width":"20px"					
					},{
					"targets": [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39],
					"orderable": false
					},{
                    "targets": [5],"width":"300px"
                    }
				],
				autoWidth: false,
				fnRowCallback: function( nRow, aData, iDisplayIndex, iDisplayIndexFull ) {					
					$("td:not(:last)",nRow).click(function(e){
						e.preventDefault();
						e.stopImmediatePropagation();
						e.stopPropagation();						
						
						var Req_cod=aData[0];
                        var FrD_Cor=aData[13];
                        var For_Cod=aData[14];
                        var For_Cor=aData[8];                        

						$.ajax( {
							type:'POST',					
							url: url,
							data: {Req_cod:Req_cod, FrD_Cor:FrD_Cor, For_Cod:For_Cod, For_Cor:For_Cor},
							success: function ( data ) {
								param = data.split(sas)
								if(param[0]==200){
                                    
									$(frmid).html(param[1]);
									$(modalid).modal("show")
								}
							},
							error: function(XMLHttpRequest, textStatus, errorThrown){

							}
						});	
                        
					});
					
				}
			});
		}	

        $("#btn_frmcompras").click(function(e){
            e.preventDefault();
            e.stopImmediatePropagation();
            e.stopPropagation();
            
            formValidate("#frmcompras")
			if($("#frmcompras").valid()){
                var Mes = $("#INFCompras_Mes").val();
                var Anio = $("#INFCompras_Anio").val();
                var Sis = $("#SISCompras_Id").val();
                var Dep = $("#DEPCompras_Id").val();
                var data = {SIS_Id: Sis, INF_Mes: Mes, INF_Anio: Anio, DEP_Id:Dep}
                tableRequerimientos(data)
            }
        })

        $("#btn_frmWorkflowv1").click(function(e){
            e.preventDefault();
            e.stopImmediatePropagation();
            e.stopPropagation();
            
            formValidate("#frmwrkflowv1")
			if($("#frmwrkflowv1").valid()){
                var Flu = $("#INFWorkflowv1_Flu").val();
                var Mes = $("#INFWorkflowv1_Mes").val();
                var Anio = $("#INFWorkflowv1_Anio").val();
                var Sis = $("#SISWorkflowv1_Id").val();
                var Dep = $("#DEPWorkflowv1_Id").val();                
                var data = {FLU_Id:Flu, SIS_Id: Sis, INF_Mes: Mes, INF_Anio: Anio, DEP_Id:Dep}
                tableRequerimientos(data)
            }
        })

		$(".content-nav").tabsmaterialize({},function(){				
		});	

        jQuery.fn.DataTable.Api.register( 'buttons.exportData()', function ( options ) {            
            if ( this.context.length ) {
                var tableid=this.context[0].sTableId;
                if(tableid=='tblreq-1'){
                    var Mes = $("#INFCompras_Mes").val();
                    var Anio = $("#INFCompras_Anio").val();
                    var Sis = $("#SISCompras_Id").val();
                    var data = {SIS_Id: Sis, INF_Mes: Mes, INF_Anio: Anio, start:0}  
                }
                if(tableid=='tblreq-2'){
                    var Flu = $("#INFWorkflowv1_Flu").val();
                    var Mes = $("#INFWorkflowv1_Mes").val();
                    var Anio = $("#INFWorkflowv1_Anio").val();
                    var Sis = $("#SISWorkflowv1_Id").val();
                    var data = {FLU_Id:Flu, SIS_Id: Sis, INF_Mes: Mes, INF_Anio: Anio, start:0}
                }
				var row = [];
                var jsonResult = $.ajax({
                    url:"/requerimientos-antiguos",
                    data: data,
                    success: function (result) {
                        //Do nothing
                    },
                    async: false,
					type:"POST"
                });				
				$("#tblreq-1").DataTable().columns().header().each(function(e,i){
					row.push(e.innerText.replace(/(\r\n|\n|\r)/gm, ""))
				});
                $("#tblreq-2").DataTable().columns().header().each(function(e,i){
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

        $('body').on('click','.dowadj', function () {
            var INF_Arc;
            var SIS_Id;
            var arc;
            INF_Arc = $(this).data("arc");
            SIS_Id = $(this).data("sis");
            arc = INF_Arc.split('/');            
            $.ajax({
                url: '/bajar-archivo',
                data:{INF_Arc:INF_Arc, SIS_Id:SIS_Id},
                method: 'POST',
                xhrFields: {
                    responseType: 'blob'
                },
                success: function (data) {
                    var a = document.createElement('a');
                    var url = window.URL.createObjectURL(data);
                    a.href = url;
                    a.download = arc[1];
                    document.body.append(a);
                    a.click();
                    a.remove();
                    window.URL.revokeObjectURL(url);
                }
            });
        });

        $('body').on('click','.reqdata', function () {
            var Req_cod;                        
            Req_cod = $(this).data("req");                        

            $.ajax( {
                type:'POST',					
                url: "/datos-workflowv1",
                data: {Req_cod:Req_cod},
                success: function ( data ) {
                    param = data.split(sas)
                    if(param[0]==200){                        
                        $("#frmbtn_datosworkflowv1").html(param[1]);
			            $("#datosWorkFlowv1").modal("show")
                    }
                },
                error: function(XMLHttpRequest, textStatus, errorThrown){

                }
            });	            
        });

        $('body').on('click','.downcer', function () {
            var Req_cod;                        
            Req_cod = $(this).data("req");            
            $.ajax( {
                type:'POST',					
                url: "/genera-informe-pdf-legacy",
                data: {Req_cod:Req_cod, INF_Id:1},
                success: function ( data ) {
					var param = data.split(sas)
					if(param[0]=="200"){						
                        $("body").append("<div id='pry-reportpdf'></div>")							
                        $("#pry-reportpdf").html(param[1]);
                        //$("#pry-reportpdf").remove();
                        ajax_icon_handling('load','Buscando informes','','');
                        var waitfld = setInterval(function(){                            
                            $.ajax({
                                type: 'POST',								
                                url:'/lista-informes-legacy',				
                                data:{INF_Id:1,Req_cod:Req_cod},
                                success: function(data) {
                                    var param=data.split(bb);			
                                    if(param[0]=="200"){				
                                        ajax_icon_handling(true,'Listado de informes creado.','',param[1]);
                                        $(".swal2-popup").css("width","60rem");
                                        loadtables("#tbl-" + param[1]);
                                        $(".arcinf").click(function(){
                                            var INF_Arc = $(this).data("file");							
                                            var data = {INF_Id:1,Req_cod:Req_cod,INF_Arc:INF_Arc};
                                            
                                            $.ajax({
                                                url: "/bajar-archivo-legacy",
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
                                        ajax_icon_handling(false,'No fue posible crear el listado de informes.','','');
                                    }						
                                },
                                error: function(XMLHttpRequest, textStatus, errorThrown){				
                                    ajax_icon_handling(false,'No fue posible crear el listado de informes.','','');	
                                },
                                complete: function(){																		
                                }
                            })
                            clearInterval(waitfld)
                        },3000)
                    }
                },
                error: function(XMLHttpRequest, textStatus, errorThrown){

                }
            });	              
        });

        $('body').on('click','.downdoc', function () {
            var Req_cod;                        
            Req_cod = $(this).data("req");
            var INF_Id = $(this).data("inf");
            $.ajax( {
                type:'POST',					
                url: "/genera-informe-pdf-legacy",
                data: {Req_cod:Req_cod, INF_Id:INF_Id},
                success: function ( data ) {
					var param = data.split(sas)
					if(param[0]=="200"){						
                        $("body").append("<div id='pry-reportpdf'></div>")							
                        $("#pry-reportpdf").html(param[1]);
                        $("#pry-reportpdf").remove();
                        ajax_icon_handling('load','Buscando informes','','');
                        var waitfld = setInterval(function(){                            
                            $.ajax({
                                type: 'POST',								
                                url:'/lista-informes-legacy',				
                                data:{INF_Id:INF_Id,Req_cod:Req_cod},
                                success: function(data) {
                                    var param=data.split(bb);			
                                    if(param[0]=="200"){				
                                        ajax_icon_handling(true,'Listado de informes creado.','',param[1]);
                                        $(".swal2-popup").css("width","60rem");
                                        loadtables("#tbl-" + param[1]);
                                        $(".arcinf").click(function(){
                                            var INF_Arc = $(this).data("file");							
                                            var data = {INF_Id:INF_Id,Req_cod:Req_cod,INF_Arc:INF_Arc};
                                            
                                            $.ajax({
                                                url: "/bajar-archivo-legacy",
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
                                        ajax_icon_handling(false,'No fue posible crear el listado de informes.','','');
                                    }						
                                },
                                error: function(XMLHttpRequest, textStatus, errorThrown){				
                                    ajax_icon_handling(false,'No fue posible crear el listado de informes.','','');	
                                },
                                complete: function(){																		
                                }
                            })
                            clearInterval(waitfld)
                        },3000)
                    }
                },
                error: function(XMLHttpRequest, textStatus, errorThrown){

                }
            });	              
        });
    })
</script>