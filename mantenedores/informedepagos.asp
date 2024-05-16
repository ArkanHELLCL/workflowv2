<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<!-- #INCLUDE FILE="functions.inc" -->
<%	
    datadevengosNulos = "{""draw"":""" & draw & """,""recordsTotal"":""" & recordsTotal & """,""recordsFiltered"":""" & recordsFiltered & """,""sort"":""" & sort & """,""data"":["	
	if isEmpty(session("wk2_usrid")) or isNull(session("wk2_usrid")) then
		response.Write(datadevengosNulos & "{""code"":""503"",""response"":""Parámetros no válidos""}]}")
		response.end
	end if    
    
    PRO_RUT = Request("PRO_RUT")
    PRO_RazonSocial = LimpiarURL(Request("PRO_RazonSocial"))
    PAG_OC = Request("PAG_OC")
    VRE_Id = Request("VRE_Id")
    DRE_FechaEdit = Request("DRE_FechaEdit")

    if(PRO_RUT = "" or PRO_RUT = "undefined" or PRO_RUT = "null") then
        PRO_RUT = -1
    end if
    if(PRO_RazonSocial = "" or PRO_RazonSocial = "undefined" or PRO_RazonSocial = "null") then
        PRO_RazonSocial = ""
    end if
    if(PAG_OC = "" or PAG_OC = "undefined" or PAG_OC = "null") then
        PAG_OC = ""
    end if
    if(VRE_Id = "" or VRE_Id = "undefined" or VRE_Id = "null") then
        VRE_Id = -1
    end if
    if(DRE_FechaEdit = "" or DRE_FechaEdit = "undefined" or DRE_FechaEdit = "null") then
        DRE_FechaEdit = ""
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

    sql="exec [spPagos_Listar] " & PRO_RUT & ",'" & PRO_RazonSocial & "','" & PAG_OC & "'," & VRE_Id & ",'" & DRE_FechaEdit & "','" & searchTXT & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
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

	VerDetalles = "<i class='fas fa-chevron-down text-secondary verdetalle' data-toggle='tooltip' title='Ver detalles'></i>"

    datadevengosNulos = "{""draw"":""" & draw & """,""recordsTotal"":""" & recordsTotal & """,""recordsFiltered"":""" & recordsFiltered & """,""sort"":""" & sort & """,""data"":["	

    do While Not rs.EOF	and (contreg < length or length=0)
        datadevengosNulos=datadevengosNulos & "[""" & rs("R.Id") & """,""" & rs("R.Descripcion") & """,""" & rs("R.Creacion") & """,""" & rs("Creador") & """,""" & rs("Paso") & """,""" & rs("Estado Paso") & """,""" & rs("Editor") & """,""" & rs("Dependencia") & """,""" & rs("Proo.RUT") & """,""" & rs("Razon Social") & """,""" & rs("O.C.") & """,""" & rs("T.Documento") & """,""" & VerDetalles  & """]"
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