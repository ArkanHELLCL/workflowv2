<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<!-- #INCLUDE FILE="functions.inc" -->
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
	
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End 			   
	end if	
		
	sql="exec [spBandejaPendientesAntiguos_Consultar] " & session("wk2_usrid") & "," & FLU_Id
    path="D:\sitios\WorkFlow\"            
			
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
    dias="-"
	atraso=-1
    cambiareditor=""
    observaciones = ""

	dataRequerimientoPen = "{""draw"":""" & draw & """,""recordsTotal"":""" & recordsTotal & """,""recordsFiltered"":""" & recordsFiltered & """,""sort"":""" & sort & """,""data"":["	
	do While Not rs.EOF	and (contreg < length or length=0)
		'Buscando adjuntos
        archivo=rs("archivo")        
		archivos = 0					
        If fs.FileExists(path & archivo) Then
            archivos = 1
        else
            archivos = 0
        end if
		'Buscando adjuntos
		if(archivos>0) then
			colordown="text-primary"				
			disableddown="pointer"	                        
            data="data-sis='" & tpo & "' data-arc='" & archivo & "'"            
			clasedown="dowadj"
		else
			colordown="text-white-50"				
			disableddown="not-allowed"				
			data=""
			clasedown=""			
		end if
								
		adjunto="<i class='fas fa-cloud-download-alt " & clasedown & " " & colordown & "' style='cursor:" & disableddown & "' title='Bajar adjunto(s)' " & data & " data-toggle='tooltip'></i> " & vermod & "<span style='display:none'></span>"

		if(rs("UsuarioEditor")="" or IsNULL(rs("UsuarioEditor"))) then
			Editor = "Unidad"
		else
			Editor = rs("UsuarioEditor")
		end if
	    datos="<i class='fas fa-list-alt text-secondary reqdata' style='cursor:pointer' data-req='" & rs("DRE_Id") & "'></i>"
		acciones = adjunto & " " & cambiareditor & " " & observaciones & " " & datos

        dataRequerimientoPen = dataRequerimientoPen & "[""" & rs("DRE_Id") & """,""" & rs("VRE_Id") & """,""" & LimpiarUrl(rs("VRE_Descripcion")) & """,""" & rs("REQ_Id") & """,""" & rs("REQ_Identificador") & """,""" & LimpiarUrl(rs("REQ_Descripcion")) & """,""" & rs("ESR_IdDatoRequerimiento") & """,""" & rs("ESR_AccionDatoRequerimiento") & """,""" & rs("VFF_Id") & """,""" & rs("VFL_Id") & """,""" & rs("FLU_Id") & """,""" & rs("FLU_Descripcion") & """,""" & rs("REQ_Ano") & """,""" & rs("VFO_Id") & """,""" & rs("FOR_Id") & """,""" & rs("FOR_Descripcion") & """,""" & rs("IdCreador") & """,""" & rs("UsuarioCreador") & """,""" & rs("IdPerfilCreador") & """,""" & rs("PerfilCreador") & """,""" & rs("IdEditor") & """,""" & Editor & """,""" & rs("IdPerfilEditor") & """,""" & rs("PerfilEditor") & """,""" & rs("DEP_IdActual") & """,""" & rs("DepDescripcionActual") & """,""" & rs("DEPCodigoActual") & """,""" & rs("DEP_IdOrigen") & """,""" & rs("DepDescripcionOrigen") & """,""" & rs("DepCodigoOrigen") & """,""" & rs("DRE_Estado") & """,""" & rs("DRE_SubEstado") & """,""" & rs("DRE_UsuarioEdit") & """,""" & rs("DRE_FechaEdit") & """,""" & rs("DRE_AccionEdit") & """,""" & rs("REQ_Fechaedit") & """,""" & rs("ESR_DescripcionRequerimiento") & """,""" & dias & """,""" & acciones & """,""" & tpo & """,""" & rs("Flu_CodPas") & """]"																	
		rs.MoveNext
		if not rs.eof then
			dataRequerimientoPen = dataRequerimientoPen & ","
		end if
		contreg=contreg+1
    loop
    rs.Close
    cnn.Close     
      
	dataRequerimientoPen=dataRequerimientoPen & "]" & ",""search"": """ & search & """" & "}"
    response.write(replace(dataRequerimientoPen,"],]","]]"))	
    %>