<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%		
	INF_Id	= request("INF_Id")	
	DRE_Id	= request("DRE_Id")	
		
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.write("503\\Error de conexion")
	   response.End() 			   
	end if

	sql="exec spDatoRequerimiento_Consultar  " & DRE_Id
	set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then
	   response.write("503\\Error de conexion")
		rs.close
		cnn.close
		response.end()
	End If
	if not rs.eof then		
		REQ_Carpeta=rs("REQ_Carpeta")
        carpeta=REQ_Carpeta
		'carpeta = mid(REQ_Carpeta,2,len(REQ_Carpeta)-2)
		if len(INF_Id)>1 then
			yINF_Id=""
			for i=0 to len(INF_Id)
				if(isnumeric(mid(INF_Id,i,1))) then
					yINF_Id=yINF_Id & mid(INF_Id,i,1)
				end if
			next
		else
			yINF_Id=cint(INF_Id)
		end if
		path="D:\DocumentosSistema\WorkFlow\" & Carpeta & "\informes\INF_Id-" & yINF_Id & "\"
	else
		response.write("404\\Tabla sin datos")
		rs.close
		cnn.close
		response.end()
	end if
				
	cnn.close
	set cnn = nothing		
	corr=0
	response.write("200\\")%>	
	<div style="max-height:400px;overflow-y:auto">
		<table id="tbl-informesgenerados" class="table table-striped table-bordered table-sm" data-id="informesgenerados" data-page="false" data-selected="false" data-keys="0" style="margin-top:20px;" width="100%"> 
			<thead>
				<tr> 
					<th>Corr</th> 
					<th>Nombre</th>
					<th>Tamaño</th>			
					<th>Modificación</th>								
					<th class="filter-select filter-exact" data-placeholder="Todos">Descarga</th>
				</tr> 
			</thead>
			<tbody><%
			Set fso = CreateObject("Scripting.FileSystemObject")
			Set directorio = fso.GetFolder (path)				
			For Each fichero IN directorio.Files
				Set file = fso.GetFile(fichero)
				if ucase(mid(fichero.Name,len(fichero.Name)-3))=".PDF" then
					corr=corr+1%> 
					<tr> 
						<td class="key"><%=corr%></td> 
						<td><%Response.Write (fichero.Name)%></td> 
						<td><%Response.Write (fichero.size)%></td> 
						<td><%Response.Write (fichero.DateLastModified)%></td> 														
						<th>
							<i class="fas fa-cloud-download-alt text-primary arcinf" data-file="<%=fichero.Name%>" data-dre="<%=DRE_Id%>" data-inf="<%=INF_Id%>" style="cursor:pointer;"></i>
						</th>
					</tr><%
				end if
			Next
			if(corr=0) then%>
				<tr> 
					<td colspan='5'>No existen informes para este requerimiento</td>
				</tr><% 
			end if%>
			</tbody>
		</table>
	</div>