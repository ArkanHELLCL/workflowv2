<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<!-- #INCLUDE FILE="functions.inc" -->
<%					
	if isEmpty(session("wk2_usrid")) or isNull(session("wk2_usrid")) then
		response.Write("500/@/Error Parámetros no válidos")
		response.end
	end if
	'Listas desplegables
	TipoDocumento=14
	TipoMoneda=4
	REQ_Id = request("REQ_Id")
	
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End 			   
	end if	
	
	sql="exec spPagosRequerimientos_Listar " & REQ_Id & ",-1"
	set rs = cnn.Execute(sql)
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.write("503/@/Error de conexion " & ErrMsg)
	   response.End() 			   
	end if

	contreg=0
	dataListaDocumentosPago = "{""data"":["	
	do While Not rs.EOF
		
		acciones = "<i class='fas fa-edit text-warning edtdocpag' data-req='" & rs("REQ_Id") & "' data-pag='" & rs("PAG_Id") & " ' title='Edtar documento de pago'></i> <i class='fas fa-trash text-danger deldocpag' data-req='" & rs("REQ_Id") & "' data-pag='" & rs("PAG_Id") & " ' title='Eliminar documento de pago'></i>"

		estado="Pendiente"
		if(rs("PAG_EstadoPago")=1) then
			estado="Pagado"
		end if

		DocumentoDes=""
		xql="exec spItemListaDesplegable_Consultar " & rs("IdTipoDocumento")
		set rx = cnn.Execute(xql)		
		on error resume next
		if not rx.eof then
			DocumentoDes=rx("ILD_Descripcion")
		end if

		MonedaDes=""
		zql="exec spItemListaDesplegable_Consultar " & rs("IdMoneda")
		set zx = cnn.Execute(zql)		
		on error resume next
		if not zx.eof then
			MonedaDes=zx("ILD_Descripcion")
		end if

        dataListaDocumentosPago = dataListaDocumentosPago & "[""" & rs("PAG_Id") & """,""" & rs("PAG_Descripcion") & """,""" & rs("PAG_Mes") & """,""" & rs("PAG_FechaDescarga") & """,""" & rs("PAG_FechaPublicacion") & """,""" & rs("PAG_FechaEmision") & """,""" & rs("PAG_NumFactura") & """,""" & estado & """,""" & rs("RazonSocialProveedor") & """,""" & DocumentoDes & """,""" & rs("PAG_OrdenCompra") & """,""" & MonedaDes & """,""" & rs("PAG_MontoTotalFactura") & """,""" & rs("PAG_InfoExtra") & """,""" & rs("PAG_UsuarioEdit") & """,""" & rs("PAG_FechaEdit") & """,""" & acciones & """]"																	
		rs.MoveNext
		if not rs.eof then
			dataListaDocumentosPago = dataListaDocumentosPago & ","
		end if
		contreg=contreg+1
    loop
    rs.Close
    cnn.Close     
      
	dataListaDocumentosPago=dataListaDocumentosPago & "]" & ",""search"": """ & search & """" & "}"
    response.write(replace(dataListaDocumentosPago,"],]","]]"))	
    %>