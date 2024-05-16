<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="include\template\session.min.inc" -->
<!-- #INCLUDE FILE="include\template\functions.inc" -->
<%					
	if isEmpty(session("wk2_usrid")) or isNull(session("wk2_usrid")) then
		response.Write("500/@/Error Parámetros no válidos")
		response.end
	end if
    VFL_Id = request("VFL_Id")
    dataPermisoCreacion = "{""data"":"

	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
    cnn.open session("DSN_WorkFlowv2")
	
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write(dataPermisoCreacion & "[{""code"":""503"",""response"":""" & ErrMsg & """}]}")
	   response.End() 			   
	end if    	

	set rs = cnn.Execute("exec [spPermisoCreacion_Consultar] " & session("wk2_usrdepid") & "," & session("wk2_usrperfil") & "," & VFL_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'")
    if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write(dataPermisoCreacion & "[{""code"":""503"",""response"":""" & ErrMsg & """}]}")
	   response.End() 			   
	end if
	if not rs.EOF then        
        dataPermisoCreacion = dataPermisoCreacion & "[{""code"":""200"",""response"":""" & rs("PermisoCreacion") & """}]"
    else
        dataPermisoCreacion = dataPermisoCreacion & "[{""code"":""404"",""response"":""No se encontraron datos""}]" 
    end if

    dataPermisoCreacion=dataPermisoCreacion & "}"
    rs.Close
    cnn.Close     
      	
    response.write(dataPermisoCreacion)
%>