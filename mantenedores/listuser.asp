<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<!-- #INCLUDE FILE="functions.inc" -->
<%	

'if session("wk2_usrperfil")<>1 then
	'response.write("403/@/No autorizado")
	'response.end()
'end if
Const titulo = "Listas de usuario v. 1.0"

Dim oRootLDAP, Dominio
Dim nombre, departamento, pais, descripcion, empresa, texto
Dim objFSOut, objStreamout, fileout

ahora = now
ano = datepart("yyyy",ahora)
mes = datepart("m",ahora)
dia = datepart("d",ahora)
hora = datepart("h",ahora)
minuto = datepart("n",ahora)
segundo = datepart("s",ahora)
ahora = ano & mes & dia & hora & minuto & segundo


Set oRootLDAP = GetObject("LDAP://rootDSE")
Dominio = "OU=MINTRAB,DC=MINTRAB,DC=MS"
Set oContenedor = GetObject("LDAP://" & Dominio)
response.write("200/@/")%>

<meta charset="UTF-8">

<div class="row container-header">
	<div class="col-sm-12">

		
	</div>
</div>

<div class="row container-body">
	<div class="col-sm-12">
		<div style="overflow-x: auto;">
			<table id="tbl-usuariosldap" class="ts table table-striped table-bordered dataTable table-sm" data-id="usuariosldap" data-page="true" data-selected="true" data-keys="1" style="margin-bottom: 0;" data-url="" data-noajax="true" cellspacing="0" width="100%" data-edit="false">
				<thead> 
					<tr>					
						<th>Usuario</th>									
						<th>Nombres</th>
						<th>Apellidos</th>
						<th>RUT</th>
						<th>Correo</th>
						<th>Departamento</th>					
					</tr> 
				</thead>							
				<tbody><%		

					listUsers(oContenedor)%>

				</tbody>                 
			</table>
		</div>
	</div>
</div><%

sub listUsers(oObjeto)
	dim oUser
	for each oUser in oObjeto
		'response.write(oUser.get("distinguishedName") & "</br>")
		select case lcase(oUser.class)
			case "user"

				'cn=oUser.get("cn")			
				cuenta=oUser.get("sAMAccountname")

				nombres=ObtenInfo(cuenta,"givenname",Dominio)			'ObtenInfo(cuenta,"DisplayName",Dominio)
				apellidos=ObtenInfo(cuenta,"sn",Dominio)				
				departamento=EliminarAcentos(ObtenInfo(cuenta,"department",Dominio))
				mail=ObtenInfo(cuenta,"mail",Dominio)			
				rut=ObtenInfo(cuenta,"extensionAttribute1 ",Dominio)
				dv=ObtenInfo(cuenta,"extensionAttribute2 ",Dominio)

				texto = "<tr class='usrline'><td>" & cuenta & "</td><td>" & nombres & "</td><td>" & apellidos & "</td><td>" & rut & dv & "</td><td>" & mail & "</td><td>" & departamento & "</td></tr>"	


				'if departamento<>"" and mail<>"N/A" and rut<>"N/A" then
				if departamento<>"" and mail<>"N/A" then
					response.write(texto)
				end if			
			case "organizationalunit", "container"
				listUSers(GetObject("LDAP://" & oUser.get("distinguishedName")))			
		end select
	next
end sub
%>
