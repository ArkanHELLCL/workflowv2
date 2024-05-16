<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%	
	if(session("wk2_usrperfil")>2) then%>
	   {"state": 403, "message": "Perfil no autorizado","data": null}<%
		response.End() 			   
	end if		
		
	PER_Id		    			    = Request("PER_Id")
	USR_Estado      			    = Request("USR_Estado")
	USR_Usuario     			  	= LimpiarUrl(Request("USR_Usuario"))
	USR_Telefono     				= Request("USR_Telefono")	
	USR_Mail        				= Request("USR_Mail")
	USR_Nombre      				= LimpiarUrl(Request("USR_Nombre"))
	USR_Apellido       				= LimpiarUrl(Request("USR_Apellido"))
	SEX_Id                          = Request("SEX_Id")	
	Rut								= Request("USR_Rut")	
	DEP_Id							= Request("DEP_Id")	
	USR_Firma						= Request("USR_Firma")
	USR_Jefatura					= Request("USR_Jefatura")
	
	USR_Rut=replace(mid(Rut,1,len(Rut)-2),".","")
	USR_Dv=mid(Rut,len(Rut),1)


	datos = PER_Id & "," & USR_Rut & ",'" & USR_Dv & "'," & USR_Estado & ",'" & USR_Usuario & "','" & USR_Telefono & "','" & USR_Mail & "','" & USR_Nombre & "','" & USR_Apellido & "'," & SEX_Id & "," & DEP_Id & "," & USR_Jefatura	& ",'" & USR_Firma & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'" 


	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close%>
	   {"state": 503, "message": "Error Conexión : <%=ErrMsg%>","data" : "<%=datos%>"}<%
	   response.End() 			   
	end if		

    tql="exec [spUsuario_ConsultarPorLogin] '" & USR_Usuario & "'"
    set rs = cnn.Execute(tql)
	on error resume next
	if cnn.Errors.Count > 0 then%>
	   {"state": 503, "message": "Error Conexión : <%=ErrMsg%>","data": "<%=sql%>"}<%
		rs.close
		cnn.close
		response.end()
	End If					
    if(not rs.eof) then%>
        {"state": 10, "message": "Error en creación usuario ya existe","data": "null"}<%
		rs.close
		cnn.close
		response.end()
    end if
	
	sql="exec spUsuario_Agregar " & datos 	
	set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then%>
	   {"state": 503, "message": "Error Conexión : <%=ErrMsg%>","data": "<%=sql%>"}<%
		rs.close
		cnn.close
		response.end()
	End If
    if(not rs.eof) then
        USR_Id = rs("USR_Id")
    end if
	
	cnn.close
	set cnn = nothing%>
	{"state": 200, "message": "Ejecución exitosa","data": <%=USR_Id%>}