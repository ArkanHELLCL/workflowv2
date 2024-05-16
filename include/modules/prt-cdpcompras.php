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
    $DEP_DescripcionOrigen = $row['DepDescripcionOrigen'];
    $dir='d:/DocumentosSistema/WorkFlow/{'.$REQ_Carpeta.'}/informes/INF_Id-'.$data->INF_Id.'/';        
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
		$VCE_Id = $row['VCE_Id'];		//Para cuando es certificado
		$NombreArchivo = trim(str_replace("/prt-","",$INF_NombreArchivo));
		//$VCE_FechaEdit=$row['VCE_FechaEdit'];
        $VCE_FechaEdit=$row['VCE_FechaEDit'];
		$FLD_Id=$row['FLD_Id'];
		$FLD_IdAprobacion=$row['FLD_IdAprobacion'];
        //$VFO_Id=$row['VFO_Id'];
        if(is_null($FLD_IdAprobacion)){
            $FLD_IdAprobacion = $FLD_Id;
        };
        if(is_null($VCE_Id) || $VCE_Id==""){
            $VCE_Id=0;
        };
        $ESR_IdInforme = $row['ESR_IdInforme'];
        if(is_null($ESR_IdInforme)){
            $ESR_IdInforme=2;
        };
        break;
    }
}
sqlsrv_free_stmt( $stmt);



if($VCE_Id!=0){
	//Certificado y otros
    $tsql_callSP = "spIDVersionFormulario_Mostrar ?, ?, ?";
    $params = array(   
            array($VRE_Id, SQLSRV_PARAM_IN),
            array($FLD_IdAprobacion, SQLSRV_PARAM_IN),
            array($ESR_IdInforme, SQLSRV_PARAM_IN)
    ); 
	//Rescatar valor a partir del paso 5 del diseño del flujo (28)
	$dato=$FLD_IdAprobacion;
}else{	
    $response = array('response' => 'error', 'data'=>'Error 7 Aun no se crea el certificado. Imposible generar pdf');
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
    if($VCE_Id!=0){
        //Certificado y otros
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


//Buscar Departamento del creador del formulario
$tsql_callSP = "spUsuario_Consultar ?";
$params = array(   
		  array($VFO_IdUSuarioEdit, SQLSRV_PARAM_IN)          
   );  

$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
$ok = false;
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))
{
    $ok=true;
    //Creador
    $DEP_Id=$row['DEP_Id'];
    $DEP_Descripcion=$row['DEP_Descripcion'];

    //Usuario que aprobo el memo
    $USR_Usuario = $row['USR_Usuario'];
    $USR_Nombre = $row['USR_Nombre'];
    $USR_Apellido = $row['USR_Apellido'];
    $USR_Rut = $row['USR_Rut'];
    $USR_DV = $row['USR_DV'];
    $USR_Firma = $row['USR_Firma'];
    break;
};
sqlsrv_free_stmt( $stmt);



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
    $USR_UsuarioFIN = $row['USR_Usuario'];     //Jefe del departamento creador
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
$tsql_callSP = "spInformesCertificadosxVersion_Listar ?, ?, ?, 1";
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
    $VCE_Id=$row['VCE_Id'];
    $VCE_Glosa=$row['VCE_Glosa'];
    break;
};
sqlsrv_free_stmt( $stmt);


//Datos del cdp
/*$mes=date_format($VFO_FechaEdit,'m');
$anio=date_format($VFO_FechaEdit,'Y');
$dia=date_format($VFO_FechaEdit,'d');
$diasemana=date_format($VFO_FechaEdit,'w');*/

$mes=date_format($VCE_FechaEdit,'m');
$anio=date_format($VCE_FechaEdit,'Y');
$dia=date_format($VCE_FechaEdit,'d');
$diasemana=date_format($VCE_FechaEdit,'w');

$dias = array("Domingo","Lunes","Martes","Miercoles","Jueves","Viernes","Sabado");
$meses = array("Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre");

$fecha_larga=$dias[$diasemana]." ".$dia." de ".$meses[$mes-1]." de ".$anio;
$fecha="\n\n\nSantiago, ".$fecha_larga;

$titulo="";
$subtitulo="";
$id="\nN° ".$VCE_Id."/ Req° ".$REQ_Id;

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
$pdf->SetTitle('CERTIFICADO DE DISPONIBILIDAD PRESUPUESTARIA');
$pdf->SetSubject($ver);
$pdf->SetKeywords('TCPDF, PDF, cdp, workflow, compras');


// set default header data
$pdf->SetHeaderData("logo_subtrab.jpg", 30, 'CERTIFICADO DE DISPONIBILIDAD PRESUPUESTARIA' , $titulo.$subtitulo.$fecha.$id);

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
$html = $htmlstyle.'<table width="100%" border="0" align="center">';

$datosTabla = '';
$tsql_callSP = "spDatosFormularioxVersion_Consultar ?, -1";
$params = array(   
            array($data->DRE_Id, SQLSRV_PARAM_IN)            
    ); 
$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
$pgmpre=false;
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))    
{
    if(strtolower($row['FDI_NombreHTML'])=='comprogramapresupuestario'){
        $pgmpre=true;
        $html=$html.'<tr>
            <td style="text-align:left;font-size:12px" width="30%"><span><strong>'.$row['FDI_Descripcion'].'</strong></span></td>';
            if(trim($row['FDI_TipoCampo'])=="L"){
                //Buscando la descripcion de la lista
                $VFO_Id=$row['VFO_Id'];                    
                $tsql_callSP2 = "spItemListaDesplegable_Consultar ?";
                $params2 = array(   
                            array($row['DFO_Dato'], SQLSRV_PARAM_IN)            
                    ); 
                $stmt2 = sqlsrv_query( $conn, $tsql_callSP2, $params2);
                while( $row2 = sqlsrv_fetch_array( $stmt2, SQLSRV_FETCH_ASSOC))    
                {
                    $html=$html.'<td style="text-align:left;"><strong>: <span>'.trim($row2['ILD_Descripcion']).'</span></strong></td>';
                    break;
                };
            }else{
                $html=$html.'<td style="text-align:left;"><strong>: <span>'.trim($row['DFO_Dato']).'</span></strong></td>';
            };        
        $html=$html.'</tr>';
        break;
    };
};
$html=$html.'<tr>
            <td style="text-align:left;font-size:12px" width="30%"><span><strong>Proyecto Específico</strong></span></td>
            <td style="text-align:left;" width="70%"><strong>: <span>'.$REQ_Descripcion.'</span></strong></td>
        </tr>
        <tr>
            <td style="text-align:left;font-size:12px" width="30%"><span><strong>Unidad Solicitante</strong></span></td>
            <td style="text-align:left;" width="70%"><strong>: <span>'.$DEP_DescripcionOrigen.'</span></strong></td>
        </tr>
    </table><br><br><br><br>';

sqlsrv_free_stmt( $stmt);
if($pgmpre){
    sqlsrv_free_stmt( $stmt2);
}


//Desplegando todas las imputaciones de la ultimia version del certificado
$datosTabla = '';
$tsql_callSP = "spDetalleCertificado_Listar 1, ?";
$params = array(   
            array($VCE_Id, SQLSRV_PARAM_IN)            
    ); 
$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))
{
    $ESR_DescripcionVersionCertificado=$row['ESR_DescripcionVersionCertificado'];
    $ESR_IdVersionCertificado=$row['ESR_IdVersionCertificado'];
    $html=$html.'<table width="100%">
        <tbody>
            <tr>
                <td width="50%"><strong>Imputación:</strong></td>
                <td><strong>'.$row['ILD_Descripcion'].'</strong></td>
            </tr>
        </tbody>
    </table>
    <table width="100%" border="1">
        <tbody>
            <tr>
                <td width="50%">Presupuesto Asignado:</td>
                <td>$ '.number_format($row['DCE_Asignado'],0,',','.').'</td>
            </tr>
            <tr>
                <td width="50%">Presupuesto Comprometido:</td>
                <td>$ '.number_format($row['DCE_Comprometido'],0,',','.').'</td>
            </tr>
            <tr>
                <td width="50%">Presente Documento:</td>
                <td>$ '.number_format($row['DCE_Monto'],0,',','.').'</td>
            </tr>
            <tr>
                <td width="50%">Saldo Disponible</td>
                <td>$ '; 
                    $saldo = $row['DCE_Asignado'] - ($row['DCE_Comprometido'] + $row['DCE_Monto']);
                    $html=$html.number_format($saldo,0,',','.').'</td>
            </tr>
        </tbody>
    </table>
    <br>
    <br>';
};
sqlsrv_free_stmt( $stmt);

$html=$html.'<br>
<table width="100%"  border="0" align="left">
    <tbody>
        <tr>
            <td style="text-align:left">
                Nota : '.$VCE_Glosa.'
            </td>
        </tr>
        <tr>
            <td style="text-align:right">
                Estado : <strong>'.$ESR_DescripcionVersionCertificado.'</strong>
            </td>
        </tr>
    </tbody>
</table>
<table width="100%"  border="0" align="center">
  <tr>
    <td style="text-align:center"><div style="width:100%;text-align:center;">
      <p>&nbsp;</p>';
      if($ESR_IdVersionCertificado==8){
        $html=$html.'<p><img src="'.$USR_FirmaFIN.'"></p>';
      }
      $html=$html.'<p><span>'.mb_strtoupper($USR_NombreFIN,'utf-8').' '.mb_strtoupper($USR_ApellidoFIN,'utf-8').'<br></span>
    	 <span>JEFE(A) '.mb_strtoupper($DEP_DescripcionFIN,'utf-8').'<br></span>
         <span>'.$USR_RutFIN."-".$USR_DvFIN.'<br></span>
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