<?php
//Library
require_once('../../appl/TCPDF-master/tcpdf.php');
//Connection
require_once('../template/dsn.php');

//Rescatabndo JSON POST
// Takes raw data from the request
$json = file_get_contents('php://input');

// Converts it into a PHP object
$data = json_decode($json);


if($data->INF_Id==0 || $data->INF_Id==''){
    $response = array('response' => 'error', 'data'=>'Error 1 No fue posible encontrar el informe a generar');
    echo json_encode($response);
    die;
}
if($data->DRE_Id==0 || $data->DRE_Id==''){
    $response = array('response' => 'error', 'data'=>'Error 2 No fue posible encontrar el registro del requerimiento actual');
    echo json_encode($response);
    die;
}

//Datos BD
$tsql_callSP = "spDatoRequerimiento_Consultar ?";
$params = array(   
		  array($data->DRE_Id, SQLSRV_PARAM_IN),		  
   );  

$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))  
{
    $REQ_Carpeta=$row['REQ_Carpeta'];    
    $REQ_Descripcion=$row['REQ_Descripcion'];
    $VFL_Id=$row['VFL_Id'];
    $FLD_Id=$row['FLD_Id'];
    $REQ_Id=$row['REQ_Id'];
    $VRE_Id=$row['VRE_Id'];
    $REQ_FechaEdit=$row['REQ_FechaEdit'];
    $DEP_DescripcionOrigen = $row['DepDescripcionOrigen'];
    $dir='d:/DocumentosSistema/WorkFlow/{'.$REQ_Carpeta.'}/informes/INF_Id-'.$data->INF_Id.'/';
    $VPV_FechaPago = 'WFP-'.$VRE_Id.'/'.date_format($REQ_FechaEdit,'d-m-Y');
}
sqlsrv_free_stmt( $stmt);



$tsql_callSP = "spInformesCertificadosxVersion_Listar ?, ?, -1, 1";
$params = array(   
		  array($REQ_Id, SQLSRV_PARAM_IN),
          array($VFL_Id, SQLSRV_PARAM_IN)
   );  

$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
$ok = false;
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))  
{
    if($row['INF_Estado']==1 and $row['Id']==$data->INF_Id){
	    $ok = true;
		$INF_NombreArchivo = $row['INF_NombreArchivo'];
		$INF_Descripcion  = $row['INF_Descripcion'];
		$VPV_Id = $row['VPV_Id'];		//Para cuando es certificado
		$NombreArchivo = trim(str_replace("/prt-","",$INF_NombreArchivo));
		
        $VPV_FechaEdit=$row['VPV_FechaEDit'];
		$FLD_Id=$row['FLD_Id'];
		$FLD_IdAprobacion=$row['FLD_IdAprobacion'];
        
        if(is_null($FLD_IdAprobacion)){
            $FLD_IdAprobacion = $FLD_Id;
        };
        if(is_null($VPV_Id) || $VPV_Id==""){
            $VPV_Id=0;
        };
        $ESR_IdInforme = $row['ESR_IdInforme'];
        if(is_null($ESR_IdInforme)){
            $ESR_IdInforme=2;
        };
        break;
    }
}
sqlsrv_free_stmt( $stmt);



if($VPV_Id!=0){
	//Providencia
    $tsql_callSP = "spIDVersionFormulario_Mostrar ?, ?, ?";
    $params = array(   
            array($VRE_Id, SQLSRV_PARAM_IN),
            array($FLD_IdAprobacion, SQLSRV_PARAM_IN),
            array($ESR_IdInforme, SQLSRV_PARAM_IN)
    ); 
	//Rescatar valor a partir del paso 5 del diseño del flujo (28)
	$dato=$FLD_IdAprobacion;
}else{	
    $response = array('response' => 'error', 'data'=>'Error 7 Aun no se crea la providencia. Imposible generar pdf');
    echo json_encode($response);
    die;    
};	

$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
if( $stmt === false ) {
    die( print_r( sqlsrv_errors(), true));
}
$row_count = sqlsrv_num_rows( $stmt );

if($row_count===false){      //No hay registros
    sqlsrv_free_stmt( $stmt);
    if($VPV_Id!=0){
        //Providencia
        $tsql_callSP = "spIDVersionFormulario_Mostrar ?, ?, ?";
        $params = array(   
                array($VRE_Id, SQLSRV_PARAM_IN),
                array($FLD_Id, SQLSRV_PARAM_IN),
                array($ESR_IdInforme, SQLSRV_PARAM_IN)
        ); 	
        $dato=$FLD_Id;
        $stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
        while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))  
        {
            //Creador
            $VFO_IdUSuarioEdit = $row['VFO_IdUSuarioEdit'];
            $VFO_FechaEdit = $row['VFO_FechaEdit'];
            $USR_IdEditor = $row['USR_IdEditor'];
            break;
        }
    }
}else{
    while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))  
    {
        //Creador
        $VFO_IdUSuarioEdit = $row['VFO_IdUSuarioEdit'];
        $VFO_FechaEdit = $row['VFO_FechaEdit'];
        $USR_IdEditor = $row['USR_IdEditor'];
        break;
    }
};
if(is_null($ESR_IdInforme)){
    $ESR_IdInforme=2;
};
sqlsrv_free_stmt( $stmt);

//Buscando jefe/a Departamento de SSGG (10)
$DEP_IdFIN = 10;
$tsql_callSP = "spJefeDepartamento_Mostrar ?, ?, ?";
$params = array(   
		  array($DEP_IdFIN, SQLSRV_PARAM_IN),
          array($data->wk2_usrid, SQLSRV_PARAM_IN),
          array($data->wk2_usrtoken, SQLSRV_PARAM_IN)
   );  

$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
$ok = false;
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))
{
    $ok=true;
    //Jefatura
    $USR_UsuarioSG = $row['USR_Usuario'];
    $USR_NombreSG = $row['USR_Nombre'];
    $USR_ApellidoSG = $row['USR_Apellido'];
    $USR_RutSG = $row['USR_Rut'];
    $USR_DvSG = $row['USR_DV'];
    $USR_IdSG = $row['USR_Id'];
    $USR_FirmaSG = $row['USR_Firma'];

    $DEP_DescripcionSG=$row['DEP_Descripcion'];
    break;
};

//Buscando jefe/a Departamento de Finanzas (9)
$DEP_IdFIN = 9;
$tsql_callSP = "spJefeDepartamento_Mostrar ?, ?, ?";
$params = array(   
		  array($DEP_IdFIN, SQLSRV_PARAM_IN),
          array($data->wk2_usrid, SQLSRV_PARAM_IN),
          array($data->wk2_usrtoken, SQLSRV_PARAM_IN)
   );  

$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
$ok = false;
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))
{
    $ok=true;
    //Jefatura
    $USR_UsuarioFIN = $row['USR_Usuario'];
    $USR_NombreFIN = $row['USR_Nombre'];
    $USR_ApellidoFIN = $row['USR_Apellido'];
    $USR_RutFIN = $row['USR_Rut'];
    $USR_DvFIN = $row['USR_DV'];
    $USR_IdFIN = $row['USR_Id'];
    $USR_FirmaFIN = $row['USR_Firma'];

    $DEP_DescripcionFIN=$row['DEP_Descripcion'];
    break;
};
sqlsrv_free_stmt( $stmt);

//Obteniendo la ultima version del certificado grabada
/*$tsql_callSP = "spInformesCertificadosxVersion_Listar ?, ?, ?, 1";
$params = array(   
		  array($REQ_Id, SQLSRV_PARAM_IN),
          array($VFL_Id, SQLSRV_PARAM_IN),
          array($FLD_Id, SQLSRV_PARAM_IN)
   );  

$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
$ok = false;
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))
{
    $ok=true;
    $VPV_Id=$row['VPV_Id'];
    //$VCE_Glosa=$row['VCE_Glosa'];
    break;
};
sqlsrv_free_stmt( $stmt);*/

$mes=date_format($VPV_FechaEdit,'m');
$anio=date_format($VPV_FechaEdit,'Y');
$dia=date_format($VPV_FechaEdit,'d');
$diasemana=date_format($VPV_FechaEdit,'w');

$dias = array("Domingo","Lunes","Martes","Miercoles","Jueves","Viernes","Sabado");
$meses = array("Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre");

$fecha_larga=$dias[$diasemana]." ".$dia." de ".$meses[$mes-1]." de ".$anio;
$fecha="\n\n\n\nSantiago, ".$fecha_larga;

$titulo="NÚMERO INGRESO CONTROL FACTURA: ".$VRE_Id;
$subtitulo="";
$id="";
//$id="\nN° ".$VCE_Id."/ Req° ".$REQ_Id;

if(!$ok){
    $response = array('response' => 'error', 'data'=>'Error 9 No fue posible generar el informe solicitado, no esta activo');
    echo json_encode($response);
    die;    
};

// Extend the TCPDF class to create custom Header and Footer
class MYPDF extends TCPDF {    
    //Page header    
    // Page footer
    public function Footer() {
        // Position at 15 mm from bottom
        $this->SetY(-15);
        // Set font
        $this->SetFont('helvetica', '', 8);
        // Custom footer HTML
        $this->html = '<hr><br><span>'.$this->VerSis.'</span><br><b>página '.$this->getAliasNumPage().'/'.$this->getAliasNbPages().'</b>';
        $this->writeHTML($this->html, true, false, true, false, '');
    }
}

// create new PDF document
$pdf = new MYPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);

// set document information
//Version del sistema dsn.php
$pdf->VerSis = $ver;
$pdf->SetCreator(PDF_CREATOR);
$pdf->SetAuthor('SUBTRAB');
//pdf->SetTitle($_POST["titulo"]);
$pdf->SetTitle('PROVIDENCIA DE PAGO');
$pdf->SetSubject($ver);
$pdf->SetKeywords('TCPDF, PDF, cdp, workflow, compras');


// set default header data
$pdf->SetHeaderData("logo_subtrab.jpg", 30, 'PROVIDENCIA' , $titulo.$subtitulo.$id.$fecha);

// set header and footer fonts
$pdf->setHeaderFont(Array(PDF_FONT_NAME_MAIN, '', PDF_FONT_SIZE_MAIN));
$pdf->setFooterFont(Array(PDF_FONT_NAME_DATA, '', PDF_FONT_SIZE_DATA));

// set default monospaced font
$pdf->SetDefaultMonospacedFont(PDF_FONT_MONOSPACED);

// set margins
//$pdf->SetMargins(PDF_MARGIN_LEFT, PDF_MARGIN_TOP, PDF_MARGIN_RIGHT);
$pdf->SetMargins(PDF_MARGIN_LEFT, 40, PDF_MARGIN_RIGHT);
$pdf->SetHeaderMargin(PDF_MARGIN_HEADER);
$pdf->SetFooterMargin(PDF_MARGIN_FOOTER);

// set auto page breaks
$pdf->SetAutoPageBreak(TRUE, PDF_MARGIN_BOTTOM);

// set image scale factor
$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

// set some language-dependent strings (optional)
if (@file_exists(dirname(__FILE__).'/lang/eng.php')) {
    require_once(dirname(__FILE__).'/lang/eng.php');
    $pdf->setLanguageArray($l);
}

// ---------------------------------------------------------

// set font
$pdf->SetFont('helvetica', '', 10);

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Print a document

// add a page
$pdf->AddPage('P','A4');
// create some HTML content
$htmlstyle = '';
$html = $htmlstyle.'<table width="100%" border="0" align="left" style="font-size:10px;">';
$html = $html.'<tr>
                <td width="5%" style="text-align:left;padding-bottom:5px;height:15px;"><strong>De:</strong></td>
                <td width="95%" style="text-align:left;border-bottom:1px dotted black;padding-bottom:5px">JEFA(E) '.strtoupper($DEP_DescripcionSG).'</td>
              </tr>              
              <tr>
                <td width="5%" style="text-align:left;padding-bottom:5px;height:15px;"><strong>A:</strong></td>
                <td width="95%" style="text-align:left;border-bottom:1px dotted black;padding-bottom:5px">JEFA(E) '.strtoupper($DEP_DescripcionFIN).'</td>
              </tr>';
$html = $html.'</table>
            <br><br>
            <span style="font-size:10px;">Detalle:</span>
            <br><br>';

$datosTabla = '';
$tsql_callSP = "spDatosFormularioxVersion_Consultar ?, -1";
$params = array(   
            array($data->DRE_Id, SQLSRV_PARAM_IN)            
    ); 
$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))    
{
    if($row['FDI_Id']==104)
    {
        $VPV_NumDoc=$row['DFO_Dato'];
    }
    if($row['FDI_Id']==105)
    {
        $tsql_callSP2 = "spProveedores_Consultar ?";
        $params2 = array(   
                    array($row['DFO_Dato'], SQLSRV_PARAM_IN)            
            );
        $stmt2 = sqlsrv_query( $conn, $tsql_callSP2, $params2);
        while( $row2 = sqlsrv_fetch_array( $stmt2, SQLSRV_FETCH_ASSOC))
        {
            $PRO_RazonSocial=$row2['PRO_RazonSocial'];
            $PRO_Rut=$row2['PRO_Rut'];
            $PRO_Dv=$row2['PRO_DV'];
            break;
        };
    }
    if($row['FDI_Id']==107)
    {
        $VPV_OC=$row['DFO_Dato'];
    }
    if($row['FDI_Id']==109)
    {
        $VPV_Monto=$row['DFO_Dato'];
    }
    if($row['FDI_Id']==112)
    {
        $VPV_Observaciones=$row['DFO_Dato'];
    }
    if($row['FDI_Id']==124)
    {
        $VPV_FolioCompromiso=$row['DFO_Dato'];
    }
};
sqlsrv_free_stmt( $stmt);

$html=$html.'<table width="100%" border="1" align="center" style="font-size:10px;">';
$html=$html.'<tr>
                <td>N° Documento</td>
                <td colspan="2">'.$VPV_NumDoc.'</td>
            </tr>
            <tr>
                <td>Nombre Proovedor</td>
                <td colspan="2">'.$PRO_RazonSocial.'</td>
            </tr>
            <tr>
                <td>RUT Proovedor</td>
                <td colspan="2">'.number_format($PRO_Rut,0,',','.').'-'.$PRO_Dv.'</td>
            </tr>
            <tr>
                <td>Monto</td>
                <td colspan="2">$ '.number_format($VPV_Monto,0,',','.').'</td>
            </tr>
            <tr>
                <td>Doc. autoriza pago</td>
                <td colspan="2">'.$VPV_FechaPago.'</td>
            </tr>
            <tr>
                <td>Orden de compra</td>
                <td colspan="2">'.$VPV_OC.'</td>
            </tr>
            <tr>
                <td>Folio compromiso</td>
                <td colspan="2">'.$VPV_FolioCompromiso.'</td>
            </tr>';

$tsql_callSP = "spDetalleProvidencia_Listar 1, ?";
$params = array(   
            array($VPV_Id, SQLSRV_PARAM_IN)            
    ); 
$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))
{
    $ESR_DescripcionVersionProvidencia=$row['ESR_DescripcionVersionProvidencia'];
    $ESR_IdVersionProvidencia=$row['ESR_IdVersionProvidencia'];
    if($row['DPV_ResolucionDecreto']==1){
        $chkREsDec="[X]";
    }else{      
        $chkREsDec="[_]";
    };
    if($row['DPV_FolioAltaBien']==1){
        $chkFolioAltaBien="[X]";
    }else{
        $chkFolioAltaBien="[_]";
    };
    if($row['DPV_Factoring']==1){
        $chkFactoring="[X]";
    }else{
        $chkFactoring="[_]";
    };
    $html=$html.'        
            <tr>
                <td>Saldo inicial</td>
                <td colspan="2">$ '.number_format($row['DPV_SaldoInicial'],0,',','.').'</td>
            </tr>
            <tr>
                <td>Saldo consumido</td>
                <td colspan="2">$ '.number_format($row['DPV_SaldoConsumido'],0,',','.').'</td>
            </tr>
            <tr>
                <td>Saldo actual</td>
                <td colspan="2">$ '.number_format($row['DPV_SaldoActual'],0,',','.').'</td>
            </tr>
            <tr>
                <td>Autorización de compra</td>
                <td>No aplica</td>
                <td>N°</td>                
            </tr>
            <tr>
                <td>Resolución/Decreto</td>
                <td>'.$chkREsDec.'</td>
                <td>'.$row['DPV_ResolucionDecretoNumero'].'</td>                
            </tr>
            <tr>
                <td>Folio alta del bien</td>
                <td>'.$chkFolioAltaBien.'</td>
                <td>'.$row['DPV_FolioAltaBienNumero'].'</td>                
            </tr>
            <tr>
                <td>Factoring</td>
                <td>'.$chkFactoring.'</td>
                <td>'.$row['DPV_FactoringNombre'].'</td>                
            </tr>';
};
sqlsrv_free_stmt( $stmt);

//Buscando V°B°
$tsql_callSP = "[spDatoRequerimientoVB_Consultar] ?, ?, ?, ?";
$params = array(   
            array($VRE_Id, SQLSRV_PARAM_IN),
            array($FLD_IdAprobacion, SQLSRV_PARAM_IN),
            array($data->wk2_usrid, SQLSRV_PARAM_IN),
            array($data->wk2_usrtoken, SQLSRV_PARAM_IN)           
    ); 
$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
$cont=1;
$VB='';
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))
{
    if($cont>1){
        $VB=$VB.'/';
    };    
    $USR_Nombres = explode(" ",$row['USR_Nombre']);
    $USR_Apellidos = explode(" ",$row['USR_Apellido']);
    $VB=$VB.strtoupper(substr($USR_Nombres[0],0,1));    
    if(count($USR_Apellidos)==2){
        $VB=$VB.strtoupper(substr($USR_Apellidos[0],0,1)).strtoupper(substr($USR_Apellidos[1],0,1));
    }else{
        $VB=$VB.strtoupper(substr($USR_Apellidos[0],0,1));
    };
    $cont++;
};

$html=$html.'</table><br><br>
<table width="100%"  border="0" align="left" style="font-size:10px;">
    <tbody>
        <tr>
            <td style="text-align:left">
                Observaciones : '.$VPV_Observaciones.'
            </td>
        </tr>        
        <tr>
            <td style="text-align:right">
                Estado : <strong>'.strtoupper($ESR_DescripcionVersionProvidencia).'</strong>
            </td>
        </tr>
    </tbody>
</table>';

if($cont>1){
    $html=$html.'<br><br><br>';
    $html=$html.'<span style="font-size:10px;"><strong>'.$VB.'</strong><br>';
    $html=$html.'<span style="font-size:10px;"><strong>V°B°</strong>';
    $html=$html.'<br><br><br>';
};

$html=$html.'<table width="100%"  border="0" align="center">
  <tr>
    <td style="text-align:center"><div style="width:100%;text-align:center;">
      <p>&nbsp;</p>';
      if($ESR_IdVersionProvidencia==8){
        $html=$html.'<p><img src="'.$USR_FirmaSG.'"></p>';
      }
      $html=$html.'<p><span style="font-size:10px;"><strong>'.mb_strtoupper($USR_NombreSG,'utf-8').' '.mb_strtoupper($USR_ApellidoSG,'utf-8').'</strong><br></span>
    	 <span style="font-size:10px;">JEFE(A) '.mb_strtoupper($DEP_DescripcionSG,'utf-8').'<br></span>
         <span style="font-size:10px;">'.$USR_RutSG."-".$USR_DvSG.'<br></span>
      </p>
      </div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>';

// reset pointer to the last page
$pdf->lastPage();
// output the HTML content
$pdf->writeHTML($html, true, false, true, false, '');

// ---------------------------------------------------------
//Cierre de la conexion
sqlsrv_close( $conn);
//Close and output PDF document

if (!is_dir($dir)) {
    mkdir($dir, 0777, true);
}

//Creando fecha juliana
$dia=date("d");
$mes=date("m");
$anio=date("Y");
$jdate=juliantojd($mes,$dia,$anio);
$pdf->Output($dir.$NombreArchivo.$jdate.time().".pdf", 'F');	//Grabar
$pdf->Output($dir.$NombreArchivo.".pdf", 'F');	//Grabar

$response = array('response' => 'ok');
echo json_encode($response);
//============================================================+
// END OF FILE
//============================================================+
?>