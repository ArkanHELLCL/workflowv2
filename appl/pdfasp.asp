<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%	
	If (Session("workflowv2") <> Session.SessionID) Then
		Response.write("403/@/Error 0 Usuario no autorizado")
		Response.end()
	end if
	HostName = "https://" & Request.ServerVariables("SERVER_NAME")
	ruta=Request.ServerVariables("HTTP_REFERER")

    splitruta=split(ruta,"/")    
	xm=splitruta(5)
    DRE_Id=splitruta(7)	
	
	
    INF_Id=request("INF_Id")
    if(INF_Id="") then        
        response.Write("404/@/Error 1 No fue posible encontrar el informe a generar")
	    response.End()
    end if
    
    if(DRE_Id="" or DRE_Id=0) then        
        response.Write("404/@/Error 2 No fue posible encontrar el registro del requerimiento actual")
	    response.End()
    end if
    
    if(session("wk2_usrperfil")=5) then     'Auditor
	    response.Write("403/@/Error 3 Usuario no autorizado")
	    response.End()
	end if	

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error 4 Conexión:" & ErrMsg)
	   response.End()
	end If 

    'Consultando el nombre de la carpeta de requerimiento
    sql="exec spDatoRequerimiento_Consultar " & DRE_Id
    set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("503/@/Error 5: spDatoRequerimiento_Consultar")
		cnn.close 		
		response.end
	End If
    if not rs.eof Then
        REQ_Carpeta=rs("REQ_Carpeta")
		carpeta=replace(replace(REQ_Carpeta,"{",""),"}","")
		REQ_Descripcion=rs("REQ_Descripcion")
		VFL_Id=rs("VFL_Id")
		FLD_Id=rs("FLD_Id")
		REQ_Id=rs("REQ_Id")		
		VRE_Id=rs("VRE_Id")
		dir="D:\DocumentosSistema\WorkFlow\" & REQ_Carpeta & "\informes\INF_Id-" & CInt(INF_Id) & "\"
    else
        response.Write("404/@/Error 6 No fue posible encontrar la carpeta del requeirmiento " & DRE_Id)
	    response.End()
    end if
	
	tql="exec spInformesCertificadosxVersion_Listar " & REQ_Id & ", " & VFL_Id & ",-1,1"	'Todos los informes
    set rs = cnn.Execute(tql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("503/@/Error 7: spInformesCertificadosxVersion_Listar")
		cnn.close 		
		response.end
	End If
	ok=false
    do while not rs.eof
		if(CInt(rs("INF_Estado"))=1 and CInt(rs("Id"))=CInt(INF_Id)) then
			ok=true
			INF_NombreArchivo = rs("INF_NombreArchivo")
			INF_Descripcion  = rs("INF_Descripcion")
			VCE_Id = rs("VCE_Id")		'Para cuando es certificado
			NombreArchivo = trim(replace(INF_NombreArchivo,"/",""))	
			VCE_FechaEdit=rs("VCE_FechaEdit")
			FLD_IdMemo=rs("FLD_Id")
			FLD_IdAprobacion=rs("FLD_IdAprobacion")
			if(isNULL(FLD_IdAprobacion)) then
				FLD_IdAprobacion = FLD_IdMemo
			end if
			if(IsNULL(VCE_Id) or VCE_Id="") then
				VCE_Id=0
			end if
			ESR_IdInforme = rs("ESR_IdInforme")
			if(IsNULL(ESR_IdInforme)) then
				ESR_IdInforme=2
			end if
			exit do
		end if
		rs.movenext
	loop

	
	if(VCE_Id<>0) then
		'Certificado y otros
		gsql="exec spIDVersionFormulario_Mostrar " & VRE_Id & "," & FLD_IdAprobacion & "," & ESR_IdInforme		'Rescatar valor a partir del paso 5 del diseño del flujo (28)
		dato=FLD_IdAprobacion
	else
		'Memo
		gsql="exec spIDVersionFormularioMEMOVisadoJefatura_Mostrar " & VRE_Id & "," & FLD_IdMemo & "," & ESR_IdInforme
		dato=FLD_IdMemo
	end if
	set rsx = cnn.Execute(gsql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 8:" & ErrMsg)
		response.End()		
	end if
	if not rsx.eof then
		'Creador
		VFO_IdUSuarioEdit = rsx("VFO_IdUSuarioEdit")
		'UsuarioEdit = rsx("VFO_UsuarioEdit")     'Creador del formulario
		VFO_FechaEdit = rsx("VFO_FechaEdit")
		USR_IdEditor = rsx("USR_IdEditor")
	else
		if(VCE_Id<>0) then
			'Certificado y otros
			gsql="exec spIDVersionFormulario_Mostrar " & VRE_Id & "," & FLD_IdMemo & "," & ESR_IdInforme		'Rescatar valor a partir del paso 5 del diseño del flujo (28)
			dato=FLD_IdMemo
			set rsx = cnn.Execute(gsql)
			on error resume next
			if cnn.Errors.Count > 0 then 
				ErrMsg = cnn.Errors(0).description			
				cnn.close 			   
				response.Write("503/@/Error Conexión 8:" & ErrMsg)
				response.End()		
			end if
			if not rsx.eof then
				'Creador
				VFO_IdUSuarioEdit = rsx("VFO_IdUSuarioEdit")
				'UsuarioEdit = rsx("VFO_UsuarioEdit")     'Creador del formulario
				VFO_FechaEdit = rsx("VFO_FechaEdit")
				USR_IdEditor = rsx("USR_IdEditor")
			else
				response.Write("404/@/Error 10.1 No fue posible encontrar la version deñ informe " & VRE_Id & "-" & dato)
				response.End()
			end if
		else
			response.Write("404/@/Error 10 No fue posible encontrar la version deñ informe " & VRE_Id & "-" & dato)
			response.End()
		end if
	end if
	
	

	mes=month(VFO_FechaEdit)
	anio=year(VFO_FechaEdit)
	dia=day(VFO_FechaEdit)
	diasemana=weekday(VFO_FechaEdit)
	
	dim dias(7),meses(12)
	dias(1)="Domingo"
	dias(2)="Lunes"
	dias(3)="Martes"
	dias(4)="Miercoles"
	dias(5)="Jueves"
	dias(6)="Viernes"
	dias(7)="Sabado"

	meses(1)="Enero"
	meses(2)="Febrero"
	meses(3)="Marzo"
	meses(4)="Abril"
	meses(5)="Mayo"
	meses(6)="Junio"
	meses(7)="Julio"
	meses(8)="Agosto"
	meses(9)="Septiembre"
	meses(10)="Octubre"
	meses(11)="Noviembre"
	meses(12)="Diciembre"
	
	fecha_larga=dias(diasemana) + " " + cstr(dia) + " de " + meses(mes) + " de " + cstr(anio)	  		

	fecha="Santiago, " & fecha_larga
	if(VCE_Id=0) then
		titulo="SUBSECRETARÍA DEL TRABAJO"
		subtitulo="DIVISIÓN DE ADMINISTRACIÓN Y FINANZAS"
		id="N° " & REQ_Id & "/" & VRE_Id
	else
		titulo=""
		subtitulo=""
		id="N° " & VCE_Id & "/ Req° " & REQ_Id
	end if
	
	if(not ok) then
		response.Write("403/@/Error 9 No fue posible generar el informe solicitado, no esta activo " & INF_Id)
	    response.End()
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
				data:{INF_Id:<%=INF_Id%>,VCE_Id:<%=VCE_Id%>},
				success: function(data) {
					$.ajax({
						type: 'POST',									
						url:'/genera-informe-html',
						data:{informe:data, DRE_Id:<%=DRE_Id%>,INF_Archivo:'<%=NombreArchivo%>',INF_Id:<%=INF_Id%>},
						success: function(data) {								
							$.ajax({
								type: 'POST',									
								url:'/genera-informe',								
								data:{path:'<%=carpeta%>',informe:'<%=ucase(INF_Descripcion)%>',titulo:'<%=titulo%>',subtitulo:'<%=subtitulo%>',fecha:'<%=fecha%>',id:'<%=id%>',archivo:'<%=NombreArchivo%>',INF_Id:<%=INF_Id%>},
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