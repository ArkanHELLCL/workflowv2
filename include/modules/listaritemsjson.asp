<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->

<%			
    LID_Id = request("prm1")
	search = ucase(trim(request("search")))

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	    ErrMsg = cnn.Errors(0).description	   
	    cnn.close%>
        {"status":"503","message":"<%=ErrMsg%>","data":[]}<%
	    response.End() 			   
	end if

	xql="exec spItemListaDesplegable_Listar " & LID_Id & ", 1, '" & search & "'"
    set rx = cnn.Execute(xql)		
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description			
        cnn.close%>
        {"status":"503","message":"<%=ErrMsg%>","data":[]}<%        
        response.End()		
    end if%>
    {"status":"200","message":"Ejecución exitosa","data":{
    <%
    count = 0
    do while not rx.eof
        count=count+1%>
        "<%=rx("ILD_Id")%>":"<%=rx("ILD_Descripcion")%>"<%
        rx.movenext
        if not rx.eof then%>,<%end if
    loop				
	cnn.close
	set cnn = nothing%>
    },"totalRecords": <%=count%>}