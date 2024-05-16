<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%
  'splitruta=split(ruta,"/")    
  'xm=splitruta(5)
  'DRE_Id=splitruta(7)
  Req_Cod = request("Req_Cod")
      
  INF_Id=request("INF_Id")
  if(INF_Id="") then        
      response.Write("404/@/Error 1 No fue posible encontrar el informe a generar")
      response.End()
  end if

  if(Req_Cod="" or Req_Cod=0) then        
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

    
  sql="exec [spDatosRequerimientoWorkFlowv1_Listar] " & Req_Cod
  set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("503/@/Error 4: [spDatosRequerimientoWorkFlowv1_Listar]")
		cnn.close 		
		response.end
	End If
    
    do while not rs.eof 
        ReqFchCre=rs("Req_FchCre")
        nomjefe=rs("NombreCreador")
        nomjefe5=rs("NombreJefeDaf")
        dep=rs("UnidadCreador")
        rjefe=rs("RutCreador")
		if rs("Frm_Cor")=1 then
			espec=trim(rs("FrD_Data"))
		end if			
		if CInt(rs("Frm_Cor"))=2 then
			justific=trim(rs("Frd_Data"))
		end if
		if CInt(rs("Frm_Cor"))=3 then
			proyecto=trim(rs("Frd_Data"))
		end if
		if CInt(rs("Frm_Cor"))=6 then
			cantidad=trim(rs("Frd_Data"))
		end if		
		rs.movenext
	loop
         
	id=Req_Cod 'Solo el numero del requerimiento
	jefe_directo=ucase(nomjefe) 'Desde Tabla Core.Usuarios
	
	espectec=espec
	justific=justific
	cargo_jefe_directo=ucase(dep)
  rut_jefe_directo=ucase(rjefe)	
	fecha_ingreso=ReqFchCre
	
	mes=month(ReqFchCre)
	anio=year(ReqFchCre)
	dia=day(ReqFchCre)
	diasemana=weekday(ReqFchCre)

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
    <td width="23%"><span class="Estilo14"><img width="134" height="124" src="SUBTRAB_160.jpg"></span></td>
    <td width="77%"><span class="Estilo19">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SUBSECRETARIA DEL TRABAJO <BR>
DIVISION ADMINISTRACION Y FINANZAS<BR><BR>
    </span><span class="Estilo12">Santiago, <%=fecha_larga%></span></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><span class="Estilo11 Estilo7 Estilo12"><strong>N&deg;</strong> <%=id%></span></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td style="text-align:left;"><span class="Estilo19">DE</span></td>
    <td style="text-align:left;">: <span class="Estilo19"><%=jefe_directo%></span></td>
  </tr>
  <tr>
    <td style="text-align:left;"><span class="Estilo19">A</span></td>
    <td style="text-align:left;"><span class="Estilo12">:<strong> SR.(SRA.) <%=ucase(nomjefe5)%><BR>
&nbsp;&nbsp;JEFE DE <%=ucase(dep5)%><BR>
&nbsp;&nbsp;SUBSECRETARIA DEL TRABAJO</strong> </span></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr bordercolor="#1A50B8">
    <td colspan="2" style="text-align:left;"> 	
	  <%=cantidad%> &nbsp;
		<%linea=split(espectec,chr(13))
	  	for each x in linea
	    	response.write(x & "<br />")
		next
	   %>            
	</td>		
  </tr>
   <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  
  
  <tr>
    <td colspan="2" style="text-align:left;">Especficiaciones Técnicas:</td>
  </tr>  
  <tr>
    <td colspan="2" style="text-align:left;">	  
	<% 
		linea=split(proyecto,chr(13))
	  	for each x in linea
	    	response.write(x & "<br />")
		next
	   %></td>
  </tr>
  
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>  
  
 <tr>
    <td colspan="2" style="text-align:left;">Justificación:</td>
  </tr>  
  <tr>
    <td colspan="2" style="text-align:left;">	  
	<% 
		linea=split(justific,chr(13))
	  	for each x in linea
	    	response.write(x & "<br />")
		next
	   %></td>
  </tr>
  <tr></tr>
  <tr></tr>
  <tr></tr>
  <tr>
    <td colspan="2"><div align="center">
      <p>&nbsp;</p>
      <p><img src="TIMBRE.jpg" width="113" height="115"></p>
      <p><span class="Estilo12"><%=jefe_directo%><br></span>
    	 <span class="Estilo12"><%=cargo_jefe_directo%><br></span>
         <span class="Estilo12"><%=rut_jefe_directo%><br></span>
      </p>
      </div></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
</table>