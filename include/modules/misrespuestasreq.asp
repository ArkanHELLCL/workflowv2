<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<%					
	REQ_Id 				= request("REQ_Id")
	REQ_Identificador 	= request("REQ_Identificador")
	MEN_Id 				= request("MEN_Id")
	table 				= request("table")
	
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503//Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if			
	
	if isEmpty(session("wk2_usrid")) or isNull(session("wk2_usrid")) then
		response.Write("500//Error Parámetros no válidos")
		response.end()
	end if	%>
<table class="table table-striped" id="<%=table%>">
	<thead>
		<tr>
			<th>id</th>
			<th>#</th>
			<th>Remitente</th>
			<th>Tipo Mensaje</th>
			<th>Mensaje</th>
			<th>Fecha</th>			
		</tr>
	</thead>
	<tbody><%
	set rs2 = cnn.Execute("exec spMensaje_Listar " & MEN_Id & "," & REQ_Id & ",'" & REQ_Identificador & "'," & session("wk2_usrid"))
	do while not rs2.eof%>
		<tr>
			<td><%=rs2("MEN_Id")%></td>
			<td><%=rs2("MEN_Corr")%></td>
			<td><%=rs2("USR_Nombre") & " " & rs2("USR_Apellido")%></td>
			<td><%
                if(IsNULL(rs2("ESR_Id"))) then
                    response.write("Respuesta")
                else
                    response.write(rs2("ESR_Descripcion"))
                end if%>
            </td>
			<td><%=rs2("MEN_Texto")%></td>
			<td><%=rs2("MEN_Fecha")%></td>			
		</tr><%
		rs2.movenext
	loop	
  	rs2.Close
  	cnn.Close%>
	
	
	</tbody>
</table>