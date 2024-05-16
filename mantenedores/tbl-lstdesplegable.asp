<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
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
	
	set rs = cnn.Execute("exec spListaDesplegable_Listar -1") 'todos
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error spListaDesplegable_Listar")
		cnn.close 		
		response.end
	End If	
	cont=0
	dataLstdesplegable = "{""data"":["
	
	do While Not rs.EOF
		if cont>0 then
			dataLstdesplegable = dataLstdesplegable & ","
		end if
        if(CInt(rs("LID_Estado")))=1 then
            estado = "Activo"
        else
            estado = "Bloqueado"
        end if

		dataLstdesplegable = dataLstdesplegable & "[""" & rs("LID_Id") & """,""" & LimpiarUrl(rs("LID_Descripcion")) & """,""" & estado & """]"

		rs.movenext			
		cont=cont+1	
	loop
	dataLstdesplegable=dataLstdesplegable & "]}"
	
	response.write(dataLstdesplegable)
%>