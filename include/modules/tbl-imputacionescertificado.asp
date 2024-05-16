<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
    splitruta=split(ruta,"/")    
	xm=splitruta(5)
    DRE_Id=splitruta(7)
    
    VCE_Id=request("VCE_Id")

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
    end if    

	'Preguntar si el perfil actual tiene permiso para el flujo actual
    FLU_IdPerfil=false
    tl="exec [spUsuarioVersionFlujo_Listar] 1," & session("wk2_usrid")       'Todos flujos asociados al usuario actual
    set rs = cnn.Execute(tl)
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
        tl.movenext
    loop

	tsql="exec [spDetalleCertificado_Listar] -1, " &  VCE_Id      'Todas las imputaciones para una version de certificado
    set rs = cnn.Execute(tsql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error [spDetalleCertificado_Listar]")
		cnn.close 		
		response.end
	End If	
	j=0
	dataImputacionesCertificado = "{""data"":["
	do While Not rs.EOF
		if(session("wk2_usrid")=IdEditor) and (rs("FLD_Id")=FLD_Id) or (session("wk2_usrid")=IdEditor and session("wk2_usrperfil")=1) or (session("wk2_usrid")=IdEditor and session("wk2_usrperfil")=2 and FLU_IdPerfil) then
        	acciones=" <i class='fas fa-trash text-danger delimp' title='Eliminar Imputacion' data-dce='" & rs("DCE_Id") & "'></i>"
		else
			acciones=" <i class='fas fa-trash text-white-50' title='Eliminar Imputación'></i>"
		end if		

        dataImputacionesCertificado = dataImputacionesCertificado & "[""" & rs("DCE_Id") & """,""" & rs("ILD_Descripcion") & """,""" & rs("DCE_Monto") & """,""" & rs("DCE_Comprometido") & """,""" & rs("DCE_Asignado") & """,""" & rs("PRE_PresupuestoAsignado") & """,""" & rs("PRE_PresupuestoComprometido") & """,""" & rs("DCE_UsuarioEdit") & """,""" & rs("DCE_FechaEdit") & """,""" & acciones & """]"        
        rs.movenext
        if not rs.eof then
            dataImputacionesCertificado = dataImputacionesCertificado & ","
        end if
	loop
	dataImputacionesCertificado=dataImputacionesCertificado & "]}"
	
	response.write(dataImputacionesCertificado)
%>