<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%	
    'if (session("wk2_usrperfil")=4 and session("wk2_usrjefatura")<>1) or session("wk2_usrperfil")=3 then	
		'response.Write("403/@/Error Perfil no autorizado")
		'response.end()
	'end if
    DEP_Id = request("DEP_Id")    

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if		
	set rs = cnn.Execute("exec [spDepartamento_Consultar] " & DEP_Id)
	on error resume next        				
    if not rs.eof then
        Departamento = rs("DEP_Descripcion")
    end if

	response.write("200/@/" & Departamento)%>
	
