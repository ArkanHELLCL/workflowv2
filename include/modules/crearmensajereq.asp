<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%
	
	if(session("wk2_usrperfil")=5) then	'Auditor%>
	   {"state": 403, "message": "Perfil no autorizado","data": null}<%
		response.End() 			   
	end if
		
	
	REQ_Id				= request("REQ_Id")	
	REQ_Identificador	= request("REQ_Identificador")
	MEN_Id				= request("MEN_Id")
	MEN_Texto			= LimpiarUrl(request("MEN_Texto"))
	ESR_Id				= "NULL"    'Mensaje de usuario
	MEN_Archivo			= ""
				
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close%>
	   {"state": 503, "message": "Error Conexión : <%=ErrMsg%>","data": null}<%
	   response.End() 			   
	end if			
	
	sqx="exec [spMensaje_Agregar] " & ESR_Id & "," & REQ_Id & ",'" & MEN_Texto & "','" & MEN_Archivo & "','" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
	set rx = cnn.Execute(sqx)	
	on error resume next
	if cnn.Errors.Count > 0 then
		ErrMsg = cnn.Errors(0).description%>
	   	{"state": 503, "message": "Error Conexión : <%=ErrMsg%>","data": "<%=sqx%>"}<%
		rs.close
		cnn.close
		response.end()
	End If	
	%>	
	{"state": 200, "message": "Grabación de consulta correcta","data": null}