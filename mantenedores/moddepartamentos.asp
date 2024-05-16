<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%	
	if(session("wk2_usrperfil")>2) then	%>
	   {"state": 403, "message": "Perfil no autorizado","data": null}<%
		response.End() 			   
	end if		
	
	DEP_Id			= Request("DEP_Id")
	DEP_Descripcion	= LimpiarUrl(Request("DEP_Descripcion"))
	DEP_Estado 		= Request("DEP_Estado")
	DEP_Codigo		= Request("DEP_Codigo")
	DEP_DescripcionCorta = LimpiarUrl(Request("DEP_DescripcionCorta"))
	DEP_TipoVista = Request("DEP_TipoVista")

	if(DEP_Codigo="" or IsNULL(DEP_Codigo)) then
		DEP_Codigo = "NULL"
	end if
 
	datos = DEP_Id & ",'" & DEP_Descripcion & "'," & DEP_Estado & "," & DEP_Codigo & ",'" & DEP_DescripcionCorta & "'," & DEP_TipoVista	& "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close%>
	   {"state": 503, "message": "Error Conexión : <%=ErrMsg%>","data" : "<%=datos%>"}<%
	   response.End() 			   
	end if		
	
	sql="exec spDepartamento_Modificar " & datos 
	
	set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then%>
	   {"state": 503, "message": "Error Conexión : <%=ErrMsg%>","data": "<%=sql%>"}<%
		rs.close
		cnn.close
		response.end()
	End If					
	
	cnn.close
	set cnn = nothing%>
	{"state": 200, "message": "Ejecución exitosa","data": null}