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
	
	set rs = cnn.Execute("exec spDiasFestivosxAnio_Listar") 'todos
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error spDiasFestivosxAnio_Listar")
		cnn.close 		
		response.end
	End If	
	cont=0
	dataFestivo = "{""data"":["
	
	do While Not rs.EOF
		if cont>0 then
			dataFestivo = dataFestivo & ","
		end if

		dataFestivo = dataFestivo & "[""" & rs("DFE_Id") & """,""" & rs("DFE_Fecha") & """,""" & LimpiarUrl(rs("DFE_Motivo")) & """]"

		rs.movenext			
		cont=cont+1	
	loop
	dataFestivo=dataFestivo & "]}"
	
	response.write(dataFestivo)
%>