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
	
	set rs = cnn.Execute("exec spDepartamento_Listar -1") 'todos
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error spDepartamento_Listar")
		cnn.close 		
		response.end
	End If	
	cont=0
	dataDepartamentos = "{""data"":["
	
	do While Not rs.EOF
		if(rs("DEP_Id")>0 or session("wk2_usrperfil")=1) then
			if cont>0 then
				dataDepartamentos = dataDepartamentos & ","
			end if
			if(rs("DEP_TipoVista")=1) then
				TipoVista = "Si"
			else
				TipoVista = "No"
			end if

			dataDepartamentos = dataDepartamentos & "[""" & rs("DEP_Id") & """,""" & rs("DEP_Descripcion") & """,""" & rs("DEP_DescripcionCorta") & """,""" & TipoVista & """,""" & rs("DEP_Codigo") & """,""" & rs("DEP_NombreDependiente") & """]"
			cont=cont+1	
		end if
		rs.movenext					
	loop
	dataDepartamentos=dataDepartamentos & "]}"
	
	response.write(dataDepartamentos)
%>