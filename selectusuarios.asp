<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%	
    'if (session("wk2_usrperfil")=4 and session("wk2_usrjefatura")<>1) or session("wk2_usrperfil")=3 then
	'	response.Write("403/@/Error Perfil no autorizado")
	'	response.end()
	'end if
    DEP_Id = request("DEP_Id")
    VFL_Id = request("VFL_Id")

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if		
	
	response.write("200/@/")%>
	<select name="USR_IdSelected" id="USR_IdSelected" class="validate select-text form-control" required>
		<option value="" disabled selected></option><%
		if(session("wk2_usrperfil")=1) then
			set rs = cnn.Execute("exec spUsuario_Listar 1")
		else
			set rs = cnn.Execute("exec [spUsuarioDepartamentoFlujo_Listar] " & DEP_Id & "," & VFL_Id & ",1")
		end if
		on error resume next        				
		do While Not rs.eof%>
			<option value="<%=rs("USR_Id")%>"><%=rs("USR_Nombre")%>&nbsp;<%=rs("USR_Apellido")%>&nbsp;(<%=rs("USR_Usuario")%>)</option><%			
			rs.movenext						
		loop
		rs.Close	
		cnn.Close%>
	</select>
	<i class="fas fa-user input-prefix"></i>
	<span class="select-highlight"></span>
	<span class="select-bar"></span>
	<label class="select-label">Usuario Departamento Actual</label>
