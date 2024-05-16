<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<!-- #INCLUDE FILE="functions.inc" -->
<%
Req_cod = request("Req_cod")
FrD_Cor = request("FrD_Cor")
For_Cod = request("For_Cod")
For_Cor = request("For_Cor")
VFL_Id  = request("VFL_Id")
Flu_CodPas = request("FLU_CodPas")

set cnn = Server.CreateObject("ADODB.Connection")
on error resume next	
cnn.open session("DSN_WorkFlowv2")
if cnn.Errors.Count > 0 then 
    ErrMsg = cnn.Errors(0).description	   
    cnn.close
    response.Write("503/@/Error Conexión:" & ErrMsg)
    response.End() 			   
end if

yql="exec [spVersionFlujo_Consultar] " & VFL_Id
set rs = cnn.Execute(yql)
on error resume next
if not rs.eof then
    FLU_Descripcion = rs("FLU_Descripcion")
end if

editar = false
flujo  = false
xql="exec [spUsuarioVersionFlujoxUsuarioFlujo_Consultar] " & session("wk2_usrid") & "," & VFL_Id
set rs = cnn.Execute(xql)
on error resume next
if not rs.eof then
    flujo = true
end if

if(session("wk2_usrperfil")=1 or (session("wk2_usrperfil")=2 and flujo)) then
    editar = true
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
    <h5>Flujo <%=FLU_Descripcion%></h5>
    <h5>Requerimiento N° <%=Req_cod%></h5>
    <h5>Paso <%=Flu_CodPas%></h5><%
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
                                if(trim(rs("Frm_TipCam"))<>"L") then
                                    if(trim(rs("Frm_TipCam"))="F" and trim(ucase(rs("Frm_DesCam"))) = "FECHA DE ENTREGA") and (editar) then%>
                                        <input type="text" id="FrD_DataBoletas" name="FrD_DataBoletas" class="form-control calendario" required readonly="" value="<%=LimpiarUrl(rs("FrD_Data"))%>"><%
                                    else%>
                                        <input type="text" class="form-control" readonly="" value="<%=LimpiarUrl(rs("FrD_Data"))%>"><%
                                    end if
                                else%>
                                    <input type="text" class="form-control" readonly="" value="<%=rs("LBx_Item")%>"><%                                    
                                end if
                            end if%>
                            <span class="select-bar"></span><%
                            if LimpiarUrl(rs("FrD_Data"))<>"" then%>
                                <label for="" class="select-label active"><%=rs("Frm_DesCam")%></label><%
                            else%>
                                <label for="" class="select-label"><%=rs("Frm_DesCam")%></label><%
                            end if%>
                        </div>
                    </div>
                </div>
            </div><%
        end if
        rs.movenext
    loop%>
    <input type="hidden" id="Req_codBoletas" name="Req_codBoletas" value="<%=Req_Cod%>">    
</div>
<div class="modal-footer"><%
    if editar then%>
        <button type="button" class="btn btn-success btn-md waves-effect" id="btn_wrkpenfinalizar" name="btn_wrkpenfinalizar"><i class="fas fa-check-square"></i> Finalizar</button><%
    end if%>
    <button type="button" class="btn btn-secondary btn-md waves-effect" data-dismiss="modal"><i class="fas fa-times"></i> Cerrar</button>
</div>

<script>
    var titani = setInterval(function(){				
		$("h5").slideDown("slow",function(){
			$("h6").slideDown("slow",function(){
				$(".verobs").addClass("shake")
				clearInterval(titani)
			});
		})
	},2300);
    if ($(".calendario").val() ==  null){
		$(".calendario").datepicker().datepicker("setDate", new Date());
	}else{
		$(".calendario").datepicker();
	}
</script>