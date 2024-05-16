<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="include\template\session.min.inc" -->
<!-- #INCLUDE FILE="include\template\functions.inc" -->
<%					
	if isEmpty(session("wk2_usrid")) or isNull(session("wk2_usrid")) then
		response.Write("500/@/Error Parámetros no válidos")
		response.end
	end if
    REQ_Id = request("REQ_Id")
    dataRequerimiento = "{""data"":"

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write(dataRequerimiento & "[{""code"":""503"",""response"":""" & ErrMsg & """}]}")
	   response.End() 			   
	end if
    	

	set rs = cnn.Execute("exec spRequerimiento_Consultar " & REQ_Id)
    if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write(dataRequerimiento & "[{""code"":""503"",""response"":""" & ErrMsg & """}]}")
	   response.End() 			   
	end if
	if not rs.EOF then		
        dataRequerimiento = dataRequerimiento & "[{""code"":""200"",""response"":""" & rs("REQ_Descripcion") & """}]"
    else
        dataRequerimiento = dataRequerimiento & "[{""code"":""404"",""response"":""No se encontraron datos""}]" 
    end if

    dataRequerimiento=dataRequerimiento & ", ""REQ_Id"":""" & REQ_Id & """, ""FLU_Id"":""" & rs("FLU_Id") & """}"
    rs.Close
    cnn.Close     
      	
    response.write(dataRequerimiento)
    %>