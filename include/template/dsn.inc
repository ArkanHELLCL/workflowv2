<%
'--------------------------------------------------------------------
' Archivo de Conexion a Base de Datos  DSN.INC
'
'--------------------------------------------------------------------
'---- Servidor ?----
'---- Base de Datos WorkFlow----

Const DSN_WorkFlowv2 = "Provider=SQLNCLI11;Trusted_Connection=yes;DATABASE=WorkFlowV2;Server=REDBULL-SRV\SQLDES;"
'Const DSN_WorkFlowv2 = "Provider=SQLNCLI11;Trusted_Connection=yes;DATABASE=WorkFlowV2;Server=RAPTORS-SRV;"
session("DSN_WorkFlowv2") = DSN_WorkFlowv2
%>
