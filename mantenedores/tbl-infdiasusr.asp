<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
    INF_Fecha = request("INF_Fecha")
    INF_Mes = request("INF_Mes")
    
    INF_Anio = request("INF_Anio")
    INF_Usuario = request("INF_Usuario")

    
    if(INF_Usuario=0) then
        INF_Usuario = -1
    end if    	

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if			
	
	'Departamento actual debe ser DAF
	sql = "exec [spInformeDiasxUsuarioo_Listar] " & INF_Usuario & "," & INF_Anio & "," & INF_Mes
	set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error [spInformeDiasxUsuarioo_Listar] " & sql)
		cnn.close 		
		response.end
	End If	
	cont=0
	dataInfdiasusr = "{""data"":["
	
	do While Not rs.EOF
		if cont>0 then
			dataInfdiasusr = dataInfdiasusr & ","
		end if

		dataInfdiasusr = dataInfdiasusr & "[""" & rs("REQ_Id") & """,""" & rs("REQ_Descripcion") & """,""" & rs("REQ_FechaEdit") & """,""" & rs("REQ_UsuarioEdit") & """,""" & rs("DRE_FechaDifCreacion") & """,""" & rs("DRE_FechaEdit") & """,""" & rs("DRE_FechaEditAnterior") & """,""" & rs("DRE_UsuarioEdit") & """,""" & rs("DRE_FechaDifAprobacion") & """,""" & rs("DRE_FechaCierre") & """,""" & rs("DRE_UsuarioCierre") & """,""" & rs("DRE_FechaDifCierre") & """]"

		rs.movenext			
		cont=cont+1	
	loop
	dataInfdiasusr=dataInfdiasusr & "]}"
	
	response.write(dataInfdiasusr)
%>