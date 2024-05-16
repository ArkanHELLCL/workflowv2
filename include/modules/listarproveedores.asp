<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->

<%			
	search = ucase(trim(request("search")))

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.write("503\\Error de conexion")
	   response.End() 			   
	end if

	xql="exec spProveedores_Listar 1 ,'" & search & "'"
    set rx = cnn.Execute(xql)		
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description			
        cnn.close 			   
        response.Write("503\\Error Conexión 3:" & ErrMsg)
        response.End()		
    end if
    response.write("200\\")
    do while not rx.eof%>
        <li data-value="<%=rx("PRO_Id")%>"><%=rx("PRO_RazonSocial")%> - <%=rx("PRO_Rut")%></li><%
        rx.movenext												
    loop
				
	cnn.close
	set cnn = nothing%>