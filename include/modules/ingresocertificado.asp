<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
    splitruta=split(ruta,"/")    
	xm=splitruta(5)
    DRE_Id=splitruta(7)
    
    VCE_Id=request("VCE_Id")
    if(VCE_Id="") then
        VCE_Id=0
    end if
    INF_Id=request("INF_Id")
    if(INF_Id="") then
        INF_Id=0
    end if

    ILD_Id=request("ILD_Id")
    DCE_Monto=request("DCE_Monto")
    VCE_Glosa=request("VCE_Glosa")
    PRE_PresupuestoAsignado=request("PRE_PresupuestoAsignado")
    PRE_PresupuestoComprometido=request("PRE_PresupuestoComprometido")
    REQ_Id=request("REQ_Id")
    PRE_Anio = year(date)

    if(session("ds5_usrperfil")=5) then     'Auditor
	    response.Write("403/@/Error 1 Usuario no autorizado")
	    response.End()
	end if	

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error 2 Conexión:" & ErrMsg)
	   response.End()
	end if		    

	tsql="exec spVersionCertificado_Consultar " &  VCE_Id
    set rs = cnn.Execute(tsql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("503/@/Error 3: spVersionCertificado_Consultar")
		cnn.close 		
		response.end
	End If	
    creado=false
	if rs.eof then
        rsql="exec spInformes_Consultar " & INF_Id
        set rx = cnn.Execute(rsql)
        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description
            response.write("503/@/Error 4 [spDatoRequerimiento_Consultar]")
            cnn.close 		
            response.end
        End If	
        if not rx.eof then            
            CER_Id=rx("CER_Id")
        else
            response.Write("404/@/Error 5 Informe no encontrado: " & INF_Id)
	        response.End()
        end if

        if(IsNULL(CER_Id)) then
            response.Write("404/@/Error 6 Informe no es un Certificado: " & INF_Id)
	        response.End()
        end if

        'Creando una version para el CDP
        ESR_Id = 2  'Pendiente
        sql="exec spVersionCertificado_Agregar " & REQ_Id & "," & CER_Id & "," & ESR_Id & ",'" & VCE_Glosa & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
        set ry = cnn.Execute(sql)
        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description
            response.write("503/@/Error 8 [spVersionCertificado_Agregar]")
            cnn.close 		
            response.end
        End If
        if not ry.eof then
            VCE_Id=ry("VCE_Id")
        end if
        creado=true
    else
        'ESR_id=rs("ESR_Id")
        ESR_Id=2    'Pendiente
        CER_Id=rs("CER_Id")
        VCE_Estado=rs("VCE_Estado")
    end if

    if(not creado) then
        'Modificando la glosa del CDP
        sql="exec spVersionCertificado_Modificar " & VCE_Id & "," & REQ_Id & "," & CER_Id & "," & VCE_Estado & "," & ESR_Id & ",'" & VCE_Glosa & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
        set ry = cnn.Execute(sql)
        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description
            response.write("503/@/Error 8 [spVersionCertificado_Modificar]")
            cnn.close 		
            response.end
        End If        
    end if

    'Creación del detalle del certificado.
	ysql="exec [spDetalleCertificado_Agregar] " & VCE_Id & ",'" & ILD_Id & "'," & DCE_Monto & "," & PRE_PresupuestoAsignado & "," & PRE_PresupuestoComprometido & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
    set rw = cnn.Execute(ysql)
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description
        response.write("503/@/Error 9 spDetalleCertificado_Agregar")
        cnn.close 		
        response.end
    End If
    if not rw.eof then
        DCE_Id=rw("DCE_Id")
    end if

    'Consulta por registro de presupuesto para el item imputacion agregado al certificado
    ksql="exec [spItemListaDesplegable_Consultar] " & ILD_Id
    set rx = cnn.Execute(ksql)
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description
        response.write("503/@/Error 10 spItemListaDesplegable_Consultar")
        cnn.close 		
        response.end
    End If
    if not rx.eof then
        PRE_Id=rx("PRE_Id")
        PRE_AnioORI=rx("PRE_Anio")
        PRE_EstadoORI=rx("PRE_Estado")
    else
        'Error no se pudo econtrar el registro del presupuesto    
    end if

    if(IsNULL(PRE_Id)) then
        'Crear un nuevo registro para el presupuesto para esta imputación
        kql="exec [spPresupuesto_Agregar] " & ILD_Id & "," & PRE_PresupuestoAsignado & "," & PRE_PresupuestoComprometido & "," & PRE_Anio & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
        set rxw = cnn.Execute(kql)
        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description
            response.write("503/@/Error 11 spPresupuesto_Agregar")
            cnn.close 		
            response.end
        End If
        if not rxw.eof then
            PRE_Id=rxw("PRE_Id")
        end if
    else
        'Actualiza los montos del presupuesto para esta imputación
        kql="exec [spPresupuesto_Modificar] " & PRE_Id & "," & ILD_Id & "," & PRE_PresupuestoAsignado & "," & PRE_PresupuestoComprometido & "," & PRE_AnioORI & "," & PRE_EstadoORI & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
        set rxw = cnn.Execute(kql)
        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description
            response.write("503/@/Error 12 spPresupuesto_Modificar")
            cnn.close 		
            response.end
        End If        
    end if

    response.write("200/@/" & VCE_Id & "/@/" & DCE_Id & "/@/" & PRE_Id)
%>