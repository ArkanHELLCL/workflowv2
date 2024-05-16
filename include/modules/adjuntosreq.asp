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
        VFO_Id=rs("VFO_Id")
		REQ_Carpeta=rs("REQ_Carpeta")
        carpeta=REQ_Carpeta		
		path="D:\DocumentosSistema\WorkFlow\" & carpeta & "\adjuntos\"
	else
		ErrMsg="No fue posible encontrar el registro del detalle del requerimiento"
		response.Write("404/@/Error : " & ErrMsg)
		response.End()
	end if
	cnn.close
	set cnn = nothing		
	cont=0

    dataAdjuntospry = "{""data"":["

    Set fso = CreateObject("Scripting.FileSystemObject")
    Set directorio = fso.GetFolder (path)			
    For Each fichero IN directorio.Files
        Set file = fso.GetFile(fichero)
        filename=split(fichero.Name,".")
        'if(len(filename(0)))>=50 then
        '    nombrearchivo = mid(filename(0),1,50) & "..." & filename(1)
        'else
            nombrearchivo = filename(0) & "." & filename(1)
        'end if
        corr=corr+1
        
        if cont=1 then
			dataAdjuntospry = dataAdjuntospry & ","				
		end if		
		cont=1		
		dataAdjuntospry = dataAdjuntospry & "[""" & corr & """,""" & nombrearchivo & """,""" & fichero.size & """,""" & fichero.DateLastModified & """,""" & VFO_Id & """,""" & DRE_Id & """,""" & "<i class='fas fa-cloud-download-alt text-primary arcreq' data-file='" & fichero.Name & "' data-dre='" & DRE_Id & "' data-vfo='" & VFO_Id & "' style='cursor:pointer;'></i>" & """]"         
    Next
	dataAdjuntospry=dataAdjuntospry & "]}"
	
	response.write(dataAdjuntospry)
%>