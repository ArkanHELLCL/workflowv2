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

    
    sql="exec [spCertificadosWorkFlowv1_Generar] " & Req_Cod
    set rs = cnn.Execute(sql)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("503/@/Error 4: spCertificadosWorkFlowv1_Generar")
		cnn.close 		
		response.end
	End If
    rs.movefirst
    if not rs.eof then        
        CDisCod=rs("CDis_Cod")        
        PrgPre=LimpiarUrl(trim(rs("FrD_Data")))

    end if    
    rs.movenext
    if not rs.eof then                
        PryEsp=LimpiarUrl(trim(rs("FrD_Data")))
        Uni_Des=rs("Uni_Des")
        CDisFchCre=rs("CDis_FchCre")
        CDisValImp=rs("CDis_ValImp")
		CDisPreAsi=rs("CDis_PreAsi")
		CDisPreCom=rs("CDis_PreCom")
		CDisPreDoc=rs("CDis_PreDoc")
		CDisSalDis=rs("CDis_SalDis")
		CDisEst=rs("CDis_Est")		
		CDisUsrVal=trim(ucase(rs("CDis_UsrVal")))
		CDisUsrApr=trim(ucase(rs("CDis_UsrApr")))
		if CDisEst=0 then
			Estado="En Tramite"
		else
			if CDisEst=1 then
				Estado="Aprobado"
			else
				Estado="Para Aprobacion"
			end if
		end if
    end if

    'Datos del CDP            
	mes=month(CDisFchCre)
	anio=year(CDisFchCre)
	dia=day(CDisFchCre)
    diasemana=weekday(CDisFchCre)

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
    <td width="77%" style="text-align:right">
        <span class="Estilo12">Santiago, <%=fecha_larga%></span>
    </td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr style="text-align:center">
    <td colspan="2"><span class="Estilo11 Estilo7 Estilo12"><strong>CERTIFICADO DE DISPONIBILIDAD PRESUPUESTARIA</strong></span></td>
  </tr>
  <tr style="text-align:center">    
    <td colspan="2"><span class="Estilo11 Estilo7 Estilo12"><strong>N&deg; <%=CDisCod%> / Req&deg; <%=Req_Cod%></strong></span></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>    
</table>
<br>
<br>
<table width="100%"  border="0" align="center">
    <tr>
        <td style="text-align:left;font-size:12px" width="30%"><span class="Estilo19"><strong>Programa Presupuestario</strong></span></td>
        <td style="text-align:left;"><strong>: <span class="Estilo19">P.<%=PrgPre%></span></strong></td>
    </tr>
    <tr>
        <td style="text-align:left;font-size:12px" width="30%"><span class="Estilo19"><strong>Proyecto Específico</strong></span></td>
        <td style="text-align:left;"><strong>: <span class="Estilo19"><%=PryEsp%></span></strong></td>
    </tr>
    <tr>
        <td style="text-align:left;font-size:12px" width="30%"><span class="Estilo19"><strong>Unidad Solicitante</strong></span></td>
        <td style="text-align:left;"><strong>: <span class="Estilo19"><%=Uni_Des%></span></strong></td>
    </tr>
</table>
<br>
<br>
<table width="100%">
    <tbody>
        <tr>
            <td width="50%"><strong>Imputación:</strong></td>
            <td><strong><%=CDisValImp%></strong></td>
        </tr>
    </tbody>
</table>
<table width="100%" border="1">
    <tbody>
        <tr>
            <td width="50%">Presupuesto Asignado:</td>
            <td>$ <%=FormatNumber(CDisPreAsi,0)%></td>
        </tr>
        <tr>
            <td width="50%">Presupuesto Comprometido:</td>
            <td>$ <%=FormatNumber(CDisPreCom,0)%></td>
        </tr>
        <tr>
            <td width="50%">Presente Documento:</td>
            <td>$ <%=FormatNumber(CDisPreDoc,0)%></td>
        </tr>
        <tr>
            <td width="50%">Saldo Disponible</td>
            <td>$ <%=FormatNumber(CDisSalDis,0)%></td>
        </tr>
    </tbody>
</table> 

<table width="100%"  border="0" align="left">
    <tbody>        
        <tr>
            <td style="text-align:right">
                Estado : <%=Estado%>
            </td>
        </tr>
    </tbody>
</table>
<br>
<table width="100%"  border="0" align="center">
    <tbody> 
        <tr>
            <td style="text-align:center">
                <div style="width:100%;text-align:center;">
                    <p>&nbsp;</p>
                    <p><img src="<%=CDisUsrVal%>.gif" height="200" width="250"></p>      
                </div>
            </td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
    </tbody>
</table>