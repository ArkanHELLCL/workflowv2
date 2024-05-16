<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<!-- #INCLUDE FILE="functions.inc" -->
<%					
	if (session("wk2_usrperfil")=4 or session("wk2_usrperfil")=5) then
		response.Write("500/@/Error PErfil no autorizado")
		response.end
	end if

    Req_Cod = request("Req_Cod")
    FrD_Data = request("FrD_Data")

    set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End 			   
	end if

    ssql="exec [spBoletasAntiguo_Cerrar] " & session("wk2_usrid") & "," & Req_Cod & ",'" & FrD_Data	& "'"
	set rs = cnn.Execute(ssql)		
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 2:" & ErrMsg)
		response.End()		
	end if
    response.Write("200/@/")
%>
