<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%	
    splitruta=split(ruta,"/")    
	xm=splitruta(5)
    DRE_Id=splitruta(7)
    
    VPV_Id=request("VPV_Id")
    if(VPV_Id="") then
        VPV_Id=0
    end if
    INF_Id=request("INF_Id")
    if(INF_Id="") then
        INF_Id=0
    end if
    
    DPV_SaldoInicial=request("DPV_SaldoInicial")
    DPV_SaldoConsumido=request("DPV_SaldoConsumido")
    DPV_SaldoActual=request("DPV_SaldoActual")
    DPV_FolioAltaBien=request("DPV_FolioAltaBien")
    DPV_ResolucionDecreto=request("DPV_ResolucionDecreto")
    DPV_Factoring=request("DPV_Factoring")
    DPV_ResolucionDecretoNumero=LimpiarUrl(request("DPV_ResolucionDecretoNumero"))
    DPV_FolioAltaBienNumero=LimpiarUrl(request("DPV_FolioAltaBienNumero"))
    DPV_FactoringNombre=LimpiarUrl(request("DPV_FactoringNombre"))

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

	tsql="exec spVersionProvidencia_Consultar " &  VPV_Id
    set rs = cnn.Execute(tsql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("503/@/Error 3: spVersionProvidencia_Consultar " & ErrMsg)
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
            response.write("503/@/Error 4 [spInformes_Consultar]")
            cnn.close 		
            response.end
        End If	
        if not rx.eof then            
            PRV_Id=rx("PRV_Id")
        else
            response.Write("404/@/Error 5 Informe no encontrado: " & INF_Id)
	        response.End()
        end if

        if(IsNULL(PRV_Id)) then
            response.Write("404/@/Error 6 Informe no es un Certificado: " & INF_Id)
	        response.End()
        end if

        'Creando una version para la Providencia
        ESR_Id = 2  'Pendiente
        sql="exec spVersionProvidencia_Agregar " & REQ_Id & "," & PRV_Id & "," & ESR_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
        set ry = cnn.Execute(sql)
        on error resume next
        if cnn.Errors.Count > 0 then 
            ErrMsg = cnn.Errors(0).description
            response.write("503/@/Error 8 [spVersionProvidencia_Agregar] " & ErrMsg)
            cnn.close 		
            response.end
        End If
        if not ry.eof then
            VPV_Id=ry("VPV_Id")
        end if
        creado=true
    else
        'ESR_id=rs("ESR_Id")
        ESR_Id=2    'Pendiente
        PRV_Id=rs("PRV_Id")
        VPV_Estado=rs("VPV_Estado")
    end if

    'Por ahora no hay glosa para la providencia
    'if(not creado) then
        'Modificando la glosa del CDP
    '    sql="exec spVersionProvidencia_Modificar " & VPV_Id & "," & REQ_Id & "," & PRV_Id & "," & VPV_Estado & "," & ESR_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
    '    set ry = cnn.Execute(sql)
    '    on error resume next
    '    if cnn.Errors.Count > 0 then 
    '        ErrMsg = cnn.Errors(0).description
    '        response.write("503/@/Error 8 [spVersionProvidencia_Modificar]")
    '        cnn.close 		
    '        response.end
    '    End If        
    'end if

    'Creación del detalle de la providencia
	ysql="exec [spDetalleProvidencia_Agregar] " & VPV_Id & "," & DPV_SaldoInicial & "," & DPV_SaldoConsumido & "," & DPV_SaldoActual & "," & DPV_FolioAltaBien & "," & DPV_ResolucionDecreto & "," & DPV_Factoring & ",'" & DPV_ResolucionDecretoNumero & "','" & DPV_FolioAltaBienNumero & "','" & DPV_FactoringNombre & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
    set rw = cnn.Execute(ysql)
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description
        response.write("503/@/Error 9 [spDetalleProvidencia_Agregar] " & ErrMsg & " " & ysql)
        cnn.close 		
        response.end
    End If
    if not rw.eof then
        DPV_Id=rw("DPV_Id")
    end if    

    response.write("200/@/" & VPV_Id & "/@/" & DPV_Id)
%>