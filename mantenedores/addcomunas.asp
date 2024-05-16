<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%	
	if(session("wk2_usrperfil")>2) then	%>
	   {"state": 403, "message": "Perfil no autorizado","data": null}<%
		response.End() 			   
	end if		
		
	REG_Id			    = Request("REG_Id")
	COM_Nombre	        = LimpiarUrl(Request("COM_Nombre"))
	COM_OrdenGeografico = Request("COM_OrdenGeografico")
	
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close%>
	   {"state": 503, "message": "Error Conexión : <%=ErrMsg%>","data" : "<%=datos%>"}<%
	   response.End() 			   
	end if	

	tql="exec spRegion_consultar " & REG_Id
	set rs = cnn.Execute(tql)
	on error resume next
	if(not rs.eof) then
		REG_OrderGeografico = rs("REG_OrderGeografico")
	end if

	if(len(COM_OrdenGeografico)=1) then
		COM_OrdenGeografico="00" & COM_OrdenGeografico
	end if
	if(len(COM_OrdenGeografico)=2) then
		COM_OrdenGeografico="0" & COM_OrdenGeografico
	end if

	COM_OrdenGeografico = trim(REG_OrderGeografico) & COM_OrdenGeografico
 
	datos = COM_OrdenGeografico & ",'" & COM_Nombre & "'," & REG_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"		
	
	sql="exec spComuna_Agregar " & datos 
	
	set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then%>
	   {"state": 503, "message": "Error Conexión : <%=ErrMsg%>","data": "<%=sql%>"}<%
		rs.close
		cnn.close
		response.end()
	End If					
	
	cnn.close
	set cnn = nothing%>
	{"state": 200, "message": "Ejecución exitosa","data": null}