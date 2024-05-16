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
    INF_Id=request("INF_Id")        'Para crear una nueva providencia
    if(INF_Id="" or INF_Id=0) then
        INF_Id=0                       
    end if
    accion="Modificación"    
    VPV_Id=request("VPV_Id")        'Para cuando se solicita modificar la version de la providencia
    if(VPV_Id="" or VPV_Id=0) then
        VPV_Id=0                    'Creación
        accion="Creación"
    end if    

    if(IsNULL(DRE_Id) or DRE_Id="") then
        response.write("404//ERROR: No fue posible encontrar registro de DatosRequerimiento")
        response.end()
    end if    
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
        REQ_FechaEdit = mid(rs("REQ_FechaEdit"),1,10)

        VPV_FechaPago = "WFP-" & VRE_Id & "/" & REQ_FechaEdit
    end if     
    ESR_Estado="Pendiente de Creación"
    DEP_Descripcion=session("wk2_usrdepcorta")
    if(VPV_Id=0) then
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
        sql="exec spVersionProvidencia_Consultar " & VPV_Id
        set rs = cnn.Execute(sql)
        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description
            response.write("Error [spVersionProvidencia_Consultar]")
            cnn.close 		
            response.end
        End If        
        if not rs.eof then
            INF_Descripcion = rs("INF_Descripcion")
            'VPV_Glosa=rs("VPV_Glosa")
            FLD_IdInforme=rs("FLD_Id")
            ESR_Estado=rs("ESR_DescripcionVersionProvidencias")
            'DEP_Descripcion=rs("DEP_Descripcion")
        end if

        sqy="exec [spDetalleProvidencia_Listar] 1, " & VPV_Id
        set ry = cnn.Execute(sqy)
        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description
            response.write("Error [spVersionProvidencia_Consultar]")
            cnn.close 		
            response.end
        End If        
        if not ry.eof then
            DPV_SaldoInicial=FormatNumber(ry("DPV_SaldoInicial"),0)
            DPV_SaldoConsumido=FormatNumber(ry("DPV_SaldoConsumido"),0)
            DPV_SaldoActual=FormatNumber(ry("DPV_SaldoActual"),0)
            'DPV_Observacioens=ry("DPV_Observacioens")
            DPV_FolioAltaBien=ry("DPV_FolioAltaBien")
            DPV_ResolucionDecreto=ry("DPV_ResolucionDecreto")
            DPV_Factoring=ry("DPV_Factoring")
            DPV_ResolucionDecretoNumero=ry("DPV_ResolucionDecretoNumero")
            DPV_FolioAltaBienNumero=ry("DPV_FolioAltaBienNumero")
            DPV_FactoringNombre=ry("DPV_FactoringNombre")
        end if        
    end if

    'Departamento Solicitante SSGG(10)
    sql="exec spDepartamento_Consultar 10" 
    set rs = cnn.Execute(sql)
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description
        response.write("Error [spVersionProvidencia_Consultar]")
        cnn.close 		
        response.end
    End If        
    if not rs.eof then
        DEP_Descripcion=rs("DEP_Descripcion")
    end If

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

    xs="exec spDatosFormularioxVersion_Consultar " & DRE_Id & ",-1"
    set tr = cnn.Execute(xs)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error [spDatosFormularioxVersion_Consultar]")
		cnn.close 		
		response.end
	End If	
    do while not tr.eof
        if(INF_Id = 11) then
            if(tr("FDI_Id")=79) then
                xy = "exec spProveedores_Consultar " & CInt(tr("DFO_Dato"))
                set tz = cnn.Execute(xy)
                on error resume next
                if not tz.eof then
                    PRO_RazonSocial=tz("PRO_RazonSocial")                    
                    Rut=FormatNumber(tz("PRO_Rut"),0)
                    PRO_Dv=tz("PRO_Dv")
                    PRO_Rut = Rut & "-" & PRO_Dv
                end if
            end if
            if(tr("FDI_Id")=81) then
                VPV_OC=tr("DFO_Dato")
            end if
            if(tr("FDI_Id")=83) then
                VPV_Monto="$ " & FormatNumber(tr("DFO_Dato"),0)
            end if
            if(tr("FDI_Id")=98) then
                VPV_FolioCompromiso=tr("DFO_Dato")
            end if
        else
            if(INF_Id = 12) then
                if(tr("FDI_Id")=105) then
                    xy = "exec spProveedores_Consultar " & CInt(tr("DFO_Dato"))
                    set tz = cnn.Execute(xy)
                    on error resume next
                    if not tz.eof then
                        PRO_RazonSocial=tz("PRO_RazonSocial")                    
                        Rut=FormatNumber(tz("PRO_Rut"),0)
                        PRO_Dv=tz("PRO_Dv")
                        PRO_Rut = Rut & "-" & PRO_Dv
                    end if
                end if
                if(tr("FDI_Id")=107) then
                    VPV_OC=tr("DFO_Dato")
                end if
                if(tr("FDI_Id")=109) then
                    VPV_Monto="$ " & FormatNumber(tr("DFO_Dato"),0)
                end if
                if(tr("FDI_Id")=124) then
                    VPV_FolioCompromiso=tr("DFO_Dato")
                end if
            end if
        end if
        tr.movenext
    loop


    if((session("wk2_usrid")=IdEditor) and (FLD_IdInforme=FLD_Id) or (session("wk2_usrid")=IdEditor and session("wk2_usrperfil")=1) or (session("wk2_usrid")=IdEditor and session("wk2_usrperfil")=2 and FLU_IdPerfil)) and VPV_Id=0 then
        readonly=false
        required="required"
        disabled=""
        tipo="number"
    else
        readonly=true
        accion="Visualizar"
        required="readonly"
        disabled="disabled"
        tipo="text"
    end if

    response.write("200//")%>

    <form role="form" action="" method="POST" name="frmProvidenciaadd" id="frmProvidenciaadd" class="form-signin needs-validation" style="padding-left: 30px;">
		<h5>Informe : <%=INF_Descripcion%></h5>        
		<h6>Ingreso de información (<%=accion%>)</h6>
        <h6>Estado : <%=ESR_Estado%></h6>
        <h6>Departamento Solicitante : <%=DEP_Descripcion%></h6>
        <div style="display:flex;padding-top:20px;gap:20px;width:80%;margin:auto">
            <table class="table table-bordered table-sm" style="width: 50%;margin:auto;text-align:center">
                <tbody>
                    <tr>
                        <td>Nombre Proveedor</td>
                        <td><%=PRO_RazonSocial%></td>                        
                    </tr>
                    <tr>
                        <td>RUT Proveedor</td>
                        <td><%=PRO_Rut%></td>                        
                    </tr>
                    <tr>
                        <td>Monto</td>
                        <td><%=VPV_Monto%></td>
                    </tr>
                    <tr>
                        <td>Doc. autoriza Pago</td>
                        <td><%=VPV_FechaPago%></td>
                    </tr>
                    <tr>
                        <td>Orden de compra</td>
                        <td><%=VPV_OC%></td>
                    </tr>
                    <tr>
                        <td>Folio compromiso</td>
                        <td><%=VPV_FolioCompromiso%></td>
                    </tr>
                    <tr>
                        <td>Saldo inicial</td>
                        <td style="display:flex; align-items: center;">
                            <span style="padding-right:10px;">$</span>
                            <input type="<%=tipo%>" id="DPV_SaldoInicial" name="DPV_SaldoInicial" class="form-control" <%=required%> value="<%=DPV_SaldoInicial%>">
                        </td>
                    </tr>
                </tbody>    
            </table>
            <table class="table table-bordered table-sm" style="width: 50%;margin:auto;text-align:center">
                <tbody>
                    <tr>
                        <td>Saldo consumido</td>
                        <td colspan="2">
                            <div style="display:flex; align-items: center;">
                                <span style="padding-right:10px;">$</span>
                                <input type="<%=tipo%>" id="DPV_SaldoConsumido" name="DPV_SaldoConsumido" class="form-control" <%=required%>  value="<%=DPV_SaldoInicial%>">
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>Saldo actual</td>
                        <td colspan="2">
                            <div style="display:flex; align-items: center;">
                                <span style="padding-right:10px;">$</span>
                                <input type="<%=tipo%>" id="DPV_SaldoActual" name="DPV_SaldoActual" class="form-control" <%=required%> value="<%=DPV_SaldoInicial%>">
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th>Autorización de Compra</th>
                        <th>No aplica</th>
                        <th>N°/Nombre</th>
                    </tr>
                    <tr>
                        <td>Resolución/Decreto</td>                            
                        <td>                                
                            <div class="rkmd-checkbox checkbox-rotate checkbox-ripple">
                                <label class="input-checkbox checkbox-green" style="width:auto;padding-top:4px">
                                    <input id="DPV_ResolucionDecretochk" name="DPV_ResolucionDecretochk" type="checkbox" <%=disabled%>>
                                    <span class="checkbox" style="padding-left: 30px;">No aplica</span>
                                </label>
                            </div>
                        </td>
                        <td>                                
                            <input type="text" id="DPV_ResolucionDecretoNumero" name="DPV_ResolucionDecretoNumero" class="form-control" <%=required%> value="<%=DPV_ResolucionDecretoNumero%>">
                        </td>                            
                    </tr>
                    <tr>
                        <td>Folio alta del bien</td>                            
                        <td>                                
                            <div class="rkmd-checkbox checkbox-rotate checkbox-ripple">
                                <label class="input-checkbox checkbox-green" style="width:auto;padding-top:4px">
                                    <input id="DPV_FolioAltaBienchk" name="DPV_FolioAltaBienchk" type="checkbox" <%=disabled%>>
                                    <span class="checkbox" style="padding-left: 30px;">No aplica</span>
                                </label>
                            </div>
                        </td>
                        <td>                                
                            <input type="text" id="DPV_FolioAltaBienNumero" name="DPV_FolioAltaBienNumero" class="form-control" <%=required%> value="<%=DPV_FolioAltaBienNumero%>">
                        </td>                            
                    </tr>
                    <tr>
                        <td>Factoring</td>                            
                        <td>                                
                            <div class="rkmd-checkbox checkbox-rotate checkbox-ripple">
                                <label class="input-checkbox checkbox-green" style="width:auto;padding-top:4px">
                                    <input id="DPV_Factoringchk" name="DPV_Factoringchk" type="checkbox" <%=disabled%>>
                                    <span class="checkbox" style="padding-left: 30px;">No aplica</span>
                                </label>
                            </div>
                        </td>
                        <td>                                
                            <input type="text" id="DPV_FactoringNombre" name="DPV_FactoringNombre" class="form-control" <%=required%> value="<%=DPV_FactoringNombre%>">
                        </td>                            
                    </tr>
                </tbody>
            </table>
        </div>                       
        <input type="hidden" name="VPV_Id" id="VPV_Id" value="<%=VPV_Id%>">
        <input type="hidden" name="INF_Id" id="INF_Id" value="<%=INF_Id%>">
        <input type="hidden" name="REQ_Id" id="REQ_Id" value="<%=REQ_Id%>">
    </form>
    <footer style="text-align:right">
        <button type="button" class="btn btn-danger btn-md waves-effect waves-dark" id="btn_salirinformes" name="btn_salirinformes" style="float:right;"><i class="fas fa-sign-out-alt"></i></button><%
        if(session("wk2_usrperfil")<>5 and not readonly) then%>
            <button type="button" class="btn btn-success btn-md waves-effect waves-dark" id="btn_Providenciaadd" name="btn_Providenciaadd" style="float: right;"><i class="fas fa-plus"></i></button><%
        end if%>
    </footer>

    <script>
        var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);
        var imputacionesTable;        
        var VPV_Id=<%=VPV_Id%>;        

        $("#frmProvidenciaadd")[0].reset();        

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

        $("#btn_Providenciaadd").on("click",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();

            formValidate("#frmProvidenciaadd");
            if($("#frmProvidenciaadd").valid()){
                if($("#DPV_FolioAltaBienchk").is(":checked")){
                    var DPV_FolioAltaBien = 1
                }else{
                    var DPV_FolioAltaBien = 0
                }
                if($("#DPV_ResolucionDecretochk").is(":checked")){
                    var DPV_ResolucionDecreto = 1
                }else{
                    var DPV_ResolucionDecreto = 0
                }
                if($("#DPV_Factoringchk").is(":checked")){
                    var DPV_Factoring = 1
                }else{
                    var DPV_Factoring = 0
                }

                var data = $("#frmProvidenciaadd").serialize() + "&DPV_FolioAltaBien=" + DPV_FolioAltaBien + "&DPV_ResolucionDecreto=" + DPV_ResolucionDecreto + "&DPV_Factoring=" + DPV_Factoring;               	
                $.ajax({
                    type:'POST',					
                    url: '/ingreso-de-providencia',
                    data:data,					
                    success: function ( data ) {
                        var param = data.split(sas)                                                
                        if(param[0]=="200"){       
                            VPV_Id=param[1];
                            var DPV_Id=param[2];
                            $("#VPV_Id").val(VPV_Id);                            
                            $("#frmProvidenciaadd")[0].reset();
                            swalWithBootstrapButtons.fire({
                                icon:'success',								
                                title: 'Provicencia creada axitosamente.'
                            });
                        }else{
                            swalWithBootstrapButtons.fire({
                                icon:'error',								
                                title: 'ERROR: No fue posible crear la providencia.',
                                text:param[1]
                            });
                        }
                    }
                })
            }
        })

        $("#DPV_ResolucionDecretochk").on("click",function(e){
            if($(this).is(":checked")){
                $("#DPV_ResolucionDecretoNumero").prop("required",false);
                $("#DPV_ResolucionDecretoNumero").removeClass("is-invalid");
                $("#DPV_ResolucionDecretoNumero").val("");
            }else{
                $("#DPV_ResolucionDecretoNumero").prop("required",true);
            }        
        })

        $("#DPV_FolioAltaBienchk").on("click",function(e){
            if($(this).is(":checked")){
                $("#DPV_FolioAltaBienNumero").prop("required",false);
                $("#DPV_FolioAltaBienNumero").removeClass("is-invalid");
                $("#DPV_FolioAltaBienNumero").val("");
            }else{
                $("#DPV_FolioAltaBienNumero").prop("required",true);
            }        
        })

        $("#DPV_Factoringchk").on("click", function(e){
            if($(this).is(":checked")){
                $("#DPV_FactoringNombre").prop("required",false);
                $("#DPV_FactoringNombre").removeClass("is-invalid");
                $("#DPV_FactoringNombre").val("");
            }else{
                $("#DPV_FactoringNombre").prop("required",true);
            }
        })
    </script>