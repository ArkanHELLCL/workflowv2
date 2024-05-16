<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%
  splitruta=split(ruta,"/")    
	xm=splitruta(5)
  DRE_Id=splitruta(7)
    
  INF_Id=request("INF_Id")
  if(INF_Id="") then        
      response.Write("404/@/Error 1 No fue posible encontrar el informe a generar")
    response.End()
  end if
  
  if(DRE_Id="" or DRE_Id=0) then        
      response.Write("404/@/Error 2 No fue posible encontrar el registro del requerimiento actual")
    response.End()
  end if

  set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error 3 Conexión:" & ErrMsg)
	   response.End()
	end If 

  'Consultando el nombre de la carpeta de requerimiento
  sql="exec spDatoRequerimiento_Consultar " & DRE_Id
  set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("503/@/Error 4: spDatoRequerimiento_Consultar")
		cnn.close 		
		response.end
	End If
  if not rs.eof Then
      VRE_Id=rs("VRE_Id")
      REQ_Id=rs("REQ_Id")
  else
      response.Write("404/@/Error 5 No fue posible encontrar el requeirmiento " & DRE_Id)
      response.End()
  end if

  tql="exec spInformes_Consultar " & INF_Id
  set rs = cnn.Execute(tql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("503/@/Error 6: spInformes_Consultar")
		cnn.close 		
		response.end
	End If
  if not rs.eof Then
      FLD_Id=rs("FLD_Id")      
      REQ_Descripcion=rs("REQ_Descripcion")
      VFO_Id=rs("VFO_Id")
      ESR_IdInforme = rs("ESR_IdInforme")
			if(IsNULL(ESR_IdInforme)) then
				ESR_IdInforme=2
			end if
  else
      response.Write("404/@/Error 7 No fue posible encontrar el id del flujo del informe " & INF_Id)
    response.End()
  end if
              
  'Buscar el formulario visado para este requerimiento para obtener la fecha de creacion relacionado con el FLD_Id de la tabla informes
  gsql="exec spIDVersionFormulario_Mostrar   " & VRE_Id & "," & FLD_Id & "," & ESR_IdInforme  'Memo
  set rsx = cnn.Execute(gsql)
  on error resume next
  if cnn.Errors.Count > 0 then 
      ErrMsg = cnn.Errors(0).description			
      cnn.close 			   
      response.Write("503/@/Error Conexión 8:" & ErrMsg)
      response.End()		
  end if
  if not rsx.eof then
      'Creador
      VFO_IdUSuarioEdit = rsx("VFO_IdUSuarioEdit")
      'UsuarioEdit = rsx("VFO_UsuarioEdit")     'Creador del formulario
      VFO_FechaEdit = rsx("VFO_FechaEdit")
  else
      response.Write("404/@/Error 10 No fue posible encontrar la version deñ informe " & VRE_Id & "-" & FLD_Id)
    response.End()
  end if

  'Buscar Departamento del creador del formulario
  xsql="exec [spUsuario_Consultar] " & VFO_IdUSuarioEdit
	set rs = cnn.Execute(xsql)		
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 9:" & ErrMsg)
		response.End()		
	end if
  if not rs.eof then
      'Creador
      DEP_Id=rs("DEP_Id")
      DEP_Descripcion=rs("DEP_Descripcion")

      'Usuario que aprobo el memo
      USR_Usuario = rs("USR_Usuario")     
      USR_Nombre = rs("USR_Nombre")
      USR_Apellido = rs("USR_Apellido")
      USR_Rut = rs("USR_Rut")
      USR_Dv = rs("USR_Dv")
      USR_Firma = rs("USR_Firma")
  else
      response.Write("404/@/Error 10 No fue posible encontrar departamento del creador " & INF_Id)
    response.End()
  end if
  
  'Buscar el jefe del departamento creador.
  'No, se debe buscar al usuario que aprobo el memo, ya que al momento de generar el memo podria ya no ser jefe de la unidad
  'ysql="exec spJefeDepartamento_Mostrar " & DEP_Id & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"  
	'set rs = cnn.Execute(ysql)		
	'on error resume next
	'if cnn.Errors.Count > 0 then 
	'	ErrMsg = cnn.Errors(0).description			
	'	cnn.close 			   
	'	response.Write("503/@/Error Conexión 11:" & ErrMsg)
	'	response.End()		
	'end if
  'if not rs.eof then
      'Jefatura
  '    USR_Usuario = rs("USR_Usuario")     'Jefe del departamento creador
  '    USR_Nombre = rs("USR_Nombre")
  '    USR_Apellido = rs("USR_Apellido")
  '    USR_Rut = rs("USR_Rut")
  '    USR_Dv = rs("USR_Dv")
  '    USR_Firma = rs("USR_Firma")
  'else
  '    response.Write("404/@/Error 12 No fue posible encontrar el usuario jefe del departamento creador " & DEP_Id)
  '    response.End()
  'end if

  'Buscando jefe/a DAF (4)
  DEP_IdDAF = 4
  rsql="exec spJefeDepartamento_Mostrar " & DEP_IdDAF & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
	set rs = cnn.Execute(rsql)		
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 11:" & ErrMsg)
		response.End()		
	end if
  if not rs.eof then
      'Jefatura
      USR_UsuarioDAF = rs("USR_Usuario")     'Jefe del departamento creador
      USR_NombreDAF = rs("USR_Nombre")
      USR_ApellidoDAF = rs("USR_Apellido")
      USR_RutDAF = rs("USR_Rut")
      USR_DvDAF = rs("USR_Dv")
      USR_IdDAF = rs("USR_Id")
      USR_FirmaDAF = rs("USR_Firma")

      DEP_DescripcionDAF=rs("DEP_Descripcion")
  else
      response.Write("404/@/Error 17 No fue posible encontrar el usuario DAF 4")
      response.End()
  end if

  DAF_Nombre = USR_NombreDAF & " " & USR_ApellidoDAF

  'Datos del memo
  id=REQ_Id & "/" & VRE_Id
  jefe_directo = USR_Nombre & " " & USR_Apellido
  jefe_directo=ucase(jefe_directo)
  cargo_jefe_directo=ucase(DEP_Descripcion)
  rut_jefe_directo=USR_Rut & "-" & USR_Dv
  rut_jefe_directo=ucase(rut_jefe_directo)	
	
	mes=month(VFO_FechaEdit)
	anio=year(VFO_FechaEdit)
	dia=day(VFO_FechaEdit)
	diasemana=weekday(VFO_FechaEdit)
	
	dim dias(7),meses(12)
	dias(1)="Domingo"
	dias(2)="Lunes"
	dias(3)="Martes"
	dias(4)="Miercoles"
	dias(5)="Jueves"
	dias(6)="Viernes"
	dias(7)="Sabado"

	meses(1)="Enero"
	meses(2)="Febrero"
	meses(3)="Marzo"
	meses(4)="Abril"
	meses(5)="Mayo"
	meses(6)="Junio"
	meses(7)="Julio"
	meses(8)="Agosto"
	meses(9)="Septiembre"
	meses(10)="Octubre"
	meses(11)="Noviembre"
	meses(12)="Diciembre"
	
	fecha_larga=dias(diasemana) + " " + cstr(dia) + " de " + meses(mes) + " de " + cstr(anio)	  		
%>
<style type="text/css">
<!--
.Estilo14 {font-family: Arial, Helvetica, sans-serif; font-size: 12; }
.Estilo12 {font-size: 12px}
.Estilo19 {font-size: 12px; font-weight: bold; text-align:left;}
-->
</style>
<table width="100%"  border="0" align="center"> 
  <tr>
    <td style="text-align:left;" width="30%"><span class="Estilo19"><strong>DE</strong></span></td>
    <td style="text-align:left;" width="70%"><strong>: <span class="Estilo19"><%=jefe_directo%></span></strong></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td style="text-align:left;" width="30%"><span class="Estilo19"><strong>A</strong></span></td>
    <td style="text-align:left;" width="70%"><span class="Estilo12"><strong>: SR.(A) <%=ucase(DAF_Nombre)%><BR>&nbsp;&nbsp;JEFE(A) DE <%=ucase(DEP_DescripcionDAF)%><BR>&nbsp;&nbsp;SUBSECRETARÍA DEL TRABAJO</strong></span>
    </td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
</table>
<table width="100%">
<%
  'Desplegando todos (-1) los datos de al ultima version del formulario grabada
  fsql="exec spDatosFormularioxVersion_Consultar " & DRE_Id & ",-1"
	set rs = cnn.Execute(fsql)		
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 9:" & ErrMsg)
		response.End()		
	end if
  do while not rs.eof
    if(CInt(rs("FDI_Imprimible"))=1) then%>
      <tr>
        <td style="font-size: 12;"><%=rs("FDI_Descripcion")%>&nbsp;:</td>
      </tr>
      <tr><%
        If(trim(rs("FDI_TipoCampo"))="N") then
          dato=FormatNumber(rs("DFO_Dato"),0)%>
          <td style="font-size: 12;"><%=dato%></td><%
        else%>
          <td style="font-size: 12;"><%=trim(rs("DFO_Dato"))%></td><%
        end if%>
      </tr>
      <tr>
        <td style="font-size: 12;">&nbsp;</td>
      </tr><%
    end if
    rs.movenext
  loop%>
  <tr>
    <td style="text-align:center"><div style="width:100%;text-align:center;">
      <p>&nbsp;</p>
      <p><%
      if(IsNULL(USR_Firma) or USR_Firma="") then%>
        <img width="230px" height="120px" src="data:image/jpeg;base64,/9j/4AAQSkZJRgABAgAAZABkAAD/7AARRHVja3kAAQAEAAAAHgAA/+4ADkFkb2JlAGTAAAAAAf/bAIQAEAsLCwwLEAwMEBcPDQ8XGxQQEBQbHxcXFxcXHx4XGhoaGhceHiMlJyUjHi8vMzMvL0BAQEBAQEBAQEBAQEBAQAERDw8RExEVEhIVFBEUERQaFBYWFBomGhocGhomMCMeHh4eIzArLicnJy4rNTUwMDU1QEA/QEBAQEBAQEBAQEBA/8AAEQgAcwBxAwEiAAIRAQMRAf/EAIYAAQADAQEBAAAAAAAAAAAAAAACAwQFAQcBAQEBAAAAAAAAAAAAAAAAAAABAhAAAgEDAgMGAwYFBAMAAAAAAQIDABEEIRIxQRNRYSIyFAVxgSORocFCUmLRcjM0FfCSoiSxU1QRAQACAQMEAgMAAAAAAAAAAAABETFRYXEhQYESkdHwoQL/2gAMAwEAAhEDEQA/APoFK8r2g8r2lZsjOhgYRC8k7eWJNW+fZ86DTUWdEF3YKO0mwrEy50qtJPJ6aIC/TiG57d7WP3VTjQ+3zE7IWllCCRDOSd6twIJ3VL/JWmz/ACOB/wDTF/vX+NTTLxZP6c0bfBgfxrIZoF9vTLXHQs6hkiUDmNxF7DgAaufGwZIOqYY2jK7wbAAi1+NS52Khqr2uTjw48m30rTYUjp1ES/hKnmFJZTx+NXjKy8YA5KCeHlPCL6drJ/CrZTfSoRSxzIJImDo3Aip1UKUpQKUpQKUrJnZDoFgg/uZztT9o/M5+FJkRyMmWWY4mHbqD+tKdVjB5d7VThvHHkiGJdocFmllvvmKkq20/tPbXmRA+HCoRC+MgLSlSRIZDwkaw1APG34V5lZMMmMHkbcY2QxTQ8Xk1usfH5/GsctJRy5WPLK4BmxjK4dCRuQlmO5b6bbcbn4Vixp0xn/6zGR7lSiAyq0dyUB1XawBtobVsg9vkyfqZ3hRjuGMmi685CNWJropHFEm2NQijkBYUqZ2Lhx4Vy0WNTiPMkSkIr7APEb7ra614ZcqPAbDaCWNSCvU2iTah4r4LV02zIwSBqAL6ak/Cro5VkUMKvrul7OT6vq3yoypeBDHBAlyVL2u77gDYWHKrICuFjs6ur7BsTY2/ryPZgxXkSf8AVq2ZOBjZWsi2kHlkXRgfiK5zpPh5MRyGDKpIhyCPBduUqjgf3CpNx9r0lrONMlsvHToznWaC90ft4c++tGLlR5UW9LqQdrofMjDiDTJnEGPvkkCMRYMFvdj+lL3PwrCZJFHr0jMc0dlzIO1SAd1hfUA3+6rhMurSooyuodTdWFwe41KtIUpSg8rlo5mM2V1BE85OPiuReyrxIHaTc1s9wlMOFM6+bbZf5m8I+81SIpIFgGMFkeBNjwlgpKvt1B5G61mcrDLDFkY0zxMfTI43sYgGjIQDc25ySp+VWYaRtf3Ge0cMYIxozoscY/N8WqGXJNkKkRAj9ZIqbVbf9NbliSulz3V11UKoVRYAWA7hUiOvCzLhY/uJhbIbRHmjM6byCrSLckDa3Ai1vhR83JlnRFeJxKdistwCSm4gePip0/hW73CKNmHMsNrrqNPiutGyjj4xks3SiAVQviJsO1zVqdUuNHEaV5LNdVKsjsbH6Z3W8dzy+VaEzZrxjQtKbOOBa7FQ6ksONuyrpfcUmcfSkMgGqjaCRa9+PZXsecs8ildypHZlBAC7bbu08anlfCpfcnjm6oaPqyRRhjY2j8TXEmtyV4HhXVxpRmYijJVd0u4FfysASNy35G16qyZnmQMovE1iAdDfvqrKyrtGV0KWJPeK1Eb2kyjEvo8lonj680Kk4hJ8TRE6rc80qcGTly5Y3qdm9o2RFJiC28TGQ8WDC1W+6KelFmJ58d1a/wCxtGH31X6t8NY4olSYPuMUS3D8bhT5uTcTas4nZcrsC8Ek2EfLGd8N/wD1vy+RrdWGbcmXiZDLsZ7xSLe9tw3DX4it1ajTRJKUpVRi90G7HRf1Sxj/AJA1VlowkkkM8CojLKUlXcVICqCSGFte6rfddMXeOMckbfYwqrOXGjkWbIm2RluqItt9zxiwOmthpp21me/hqFUPizcUMVZgs0l08t3YnT7a05PumNEzRCQCRTZr30tWSF1GdjN41duojrIoVruepwFx+bStPusIdIgAV3TRhmUlTZmCny25GpGJJyyL7lhSs0e/aw0ZyDoe6w1pmZmD6ZoYZSS4K3IJGvPlUIcYo0zjcIleVAwmcNpuVRtJA++9OjI2HHJJ1A8ioEKs8xO4XZwDqDbXSlyVDHHLgLZZSdw03gsLm1uPEVck+FHIdGjRrI1tzEW0HHSnpnkjhkcsWaQQuLshG297jTja9TEKR+pWSVyI0UqdzE+XQ8dNaeIPloGZidNoUJIB3ISDqOYrLLlwjXxDX9JsftFeToUyz0ncRBo9Wdm2ki5BVj+bvqWS0gmUMW6asE4Ex+MXJ3W23vYVblKdJZ48z2yQAkkRHdcEa2vWTHyXgjSUdFWMUQZpCQxDEoOHLSt+WRB7dKRoFiIH2WFYEnxcZYPUGKbZHtKkL1I7ABrX433cKk5WML55JJsVJZChZMmPaY9VIDquhPzrqVz8wxNBipDYJJNHsAFhtB3cPlXQrUZSSlKVUU5cPXxZYhxZSB8eX31ia2XiRZJlECFDHMxAPhawK+LhqK6dYIbY+XJiuPpT3khv5bnzr+NSVhjy4ulEMmJZndHVlllI1K3t4TqL3twFWf8AYyOnkRzI5tuiBiDMobjZjUssSRq82S4mliVpIccDbGAhsHYcz/oVXizP7fkPDPY4kjfTmAKorONxUXJsPnWe69kGwZIzr0Va17enj1BGtSXHyQFIZVEOqWiTwbtTttwv3V1yiPZiAew150Y91/8Ajy+yr6wly4vpwT1DIu4tfd6dCSx1586sONNNIrNJukQ2VjCl1trp2V12iRrXHAgi3dRoo2Fttu8aGr6wXLjPiOXkvIGZh9U9JLn+bQ3qS+2s0IDNtibxbeklr9pCiuqMeIAjaDfiTxNQzMuHEh3ya30RBxY9gFT1/kuXOyReNMVsnerOrOWAQJEtyT2WuAKvxZhj7Vki3GRrLkxBXVyx5lANvHn9tVxYmUts6SMS5DsGeA28MdiAqbtLre9aIFixvUZXTMELBWKNYeJb7m2i9r6VIzePpSX63ukMY8uOjSt/M3gUf+a3Vj9ujk2PkzC0uS28j9K8EX7K2VqNdUkpSlVCs+Zjeoisp2Sod0T/AKWHCtFKDDE0OchiyU2zx3WWO5B146qRdWrW8UckZidQ0ZFipGlqoysQyss0LdLJTyPyI/Sw5iow54LiDJXoZFvKfK3ejc6nK8Kenm+3m0AOTi8or/UQftJ4iroPc8OY7eoI5Bxjk8DD5NWuqp8TGyP60Sv3ka/bSpjBeqwOp4EH4GoyTwxC8jqg7yBWM+ze3i5CFBx0YgVViQezTSskKrI6Gx3Etfv1qXO3yVG62T3VZD08GNsmT9QBEY+LGpY2A5lGVmt1cj8oHkj7lH41sREQbUUKByAtUZZooUMkrhEHEmrXeS9E6wFv8jOEX+zha7tylcflHcKN1/cfCoaDD5tweUdg7BW6ONIkWONQqKLKo4AUzwYe17SlVClKUClKUCq5oIchDHMgdTyP4VZSgw+lzMf+0mDpyinubfBxrXozcqPSfEfTi0REg+7WttKlaStsP+UxyCHjlUHSxjb+FZMQ4eLK0mLBPI734RkDjfna1dmlSp1/RbD1Pc5v6cS46n80p3N/tXT76nH7fHvEuQxyJRqGfgv8q8BWulWtepbyvaUqoUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSg//Z" ></p><%
      else%>
        <img width="230px" height="120px" src="<%=USR_Firma%>" ></p><%
      end if%>
      <p><span class="Estilo12"><%=jefe_directo%><br></span>
    	 <span class="Estilo12">JEFE <%=cargo_jefe_directo%><br></span>
         <span class="Estilo12"><%=rut_jefe_directo%><br></span>
      </p>
      </div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>