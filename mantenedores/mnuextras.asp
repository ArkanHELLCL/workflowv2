<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%
	tipo=request("type")
	subtipo=request("subtype")
	
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if			
	response.write("200/@/")
	'response.write(tipo & "-" & subtipo)	
	call menu(tipo, subtipo)	
	
	function menu(tipo, subtipo)
		dim reportesUrl(1000)
		dim reportesNom(1000)		

		if(CInt(session("wk2_usrperfil")) = 1) then
			'Todos los flujos			
			sql="exec [spReportes_Listar] 1, -1"			
		end if
		if(CInt(session("wk2_usrperfil")) >= 2) then		
			'Solo los flujos asociados al usuario en estado activo			
			sql="exec [spReportesUsuarioVersionFlujo_Listar] 1, " & session("wk2_usrid")
		end if		
		i=1		

		set rx = cnn.Execute(sql)	
		on error resume next
		if cnn.Errors.Count > 0 then 
			ErrMsg = cnn.Errors(0).description
			response.write("503/@/Error SQL: " & ErrMsg & "-" & sql)
			cnn.close 			   
			response.end
		End If
		if(rx.eof) then
			reportesUrl(i-1) = "/sin-reportes"
			reportesNom(i-1) = "Sin Reportes"
		end if
		REP_URL = ""
		do while not rx.eof
			if(IsNULL(rx("DEP_Id")) or rx("DEP_Id") = session("wk2_usrdepid")) or (CInt(session("wk2_usrperfil")) = 1) then				
				reportesUrl(i-1) = rx("REP_Url")
				'reportesNom(i-1) = rx("REP_Descripcion") & "(" & mid(rx("FLU_Descripcion"),1,3) & "/v" & rx("VFL_Id") &")"
				reportesNom(i-1) = rx("REP_Descripcion")				
			end if
			rx.movenext
			if(IsNULL(rx("DEP_Id")) or rx("DEP_Id") = session("wk2_usrdepid")) or (CInt(session("wk2_usrperfil")) = 1) then
				if(not rx.eof) then
					i=i+1
				end if
			end if
		loop

		redim reportesUrl(i)
		redim reportesNom(i)
		reportesLar = i-1
		
		mantenedoresUrl=array("/usuarios","/departamentos","/listas-desplegables","/items-lista-desplegable","/regiones","/comunas","/sexo","/festivo","/proveedores")
		mantenedoresNom=array("Usuarios","Departamentos","Listas desplegables","Items lista desplegable","Regiones","Comunas","Sexo","Festivos","Proveedores")		
		mantenedoresLar = UBound(mantenedoresUrl)
		
		item=0
		if(subtipo<>"") then
			subtipo="/" & subtipo
			if tipo="man" then
				for i=0 to mantenedoresLar
					if(mantenedoresUrl(i)=subtipo) then
						item=i
					end if
				next
			end if
			if tipo="rep" then
				for i=0 to reportesLar
					if(reportesUrl(i)=subtipo) then
						item=i
					end if
				next
			end if
		else
			item=0
		end if
		
		param=""
		salida=""
				
		'Mantenedores y reportes
		'if (session("wk2_usrperfil")<>4) then
			salida = salida + "<ul class='nav nav-stacked nav-tree' role='tab-list'>"
			salida = salida + "<li role='presentation' class='category text-primary reportes' style='margin-top: 0;margin-bottom:5px;'><i class='fas fa-angle-up ml-1 repmenu'></i><i class='fas fa-file-invoice' style='padding-right:7px;'></i> Reportes </li>"
			for i=0 to reportesLar
				if(i=item) then
					clase="active"
					clase2="done act"
				else
					clase=""
					clase2="done"
				end if
				salida = salida + "<li role='presentation' class='" & clase & " mnustep reportes' data-url='" & reportesURL(i) & "'><a role='tab' href='#'" & param &"><i class='globo " & clase2 & "'>" & ucase(mid(reportesNom(i),1,1)) & "</i>" & reportesNom(i) & " </a></li>"
			next
			salida = salida + "</ul>"
		'end if
		if (session("wk2_usrperfil")<>4 and session("wk2_usrperfil")<>3) then
			salida = salida + "<ul class='nav nav-stacked nav-tree' role='tab-list'>"			
			salida = salida + "<li role='presentation' class='category text-primary mantenedores' style='margin-top: 0;'><i class='fas fa-angle-up ml-1 manmenu'></i><i class='fas fa-server' style='padding-right:7px;'></i> Mantenedores </li>"
			
			for i=0 to mantenedoresLar
				if(i=item) then
					clase="active"
					clase2="done act"
				else
					clase=""
					clase2="done"
				end if
				salida = salida + "<li role='presentation' class='" & clase & " mnustep mantenedores' style='height:0;padding-top:0;visibility:hidden;opacity:0' data-url='" & mantenedoresURL(i) & "'><a role='tab' href='#'" & param &"><i class='globo " & clase2 & "'>" & ucase(mid(mantenedoresNom(i),1,1)) & "</i>" & mantenedoresNom(i) & " </a></li>"
			next
			salida = salida + "</ul>"
		end if						
				
		response.write(salida)	
	end function		
%><%
response.write("/@/" & pryarc)%>