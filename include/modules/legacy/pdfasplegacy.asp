<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%	
	If (Session("workflowv2") <> Session.SessionID) Then
		Response.write("403/@/Error 0 Usuario no autorizado")
		Response.end()
	end if
	'HostName = "https://" & Request.ServerVariables("SERVER_NAME")
	'ruta=Request.ServerVariables("HTTP_REFERER")

    'splitruta=split(ruta,"/")    
	'xm=splitruta(5)
    'DRE_Id=splitruta(7)	
    Req_Cod = request("REQ_Cod")	
    INF_Id = request("INF_Id")

    if(INF_Id="") then        
        response.Write("404/@/Error 1 No fue posible encontrar el informe a generar")
	    response.End()
    end if
    
    if(Req_Cod="" or Req_Cod=0) then        
        response.Write("404/@/Error 2 No fue posible encontrar el registro del requerimiento actual")
	    response.End()
    end if
    
    if(session("wk2_usrperfil")=5) then     'Auditor
	    response.Write("403/@/Error 3 Usuario no autorizado")
	    response.End()
	end if	

    '1 Certificado de disponiblidad
    '2 Memo
    '3 Bases	

    if(CInt(INF_Id=1)) then
        'Certificado de disponibilidad
        'dir="D:\DocumentosSistema\WorkFlow\legacy\workflowv1\REQ-" & CInt(DRE_Id) & "\CDP\"
        NombreArchivo="CertificadoWFv1"
        INF_NombreArchivo="/certificado-workflowv1"
        INF_Descipcion="CERTIFICADO DE DISPONIBILIDAD PRESUPUESTARIA"
    else
        if(CInt(INF_Id=2)) then
            'Memo
            'dir="D:\DocumentosSistema\WorkFlow\legacy\workflowv1\REQ-" & CInt(DRE_Id) & "\MEMO\"
            NombreArchivo="MemoWFv1"
            INF_NombreArchivo="/memo-workflowv1"
            INF_Descipcion="MEMO"
        else
            if(CInt(INF_Id=3)) then
                'Bases
                'dir="D:\DocumentosSistema\WorkFlow\legacy\workflowv1\REQ-" & CInt(DRE_Id) & "\BASES\"
                NombreArchivo="basesWFv1"
                INF_NombreArchivo="/bases-workflowv1"
                INF_Descipcion="BASES"
            else
                response.write("503/@/Error 8: Id no reconocido")                
                response.end
            end if
        end if
    end if		

	response.Write("200/@/")
%>
<script>
	$(document).ready(function() {
		$(function(){
			var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);
			$.ajaxSetup({
				async: false			  	
			});			
			$.ajax({
				type: 'POST',
				url: '<%=INF_NombreArchivo%>',
				data:{INF_Id:<%=INF_Id%>,Req_Cod:<%=Req_Cod%>},
				success: function(data) {
					$.ajax({
						type: 'POST',									
						url:'/genera-informe-html-legacy',
						data:{informe:data, Req_Cod:<%=Req_Cod%>,INF_Archivo:'<%=NombreArchivo%>',INF_Id:<%=INF_Id%>},
						success: function(data) {								
							$.ajax({
								type: 'POST',									
								url:'/genera-informe-legacy',								
								data:{Req_Cod:<%=Req_Cod%>,titulo:'<%=INF_Descipcion%>',archivo:'<%=NombreArchivo%>',INF_Id:<%=INF_Id%>},
								success: function(data) {
									
								},
								error: function(XMLHttpRequest, textStatus, errorThrown){
									console.log('Error 1: ' + XMLHttpRequest)		
								}
							});							
						},
						error: function(XMLHttpRequest, textStatus, errorThrown){
							console.log('Error 2: ' + XMLHttpRequest)
						}
					});		

				},
				error: function(XMLHttpRequest, textStatus, errorThrown){
					console.log('Error 3: ' + XMLHttpRequest)
				},
				complete: function(){
					$('#ajaxBusy').hide(); 
				}
			});
			$.ajaxSetup({
				async: true
			});
		})
	})
</script>