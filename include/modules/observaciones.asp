<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%
	
	if(session("wk2_usrperfil")=5) then	'Auditor
		response.Write("403\\Perfil no autorizado")
		response.End() 			   
	end if
    
	ESR_Id = request("ESR_Id")

    set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if

	'Buscando si el estado tiene observaciones obligatorias
    ssql="exec spEstadoRequerimiento_Consultar " & ESR_Id		
	set rs = cnn.Execute(ssql)		
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 2:" & ErrMsg)
		response.End()		
	end if    

    if(not rs.eof) then
		ESR_Observacion = rs("ESR_Observacion")
        if(IsNULL(ESR_Observacion) or ESR_Observacion="") then
            ESR_Observacion = 0 'No
        end if
    else
        ESR_Observacion = 0 'No
	end if    

    response.write("200/@/" & ESR_Observacion)
%>