<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%
	
	if(session("wk2_usrperfil")=5) then	'Auditor
		response.Write("403/@/Perfil no autorizado")
		response.End() 			   
	end if
    
    VFL_Id          = request("VFL_Id")
    REQ_Descripcion = LimpiarUrl(request("REQ_Descripcion"))
    ESR_Id          = 1                         'Creación
    VFO_Id          = "NULL"                    'Aun no sea crea el formulario

    REQ_EsPadre     = "NULL"                    'Cambiar por datos del formulario
    REQ_CodReqAnterior = "NULL"                 'Cambiar por datos del formulario


    if(REQ_Descripcion="") then
       response.Write("503/@/Error descripción del proyecto no puede ser vacia")
	   response.End() 
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

    fsql = "exec [spVersionFlujoFormularixVersionFlujoo_Consultar] " & VFL_Id & ",1"
    set rs = cnn.Execute(fsql)
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description
        response.Write("503/@/Error Conexión 2:" & ErrMsg & "-" & fsql)
        rs.close
        cnn.close
        response.end()
    End If
    if not rs.eof then
        FOR_Id = rs("FOR_Id")
    else
        response.Write("404/@/No se encuentra Datos para el flujo1:" & VFL_Id)
        rs.close
        cnn.close
        response.end()
    end if
    
    bsql = "exec spFlujoDatos_Listar " & VFL_Id & ", 1"
    set rs = cnn.Execute(bsql)
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description
        response.Write("503/@/Error Conexión 2:" & ErrMsg & "-" & bsql)
        rs.close
        cnn.close
        response.end()
    End If
    if not rs.eof then
        FLD_Id            = rs("FLD_Id")                'Primer registro, en creacion de nuevo requerimiento        
        FLD_InicioTermino = rs("FLD_InicioTermino")
        If(IsNULL(rs("DEP_Id"))) then
            'Debe ir a la jefatura para su revision/visacion
            'Se debe mantener en el mismo departamento del creador para que el jefe lo vise. Debe quedar en modo creacion
            DEP_IdOrigen = session("wk2_usrdepid")      'Dependencia Origen es la del creador en modo creacion 
            DEP_IdActual = session("wk2_usrdepid")      'Dependencia Actual es la del creador en modo creacion 
        else
            'Va al departamento que el flujo tiene definido.
            'No debe permanecer en el departamento actual, se debe ir al departamento definido en el flujo, no pude ser creado con estado 1
            'ESR_Id = rs("ESR_Id")
            DEP_IdOrigen = session("wk2_usrdepid")      'Dependencia Origen es la del creador en modo creacion
            'DEP_IdActual = rs("DEP_Id")
            DEP_IdActual = session("wk2_usrdepid")      'Dependencia Actual es la del creador en modo creacion
        end if
    else
        response.Write("404/@/No se encuentra Datos para el flujo2:" & VFL_Id)
        rs.close
        cnn.close
        response.end()
    end if

    'Consultando si la relacion ya existe para no volver a crearla
    msql = "exec [spVersionFlujoFormularioRelacion_Consultar] " & VFL_Id & "," & FOR_Id    
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
        VFF_Id = rs("VFF_Id")
    else	
        'Grabar VersionFlujoFormulario  VFL_Id, FOR_Id      Se relaciona el id del formualrio a la version del flujo que viene por parametro
        xsql = "exec [spVersionFlujoFormulario_Agregar] " & VFL_Id & "," & FOR_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
        set rs = cnn.Execute(xsql)
        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description
            response.Write("503/@/Error Conexión 3:" & ErrMsg & "-" & xsql)
            rs.close
            cnn.close
            response.end()
        End If
        if not rs.eof then
            VFF_Id = rs("VFF_Id")   'Id de la relacion Version Flujo con Version Formulario
        else
            response.Write("404/@/No se encuentra Datos para del flujo formulario:" & VFL_Id & "-" & FOR_Id)
            rs.close
            cnn.close
            response.end()
        end if  
    end if 

    'Grabar Requerimiento
    'Grabar VersionRequerimiento
    zsql = "exec spRequerimiento_Agregar " & VFF_Id & ",'" & REQ_Descripcion & "'," & REQ_EsPadre & "," & REQ_CodReqAnterior & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
    set rs = cnn.Execute(zsql)
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description
        response.Write("503/@/Error Conexión 4:" & ErrMsg & "-" & zsql)
        rs.close
        cnn.close
        response.end()
    End If
    if not rs.eof then
        REQ_Id = rs("REQ_Id")                       'Id del requerimiento agregado
        VRE_Id = rs("VRE_Id")                       'Id de la Version del requerimiento agregado
        REQ_Carpeta = rs("REQ_Carpeta")             'Carpeta
        REQ_Identificador = rs("REQ_Identificador") 'Identificador del requerimiento
    else
        response.Write("503/@/No se pudo grabar el requerimiento:" & VFF_Id)
        rs.close
        cnn.close
        response.end()
    end if 

    wsql = "exec spDatoRequerimiento_Agregar " & session("wk2_usrid") & "," & VRE_Id & "," & DEP_IdActual & "," & DEP_IdOrigen & "," & ESR_Id & "," & FLD_Id & "," & VFO_Id & ",'" & DRE_Obervaciones & "'," & REQ_Id & ",'" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
    set rs = cnn.Execute(wsql)
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description
        response.Write("503/@/Error Conexión 5:" & ErrMsg & "-" & wsql)
        rs.close
        cnn.close
        response.end()
    End If    
    if not rs.eof then
        DRE_Id = rs("DRE_Id")
        DRE_FechaEdit = rs("DRE_FechaEdit")
    else
        response.Write("503/@/No se pudo grabar detalle del requerimiento:" & VRE_Id)
        rs.close
        cnn.close
        response.end()
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

    response.write("200/@/" & REQ_Id & "/@/" & VRE_Id & "/@/" & DRE_Id)
%>