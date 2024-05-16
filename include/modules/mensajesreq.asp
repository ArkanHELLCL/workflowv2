<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%
	splitruta=split(ruta,"/")
	DRE_Id=splitruta(7)
	xm=splitruta(5)
	if(xm="modificar") then
		modo=2
		mode="mod"
	end if
	if(xm="visualizar") then
		modo=4
		mode="vis"
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
	
	ssql="exec spDatoRequerimiento_Consultar " & DRE_Id		
	set rs = cnn.Execute(ssql)		
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 2:" & ErrMsg)
		response.End()		
	end if

	if not rs.eof then
		FLD_Id								= rs("FLD_Id")
		ESR_DescripcionFlujoDatos 			= rs("ESR_DescripcionFlujoDatos")
		ESR_IdFlujoDatos					= rs("ESR_IdFlujoDatos")
		ESR_AccionFlujoDatos				= rs("ESR_AccionFlujoDatos")
		VFO_Id 								= rs("VFO_Id")
		VerFor 								= "V." & VFO_Id		
		REQ_Descripcion 					= rs("REQ_Descripcion")
		IdEditor							= rs("IdEditor")			
		USR_JefaturaCreador					= rs("USR_JefaturaCreador")
		NombreEditor						= rs("NombreEditor")
		ApellidoEditor						= rs("ApellidoEditor")
		USR_JefaturaEditor					= rs("USR_JefaturaEditor")
		DEP_IdActual						= rs("DEP_IdActual")
		DepDescripcionActual				= rs("DepDescripcionActual")
		ESR_IdDatoRequerimiento				= rs("ESR_IdDatoRequerimiento")
		ESR_DescripcionDatoRequerimiento	= rs("ESR_DescripcionDatoRequerimiento")
		ESR_AccionDatoRequerimiento			= rs("ESR_AccionDatoRequerimiento")
		VFL_Id								= rs("VFL_Id")
		REQ_Id								= rs("REQ_Id")
		FLD_Prioridad						= rs("FLD_Prioridad")
		DRE_SubEstado						= rs("DRE_SubEstado")
		FLD_InicioTermino					= rs("FLD_InicioTermino")
		FLD_IdHijoSi						= rs("FLD_IdHijoSi")
		VRE_Id								= rs("VRE_Id")
		FLU_Id								= rs("FLU_Id")
		REQ_Estado							= rs("REQ_Estado")
        REQ_Carpeta                         = rs("REQ_Carpeta")
        REQ_Identificador                   = rs("REQ_Identificador")

		accion								= ESR_AccionFlujoDatos
		estado								= ESR_DescripcionFlujoDatos
		if(IsNULL(IdEditor)) then
			IdEditor=0
		end if		
		if(ESR_IdDatoRequerimiento=1 or ESR_IdDatoRequerimiento=7 or ESR_IdDatoRequerimiento=5) then
			'Creacion, Cierre y Rechazo
			accion								= ESR_AccionDatoRequerimiento
			estado								= ESR_DescripcionDatoRequerimiento
		end if		
	else
		ErrMsg="No fue posible encontrar el registro del detalle del requerimiento"
		response.Write("404/@/Error : " & ErrMsg)
		response.End()
	end if
	
	sql = "exec spMensajeRequerimiento_Listar " & REQ_Id & ",'" & REQ_Identificador & "'," & session("wk2_usrid")
	set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error spMensajeRequerimiento_Listar " & sql)
		cnn.close 		
		response.end
	End If	
	cont=0
	dataMensajespry = "{""data"":["
	do While Not rs.EOF		
		if cont=1 then
			dataMensajespry = dataMensajespry & ","				
		end if		
		cont=1
		if(IsNULL(rs("ESR_Id"))) then
			tipo = "Consulta"
		else
			tipo = rs("ESR_Accion")
		end if
		if(IsNULL(rs("ESR_Id")) and REQ_Estado=1) then
			'Mensajes del sistema
			if(rs("MaxCorrelativo")>0) then
				acciones="<i class='fas fa-reply resppry text-primary' data-id='" & rs("MEN_Id") & "' data-usr='" & rs("USR_Id") & "' data-req='" & rs("REQ_Id") & "' data-toggle='tooltip' title='Responder mensaje'></i> <i class='fas fa-chevron-down text-secondary verrespry' data-toggle='tooltip' title='Ver respuestas'></i>"
			else
				acciones="<i class='fas fa-reply resppry text-primary' data-id='" & rs("MEN_Id") & "' data-usr='" & rs("USR_Id") & "' data-req='" & rs("REQ_Id") & "' data-toggle='tooltip' title='Responder mensaje'></i>"
			end if
		else
			'Mensajes de usuarios visibles para todos			
			acciones="<i class='fas fa-reply text-white-50' data-toggle='tooltip' title='Responder mensaje' style='cursor:not-allowed'></i>"
		end if
		dataMensajespry = dataMensajespry & "[""" & rs("MEN_Id") & """,""" & rs("USR_Nombre") & " " & rs("USR_Apellido") & """,""" & tipo & """,""" & rs("MEN_Texto") & """,""" & rs("MEN_Fecha") & """,""" & acciones & """]"			

		rs.movenext
	loop
	dataMensajespry=dataMensajespry & "]}"
	
	response.write(dataMensajespry)
%>