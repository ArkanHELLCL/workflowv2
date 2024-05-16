<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%
	
	if(session("wk2_usrperfil")=5) then	'Auditor
		response.Write("403\\Perfil no autorizado")
		response.End() 			   
	end if
    
    DRE_Id = request("DRE_Id")
	ESR_Id = 7					'Cerrado
	DRE_Observaciones = LimpiarUrl(request("DRE_Observaciones"))

    set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if

	'Buscando en el registro actual del requerimiento
    ssql="exec spDatoRequerimiento_Consultar " & DRE_Id		
	set rs = cnn.Execute(ssql)		
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 2:" & ErrMsg)
		response.End()		
	end if    

    if(not rs.eof) then
		REQ_Id = rs("REQ_Id")
		REQ_Identificador = rs("REQ_Identificador")
		USR_IdCreador = rs("IdCreador")
		LIS_Id = rs("LIS_Id")		'Para envio de correos definidos en la lista de distribucion
		VRE_Id = rs("VRE_Id")		'Para envio de correos definidos en la lista de distribucion
		DEP_IdActualOri = rs("DEP_Id")
		DEP_IdOrigen = rs("DEP_IdOrigen")
		IdEditor = rs("IdEditor")		
	end if

    msql = "exec [SpDatoRequerimiento_Cerrar]  " & DRE_Id & ",'" & DRE_Observaciones & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
    set rs = cnn.Execute(msql)
	on error resume next
	if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description
		response.Write("503/@/Error Conexión 3:" & ErrMsg & "-" & msql)
		rs.close
		cnn.close
		response.end()
	End If
	if not rs.eof then
        DRE_IdNew = rs("DRE_Id")
		DRE_FechaEdit = rs("DRE_FechaEdit")
		DEP_IdActual = rs("DEP_IdActual")
    end if    

	'Creación del mensaje
    'Busqueda de la descripcion del Estado
    vsql = "exec spEstadoRequerimiento_Consultar " & ESR_Id
    set rs = cnn.Execute(vsql)
    on error resume next
    if not rs.eof then
        ESR_DescripcionMensaje = rs("ESR_Descripcion")
        MEN_Mensaje = "Requerimiento Nro. " & REQ_Id & ", " & ESR_DescripcionMensaje & " por : " & session("wk2_usrnom") & " - " & DRE_FechaEdit
    end if

    rsql = "exec [spMensaje_Agregar] " & ESR_Id & "," & REQ_Id & ",'" & MEN_Mensaje & "','','" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
    set rs = cnn.Execute(rsql)
    on error resume next
    'No se detiene el proceso si falla la grabacion del mensaje

	'Envio de correo al propietario
	'WHERE USR.USR_Id = @USR_Id
	ysql = "exec [spCorreoxUsuario_Enviar] " & USR_IdCreador & "," & ESR_Id & "," & REQ_Id & ",'" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'" 
	set rs = cnn.Execute(ysql)
	on error resume next
	'No se detiene la ejecucion si existe un error en la ejecucion del envio del mail

	'WHERE DEP.DEP_Id = @DEP_Id AND (USR.PER_Id <> 4 OR (USR.PER_Id = 4 AND USR.USR_Jefatura = 1))  
	hsql = "exec [spCorreoxDepartamento_Enviar] " & DEP_IdOrigen & "," & ESR_Id & "," & REQ_Id & ",'" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'" 
	set rs = cnn.Execute(hsql)
	on error resume next

    response.write("200/@/" & DRE_IdNew)
%>