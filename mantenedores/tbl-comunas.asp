<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
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
	
	set rs = cnn.Execute("exec spComuna_Listar -1") 'todos
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error spComuna_Listar")
		cnn.close 		
		response.end
	End If	
	cont=0
	dataComunas = "{""data"":["
	
	do While Not rs.EOF
		if cont>0 then
			dataComunas = dataComunas & ","
		end if

		dataComunas = dataComunas & "[""" & rs("COM_Id") & """,""" & rs("REG_Nombre") & """,""" & rs("COM_Nombre") & """,""" & rs("COM_OrdenGeografico") & """]"

		rs.movenext			
		cont=cont+1	
	loop
	dataComunas=dataComunas & "]}"
	
	response.write(dataComunas)
%>