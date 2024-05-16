<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%
If (Session("workflowv2") <> Session.SessionID) and (request("SIS_Id")<>3) Then
	Response.write("No autorizado")
	Response.end()
end if	
DRE_Id = request("DRE_Id")
VFO_Id = request("VFO_Id")
INF_Id = request("INF_Id")

SIS_Id = request("SIS_Id")

if(DRE_Id="") then
	DRE_Id=0
end if
if(VFO_Id="") then
	VFO_Id=0
end if
if(INF_Id="") then
	INF_Id=0
end if
if(SIS_Id="") then
	SIS_Id=9
end if

if(DRE_Id>0) then
	set cnn = Server.CreateObject("ADODB.Connection")
	cnn.open session("DSN_WorkFlowv2")
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 
		response.write(ErrMsg)
		Response.end()
	End If

	sql="exec spDatoRequerimiento_Consultar  " & DRE_Id
	set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.write(ErrMsg & " " & sqx)
		Response.end()
	End If

	if not rs.eof then	
		REQ_Carpeta=rs("REQ_Carpeta")
        carpeta=REQ_Carpeta
		'carpeta = mid(REQ_Carpeta,2,len(REQ_Carpeta)-2)		
		if(VFO_Id<>0) then			
			dir="D:\DocumentosSistema\WorkFlow\" & carpeta & "\adjuntos\"
		else
			if(INF_Id<>0) then
				if len(INF_Id)>1 then
					yINF_Id=""
					for i=0 to len(INF_Id)
						if(isnumeric(mid(INF_Id,i,1))) then
							yINF_Id=yINF_Id & mid(INF_Id,i,1)
						end if
					next
				else
					yINF_Id=cint(INF_Id)
				end if
				dir="D:\DocumentosSistema\WorkFlow\" & REQ_Carpeta & "\informes\INF_Id-" & yINF_Id & "\"
			else
				'Otras descargas
			end if
		end if
	end if
	if REQ_Carpeta="" then
		response.Write(dir)
		response.write("Carpeta vacia")
		Response.end()
	end if

	cnn.close
	set rs=nothing
	set cnn=nothing
	'response.Write(dir)
	'response.End()
end if

if(SIS_Id=1) then
	dir="D:\sitios\WorkFlow\old\" 
end if
if(SIS_Id=2) then
	dir="D:\sitios\WorkFlow\" 
end if
if(SIS_Id=3) then
	dir="D:\DocumentosSistema\WorkFlow\manuales\" 
end if

Dim objConn, strFile
Dim intCampaignRecipientID

'strFile = Request.QueryString("INF_Arc")
strFile = Request("INF_Arc")

If strFile <> "" Then

	dim fs
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	on error resume next
	if fs.FileExists(dir & strFile) then
	  'response.write("File c:\asp\introduction.asp exists!")
	else
	  'response.write("File c:\asp\introduction.asp does not exist!")
	  response.write("Archivo no existe " & dir)
	  Response.end()
	end if
	set fs=nothing

    Response.Buffer = False
	Response.ContentType = "application/download"
    Response.AddHeader "Content-Length", fs.Size
	Response.Addheader "Content-Disposition", "attachment; filename=" & Replace(Replace(strFile," ","-"), ",","_")
	'Response.AddHeader("Content-Disposition", "attachment; filename='" & Replace(strFile," ","-") & "'")	
    Response.BinaryWrite objStream.Read
	
    Dim objStream
    Set objStream = Server.CreateObject("ADODB.Stream")    
    objStream.Open		
	objStream.Type = 1 'adTypeBinary
	'on error resume next
	objStream.LoadFromFile(dir & strFile)
	
	Do While NOT objStream.EOS AND Response.IsClientConnected
        Response.BinaryWrite objStream.Read(1024)
        Response.Flush()
    Loop
	'on error resume next
    'Response.ContentType = "application/x-unknown"
    'Response.Addheader "Content-Disposition", "attachment; filename=pepito.txt" '& strFile
	
    objStream.Close
    Set objStream = Nothing

End If
%>