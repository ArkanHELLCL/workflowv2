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
	
	set rs = cnn.Execute("exec spRegion_Listar") 'todos
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error spRegion_Listar")
		cnn.close 		
		response.end
	End If	
	cont=0
	dataRegiones = "{""data"":["
	
	do While Not rs.EOF
		if cont>0 then
			dataRegiones = dataRegiones & ","
		end if

		dataRegiones = dataRegiones & "[""" & rs("REG_Id") & """,""" & rs("REG_Nombre") & """,""" & rs("REG_OrderGeografico") & """]"

		rs.movenext			
		cont=cont+1	
	loop
	dataRegiones=dataRegiones & "]}"
	
	response.write(dataRegiones)
%>