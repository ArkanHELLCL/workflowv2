<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%
    splitruta=split(ruta,"/")    
	xm=splitruta(5)
    DRE_Id=splitruta(7)
    
	if(xm="modificar") then
		modo=2	
		required="required"
	end if
	if(xm="visualizar") or (session("ds5_usrperfil")=5) then
		modo=4	
		required="disabled"
	end if
    if(modo="") then
        modo=4
    end if
    INF_Id=request("INF_Id")        'Para crear un nuevo certificado de disponibilidad
    if(INF_Id="" or INF_Id=0) then
        INF_Id=0                       
    end if
    accion="Modificación"    
    VCE_Id=request("VCE_Id")        'Para cuando se solicita modificar la version del certificado de disponibilidad.
    if(VCE_Id="" or VCE_Id=0) then
        VCE_Id=0                    'Creación
        accion="Creación"
    end if    

    if(IsNULL(DRE_Id) or DRE_Id="") then
        response.write("404//ERROR: No fue posible encontrar registro de DatosRequerimiento")
        response.end()
    end if
    'FLD_IdInforme=request("FLD_IdInforme")
    'if(IsNULL(FLD_IdInforme) or FLD_IdInforme="") then
    '    response.write("404//ERROR: No fue posible encontrar registro del informe")
    '    response.end()
    'end if
    set cnn = Server.CreateObject("ADODB.Connection")
    on error resume next	
    cnn.open session("DSN_WorkFlowv2")
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description	   
        cnn.close
        response.Write("503//Error Conexión 1:" & ErrMsg)
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
    End If
    if not rs.eof then
        FLD_Id=rs("FLD_Id")
        FLD_Prioridad = rs("FLD_Prioridad")
        DEP_IdActual = rs("DEP_IdActual")
        VFL_Id=rs("VFL_Id")
        DepDescripcionOrigen=rs("DepDescripcionOrigen")
        REQ_Id=rs("REQ_Id")
        VRE_Id=rs("VRE_Id")
        IdEditor=rs("IdEditor")
        FLU_Id=rs("FLU_Id")
    end if     
    ESR_Estado="Pendiente de Creación"
    DEP_Descripcion=session("wk2_usrdepcorta")
    if(VCE_Id=0) then
        sql="exec spInformes_Consultar " & INF_Id
        set rs = cnn.Execute(sql)
        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description
            response.write("Error [spInformes_Consultar]")
            cnn.close 		
            response.end
        End If
        if not rs.eof then
            INF_Descripcion = rs("INF_Descripcion")
            FLD_IdInforme = rs("FLD_Id")
        end if
    else
        sql="exec spVersionCertificado_Consultar " & VCE_Id
        set rs = cnn.Execute(sql)
        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description
            response.write("Error [spInformes_Consultar]")
            cnn.close 		
            response.end
        End If
        if not rs.eof then
            INF_Descripcion = rs("INF_Descripcion")
            VCE_Glosa=rs("VCE_Glosa")
            FLD_IdInforme=rs("FLD_Id")
            ESR_Estado=rs("ESR_DescripcionVersionCertificado")
            DEP_Descripcion=rs("DEP_Descripcion")
        end if        
    end if

    'Preguntar si el perfil actual tiene permiso para el flujo actual
    FLU_IdPerfil=false
    tl="exec [spUsuarioVersionFlujo_Listar] 1," & session("wk2_usrid")       'Todos flujos asociados al usuario actual
    set tr = cnn.Execute(tl)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error [spUsuarioVersionFlujo_Listar]")
		cnn.close 		
		response.end
	End If	
    do while not tr.eof
        if(FLU_Id=tr("FLU_Id")) then
            'tiene asignado este flujo
            FLU_IdPerfil=true
            exit do
        end if
        tr.movenext
    loop

    if((session("wk2_usrid")=IdEditor) and (FLD_IdInforme=FLD_Id) or (session("wk2_usrid")=IdEditor and session("wk2_usrperfil")=1) or (session("wk2_usrid")=IdEditor and session("wk2_usrperfil")=2 and FLU_IdPerfil)) and VCE_Id=0 then
        readonly=false
    else
        readonly=true
        accion="Visualizar"
    end if

    response.write("200//")%>

    <form role="form" action="" method="POST" name="frmInformesadd" id="frmInformesadd" class="form-signin needs-validation" style="padding-left: 30px;">		
		<h5>Informe : <%=INF_Descripcion%></h5>        
		<h6>Ingreso de información (<%=accion%>)</h6>
        <h6>Estado : <%=ESR_Estado%></h6>
        <h6>Departamento Solicitante : <%=DEP_Descripcion%></h6><%
        if not readonly then%>
            <div class="row">
                <div class="col-sm-12 col-md-6 col-lg-6">
                    <div class="md-form input-with-post-icon">
                        <div class="error-message">
                            <i class="fas fa-dollar-sign input-prefix"></i>
                            <input type="text" class="form-control suggestions" id="vis-ILD_Id" name="vis-ILD_Id" value="<%=rw("ILD_Descripcion")%>" <%=disabled%> data-url="/listar-items-json" data-prm1="11">
                            <i class="fas fa-search"></i>
                            <span class="select-bar"></span>
                            <label for="DCE_Monto" class="select-label">Imputación</label>
                            <input type="hidden" id="ILD_Id" name="ILD_Id" value="">
                        </div>
                    </div>
                </div>
                <div class="col-sm-12 col-md-2 col-lg-2">
                    <div class="md-form input-with-post-icon">
                        <div class="error-message">                        
                            <i class="fas fa-dollar-sign input-prefix"></i>
                            <input type="number" id="DCE_Monto" name="DCE_Monto" class="form-control" required value="">                            
                            <span class="select-bar"></span>                        
                            <label for="DCE_Monto" class="select-label">Monto</label>
                        </div>
                    </div>
                </div>

                <div class="col-sm-12 col-md-2 col-lg-2">
                    <div class="md-form input-with-post-icon">
                        <div class="error-message">                        
                            <i class="fas fa-dollar-sign input-prefix"></i>
                            <input type="number" id="PRE_PresupuestoAsignado" name="PRE_PresupuestoAsignado" class="form-control" required value="">                            
                            <span class="select-bar"></span>
                            <label for="PRE_PresupuestoAsignado" class="select-label">Presupuesto Asignado</label>                        
                        </div>
                    </div>
                </div>
                <div class="col-sm-12 col-md-2 col-lg-2">
                    <div class="md-form input-with-post-icon">
                        <div class="error-message">                        
                            <i class="fas fa-dollar-sign input-prefix"></i>
                            <input type="number" id="PRE_PresupuestoComprometido" name="PRE_PresupuestoComprometido" class="form-control" required value="">                            
                            <span class="select-bar"></span>
                            <label for="PRE_PresupuestoComprometido" class="select-label">Presupuesto Compremitido</label>                        
                        </div>
                    </div>
                </div>
            </div><%
        end if%>
        <div class="row">
            <div class="col-sm-12 col-md-10 col-lg-10">
                <div class="md-form input-with-post-icon">
                    <div class="error-message">                        
                        <i class="fas fa-edit prefix"></i><%
                        if(session("wk2_usrperfil")<>5 and not readonly) then%>
                            <textarea id="VCE_Glosa" name="VCE_Glosa" class="md-textarea form-control" rows="3"><%=VCE_Glosa%></textarea>
                            <span class="select-bar"></span><%
                        else%>
                            <textarea id="VCE_Glosa" name="VCE_Glosa" class="md-textarea form-control" rows="3" readonly><%=VCE_Glosa%></textarea>
                            <span class="select-bar"></span><%
                        end if
                        if(trim(VCE_Glosa)<>"") then%>
                            <label for="VCE_Glosa" class="select-label active">Glosa</label><%
                        else%>
                            <label for="VCE_Glosa" class="select-label">Glosa</label><%
                        end if%>
                    </div>
                </div>
            </div>
            <div class="col align-self-end" style="top:-20px">
                <button type="button" class="btn btn-danger btn-md waves-effect waves-dark" id="btn_salirinformes" name="btn_salirinformes" style="float:right;"><i class="fas fa-sign-out-alt"></i></button><%
                if(session("wk2_usrperfil")<>5 and not readonly) then%>
                    <button type="button" class="btn btn-success btn-md waves-effect waves-dark" id="btn_frm10s4_1" name="btn_frm10s4_1" style="float: right;"><i class="fas fa-plus"></i></button><%
                end if%>
            </div>
        </div>
        
        <h6 style="padding-top:20px;padding-bottom:20px">Imputaciones ingresadas</h6>
        <div class="row"> 		
            <div class="col-12" style="overflow: auto;">
                <table id="tbl-imputaciones" class="ts table table-striped table-bordered dataTable table-sm" data-id="imputaciones" data-page="true" data-selected="true" data-keys="1"> 
                    <thead> 
                        <tr>
                            <td>id</td>
                            <td>Imputación</td>
                            <td>Monto</td>
                            <td>Comprometido</td>
                            <td>Asignado</td>
                            <td>Presupuesto Asignado</td>
                            <td>Presupuesto Compremitido</td>
                            <td>Creador</td>
                            <td>Fecha</td>
                            <td>Acciones</td>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
        <input type="hidden" name="VCE_Id" id="VCE_Id" value="<%=VCE_Id%>">
        <input type="hidden" name="INF_Id" id="INF_Id" value="<%=INF_Id%>">
        <input type="hidden" name="REQ_Id" id="REQ_Id" value="<%=REQ_Id%>">
    </form>

    <script>
        var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);
        var imputacionesTable;        
        var VCE_Id=<%=VCE_Id%>;        

        $("#frmInformesadd")[0].reset();
        loadTableImputaciones();        
        function loadTableImputaciones(){			
			if($.fn.DataTable.isDataTable( "#tbl-imputaciones")){				
				if(imputacionesTable!=undefined){
					imputacionesTable.destroy();
				}else{
					$('#tbl-imputaciones').dataTable().fnClearTable();
    				$('#tbl-imputaciones').dataTable().fnDestroy();
				}
			}
			imputacionesTable = $('#tbl-imputaciones').DataTable({
				lengthMenu: [ 5,10,20 ],
				ajax:{
					url:"/imputaciones-certificado",
					type:"POST",					
                    data: function (d) {
                        d.VCE_Id = VCE_Id;
                    }
				},				
				fnRowCallback: function( nRow, aData, iDisplayIndex, iDisplayIndexFull ) {					
					$("td:not(:last)",nRow).click(function(e){												
					})
				},
				order:[0,"asc"]
			});
            $("#tbl-imputaciones").css("width","100%");
		}

        $("#ILD_Id").on("click",function(e){
            e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();

            var ILD_Id = $("#ILD_Id").val();
            $.ajax({
                type:'POST',					
                url: '/consulta-presupuesto',
                data:{ILD_Id:ILD_Id},					
                success: function ( data ) {
                    var param = data.split(sas)
                    if(param[0]==200){                                                
                        if(param[1]!=""){
                            $("#PRE_PresupuestoAsignado").val(param[1]);
                            $("#PRE_PresupuestoAsignado").siblings("label").addClass("active");
                        }
                        if(param[2]!=""){
                            $("#PRE_PresupuestoComprometido").val(param[2]);
                            $("#PRE_PresupuestoComprometido").siblings("label").addClass("active");
                        }
                    }
                }
            });
        })

        $("#tbl-imputaciones").on("click",".delimp",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();

            swalWithBootstrapButtons.fire({
                title: 'Eliminar Imputación',
                text: "¿Deseas eliminar esta imputación?",
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: '<i class="fas fa-thumbs-up"></i> Si',
                cancelButtonText: '<i class="fas fa-thumbs-down"></i> No'
            }).then((result) => {
                if (result.value) {                    
                    var DCE_Id=$(this).data("dce");
                    $.ajax({
                        type:'POST',					
                        url: '/eliminar-imputacion-certificado',
                        data:{DCE_Id:DCE_Id},					
                        success: function ( data ) {
                            var param = data.split(sas)
                            if(param[0]==200){
                                imputacionesTable.ajax.reload();
                                Toast.fire({
                                    icon: 'success',
                                    title: 'Imputación eliminada correctamente'
                                });
                            }else{
                                swalWithBootstrapButtons.fire({
                                    icon:'error',								
                                    title: 'ERROR: No fue posible eliminar la imputación.',
                                    text:param[1]
                                });
                            }
                        }
                    });
                }
            })
            
        })

        $("#btn_frm10s4_1").on("click",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();

            formValidate("#frmInformesadd");
            if($("#frmInformesadd").valid()){
                var data = $("#frmInformesadd").serializeArray();               	
                $.ajax({
                    type:'POST',					
                    url: '/ingreso-certificado-disponibilidad',
                    data:data,					
                    success: function ( data ) {
                        var param = data.split(sas)                                                
                        if(param[0]=="200"){       
                            VCE_Id=param[1];
                            var DCE_Id=param[2];
                            $("#VCE_Id").val(VCE_Id);                     
                            imputacionesTable.ajax.reload();
                            var VCE_Glosa=$("#VCE_Glosa").val();
                            $("#frmInformesadd")[0].reset();
                            $("#VCE_Glosa").val(VCE_Glosa);
                            Toast.fire({
                                icon: 'success',
                                title: 'Imputación agregada correctamente'
                            });			
                        }else{
                            swalWithBootstrapButtons.fire({
                                icon:'error',								
                                title: 'ERROR: No fue posible crear el certificado.',
                                text:param[1]
                            });
                        }
                    }
                })
            }
        })
                
        $('#vis-ILD_Id').autocomplete({
            delay: 250	,
            minLength: 1,			
            source: function (request, response) {				
                $.ajax({
                    url: $(this.element).data("url"),
                    type: "POST",
                    dataType: "json",
                    data: { prm1 : $(this.element).data("prm1"), search: request.term },
                    success: function (data) {						
                        response($.map(data.data, function (el, val) {							
                            return {								
                                label:el,
                                value:el,
                                data:val
                            };
                        }));
                    },
                    error: function (xhr, status, error) {
                        console.log(error);
                    }
                });
            },			
            select: function( event, ui ) {	
                var id = $(this).attr("id").replace("vis-","");
                if(ui.item!=null){					
                    $("#vis-" + id).val(ui.item.value);
                }
                return false;
            },
            change: function( event, ui ) {				
                var id = $(this).attr("id").replace("vis-","");
                if(ui.item!=null){
                    $("#" + id).val(ui.item.data);
                    $("#vis-" + id).val(ui.item.value);					
                }else{
                    $("#" + id).val("");
                    $("#vis-"+ id).val("")
                    $("#vis-"+ id).removeClass("is-valid")
                    $("#vis-"+ id).removeClass("is-invalid")
                    $("#vis-"+ id).removeClass("valid")
                    $("#vis-"+ id).siblings().removeClass("active")
                }				
                return false;
            },
            focus: function(event, ui ){
                var id = $(this).attr("id").replace("vis-","");
                if(ui.item!=null){					
                    $("#vis-" + id).val(ui.item.value);
                }
                return false;
            }			
        });
        
    </script>