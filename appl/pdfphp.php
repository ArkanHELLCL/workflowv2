<?php
//============================================================+
// File name   : example_061.php
// Begin       : 2010-05-24
// Last Update : 2014-01-25
//
// Description : Example 061 for TCPDF class
//               XHTML + CSS
//
// Author: Nicola Asuni
//
// (c) Copyright:
//               Nicola Asuni
//               Tecnick.com LTD
//               www.tecnick.com
//               info@tecnick.com
//============================================================+

/**
 * Creates an example PDF TEST document using TCPDF
 * @package com.tecnick.tcpdf
 * @abstract TCPDF - Example: XHTML + CSS
 * @author Nicola Asuni
 * @since 2010-05-25
 */

//define
/*
define ('PDF_HEADER_LOGO', "../../img/logo_subtrab.png");
define ('PDF_HEADER_LOGO_WIDTH', 30);
define ('PDF_HEADER_TITLE', $_POST["titulo"]);
//define ('PDF_HEADER_STRING', "Nombre del Proyecto\nEjecutor\nEncargado\nFecha");
define ('PDF_HEADER_STRING', $_POST["nombre"]."\nNombre Ejecutor: ".$_POST["ejecutor"]."\nEncargado del Proyecto: ".$_POST["encargado"]."\n\n".$_POST["fecha"]);
define ('PDF_MARGIN_TOP',40);
//define ('PDF_FONT_SIZE_MAIN',18);
*/
define ('PDF_HEADER_LOGO', 'logo_subtrab.jpg');
define ('PDF_HEADER_LOGO_WIDTH', 30);
define ('PDF_HEADER_TITLE', $_POST["informe"]);
define ('PDF_HEADER_STRING', $_POST["titulo"]."\n".$_POST["subtitulo"]."\n\n".$_POST["fecha"]."\n".$_POST["id"]);
define ('PDF_MARGIN_TOP',40);
 
//define ('PDF_FONT_SIZE_MAIN',18);


// Include the main TCPDF library (search for installation path).
require_once('TCPDF-master/tcpdf.php');
if (isset($_SERVER['HTTP_ORIGIN'])) {
    header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
    header('Access-Control-Allow-Credentials: true');
    header('Access-Control-Max-Age: 86400');    // cache for 1 day
    header("Access-Control-Allow-Headers: X-Requested-With");
}

// Access-Control headers are received during OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {

    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']))
        header("Access-Control-Allow-Methods: GET, POST, OPTIONS");         

    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']))
        header("Access-Control-Allow-Headers:        {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");

    exit(0);
}
$dir = "D:\\DocumentosSistema\\WorkFlow\\{".$_POST["path"]."}\\informes\\INF_Id-".$_POST["INF_Id"]."\\";

// create new PDF document
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);

// set document information
$pdf->SetCreator(PDF_CREATOR);
$pdf->SetAuthor('SUBTRAB');
//$pdf->SetTitle($_POST["titulo"]."\n".$_POST["subtitulo"]."\n\n");
$pdf->SetSubject('Sistema WorkFlow V2.2022');
$pdf->SetKeywords('TCPDF, PDF, workflow, compras, flujo');

// set default header data
$pdf->SetHeaderData(PDF_HEADER_LOGO, PDF_HEADER_LOGO_WIDTH, PDF_HEADER_TITLE, PDF_HEADER_STRING);

//define("bottom_info", "|FIRST PAGE|SECOND PAGE|THIRD PAGE|...", true);  

// set header and footer fonts
$pdf->setHeaderFont(Array(PDF_FONT_NAME_MAIN, 'B', PDF_FONT_SIZE_MAIN));
$pdf->setFooterFont(Array(PDF_FONT_NAME_DATA, '', PDF_FONT_SIZE_DATA));

// set default monospaced font
$pdf->SetDefaultMonospacedFont(PDF_FONT_MONOSPACED);

// set margins
$pdf->SetMargins(PDF_MARGIN_LEFT, PDF_MARGIN_TOP, PDF_MARGIN_RIGHT);
$pdf->SetHeaderMargin(PDF_MARGIN_HEADER);
$pdf->SetFooterMargin(PDF_MARGIN_FOOTER);

// set auto page breaks
//$pdf->SetAutoPageBreak(TRUE, PDF_MARGIN_BOTTOM);
$pdf->SetAutoPageBreak(TRUE, PDF_MARGIN_BOTTOM-10);

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

// set table
$pdf->SetCellPadding(0);

//if($_POST["archivo"]=='informeconcensosmesa' || $_POST["archivo"]=='informeinicialmesa' || $_POST["archivo"]=='informesistematizacionmesa'){
	$pdf->AddPage('P','A4');
//}else{
	//$pdf->AddPage('P','A4');
//}

// add a page

// define some HTML content with style
//$html = file_get_contents($_POST["path"].$_POST["archivo"].".htm");
$html = file_get_contents($dir.$_POST["archivo"].".htm");


// output the HTML content
$pdf->writeHTML($html, true, false, true, false, '');

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// reset pointer to the last page
$pdf->lastPage();

// ---------------------------------------------------------
//Creando fecha juliana
$dia=date("d");
$mes=date("m");
$anio=date("Y");
$jdate=juliantojd($mes,$dia,$anio);
//Creando respaldo del archivo generado
//$pdf->Output($_POST["path"].$_POST["archivo"].$jdate.time().".pdf", 'F');	//Grabar
$pdf->Output($dir.$_POST["archivo"].$jdate.time().".pdf", 'F');	//Grabar
//Close and output PDF document
//$pdf->Output($_POST["salida"], 'I');	//Visualizar
//$pdf->Output($_POST["salida"], 'D');	//Bajar
//$pdf->Output($_POST["path"].$_POST["archivo"].".pdf", 'F');	//Grabar
$pdf->Output($dir.$_POST["archivo"].".pdf", 'F');	//Grabar

//============================================================+
// END OF FILE
//============================================================+