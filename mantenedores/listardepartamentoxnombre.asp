<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
	DEP_Descripcion = request("DEP_Descripcion")
	
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if			
		
	set rs = cnn.Execute("exec spDepartamento_ConsultarPorNombre '" & DEP_Descripcion & "'")
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error spDepartamento_ConsultarPorNombre")
		cnn.close 		
		response.end
	End If	
	
	
	if Not rs.EOF then%>
		{"DEP_Id": "<%=rs("DEP_Id")%>", "DEP_Descripcion": "<%=rs("DEP_Descripcion")%>","DEP_Estado": "<%=rs("DEP_Estado")%>", "DEP_Codigo" : "<%=rs("DEP_Codigo")%>"}<%
	else%>
		{}<%
	end if			
%>