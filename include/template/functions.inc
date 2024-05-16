<%
Function Base64Encode(sText)
  Dim oXML, oNode
  Set oXML = CreateObject("Msxml2.DOMDocument.3.0")
  Set oNode = oXML.CreateElement("base64")
  oNode.dataType = "bin.base64"
  oNode.nodeTypedValue = Stream_StringToBinary(sText)
  Base64Encode = oNode.text
  Set oNode = Nothing
  Set oXML = Nothing
End Function

Function Base64Decode(ByVal vCode)
  Dim oXML, oNode
  Set oXML = CreateObject("Msxml2.DOMDocument.3.0")
  Set oNode = oXML.CreateElement("base64")
  oNode.dataType = "bin.base64"
  oNode.text = vCode
  Base64Decode = Stream_BinaryToString(oNode.nodeTypedValue)
  Set oNode = Nothing
  Set oXML = Nothing
End Function

Private Function Stream_StringToBinary(Text)
  Const adTypeText = 2
  Const adTypeBinary = 1
  Dim BinaryStream 'As New Stream
  Set BinaryStream = CreateObject("ADODB.Stream")
  BinaryStream.Type = adTypeText
  BinaryStream.CharSet = "us-ascii"
  BinaryStream.Open
  BinaryStream.WriteText Text
  BinaryStream.Position = 0
  BinaryStream.Type = adTypeBinary
  BinaryStream.Position = 0
  Stream_StringToBinary = BinaryStream.Read
  Set BinaryStream = Nothing
End Function

Private Function Stream_BinaryToString(Binary)
  Const adTypeText = 2
  Const adTypeBinary = 1
  Dim BinaryStream 'As New Stream
  Set BinaryStream = CreateObject("ADODB.Stream")
  BinaryStream.Type = adTypeBinary
  BinaryStream.Open
  BinaryStream.Write Binary
  BinaryStream.Position = 0
  BinaryStream.Type = adTypeText
  BinaryStream.CharSet = "us-ascii"
  Stream_BinaryToString = BinaryStream.ReadText
  Set BinaryStream = Nothing
End Function

Function EliminarAcentos(texto)

    Dim i, s1, s2
    s1 = "ÁÀÉÈÍÏÓÒÚÜáàèéíïóòúüñç"
    s2 = "AAEEIIOOUUaaeeiioouunc"
    If Len(texto) <> 0 Then
        For i = 1 To Len(s1)
            texto = Replace(texto, Mid(s1,i,1), Mid(s2,i,1))
        Next
    End If
    
    EliminarAcentos = texto

End Function

Function LimpiarUrl(ByVal texto)
    
    Dim objRegExp
    Set objRegExp = New Regexp
    
    objRegExp.IgnoreCase = True
    objRegExp.Global = True
    
    objRegExp.Pattern = "\s+"
    texto = objRegExp.Replace(texto, " ")
    '	%, /, (), =, ∑, +, - 
    objRegExp.Pattern = "[""\\<>&#~{}@:\/!;'//]+"
    texto = objRegExp.Replace(texto, "")
    
    Dim i, s1, s2
    's1 = "ÁÀÉÈÍÏÓÒÚÜáàèéíïóòúüñç "
    's2 = "AAEEIIOOUUaaeeiioouunc-"
	s1 = "ÁÀÉÈÍÏÓÒÚÜàèïòüç"
    s2 = "AAEEIIOOUUaeiouc"
    If Len(texto) <> 0 Then
        For i = 1 To Len(s1)
            texto = Replace(texto, Mid(s1,i,1), Mid(s2,i,1))
        Next
    End If

    'LimpiarUrl = LCase(texto)
    LimpiarUrl = Replace(Replace(Replace(texto,chr(10),""),chr(9),""),chr(13),"")

End Function

function ObtenInfo(oUser,oCampo, cDominio)
	set cn = createobject("ADODB.Connection")
	set cmd = createobject("ADODB.Command")
	set rs = createobject("ADODB.Recordset")
	cn.open "Provider=ADsDSOObject;"

	cmd.activeconnection=cn
	cmd.commandtext="SELECT " & oCampo & " FROM 'LDAP://" & cDominio & _
	   "' WHERE sAMAccountName = '" & oUser & "'"
	
	set rs = cmd.execute
	if err<>0 then
		 FindUser="Error conectandose a la base del AD:" & err.description
	else
		if not rs.EOF then
		if (not rs.BOF and not rs.EOF) AND (rs(0)<>"") then
			ObtenInfo=rs(0)
		else
			ObtenInfo="N/A"
		end if	
		else
			ObtenInfo="N/A"
		end if
	end if
	cn.close
end function

Function ConvertirFecha(Fecha)
	dia=mid(Fecha,1,2)
	mes=mid(Fecha,4,2)
	anio=mid(Fecha,7,4)
	ConvertirFecha=anio & "-" & mes & "-" & dia & " " & mid(Fecha,12, len(Fecha))
end Function

Function ConvertirFechaInverso(Fecha)
	anio=mid(Fecha,1,4)
	mes=mid(Fecha,6,2)
	dia=mid(Fecha,9,2)
	ConvertirFechaInverso=dia & "-" & mes & "-" & anio & " " & mid(Fecha,12, len(Fecha))
end Function

function filtrariplocal(IP)
	'10.0.0.1 - 10.0.255.254
	' Regiones 		10.0.1.0   - 10.0.17.0
	' Metropolitana	10.0.101.0 - 10.0.110.0 
	'DIM IP
	'Regiones
	MinIp1=1
	MaxIp1=17

	'Metropolitana
	MinIp11=101
	MaxIp11=110
	
	MinIp12=200
	MaxIp12=200
	
	MinIp2=1	
	MaxIp2=254	

	'IP = Request.ServerVariables("HTTP_X_FORWARDED_FOR") ' se chequea si hay un proxy

	'If IP ="" Then IP = Request.ServerVariables("REMOTE_ADDR") ' si no hay proxy se toma la IP original

	desIP=split(IP,".")	
	'response.write(IP & "<br/>")

	NDesIPa=CInt(desIP(0))
	NDesIPb=CInt(desIP(1))

	NDesIP1=CInt(desIP(2))
	NDesIP2=CInt(desIP(3))
	'response.write("entre")
	'response.write(desIP(0) & "<br/>")
	'response.write(desIP(1) & "<br/>")
	'response.write(desIP(2) & "<br/>")
	'response.write(desIP(3) & "<br/>")

	if(NDesIPa=10 and NDesIPb=0) then	'Regiones
		'response.write("Primer o Segundo numero dentro del rango (10.0): " & NDesIPa & "." & NDesIPb)		
		'filtrariplocal=true
		if(NDesIP1>=MinIp1 and NDesIP1<=MaxIp1) then
			'response.write("Primer numero dentro del rango (0-255): " & NDesIP1)		
			'filtrariplocal=true
			if(NDesIP2>=MinIp2 and NDesIP2<=MaxIp2) then
				'response.write("Primer numero dentro del rango (1-254): " & NDesIP2)
				filtrariplocal=0
				'response.write("<span class='mute">Acesso desde intranet</span>")
			else
				'response.write("Primer numero fuera del rango : (1-254)" & NDesIP2)
				filtrariplocal=-1
			end if	
		else
			if(NDesIP1>=MinIp11 and NDesIP1<=MaxIp11) then
				'response.write("Primer numero dentro del rango (0-255): " & NDesIP1)		
				'filtrariplocal=true
				if(NDesIP2>=MinIp2 and NDesIP2<=MaxIp2) then
					'response.write("Primer numero dentro del rango (1-254): " & NDesIP2)
					filtrariplocal=1
					'response.write("<span class='mute">Acesso desde intranet</span>")
				else
					'response.write("Primer numero fuera del rango : (1-254)" & NDesIP2)
					filtrariplocal=-1
				end if	
			else
				if(NDesIP1>=MinIp12 and NDesIP1<=MaxIp12) then
					'response.write("Primer numero dentro del rango (0-255): " & NDesIP1)		
					'filtrariplocal=true
					if(NDesIP2>=MinIp2 and NDesIP2<=MaxIp2) then
						'response.write("Primer numero dentro del rango (1-254): " & NDesIP2)
						filtrariplocal=1
						'response.write("<span class='mute">Acesso desde intranet</span>")
					else
						'response.write("Primer numero fuera del rango : (1-254)" & NDesIP2)
						filtrariplocal=-1
					end if	
				else
					'response.write("Primer numero fuera del rango (0-255): " & NDesIP1)
					filtrariplocal=-1
				end if
			end if							
		end if
	else		
		filtrariplocal=-1		
	end if	
	
end function

Function RegExResults(strTarget, strPattern)

    Set regEx = New RegExp
    regEx.Pattern = strPattern
    regEx.Global = true
    Set RegExResults = regEx.Execute(strTarget)
    Set regEx = Nothing

End Function


%>