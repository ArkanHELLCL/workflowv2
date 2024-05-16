<%
	informe=request("informe")
    DRE_Id=request("DRE_Id")
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
    
    'Consultando el nombre de la carpeta de requerimiento
    sql="exec spDatoRequerimiento_Consultar " & DRE_Id
    set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("503/@/Error 5: spDatoRequerimiento_Consultar")
		cnn.close 		
		response.end
	End If
    if not rs.eof Then
        REQ_Carpeta=rs("REQ_Carpeta")
		VFL_Id=rs("VFL_Id")
		FLD_Id=rs("FLD_Id")
		INF_Path="D:\DocumentosSistema\WorkFlow\" & REQ_Carpeta & "\informes\INF_Id-" & CInt(INF_Id) & "\"
    else
        response.Write("404/@/Error 6 No fue posible encontrar la carpeta del requeirmiento " & DRE_Id)
	    response.End()
    end if
	
	on error resume next
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