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


if($data->wk2_usrperfil==5 || $data->wk2_usrperfil==''){
    $response = array('response' => 'error', 'data' => 'Error 3 Usuario no autorizado');
    echo json_encode($response);
    die;
}
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
		$VCE_FechaEdit=$row['VCE_FechaEdit'];
		$FLD_IdMemo=$row['FLD_Id'];
		$FLD_IdAprobacion=$row['FLD_IdAprobacion'];
        if(is_null($FLD_IdAprobacion)){
            $FLD_IdAprobacion = $FLD_IdMemo;
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



/*if($VCE_Id!=0){
	//Certificado y otros
    $tsql_callSP = "spIDVersionFormulario_Mostrar ?, ?, ?";
    $params = array(   
            array($VRE_Id, SQLSRV_PARAM_IN),
            array($FLD_IdAprobacion, SQLSRV_PARAM_IN),
            array($ESR_IdInforme, SQLSRV_PARAM_IN)
    ); 
	//Rescatar valor a partir del paso 5 del diseño del flujo (28)
	$dato=$FLD_IdAprobacion;
}else{*/
//Memo
$tsql_callSP = "spIDVersionFormularioMEMOVisadoJefatura_Mostrar ?, ?, ?";
$params = array(   
        array($VRE_Id, SQLSRV_PARAM_IN),
        //array($FLD_IdMemo, SQLSRV_PARAM_IN),
        array($FLD_IdAprobacion, SQLSRV_PARAM_IN),
        array($ESR_IdInforme, SQLSRV_PARAM_IN)
); 	
$dato=$FLD_IdMemo;
//};	

$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
/*if(is_null($stmt)){      //No hay registros
    sqlsrv_free_stmt( $stmt);
    if($VCE_Id!=0){
        //Certificado y otros
        $tsql_callSP = "spIDVersionFormulario_Mostrar ?, ?, ?";
        $params = array(   
                array($VRE_Id, SQLSRV_PARAM_IN),
                array($FLD_IdMemo, SQLSRV_PARAM_IN),
                array($ESR_IdInforme, SQLSRV_PARAM_IN)
        ); 	
        $dato=$FLD_IdMemo;
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
}else{*/
    while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))  
    {
        //Creador
        $VFO_IdUSuarioEdit = $row['VFO_IdUSuarioEdit'];
        $VFO_FechaEdit = $row['VFO_FechaEdit'];
        $USR_IdEditor = $row['USR_IdEditor'];
        break;
    }
//};
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



//Buscando jefe/a DAF (4)
$DEP_IdDAF = 4;
$tsql_callSP = "spJefeDepartamento_Mostrar ?, ?, ?";
$params = array(   
		  array($DEP_IdDAF, SQLSRV_PARAM_IN),
          array($data->wk2_usrid, SQLSRV_PARAM_IN),
          array($data->wk2_usrtoken, SQLSRV_PARAM_IN)
   );  

$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
$ok = false;
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))
{
    $ok=true;
    //Jefatura
    $USR_UsuarioDAF = $row['USR_Usuario'];     //Jefe del departamento creador
    $USR_NombreDAF = $row['USR_Nombre'];
    $USR_ApellidoDAF = $row['USR_Apellido'];
    $USR_RutDAF = $row['USR_Rut'];
    $USR_DvDAF = $row['USR_DV'];
    $USR_IdDAF = $row['USR_Id'];
    $USR_FirmaDAF = $row['USR_Firma'];

    $DEP_DescripcionDAF=$row['DEP_Descripcion'];
    break;
};
sqlsrv_free_stmt( $stmt);

$DAF_Nombre = $USR_NombreDAF." ".$USR_ApellidoDAF;

//Datos del memo
$id=$REQ_Id."/".$VRE_Id;
$jefe_directo = $USR_Nombre." ".$USR_Apellido;
$jefe_directo=mb_strtoupper($jefe_directo,'utf-8');
$cargo_jefe_directo=mb_strtoupper($DEP_Descripcion,'utf-8');
$rut_jefe_directo=$USR_Rut."-".$USR_DV;
$rut_jefe_directo=mb_strtoupper($rut_jefe_directo,'utf-8');

$mes=date_format($VFO_FechaEdit,'m');
$anio=date_format($VFO_FechaEdit,'Y');
$dia=date_format($VFO_FechaEdit,'d');
$diasemana=date_format($VFO_FechaEdit,'w');

$dias = array("Domingo","Lunes","Martes","Miercoles","Jueves","Viernes","Sabado");
$meses = array("Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre");

$fecha_larga=$dias[$diasemana]." ".$dia." de ".$meses[$mes-1]." de ".$anio;
$fecha="\n\nSantiago, ".$fecha_larga;
if($VCE_Id==0){
    $titulo="SUBSECRETARÍA DEL TRABAJO";
    $subtitulo="\nDIVISIÓN DE ADMINISTRACIÓN Y FINANZAS";
    $id="\nN° ".$REQ_Id."/".$VRE_Id;
}else{
    $titulo="";
    $subtitulo="";
    $id="\nN° ".$VCE_Id."/ Req° ".$REQ_Id;
};

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
//$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);
$pdf = new MYPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);

// set document information
//Version del sistema dsn.php
$pdf->VerSis = $ver;
$pdf->SetCreator(PDF_CREATOR);
$pdf->SetAuthor('SUBTRAB');
//pdf->SetTitle($_POST["titulo"]);
$pdf->SetTitle('MEMORANDUM');
$pdf->SetSubject($ver);
$pdf->SetKeywords('TCPDF, PDF, memo, workflow, compras');


// set default header data
//$pdf->SetHeaderData(PDF_HEADER_LOGO, PDF_HEADER_LOGO_WIDTH, PDF_HEADER_TITLE, PDF_HEADER_STRING);
$pdf->SetHeaderData("logo_subtrab.jpg", 30, 'MEMORANDUM' , $titulo.$subtitulo.$fecha.$id);

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
$html = $htmlstyle.'<table width="100%" border="0" align="center"> 
                <tr>
                    <td style="text-align:left;" width="30%"><strong>DE</strong></td>
                    <td style="text-align:left;" width="70%"><strong>: '.$jefe_directo.'</strong></td>
                </tr>
                <tr>
                    <td colspan="2">&nbsp;</td>
                </tr>
                <tr>
                    <td style="text-align:left;" width="30%"><strong>A</strong></td>
                    <td style="text-align:left;" width="70%"><strong>: SR.(A) '.mb_strtoupper($DAF_Nombre,'utf-8').'<BR>&nbsp;&nbsp;JEFE(A) DE '.mb_strtoupper($DEP_DescripcionDAF,'utf-8').'<BR>&nbsp;&nbsp;'.$titulo.'</strong></td>
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
            <table width="100%">';

$datosdb = '<tr>
            <td style="text-align:left">Sin datos</td>
        </tr>';            
$datosTabla = '';
$tsql_callSP = "spDatosFormularioxVersion_Consultar ?, -1";
$params = array(   
            array($data->DRE_Id, SQLSRV_PARAM_IN)            
    ); 
$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))  
{
    if($row['FDI_Imprimible']==1){

        $datosTabla = $datosTabla.'<tr>
                                        <td style="font-size: 12;">'.$row['FDI_Descripcion'].'&nbsp;:</td>
                                    </tr>
                                <tr>';
        if(trim($row['FDI_TipoCampo'])=="N"){            
            $datosTabla = $datosTabla.'<td style="font-size: 12;">'.number_format($row['DFO_Dato'],0,',','.').'</td>';
        }else{
            $datosTabla = $datosTabla.'<td style="font-size: 12;">'.trim($row['DFO_Dato']).'</td>';
        };
        $datosTabla = $datosTabla.'</tr>
                                <tr>
                                    <td style="font-size: 12;">&nbsp;</td>
                                </tr>';
    };
};
if(strlen($datosTabla)>0){
    $datosdb=$datosTabla;
};
$html = $html.$datosdb.'</table><br><br>';

$html = $html.'<tr>
    <td style="text-align:center"><div style="width:100%;text-align:center;">
      <p>&nbsp;</p>
      <p>';
      if(is_null($USR_Firma) || $USR_Firma==""){
        $html = $html.'<img width="230px" height="120px" src="data:image/jpeg;base64,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" ></p>';
      }else{
        $html = $html.'<img width="230px" height="120px" src="'.$USR_Firma.'"></p>';
      };
      $html = $html.'<p><span class="Estilo12">'.$jefe_directo.'<br></span>
    	 <span class="Estilo12">JEFE '.$cargo_jefe_directo.'<br></span>
         <span class="Estilo12">'.$rut_jefe_directo.'<br></span>
      </p>
      </div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>';

sqlsrv_free_stmt( $stmt);


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