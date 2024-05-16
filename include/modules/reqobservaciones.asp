<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%    
	VRE_Id = request("VRE_Id")

    set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if

	'Buscando todas las observaciones del requerimiento
    ssql="exec spDatoRequerimientoObservaciones_Listar " & VRE_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
	set rs = cnn.Execute(ssql)		
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 2:" & ErrMsg)
		response.End()		
	end if    

    response.write("200/@/")%>
    <table id="tbl-observaciones" class="table table-striped table-bordered table-sm" data-id="adjuntos" data-page="false" data-selected="false" data-keys="0" style="margin-top:20px;" width="100%"> 
	<thead> 
		<tr> 
			<th>Corr</th>
            <th>Id</th>
			<th>Estado</th>
			<th>Fecha</th>			
			<th>Usuario</th>
			<th>Observación</th>
		</tr> 
	</thead> 	
	<tbody><%
    cont=1
    do while(not rs.eof)%>
        <tr>
            <td><%=cont%></td>
            <td><%=rs("DRE_Id")%></td>
            <td><%=rs("ESR_Descripcion")%></td>
            <td><%=rs("DRE_FechaEdit")%></td>
            <td><%=rs("DRE_UsuarioEdit")%></td>
            <td><%=LimpiarUrl(rs("DRE_Observaciones")) %></td>
        </tr><%        
		rs.movenext
        cont = cont + 1
    loop    
%>