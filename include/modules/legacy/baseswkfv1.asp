<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<!-- #INCLUDE file="functions.inc" -->
<%
    Req_Cod = request("Req_Cod")    

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
        rs.movenext
    loop

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

    mes=month(date)
	anio=year(date)
	dia=day(date)
	diasemana=weekday(date)

    fecha_larga=dias(diasemana) & " " & cstr(dia) & " de " & meses(mes) & " de " + cstr(anio)    
%>
<style type="text/css">
<!--
.Estilo14 {font-family: Arial, Helvetica, sans-serif; font-size: 12; }
.Estilo12 {font-size: 12px}
.Estilo19 {font-size: 12px; font-weight: bold; text-align:left;}
-->
</style>
<table width="100%"  border="0">
    <tr class="Estilo12">
        <td colspan="2" style="text-align:center;">           
            <span class="Estilo14" style="text-align:center;"><img width="160" height="149" src="SUBTRAB_160.jpg"></span>
        </td>
    </tr>
    <tr>
        <td colspan="2" align="right" >&nbsp;</td>
    </tr>
    <tr>
        <td colspan="2" style="text-align:center;">
            <span class="Estilo13"><strong><br><br>
            BASES ADMINISTRATIVAS COMPRA DE BIENES O<br>
            ADQUISICI&Oacute;N DE SERVICIOS MENORES A 100 UTM</strong></span><br>            
        </td>
    </tr>
    <tr class="Estilo12">
        <td colspan="2"><span class="Estilo7"></span></td>
    </tr>
    <tr class="Estilo12">
        <td colspan="2"></td>
    </tr>
    <tr class="Estilo12">
        <td colspan="2" class="Estilo10">
            <p class="Estilo19">&nbsp;</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">La Subsecretaria del Trabajo, llama a personas naturales y jur&iacute;dicas del rubro, para proveer o prestar el bien o servicio que se establece en los requerimientos t&eacute;cnicos y seg&uacute;n las especificaciones que se se&ntilde;alar&aacute;n, a trav&eacute;s del Portal de Compras y Contrataciones del Estado, en adelante, indistintamente, &ldquo;<a href="http://www.mercadopublico.cl">www.mercadopublico.cl</a>&rdquo; o &ldquo;el portal&rdquo;</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>1. Generalidades</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>1.1 Aceptaci&oacute;n de las bases</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">La participaci&oacute;n en el proceso implica la aceptaci&oacute;n de los proponentes de todas y cada una de las disposiciones contenidas en la Ley N&deg;19.886, su Reglamento, as&iacute; como en las presentes Bases, sin necesidad de declaraci&oacute;n expresa.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>1.2. Interpretaci&oacute;n de las Bases.</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">La Subsecretaria se reserva el derecho de interpretar las diferentes materias relacionadas con las presentes Bases, conforme los criterios de ecuanimidad que estime convenientes, sin perjuicio de tener presente siempre la necesidad de m&aacute;xima eficacia, eficiencia y ahorro en la contrataci&oacute;n materia de este proceso concursal, sin que ello implique que necesariamente se adjudicar&aacute; a la oferta que resulte de menor costo.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>2. Requisitos de Participaci&oacute;n</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>2.1.</strong> Podr&aacute;n participar en el proceso todas las personas naturales yjur&iacute;dicas que sean proveedores de los productos o servicios que se propone licitar en este procedimiento, y que cumplan con los dem&aacute;s requisitos requeridos por las presentesbases administrativas.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo16"><span class="Estilo20"><strong>2.2</strong> Para participar en el proceso, los oferentes INSCRITOS en el Registro Chileproveedores, deber&aacute;n adjuntar en formato electr&oacute;nico (escaneada), como archivo adjunto al Portal, la Declaraci&oacute;n jurada firmada contenida en el ANEXO N&deg;1 si es persona natural, o la contenida en el ANEXO N&deg;2, si es persona jur&iacute;dica.</span></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>2.3. </strong>Para participar en el proceso, los oferentes NO INSCRITOS en el Registro Chileproveedores, deber&aacute;n adjuntar en formato electr&oacute;nico, como archivo adjunto al Portal, los siguientes documentos:</p>
            <div style="text-align:justify;" class="Estilo16">
                <ul class="Estilo10">
                    <li class="Estilo20">Declaraci&oacute;n jurada contenida en el ANEXO N&deg;1 si es persona natural, o la contenida en el ANEXO N&deg;2, si es persona jur&iacute;dica.</li>
                    <li class="Estilo20">Certificado de deuda Tesorer&iacute;a General de la Rep&uacute;blica.</li>
                    <li class="Estilo20">Certificado de Antecedentes Laborales y Previsionales de cobertura nacional, extendido por la Inspecci&oacute;n del Trabajo competente, vigente al momento del acto de apertura.</li>
                    <li class="Estilo20">En el caso de personas jur&iacute;dicas, escritura de constituci&oacute;n y sus modificaciones posteriores, si las hubiere, con constancia de su inscripci&oacute;n en el Registro de Comercio y publicaci&oacute;n en el Diario Oficial. Certificado de vigencia de la sociedad, emitido por el respectivo Conservador de Bienes Ra&iacute;ces, de una antig&uuml;edad no superior a 90 d&iacute;as corridos contados desde la fecha de apertura de la licitaci&oacute;n. C&eacute;dula nacional de identidad del representante legal del oferente y del RUT de la persona jur&iacute;dica, as&iacute; como la escritura que acredite la personer&iacute;a del se&ntilde;alado representante.</li>
                    <li class="Estilo20">En caso de personas naturales, c&eacute;dula de identidad del oferente, Iniciaci&oacute;n de actividades y comprobante de pago de patente comercial.</li>
                </ul>
            </div>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>3. Consultas, Respuestas y Aclaraciones</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;</strong>Las consultas se recibir&aacute;n y ser&aacute;n respondidas s&oacute;lo a trav&eacute;s del foro del Portal, en las fechas y horas indicadas en la ficha de publicaci&oacute;n. Al responder, la Subsecretaria podr&aacute; tambi&eacute;n publicar aclaraciones y/o antecedentes complementarios.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>4. De las Ofertas</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;</strong>Las ofertas deber&aacute;n presentarse s&oacute;lo a trav&eacute;s del portal <a href="http://www.mercadopublico.cl">www.mercadopublico.cl</a>, hasta la hora y fecha indicada en la ficha depublicaci&oacute;n. No se recibir&aacute;n ofertas por otros medios.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">La validez m&iacute;nima de las ofertas ser&aacute; de 30 d&iacute;as corridos.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;4.1 Contenido de las ofertas</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Ser&aacute; responsabilidad de los oferentes proporcionar informaci&oacute;n que permita al servicio efectuar la evaluaci&oacute;n de sus ofertas.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Oferta T&eacute;cnica: Deber&aacute; cumplir todos los requerimientos establecidos en las bases t&eacute;cnicas.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Oferta Econ&oacute;mica: Deber&aacute; presentarse de acuerdo a los formatos de cada l&iacute;nea de adquisici&oacute;n, en el Portal. Los valores ingresados al Portal deber&aacute;n expresarse en moneda nacional y en NETO, es decir, que no deben contener ning&uacute;n tipo de impuesto, pues el portal agrega el impuesto en forma autom&aacute;tica. </p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Para aquellos proponentes que sean contribuyentes de <strong>2&ordm;categor&iacute;a con boletas de honorarios</strong> por servicios profesionales, deber&aacute;n presentar en <a href="http://www.mercadopublico.cl">www.mercadopublico.cl</a>el valor bruto total, pues la Subsecretaria proceder&aacute; a efectuar la retenci&oacute;n del 10% (de acuerdo al art&iacute;culo 74, n&uacute;mero 2 de la Ley de Renta).</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;4.2 Apertura de las Ofertas</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;</strong>La apertura de las ofertas se realizar&aacute; el d&iacute;a y hora indicada en la ficha de publicaci&oacute;n.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;4.3 Evaluaci&oacute;n de las Ofertas </strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo16"><span class="Estilo20"><strong>&nbsp;</strong>De acuerdo a la tabla de factores y las correspondientes ponderaciones que se publicar&aacute;n en el portal de compras <a href="http://www.mercadopublico.cl">www.mercadopublico.cl</a> .</span></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;</strong>La Subsecretaria del Trabajo se reserva el derecho de rechazar todas o alguna de las ofertas si &eacute;stas no resultan convenientes a los intereses institucionales o exceden los marcos presupuestarios disponibles, sin incurrir en responsabilidad alguna por tratarse del ejercicio de potestades facultativas propias, as&iacute; reconocidas expresamente por los proponentes.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Las ofertas que no cumplan con los requisitos contenidos en las bases ser&aacute;n declaradas inadmisibles.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">En caso de no adjudicarse o no resolverse la inadmisibilidad de las ofertas o ladeserci&oacute;n del proceso en el plazo se&ntilde;alado en el cronograma establecido en el portal, la Subsecretaria fijar&aacute; un nuevo plazo de d&iacute;as h&aacute;biles para dictar el acto administrativo respectivo, el cual, se informar&aacute; a trav&eacute;s de www.mercadopublico.cl junto a las razones que justifiquen el incumplimiento del plazo original.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>4.4 Mecanismos de Resoluci&oacute;n de Empates:</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;</strong>En caso de igualdad en el puntaje final, se privilegiar&aacute; al oferente que ha obtenido el mayor puntaje en la evaluaci&oacute;n t&eacute;cnica. De mantenerse el empate, se escoger&aacute; al proponente cuya oferta resulte ser la m&aacute;s econ&oacute;mica.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">De mantenerse a&uacute;n el empate se preferir&aacute; aquella oferta presentada por el oferente que acredite tener una mayor antig&uuml;edad, de acuerdo al Certificado de iniciaci&oacute;n de actividades emitido por el Servicio de Impuestos Internos.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>4.5 Mecanismo de Soluci&oacute;n de Consultas Respecto de la Adjudicaci&oacute;n: </strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Los oferentes podr&aacute;n hacer consultas en relaci&oacute;n a la adjudicaci&oacute;n, en el plazo de tres d&iacute;as h&aacute;biles a contar de la fecha de la publicaci&oacute;n en el portal <a href="http://www.mercadopublico.cl">www.mercadopublico.cl</a> de la Resoluci&oacute;n adjudicatoria. Dichas consultas deber&aacute;n dirigirse al funcionario de contacto se&ntilde;alado en el portal.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Todas las respuestas ser&aacute;n evacuadas y puestas en conocimiento de todos los oferentes, a trav&eacute;s del sistema <a href="http://www.mercadopublico.cl">www.mercadopublico.cl</a>, en el plazo de 2 d&iacute;as h&aacute;biles, contados desde el vencimiento del plazo indicado en el p&aacute;rrafo anterior.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>4.6 Acreditaci&oacute;n del Cumplimiento de Remuneraciones o Cotizaciones de Seguridad Social:</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;</strong>Para la emisi&oacute;n de la orden de compra respectiva, el adjudicatario tendr&aacute; un plazo de 5d&iacute;as h&aacute;biles contados desde la fecha de la publicaci&oacute;n de la adjudicaci&oacute;n en el portal <a href="http://www.mercadopublico.cl">www.mercadopublico.cl</a>, para entregar a la Subsecretaria una declaraci&oacute;n jurada, donde declare que se encuentra al d&iacute;a en el pago de las remuneraciones y cotizaciones de seguridad social, con sus actuales trabajadores o con trabajadores contratados en los &uacute;ltimos dos a&ntilde;os.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Dicha declaraci&oacute;n jurada deber&aacute; ser entregada en formato papel, en Calle Hu&eacute;rfanosN&deg; 1273, 4&deg; Piso, Comuna de Santiago, Unidad de Adquisiciones o, enviado escaneado al correo electr&oacute;nico del funcionario de contacto se&ntilde;alado en el portal <a href="http://www.mercadopublico.cl">www.mercadopublico.cl</a>.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>4.7 Presentaci&oacute;n de Antecedentes Omitidos por los Oferentes:</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;</strong>Los oferentes podr&aacute;n presentar los antecedentes requeridos para participar en los procesos de licitaci&oacute;n s&oacute;lo en el per&iacute;odo determinado para tal efecto, sin existir plazos extraordinarios o complementarios.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>5. Eventual contrataci&oacute;n escrita</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">La Subsecretaria podr&aacute; disponer la celebraci&oacute;n de un contrato escrito, previo a la emisi&oacute;n de la respectiva orden de compra. En este contrato se podr&aacute; disponer la constituci&oacute;n de una garant&iacute;a, mediante boleta bancaria nominativa e irrevocable a nombre de la Subsecretaria, por un monto m&aacute;ximo del 10% del valor neto del contrato, la cual le ser&aacute; devuelta al proveedor una vez que cumpla todas las obligaciones estipuladas.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>6. De la Orden de Compra</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;</strong>Una vez efectuada la evaluaci&oacute;n por parte de la Subsecretaria, se emitir&aacute; la orden de compra nominativa al o los oferente (s) seleccionado (s), a trav&eacute;s del portal. La orden contendr&aacute; los bienes o servicios adjudicados, la descripci&oacute;n t&eacute;cnica general y, en su caso, el lugar de entrega.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">La orden de compra DEBE ser aceptada a trav&eacute;s del portal por el oferente seleccionadoen un plazo m&aacute;ximo de 48 horas desde su emisi&oacute;n.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">La orden de compra NO puede ser cedida a terceros en forma alguna.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">La Subsecretaria se reserva el derecho de dejar sin efecto la orden de compra emitida, por incumplimientos del proveedor, especialmente de los plazos de entrega.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">En caso que el o los proveedores adjudicados no est&eacute;n inscritos en el Registro Electr&oacute;nico Oficial de Contratistas de la Administraci&oacute;n, Chileproveedores, estar&aacute;n obligados a inscribirse dentro del plazo de 15 d&iacute;as h&aacute;biles contados desde la emisi&oacute;n de la orden de compra respectiva.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>7. Recepci&oacute;n de bienes</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;</strong>En caso de que se trate de compra de bienes, el producto adquirido deber&aacute; ser despachado al lugar de destino que se se&ntilde;ale en la respectiva Orden de Compra. La unidad solicitante de la Subsecretaria revisar&aacute; los bienes y otorgar&aacute;, si correspondiere, el Visto Bueno o conformidad al proveedor.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>8. Condiciones de Ejecuci&oacute;n</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">La Subsecretar&iacute;a queda liberada de toda responsabilidad por da&ntilde;os a terceros que se produjeren con motivo del cumplimiento de la oferta, los que ser&aacute;n de &uacute;nica y exclusiva responsabilidad del proveedor correspondiente.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Los incumplimientos del proveedor, especialmente en cuanto a los plazos de entrega y a la calidad de los bienes o servicios suministrados o prestados, facultar&aacute;n a la Subsecretaria para efectuar descuentos de hasta el 10% del valor neto total de la orden de compra. </p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;8.2 Pago.</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;</strong>Una vez recibidos conforme todos los bienes en el lugar de destino indicado en la orden de compra, o, en su caso, aprobada la prestaci&oacute;n del servicio por escrito por la Subsecretaria, se proceder&aacute; a cursar el pago, contra presentaci&oacute;nde la boleta o factura correspondiente. (De preferencia electr&oacute;nica). En caso de que el documento no sea electr&oacute;nico, se deber&aacute; presentar en original en las dependencias de la Subsecretaria se&ntilde;aladas en el portal de compras. El pago se realizar&aacute; dentro de los treinta d&iacute;as siguientes a la aprobaci&oacute;n del documento correspondiente (boleta o factura).</p>
            <p style="text-align:justify;" class="Estilo10 Estilo16">&nbsp;</p>
        </td>
    </tr>
    <tr class="Estilo12">
        <td colspan="2" class="Estilo19 Estilo20">&nbsp;</td>
    </tr>
    <tr class="Estilo12">
        <td colspan="2" class="Estilo19 Estilo20">
            <p style="text-align:justify;"><strong>9. Especificaciones T&eacute;cnicas</strong></p>
        </td>
    </tr>
    <tr>
        <br>
  	    <td colspan="2" class="Estilo19 Estilo20">
            <table width="100%" border="0">
                <tr>
                    <td><% 
                        linea=split(espec,chr(13))
                        for each x in linea
                        response.write(x & "<br />")
                        next%>            
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
<br>
<br>
<table width="100%"  border="0">
    <tr class="Estilo12">
        <td colspan="2" class="Estilo19 Estilo20">&nbsp;</td>
    </tr>
    <tr class="Estilo12">
        <td colspan="2">
            <p style="text-align:justify;" class="Estilo19 Estilo20">2.- Con todo, las bases administrativas correspondientes a las licitacionesp&uacute;blicas por un monto menor a 100 UTM se ajustar&aacute;n al formatotipo aprobado por la presenteresoluci&oacute;n, debiendo establecerse en la convocatoria respectiva la procedencia de su aplicaci&oacute;n conforme a dicha modalidad</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">&nbsp;</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>ANEXO N&deg; 1:</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;</strong></p>
            <h1 style="text-align:justify;" class="Estilo19 Estilo20">FORMATO DE DECLARACI&Oacute;N JURADA SIMPLE PERSONAS NATURALES</h1>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Santiago, <%=fecha_larga%></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Se&ntilde;or</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Subsecretario del Trabajo</p>
            <h2 style="text-align:justify;" class="Estilo19 Estilo20">Presente</h2>
            <div style="text-align:justify;" class="Estilo20">
                <table border="1" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="299" valign="top" class="Estilo10"><p>NOMBRES</p></td>
                        <td width="299" valign="top" class="Estilo10"><p>APELLIDOS</p></td>
                    </tr>
                    <tr>
                        <td width="299" valign="top" class="Estilo10"><p>&nbsp;</p></td>
                        <td width="299" valign="top" class="Estilo10"><p>&nbsp;</p></td>
                    </tr>
                </table>
            </div>
            <span class="Estilo20"><br><br></span>
            <div style="text-align:justify;" class="Estilo20">
                <table border="1" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="199" valign="top" class="Estilo10"><p>C&Eacute;DULA DE IDENTIDAD</p></td>
                        <td width="200" valign="top" class="Estilo10"><p>ESTADO CIVIL</p></td>
                        <td width="196" valign="top" class="Estilo10"><p>PROFESI&Oacute;N U OFICIO</p></td>
                    </tr>
                    <tr>
                        <td width="199" valign="top" class="Estilo10"><p>&nbsp;</p></td>
                        <td width="200" valign="top" class="Estilo10"><p>&nbsp;</p></td>
                        <td width="196" valign="top" class="Estilo10"><p>&nbsp;</p></td>
                    </tr>
                </table>
            </div>
            <span class="Estilo20"><br><br></span>
            <div style="text-align:justify;" class="Estilo20">
                <table border="1" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="599" valign="top" class="Estilo10"><p>DOMICILIO</p></td>
                    </tr>
                    <tr>
                        <td width="599" valign="top" class="Estilo10"><p>&nbsp;</p></td>
                    </tr>
                </table>
            </div>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Para los efectos de lo dispuesto en el art&iacute;culo 4&ordm; de la Ley N&deg; 19.886, declaro bajo juramento que no soy funcionario directivo del Ministerio del Trabajo y Previsi&oacute;n Social y sus servicios dependientes, ni tengo respecto de alguno de dichos directivos la calidad de c&oacute;nyuge, hijo, adoptado, o pariente hasta el tercer grado de consanguinidad y segundo de afinidad, inclusive.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Declaro asimismo bajo juramento que no tengo la calidad de gerente, administrador, representante o director de una sociedad de personas de la que formen parte funcionarios directivos del Ministerio del Trabajo y Previsi&oacute;n Social y de los servicios que por su intermedio se relaciones con el Gobierno, o personas que tengan la calidad de c&oacute;nyuge, hijo, adoptado, o pariente hasta el tercer grado de consanguinidad y segundo de afinidad, inclusive, respecto de un funcionario directivo del Ministerio delTrabajo y Previsi&oacute;n Social y servicios relacionados; ni de una sociedad comandita por acciones o an&oacute;nima cerrada en que sean accionistas funcionarios directivos del Ministerio del Trabajo y Previsi&oacute;n Social y sus servicios relacionados, o personas que tengan la calidad de c&oacute;nyuge, hijo, adoptado, o pariente hasta el tercer grado de consanguinidad y segundo de afinidad, inclusive, respecto de uno de dichos directivos; ni de una sociedad an&oacute;nima abierta en que un funcionario directivo del citado Ministerio y sus servicios relacionados, o personas que tengan la calidad de c&oacute;nyuge, hijo, adoptado, o pariente hasta el tercer grado de consanguinidad y segundo de afinidad, inclusive, sea due&ntilde;o de acciones que representen el 10% o m&aacute;s del capital.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Finalmente, declaro tambi&eacute;n bajo juramento que no he sido condenado por pr&aacute;cticas antisindicales o infracci&oacute;n a los derechos fundamentales del trabajador, dentro de los 2 a&ntilde;os anteriores.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">&nbsp;</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>FIRMA, RUT Y NOMBRE</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;</strong></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">&nbsp;</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>ANEXO N&deg; 2</strong></p>
            <h1 style="text-align:justify;" class="Estilo19 Estilo20">FORMATO DECLARACI&Oacute;N JURADA SIMPLE PERSONAS JUR&Iacute;DICAS</h1>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Santiago, <%=fecha_larga%></p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Se&ntilde;or</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Subsecretario del Trabajo</p>
            <h2 style="text-align:justify;" class="Estilo19 Estilo20">Presente</h2>
            <div style="text-align:justify;" class="Estilo20">
                <table border="1" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="299" valign="top" class="Estilo10"><p>NOMBRE(S) REPRESENTANTE(S)</p></td>
                        <td width="299" valign="top" class="Estilo10"><p>APELLIDO(S)</p></td>
                    </tr>
                    <tr>
                        <td width="299" valign="top" class="Estilo10"><p>&nbsp;</p></td>
                        <td width="299" valign="top" class="Estilo10"><p>&nbsp;</p></td>
                    </tr>
                </table>
            </div>
            <span class="Estilo20"><br><br></span>
            <div style="text-align:justify;" class="Estilo20">
                <table border="1" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="199" valign="top" class="Estilo10"><p>C&Eacute;DULA DE IDENTIDAD</p></td>
                        <td width="200" valign="top" class="Estilo10"><p>ESTADO CIVIL</p></td>
                        <td width="200" valign="top" class="Estilo10"><p>PROFESI&Oacute;N U OFICIO</p></td>
                    </tr>
                    <tr>
                        <td width="199" valign="top" class="Estilo10"><p>&nbsp;</p></td>
                        <td width="200" valign="top" class="Estilo10"><p>&nbsp;</p></td>
                        <td width="200" valign="top" class="Estilo10"><p>&nbsp;</p></td>
                    </tr>
                </table>
            </div>
            <span class="Estilo20"><br><br></span>
            <div style="text-align:justify;" class="Estilo20">
                <table border="1" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="602" valign="top" class="Estilo10"><p>DOMICILIO</p></td>
                    </tr>
                    <tr>
                        <td width="602" valign="top" class="Estilo10"><p>&nbsp;</p></td>
                    </tr>
                </table>
            </div>
            <p style="text-align:justify;" class="Estilo19 Estilo20">En representaci&oacute;n de la empresa:</p>
            <div style="text-align:justify;" class="Estilo20">
                <table border="1" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="299" valign="top" class="Estilo10"><p>RAZ&Oacute;N SOCIAL</p></td>
                        <td width="299" valign="top" class="Estilo10"><p>RUT</p></td>
                    </tr>
                    <tr>
                        <td width="299" valign="top" class="Estilo10"><p>&nbsp;</p></td>
                        <td width="299" valign="top" class="Estilo10"><p>&nbsp;</p></td>
                    </tr>
                </table>
            </div>
            <p style="text-align:justify;" class="Estilo19 Estilo20">Declaro bajo juramento que la empresa de mi representaci&oacute;nno se encuentra en ninguna de las prohibiciones previstas en el art&iacute;culo 4&deg; de la Ley N&deg; 19.886, esto es:</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">a) Haber sido condenada por pr&aacute;cticas antisindicales o infracci&oacute;n a los derechos fundamentales del trabajador, dentro de los 2 a&ntilde;os anteriores;</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">b) Tratarse de una sociedad de personas de la que formen parte funcionarios directivos del Ministerio del Trabajo y Previsi&oacute;n Social y sus servicios relacionados, o personas que tengan la calidad de c&oacute;nyuge, hijo, adoptado, o pariente hasta el tercer grado de consanguinidad y segundo de afinidad, inclusive, respecto de un funcionario directivo de dicho Ministerio y sus servicios relacionados;</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">c) Tratarse de una sociedad comandita por acciones o an&oacute;nima cerrada en que sean accionistas funcionarios directivos del Ministerio del trabajo y Previsi&oacute;n Social y sus servicios relacionados, o personas que tengan la calidad de c&oacute;nyuge, hijo, adoptado, o pariente hasta el tercer grado de consanguinidad y segundo de afinidad, inclusive, respecto de uno de dichos directivos, y</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20">d) Tratarse de una sociedad an&oacute;nima abierta en que un funcionario directivo del Ministerio del Trabajo y Previsi&oacute;n Social y sus servicios relacionados, o personas que tengan la calidad de c&oacute;nyuge, hijo, adoptado, o pariente hasta el tercer grado de consanguinidad y segundo de afinidad, inclusive, respecto de uno de dichos directivos, sea due&ntilde;o de acciones que representen el 10% o m&aacute;s del capital, ni con los gerentes, administradores, representantes o directores de cualquiera de las sociedades mencionadas.</p>
            <p style="text-align:justify;" class="Estilo19 Estilo20"><strong>&nbsp;</strong></p>
            <p style="text-align:center;" class="Estilo19 Estilo20"><strong>&nbsp;</strong></p>
            <p style="text-align:center;" class="Estilo19 Estilo20"><strong>FIRMA REPRESENTANTE LEGAL</strong></p>
            <p class="Estilo16">&nbsp;</p></td>
        </td>
    </tr>
    <tr class="Estilo12">
        <td colspan="2">
            <div style="text-align:center;" class="Estilo10 Estilo15">
                <p class="Estilo16"><br>
                    <strong>MARIA PAULA GOMEZ BINFA</strong><br>
                    JEFA DE DIVISI&Oacute;N ADMINISTRACI&Oacute;N Y FINANZAS<br>
                </p>
                <p class="Estilo16">&nbsp;       </p>
            </div>
        </td>
    </tr>    
</table>