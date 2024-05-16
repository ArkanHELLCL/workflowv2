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
	
	set rs = cnn.Execute("exec spItemListaDesplegable_Listar -1,-1") 'todos
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error spItemListaDesplegable_Listar")
		cnn.close 		
		response.end
	End If	
	cont=0
	dataItemslstdesplegable = "{""data"":["
	
	do While Not rs.EOF
		if cont>0 then
			dataItemslstdesplegable = dataItemslstdesplegable & ","
		end if
        if(CInt(rs("ILD_Estado")))=1 then
            estado = "Activo"
        else
            estado = "Bloqueado"
        end if

		dataItemslstdesplegable = dataItemslstdesplegable & "[""" & rs("ILD_Id") & """,""" & LimpiarUrl(rs("LID_Descripcion")) & """,""" & LimpiarUrl(rs("ILD_Descripcion")) & """,""" & estado & """]"

		rs.movenext			
		cont=cont+1	
	loop
	dataItemslstdesplegable=dataItemslstdesplegable & "]}"
	
	response.write(dataItemslstdesplegable)
%>