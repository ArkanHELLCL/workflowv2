<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%		
	VFO_Id	= request("VFO_Id")	
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
		path="D:\DocumentosSistema\WorkFlow\" & carpeta & "\adjuntos\"
	else
		response.write("1\\Tabla sin datos")
		rs.close
		cnn.close
		response.end()
	end if
				
	cnn.close
	set cnn = nothing		
	corr=0
	response.write("200\\")%>
	<div style="height: 400px;overflow:auto;">
		<table id="tbl-adjuntos" class="table table-striped table-bordered table-sm" data-id="adjuntos" data-page="false" data-selected="false" data-keys="0" style="margin-top:20px;" width="100%"> 
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
					filename=split(fichero.Name,".")
					if(len(filename(0)))>=50 then
						nombrearchivo = mid(filename(0),1,50) & "..." & filename(1)
					else
						nombrearchivo = filename(0) & "." & filename(1)
					end if
					corr=corr+1%> 
					<tr> 
						<td class="key"><%=corr%></td> 
						<td><%Response.Write (nombrearchivo)%></td> 
						<td><%Response.Write (fichero.size)%></td> 
						<td><%Response.Write (fichero.DateLastModified)%></td> 														
						<th>
							<i class="fas fa-cloud-download-alt text-primary arcreq" data-file="<%=fichero.Name%>" data-dre="<%=DRE_Id%>" data-vfo="<%=VFO_Id%>" style="cursor:pointer;"></i>					
						</th>
					</tr><%
				Next
				if(corr=0) then%>
					<tr> 
						<td colspan='5'>No existen adjuntos para este requerimiento</td>
					</tr><% 
				end if%>
			</tbody>                 
		</table>
	</div>