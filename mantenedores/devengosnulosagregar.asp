<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<!-- #INCLUDE file="freeASPUpload.asp" -->
<%	
    datadevengosAgregar = "{""data"":["	
	if isEmpty(session("wk2_usrid")) or isNull(session("wk2_usrid")) then
		response.Write(datadevengosAgregar & "{""code"":""503"",""response"":""Parámetros no válidos""}]}")
		response.end
	end if

    Set up = New FreeASPUpload
	up.Upload()
	Response.Flush
    
    VRE_Id = up.form("VRE_Id")
    DFO_Dato = up.form("folioDV")    

    set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
    if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write(datadevengosAgregar & "{""code"":""503"",""response"":""" & ErrMsg & """}]}")
	   response.End() 			   
	end if

    'Rescatando la carpeta del requerimiento    
    set rs = cnn.Execute("exec spVersionRequerimiento_Consultar " & VRE_Id)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
        cnn.close 			   
		response.Write(datadevengosAgregar & "{""code"":""503"",""response"":""" & ErrMsg & """}]}")		
		response.end
	End If
    if(not rs.eof) then
        REQ_Carpeta = rs("REQ_Carpeta")    
    end if

	set rs = cnn.Execute("exec [spDatoRequerimientoFolioDV_Modificar] " & VRE_Id & ", '" & DFO_Dato & "'" & ", " & session("wk2_usrid") & ", '" & session("wk2_usrtoken") & "'")
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
        cnn.close 			   
		response.Write(datadevengosAgregar & "{""code"":""503"",""response"":""" & ErrMsg & """}]}")		
		response.end
	End If        
        
    rs.Close
    cnn.Close     
      	
    datadevengosAgregar=datadevengosAgregar & "{""code"":""200"",""response"":""OK""}]}"

    'Subiendo adjuntos
    'Creando la carpeta en el servidor si esta no existe
    dim fs,f
    path="d:\DocumentosSistema\WorkFlow\" & REQ_Carpeta & "\adjuntos"
    folders = Split(path, "\")
    currentFolder = ""
    set fs=Server.CreateObject("Scripting.FileSystemObject")
    For i = 0 To UBound(folders)
        currentFolder = currentFolder & folders(i)        
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
    
    response.write(datadevengosAgregar)
    %>