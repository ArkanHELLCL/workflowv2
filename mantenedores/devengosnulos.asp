<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<!-- #INCLUDE FILE="functions.inc" -->
<%	
    datadevengosNulos = "{""draw"":""" & draw & """,""recordsTotal"":""" & recordsTotal & """,""recordsFiltered"":""" & recordsFiltered & """,""sort"":""" & sort & """,""data"":["	
	if isEmpty(session("wk2_usrid")) or isNull(session("wk2_usrid")) then
		response.Write(datadevengosNulos & "{""code"":""503"",""response"":""Parámetros no válidos""}]}")
		response.end
	end if    
    
    FLU_Id = 4  'Pagos
    FDI_Id = 67 'Devengo sin dato

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

    set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
    if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write(datadevengosNulos & "{""code"":""503"",""response"":""" & ErrMsg & """}]}")
	   response.End() 			   
	end if

	set rs = createobject("ADODB.recordset")
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
        cnn.close 			   
		response.Write(datadevengosNulos & "{""code"":""503"",""response"":""" & ErrMsg & """}]}")		
		response.end
	End If

    sql="exec spFolioDevengoSinDato_Listar " & FLU_Id & "," & FDI_Id & ",'" & searchTXT & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
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

    datadevengosNulos = "{""draw"":""" & draw & """,""recordsTotal"":""" & recordsTotal & """,""recordsFiltered"":""" & recordsFiltered & """,""sort"":""" & sort & """,""data"":["	

    do While Not rs.EOF	and (contreg < length or length=0)
        datadevengosNulos=datadevengosNulos & "[""" & rs("DRE_Id") & """,""" & rs("VRE_Id") & """,""" & rs("REQ_Descripcion") & """,""" & rs("DRE_FechaEdit") & """,""" & rs("DRE_UsuarioEdit") & """,""" & rs("DRE_Estado") & """,""" & rs("DRE_EstadoDescripcion") & """,""" & rs("EstadoPago") & """,""" & rs("DRE_UsuarioPago") & """,""" & rs("DRE_FechaPago") & """,""" & rs("FLU_Descripcion") & """,""" & rs("VFL_Id") & """,""" & rs("FOR_Id")  & """]"
        rs.movenext
        if not rs.eof then
			datadevengosNulos = datadevengosNulos & ","
		end if
        contreg=contreg+1
    loop
    
    rs.Close
    cnn.Close     
      	
    datadevengosNulos=datadevengosNulos & "]" & ",""search"": """ & search & """" & "}"
    
    response.write(replace(datadevengosNulos,"],]","]]"))
    %>