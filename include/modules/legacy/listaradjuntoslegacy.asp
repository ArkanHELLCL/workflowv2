<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%		
	INF_Id	= request("INF_Id")	
	Req_Cod	= request("Req_Cod")	
		
	if(INF_Id=1) then
        'Certificado de disponibilidad
        path="D:\DocumentosSistema\WorkFlow\legacy\workflowv1\REQ-" & CInt(Req_Cod) & "\CDP\"
        'NombreArchivo="CertificadoWFv1"
        'INF_NombreArchivo="/certificado-workflowv1"
        tabla="cdpworkflowv1"
    else
        if(INF_Id=2) then
            'Memo
            path="D:\DocumentosSistema\WorkFlow\legacy\workflowv1\REQ-" & CInt(Req_Cod) & "\MEMO\"
            'NombreArchivo="MemoWFv1"
            'INF_NombreArchivo="/memo-workflowv1"
            tabla="memopworkflowv1"
        else
            if(INF_Id=3) then
                'Bases
                path="D:\DocumentosSistema\WorkFlow\legacy\workflowv1\REQ-" & CInt(Req_Cod) & "\BASES\"
                'NombreArchivo="basesWFv1"
                'INF_NombreArchivo="/bases-workflowv1"
                tabla="basespworkflowv1"
            else
                response.write("503/@/Error 8: Id no reconocido")                
                response.end
            end if
        end if
    end if			
	corr=0
	response.write("200\\")%>	
	<table id="tbl-<%=tabla%>" class="table table-striped table-bordered table-sm" data-id="<%=tabla%>" data-page="false" data-selected="false" data-keys="0" style="margin-top:20px;" width="100%"> 
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
        on error resume next
        Err.clear        
		Set fso = CreateObject("Scripting.FileSystemObject")
		Set directorio = fso.GetFolder (path)        
        if(Err.Number =0) then
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
        end if
		if(corr=0) then%>
			<tr> 
				<td colspan='5'>No existen informes para este requerimiento</td>
			</tr><% 
		end if%>
	</tbody>                   
</table>
<%=response.write("\\tbl-" & tabla)%>