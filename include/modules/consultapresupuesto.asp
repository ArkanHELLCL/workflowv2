<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
    splitruta=split(ruta,"/")    
	xm=splitruta(5)
    DRE_Id=splitruta(7)
    
    ILD_Id=request("ILD_Id")

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if			
		
    ssql="exec spItemListaDesplegable_Consultar " & ILD_Id
	set rs = cnn.Execute(ssql)		
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 2:" & ErrMsg)
		response.End()		
	end if

	if Not rs.EOF then
        PRE_PresupuestoAsignado=rs("PRE_PresupuestoAsignado")
        PRE_PresupuestoComprometido=rs("PRE_PresupuestoComprometido")
	end if
		
	response.write("200/@/" & PRE_PresupuestoAsignado & "/@/" & PRE_PresupuestoComprometido)
%>