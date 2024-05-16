<%
'Response.AddHeader "Refresh",CStr(CInt(Session.Timeout + 1) * 60 * 21)	'21 minutos
Response.AddHeader "cache-control", "private"
Response.AddHeader "Pragma","No-Cache"
Response.Buffer = TRUE
Response.Expires = -1
Response.ExpiresAbsolute = 0
Response.CharSet = "utf-8"
Session.Timeout=60 * 8	'20 mnutos

HostName = "https://" & Request.ServerVariables("SERVER_NAME")

If (Session("workflowv2") <> Session.SessionID) Then
	Session("RequestedURL") = "https://" & _
	    Request.ServerVariables("SERVER_NAME") & _
		Request.ServerVariables("SCRIPT_NAME")

	Temp = Request.ServerVariables("QUERY_STRING")
	If (Not(ISNull(Temp)) AND Temp <> "") Then
		Session("RequestedURL") = Session("RequestedURL") & _
		    "?" & Temp
	End If	
	Response.Redirect(HostName)
Else		
	wk2_usrperfil 	= session("wk2_usrperfil")
	wk2_usuario 	= session("wk2_usuario")
	wk2_usrnom 		= session("wk2_usrnom")
	wk2_usrid 		= session("wk2_usrid")
	wk2_usrtoken	= session("wk2_usrtoken")
	workflowv2 		= session("workflow2")
	
	'Obteniendo nombre de la pagina actual
	
	ruta = Request.ServerVariables("URL") 'recoge la ruta completa
	ruta = Split(ruta,"/") 'convierte cada separación señalada por / en un elemento de un vector
	
	PaginaActual = ruta(UBound(ruta)) 'recogemos el último elemento de ese vector...	
	
	MP = Split(PaginaActual,".")
	MasterPage =  MP(LBound(MP)) 'Pagina actual sin extension			
	
End If
%>