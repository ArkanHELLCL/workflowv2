<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="include\template\session.min.inc" -->
<!-- #INCLUDE FILE="include\template\functions.inc" -->
<%	
	if(session("wk2_usrperfil")>2 ) then	'Todos menos el administrador y super
		response.write("503/@/Error Perfil no autorizado")
		response.End() 			   
	end if	
	
	DRE_Id		        = request("DRE_Id")	
	DRE_Observaciones	= LimpiarUrl(request("DRE_Observacion"))
	ESR_Id 	            = 14					'Archivado	
	MEN_Archivo	        = ""    
		
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.write("503/@/Error de conexion")
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
	end if
	
	msql = "exec [SpDatoRequerimiento_Archivar]  " & DRE_Id & ",'" & DRE_Observaciones & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
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
	
	sql = "exec [spMensaje_Agregar] " & ESR_Id & "," & REQ_Id & ",'" & MEN_Mensaje & "','','" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
	set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.write("503/@/Error de conexion")
	   response.End() 			   
	end if
	 response.write("200/@/")
%>