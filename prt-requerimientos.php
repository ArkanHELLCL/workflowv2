<?php
require_once('include/template/dsn.php');
/*
$conn = sqlsrv_connect( 'LCASTILLO-PC\MSSQLSERVER19_LC', array( "Database"=>"WorkFlowV2","CharacterSet" => "UTF-8"));
//Produccion
//$conn = sqlsrv_connect( 'KENOBI-SRV', array( "Database"=>"WorkFlowV2","CharacterSet" => "UTF-8","Encrypt" => 0));
if( $conn )  
{  
     //echo "Connection established.\n";  
}  
else  
{  
     //echo "Connection could not be established.\n";  
     die( print_r( sqlsrv_errors(), true));  
} 
*/
$json = file_get_contents('php://input');
$data = json_decode($json);

//die( print_r($data->USR_Identificador,true));

$tsql_callSP = "spRequerimientos_Imprimir ?, ?, ?, ?";
$params = array(
            array($data->Tipo, SQLSRV_PARAM_IN),
            array($data->FLU_Id, SQLSRV_PARAM_IN),
		  array($data->USR_Id, SQLSRV_PARAM_IN),
		  array($data->USR_Identificador, SQLSRV_PARAM_IN)
   );  

//die( print_r($params,true));
$stmt = sqlsrv_query( $conn, $tsql_callSP, $params);

$dataRequerimientos = "{\"data\":[";
$contreg = 0;

while( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))  
{  	  
      $contreg = $contreg + 1;
      $dataRequerimientos = $dataRequerimientos . $row['tbl_requerimientos'] . ',';
}
sqlsrv_free_stmt( $stmt);
sqlsrv_close( $conn);

$dataRequerimientos=$dataRequerimientos . "]" . ",\"recordsTotal\": \"" . $contreg . "\"" . "}";
echo str_replace("],]","]]",$dataRequerimientos);
?>