<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%	
	if(session("wk2_usrperfil")>2) then	%>
	   {"state": 403, "message": "Perfil no autorizado","data": null}<%
		response.End() 			   
	end if				

    PRO_Id                  = Request("PRO_Id")
    PRO_RazonSocial	        = LimpiarUrl(Request("PRO_RazonSocial"))
    Rut		    	        = Request("PRO_Rut")

    PRO_Rut=replace(mid(Rut,1,len(Rut)-2),".","")
	PRO_DV=mid(Rut,len(Rut),1)
    
    PRO_Direccion	        = LimpiarUrl(Request("PRO_Direccion"))
    PRO_Telefono	        = Request("PRO_Telefono")
    PRO_Mail		        = Request("PRO_Mail")
    ILD_Id			        = Request("ILD_Id")
    TCU_Id			        = Request("TCU_Id")
    PRO_NumCuentaBancaria   = LimpiarUrl(Request("PRO_NumCuentaBancaria"))
    PRO_Estado              = Request("PRO_Estado")
	PRO_PAC              	= Request("PRO_PAC")

	if(ILD_Id="") then ILD_Id="null" end if
	if(TCU_Id="") then TCU_Id="null" end if
 
	datos = PRO_Id & ",'" & PRO_RazonSocial & "'," & PRO_Rut & ",'" & PRO_DV & "','" & PRO_Direccion & "','" & PRO_Telefono	& "','" & PRO_Mail	& "'," & ILD_Id & "," & TCU_Id & ",'" & PRO_NumCuentaBancaria & "'," & PRO_Estado & "," & PRO_PAC & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close%>
	   {"state": 503, "message": "Error Conexión : <%=ErrMsg%>","data" : "<%=datos%>"}<%
	   response.End() 			   
	end if		
	
	sql="exec spProveedores_Modificar " & datos 
	
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