<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
    INF_Fecha = request("INF_Fecha")
    INF_Mes = request("INF_Mes")
    
    INF_Anio = request("INF_Anio")
    INF_Usuario = request("INF_Usuario")

    
    if(INF_Usuario=0) then
        INF_Usuario = -1
    end if    	

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if			
	
	'Departamento actual debe ser DAF
	sql = "exec [spOrdenesdeCompra_Listar] " & INF_Anio & "," & INF_Mes & "," & INF_Usuario & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
	set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error [spOrdenesdeCompra_Listar] " & sql)
		cnn.close 		
		response.end
	End If	
	cont=0
	dataordenesdecompra = "{""data"":["
	
	do While Not rs.EOF
		if cont>0 then
			dataordenesdecompra = dataordenesdecompra & ","
		end if
        if(len(rs("REQ_Descripcion"))>50) then
            REQ_Descripcion = left(rs("REQ_Descripcion"),100) & "..."
        else
            REQ_Descripcion = rs("REQ_Descripcion")
        end if
		dataordenesdecompra = dataordenesdecompra & "[""" & ucase(trim(rs("DFO_Dato"))) & """,""" & rs("VRE_Id") & """,""" & REQ_Descripcion & """,""" & rs("REQ_FechaEdit") & """,""" & rs("USR_UsuarioCreador") & """,""" & rs("USR_UsuarioEditor") & """,""" & rs("DEP_ActualDescripcion") & """,""" & rs("DEP_OrigenDescripcion") & """,""" & rs("ESR_ReqDescripcion") & """,""" & rs("FLU_Descripcion") & """,""" & rs("VFL_Id") & """,""" & rs("EstadoPago") & """,""" & rs("DRE_UsuarioPago") & """,""" & rs("DRE_FechaPago") & """]"

		rs.movenext			
		cont=cont+1	
	loop
	dataordenesdecompra=dataordenesdecompra & "]}"
	
	response.write(dataordenesdecompra)
%>