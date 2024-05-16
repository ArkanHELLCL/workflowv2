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
define ('PDF_HEADER_LOGO', NULL);
define ('PDF_HEADER_LOGO_WIDTH', NULL);
define ('PDF_HEADER_TITLE', NULL);
define ('PDF_HEADER_STRING', NULL);
define ('PDF_MARGIN_TOP',10);

 
//define ('PDF_FONT_SIZE_MAIN',18);


// Include the main TCPDF library (search for installation path).
require_once('TCPDF-master/tcpdf.php');
if($_POST["INF_Id"]==1){
    $dir = "D:\\DocumentosSistema\\WorkFlow\\legacy\\workflowv1\\REQ-".$_POST["Req_Cod"]."\\CDP\\";
}else{
    if($_POST["INF_Id"]==2){
        $dir = "D:\\DocumentosSistema\\WorkFlow\\legacy\\workflowv1\\REQ-".$_POST["Req_Cod"]."\\MEMO\\";
    }else{
        $dir = "D:\\DocumentosSistema\\WorkFlow\\legacy\\workflowv1\\REQ-".$_POST["Req_Cod"]."\\BASES\\";
    }
}

// create new PDF document
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);

// set document information
$pdf->SetCreator(PDF_CREATOR);
$pdf->SetAuthor('SUBTRAB');
$pdf->SetTitle($_POST["titulo"]);
$pdf->SetSubject('Sistema WorkFlow V1.2010');
$pdf->SetKeywords('TCPDF, PDF, workflow, compras, flujo');

// set default header data
$pdf->SetHeaderData(PDF_HEADER_LOGO, PDF_HEADER_LOGO_WIDTH, PDF_HEADER_TITLE, PDF_HEADER_STRING);

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