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
    PAG_Descripcion = LimpiarUrl(request("PAG_Descripcion"))
    PAG_Mes = request("PAG_Mes")
    PAG_FechaDescarga = request("PAG_FechaDescarga")
    PAG_FechaPublicacion = request("PAG_FechaPublicacion")
    PAG_FechaEmision = request("PAG_FechaEmision")
    PAG_NumeroFactura = request("PAG_NumeroFactura")
    PAG_EstadoPago = request("PAG_EstadoPago")
    PRO_IdProveedor = request("PRO_IdProveedor")
    PAG_TipoDocumento = request("PAG_TipoDocumento")
    PAG_OrdenCompra = request("PAG_OrdenCompra")
    PAG_Moneda = request("PAG_Moneda")
    PAG_MontoTotalFactura = request("PAG_MontoTotalFactura")
    PAG_PorcentajeIva = 0
    PAG_InfoExtra = LimpiarUrl(request("PAG_InfoExtra"))
	
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End 			   
	end if	
	
	sql="exec spPagosRequerimientos_Agregar " & REQ_Id & ",'" & PAG_Descripcion & "'," & PAG_Mes & ",'" & PAG_FechaDescarga & "','" & PAG_FechaPublicacion & "','" & PAG_FechaEmision & "'," & PAG_NumeroFactura & "," & PAG_EstadoPago & "," & PRO_IdProveedor & "," & PAG_TipoDocumento & ",'" & PAG_OrdenCompra & "'," & PAG_Moneda & "," & PAG_MontoTotalFactura & "," & PAG_PorcentajeIva & ",'" & PAG_InfoExtra & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"

	set rs = cnn.Execute(sql)
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.write("503/@/Error de conexion " & ErrMsg & " " & sql)
	   response.End() 			   
	end if
    
    response.write("200/@/Grabado exitosamente")
    %>