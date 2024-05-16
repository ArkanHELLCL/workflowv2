<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%
If (Session("workflowv2") <> Session.SessionID) Then
	Response.write("No autorizado")
	Response.end()
end if	
Req_cod = request("Req_cod")
INF_Id = request("INF_Id")

if(INF_Id="") then
	INF_Id=0
end if
if(Req_cod="") then
	Req_cod=0
end if

if(INF_Id=1) then
    'Certificado de disponibilidad
    dir="D:\DocumentosSistema\WorkFlow\legacy\workflowv1\REQ-" & CInt(Req_Cod) & "\CDP\"
    'NombreArchivo="CertificadoWFv1"
    'INF_NombreArchivo="/certificado-workflowv1"
else
    if(INF_Id=2) then
        'Memo
        dir="D:\DocumentosSistema\WorkFlow\legacy\workflowv1\REQ-" & CInt(Req_Cod) & "\MEMO\"
        'NombreArchivo="MemoWFv1"
        'INF_NombreArchivo="/memo-workflowv1"
    else
        if(INF_Id=3) then
            'Bases
            dir="D:\DocumentosSistema\WorkFlow\legacy\workflowv1\REQ-" & CInt(Req_Cod) & "\BASES\"
            'NombreArchivo="basesWFv1"
            'INF_NombreArchivo="/bases-workflowv1"
        else
            response.write("503/@/Error 8: Id no reconocido")                
            response.end
        end if
    end if
end if

Dim objConn, strFile
Dim intCampaignRecipientID

'strFile = Request.QueryString("INF_Arc")
strFile = Request("INF_Arc")
'response.write(dir & strFile)
'response.end
If strFile <> "" Then

	dim fs
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	if fs.FileExists(dir & strFile) then
	  'response.write("File c:\asp\introduction.asp exists!")
	else
	  'response.write("File c:\asp\introduction.asp does not exist!")
	  response.write("Archivo no existe " & dir)
	  Response.end()
	end if
	'set fs=nothing
    'response.write(fs.size)
    'response.end
    on error resume next
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