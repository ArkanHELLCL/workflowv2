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
    if(($row['INF_Estado']==1) && ($row['Id']==$data->INF_Id)){
	    $ok = true;
		$INF_NombreArchivo = $row['INF_NombreArchivo'];
		$INF_Descripcion  = $row['INF_Descripcion'];
		$VCE_Id = $row['VCE_Id'];		//Para cuando es certificado
		$NombreArchivo = trim(str_replace("/prt-","",$INF_NombreArchivo));
		$VCE_FechaEdit=$row['VCE_FechaEdit'];
		$FLD_IdRC=$row['FLD_Id'];
		$FLD_IdAprobacion=$row['FLD_IdAprobacion'];
        if(is_null($FLD_IdAprobacion)){
            $FLD_IdAprobacion = $FLD_IdRC;
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

//RC
$tsql_callSP = "spIDVersionFormularioMEMOVisadoJefatura_Mostrar ?, ?, ?";
$params = array(   
        array($VRE_Id, SQLSRV_PARAM_IN),
        array($FLD_IdAprobacion, SQLSRV_PARAM_IN),      //Va al paso en donde se aprueba o rechaza el RC
        array($ESR_IdInforme, SQLSRV_PARAM_IN)        
); 	
$dato=$FLD_IdRC;


$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
/*if(is_null($stmt)){      //No hay registros
    sqlsrv_free_stmt( $stmt);
    if($VCE_Id!=0){
        //Certificado y otros
        $tsql_callSP = "spIDVersionFormulario_Mostrar ?, ?, ?";
        $params = array(   
                array($VRE_Id, SQLSRV_PARAM_IN),
                array($FLD_IdRC, SQLSRV_PARAM_IN),
                array($ESR_IdInforme, SQLSRV_PARAM_IN)
        ); 	
        $dato=$FLD_IdRC;
        $stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
        while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))  
        {
            //Creador
            $VFO_IdUSuarioEdit = $row['VFO_IdUSuarioEdit'];
            $VFO_FechaEdit = $row['VFO_FechaEdit'];
            $USR_IdEditor = $row['USR_IdEditor'];
            //$USR_FechaEdit = $row['DRE_FechaEdit'];
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
        //$USR_FechaEdit = $row['DRE_FechaEdit'];  
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

    //Usuario creador
    $USR_Usuario = $row['USR_Usuario'];
    $USR_Nombre = $row['USR_Nombre'];
    $USR_Apellido = $row['USR_Apellido'];
    $USR_Rut = $row['USR_Rut'];
    $USR_DV = $row['USR_DV'];
    $USR_Firma = $row['USR_Firma'];
    break;
};
sqlsrv_free_stmt( $stmt);

//Buscar Departamento del que aprueba/rechaza la RC
$tsql_callSP = "spUsuario_Consultar ?";
$params = array(   
		  array($USR_IdEditor, SQLSRV_PARAM_IN)          
   );  

$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
$ok = false;
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))
{
    $ok=true;
    //Creador
    $DEP_IdRCApr=$row['DEP_Id'];
    $DEP_DescripcionRCApr=$row['DEP_Descripcion'];

    //Usuario creador
    $USR_UsuarioRCApr = $row['USR_Usuario'];
    $USR_NombreRCApr = $row['USR_Nombre'];
    $USR_ApellidoRCApr = $row['USR_Apellido'];
    $USR_RutRCApr = $row['USR_Rut'];
    $USR_DVRCApr = $row['USR_DV'];
    $USR_FirmaRCApr = $row['USR_Firma'];
    break;
};
sqlsrv_free_stmt( $stmt);

/*
//Buscando jefe/a DAF   --No se esta Utilizando--s
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
    $USR_UsuarioRC = $row['USR_Usuario'];     //Jefe del departamento creador de la RC
    $USR_NombreRC = $row['USR_Nombre'];
    $USR_ApellidoRC = $row['USR_Apellido'];
    $USR_RutRC = $row['USR_Rut'];
    $USR_DvRC = $row['USR_DV'];
    $USR_IdRC = $row['USR_Id'];
    $USR_FirmaRC = $row['USR_Firma'];

    $DEP_DescripcionRC=$row['DEP_Descripcion'];
    break;
};
sqlsrv_free_stmt( $stmt);

$DAF_Nombre = $USR_NombreDAF." ".$USR_ApellidoDAF;
*/

//Buscando jefe/a Departamento del que aprueba/rechaza RC
$tsql_callSP = "spJefeDepartamento_Mostrar ?, ?, ?";
$params = array(   
		  array($DEP_IdRCApr, SQLSRV_PARAM_IN),
          array($data->wk2_usrid, SQLSRV_PARAM_IN),
          array($data->wk2_usrtoken, SQLSRV_PARAM_IN)
   );  

$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
$ok = false;
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))
{
    $ok=true;
    //Jefatura
    $USR_UsuarioRCAprJ = $row['USR_Usuario'];     //Jefe del departamento creador de la RC
    $USR_NombreRCAprJ = $row['USR_Nombre'];
    $USR_ApellidoRCAprJ = $row['USR_Apellido'];
    $USR_RutRCAprJ = $row['USR_Rut'];
    $USR_DvRCAprJ = $row['USR_DV'];
    $USR_IdRCAprJ = $row['USR_Id'];
    $USR_FirmaRCAprJ = $row['USR_Firma'];

    $DEP_DescripcionRCAprJ=$row['DEP_Descripcion'];
    break;
};
sqlsrv_free_stmt( $stmt);
$APRJefe_Nombre = $USR_NombreRCAprJ." ".$USR_ApellidoRCAprJ;

//Datos del formulario de pagos
$tsql_callSP = "spDatosFormularioxVersion_Consultar ?, -1";
$params = array(   
            array($data->DRE_Id, SQLSRV_PARAM_IN)            
    ); 
$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))  
{
    if($row['FDI_Id']==54) $NumeroDocumento = number_format($row['DFO_Dato'],0,',','.');
    if($row['FDI_Id']==56){
        $tsql_callSP2 = "spProveedores_Consultar ?";
        $params2 = array(   
                    array($row['DFO_Dato'], SQLSRV_PARAM_IN)            
            ); 
        $stmt2 = sqlsrv_query( $conn, $tsql_callSP2, $params2);
        while( $row = sqlsrv_fetch_array( $stmt2, SQLSRV_FETCH_ASSOC))  
        {
            $ProveedorNombre = $row['PRO_RazonSocial'];
            $ProveedorRut = $row['PRO_Rut'];
            $ProveedorDv = $row['PRO_DV'];
        }
        sqlsrv_free_stmt( $stmt2);
    }
    //57
    if($row['FDI_Id']==57){
        $tsql_callSP2 = "spItemListaDesplegable_Consultar ?";
        $params2 = array(   
                    array($row['DFO_Dato'], SQLSRV_PARAM_IN)            
            ); 
        $stmt2 = sqlsrv_query( $conn, $tsql_callSP2, $params2);
        while( $row = sqlsrv_fetch_array( $stmt2, SQLSRV_FETCH_ASSOC))  
        {
            $TipoDocumento = $row['ILD_Descripcion'];
        }
        sqlsrv_free_stmt( $stmt2);
    }
    //Moneda
    if($row['FDI_Id']==59){
        $tsql_callSP2 = "spItemListaDesplegable_Consultar ?";
        $params2 = array(   
                    array($row['DFO_Dato'], SQLSRV_PARAM_IN)            
            ); 
        $stmt2 = sqlsrv_query( $conn, $tsql_callSP2, $params2);
        while( $row = sqlsrv_fetch_array( $stmt2, SQLSRV_FETCH_ASSOC))  
        {
            $TipoMoneda = $row['ILD_Descripcion'];
        }
        sqlsrv_free_stmt( $stmt2);
    }
    if($row['FDI_Id']==60) $MontoDocumento = number_format($row['DFO_Dato'],0,',','.');
    if($row['FDI_Id']==62) $EstadoRC = intval($row['DFO_Dato']);
    //if($EstadoRC==228){   Desarrollo
    if($EstadoRC==237){ //Produccion
        $EstadoRCDes="ACEPTADA";
        $no = "SI";
    }else{
        $EstadoRCDes="RECLAMADA";
        $no = "NO";
    } 
};
sqlsrv_free_stmt( $stmt);


//Datos de la RC
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
$fecha="\nSantiago, ".$fecha_larga;

$titulo="SUBSECRETARÍA DEL TRABAJO";
$subtitulo="\nDEPARTAMENTO DE ADQUISICIONES";
$id="\nN° ".$REQ_Id."/".$VRE_Id;

$UsrApr = "\n\nPor: ".$USR_NombreRCApr." ".$USR_ApellidoRCApr;

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
$pdf->SetTitle('RECEPCIÓN CONFORME');
$pdf->SetSubject($ver);
$pdf->SetKeywords('TCPDF, PDF, recepcion conforme, workflow, pagos');


// set default header data
//$pdf->SetHeaderData(PDF_HEADER_LOGO, PDF_HEADER_LOGO_WIDTH, PDF_HEADER_TITLE, PDF_HEADER_STRING);
$pdf->SetHeaderData("logo_subtrab.jpg", 30, 'RECEPCIÓN CONFORME' , $titulo.$subtitulo.$UsrApr.$fecha.$id);

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
$html = $htmlstyle.'<p>Mediante el presente y en representación del <strong>'.$APRJefe_Nombre.'</strong>, jefe de <strong>'.$DEP_DescripcionRCAprJ.'</strong> se informa que la recepción conforme del (bien o servicio solicitado) ha sido <strong>'.$EstadoRCDes.'</strong> y en consecuencia <strong>'.$no.'</strong> se autoriza gestionar el pago del documento tipo: <strong>'.$TipoDocumento.' N°'.$NumeroDocumento.'</strong>, del proveedor/empresa: <strong>'.$ProveedorNombre.' RUT: '.$ProveedorRut.'-'.$ProveedorDv.'</strong> por un monto de: <strong>$'.$MontoDocumento.' ('.trim($TipoMoneda).').</strong></p><p>Esta solicitud fué respondida por: <strong>'.$USR_Nombre.' '.$USR_Apellido.'</strong> perteneciente a <strong>'.$DEP_Descripcion.'</strong></p><p style="text-align:right;">Recepción Conforme: <strong>'.$EstadoRCDes.'</strong>';    


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