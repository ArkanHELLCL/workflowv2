<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
	if(session("wk2_usrperfil")>2) then
		response.Write("403\\Perfil no autorizado")
		response.End() 			   
	end if		
	
	USR_Id=request("USR_Id")	
	VFL_Id=request("VFL_Id")
		
	sql = "exec [spUsuarioVersionFlujo_Agregar] " & USR_Id & "," & VFL_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"	

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503\\Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if		
	
	set rs = cnn.Execute(sql)
	'response.write(sql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503\\Error Conexión:" & ErrMsg & "-" & sql)
	    response.End()
	End If
		
	'Leyendo tabla para retornar todos los registros de ella	
	set rs=cnn.execute("exec spUsuarioVersionFlujo_Listar -1," & USR_Id)	
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		'response.write ErrMsg & " strig= " & sq			
		cnn.close 			   
		Response.end()
	End If
	dataUsuarioFlujos = "["
	do While Not rs.EOF
		Estado="Bloqueado"
		if(rs("VFL_Estado")=1) then
			Estado="Activo"
		end if
		dataUsuarioFlujos = dataUsuarioFlujos & "{""VFL_Id"":""" & rs("VFL_Id") & """,""FLU_Descripcion"":""" & rs("FLU_Descripcion") & """,""VFL_Estado"":""" & Estado & """,""Del"":""<i class='fas fa-trash-alt text-danger' data-uvf='" & rs("UVF_Id") & "'></i>"""				
		dataUsuarioFlujos = dataUsuarioFlujos & "}"											
		rs.movenext
		if not rs.eof then
			dataUsuarioFlujos = dataUsuarioFlujos & ","
		end if
	loop
	dataUsuarioFlujos=dataUsuarioFlujos & "]"								
	rs.close							
	
	response.write("200\\" & dataUsuarioFlujos)
%>