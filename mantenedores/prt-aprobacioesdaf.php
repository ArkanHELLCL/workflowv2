<?php
require_once('../include/template/dsn.php');
$json = file_get_contents('php://input');
$data = json_decode($json);
$FLU_Id = 4;
$FLD_Id = 67;

$tsql_callSP = "spAprobacionDAF_Imprimir ?, ?, ?, ?";
$params = array(                        
            array($data->INF_Anio, SQLSRV_PARAM_IN),
            array($data->INF_Mes, SQLSRV_PARAM_IN),
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
      $dataRequerimientos = $dataRequerimientos . $row['tbl_infoaprobdaf'] . ',';
}
sqlsrv_free_stmt( $stmt);
sqlsrv_close( $conn);

$dataRequerimientos=$dataRequerimientos . "]" . ",\"recordsTotal\": \"" . $contreg . "\"" . "}";
echo str_replace("],]","]]",$dataRequerimientos);
?>