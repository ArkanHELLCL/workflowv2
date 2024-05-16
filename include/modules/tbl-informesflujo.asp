<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
    splitruta=split(ruta,"/")    
	xm=splitruta(5)
    DRE_Id=splitruta(7)

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
		FLD_Id=rs("FLD_Id")
        DEP_IdOrigen=rs("DEP_IdOrigen")        
        VRE_Id=rs("VRE_Id")
        VFL_Id=rs("VFL_Id")
        IdEditor=rs("IdEditor")
        REQ_Carpeta=rs("REQ_Carpeta")
        FLU_ID=rs("FLU_Id")
        REQ_Id=rs("REQ_Id")
        ESR_IdDatoRequerimiento=rs("ESR_IdDatoRequerimiento")
    end if     

    'Preguntar si el perfil actual tiene permiso para el flujo actual
    FLU_IdPerfil=false
    tl="exec [spUsuarioVersionFlujo_Listar] 1," & session("wk2_usrid")       'Todos flujos asociados al usuario actual
    set tr = cnn.Execute(tl)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error [spUsuarioVersionFlujo_Listar]")
		cnn.close 		
		response.end
	End If	
    do while not tr.eof
        if(FLU_Id=tr("FLU_Id")) then
            'tiene asignado este flujo
            FLU_IdPerfil=true
            exit do
        end if
        tr.movenext
    loop    

	tsql="exec [spInformesCertificadosxVersion_Listar] " & REQ_Id & "," & VFL_Id & ",-1, 1"       'Todos los informes en cualquier paso que esten en estado 1 FLD_Id, FLD_Estado
    set rs = cnn.Execute(tsql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error [spInformesCertificadosxVersion_Listar]")
		cnn.close 		
		response.end
	End If
	j=0
    dim fs,f	
	set fs=Server.CreateObject("Scripting.FileSystemObject")

	dataInformesflujo = "{""data"":["
	do While Not rs.EOF
        FLD_IdInforme=rs("FLD_Id")
        FLD_IdAprobacion=rs("FLD_IdAprobacion")
        'ESR_IdInforme = rs("ESR_Id")
        ESR_IdInforme = rs("ESR_IdInforme")
        if(IsNULL(ESR_IdInforme)) then
            ESR_IdInforme=2
        end if        

        'Buscando el departmento asociado al certificado        
        tr="exec [spFlujoDatos_Consultar] " & rs("FLD_Id")
        set xr = cnn.Execute(tr)
        on error resume next        
        if not xr.eof then
            DEP_Informe = xr("DEP_Id")
            if(DEP_Informe="" or IsNULL(DEP_Informe)) then
                DEP_Informe = session("wk2_usrdepid")
            end if
        else
            DEP_Informe = session("wk2_usrdepid")
        end if

        if(CInt(FLD_Id)>=CInt(rs("FLD_Id"))) then
            'Buscando el archivo del informe
            if len(rs("Id"))>1 then
                yINF_Id=""
                for i=0 to len(rs("Id"))
                    if(isnumeric(mid(rs("Id"),i,1))) then
                        yINF_Id=yINF_Id & mid(rs("Id"),i,1)
                    end if
                next
            else
                if(rs("Id")="" or IsNull(rs("Id"))) then
                    yINF_Id=-1
                else
                    yINF_Id=cint(rs("Id"))
                end if
            end if
            
            archivos=0
            if(yINF_Id>0) then
                path="D:\DocumentosSistema\WorkFlow\" & REQ_Carpeta & "\informes\INF_Id-" & yINF_Id            
                If fs.FolderExists(path) = true Then
                    Set carpeta = fs.getfolder(path)
                    Set ficheros = carpeta.Files
                    For Each archivo In ficheros
                        archivos = archivos + 1
                    Next
                else
                    archivos = 0
                end if
            else
                archivos = 0
            end if
            'Buscando el archivo del informe

            if j=1 then
                dataInformesflujo = dataInformesflujo & ","
            end if
            j=1
            if rs("INF_Estado")=1 then
                estado = "Activado"
            else
                estado = "Desactivado"
            end if

            UsuarioEdit="Pendiente"
            FechaEdit="Pendiente"
            if(archivos>0) then
                descargar="<i class='fas fa-cloud-download-alt text-success desinf' title='Descargar " & rs("INF_Descripcion") & "' data-inf='" & rs("Id") & "' data-fld='" & FLD_IdInforme & "'></i>"
            else
                descargar="<i class='fas fa-cloud-download-alt text-white-50' style='cursor:not-allowed' title='Descargar " & rs("INF_Descripcion") & "'></i>"
            end if
            crear=""
            modificar=""
            visualizar=""
            generar=""            
            if(IsNULL(rs("CER_Id")) and IsNULL(rs("PRV_Id"))) then
                'if(ESR_IdDatoRequerimiento<>7 and ESR_IdDatoRequerimiento<>5) then
                    generar="<i class='fas fa-sync-alt text-primary geninf' title='Generar " & rs("INF_Descripcion") & "' data-inf='" & rs("Id") & "' data-fld='" & FLD_IdInforme & "' data-prt='" & trim(replace(rs("INF_NombreArchivo"),"/","")) & "' data-file='" & trim(replace(rs("INF_NombreArchivo"),"/prt-","")) & ".pdf'></i>"
                'end if
                'El informe no es certificado ni providencia
                if(rs("INF_Estado")=1) then
                    if(IsNULL(FLD_IdAprobacion) or FLD_IdAprobacion="") then
                        xFLD_Id=rs("FLD_Id")
                    else
                        xFLD_Id=FLD_IdAprobacion
                    end if
                    if(ESR_IdInforme=24) then       'Para el caso de cambio de estados ACEPTA/RECLAMA
                        ESR_IdInforme=25    'Busca acepto primero
                    end if
                    'Buscar el formulario visado para este requerimiento para obtener la fecha de creacion relacionado con el FLD_Id de la tabla informes
                    gsql="exec spIDVersionFormulario_Mostrar   " & VRE_Id & "," & xFLD_Id & "," & ESR_IdInforme
                    set rsx = cnn.Execute(gsql)
                    on error resume next
                    if cnn.Errors.Count > 0 then 
                        ErrMsg = cnn.Errors(0).description			
                        cnn.close 			   
                        response.Write("503/@/Error Conexión 3:" & ErrMsg)
                        response.End()		
                    end if
                    if not rsx.eof then
                        UsuarioEdit = rsx("VFO_UsuarioEdit")     'Creador del formulario
                        FechaEdit = rsx("VFO_FechaEdit")
                    else
                        ESR_IdInforme=26    'Busca reclamo
                        gsql="exec spIDVersionFormulario_Mostrar   " & VRE_Id & "," & xFLD_Id & "," & ESR_IdInforme
                        set rsx = cnn.Execute(gsql)
                        on error resume next
                        if cnn.Errors.Count > 0 then 
                            ErrMsg = cnn.Errors(0).description			
                            cnn.close 			   
                            response.Write("503/@/Error Conexión 3:" & ErrMsg)
                            response.End()		
                        end if
                        if not rsx.eof then
                            UsuarioEdit = rsx("VFO_UsuarioEdit")     'Creador del formulario
                            FechaEdit = rsx("VFO_FechaEdit")
                        end if
                    end if
                else
                    'VCE_Id = rsx("VCE_Id")
                end if
            else
                'Solo para certificado de disponibilidad                
                if(not IsNULL(rs("VCE_Id"))) then
                    UsuarioEdit = rs("VCE_UsuarioEdit")
                    FechaEdit = rs("VCE_FechaEdit")                    
                    if((session("wk2_usrid")=IdEditor) and (rs("FLD_Id")=FLD_Id) or (session("wk2_usrid")=IdEditor and session("wk2_usrperfil")=1) or (session("wk2_usrid")=IdEditor and session("wk2_usrperfil")=2 and FLU_IdPerfil) or (DEP_Informe = session("wk2_usrdepid") AND session("wk2_usrjefatura") = 1)) and (ESR_IdDatoRequerimiento<>7 and ESR_IdDatoRequerimiento<>5) then
                        'Solo el propietario puede modificar el certificado y si esta en el paso que se requiere el certificado
                        'Super admin y que sea propietario
                        'Admin, propietario y que pertenezca al flujo
                        crear=" <i class='fas fa-plus text-success addcer' title='Crear " & rs("INF_Descripcion") & "' data-inf='" &  rs("Id") & "' data-fld='" & FLD_IdInforme & "'></i>"
                        'modificar =" <i class='fas fa-edit text-warning modcer' title='Modificar " & rs("INF_Descripcion") & "' data-VCE='" & rs("VCE_Id") & "'></i><span style='display:none'>Si</span>"
                        'visualizar=" <i class='fas fa-eye text-primary visinf' title='Visualizar " & rs("INF_Descripcion") & "' data-vce='" & rs("VCE_Id") & "' data-inf='" & rs("Id") & "' data-fld='" & FLD_IdInforme & "'></i>"
                    else                        
                        'visualizar=" <i class='fas fa-eye text-primary visinf' title='Visualizar " & rs("INF_Descripcion") & "' data-vce='" & rs("VCE_Id") & "' data-inf='" & rs("Id") & "' data-fld='" & FLD_IdInforme & "'></i>"
                    end if
                    if(ESR_IdDatoRequerimiento<>7 and ESR_IdDatoRequerimiento<>5) then
                        generar="<i class='fas fa-sync-alt text-primary geninf' title='Generar " & rs("INF_Descripcion") & "' data-inf='" & rs("Id") & "' data-fld='" & FLD_IdInforme & "' data-prt='" & trim(replace(rs("INF_NombreArchivo"),"/","")) & "' data-file='" & trim(replace(rs("INF_NombreArchivo"),"/prt-","")) & ".pdf'></i>"
                        visualizar=" <i class='fas fa-eye text-primary viscer' title='Visualizar " & rs("INF_Descripcion") & "' data-vce='" & rs("VCE_Id") & "' data-inf='" & rs("Id") & "' data-fld='" & FLD_IdInforme & "'></i>"
                    end if
                else
                    'Solo para providencia
                    if(not IsNULL(rs("VPV_Id"))) then
                        UsuarioEdit = rs("VPV_UsuarioEdit")
                        FechaEdit = rs("VPV_FechaEdit")                    
                        if((session("wk2_usrid")=IdEditor) and (rs("FLD_Id")=FLD_Id) or (session("wk2_usrid")=IdEditor and session("wk2_usrperfil")=1) or (session("wk2_usrid")=IdEditor and session("wk2_usrperfil")=2 and FLU_IdPerfil) or (DEP_Informe = session("wk2_usrdepid") AND session("wk2_usrjefatura") = 1)) and (ESR_IdDatoRequerimiento<>7 and ESR_IdDatoRequerimiento<>5) then                            
                            crear=" <i class='fas fa-plus text-success addprv' title='Crear " & rs("INF_Descripcion") & "' data-inf='" &  rs("Id") & "' data-fld='" & FLD_IdInforme & "'></i>"
                        else                            
                        end if
                        if(ESR_IdDatoRequerimiento<>7 and ESR_IdDatoRequerimiento<>5) then
                            generar="<i class='fas fa-sync-alt text-primary geninf' title='Generar " & rs("INF_Descripcion") & "' data-inf='" & rs("Id") & "' data-fld='" & FLD_IdInforme & "' data-prt='" & trim(replace(rs("INF_NombreArchivo"),"/","")) & "' data-file='" & trim(replace(rs("INF_NombreArchivo"),"/prt-","")) & ".pdf'></i>"
                            visualizar=" <i class='fas fa-eye text-primary visprv' title='Visualizar " & rs("INF_Descripcion") & "' data-vpv='" & rs("VPV_Id") & "' data-inf='" & rs("Id") & "' data-fld='" & FLD_IdInforme & "'></i>"
                        end if
                    else
                        if(not IsNULL(rs("PRV_Id"))) then
                            classcrear = "addprv"
                        end if
                        if(not IsNULL(rs("CER_Id"))) then
                            classcrear = "addcer"
                        end if
                        if((session("wk2_usrid")=IdEditor) and (rs("FLD_Id")=FLD_Id) or (session("wk2_usrid")=IdEditor and session("wk2_usrperfil")=1) or (session("wk2_usrid")=IdEditor and session("wk2_usrperfil")=2 and FLU_IdPerfil)) and (ESR_IdDatoRequerimiento<>7 and ESR_IdDatoRequerimiento<>5) then                                                   
                            crear=" <i class='fas fa-plus text-success " & classcrear & " pendiente' title='Crear " & rs("INF_Descripcion") & "' data-vpv='0' data-vce='0' data-inf='" &  rs("Id") & "' data-fld='" & FLD_IdInforme & "'></i>"
                        else
                            crear="<i class='fas fa-plus text-white-50' title='Crear " & rs("INF_Descripcion") & "' style='cursor:not-allowed'></i>"                        
                        end if                    
                        modificar =" <i class='fas fa-edit text-white-50' style='cursor:not-allowed'></i><span style='display:none'>No</span>"
                    end if
                end if
            end if
            'acciones=descargar & " " & generar & " " & crear & " " & modificar & " " & visualizar
            acciones=descargar & " " & generar & " " & crear & " " & visualizar
            dataInformesflujo = dataInformesflujo & "[""" & rs("Id") & """,""" & rs("INF_Descripcion") & """,""" & UsuarioEdit & """,""" & FechaEdit & """,""" & acciones & """]"            
            rs.movenext            
        else
            exit do
        end if
	loop
	dataInformesflujo=dataInformesflujo & "]}"    
	
	response.write(dataInformesflujo)
%>