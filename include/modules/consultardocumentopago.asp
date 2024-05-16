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
	PAG_Id = request("PAG_Id")
	
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End 			   
	end if	
	
	sql="exec spPagosRequerimientos_Consultar " & PAG_Id 
	set rs = cnn.Execute(sql)
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.write("503/@/Error de conexion " & ErrMsg)
	   response.End() 			   
	end if

	contreg=0
	dataListaDocumentosPago = "{""data"":["	
	if Not rs.EOF then	

        dataListaDocumentosPago = dataListaDocumentosPago & """" & rs("PAG_Id") & """,""" & rs("PAG_Descripcion") & """,""" & rs("PAG_Mes") & """,""" & rs("PAG_FechaDescarga") & """,""" & rs("PAG_FechaPublicacion") & """,""" & rs("PAG_FechaEmision") & """,""" & rs("PAG_NumFactura") & """,""" & rs("PAG_EstadoPago") & """,""" & rs("IdTipoDocumento") & """,""" & rs("PRO_IdProveedor") & """,""" & rs("PAG_OrdenCompra") & """,""" & rs("IdMoneda") & """,""" & rs("PAG_MontoTotalFactura") & """,""" & rs("PAG_InfoExtra") & """,""" & rs("PAG_UsuarioEdit") & """,""" & rs("PAG_FechaEdit") & """,""" & acciones & """"																	
		rs.MoveNext
		if not rs.eof then
			dataListaDocumentosPago = dataListaDocumentosPago & ","
		end if
		contreg=contreg+1
    end if
    rs.Close
    cnn.Close     
      
	dataListaDocumentosPago=dataListaDocumentosPago & "]" & ",""response"": ""200""" & "}"
    response.write(replace(dataListaDocumentosPago,"],]","]]"))	
    %>