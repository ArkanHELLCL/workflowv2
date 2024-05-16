<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<!--#include File="adovbs.inc"-->  
<!--#include File="functions.inc"-->  
<%
modo=request("modo")
VFL_Id=request("VFL_Id")
DRE_Id=request("DRE_Id")

id=request("id")

key1=request("key1")
key2=request("key2")
key3=request("key3")

'key4=request("key4")
'key5=request("key5")


tabId = request("tabId")

if(VFL_Id="") then
    VFL_Id = key1
end if
if(DRE_Id="") then
    DRE_Id = key3
end if
if(DRE_Id="") then
    DRE_Id=0
end if
if(id="") then
    id=0
end if

if(DRE_Id<>"" and DRE_Id<>0) then
    modo = 2
end if

set cnn = Server.CreateObject("ADODB.Connection")
on error resume next	
cnn.open session("DSN_WorkFlowv2")
if cnn.Errors.Count > 0 then 
    ErrMsg = cnn.Errors(0).description	   
    cnn.close
    response.Write("503/@/Error Conexión 1:" & ErrMsg)
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
End If
if not rs.eof then
    FLD_Id=rs("FLD_Id")
    FLD_Prioridad = rs("FLD_Prioridad")
    FLD_CodigoPaso = rs("FLD_CodigoPaso")
    DEP_IdActual = rs("DEP_IdActual")
    VFL_Id=rs("VFL_Id")
    DepDescripcionOrigen=rs("DepDescripcionOrigen")
    REQ_Id=rs("REQ_Id")
    VRE_Id=rs("VRE_Id")
    REQ_Carpeta=rs("REQ_Carpeta")
    VRE_Id = rs("VRE_Id")

    'FLD_InicioTermino = rs("FLD_InicioTermino")
	'FLD_IdHijoSi = rs("FLD_IdHijoSi")
end if

sql="exec spFlujoDatos_Listar " & VFL_Id & ", 1"
set rs = cnn.Execute(sql)
rs.movefirst            'Primer registro cuando es nuevo requerimiento
do while rs.eof
    if(FLD_Id=rs("FLD_Id")) then
        FLD_Prioridad=rs("FLD_Prioridad")
        ESR_Id=rs("ESR_Id")
        ESR_Descripcion=rs("ESR_Descripcion")
        FLU_Id=rs("FLU_Id")
        FLU_Descripcion=rs("FLU_Descripcion")
        'FLD_InicioTermino=rs("FLD_InicioTermino")
        DEP_Id=rs("DEP_Id")
        DEP_Descripcion=rs("DEP_Descripcion")
        DEP_Codigo=rs("DEP_Codigo")
        FLD_DiasLimite=rs("FLD_DiasLimite")
        FLD_CodigoPaso=rs("FLD_CodigoPaso")
        exit do
    end if
    rs.movenext             
loop
if(IsNULL(ESR_Id) or ESR_Id="") then
    ESR_Id=0
end if
rs.movenext             'Siguiente registro para ver a donde va
if not rs.eof then		
    FLD_PrioridadNEW=rs("FLD_Prioridad")
    ESR_IdNEW=rs("ESR_Id")
    ESR_DescripcionNEW=rs("ESR_Descripcion")
    FLU_IdNEW=rs("FLU_Id")
    FLU_DescripcionNEW=rs("FLU_Descripcion")
    FLD_InicioTerminoNEW=rs("FLD_InicioTermino")
    DEP_IdNEW=rs("DEP_Id")
    DEP_DescripcionNEW=rs("DEP_Descripcion")
    DEP_CodigoNEW=rs("DEP_Codigo")
    FLD_DiasLimiteNEW=rs("FLD_DiasLimite")
    FLD_CodigoPasoNEW=rs("FLD_CodigoPaso")
end if

'Buscando el ultimo DRE_Id del requerimniento en curso
lsql="exec [spDatoRequerimientoxRequerimiento_Listar] " & REQ_Id
set ww = cnn.Execute(lsql)		
on error resume next
if cnn.Errors.Count > 0 then 
    ErrMsg = cnn.Errors(0).description			
    cnn.close 			   
    response.Write("503/@/Error Conexión 2:" & ErrMsg)
    response.End()
End If
if not ww.eof then
    DRE_IdMax = ww("DRE_Id")
    FLD_IdMax = ww("FLD_Id")
end if
Departamento=""

call menu
'response.write(VRE_Id & "-" & VFL_Id & "-" & FLD_Id & "-" & FLD_Prioridad & "-" & FLD_InicioTermino & "-" & modo & "-" & DRE_Id & "-" & session("wk2_usrperfil") & "-" & DEP_IdNEW )

'function menu(xPRY_Hito,xPRY_Step,xCRT_Step,modo)
function menu
    'Buscando las cabeceras de mensajes nuevos para el proyecto activo solo si no es hito creacion
    if modo<>1 then        
        sql = "exec spUsuarioMensajeProyectoHeadNuevo_Contar " & REQ_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"

        set rs = cnn.Execute(sql)
        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description
            'cnn.close 			   		
        End If	
        if not rs.eof then
            MensajeProyectosNuevos=rs("MensajeProyectosNuevos")		
        else
            MensajeProyectosNuevos=0
        end if	

        'Buscando respuestas nuevas en los proyectos
        sql = "exec spUsuarioMensajeProyectoRespuestaNuevo_Contar " & REQ_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"

        set rs = cnn.Execute(sql)
        on error resume next
        if cnn.Errors.Count > 0 then 
        '    ErrMsg = cnn.Errors(0).description
            'cnn.close 			   		
        End If	
        if not rs.eof then
            MensajeRespuestaProyectosNuevos=rs("MensajeRespuestaProyectosNuevos")		
        else
            MensajeRespuestaProyectosNuevos=0
        end if	
    else   
        MensajeProyectosNuevos=0
        MensajeRespuestaProyectosNuevos=0        
    end if

    if(MensajeProyectosNuevos>0 and MensajeRespuestaProyectosNuevos>0) then
        mensajesproyectos="<i class='fas fa-comments'></i>Mensajes <span class='badge red' style='font-size:9px;'>" & MensajeProyectosNuevos & "</span> <span class='badge blue' style='font-size:9px;'>" & MensajeRespuestaProyectosNuevos & "</span>"
    else
        if(MensajeProyectosNuevos>0 and MensajeRespuestaProyectosNuevos=0) then
            mensajesproyectos="<i class='fas fa-comments'></i>Mensajes <span class='badge red' style='font-size:9px;'>" & MensajeProyectosNuevos & "</span>"
        else
            if(MensajeProyectosNuevos=0 and MensajeRespuestaProyectosNuevos>0) then
                mensajesproyectos="<i class='fas fa-comments'></i>Mensajes <span class='badge blue' style='font-size:9px;'>" & MensajeRespuestaProyectosNuevos & "</span>"
            else
                mensajesproyectos="<i class='fas fa-comments'></i>Mensajes"
            end if
        end if
    end if

    'Verificar que informes se pueden descargar para informar con badge
    tsql="exec [spInformesCertificadosxVersion_Listar] " & REQ_Id & "," & VFL_Id & ",-1, 1"       'Todos los informes en cualquier paso que esten en estado 1 FLD_Id, FLD_Estado
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
        if(rs("FLD_Id")>FLD_IdMax) then
            exit do
        end if
        if(IsNULL(rs("CER_Id")) and IsNULL(rs("PRV_Id"))) then
            'El informe no es certificado o no es una providencia, es decir es un informe normal           
            if(rs("INF_Estado")=1) then
                'Ya se encuentra disponible
                informelistos=informelistos+1
            else
                'Se debe crear
                informespendientes=informespendientes+1
            end if            
        else
            'El informe es un certificado o una providencia
            if(not IsNULL(rs("VCE_Id")) or not IsNULL(rs("VPV_Id"))) then
                'El informe tiene un certificado generado
                certificadoslistos=certificadoslistos+1
            else
                'No existe ningun certificado generado
                certificadospendientes=certificadospendientes+1
            end if
        end if
        rs.movenext
    loop

    pendientes=certificadospendientes+informespendientes
    listos=informelistos+certificadoslistos
    
    informes="<i class='far fa-file-alt'></i>Informes "
    if(listos>0 and pendientes>0) then
        informes=informes & "<span class='badge red inf' style='font-size:9px;'>" & pendientes & "</span> <span class='badge blue' style='font-size:9px;'>" & listos & "</span>"
    else
        if(listos=0 and pendientes>0) then
            informes=informes & "<span class='badge red inf' style='font-size:9px;'>" & pendientes & "</span>"
        else
            if(listos>0 and pendientes=0) then
                informes=informes & "<span class='badge blue' style='font-size:9px;'>" & listos & "</span>"
            else
                
            end if
        end if
    end if    
    'Adjuntos
    path="d:\DocumentosSistema\WorkFlow\" & REQ_Carpeta & "\adjuntos"
    corr = 0
    Set fso = CreateObject("Scripting.FileSystemObject")
    If fso.FolderExists(path) <> true Then
        corr = 0
    else
        Set directorio = fso.GetFolder (path)			
        For Each fichero IN directorio.Files        
            corr=corr+1                     
        Next
    end if
    
    if(corr>0) then
        adjuntos="<i class='fas fa-cloud-download-alt'></i>Adjuntos <span class='badge blue' style='font-size:9px;'>" & corr & "</span>"
    else
        adjuntos="<i class='fas fa-cloud-download-alt'></i>Adjuntos"
    end if
    

    menucierre=array(informes,mensajesproyectos,adjuntos)
    menucierrepag=array("/informes-flujo","/mensajes-requerimiento-modal","/adjuntos-modal")

    menucierrelen=Ubound(menucierre)

    'Dibujando el menu
    'Menu fijo
    clase="category text-primary"
    salida = salida + "<ul class='nav nav-stacked nav-tree' role='tab-list'>"

    salida= salida +  "<li role='presentation' class='category text-primary menus'><i class='fas fa-bars' aria-hidden='true'></i> Menú</li>"
    for j=0 to menucierrelen	'Mostrando el menu de la cabecera solo cuando el hito esta cerrado
        salida = salida + "<li role='presentation' class='menus'><a role='tab' href='#' data-url='" & menucierrepag(j) & "' data-mode='" & modo & "' data-step='" & xCRT_Step & "'>" & menucierre(j) & "</a></li>"
    next

    'Menu de pasos
    salida = salida + "<li class='pasos' style='padding-top:15px;opacity:0;visiblity:hidden'></li>"    
    salida = salida + "<li role='presentation' class='" & clase & " pasos' style='margin-top:0;'><i class='fas fa-sitemap' aria-hidden='true' style='padding-right:7px;'></i> PASOS</li>"
    
    'Creando el step creacion  
    j=0  
    ysql = "exec spDatoRequerimientoxRequerimiento_Listar " & REQ_Id & ",1"     'El ultimo DRE_Id para REQ_Id con estado Creado ESR_Id=1    
    set rsz = cnn.Execute(ysql)
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description			
        cnn.close 			   
        response.Write("503/@/Error Conexión 6:" & ErrMsg)
        response.End()
    End If
    if not rsz.eof then         
        'if (rsz("DRE_Id")=DRE_IdMax) or (FLD_Id=rsz("FLD_Id")) then       'Solo en la creación y para flujos que no tienen creacion
        if(IsNULL(rsz("DEP_Id"))) or (rsz("DRE_Id")=DRE_IdMax) then      'Solo en la creación y para flujos que no tienen creacion
            j=1
            if(IsNULL(rsz("VFO_Id"))) then
                clase="active"
                clase2="act 1"
                id=1
            else
                if(j = CInt(id)) then
                    clase="active"                    
                    clase2="act 2"
                    if(id="" or id=0) then
                        id=j
                    end if
                else
                    clase=""
                    clase2="done"  
                end if
            end if        
            DEPDescripcion="Creación " & rsz("DepDescripcionCortaActual")
            salida = salida + "<li role='presentation' class='" & clase & " pasos'><a role='tab' href='#' data-mode='" & modo & "' data-vfl='" & rsz("VFL_Id") & "' data-dre='" & rsz("DRE_Id") & "' data-id='" & j & "' class='step'><i class='globo pull-left " & clase2 & "'>" & (j) & "</i> " & DEPDescripcion & " </a></li>"

            DRE_IdCreacion = rsz("DRE_Id")
        end if
    else
        cnn.close 			   
        response.Write("404/@/Error no fue posible encontrar registro detalle de requerimiento :" & REQ_Id)
        response.End()
    end if
    'Creando el step creacion    

    'Buscar el ultimo regitro del flujo
	lr="exec [spFlujoDatosUltimoRegistro_Consultar] " & VFL_Id & ",1"		
	set ww = cnn.Execute(lr)		
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 2:" & ErrMsg)
		response.End()		
	end if
    
	if not ww.eof then
		FLD_IdUltimo = ww("FLD_Id")	        
	end if

    'Creando los siguientes step ya almacenados en la tabla DatosRequerimiento    
    FLD_IdLast=0
    sql = "exec [spDatoRequerimientoxFlujoDato_Listar] " & VRE_Id    
    Set rs = Server.CreateObject("ADODB.Recordset")

    rs.CursorType = 1
	rs.CursorLocation = 3
   	rs.Open sql, cnn

    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description			
        cnn.close 			   
        response.Write("503/@/Error Conexión 6:" & ErrMsg)
        response.End()
    End If
    first = true
    do while not rs.eof
        ESR_Id = rs("ESR_Id")
                
        'Siguientes pasos ya registrados en la tabla DatoRequerimiento        
        if(rs("ESR_Id")=1 and IsNULL(rs("VFO_Id"))) then        
            'Requerimiento creado, formulario no, debe mantenerse en el paso de creacion
            'Al parecer nunca se da este caso
            clase="disabled"
            clase2="pend"
            j=j+1
            'if(IsNULL(rs("DEP_Id"))) then
            if(IsNULL(rs("DEP_IdFlujo"))) then
                DEPDescripcion = "Jefatura " & rs("DEP_DescripcionCortaActual")
                Departamento = DEPDescripcion
            else                                
                'DEPDescripcion = rs("DEP_DescripcionCortaActual")
                DEPDescripcion = rs("DEP_DescripcionCortaFlujo")
                Departamento = DEPDescripcion                
            end if
            salida = salida + "<li role='presentation' class='" & clase & " pasos'><a role='tab' href='#' data-mode='" & modo & "' data-vfl='" & rs("VFL_Id") & "' data-dre='0' data-id='" & j & "' class='step'><i class='globo pull-left " & clase2 & "'>" & (j) & "</i> " & DEPDescripcion & "</a></li>"            
        else
            if (CInt(DRE_IdCreacion) <> CInt(rs("DRE_Id"))) then
                j=j+1
                if(j = CInt(id)) then
                    clase="active"
                    clase2="act 3"
                    if(id="" or id=0) then
                        id=j
                    end if
                else
                    clase=""
                    clase2="done"  
                end if
                rs.movenext
                if(rs.eof) then            
                    if(id="" or id=0) then
                        id=j
                        clase="active"
                        clase2="act 4"
                    end if
                end if
                
                rs.moveprevious
                if(IsNULL(rs("DEP_IdFlujo")) or (rs("ESR_IdFlujoDatos")=4) or (rs("ESR_IdFlujoDatos")=8) ) then
                    DEP_Descripcion = "Jefatura " & rs("DEP_DescripcionCortaActual")                     
                else
                    if IsNULL(rs("VFO_Id")) or rs("FLD_InicioTermino")=1 then
                        DEP_Descripcion = "Creación " &  rs("DEP_DescripcionCortaActual")
                    else
                        DEP_Descripcion = rs("DEP_DescripcionCortaActual")
                    end if
                end if

                if(CInt(FLD_IdUltimo)=CINt(rs("FLD_Id")) or (ESR_Id=7 or ESR_Id=5)) Then
                    if(CInt(rs("DRE_SubEstado")))=1 then
                        DEP_Descripcion = "Finalizar " & DEP_Descripcion
                    else
                        if(ESR_Id=5) then
                            DEP_Descripcion = "Rechazado " & DEP_Descripcion
                        end if
                        if(ESR_Id=7) then
                            DEP_Descripcion = "Finalizado " & DEP_Descripcion
                        end if
                    end if
                end if
                salida = salida + "<li role='presentation' class='" & clase & " pasos'><a role='tab' href='#' data-mode='" & modo & "' data-vfl='" & rs("VFL_Id") & "' data-dre='" & rs("DRE_Id") & "' data-id='" & j & "' class='step'><i class='globo pull-left " & clase2 & "'>" & (j) & "</i> " & DEP_Descripcion & "</a></li>"

                FLD_IdLast = rs("FLD_Id")
                FLD_InicioTermino = rs("FLD_InicioTermino")
                FLD_IdHijoSi = rs("FLD_IdHijoSi")
            end if
        end if
        rs.movenext        
    loop
    'Creando los siguientes step ya almacenados en la tabla DatosRequerimiento

    'Creando el siguiente paso del flujo siempre y cuando el ultimo registro del requerimeinto no este cerrado ESR_Id=7 o Rechazado ESR_Id=5
    if(ESR_Id<>7 and ESR_Id<>5) then
        yl = "exec spFlujoDatos_Listar " & VFL_Id & ",1"
        Set rz = Server.CreateObject("ADODB.Recordset")

        rz.CursorType = 1
        rz.CursorLocation = 3
        rz.Open yl, cnn

        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description			
            cnn.close 			   
            response.Write("503/@/Error Conexión 6:" & ErrMsg)
            response.End()
        End If
        
        do while not rz.eof            
            if(CInt(rz("FLD_Id"))=CInt(FLD_IdLast)) then
                'So para cuando se requiere que despues de que RC apruebe vaya a su jefatura
                DEP_IdAnterior = rz("DEP_Id")
                FLD_CodNotAnterior = rz("FLD_CodNot")
                rz.movenext
                FLD_InicioTermino = rz("FLD_InicioTermino")
                if(not rz.eof) then
                    j=j+1
                    clase="disabled"
                    clase2="pend"
                    if(IsNULL(rz("DEP_Id")) or (DEP_IdAnterior = 0 and FLD_CodNotAnterior=2)) then
                        'Si DEP_Id no existe o es  = 0, corresponde a la jefatura del paso anterior, solo cuando no es el primer registro                        
                        rz.moveprevious
                        'Solo para los casos de envio a RC que se requierea visacion  de jefatura (Pasos despues de creacion)
                        if(DEP_IdAnterior = 0 and FLD_CodNotAnterior=2) then
                            xl="exec [spDatoRequerimienoPorPaso_Consultar] " & VRE_Id & "," & rz("FLD_Id")
                            set xs = cnn.Execute(xl)
                            on error resume next
                            if cnn.Errors.Count > 0 then 
                                ErrMsg = cnn.Errors(0).description			
                                cnn.close 			   
                                response.Write("503/@/Error Conexión 2:" & ErrMsg)
                                response.End()
                            End If
                            if not xs.eof then
                                DEP_IdNext = xs("DEP_IdActual")
                                DEP_DescripcionNext = "Jefatura " & xs("DEP_DescripcionCorta")
                            else
                                DEP_IdNext = rz("DEP_Id")
                                DEP_DescripcionNext = "Jefatura SIN-DEP" 
                            end if
                        'Solo para los casos de envio a RC que se requierea visacion  de jefatura (Pasos despues de creacion)
                        else
                            DEP_IdNext = rz("DEP_Id")
                            DEP_DescripcionNext = "Jefatura " & rz("DEP_DescripcionCorta")
                        end if
                        rz.movenext
                    else                        
                        DEP_idNext = rz("DEP_Id")                        
                        DEP_DescripcionNext = rz("DEP_DescripcionCorta")
                        if(rz("ESR_Id")=4 or rz("ESR_Id")=8) then
                            DEP_DescripcionNext = "Jefatura " & rz("DEP_DescripcionCorta")
                        else
                            'if FLD_InicioTermino=2 or FLD_InicioTermino=4 then
                            if FLD_InicioTermino=2 then
                                DEP_DescripcionNext = "Finalizar " & rz("DEP_DescripcionCorta")
                            end if
                        end if
                    end if  

                    'Buscar paso de bifurcacion                
                    if(FLD_IdHijoSi<>0 and not IsNULL(FLD_IdHijoSi)) then
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
                            DEP_IdActualD = sw("DEP_Id")
                            DepDescripcionActualD = sw("DEP_DescripcionCorta")			
                        end if
                    end if                
                    Departamento = DEP_DescripcionNext
                    if(FLD_IdHijoSi<>0 and FLD_InicioTermino<>2 and FLD_InicioTermino<>3) then                        
                        DEP_DescripcionNext = abreviar(DEP_DescripcionNext) & " / " & abreviar(DepDescripcionActualD)                        
                    end if
                    
                    if(FLD_InicioTermino=3) then
                        DEP_DescripcionNext = DepDescripcionActualD
                        Departamento = DepDescripcionActualD
                    end if
                    
                    salida = salida + "<li role='presentation' class='" & clase & " pasos'><a role='tab' href='#' data-mode='" & modo & "' data-vfl='" & rz("VFL_Id") & "' data-dre='0' data-id='" & j & "' class='step'><i class='globo pull-left " & clase2 & "'>" & (j) & "</i> " & DEP_DescripcionNext & "</a></li>"
                    exit do
                end if
            end if
            rz.movenext
        loop
    end if
    'Creando el siguiente paso del flujo

    salida="200/@/" & salida 
    response.write(salida)    
end function
%>
<script>
    //MenuFlujo
	var ss  = String.fromCharCode(47) + String.fromCharCode(47);
	var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);
    
    var modo=<%=modo%>;
    var ESR_Id = <%=ESR_Id%>
    var data = {VFL_Id:<%=VFL_Id%>, DRE_Id:<%=DRE_Id%>,id:<%=id%>,REQ_Descripcion:'<%=REQ_Descripcion%>',modo:modo,Departamento:'<%=Departamento%>'}
	var content;

    if(modo==1){
        modificaurl(<%=VFL_Id%>,<%=DRE_Id%>,'agregar')
    }else{
        if(ESR_Id==7 || ESR_Id==5){
            modificaurl(<%=VFL_Id%>,<%=DRE_IdMax%>,'visualizar')
        }else{
            modificaurl(<%=VFL_Id%>,<%=DRE_IdMax%>,'modificar')
        }
    }

	$("#pry-content").html("Cargando el modulo...");
	$("#pry-content").append("<div class='loader_wrapper'><div class='loader'></div></div>");
	$.ajax( {
		type:'POST',					
		url: '/formulario',
		data: data,
		success: function ( data ) {
			param = data.split(sas)			
			if(param[0]==200){                
                $("#pry-content").hide();
                $("#pry-content").html(param[1]);				
                //$("#pry-content").show("fast")
                $("#pry-content").css("display","block")
			}else{				
				$("#pry-content").hide();
				$("#pry-content").html("<div class='row'><h5 style='padding-right: 15px; padding-left: 15px; display: block;'>ERROR: No fue posible encontrar el módulo correspondiente.</h5></div>");
				//$("#pry-content").show("fast")
                $("#pry-content").css("display","block")
			}			
		},
		error: function(XMLHttpRequest, textStatus, errorThrown){				
			swalWithBootstrapButtons.fire({
				icon:'error',								
				title: 'Ups!, no pude cargar los campos del proyecto'					
			});				
		},
		complete: function(){
			$(".loader_wrapper").remove();
		}
	});		
			
    function modificaurl(VFL_Id, DRE_Id,mode){
		var href = window.location.href;
		var newhref = href.substr(href.indexOf("/home")+6,href.length);
		var href_split = newhref.split("/")

		href_split[1]=mode;
		href_split[2]=VFL_Id;
		href_split[3]=DRE_Id;									
		var newurl="/home"
		$.each(href_split, function(i,e){
			newurl=newurl + "/" + e
		});
		window.history.replaceState(null, "", newurl);
		cargabreadcrumb("/breadcrumbs",{tabId:"<%=tabId%>"});
	}
</script>