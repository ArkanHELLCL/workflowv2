<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<!-- #INCLUDE FILE="functions.inc" -->
<%	
    REQ_Id = request("REQ_Id")
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if			
	
	if isEmpty(session("wk2_usrid")) or isNull(session("wk2_usrid")) then
		response.Write("500/@/Error Parámetros no válidos")
		response.end()
	end if				
	
	response.write("200/@/")%>
	<table class="table table-striped" id="tbl-mispreyresp">
	<thead>
		<tr>
			<th>Tipo</th>
			<th>id</th>
			<th>Corr</th>
			<th>Remitente</th>
			<th>Destinatario</th>
			<th>Mensaje</th>
			<th>Fecha</th>
		</tr>
	</thead>
	<tbody><%
	set rs2 = cnn.Execute("exec [spMensajeyRespuetasRequerimiento_Listar] " & REQ_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'")	
	do while not rs2.eof
		if(rs2("MEN_Corr")=0) then
			Tipo = "Pregunta"
		else
			Tipo = "Respuesta"
		end if%>
		<tr>
			<td><%=Tipo%></td>
			<td><%=rs2("MEN_Id")%></td>
			<td><%=rs2("MEN_Corr")%></td>
			<td><%=rs2("USR_Nombre") & " " & rs2("USR_Apellido")%></td>		
			<td><%=rs2("USR_NombreDestinatario") & " " & rs2("USR_ApellidoDestinatario")%></td>
			<td><%=rs2("MEN_Texto")%></td>
			<td><%=rs2("MEN_Fecha")%></td>
		</tr><%
		rs2.movenext
	loop	
  	rs2.Close
  	cnn.Close%>
	
	
	</tbody>
</table>
