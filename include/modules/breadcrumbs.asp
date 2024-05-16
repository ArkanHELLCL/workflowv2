<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<%=response.write("200/@/")%>
<%	

set cnn = Server.CreateObject("ADODB.Connection")
on error resume next	
cnn.open session("DSN_WorkFlowv2")
if cnn.Errors.Count > 0 then 
   ErrMsg = cnn.Errors(0).description	   
   cnn.close
   response.Write("503/@/Error Conexión:" & ErrMsg)
   response.End() 			   
end if

tabId=request("tabId")
if(not IsNULL(tabId) and trim(tabId)<>"") then
	tabId=trim(tabId) & "-tab"
else
	tabId=""
end if
mnuarc=""
ruta_split = split(ruta,"/")
if(UBound(ruta_split)>=7) then
	modo=CInt(ruta_split(1))
	VFL_Id=CInt(ruta_split(2))
	DRE_Id=CInt(ruta_split(3))
end if

set cnn = Server.CreateObject("ADODB.Connection")
on error resume next	
cnn.open session("DSN_WorkFlowv2")	
if cnn.Errors.Count > 0 then 
	ErrMsg = cnn.Errors(0).description	      
	sw=6
	cnn.close
	response.Write(sw & "//ERROR SQL " & ErrMsg)
	response.End() 			   
end if
sql="exec [spUsuarioVersionFlujoxUsuarioFlujo_Consultar]  " & session("wk2_usrid") & "," & VFL_Id
set rs = cnn.Execute(sql)
bandeja=false
do while not rs.eof
	if(not ISNULL(rs("FLU_BandejaAntiguos"))) then
		if rs("FLU_BandejaAntiguos")=1 then
			bandeja=true
			exit do
		end if
	end if
	rs.movenext
loop
rs.close
cnn.close

prynuevos=0
xbread=replace(ruta,HostName,"")
recortaurl

xbread=mid(replace(xbread,"-"," "),2,len(xbread))

secciones = Split(xbread,"/")
largo = Ubound(secciones) + 1

if(bandeja) then
	menuBread = array("Bandeja de entrada","Bandeja de salida","Bandeja otros proyectos","Bandeja de finalizados","Bandeja de archivados","Bandeja requerimientos antiguos","Bandeja de antiguos pendientes","Reportes","Mantenedores")

	iconBread = array(	"<li data-url='/bandeja-de-entrada' data-tab='" & tabId & "'><i class='fas fa-book'></i> Bandeja de entrada</li>",_
						"<li data-url='/bandeja-de-salida' data-tab='" & tabId & "'><i class='fas fa-book'></i> Bandeja de salida</li>",_
						"<li data-url='/bandeja-otros-proyectos' data-tab='" & tabId & "'><i class='fas fa-book'></i> Bandeja otros proyectos</li>",_
						"<li data-url='/bandeja-de-finalizados' data-tab='" & tabId & "'><i class='fas fa-book'></i> Bandeja de finalizados</li>",_
						"<li data-url='/bandeja-de-archivados' data-tab='" & tabId & "'><i class='fas fa-book'></i> Bandeja de archivados</li>",_
						"<li data-url='/bandeja-requerimientos-antiguos' data-tab='" & tabId & "'><i class='fas fa-book'></i> Bandeja requerimientos antiguos</li>",_
						"<li data-url='/bandeja-pendientes-antiguos' data-tab='" & tabId & "'><i class='fas fa-book'></i> Bandeja de antiguos pendientes</li>",_
						"<li data-url='/reportes'><i class='fas fa-print'></i> Reportes</li>",_
						"<li data-url='/mantenedores'><i class='fas fa-server'></i> Mantenedores</li>")

	'Perfiles					
	perfBread = array(	"1,2,3,4,5",_
					"3,4",_
					"2,3",_
					"1,2,3,4,5",_
					"1,2,3,4,5",_
					"1,2,3,4,5",_
					"1,2,3,5",_
					"1,2,3,4,5",_
					"1,2,5")
else
	menuBread = array("Bandeja de entrada","Bandeja de salida","Bandeja otros proyectos","Bandeja de finalizados","Bandeja de archivados","Bandeja requerimientos antiguos","Reportes","Mantenedores")

	iconBread = array(	"<li data-url='/bandeja-de-entrada' data-tab='" & tabId & "'><i class='fas fa-book'></i> Bandeja de entrada</li>",_
					"<li data-url='/bandeja-de-salida' data-tab='" & tabId & "'><i class='fas fa-book'></i> Bandeja de salida</li>",_
					"<li data-url='/bandeja-otros-proyectos' data-tab='" & tabId & "'><i class='fas fa-book'></i> Bandeja otros proyectos</li>",_
					"<li data-url='/bandeja-de-finalizados' data-tab='" & tabId & "'><i class='fas fa-book'></i> Bandeja de finalizados</li>",_
					"<li data-url='/bandeja-de-archivados' data-tab='" & tabId & "'><i class='fas fa-book'></i> Bandeja de archivados</li>",_
					"<li data-url='/bandeja-requerimientos-antiguos' data-tab='" & tabId & "'><i class='fas fa-book'></i> Bandeja requerimientos antiguos</li>",_
					"<li data-url='/reportes'><i class='fas fa-print'></i> Reportes</li>",_
					"<li data-url='/mantenedores'><i class='fas fa-server'></i> Mantenedores</li>")

	'Perfiles					
	perfBread = array(	"1,2,3,4,5",_
					"3,4",_
					"2,3",_
					"1,2,3,4,5",_
					"1,2,3,4,5",_
					"1,2,3,4,5",_
					"1,2,3,4,5",_
					"1,2,5")
end if

largBread = UBound(menuBread)

sub recortaurl	
	'Modificar
	pos2=InStr(xbread,"modificar")
	if (pos2>0 and not isnull(pos2)) then		
		xbread=mid(xbread,1,pos2+8)	
	else
		'Visualizar
		pos3=InStr(xbread,"visualizar")
		if (pos3>0 and not isnull(pos3)) then			
			xbread=mid(xbread,1,pos3+9)
		else
			'Agregar
			pos4=InStr(xbread,"agregar")
			if (pos4>0 and not isnull(pos4)) then
				xbread=mid(xbread,1,pos4+6)
			else

			end if
		end if 
	end if 				
end sub

%>
<div class="btn-toolbar" role="toolbar" style="float:left;" id="breadcrumbs">
	<nav aria-label="breadcrumb">
	  <ol class="breadcrumb"><%
	  	ismant=false
	  	for each x in secciones			
			cont=cont+1
			word = lcase(trim(x))
			word = replace(word,mid(word,1,1),ucase(mid(word,1,1)),1,1)
			if cont=2 then
				call menusistema(word,"")
			end if
			if cont>2 then%>
				<li class="breadcrumb-item active"></i> <%=word%></a></li><%
			end if
		next%>		
	  </ol>	  		
	</nav>
</div><%

function menusistema(word,active)%>		
	<li class="breadcrumb-item sistema <%=active%>">
		<a href="#" data-url="/<%=replace(LCase(word)," ","-")%>" data-tab="<%=tabId%>"> <%=word%>
			<div class="content-sistema">
				<ul class="menusistema"><%
					for i=0 to largBread
						if(word<>menuBread(i)) then
							perfiles=Split(perfBread(i),",")							
							allowed=false
							for j=0 to UBound(perfiles)								
								if(CInt(perfiles(j))=session("wk2_usrperfil")) then
									allowed=true
									'if(session("wk2_usrperfil")=4 and session("wk2_usrjefatura")=1 and i=1) then
										'allowed=false
									'end if
									if(session("wk2_usrperfil")=3 and session("wk2_usrdepvista")=1 and i=1) then
										allowed=false
									end if
									if(session("wk2_usrperfil")=3 and session("wk2_usrdepvista")<>1 and i=2) then
										allowed=false
									end if
									exit for
								end if								
							next
							if(allowed) then
								response.write(iconBread(i))
							end if
						end if
					next%>					
				</ul>
			</div>		
		</a>
	</li><%
end function
%>