<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%
	VRE_Id = request("VRE_Id")
	table 	= request("table")	
			
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if
	set rs = cnn.Execute("exec [spPagos_Consultar] " & VRE_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'")
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description	   
		cnn.close
		response.Write("503/@/Error Conexión:" & ErrMsg)
		response.End() 	
	End If%>	
	<table class="table table-striped" id="<%=table%>"><%
        if not rs.eof then%>
            <thead>
                <tr>
                    <th>R.Estado</th>                    
                    <th>Flujo</th>
                    <th>D.Limite</th>
                    <th colspan="5">Observaciones</th>
                    <th>F.Aprobación</th>
                    <th>F.Publicación</th>
                    <th>F.Emisión</th>	
                </tr>
            </thead>
            <tbody>		
                <tr>				
                    <td><%=rs("R.Estado")%></td>                    
                    <td><%=rs("Flujo")%></td>
                    <td><%=rs("D.Limite")%></td>
                    <td colspan="5"><%=rs("Observaciones")%></td>
                    <td><%=rs("F.Aprobacion")%></td>
                    <td><%=rs("F.Publicacion")%></td>
                    <td><%=rs("F.Emision")%></td>
                </tr>
            </tbody>
            <thead>
                <tr>                    			
                    <th>N.Documento</th>
                    <th>Folio Comp.</th>
                    <th>M.Total</th>
                    <th>A.Digital</th>
                    <th>F.Devengo</th>
                    <th>Pro.RUT</th>
                    <th>Moneda</th>
                    <th>U.RC</th>
                    <th>Per.Pagado</th>
                    <th>T.Servicio</th>
                    <th>T.Pago</th>
                </tr>
            </thead>
            <tbody>
                <tr>				
                    <td><%=rs("N.Documento")%></td>                    
                    <td><%=rs("Folio Comp.")%></td>
                    <td><%=rs("M.Total")%></td>
                    <td><%=rs("A.Digital")%></td>
                    <td><%=rs("F.Devengo")%></td>
                    <td><%=rs("Proo.Rut")%></td>
                    <td><%=rs("Moneda")%></td>
                    <td><%=rs("U.RC")%></td>
                    <td><%=rs("PER.Pagado")%></td>
                    <td><%=rs("T.Servicio")%></td>
                    <td><%=rs("T.Pago")%></td>
                </tr>
            </tbody><%
		end if
		rs2.Close
		cnn.Close%>		
	</table>
	