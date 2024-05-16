<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<!-- #INCLUDE FILE="functions.inc" -->
<%	
    dataaprobacionDAF = "{""draw"":""" & draw & """,""recordsTotal"":""" & recordsTotal & """,""recordsFiltered"":""" & recordsFiltered & """,""sort"":""" & sort & """,""data"":["	
	if isEmpty(session("wk2_usrid")) or isNull(session("wk2_usrid")) then
		response.Write(dataaprobacionDAF & "{""code"":""503"",""response"":""Parámetros no válidos""}]}")
		response.end
	end if    
    
    INF_Anio = Request("INF_Anio")    
    INF_Mes = Request("INF_Mes")        


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
	
	searchTXT = LimpiarURL(Request("search[value]"))
	searchREG = LimpiarURL(Request("search[regex]"))

	if(searchTXT<>"") then		
		search = searchTXT & "%"
	else
		search=""
	end if

    set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
    if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write(dataaprobacionDAF & "{""code"":""503"",""response"":""" & ErrMsg & """}]}")
	   response.End() 			   
	end if

	set rs = createobject("ADODB.recordset")
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
        cnn.close 			   
		response.Write(dataaprobacionDAF & "{""code"":""503"",""response"":""" & ErrMsg & """}]}")		
		response.end
	End If

    sql="exec [spAprobacionDAF_Listar] " & INF_Anio & "," & INF_Mes & ",'" & searchTXT & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
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

    dataaprobacionDAF = "{""draw"":""" & draw & """,""recordsTotal"":""" & recordsTotal & """,""recordsFiltered"":""" & recordsFiltered & """,""sort"":""" & sort & """,""data"":["	

    do While Not rs.EOF	and (contreg < length or length=0)
        dataaprobacionDAF=dataaprobacionDAF & "[""" & rs("VRE_Id") & """,""" & rs("VRE_Descripcion") & """,""" & rs("REQ_FechaEdit") & """,""" & rs("REQ_UsuarioEdit") & """,""" & rs("ESR_DescripcionRequerimiento") & """,""" & rs("DepDescripcionOrigen") & """,""" & rs("DEP_Descripcion") & """,""" & rs("DRE_UsuarioEdit") & """,""" & rs("DRE_FechaEdit") & """]"
        rs.movenext
        if not rs.eof then
			dataaprobacionDAF = dataaprobacionDAF & ","
		end if
        contreg=contreg+1
    loop
    
    rs.Close
    cnn.Close     
      	
    dataaprobacionDAF=dataaprobacionDAF & "]" & ",""search"": """ & search & """" & "}"
    
    response.write(replace(dataaprobacionDAF,"],]","]]"))
    %>