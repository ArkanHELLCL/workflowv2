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
        VFL_Id=rs("VFL_Id")
        REQ_Descripcion=rs("REQ_Descripcion")
        REQ_Id=rs("REQ_Id")
        DEP_DescripcionOrigen = rs("DepDescripcionOrigen")
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
        INF_Descripcion=ucase(rs("INF_Descripcion"))
        FLD_Id=rs("FLD_Id")
        FLD_IdAprobacion=rs("FLD_IdAprobacion")
        if(IsNULL(FLD_IdAprobacion)) then
            FLD_IdAprobacion=FLD_Id
        end if
        ESR_IdInforme = rs("ESR_IdInforme")
        if(IsNULL(ESR_IdInforme)) then
            ESR_IdInforme=2
        end if
    else
        response.Write("404/@/Error 7 No fue posible encontrar el id del flujo del informe " & INF_Id)
        response.End()
    end if
              
  'Buscar el formulario visado para este requerimiento para obtener la fecha de creacion relacionado con el FLD_Id de la tabla informes
    'gsql="exec spIDVersionFormulario_Mostrar   " & VRE_Id & "," & FLD_Id
    gsql="exec spIDVersionFormulario_Mostrar   " & VRE_Id & "," & FLD_IdAprobacion & "," & ESR_IdInforme
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
        gsql="exec spIDVersionFormulario_Mostrar   " & VRE_Id & "," & FLD_Id & "," & ESR_IdInforme
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
    else
        response.Write("404/@/Error 10 No fue posible encontrar departamento del creador " & INF_Id)
        response.End()
    end if      

    'Buscando jefe/a Departamento de Finanzas (9)
    DEP_IdFIN=9
    rsql="exec spJefeDepartamento_Mostrar " & DEP_IdFIn & "," & session("wk2_usrid") & ",'" & session("wk2_usrtoken") & "'"
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
        USR_UsuarioFIN = rs("USR_Usuario")     'Jefe del departamento creador
        USR_NombreFIN = rs("USR_Nombre")
        USR_ApellidoFIN = rs("USR_Apellido")
        USR_RutFIN = rs("USR_Rut")
        USR_DvFIN = rs("USR_Dv")
        USR_IdFIN = rs("USR_Id")
        USR_FirmaFIN = rs("USR_Firma")
        
        DEP_DescripcionFIN=rs("DEP_Descripcion")
    else
        response.Write("404/@/Error 17 No fue posible encontrar el usuario DAF 9 " & rsql)
        response.End()
    end if    
    
    'Obteniendo la ultima version del certificado grabada
    tsql="exec [spInformesCertificadosxVersion_Listar] " & REQ_Id & "," & VFL_Id & "," & FLD_Id & ",1"
    set rs = cnn.Execute(tsql)		
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description			
        cnn.close 			   
        response.Write("503/@/Error Conexión 19:" & ErrMsg)
        response.End()		
    end if
    if not rs.eof then
        VCE_Id=rs("VCE_Id")
        VCE_Glosa=rs("VCE_Glosa")
    else
        response.Write("404/@/Error 20 No fue posible encontrar el ultimo CDP " & FLD_Id)
        response.End()
    end if

    'Datos del CDP            
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
<%
    'Desplegando todos (-1) los datos de al ultima version del formulario grabada
    fsql="exec spDatosFormularioxVersion_Consultar " & DRE_Id & ",-1"
	set rs = cnn.Execute(fsql)		
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 21:" & ErrMsg)
		response.End()		
	end if
    do while not rs.eof
        if(lcase(rs("FDI_NombreHTML"))="comprogramapresupuestario") then%>
            <tr>            
                <td style="text-align:left;font-size:12px" width="30%"><span class="Estilo19"><strong><%=rs("FDI_Descripcion")%></strong></span></td><%
                if(trim(rs("FDI_TipoCampo"))="L") then
                    'Buscando la descripcion de la lista
                    VFO_Id=rt("VFO_Id")
                    ql="exec spItemListaDesplegable_Consultar " & CInt(rs("DFO_Dato"))
                    set rt = cnn.Execute(ql)
                    on error resume next
                    if not rt.eof then%>
                        <td style="text-align:left;"><strong>: <span class="Estilo19"><%=trim(rt("ILD_Descripcion"))%></span></strong></td><%    
                    end if
                else%>
                    <td style="text-align:left;"><strong>: <span class="Estilo19"><%=trim(rs("DFO_Dato"))%></span></strong></td><%
                end if%>
            </tr><%
            exit do
        end if
        rs.movenext
    loop%>
    <tr>
        <td style="text-align:left;font-size:12px" width="30%"><span class="Estilo19"><strong>Proyecto Específico</strong></span></td>
        <td style="text-align:left;" width="70%"><strong>: <span class="Estilo19"><%=REQ_Descripcion%></span></strong></td>
    </tr>
    <tr>
        <td style="text-align:left;font-size:12px" width="30%"><span class="Estilo19"><strong>Unidad Solicitante</strong></span></td>
        <td style="text-align:left;" width="70%"><strong>: <span class="Estilo19"><%=DEP_DescripcionOrigen%></span></strong></td>
    </tr>
</table>
<br>
<br>
<br>
<br><%
'Desplegando todas las imputaciones de la ultimia version del certificado
fql="exec [spDetalleCertificado_Listar] 1," & VCE_Id
set rs = cnn.Execute(fql)		
on error resume next
if cnn.Errors.Count > 0 then 
    ErrMsg = cnn.Errors(0).description			
    cnn.close 			   
    response.Write("503/@/Error Conexión 22:" & ErrMsg)
    response.End()		
end if
do while not rs.eof
    ESR_DescripcionVersionCertificado=rs("ESR_DescripcionVersionCertificado")%>
    <table width="100%">
        <tbody>
            <tr>
                <td width="50%"><strong>Imputación:</strong></td>
                <td><strong><%=rs("ILD_Descripcion")%></strong></td>
            </tr>
        </tbody>
    </table>
    <table width="100%" border="1">
        <tbody>
            <tr>
                <td width="50%">Presupuesto Asignado:</td>
                <td>$ <%=FormatNumber(rs("DCE_Asignado"),0)%></td>
            </tr>
            <tr>
                <td width="50%">Presupuesto Comprometido:</td>
                <td>$ <%=FormatNumber(rs("DCE_Comprometido"),0)%></td>
            </tr>
            <tr>
                <td width="50%">Presente Documento:</td>
                <td>$ <%=FormatNumber(rs("DCE_Monto"),0)%></td>
            </tr>
            <tr>
                <td width="50%">Saldo Disponible</td>
                <td>$ <% 
                    Saldo = rs("DCE_Asignado") - (rs("DCE_Comprometido") + rs("DCE_Monto"))
                    response.write(FormatNumber(Saldo,0))
                %></td>
            </tr>
        </tbody>
    </table>
    <br>
    <br><%
    rs.movenext
loop%>
<br>

<table width="100%"  border="0" align="left">
    <tbody>
        <tr>
            <td style="text-align:left">
                Nota : <%=VCE_Glosa%>
            </td>
        </tr>
        <tr>
            <td style="text-align:right">
                Estado : <%=ESR_DescripcionVersionCertificado%>
            </td>
        </tr>
    </tbody>
</table>


<table width="100%"  border="0" align="center">
  <tr>
    <td style="text-align:center"><div style="width:100%;text-align:center;">
      <p>&nbsp;</p>
      <p><img src="<%=USR_FirmaFIN%>"></p>
      <p><span class="Estilo12"><%=ucase(USR_NombreFIN & " " & USR_ApellidoFIN)%><br></span>
    	 <span class="Estilo12">JEFE(A) <%=ucase(DEP_DEscripcionFIN)%><br></span>
         <span class="Estilo12"><%=USR_RutFin & "-" & USR_DvFIN%><br></span>
      </p>
      </div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>