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
sql="exec [spWorkFlowv1_Listar] " & FrD_Cor & "," & For_Cod & "," & For_Cor
set rs = cnn.Execute(sql)
on error resume next
if not rs.eof then
    response.write("200/@/")
else
    response.write("404/@/")
    response.end()
end if
%>
<div class="modal-body">
    <h4>Requerimiento N° <%=Req_cod%></h4><%
    do while not rs.eof
        if(trim(rs("Frm_TipCam"))<>"A") then%>
            <div class="row">
                <div class="col-sm-12 col-md-12 col-lg-12">
                    <div class="md-form input-with-post-icon">
                        <div class="error-message">								
                            <i class="fas fa-edit input-prefix"></i><%
                            if(trim(rs("Frm_TipCam"))="T") then%>
                                <textarea type="text" class="md-textarea form-control" readonly="" rows="5"><%=LimpiarUrl(rs("FrD_Data"))%></textarea><%
                            else
                                if(trim(rs("Frm_TipCam"))<>"L") then%>
                                    <input type="text" class="form-control" readonly="" value="<%=LimpiarUrl(rs("FrD_Data"))%>"><%
                                else%>
                                    <input type="text" class="form-control" readonly="" value="<%=rs("LBx_Item")%>"><%                                    
                                end if
                            end if%>
                            <span class="select-bar"></span>
                            <label for="" class="select-label active"><%=rs("Frm_DesCam")%></label>                                
                        </div>
                    </div>
                </div>
            </div><%
        end if
        rs.movenext
    loop%>    
</div>				
<div class="modal-footer">
    <button type="button" class="btn btn-secondary btn-md waves-effect" data-dismiss="modal"><i class="fas fa-times"></i> Cerrar</button>
</div>