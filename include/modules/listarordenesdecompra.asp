<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%					
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.write("503/@/Error de conexion " & ErrMsg)
	   response.End() 			   
	end if

	sql="exec spOrdenesdeCompra_Listar  " & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
	set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then
        ErrMsg = cnn.Errors(0).description
	    response.write("503/@/Error de conexion " & ErrMsg)
		rs.close
		cnn.close
		response.end()
	End If
	if rs.eof then
		response.write("1/@/Tabla sin datos")
		rs.close
		cnn.close
		response.end()
	end if					
	corr=0
	response.write("200/@/")%>	
<div style="height: 400px;overflow:auto;">
	<table id="tbl-ordenesdecompra" class="table table-striped table-bordered table-sm" data-id="ordenesdecompra" data-page="false" data-selected="false" data-keys="0" style="margin-top:20px;" width="100%"> 
	<thead> 
		<tr>
            <th>Cor.</th>  
			<th>Id</th> 
			<th>V.Req</th>
            <th>Form</th>
			<th>V.Form</th>			
			<th>O.C.</th>			
            <th>Est.Req</th>
            <th>Flujo</th>
            <th>Usuario</th>
            <th>Fecha</th>                        
		</tr> 
	</thead> 	
	<tbody><%
		do while not rs.eof
            corr=corr+1%> 
			<tr class="oc">
                <td><%=corr%></td>  
				<td class="key"><%=rs("DRE_Id")%></td> 
				<td><%=rs("VRE_Id")%></td> 
                <td><%=rs("FOR_Id")%></td> 
				<td><%=rs("VFO_Id")%></td> 
				<td><%=ucase(trim(rs("DFO_Dato")))%></td>
                <td><%=rs("ESR_DREDescripcion")%></td> 
                <td><%=rs("FLU_Descripcion")%></td>
				<td><%=rs("DRE_UsuarioEdit")%></td> 
                <td><%=rs("DRE_FechaEdit")%></td>                 
			</tr><%
            rs.movenext
		loop
        cnn.close
	    set cnn = nothing%>
	</tbody>                 
	</table>
</div>