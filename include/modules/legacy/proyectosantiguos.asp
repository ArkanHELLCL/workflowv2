<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<%
modo=request("modo")
'if(isnull(modo) or modo="") then
'    response.write("404/@/")
'    response.end()
'end if
'if(modo<>4) then
    response.write("404/@/")
    response.end()
'end if
'response.write("200/@/")
%>