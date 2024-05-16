<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%	
    'if (session("wk2_usrperfil")=4 and session("wk2_usrjefatura")<>1) or session("wk2_usrperfil")=3 then
	'	response.Write("403/@/Error Perfil no autorizado")
	'	response.end()
	'end if
    USR_Id = request("USR_Id")
	if(isnull(USR_Id) or trim(USR_Id)="") then
		Usuario = "Unidad"
	end if

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if		
	set rs = cnn.Execute("exec [spUsuario_Consultar] " & USR_Id)
	on error resume next        				
    if not rs.eof then
        Usuario = rs("USR_Nombre") & " " & rs("USR_Apellido") & " (" & rs("USR_USuario") & ")"
    end if

	response.write("200/@/" & Usuario)%>
	
