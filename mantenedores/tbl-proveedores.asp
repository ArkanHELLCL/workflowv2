<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
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
	
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End 			   
	end if
		
	set rs = createobject("ADODB.recordset")
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("503/@/Error SQL: " & ErrMsg & "-" & sql)
		cnn.close 			   
		response.end
	End If

    sql = "exec spProveedores_Listar -1, '" & search & "'"


	rs.CursorType = 1
	rs.CursorLocation = 3
   	rs.Open sql, cnn		
		
	sort = column(CInt(order)) & " " & dir
	rs.Sort = sort
	if(length=0) then
		rs.PageSize     = rs.RecordCount
		rs.AbsolutePage = 1
	else
		rs.PageSize = length 
		rs.AbsolutePage = (start+length)\length
	end if		
	recordsTotal    = rs.RecordCount
	recordsFiltered = rs.RecordCount		

	dim fs,f	
	set fs=Server.CreateObject("Scripting.FileSystemObject")

	contreg=0
	dataProveedores = "{""draw"":""" & draw & """,""recordsTotal"":""" & recordsTotal & """,""recordsFiltered"":""" & recordsFiltered & """,""sort"":""" & sort & """,""data"":["	
	do While Not rs.EOF	and (contreg < length or length=0)		
        if(rs("PRO_Estado")=1) then
		    estado = "Activado"
        else
            estado = "Desactivado"
        end if
		PRO_PAC = "NO"
		if(rs("PRO_PAC")=1) then
		    PRO_PAC = "SI"                    
        end if

        dataProveedores = dataProveedores & "[""" & rs("PRO_Id") & """,""" & rs("PRO_RazonSocial") & """,""" & rs("PRO_Rut") & "-" & rs("PRO_DV") & """,""" & rs("PRO_Direccion") & """,""" & rs("PRO_Telefono") & """,""" & rs("PRO_Mail") & """,""" & PRO_PAC & """,""" & rs("ILD_Descripcion") & """,""" & rs("TCU_Descripcion") & """,""" & rs("PRO_NumCuentaBancaria") & """,""" & estado & """]"																	
		rs.MoveNext
		if not rs.eof then
			dataProveedores = dataProveedores & ","
		end if
		contreg=contreg+1
    loop
    rs.Close
    cnn.Close     
      
	dataProveedores=dataProveedores & "]" & ",""search"": """ & search & """" & "}"
    response.write(replace(dataProveedores,"],]","]]"))	
    %>