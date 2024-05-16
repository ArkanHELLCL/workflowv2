<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="include\template\session.min.inc" -->
<!-- #INCLUDE FILE="include\template\functions.inc" -->
<%					
	if isEmpty(session("wk2_usrid")) or isNull(session("wk2_usrid")) then
		response.Write("500/@/Error Parámetros no válidos")
		response.end
	end if

	if(Request("start")<>"" and not IsNULL(Request("start")) and Request("start")<>"NaN") then
		start  = CInt(Request("start"))
	else
		start  = 0
	end if
	
	length = CInt(Request("length"))
	draw   = CInt(Request("draw"))
	search = Request("search")
	order  = CInt(Request("order[0][column]"))
	dir	   = Request("order[0][dir]")
	
	searchTXT = Request("search[value]")
	searchREG = Request("search[regex]")

	if(searchTXT<>"") then		
		search = searchTXT & "%"
	else
		search=""
	end if

    FLU_Id 	= request("FLU_Id")
	tpo		= request("tpo")
	if(tpo="") then
		tpo=0
	end if
	
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End 			   
	end if	
	
	if(tpo=0) then
		if(session("wk2_usrperfil")=1 or session("wk2_usrperfil")=5) then
			'Super ADM y Auditor, solo los pendietes
			sql="exec spDatoRequerimiento_Listar " & FLU_Id & ",1, '" & search & "'"
		else	
			if(session("wk2_usrperfil")=2 or (session("wk2_usrperfil")=3 and session("wk2_usrdepvista")=1)) then
				'ADM y Revisor pueden ver todos los requerimiento del flujo al cual pertenece
				'Solo los pendientes
				'sql="exec spDatoRequerimientoxPerfil_Listar " & FLU_Id & "," & session("wk2_usrid") & ",1, '" & search & "'"
				sql="exec [spDatoRequerimientoxPerfilEntrada_Listar] " & FLU_Id & "," & session("wk2_usrid") & ",1, '" & search & "'"				
			else
				'Resto de los perfiles solo los requerimientos en donde pertenezca al flujo del requerimiento, sea editor y que no esten cerrados ni rechazados
				'Solo los pendientes
				sql="exec [spDatoRequerimientoxEditor_Listar] 1, "  & FLU_Id & "," & session("wk2_usrid") & ",1, '" & search & "'"
			end if
		end if
	else
		if(tpo=2) then
			'Archivados
			if(session("wk2_usrperfil")=1 or session("wk2_usrperfil")=5) then
				'Super ADM y Auditor, solo los archivados
				sql="exec spDatoRequerimiento_Listar " & FLU_Id & ",14, '" & search & "'"
			else
				if(session("wk2_usrperfil")=2 or session("wk2_usrperfil")=3) then
					'Revisor debe ver solo los de sus flujos
					sql="exec spDatoRequerimientoxPerfil_Listar " & FLU_Id & "," & session("wk2_usrid") & ",14, '" & search & "'"
				else
					sql="exec [spDatoRequerimientoxCreador_Listar] "  & FLU_Id & ", 14, " & session("wk2_usrid") & ",'" & search & "'"
				end if
			end if
		else
			if(tpo=3) then
				'Enviados
				'Todos los estados
				'sql="exec [spDatoRequerimientoxEditorAnterior_Listar] " & FLU_Id & "," & session("wk2_usrid") & ",1, '" & search & "'"
				sql="exec [spDatoRequerimientoEnviados_Listar] 1, " & FLU_Id & "," & session("wk2_usrid") & ",1, '" & search & "'"
			else
				if(tpo=4) Then
					'Finalizados
					sql="exec [spDatoRequerimientoFinalizados_Listar] "  & FLU_Id & "," & session("wk2_usrid") & ", '" & search & "'"
				else
					if(tpo=5) and ((session("wk2_usrperfil")=3 and session("wk2_usrdepvista")=1) or (session("wk2_usrperfil")=2)) Then
						'Otros proyectos pendientes
						'Administrador
						'Revisor vista ampliada
						sql="exec [spDatoRequerimientoxPerfilOtros_Listar] " & FLU_Id & "," & session("wk2_usrid") & ",1, '" & search & "'"						
					else
					end if
				end if
			end if
		end if
	end if
	
	'set rs = cnn.Execute(sql)
	set rs = createobject("ADODB.recordset")
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("503/@/Error SQL: " & ErrMsg & "-" & sql)
		cnn.close 			   
		response.end
	End If

	rs.CursorType = 1
	rs.CursorLocation = 3
   	rs.Open sql, cnn		
		
	sort = column(CInt(order)) & " " & dir
	rs.Sort = sort
	if(length=0) then
		rs.PageSize     = rs.RecordCount
		rs.AbsolutePage = 1	'mostrarpagina
	else
		rs.PageSize = length 
		rs.AbsolutePage = (start+length)\length		'mostrarpagina
	end if		
	recordsTotal    = rs.RecordCount
	recordsFiltered = rs.RecordCount		

	dim fs,f	
	set fs=Server.CreateObject("Scripting.FileSystemObject")

	contreg=0
	dataRequerimiento = "{""draw"":""" & draw & """,""recordsTotal"":""" & recordsTotal & """,""recordsFiltered"":""" & recordsFiltered & """,""sort"":""" & sort & """,""data"":["	
	'do While (Not rs.EOF)
	do While Not rs.EOF	and (contreg < length or length=0)
		'Buscando adjuntos
		archivos = 0
		REQ_Carpeta=rs("REQ_Carpeta")		
		path="D:\DocumentosSistema\WorkFlow\" & REQ_Carpeta & "\adjuntos\"
		If fs.FolderExists(path) = true Then
			Set carpeta = fs.getfolder(path)
			Set ficheros = carpeta.Files
			For Each archivo In ficheros
				archivos = archivos + 1
			Next
		else
			archivos = 0
		end if
		'Buscando adjuntos
		if(archivos>0) then
			colordown="text-primary"				
			disableddown="pointer"				
			data="data-vfo='" & rs("VFO_Id") & "' data-dre='" & rs("DRE_Id") & "'"
			clasedown="dowadj"
		else
			colordown="text-white-50"				
			disableddown="not-allowed"				
			data=""
			clasedown=""			
		end if
				
		if(rs("DRE_Subestado")=1) then
			dias = (rs("FLD_DiasLimites") - rs("DRE_DifDias")) & " (" & rs("FLD_DiasLimites") & ")"
			if(rs("FLD_DiasLimites") - rs("DRE_DifDias")<=5) and (rs("FLD_DiasLimites") - rs("DRE_DifDias")>=0) then
				'Advertencia
				atraso=1
			else
				if(rs("FLD_DiasLimites") - rs("DRE_DifDias")<0) then
					'Artaso
					atraso=2
				else
					'En tiempo
					atraso=0
				end if
			end if
		else
			dias="-"
			atraso=-1			
		end if

		adjunto="<i class='fas fa-cloud-download-alt " & clasedown & " " & colordown & "' style='cursor:" & disableddown & "' title='Bajar adjunto(s)' " & data & " data-toggle='tooltip'></i> " & vermod & "<span style='display:none'></span>"

		if(rs("UsuarioEditor")="" or IsNULL(rs("UsuarioEditor"))) then
			Editor = "Unidad"
		else
			Editor = rs("UsuarioEditor")
		end if

		if(session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2 or session("wk2_usrjefatura")=1) and (rs("REQ_Estado")=1) and not isnull(rs("VFO_Id")) then
			cambiareditor="<i class='fa fa-user cmbedit text-success' aria-hidden='true' title='Cambiar editor' data-vre='" & rs("VRE_Id") & "' data-vfl='" & rs("VFL_Id") & "' data-dep='" & rs("DEP_IdActual") & "' data-usr='" & rs("IdEditor") & "' data-dre='" & rs("DRE_Id") & "' data-flu='" & rs("FLU_Id") & "'></i><span style='display:none'></span>"
		else
			cambiareditor=""
		end if

		observaciones = ""		
		ssql="exec spDatoRequerimientoObservaciones_Contar " & rs("VRE_Id") & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
		set rz = cnn.Execute(ssql)		
		on error resume next		
		if(not rz.eof) then
			if(rz("Cantidad")>0) then
				observaciones = "<i class='fa fa-comment verobs text-secondary' aria-hidden='true' title ='Ver " & rz("Cantidad") & " observaciones' data-vre='" & rs("VRE_Id") & "'></i>"				
			end if
		end if
		if(tpo=0 or tpo=3) then
			wql="exec spDatoRequerimientoUltimoEstado_Consultar " & rs("VRE_Id") & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
			set wz = cnn.Execute(wql)
			on error resume next		
			if(not wz.eof) then
				estado = wz("ESR_Descripcion")
			else
				estado = "Sin Estado"
			end if
		else
			estado = rs("ESR_AccionDatoRequerimiento")			
		end if
		if(rs("VFO_Id")="" or isNULL(rs("VFO_Id"))) and session("wk2_usrid")=rs("IdCreador") then
			cmbnombre="<i class='fas fa-edit text-warning edtname' data-req='" & rs("REQ_Id") & "' data-dre='" & rs("DRE_Id") & " ' title='Cambiar nombre del requerimiento'></i>"
		else
			cmbnombre=""
		end if
		
		acciones = adjunto & " " & cambiareditor & " " & observaciones & " " & cmbnombre
		if(len(rs("REQ_Descripcion"))>100) then
			REQ_Descripcion = mid(rs("REQ_Descripcion"),1,100) & "..."
		else
			REQ_Descripcion = rs("REQ_Descripcion")
		end if
        dataRequerimiento = dataRequerimiento & "[""" & rs("DRE_Id") & """,""" & rs("VRE_Id") & """,""" & rs("FLD_CodigoPaso") & """,""" & rs("VRE_Descripcion") & """,""" & rs("REQ_Id") & """,""" & rs("REQ_Identificador") & """,""" & REQ_Descripcion & """,""" & rs("ESR_IdDatoRequerimiento") & """,""" & estado & """,""" & rs("VFF_Id") & """,""" & rs("VFL_Id") & """,""" & rs("FLU_Id") & """,""" & rs("FLU_Descripcion") & """,""" & rs("REQ_Ano") & """,""" & rs("VFO_Id") & """,""" & rs("FOR_Id") & """,""" & rs("FOR_Descripcion") & """,""" & rs("IdCreador") & """,""" & rs("UsuarioCreador") & """,""" & rs("IdPerfilCreador") & """,""" & rs("PerfilCreador") & """,""" & rs("IdEditor") & """,""" & Editor & """,""" & rs("IdPerfilEditor") & """,""" & rs("PerfilEditor") & """,""" & rs("DEP_IdActual") & """,""" & rs("DepDescripcionActual") & """,""" & rs("DEPCodigoActual") & """,""" & rs("DEP_IdOrigen") & """,""" & rs("DepDescripcionOrigen") & """,""" & rs("DepCodigoOrigen") & """,""" & rs("DRE_Estado") & """,""" & rs("DRE_SubEstado") & """,""" & rs("DRE_UsuarioEdit") & """,""" & rs("DRE_FechaEdit") & """,""" & rs("DRE_AccionEdit") & """,""" & rs("REQ_Fechaedit") & """,""" & rs("ESR_DescripcionRequerimiento") & """,""" & dias & """,""" & acciones & """,""" & atraso & """]"																	
		rs.MoveNext
		if not rs.eof then
			dataRequerimiento = dataRequerimiento & ","
		end if
		contreg=contreg+1
    loop
    rs.Close
    cnn.Close     
      
	dataRequerimiento=dataRequerimiento & "]" & ",""search"": """ & search & """" & "}"
    response.write(replace(dataRequerimiento,"],]","]]"))	
    %>