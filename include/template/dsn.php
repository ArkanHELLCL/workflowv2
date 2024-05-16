<?php
	//Coneccion BD
	//Desarrollo
	$conn = sqlsrv_connect( 'REDBULL-SRV\SQLDES', array( "Database"=>"WorkFlowV2", "CharacterSet" => "UTF-8"));
	//Produccion
	//$conn = sqlsrv_connect( 'RAPTORS-SRV', array( "Database"=>"WorkFlowV2","CharacterSet" => "UTF-8","Encrypt" => 0));

	$ver = 'Sistema WorkFlow v3.10.2023';

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
?>