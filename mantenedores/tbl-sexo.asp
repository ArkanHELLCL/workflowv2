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
	
	set rs = cnn.Execute("exec spSexo_Listar") 'todos
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error spSexo_Listar")
		cnn.close 		
		response.end
	End If	
	cont=0
	dataSexo = "{""data"":["
	
	do While Not rs.EOF
		if cont>0 then
			dataSexo = dataSexo & ","
		end if

		dataSexo = dataSexo & "[""" & rs("SEX_Id") & """,""" & rs("SEX_Descripcion") & """,""" & rs("SEX_Letra") & """]"

		rs.movenext			
		cont=cont+1	
	loop
	dataSexo=dataSexo & "]}"
	
	response.write(dataSexo)
%>