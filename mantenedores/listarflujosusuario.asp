<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
	if(session("wk2_usrperfil")>2) then
		response.Write("403\\Perfil no autorizado")
		response.End() 			   
	end if	
		
	USR_Id = Request("USR_Id")
    if(CInt(session("wk2_usrperfil"))=1) then
	    sql="exec [spUsuarioVersionFlujoNoAsignado_Listar] 1, " & USR_Id
    else
        sql="exec [spUsuarioVersionFlujoNoAsignadoPerfil_Listar] " & USR_Id & ",1, " & session("wk2_usrid")
    end if

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503\\Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if		
	
	set rs = cnn.Execute(sql)
	'response.write(sql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503\\Error Conexión:" & ErrMsg & "-" & sql)
	    response.End()
	End If
	response.write("200\\")%>
	<option value="" disabled selected></option><%
	do While Not rs.eof%>
		<option value="<%=rs("VFL_Id")%>"><%=rs("FLU_Descripcion")%>(V.<%=rs("VFL_Id")%>)</option><%		
		rs.movenext						
	loop					
	rs.close									
%>