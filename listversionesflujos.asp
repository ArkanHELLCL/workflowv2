<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="include\template\session.min.inc" -->
<%	
if session("wk2_usrperfil")>4 then
	response.write("403/@/No autorizado")
	response.end()
end if
FLU_Id = request("FLU_ID")
Const titulo = "Listas de versiones de flujos"
set cnn = Server.CreateObject("ADODB.Connection")
on error resume next	
cnn.open session("DSN_WorkFlowv2")
if cnn.Errors.Count > 0 then 
    ErrMsg = cnn.Errors(0).description	   
    cnn.close
    response.Write("503/@/Error Conexión:" & ErrMsg)
    response.End() 			   
end if			

sql=""      'Para el resto de los perfiles solo los flujos que esta asociado el perfil
if session("wk2_usrperfil")=1 then  'Super Adm
    sql="exec spVersionFlujo_Listar -1," & FLU_Id
else    
    sql="exec spUltimaVersionFlujo_Consultar " & FLU_Id
end if

set rs = cnn.Execute(sql)
if cnn.Errors.Count > 0 then 
    ErrMsg = cnn.Errors(0).description	   
    cnn.close
    response.Write("503/@/Error Ejecucion:" & ErrMsg)
    response.End() 			   
end if

response.write("200/@/")%>

<meta charset="UTF-8">

<div class="row container-header">
	<div class="col-sm-12">		
	</div>
</div>

<div class="row container-body">
	<div class="col-sm-12">
		<div style="overflow-x: hidden;">
			<table id="tbl-versionflujos" class="ts table table-striped table-bordered dataTable table-sm" data-id="versionflujos" data-page="true" data-selected="true" data-keys="1" style="margin-bottom: 0;" data-url="" data-noajax="true" cellspacing="0" width="99%" data-edit="false">
				<thead> 
					<tr>					
						<th>#Ver.Flujo</th>
                        <th>Estado</th>
						<th>#Flujo</th>
						<th>Descripción</th>
						<th>Estado</th>
						<th>Editor Versión</th>
                        <th>Fecha Versión</th>
						<th>Acción Versión</th>					
					</tr> 
				</thead>							
				<tbody><%
                do while not rs.eof%>
                    <tr class="verfluline">
                        <td><%=rs("VFL_Id")%></td>
                        <td><%
                            if(rs("VFL_Estado"))=1 then
                                response.write("Activado")
                            else
                                response.write("Desactivado")
                            end if%>
                        </td>
                        <td><%=rs("FLU_Id")%></td>
                        <td><%=rs("FLU_Descripcion")%></td>
                        <td>
                        <%
                            if(rs("FLU_Estado"))=1 then
                                response.write("Activado")
                            else
                                response.write("Desactivado")
                            end if%>                        
                        <td><%=rs("VFL_UsuarioEdit")%></td>
                        <td><%=rs("VFL_FechaEdit")%></td>
                        <td><%=rs("VFL_AccionEdit")%></td>
                    </tr><%
                    rs.MoveNext
                loop
                %>
				</tbody>                 
			</table>
		</div>
	</div>
</div>
