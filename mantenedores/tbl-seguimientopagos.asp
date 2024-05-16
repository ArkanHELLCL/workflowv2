<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%	
    INF_Fecha = request("INF_Fecha")
    INF_Mes = request("INF_Mes")
    
    INF_Anio = request("INF_Anio")
    INF_Usuario = request("INF_Usuario")

	INF_NroDoc = request("INF_NroDoc")
	INF_Proveedor = request("INF_Proveedor")
	INF_NroOC = request("INF_NroOC")

    
    if(INF_Usuario=0) then
        INF_Usuario = -1
    end if    	

	IF(INF_NroDoc="") THEN
		INF_NroDoc = "NULL"
	END IF
	IF(INF_NroOC="") THEN
		INF_NroOC = "NULL"
		sql = "exec spSeguimientoPagos_Listar " & INF_Anio & "," & INF_Mes & "," & INF_Usuario & "," & INF_NroDoc & "," & INF_Proveedor & ",NULL," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
	else
		sql = "exec spSeguimientoPagos_Listar " & INF_Anio & "," & INF_Mes & "," & INF_Usuario & "," & INF_NroDoc & "," & INF_Proveedor & ",'" & LimpiarURL(INF_NroOC) & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
	END IF

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if			
		
	
	set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error [spSeguimientoPagos_Listar] " & sql)
		cnn.close 		
		response.end
	End If	
	cont=0
	dataseguimientoPagos = "{""data"":["
	
	do While Not rs.EOF
		if cont>0 then
			dataseguimientoPagos = dataseguimientoPagos & ","
		end if
        if(len(rs("REQ_Descripcion"))>50) then
            REQ_Descripcion = left(rs("REQ_Descripcion"),100) & "..."
        else
            REQ_Descripcion = rs("REQ_Descripcion")
        end if
		dataseguimientoPagos = dataseguimientoPagos & "[""" & rs("VRE_Id") & """,""" & REQ_Descripcion & """,""" & rs("REQ_FechaEdit") & """,""" & rs("USR_UsuarioCreador") & """,""" & rs("USR_UsuarioEditor") & """,""" & rs("NumeroDocumento") & """,""" & rs("DESProveedor") & """,""" & rs("OC") & """,""" & rs("DifCreaPago") & """,""" & rs("FLU_Descripcion") & """,""" & rs("VFL_Id") & """,""" & rs("EstadoPago") & """,""" & rs("DRE_UsuarioPago") & """,""" & rs("DRE_FechaPago") & """]"

		rs.movenext			
		cont=cont+1	
	loop
	dataseguimientoPagos=dataseguimientoPagos & "]}"
	
	response.write(dataseguimientoPagos)
%>