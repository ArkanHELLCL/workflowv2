<!-- #INCLUDE FILE="include\template\dsn.inc" -->
<% 'getaduserimage.asp file contains:
Domain="MINTRAB.MS"
strUsername=request("usr_cod")
'Password=request("usr_pass")
Password="Usuario2018"



set cnn = Server.CreateObject("ADODB.Connection")
on error resume next	
cnn.open session("DSN_WorkFlowv2")	
if cnn.Errors.Count > 0 then 
   ErrMsg = cnn.Errors(0).description	   
   sw=4	   
   cnn.close
   response.Write(sw & "//Error Conexi&oacute;n:" & ErrMsg)
   response.End() 			   
end if		

sql="exec [spUsuario_ConsultarPorLogin] '" + strUsername + "'"

on error resume next
set rs = cnn.Execute(sql)	
if cnn.Errors.Count > 0 then 
   ErrMsg = cnn.Errors(0).description	   
   sw=5
   response.Write(sw & "//Error SQL:" & ErrMsg)
   rs.close
   cnn.close
Else	
	if not rs.eof then
		if rs("USR_Estado")=1 then
			sw=0
		else
			sw=1	'ok			
		end if
	else
		sw=2	'ok		
	end if
End if

if sw=0 then
	dim strUser,strPass,strQuery,oConn,cmd,oRS

	AuthenticateUser = false		        
	strQuery = "SELECT thumbnailPhoto FROM 'LDAP://" & Domain & "' WHERE sAMAccountname='"+strUsername+"'"
	set oConn = server.CreateObject("ADODB.Connection")
	oConn.Provider = "ADsDSOOBJECT"	

	oConn.properties("User ID") ="tic"
	oConn.properties("Password")=Password
	oConn.properties("Encrypt Password") = true
	'oConn.open "DS Query", strUsername,Password
	oConn.open "DS Query", "tic",Password
	set cmd = server.CreateObject("ADODB.Command")
	set cmd.ActiveConnection = oConn
	cmd.CommandText = strQuery
	on error resume next      

	Set rs = cmd.Execute

	Response.Expires = 0  
	Response.Buffer = TRUE  
	Response.Clear  
	Response.ContentType = "image/jpeg" 
	'#### Assuming your images are jpegs 
	if not rs.eof then
		Response.BinaryWrite rs("thumbnailPhoto")  
		'Response.write rs("thumbnailPhoto")  
	else 
	   'response.write "la Imagen de " &  strUsername & " no esta disponible"
	end if
	rs.Close
	con.Close
	Set rs = Nothing
	Set con = Nothing
end if
%>