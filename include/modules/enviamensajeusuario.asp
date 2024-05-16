<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<!-- #INCLUDE FILE="functions.inc" -->
<%	
	ESR_Id = "NULL" 'Pregunta
	MEN_Texto = LimpiarUrl(request("MEN_Texto"))
	USR_Id = request("USR_Id")
	PER_Id="NULL"
	
	sql=""
	sqlx=""
	sqly=""
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if			
	
	if isEmpty(session("wk2_usrid")) or isNull(session("wk2_usrid")) then
		response.Write("500/@/Error Parámetros no válidos")
		response.end()
	end if				
		
	sql = "exec spMensajePersonal_Agregar " & ESR_Id & ",'" & MEN_Texto & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
	set rs2 = cnn.Execute(sql)
    on error resume next
    if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg & "-" & sql)
	   response.End() 			   
	end if		
	if not rs2.eof then
		MEN_Id=rs2("MEN_Id")
		MEN_Corr=rs2("MEN_Corr")
	else
		response.end()
	end if				

	sqlx = "exec spMensajeUsuario_Registrar " & MEN_Id & "," & MEN_Corr & "," & USR_Id & "," & PER_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
	cnn.execute sqlx
	on error resume next	
    if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg & "-" & sqlx)
	   response.End() 			   
	end if		

	sqly = "exec spMensajeUsuario_Consultar " & MEN_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
	set rs = cnn.Execute(sqly)
	on error resume next	
    if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg & "-" & sqly)
	   response.End() 			   
	end if	
	if not rs.eof then				
        data = data & "{""MEN_Id"":""" & rs("MEN_Id") & """,""MEN_Corr"":""" & rs("MEN_Corr")  & """,""USR_Nombre"":""" & rs("USR_Nombre") & " " & rs("USR_Apellido") & """,""USR_NombreDestinatario"":""" & rs("USR_NombreDestinatario") & " " & rs("USR_ApellidoDestinatario") & """,""ESR_Accion"":""" & rs("ESR_Accion") & """,""MEN_Texto"":""" & rs("MEN_Texto") & """,""MEN_Fecha"":""" & rs("MEN_Fecha") & """,""R"":""" & rs("MaxCorrelativo") & """,""RES"":"" <i class='fas fa-reply resp text-primary' data-id='" & rs("MEN_Id") & "' data-toggle='tooltip' title='Responder mensaje'></i> """

        data = data & "}"
    else
        data = "{}"
	end if
	
  	rs2.Close
	rs.Close
  	cnn.Close
	
	response.write("200/@/" & data)
%>