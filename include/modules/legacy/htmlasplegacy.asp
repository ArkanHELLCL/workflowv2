<%
	informe=request("informe")
    Req_Cod=request("Req_Cod")
	INF_Archivo=request("INF_Archivo")
	INF_Id=request("INF_Id")

    set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error 4 Conexión:" & ErrMsg)
	   response.End()
	end If 
    
    if(INF_Id=1) then
        'Certificado de disponibilidad
        INF_Path="D:\DocumentosSistema\WorkFlow\legacy\workflowv1\REQ-" & CInt(Req_Cod) & "\CDP\"
        'NombreArchivo="CertificadoWFv1"
        'INF_NombreArchivo="/certificado-workflowv1"
    else
        if(INF_Id=2) then
            'Memo
            INF_Path="D:\DocumentosSistema\WorkFlow\legacy\workflowv1\REQ-" & CInt(Req_Cod) & "\MEMO\"
            'NombreArchivo="MemoWFv1"
            'INF_NombreArchivo="/memo-workflowv1"
        else
            if(INF_Id=3) then
                'Bases
                INF_Path="D:\DocumentosSistema\WorkFlow\legacy\workflowv1\REQ-" & CInt(Req_Cod) & "\BASES\"
                'NombreArchivo="basesWFv1"
                'INF_NombreArchivo="/bases-workflowv1"
            else
                response.write("503/@/Error 8: Id no reconocido")                
                response.end
            end if
        end if
    end if	
	set fso = createobject("scripting.filesystemobject")
					
	BuildFullPath INF_Path

	Sub BuildFullPath(ByVal FullPath)
		If Not fso.FolderExists(FullPath) Then
			BuildFullPath fso.GetParentFolderName(FullPath)
			fso.CreateFolder FullPath
		End If
	End Sub
	
	Set act = fso.CreateTextFile(INF_Path & INF_Archivo & ".htm", true)
	
	act.Write informe
	act.Close
%>