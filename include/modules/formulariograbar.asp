<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<!-- #INCLUDE file="freeASPUpload.asp" -->
<%
	
	if(session("wk2_usrperfil")=5) then	'Auditor
		response.Write("403\\Perfil no autorizado")
		response.End() 			   
	end if	    
	    
	Set up = New FreeASPUpload
	up.Upload()
	Response.Flush	

    DRE_Id              = up.form("DRE_Id")             'Linea del registro de la tabla DatoRequerimiento (Paso en que va el requermiento)    
    swpaso              = up.form("sw")                 'Bifurcacion, decición 2 tomada
    DRE_Obervaciones    = LimpiarURL(up.form("DRE_Obervaciones"))
    UsuarioDestinatario = up.form("dta-UsrDestinatario")'Departamento destino definido en el formualario
    DepDestinatario     = up.form("DepDestinatario")    'Solo cuando se crear el campo en el formulario
    ESR_IdMod           = up.form("ESR_IdMod")          'Modificador de estado, campo tipo "E"

    if(swpaso="") then
        'No se ha tomado ninguna decicion
        swpaso=0
    end if

    if(IsNULL(DepDestinatario) or DepDestinatario="") then
        'Ya no se debe realizar el envio dinamico
        DepDestinatario=0
    end if

    if(IsNULL(ESR_IdMod) or ESR_IdMod="") then
        'Ya no se debe realizar el envio dinamico
        ESR_IdMod=-1      'No existe modificador de estado
    end if

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description
	   cnn.close
	   response.Write("503\\Error Conexión 1:" & ErrMsg)
	   response.End() 			   
	end if		    
    
    if(not IsNULL(UsuarioDestinatario) and UsuarioDestinatario<>"") and (DepDestinatario=1) then
        'Buscar departamento del usuario destinatario
        stql="exec spUsuario_Consultar " & UsuarioDestinatario		
        set rs = cnn.Execute(stql)		
        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description			
            cnn.close 			   
            response.Write("503/@/Error Conexión 2:" & ErrMsg)
            response.End()		
        end if
        if(not rs.eof) then
            DepUsuarioDestinatario = rs("DEP_Id")
        end if
    else
        UsuarioDestinatario=""
        DepUsuarioDestinatario=""
    end if

    'Buscando en el registro actual del requerimiento el VFO_Id asociado y el id del flujo asociado
    ssql="exec spDatoRequerimiento_Consultar " & DRE_Id		
	set rs = cnn.Execute(ssql)		
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 2:" & ErrMsg)
		response.End()		
	end if
    FLD_IdPrev=0
    FLD_IdNext=0

    if(not rs.eof) then
        FLD_Id = rs("FLD_Id")   'Flujo dato id
        FOR_Id = rs("FOR_Id")   'Formulario id
        VFO_Id = rs("VFO_Id")   'Version del formulario id
        VFO_IdOri = rs("VFO_Id")    'Para saber cuando es la primera creacion del formulario
        VFL_Id = rs("VFL_Id")   'Version del flujo id
        VFF_Id = rs("VFF_Id")   'Version Flujo id
        ESR_IdFlujoDatos = rs("ESR_IdFlujoDatos")
        ESR_DescripcionFlujoDato = rs("ESR_DescripcionFlujoDato")   'Accion actual del registro DatoRequerimiento
        ESR_MovimientoFlujoDatos = rs("ESR_MovimientoFlujoDatos")
        DEP_IdActual = rs("DEP_IdActual")
        DEP_IdActualFlujo = rs("DEP_Id")        'Preguntar si es 0 para hacer lectura del dato desde el formulario        
        'if(DEP_IdActualFlujo=0) then
        FLD_CodNot=rs("FLD_CodNot")
        if((not IsNULL(UsuarioDestinatario) and UsuarioDestinatario<>"") and (DepDestinatario=1)) or (DEP_IdActualFlujo=0) then
            if(DepUsuarioDestinatario<>"") then
                DEP_IdActualFlujo=DepUsuarioDestinatario
            end if
        end if
        DEP_IdOrigen = rs("DEP_IdOrigen")       'Departamento creador del requerimiento
        FLD_InicioTermino = rs("FLD_InicioTermino")        
        ESR_IdDatoRequerimiento=rs("ESR_IdDatoRequerimiento")   'Id Estado actula del requerimiento
        ESR_DescripcionDatoRequerimiento = rs("ESR_DescripcionDatoRequerimiento")
        ESR_MovimientoDatoRequerimiento = rs("ESR_MovimientoDatoRequerimiento")
        REQ_Id = rs("REQ_Id")                       'Id del requerimiento agregado
        VRE_Id = rs("VRE_Id")                       'Id de la Version del requerimiento agregado
        REQ_Carpeta = rs("REQ_Carpeta")             'Carpeta
        REQ_Identificador = rs("REQ_Identificador") 'Identificador del requerimiento        
        DEP_Id = rs("DEP_Id")
        DRE_SubEstado = rs("DRE_SubEstado")
        REQ_IdUsuarioEdit = rs("REQ_IdUsuarioEdit") 'Id del creador del requerimiento        
        FLD_IdHijoSi = rs("FLD_IdHijoSi")
        USR_IdCreador = rs("IdCreador")

        LIS_Id = rs("LIS_Id")		'Para envio de correos definidos en la lista de distribucion
		VRE_Id = rs("VRE_Id")		'Para envio de correos definidos en la lista de distribucion
		DEP_IdActualOri = rs("DEP_Id")
		IdEditor = rs("IdEditor")
    else
        cnn.close
	    response.Write("404\\Error no fue podible encontrar el registro de detalle en tabla requerimiento")
	    response.End() 
    end if    

    'Buscar informe obligatorio que aun este pendiente de creacion
    tsql="exec [spInformesCertificadosxVersion_Listar] " & REQ_Id & "," & VFL_Id & ",-1, 1"
    set rs = cnn.Execute(tsql)		
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description			
        cnn.close 			   
        response.Write("503/@/Error Conexión 2:" & ErrMsg)
        response.End()
    End If
	informelistos=0
    informespendientes=0
    certificadoslistos=0
    certificadospendientes=0
    pendientes=0
    listos=0
	do while not rs.eof
        if(CInt(rs("INF_Obligatorio"))=1) then
            'Solo si es obligatorio    
			if(IsNULL(rs("CER_Id")) and IsNULL(rs("PRV_Id"))) then
				'El informe no es certificado ni providencia
				if(rs("INF_Estado")=1) then
					'Ya se encuentra disponible
					informelistos=informelistos+1
				else					
                    if(CInt(FLD_Id)=CInt(rs("FLD_Id"))) then
                        'Se debe crear en este paso
					    informespendientes=informespendientes+1
                    end if
				end if            
			else
                'response.write(rs("ESR_IdVersionCertificado") & "-" & ESR_IdFlujoDatos & "-" & rs("ESR_Id") & "-" & rs("FLD_IdAprobacion") & "-" & FLD_Id)
                'response.end()
                '2-4-3-36-36                
				'El informe es un certificado
				if(not IsNULL(rs("VCE_Id")) and not IsNULL(rs("CER_Id"))) then
					'El informe tiene un certificado generado
					certificadoslistos=certificadoslistos+1                    
                    'if(CInt(rs("ESR_IdVersionCertificado"))=2 and CInt(ESR_IdFlujoDatos)=4) and CInt(FLD_Id)=CInt(rs("FLD_IdAprobacion")) then
                    if(CInt(rs("ESR_IdVersionCertificado"))=2 and CInt(ESR_IdFlujoDatos)=rs("ESR_IdInforme")) and CInt(FLD_Id)=CInt(rs("FLD_IdAprobacion")) then
                        'Certificado en estado pendiente y estado del flujo actual es visado
                        'Y debe aprobarse en este paso
                        'Actualizar certificado a estado aprobado 8
                        'response.write(rs("ESR_IdVersionCertificado") & "-" & ESR_IdFlujoDatos & "-" & rs("ESR_Id") & "-" & rs("FLD_IdAprobacion") & "-" & FLD_Id)
                        'response.end()
                        VCE_Estado=1    'Activo
                        ESR_IdVersionCertificado=8  'Aprobado
                        sql="exec spVersionCertificado_Modificar " & rs("VCE_Id") & "," & REQ_Id & "," & rs("CER_Id") & "," & VCE_Estado & "," & ESR_IdVersionCertificado & ",'" & rs("VCE_Glosa") & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
                        set ry = cnn.Execute(sql)
                        on error resume next
                        if cnn.Errors.Count > 0 then 
                            ErrMsg = cnn.Errors(0).description
                            response.write("503/@/Error 8 [spVersionCertificado_Modificar]")
                            cnn.close 		
                            response.end
                        End If    
                    end if
				else
                    if(CInt(FLD_Id)=CInt(rs("FLD_Id")) and not IsNULL(rs("CER_Id"))) then
					    'No existe ningun certificado generado para este paso
					    certificadospendientes=certificadospendientes+1
                    end if
				end if

                'El informe es una providencia
				if(not IsNULL(rs("VPV_Id")) and not IsNULL(rs("PRV_Id"))) then                    
					'El informe tiene un certificado generado                    
					certificadoslistos=certificadoslistos+1                    
                    'if(CInt(rs("ESR_IdVersionCertificado"))=2 and CInt(ESR_IdFlujoDatos)=4) and CInt(FLD_Id)=CInt(rs("FLD_IdAprobacion")) then
                    if(CInt(rs("ESR_IdVersionProvidencia"))=2 and CInt(ESR_IdFlujoDatos)=rs("ESR_IdInforme")) and CInt(FLD_Id)=CInt(rs("FLD_IdAprobacion")) then
                        'Providencia en estado pendiente y estado del flujo actual es visado
                        'Y debe aprobarse en este paso
                        'Actualizar providencia a estado aprobado 8
                        VPV_Estado=1    'Activo
                        ESR_IdVersionProvidencia=8  'Aprobado
                        sql="exec spVersionProvidencia_Modificar " & rs("VPV_Id") & "," & REQ_Id & "," & rs("PRV_Id") & "," & VPV_Estado & "," & ESR_IdVersionProvidencia & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
                        set ry = cnn.Execute(sql)
                        on error resume next
                        if cnn.Errors.Count > 0 then 
                            ErrMsg = cnn.Errors(0).description
                            response.write("503/@/Error 8 [spVersionProvidencia_Modificar] " & sql & " " & ErrMsg)
                            cnn.close 		
                            response.end
                        End If    
                    end if
				else
                    if(CInt(FLD_Id)=CInt(rs("FLD_Id")) and not IsNULL(rs("PRV_Id"))) then
					    'No existe ninguna providencia generada para este paso
					    certificadospendientes=certificadospendientes+1
                    end if
				end if

			end if		
		end if
        rs.movenext
    loop
    
	pendientes=certificadospendientes+informespendientes
    listos=informelistos+certificadoslistos
    if(pendientes>0 and CInt(swpaso)<>-1) then
		ErrMsg ="Existen informes obligatorios no creados para este paso: "	& FLD_Id & "-" & informespendientes & "-" & certificadospendientes
		cnn.close 			   
		response.Write("403/@/Error :" & ErrMsg)
		response.End()
	end if

    if(CInt(swpaso)<>-1) then
        'Crear nueva version del formulario cuando no sea devolución
        gsql = "exec spVersionFormulario_Agregar " & FOR_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
        set rs = cnn.Execute(gsql)
        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description
            response.Write("503\\Error Conexión 2:" & ErrMsg & "-" & bsql)
            rs.close
            cnn.close
            response.end()
        End If
        if not rs.eof then
            VFO_Id = rs("VFO_Id")   'Nuevo Id de version formulario para grabar en el nuevo registro en trabla DatosRequerimiento
        else
            cnn.close
            response.Write("404\\Error no fue posible generar una nueva versión para el formualrio : " & FOR_Id)
            response.End()
        end if    
    end if
    bandera = ""
    'Buscando el paso actual del flujo en que esta el requerimiento en el flujo para obtener el siguiente
    bsql = "exec spFlujoDatos_Listar " & VFL_Id & ", 1"    
    Set rs = Server.CreateObject("ADODB.Recordset")

    rs.CursorType = 1
	rs.CursorLocation = 3
   	rs.Open bsql, cnn

    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description
        response.Write("503\\Error Conexión 2:" & ErrMsg & "-" & bsql)
        rs.close
        cnn.close
        response.end()
    End If
    rs.movefirst
    do while not rs.eof
        if(rs("FLD_Id")=FLD_Id) then
            rs.moveprevious
            if not rs.bof then
                FLD_IdPrev       = rs("FLD_Id")       
                DEP_IdActualPrev = rs("DEP_Id")
                FLD_InicioTerminoPrev = rs("FLD_InicioTermino")
                ESR_IdFlujoDatosPrev = rs("ESR_Id")
                ESR_DescripcionFlujoDatoPrev = rs("ESR_Descripcion")
                DEP_IdPrev = rs("DEP_Id")
                'rs.movenext     'Lo dejo en el registro coincidente.                
            else
                FLD_IdPrev = -1                
            end if
            if(FLD_IdPrev = -1) then
                rs.movefirst        'Vuelvo al registro actual
                rs.movenext         'Voy al siguiente
            else
                rs.movenext         'Vuelvo al registro actual
                rs.movenext         'Voy al siguiente
            end if
                        
            if not rs.eof then
                FLD_IdNext       = rs("FLD_Id")                       
                FLD_InicioTerminoNext = rs("FLD_InicioTermino")
                ESR_IdFlujoDatosNext = rs("ESR_Id")
                ESR_DescripcionFlujoDatoNext = rs("ESR_Descripcion")
                DEP_IdNext = rs("DEP_Id")
                bandera = FLD_IdNext
            else
                FLD_IdNext=-1   'No hay mas paso en el flujo
            end if
            exit do
        end if
        rs.movenext
    loop    
    
    ESR_Id = ESR_IdFlujoDatos

    if(Cint(swpaso)=-1) then
        ESR_Id=6    'Devuelto
        'Solo cuando se solicita devolución
        'Buscar el paso anterior cuando se devuelve                    
        lsql = "exec [spDatoRequerimientoxFlujoDato_Listar] " & VRE_Id    
        Set ww = Server.CreateObject("ADODB.Recordset")

        ww.CursorType = 1
        ww.CursorLocation = 3
        ww.Open lsql, cnn
        on error resume next	
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description			
            cnn.close 			   
            response.Write("503/@/Error Conexión 2:" & ErrMsg)
            response.End()
        End If
        ww.movelast
        ww.moveprevious
        'Flujo anteror
        if not ww.eof then                        
            FLD_IdDev = ww("FLD_Id")
            DEP_IdACtualDev = ww("DEP_IdActual")
            ESR_IdDevuelto = ww("ESR_Id")
        else
            'Estoy en el primer registro, no se puede devolver
            DRE_IdDev = 0
            FLD_IdDev = 0
        end if
        'Buscar el ultimo registro del requiriemto
    end if
    msg="Requerimiento"
    id = REQ_Id
    if(IsNull(VFO_IdOri)) then
        'Si es creación del formulario
        ESR_Id=1    'Creacion del formulario
        msg = "Formulario"
        id = VFO_Id

        'Buscar el jefe del departamento creador.
        ysql="exec spJefeDepartamento_Mostrar " & session("wk2_usrdepid") & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
        set rs = cnn.Execute(ysql)		
        on error resume next        
        if not rs.eof then
            'Jefatura
            USR_Id = rs("USR_Id")
            USR_Usuario = rs("USR_Usuario")     'Jefe del departamento creador
            USR_Nombre = rs("USR_Nombre")
            USR_Apellido = rs("USR_Apellido")
            USR_Rut = rs("USR_Rut")
            USR_Dv = rs("USR_Dv")
            USR_Firma = rs("USR_Firma")        
        end if

        'Envio de correo al jefe de la unidad
        wsql = "exec [spCorreoxUsuario_Enviar] " & USR_Id & "," & ESR_Id & "," & REQ_Id & ",'" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'" 
        set rs = cnn.Execute(wsql)
        on error resume next
        'No se detiene la ejecucion si existe un error en la ejecucion del envio del mail
    end if
    'Primera grabación del regitro datarequerimiento
    'Modificador de estado si es que existe
    if(ESR_IdMod<>-1) then  'Modificador existe
        ESR_Id = ESR_IdMod  'Modificando el estado del requerimiento por el enviado por parametro
    end if
    wsql = "exec spDatoRequerimiento_Agregar " & session("wk2_usrid") & "," & VRE_Id & "," & DEP_IdActual & "," & DEP_IdOrigen & "," & ESR_Id & "," & FLD_Id & "," & VFO_Id & ",'" & DRE_Obervaciones & "'," & REQ_Id & ",'" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
    set rs = cnn.Execute(wsql)
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description
        response.Write("503\\Error Conexión 5.0:" & ErrMsg & "-" & wsql & "-" & FLD_IdPrev & "-" & FLD_IdNext)
        rs.close
        cnn.close
        response.end()
    End If    
    if not rs.eof then
        DRE_Id = rs("DRE_Id")
        DRE_FechaEdit = rs("DRE_FechaEdit")
    end if
    
    'Creación del mensaje
    'Busqueda de la descripcion del Estado
    vsql = "exec spEstadoRequerimiento_Consultar " & ESR_Id
    set rs = cnn.Execute(vsql)
    on error resume next
    if not rs.eof then
        ESR_DescripcionMensaje = rs("ESR_Descripcion")
        MEN_Mensaje = msg & " Nro. " & id & ", " & ESR_DescripcionMensaje & " por : " & session("wk2_usrnom") & " - " & DRE_FechaEdit
    end if

    rsql = "exec [spMensaje_Agregar] " & ESR_Id & "," & REQ_Id & ",'" & MEN_Mensaje & "','','" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
    set rs = cnn.Execute(rsql)
    on error resume next
    'No se detiene el proceso si falla la grabacion del mensaje    

    if((ESR_MovimientoDatoRequerimiento>0 or not IsNULL(DEP_IdActualFlujo)) and (FLD_InicioTermino<>3 and FLD_InicioTermino<>4) and (CInt(swpaso)=0)) or ((ESR_MovimientoDatoRequerimiento>0 or not IsNULL(DEP_IdActualFlujo)) and (FLD_InicioTermino=4) and (CInt(swpaso)=0))  then
    'if(ESR_MovimientoDatoRequerimiento>0 or not IsNULL(DEP_IdActualFlujo)) and (FLD_InicioTermino<>3) and (CInt(swpaso)=0) then
    'if(ESR_MovimientoFlujoDatos>0) and (FLD_InicioTermino<>3) and (CInt(swpaso)=0) then    'No funciona para comrpas si para boletas   
        'Si no es bifurcacion
        'Solo los estado que avanzan
        'El flujo debe seguir con el siguien paso        
        'Condicion cuando se esta grabando en el paso de cierre del requerimiento FLD_IdNext=-1        
        'Se agrega condicion FLD_InicioTermino<>4 para poder cerrar un flujo ademas de poder seleccionar las decisiones. (3 opciones)        
        if(FLD_IdNext<>-1) then
            'if(FLD_CodNot=2 and DEP_IdActualFlujo=0) then  'No avanza, dato del flujo no del requerimiento
            '    FLD_Id=FLD_Id
            'else
                FLD_Id=FLD_IdNext
            'end if            
        end if
        sx="no"
        if(FLD_CodNot=2 and DEP_IdActualFlujo=0) then
            DEP_IdActual=DEP_IdActual
            sx="si"
        else
            DEP_IdActual=DEP_IdNext
        end if                
        REQ_IdUsuarioEdit="NULL"
        if(DEP_IdActual="" or IsNULL(DEP_IdActual)) then
            DEP_IdActual = DEP_IdActualFlujo 'Es la jefatura del paso actual.
        end if
        'response.Write(DEP_IdActual & "-" & FLD_CodNot & "-" & DEP_IdActualFlujo & "-" & sx & "-" & DepUsuarioDestinatario)
        'response.end()
        bandera = "b-" & ESR_MovimientoFlujoDatos & "-" & FLD_InicioTermino & "-" & swpaso
    else        
        if(CInt(swpaso)=1 and CInt(FLD_IdHijoSi)<>0) then
            'Decicion tomada, se debe ir al paso del flujo de la decicion
            FLD_Id=FLD_IdHijoSi
            wl="exec spFlujoDatos_Consultar " & FLD_Id
            set rr = cnn.Execute(wl)
            on error resume next
            if cnn.Errors.Count > 0 then 
                ErrMsg = cnn.Errors(0).description
                response.Write("503\\Error Conexión 5:" & ErrMsg & "-" & wsql & "-" & FLD_IdPrev & "-" & FLD_IdNext)
                rs.close
                cnn.close
                response.end()
            End If    
            if not rr.eof then
                'ESR_Id=rr("ESR_Id")
                DEP_IdActual=rr("DEP_Id")
                REQ_IdUsuarioEdit="NULL"
                if(DEP_IdActual="" or IsNULL(DEP_IdActual)) then
                    DEP_IdActual = DEP_IdActualFlujo 'Es la jefatura del paso actual.
                end if
            end if
        else
            if(FLD_InicioTermino=3 and FLD_IdHijoSi<>0) then
                FLD_Id = FLD_IdHijoSi   'Bifurcación
                rl="exec spFlujoDatos_Consultar " & FLD_IdHijoSi		
                set sw = cnn.Execute(rl)
                on error resume next
                if cnn.Errors.Count > 0 then 
                    ErrMsg = cnn.Errors(0).description			
                    cnn.close 			   
                    response.Write("503/@/Error Conexión 2:" & ErrMsg)
                    response.End()		
                end if
                
                if not rl.eof then
                    DEP_IdActual = sw("DEP_Id")
                    DepDescripcionActual = sw("DEP_DescripcionCorta")			
                end if
            else
                if(Cint(swpaso)=-1) then
                    FLD_Id = FLD_IdDev
                    DEP_IdACtual = DEP_IdACtualDev
                end if
            end if        
        end if
    end if

    'Envio de mail de aviso al departamento donde va el flujo
    'ESR_Id = 1, Crear, siempre y cuando no sea jefatura
    'ESR_Id = 3, Revisado
    'ESR_Id = 4, Visado
    'ESR_Id = 6, Devuelto    
    'ESR_Id = 10 Adjudicado
    'if(CInt(ESR_IdFlujoDatos) = 3 or CInt(ESR_IdFlujoDatos) = 4 or CInt(ESR_IdFlujoDatos) = 6 or CInt(ESR_IdFlujoDatos) = 10) then
    if(((CInt(ESR_Id) = 1 and not IsNULL(DEP_IdActualFlujo)) or CInt(ESR_Id) = 3 or CInt(ESR_Id) = 4 or CInt(ESR_Id) = 6 or CInt(ESR_Id) = 8 or CInt(ESR_Id) = 10 or CInt(ESR_Id) = 20 or CInt(ESR_Id) = 22 or (CInt(ESR_Id) >= 24) and CInt(ESR_Id) <= 29) and FLD_InicioTermino<>2) then
        'Preguntar por DEP_IdDestino para solo enviar al nuevo propietario y no a todo el departamento
        if(not IsNULL(UsuarioDestinatario) and UsuarioDestinatario<>"") and (DepDestinatario=1) then
            rsql = "exec [spCorreoxUsuario_Enviar] " & UsuarioDestinatario & "," & ESR_Id & "," & REQ_Id & ",'" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'" 
            set rs = cnn.Execute(rsql)
            on error resume next
            'No se detiene la ejecucion si existe un error en la ejecucion del envio del mail
        else
            'Cuando no es jefatura
            hsql = "exec [spCorreoxDepartamento_Enviar] " & DEP_IdActual & "," & ESR_Id & "," & REQ_Id & ",'" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'" 
            set rs = cnn.Execute(hsql)
            on error resume next
            'No se detiene la ejecucion si existe un error en la ejecucion del envio del mail        
        end if

        if(CInt(ESR_Id) = 6 or CInt(ESR_Id) = 10) then
            'Envio de correo al propietario
            'ESR_Id = 6 Devuelto    
            'ESR_Id = 10 Adjudicado
            rsql = "exec [spCorreoxUsuario_Enviar] " & USR_IdCreador & "," & ESR_Id & "," & REQ_Id & ",'" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'" 
            set rs = cnn.Execute(rsql)
            on error resume next
            'No se detiene la ejecucion si existe un error en la ejecucion del envio del mail
        end if 

        'Para pasos que tengan lista de distribucion
        'if(not IsNULL(LIS_Id)) and (CInt(ESR_Id) <> 6 and CInt(ESR_Id) <> 10) then
        if(not IsNULL(LIS_Id)) and (CInt(ESR_Id) = 20) then
            'ESR_Id = 20 Pagado
            isql = "exec spDetalleListaDistribucion_Listar " & LIS_Id
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
                    'Cuando DEP_Id <> null no se toma en cuenta el paso de la lista de distribución
                    'if(IsNULL(FLD_Id)) then	'Paso Actual
                        DEP_Idlst = DEP_Idlst 	'Departamento de la lista de distribucion
                        ESR_Idlst = ESR_Id		'Estado del paso actual
                        USR_IdEditorlst = null
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
    end if

    ESR_Id = 2  'Queda en estado pendiente siempre
    'Asignar el usuario del formulario cuando DEP_IdDestino tenga información
    REQ_IdUsuarioEdit = "NULL"
    
    'Asignacion al departamento y usuario ingresados en el formulario, solo si el dato existe en el formulario.
    if(not IsNULL(UsuarioDestinatario) and UsuarioDestinatario<>"") and (DepDestinatario=1) then        
        REQ_IdUsuarioEdit=UsuarioDestinatario
        DEP_IdActual=DepUsuarioDestinatario
    end if

    'Segunda grabación del regitro datarequerimiento
    wsql = "exec spDatoRequerimiento_Agregar " & REQ_IdUsuarioEdit & "," & VRE_Id & "," & DEP_IdActual & "," & DEP_IdOrigen & "," & ESR_Id & "," & FLD_Id & "," & VFO_Id & ",'" & DRE_Obervaciones & "'," & REQ_Id & ",'" & REQ_Identificador & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
    set rs = cnn.Execute(wsql)
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description
        response.Write("503\\Error Conexión 5.1:" & ErrMsg & "-" & wsql & "/" & DRE_Id & "/" & FLD_Id & "/" & FLD_IdPrev & "/" & FLD_IdNext)
        rs.close
        cnn.close
        response.end()
    End If    
    if not rs.eof then
        DRE_Id = rs("DRE_Id")
    end if
    'Envio de mail de aviso al departamento donde va el flujo    

    'Consultando si la relacion ya existe para no volver a crearla
    msql = "exec [spVersionFlujoFormularioRelacion_Consultar] " & VFL_Id & "," & FOR_Id    
    set rs = cnn.Execute(msql)
	on error resume next
	if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description
		response.Write("503\\Error Conexión 6:" & ErrMsg & "-" & msql)
		rs.close
		cnn.close
		response.end()
	End If
    if not rs.eof then
        VFF_Id = rs("VFF_Id")
    else	
        'Grabar VersionFlujoFormulario  VFL_Id, FOR_Id      Se relaciona el id del formualrio al flujo que viene por parametro
        xsql = "exec [spVersionFlujoFormulario_Agregar] " & VFL_Id & "," & FOR_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
        set rs = cnn.Execute(xsql)
        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description
            response.Write("503\\Error Conexión 7:" & ErrMsg & "-" & xsql)
            rs.close
            cnn.close
            response.end()
        End If
        if not rs.eof then
            VFF_Id = rs("VFF_Id")   'Id de la relacion Version Flujo con Version Formulario
        end if  
    end if        

    if(CInt(swpaso)<>-1) then
        'Grabar DatosFormulario solo si no es devolución
        'leer todos los campos imput que viene en el post    
        aKeys = up.FormElements.Keys
        For i = 0 To up.FormElements.Count -1 ' Iterate the array
            'response.write aKeys(i) & " = " & up.FormElements.Item(aKeys(i)) & "<BR>"
            if(ucase(trim(mid(aKeys(i),1,3)))="DTA") and ((ucase(trim(mid(aKeys(i),len(aKeys(i))-2,3)))<>"-ID")) then
                'response.write aKeys(i) & " = " & up.FormElements.Item(aKeys(i)) & "<BR><BR>"
                FDI_IdName = aKeys(i) & "-id"
                FDI_Id = up.form(FDI_IdName)
                if(FDI_Id<>"") then
                    asql = "exec spDatosFormulario_Agregar " & FDI_Id & ",'" & LimpiarUrl(up.FormElements.Item(aKeys(i))) & "'," & VFO_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
                    set rs = cnn.Execute(asql)
                    on error resume next
                    if cnn.Errors.Count > 0 then 
                        ErrMsg = cnn.Errors(0).description
                        response.Write("503\\Error Conexión 6:" & ErrMsg & "-" & asql)
                        rs.close
                        cnn.close
                        response.end()
                    End If
                end if
            else
            end if
        Next

        'Subiendo adjuntos
        'Creando la carpeta en el servidor si esta no existe
        dim fs,f
        path="d:\DocumentosSistema\WorkFlow\" & REQ_Carpeta & "\adjuntos"
        folders = Split(path, "\")
        currentFolder = ""
        set fs=Server.CreateObject("Scripting.FileSystemObject")
        For i = 0 To UBound(folders)
            currentFolder = currentFolder & folders(i)
            'response.write("</br>" & currentFolder & "</br>")
            If fs.FolderExists(currentFolder) <> true Then
                Set f=fs.CreateFolder(currentFolder)
                Set f=nothing       
            End If      
            currentFolder = currentFolder & "\"
        Next
        set f=nothing
        set fs=nothing	
        
        ruta=path		
        up.Save(ruta)	'Subiendo archivo(s)
    end if
    bandera = bandera & " filtro:" & filtro & " ESR_IdDatoRequerimiento: " & ESR_IdDatoRequerimiento & " DEP_IdActualFlujo: " & DEP_IdActualFlujo & " UsuarioDestinatario: " & UsuarioDestinatario & " DepDestinatario: " & DepDestinatario
	response.write("200\\" & VFO_Id & "\\" & FLD_Id & "\\" & DRE_Id & "\\" & FLD_IdPrev & "\\" & FLD_IdNext & "\\" & bandera)
%>