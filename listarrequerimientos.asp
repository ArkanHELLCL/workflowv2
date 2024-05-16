<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="include\template\session.min.inc" -->
<%
    FLU_Id = request("FLU_Id")
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.write("503/@/Error de conexion")
	   response.End() 			   
	end if							
	
	response.write("200/@/")%>
	<table id="tbl-listrequerimientos" class="table table-striped table-bordered table-sm" data-id="listrequerimientos" style="margin-top:20px;" width="100%"> 
		<thead> 
			<tr> 
				<th></th> 
				<th>#</th> 
				<th>#Req</th>
                <th>Requerimiento</th>
				<th>Fecha de creación</th>
                <th>Creador</th>
                <th>Editor</th>
				<th>Subestado</th>			
			</tr> 
		</thead> 	
		<tbody><%
			if(session("wk2_usrperfil")=1) then                
                sql="exec spDatoRequerimiento_Listar " & FLU_Id & ",1, '" & search & "'"
            else	
                if(session("wk2_usrperfil")=2) then                  
                    sql="exec spDatoRequerimientoxPerfil_Listar " & FLU_Id & "," & session("wk2_usrid") & ",1, '" & search & "'"
                end if
            end if
            set rx = cnn.Execute(sql)
            do while not rx.eof%>
                <tr>
                    <td></td>
                    <td><%=rx("DRE_Id")%></td>
                    <td><%=rx("REQ_Id")%></td>						
                    <td><%=rx("REQ_Descripcion")%></td>
                    <td><%=rx("REQ_FechaEdit")%></td>
                    <td><%=rx("REQ_UsuarioEdit")%></td>
                    <td><%=rx("DRE_UsuarioEdit")%></td>
                    <td><%=rx("DRE_Subestado")%></td>
                </tr><%
                rx.movenext
            loop%>						
		</tbody>
	</table>
	<button type="button" class="btn btn-danger btn-md waves-effect waves-dark" id="btn_archivapry" name="btn_archivapry"><i class="fas fa-archive"></i> Archivar</button>
	<button type="button" class="btn btn-secondary btn-md waves-effect waves-dark" id="btn_cancelapry" name="btn_cancelapry"><i class="fas fa-thumbs-down"></i> Cancelar</button>