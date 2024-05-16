<%
'Response.AddHeader "Refresh",CStr(CInt(Session.Timeout + 1) * 20)	'60*8
Response.AddHeader "cache-control", "private"
Response.AddHeader "Pragma","No-Cache"
Response.Buffer = TRUE
Response.Expires = -1
Response.ExpiresAbsolute = 0
Response.CharSet = "utf-8"
Session.Timeout=60 * 8

HostName = "https://" & Request.ServerVariables("SERVER_NAME")

ruta=Request.ServerVariables("HTTP_REFERER")
if (InStr(ruta,"home")=0 or isnull(InStr(ruta,"home"))) then		
	response.redirect("/ingreso-de-credenciales")
	'Response.write("503")
	response.end()
else
	If (Session("workflowv2") <> Session.SessionID) Then
		Session("RequestedURL") = "https://" & _
			Request.ServerVariables("SERVER_NAME") & _
			Request.ServerVariables("SCRIPT_NAME")

		Temp = Request.ServerVariables("QUERY_STRING")
		If (Not(ISNull(Temp)) AND Temp <> "") Then
			Session("RequestedURL") = Session("RequestedURL") & _
				"?" & Temp
		End If	
		Response.write("504")
		response.end()
	end if		

	'response.write("0/@/")
end if
%>