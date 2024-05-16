<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->

<%
    prm1 = CInt(request("prm1"))
    search = request("search")
    dim Fecha
    mes=Array("","Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre")

    fecha=Now()
    fechadesde = DateAdd("yyyy", -prm1, fecha)
    
    %>
        {"status":"200","message":"Ejecución exitosa","data":{
    <%
    count = 0
    si=false
    do while fechadesde<=fecha
        count=count+1
        text = mes(month(fecha)) & " de " & year(fecha)                
        if(InStr(ucase(text),ucase(search))>0 or (IsNULL(search) or search="")) then
            if si then%>,<%end if
            si=true
            %>
            "<%=month(fecha)%>-<%=year(fecha)%>":"<%=text%>"<%
        end if        
        fecha = DateAdd("m", -1, fecha)        
    loop%>
    },"totalRecords": <%=count%>}