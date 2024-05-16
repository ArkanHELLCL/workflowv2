<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<!-- #INCLUDE FILE="functions.inc" -->
<%
Req_cod = request("Req_cod")
FrD_Cor = request("FrD_Cor")
For_Cod = request("For_Cod")
For_Cor = request("For_Cor")

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
<div class="modal-body">
    <h4>Requerimiento N° <%=Req_cod%></h4>
    <div class="row">
        <h5>Certificados</h5>
        <table class="ts table table-striped table-bordered dataTable table-sm" cellspacing="0" data-id="2" style="width:99%;margin-top:10px;">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Creador</th>                        
                    <th>Creción</th>
                    <th>Visador</th>
                    <th>Visado</th>
                    <th>Aprobador</th>
                    <th>Aprobado</th>
                    <th></th>
                </tr>
            </head>
            <tbody><%
                sql1="exec [spCertificadosWorkFlowv1_Listar] " & Req_cod
                set rs = cnn.Execute(sql1)
                on error resume next
                if(not rs.eof) then
                    do while not rs.eof%>        
                        <tr>
                            <td><%=rs("CDis_Cod")%></td>
                            <td><%=rs("CDis_UsrCre")%></td>                        
                            <td><%=rs("CDis_FchCre")%></td>
                            <td><%=rs("CDis_UsrVal")%></td>
                            <td><%=rs("CDis_FchVal")%></td>
                            <td><%=rs("CDis_UsrApr")%></td>
                            <td><%=rs("CDis_FchApr")%></td>
                            <td><i class="fas fa-cloud-download-alt text-primary downcer" style="cursor:pointer" data-req="<%=Req_cod%>" data-dis="<%=rs("CDis_Cod")%>"></i></td>
                        </tr><%        
                        rs.movenext
                    loop
                else%>
                    <tr>
                        <td colspan="8">No existen certificados para este requerimiento</td>
                    </tr><%
                end if
                rs.close%>
            </tbody>
        </table>
    </div>
    </br>
    <div class="row">
        <h5>Documentos</h5>
        <table class="ts table table-striped table-bordered dataTable table-sm" cellspacing="0" data-id="2" style="width:99%;margin-top:10px;">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Usuario</th>                        
                    <th>Documento</th>
                    <th>Creación</th>                        
                    <th></th>
                </tr>
            </head>
            <tbody><%
                sql2="exec [spDocumentosWorkFlowv1_Generar] " & Req_cod
                set rs = cnn.Execute(sql2)
                on error resume next
                if(not rs.eof) then
                    corr=1
                    do while not rs.eof%>        
                        <tr>
                            <td><%=corr%></td>
                            <td><%=rs("Inf_UsrCre")%></td>                        
                            <td><%=rs("Inf_Des")%></td>
                            <td><%=rs("Inf_FchCre")%></td>                        
                            <td><i class="fas fa-cloud-download-alt text-primary downdoc" style="cursor:pointer" data-req="<%=Req_cod%>" data-inf="<%=corr+1%>"></i></td>
                        </tr><%        
                        rs.movenext
                        corr=corr+1
                    loop
                else%>
                    <tr>
                        <td colspan="5">No existen Documentos para este requerimientos</td>
                    </tr><%
                end if
                rs.close%>
            </tbody>
        </table>
    </div>
    </br>
    <div class="row">
        <h5>Observaciones</h5>
        <table class="ts table table-striped table-bordered dataTable table-sm" cellspacing="0" data-id="2" style="width:99%;margin-top:10px;">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Usuario</th>                        
                    <th>Observación</th>
                    <th>Creación</th>                    
                </tr>
            </head>
            <tbody><%
                sql3="exec [spObservacionesRequerimientoWorkFlowv1_Listar] " & Req_cod
                set rs = cnn.Execute(sql3)
                on error resume next
                if(not rs.eof) then
                    corr=1
                    do while not rs.eof%>        
                        <tr>
                            <td><%=corr%></td>
                            <td><%=rs("Obs_UsrCre")%></td>                        
                            <td><%=rs("Obs_Des")%></td>
                            <td><%=rs("Obs_FchCre")%></td>                                                
                        </tr><%        
                        rs.movenext
                        corr=corr+1
                    loop
                else%>
                    <tr>
                        <td colspan="4">No existen Observaciones para este requerimiento</td>
                    </tr><%
                end if
                rs.close%>
            </tbody>
        </table>
    </div>
    </br>
    <div class="row">
        <h5>Estados</h5>
        <table class="ts table table-striped table-bordered dataTable table-sm" cellspacing="0" data-id="2" style="width:99%;margin-top:10px;">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Usuario</th>                        
                    <th>Versión</th>
                    <th>Creación</th>
                    <th>Estado</th>
                </tr>
            </head>
            <tbody><%
                sql4="exec [spEstadosRequerimientoWorkFlowv1_Listar] " & Req_cod
                set rs = cnn.Execute(sql4)
                on error resume next
                if(not rs.eof) then
                    corr=1
                    do while not rs.eof
                        if(TRIM(rs("Req_UsrEdt"))<>"UNIDAD") then%>        
                            <tr>
                                <td><%=corr%></td>
                                <td><%=rs("Req_UsrEdt")%></td>                        
                                <td><%=rs("Frd_Cor")%></td>
                                <td><%=rs("REQ_FchMod")%></td>
                                <td><%=rs("REQ_Estado")%></td>
                            </tr><%
                        end if
                        rs.movenext
                        corr=corr+1
                    loop
                else%>
                    <tr>
                        <td colspan="5">No existen Estados para este requerimiento</td>                        
                    </tr><%
                end if
                rs.close%>
            </tbody>
        </table>
    </div>
</div>				
<div class="modal-footer">
    <button type="button" class="btn btn-secondary btn-md waves-effect" data-dismiss="modal"><i class="fas fa-times"></i> Cerrar</button>
</div>