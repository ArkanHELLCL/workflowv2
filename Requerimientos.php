<?php
    require_once('./include/template/dsn.php');
    //$json = file_get_contents('php://input');
    //$data = json_decode($json);
    //echo $data;
    $length = intval($_REQUEST["length"]);
    $draw = intval($_REQUEST["draw"]);
    $search = $_REQUEST["search"];
    $order = intval($_REQUEST["order"][0]["column"]);
    $dir = $_REQUEST["order"][0]["dir"];
    
    $searchTXT = $_REQUEST["search"]["value"];
    $searchREG = $_REQUEST["search"]["regex"];
    
    if (!empty($searchTXT)) {
        $search = $searchTXT . "%";
    } else {
        $search = "";
    }

    $FLU_Id = $_REQUEST["FLU_Id"];
    $tpo = $_REQUEST["tpo"];
    if ($tpo == "") {
        $tpo = 0;
    }
    
    //echo $json, $data;
    $tsql_callSP = "spDatoRequerimientoBFJSON_Listar ?, ?";
    $params = array(                
                /*array($data->USR_Id, SQLSRV_PARAM_IN),
                array($data->USR_Identificador, SQLSRV_PARAM_IN)*/
                array(5, SQLSRV_PARAM_IN),
                array('80B9DCB3-C59C-4A91-B6CE-C40907C7058B', SQLSRV_PARAM_IN)
            );  
        
    $stmt = sqlsrv_query( $conn, $tsql_callSP, $params);
    
    //$dataRequerimientos = "{\"data\":";
    $contreg = 0;
    
    if( $row = sqlsrv_fetch_array( $stmt, SQLSRV_FETCH_ASSOC))  
    {  	            
          $dataRequerimientos = $row['returnXml'];
    }
    
    $resultJSON = json_decode($dataRequerimientos, true);
    $contreg = count($resultJSON);    
    if(is_object($resultJSON) || is_array($resultJSON)){        
        foreach($resultJSON as $value){
            //if(intval($FLU_Id) == intval($value['FLU_Id'])){
                
                if($cadena != ''){
                    $cadena = $cadena . ',';
                }   
                $cadena = $cadena . '["' . $value['DRE_Id'] . '"' . ',' . '"' . $value['VRE_Id'] . '"' . ',' . '"' . $value['FLD_CodigoPaso'] . '"' . ',' . '"' . $value['VRE_Descripcion'] . '"' . ',' . '"' . $value['REQ_Id'] . '"' . ',' . '"' . $value['REQ_Identificador'] . '"' . ',' . '"' . $value['REQ_Descripcion'] . '"' . ',' . '"' . $REQ_Descripcion . '"' . ',' . '"' . $value['ESR_IdDatoRequerimiento'] . '"' . ',' . '"' . $estado . '"' . ',' . '"' . $value['VFF_Id'] . '"' . ',' . '"' . $value['VFL_Id'] . '"' . ',' . '"' . $value['FLU_Id'] . '"' . ',' . '"' . $value['FLU_Descripcion'] . '"' . ',' . '"' . $value['REQ_Ano'] . '"' . ',' . '"' . $value['VFO_Id'] . '"' . ',' . '"' . $value['FOR_Id'] . '"' . ',' . '"' . $value['FOR_Descripcion'] . '"' . ',' . '"' . $value['IdCreador'] . '"' . ',' . '"' . $value['UsuarioCreador'] . '"' . ',' . '"' . $value['IdPerfilCreador'] . '"' . ',' . '"' . $value['PerfilCreador'] . '"' . ',' . '"' . $value['IdEditor'] . '"' . ',' . '"' . $Editor . '"' . ',' . '"' . $value['IdPerfilEditor'] . '"' . ',' . '"' . $value['PerfilEditor'] . '"' . ',' . '"' . $value['DepDescripcionActual'] . '"' . ',' . '"' . $value['DEPCodigoActual'] . '"' . ',' . '"' . $value['DEP_IdOrigen'] . '"' . ',' . '"' . $value['DepDescripcionOrigen'] . '"' . ',' . '"' . $value['DepCodigoOrigen'] . '"' . ',' . '"' . $value['DRE_Estado'] . '"' . ',' . '"' . $value['DRE_SubEstado'] . '"' . ',' . '"' . $value['DRE_UsuarioEdit'] . '"' . ',' . '"' . $value['DRE_FechaEdit'] . '"' . ',' . '"' . $value['DRE_AccionEdit'] . '"' . ',' . '"' . $value['REQ_Fechaedit'] . '"' . ',' . '"' . $value['ESR_DescripcionRequerimiento'] . '"' . ',' . '"' . $dias . '"' . ',' . '"' . $acciones . '"' . ',' . '"' . $atraso . '"]';
            //}
        }
    }else{
        //echo "no";
    }    

    sqlsrv_free_stmt( $stmt);
    sqlsrv_close( $conn);
    
    $dataRequerimientos='{"draw":"'.$draw.'","recordsTotal":"'.strval($contreg).'","recordsFiltered":"'.$recordsFiltered.'","sort":"'.$sort.'","data":['.$cadena.']}';
    
    //echo str_replace("],]","]]",$dataRequerimientos);
    echo $dataRequerimientos;
?>