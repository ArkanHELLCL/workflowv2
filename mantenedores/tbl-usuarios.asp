<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%	
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if			
	
	'if(session("wk2_usrperfil")=1) then
		set rs = cnn.Execute("exec spUsuario_Listar -1")
	'else
	'	set rs = cnn.Execute("exec [spUsuarioAdministrador_Listar] -1 , " & session("wk2_usrid"))
	'end if
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error spUsuario_Listar")
		cnn.close 		
		response.end
	End If	
	
	dataUsuarios = "{""data"":["
	do While Not rs.EOF		
		if rs("USR_Estado")=1 then
			estado="Activado"
		else
			estado="Desactivado"
		end if		
		jefatura="No"
		if(CInt(rs("USR_Jefatura"))=1) then
			jefatura = "Si"
		end if
		firma="No"
		if(not IsNULL(rs("USR_Firma")) and trim(rs("USR_Firma"))<>"") then
			firma="Si"
		end if

		flujos=""
		set rt = cnn.Execute("exec spUsuarioVersionFlujo_Listar -1, " & rs("USR_Id"))
		on error resume next 
		do while not rt.eof
			flujos = flujos & rt("FLU_Descripcion")	& "(V." & rt("VFL_Id") & ")"
			rt.movenext
			if not rt.eof then
				flujos = flujos & " ,"
			end if
		loop
		if(flujos="" and rs("PER_Id")=1) then
			flujos = "Todos"
		else
			if(flujos="") then
				flujos = "Sin flujos asignados"
			end if
		end if
		data=false
		if(session("wk2_usrperfil")=2 and rs("PER_Id")<>1) or (session("wk2_usrperfil")=1) then
			dataUsuarios = dataUsuarios & "[""" & rs("USR_Id") & """,""" & rs("PER_Nombre") & """,""" & LimpiarUrl(UCASE(rs("USR_Usuario"))) & """,""" & LimpiarUrl(rs("USR_Nombre")) & " " & LimpiarUrl(rs("USR_Apellido")) & """,""" & rs("DEP_Descripcion") & """,""" & jefatura & """,""" & firma & """,""" & flujos & """,""" & estado & """,""" & rs("USR_Mail") & """,""" & LimpiarUrl(rs("USR_Nombre")) & """,""" & LimpiarUrl(rs("USR_Apellido")) & """,""" & rs("USR_Rut") & """,""" & rs("USR_Dv") & """,""" & rs("SEX_Descripcion") & """]"
			data=true
		end if	
		rs.movenext
		if not rs.eof and data then
			dataUsuarios = dataUsuarios & ","
		end if
	loop
	dataUsuarios=dataUsuarios & "]}"
	
	response.write(dataUsuarios)	
%>