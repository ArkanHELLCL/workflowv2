<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<!-- #INCLUDE FILE="functions.inc" -->
<%
    dataReqVisadoAutom = "{""data"":"
	if isEmpty(session("wk2_usrid")) or isNull(session("wk2_usrid")) then
		response.Write(dataReqVisadoAutom & "[{""code"":""500"",""response"":""Parámetros no Válidos""}]}")
		response.end
	end if
    FLU_Id = request("FLU_Id")

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write(dataReqVisadoAutom & "[{""code"":""503"",""response"":""" & ErrMsg & """}]}")
	   response.End() 			   
	end if    	

	set rs = cnn.Execute("exec [spDatoRequerimientoVisadoMasivo_Ejecutar] " & FLU_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'")
    if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write(dataReqVisadoAutom & "[{""code"":""503"",""response"":""" & ErrMsg & """}]}")
	   response.End() 			   
	end if
	
    dataReqVisadoAutom = dataReqVisadoAutom & "[{""code"":""200"",""response"":""Visación realizada""}]}"
                          
    rs.Close
    cnn.Close     
      	
    response.write(dataReqVisadoAutom)
    %>