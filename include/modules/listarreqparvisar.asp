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

    FLU_Id = request("FLU_Id")

	sql="exec [spRequerimientosVisadoAutomatico_Listar]  " & FLU_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
	set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then
        ErrMsg = cnn.Errors(0).description
	    response.write("503/@/Error de conexion " & ErrMsg)
		rs.close
		cnn.close
		response.end()
	End If					
	corr=0
    visar=true
	response.write("200/@/")%>	
<div style="height: 400px;overflow:auto;">
    </br>
    <p>A continuación se listan los requerimientos que serán visados automáticamente.
    Al confirmar, se procederá a visar los requerimientos seleccionados.</p>
	<table id="tbl-reqparavisar" class="table table-striped table-bordered table-sm" data-id="ordenesdecompra" data-page="false" data-selected="false" data-keys="0" style="margin-top:20px;" width="100%"> 
	<thead> 
		<tr>
            <th>Cor.</th>  
			<th>Id</th> 
			<th>V.Req</th>
            <th>Editor</th>
			<th>Departamento</th>			
			<th>V.Form</th>			
            <th>Est.Req</th>            
            <th>Usuario</th>
            <th>Fecha</th>                        
		</tr> 
	</thead><%
    if rs.eof then
        visar=false%>
		<tbody>
            <tr>
                <td colspan="9">No se encontraron requerimientos para visar automáticamente.</td>
            </tr>
        </tbody><%
	end if	%>
	<tbody><%
		do while not rs.eof
            corr=corr+1
            editor = rs("USR_Usuario")
            if(IsNULL(rs("USR_Usuario")) or rs("USR_Usuario")="") then
                editor="Unidad"
            end if%> 
			<tr class="rv">
                <td><%=corr%></td>  
				<td class="key"><%=rs("DRE_Id")%></td> 
				<td><%=rs("VRE_Id")%></td> 
                <td><%=editor%></td> 
				<td><%=rs("DEP_DescripcionCorta")%></td> 
				<td><%=rs("VFO_Id")%></td>
                <td><%=rs("ESR_Descripcion")%></td>                 
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
<div class="footer"><%
    if(visar) then%>
        <input type="button" class="btn btn-success" value="Visar" id="btn_visarautomatico" data-flu="<%=FLU_Id%>"><%
    end if%>
    <input type="button" class="btn btn-danger" value="Cancelar" onclick="swal.close();">
</div>