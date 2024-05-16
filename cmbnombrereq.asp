<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="include\template\session.min.inc" -->
<!-- #INCLUDE FILE="include\template\functions.inc" -->
<%
    dataRequerimiento = "{""data"":"
	if isEmpty(session("wk2_usrid")) or isNull(session("wk2_usrid")) then
		response.Write(dataRequerimiento & "[{""code"":""500"",""response"":""Parámetros no Válidos""}]}")
		response.end
	end if
    REQ_Id = request("REQ_IdCmbNombre")
    REQ_DesAnterior = LimpiarUrl(request("NombreActual"))
    REQ_Descripcion = LimpiarUrl(request("NuevoNombre"))
    DRE_Id = request("DRE_IdActualNom")
    DRE_Observaciones = "Cambio de nombre Requerimiento - Nombre Anterior = " & REQ_DesAnterior    

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write(dataRequerimiento & "[{""code"":""503"",""response"":""" & ErrMsg & """}]}")
	   response.End() 			   
	end if    	

	set rs = cnn.Execute("exec spDatoRequerimiento_Consultar " & DRE_Id)
    if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write(dataRequerimiento & "[{""code"":""503"",""response"":""" & ErrMsg & """}]}")
	   response.End() 			   
	end if
	if not rs.EOF then		
        if(rs("VFO_Id")="" or isNULL(rs("VFO_Id"))) and session("wk2_usrid")=rs("IdCreador") then
            set rz = cnn.Execute("exec [spRequerimientoNombre_Modificar] " & REQ_Id & ",'" & rs("REQ_Identificador") & "','" & REQ_Descripcion & "','" & DRE_Observaciones & "'," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'")
            if cnn.Errors.Count > 0 then 
                ErrMsg = cnn.Errors(0).description	   
                cnn.close
                response.Write(dataRequerimiento & "[{""code"":""503"",""response"":""" & ErrMsg & """}]}")
                response.End()
            end if
            dataRequerimiento = dataRequerimiento & "[{""code"":""200"",""response"":""Modificación realizada""}]"            
        else
            response.Write(dataRequerimiento & "[{""code"":""403"",""response"":""Parámetros no válidos""}]}")
	        response.End() 			   
        end if                
    else
        dataRequerimiento = dataRequerimiento & "[{""code"":""404"",""response"":""No se encontraron datos""}]}" 
    end if

    dataRequerimiento=dataRequerimiento & ", ""REQ_Id"":""" & REQ_Id & """, ""FLU_Id"":""" & rs("FLU_Id") & """}"
    rs.Close
    cnn.Close     
      	
    response.write(dataRequerimiento)
    %>