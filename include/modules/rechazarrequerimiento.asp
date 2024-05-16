<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%
	
	if(session("wk2_usrperfil")=5) then	'Auditor
		response.Write("403\\Perfil no autorizado")
		response.End() 			   
	end if
    
    DRE_Id = request("DRE_Id")
	DRE_Observaciones = LimpiarUrl(request("DRE_Observaciones"))
	ESR_Id = 5					'Rechazado

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

    msql = "exec SpDatoRequerimiento_Rechazar  " & DRE_Id & ",'" & DRE_Observaciones & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
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
        DRE_IdNew = rs("DRE_Id")   'Id de la relacion Version Flujo con Version Formulario
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
	ysql = "exec [spCorreoxUsuario_Enviar] " & USR_IdCreador & "," & ESR_Id & "," & REQ_Id & ",'" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'" 
	set rs = cnn.Execute(ysql)
	on error resume next
	'No se detiene la ejecucion si existe un error en la ejecucion del envio del mail

	hsql = "exec [spCorreoxDepartamento_Enviar] " & DEP_IdOrigen & "," & ESR_Id & "," & REQ_Id & ",'" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'" 
	set rs = cnn.Execute(hsql)
	on error resume next

	'Para pasos que tengan lista de distribucion	
	
	if(not IsNULL(LIS_Id)) then
		isql = "exec spDetalleListaDistribucion_Consultar " & LIS_Id
		set rs = cnn.Execute(isql)
		on error resume next
		do while not rs.eof
			'Recorriendo todos los pasos de la lista de distribucion para enviar correo
			DEP_IdLst = rs("DEP_Id")		
			'DLD_PerfilCreador= rs("DLD_PerfilCreador") 	Ya se esta enviando correo al creador
			'DLD_PerfilJefatura= rs("DLD_PerfilJefatura")	Siempre se le va a enviar a la jefatura
			'DLD_PerfilEditor= rs("DLD_PerfilEditor")		'Editor del paso de la lista de distribucion
			'DLD_PerfilEditorActual= rs("DLD_PerfilEditorActual")	'Editor actual del requerimiento
			'Se van a obviar estos parametros, si hay una lista se va a enviar al editor del paso seleccionado en la lista y a su jefatura. Si el paso es NULL se enviara al editor y a su jefatura del paso actual del equerimiento.
			FLD_Idlst = rs("FLD_Id")
			if(IsNULL(DEP_Idlst)) then		'Departamento actual del
				if(IsNULL(FLD_Idlst)) then	'Paso Actual
					DEP_Idlst = DEP_IdActualOri
					ESR_Idlst = ESR_Id		'Estado del paso actual
					USR_IdEditorlst = IdEditor
				else
					'Buscar departamento del paso definido en la lista de distribucion
					'Obteniendo el dato del paso definido en la lista de distribucion
					xl="exec [spDatoRequerimienoPorPaso_Consultar] " & VRE_Id & "," & FLD_Idlst
					set xs = cnn.Execute(xl)
					on error resume next	
					if not xs.eof then
						DEP_Idlst = xs("DEP_Id")						'Departamento del paso
						'ESR_Id = xs("ESR_Id")						'Estado del paso
						ESR_Idlst = ESR_Id
						USR_IdJefaturalst = xs("USR_IdJefatura")		'Jefatura del revisor
						USR_IdEditorlst = xs("USR_IdEditor")			'Revisor					
					end if
				end if
			else
				'Cuando DEP_Id <> null no se toma en cuenta el paso de la lista de districcion
				'if(IsNULL(FLD_Id)) then	'Paso Actual
					DEP_Idlst = DEP_Id 	'Departamento de la lista de distribucion
					ESR_Idlst = ESR_Id		'Estado del paso actual
					USR_IdEditorlst = IdEditor
				'else
					
				'end if			
			end if

			'Envio de correos por cada linea de la lista de distribucion
			if(not IsNULL(USR_IdEditorlst)) then
				asql = "exec [spCorreoxUsuario_Enviar] " & USR_IdEditorlst & "," & ESR_Idlst & "," & REQ_Id & ",'" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'" 
				set asl = cnn.Execute(asql)
				on error resume next
			end if		
			bsql = "exec [spCorreoxDepartamento_Enviar] " & DEP_Idlst & "," & ESR_Idlst & "," & REQ_Id & ",'" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'" 
			set bsl = cnn.Execute(bsql)
			on error resume next
			rs.MoveNext
		loop
	end if

    response.write("200/@/" & DRE_IdNew)
%>