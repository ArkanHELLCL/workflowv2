<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
    splitruta=split(ruta,"/")    
	xm=splitruta(5)
    DRE_Id=splitruta(7)
    
    DCE_Id=request("DCE_Id")
    if(DCE_Id="") then        
        response.Write("404/@/Error 2 No fue posible encontrar el registro a eliminar")
	    response.End()
    end if
    
    if(session("ds5_usrperfil")=5) then     'Auditor
	    response.Write("403/@/Error 1 Usuario no autorizado")
	    response.End()
	end if	

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error 2 Conexión:" & ErrMsg)
	   response.End()
	end if		    

	tsql="exec spDetalleCertificado_Eliminar " &  DCE_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
    set rs = cnn.Execute(tsql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("503/@/Error 3: spDetalleCertificado_Eliminar")
		cnn.close 		
		response.end
	End If	

    response.write("200/@/")
%>