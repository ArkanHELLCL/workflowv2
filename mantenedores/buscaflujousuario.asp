<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
	if(session("wk2_usrperfil")>2) then
		response.Write("403/@/Perfil no autorizado")
		response.End() 			   
	end if		

    USR_Id=request("USR_Id")
			
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if		
	
    sql2 = "exec [spUsuario_Consultar] " & USR_Id
	set rt = cnn.Execute(sql2)	
	on error resume next
    if(not rt.eof) then
        PER_Id = rt("PER_Id")
    end if
    
    sql = "exec [spUsuarioVersionFlujo_Listar] -1, " & USR_Id
	set rs = cnn.Execute(sql)	
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión:" & ErrMsg & "-" & sql)
	    response.End()
	End If
		
	if not rs.eof or PER_Id = 1 then
        Flujo = 1
    else
        Flujo = 0
    end if						
	rs.close							
	
	response.write("200/@/" & Flujo)
%>