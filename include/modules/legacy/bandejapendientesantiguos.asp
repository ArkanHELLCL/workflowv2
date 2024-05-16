<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<%
titulo="Requerimientos Pendientes Antiguos"
gradiente="aqua-gradient"
color="darkblue-text"

set cnn = Server.CreateObject("ADODB.Connection")
on error resume next	
cnn.open session("DSN_WorkFlowv2")
if cnn.Errors.Count > 0 then 
    ErrMsg = cnn.Errors(0).description	   
    cnn.close
    response.Write("503/@/Error Conexión:" & ErrMsg)
    response.End() 			   
end if
response.write("200/@/")
%>
<div class="row container-header">

</div>
<div class="row container-body mCustomScrollbar">    
	<!--container-nav-->
	<div class="container-nav">
		<div class="header">				
			<div class="content-nav"><%
                sql="exec spFlujo_Listar  1"
                set rs = cnn.Execute(sql)
                bandeja=false
                do while not rs.eof
                    if rs("FLU_BandejaAntiguos")=1 then%>
				        <a id="sispentab<%=rs("FLU_Id")%>-tab" href="#sispentab<%=rs("FLU_Id")%>" class="active tab" data-sis="<%=rs("FLU_Id")%>"><i class="fas fa-sitemap"></i> Flujo <%=rs("FLU_Descripcion")%></a><%
                    end if
                    rs.movenext
                loop%>
				<span class="yellow-bar"></span>				
			</div>				
		</div>
	
		<!--tab-content-->
		<div class="tab-content"><%
            rs.movefirst
            do while not rs.eof
                if rs("FLU_BandejaAntiguos")=1 then%>
                    <div id="sispentab<%=rs("FLU_Id")%>" data-sis="<%=rs("FLU_Id")%>">
                        <!--wrapper-editor-->
                        <div class="wrapper-editor">                    						
                            <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
                                <!-- Table with panel -->					
                                <div class="card card-cascade narrower">
                                    <!--Card image-->
                                    <div class="view view-cascade gradient-card-header <%=gradiente%> narrower py-2 mx-4 mb-3 d-flex justify-content-between align-items-center">
                                        <div>									
                                        </div>
                                        <a href="" class="<%=color%> mx-3"><i class="fas fa-book"></i> Requerimientos Pendientes</a>
                                        <div>
                                        </div>                                
                                    </div>
                                    <!--/Card image-->
                                    <div class="px-4">
                                        <div class="table-wrapper col-sm-12 mCustomScrollbar" id="container-table-1">
                                            <!--Table-->										
                                            <table id="tblreqpen-<%=rs("FLU_Id")%>" class="ts table table-striped table-bordered dataTable table-sm" cellspacing="0" data-id="<%=rs("FLU_Id")%>" style="width:99%">
                                                <thead>
                                                    <tr>													
                                                        <th>#</th>
                                                        <th>Ver.</th>
                                                        <th>Descripción Versión Requerimiento</th>													
                                                        <th>#Req.</th>
                                                        <th>Req.Identificador</th>
                                                        <th>Requerimiento</th>													
                                                        <th>Id.Estado Requerimiento</th>
                                                        <th>Subestado</th>													
                                                        <th>Id Versión Flujo Formulario</th>
                                                        <th>V.FLujo</th>
                                                        <th>Id Flujo</th>													
                                                        <th>Flujo</th>												
                                                        <th>Año</th>
                                                        <th>V.Form.</th>
                                                        <th>Id Formulario</th>
                                                        <th>Descripción Formulario</th>													
                                                        <th>Id.Creador</th>													
                                                        <th>Creador</th>
                                                        <th>Id Perfil Creadorr</th>
                                                        <th>Descripción Perfil Creador</th>													
                                                        <th>Id Editor</th>
                                                        <th>Editor</th>
                                                        <th>Id.Perfil Editor</th>
                                                        <th>Descripcion Perfil Editor</th>
                                                        <th>Id Dependencia Actual</th>
                                                        <th>Dep. Editor</th>
                                                        <th>Id Dependencia Padre Actual</th>
                                                        <th>Id Dependencia Origen</th>
                                                        <th>Dep. Creación</th>
                                                        <th>Id Dependencia Padre Origen</th>													
                                                        <th>Estado Registro</th>
                                                        <th>Sub Estado del registro</th>
                                                        <th>Usuario Creador Registro</th>
                                                        <th>Última Actualización</th>
                                                        <th>Acción realizada</th>
                                                        <th>Creación Requerimiento</th>
                                                        <th>Estado</th>
                                                        <th>Dias</th>
                                                        <th>Acciones</th>
                                                        <th>Atraso</th>
                                                        <th>Paso</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <!-- Table with panel -->		
                            </div>	  
                        </div>
                        <!--wrapper-editor-->
                    </div><%
                end if
                rs.movenext
            loop%>
		</div>
		<!--tab-content-->
	</div>
	<!--container-nav-->	
</div>
<!-- Formulario workflowv1 -->
<div class="modal fade in" id="formularioWorkFlowPenv1" tabindex="-1" role="dialog" aria-labelledby="formularioWorkFlowPenv1" aria-hidden="true">
	<div class="modal-dialog cascading-modal narrower modal-lg" role="document" style="max-height:600px">  		
    	<div class="modal-content">		
      		<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
        		<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-user"></i> Datos del formulario (WorkFlowv1)</div>				
      		</div>
			<form role="form" action="" method="POST" name="frmbtn_workflowpenv1" id="frmbtn_workflowpenv1" class="needs-validation" style="overflow-y:auto;max-height: 600px;">
			</form>
		</div>
	</div>
</div>
<!-- Formulario workflowv1 -->
<!-- Datos workflowv1 -->
<div class="modal fade in" id="datosWorkFlowPenv1" tabindex="-1" role="dialog" aria-labelledby="datosWorkFlowPenv1" aria-hidden="true">
	<div class="modal-dialog cascading-modal narrower modal-lg" role="document" style="max-height:600px">  		
    	<div class="modal-content">		
      		<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
        		<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-user"></i> Datos del requerimeinto (WorkFlowv1)</div>				
      		</div>
			<form role="form" action="" method="POST" name="frmbtn_datosWorkFlowPenv1" id="frmbtn_datosWorkFlowPenv1" class="needs-validation" style="overflow-y:auto;max-height: 600px;">
			</form>
		</div>
	</div>
</div>
<!-- Datos workflowv1 -->
<script>
//bandeja antiguos pendientes
    $(function () {
		$('[data-toggle="tooltip"]').tooltip({
			trigger : 'hover'
		})
		$('[data-toggle="tooltip"]').on('click', function () {
			$(this).tooltip('hide')
		})		
	});
    $(document).ready(function() {
        var b = String.fromCharCode(92);
		var bb = String.fromCharCode(92) + String.fromCharCode(92);
		var ss = String.fromCharCode(47) + String.fromCharCode(47);	
		var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);		        

		$(".mCustomScrollbar").mCustomScrollbar({
			theme:scrollTheme,
			advanced:{
				autoExpandHorizontalScroll:true,
				updateOnContentResize:true,
				autoExpandVerticalScroll:true,
				scrollbarPosition:"outside"
			},
            //axis:"yx"
		});	
		
        var requerimientosWorkFlowv1Table;

		function tableRequerimientos(FLU_Id){            
			$("#tblreqpen-" + FLU_Id).dataTable().fnDestroy();
			requerimientosTable = $('#tblreqpen-' + FLU_Id).DataTable({
				lengthMenu: [ 10,15,20 ],
                stateSave: true,
				processing: true,
        		serverSide: true,
				ajax:{
					url:"/requerimientos-pendientes-antiguos", 
                    data:{FLU_Id:FLU_Id},
					type:"POST",					
					dataSrc:function(json){					
						return json.data;					
					}
				},
                dom: 'lBfrtip',
            	buttons: [					
					$.extend( true, {}, buttonCommon, {
						extend: 'excelHtml5',                        
					}),					
				],
				columnDefs: [{
					"targets": [2,4,6,8,10,11,14,15,16,18,19,20,22,23,24,26,27,29,30,31,32,34,39,40],
					"visible": false,
					"searchable": false,
					},{
					"targets": [0,2,3,6,9,12,15,18],"width":"20px"					
					},{
					"targets": [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40],
					"orderable": false
					},{
                    "targets": [5],"width":"300px"
                    }
				],
				autoWidth: false,
				fnRowCallback: function( nRow, aData, iDisplayIndex, iDisplayIndexFull ) {					
					$("td:not(:last)",nRow).click(function(e){
						e.preventDefault();
						e.stopImmediatePropagation();
						e.stopPropagation();						
						
						var Req_cod=aData[0];
                        var FrD_Cor=aData[13];
                        var For_Cod=aData[14];
                        var For_Cor=aData[8];
                        var VFL_Id=aData[9];
                        var FLU_CodPas=aData[40];

                        var url='/formulario-pendientes-workflowv1'
                        var frmid="#frmbtn_workflowpenv1"
                        var modalid="#formularioWorkFlowPenv1"

						$.ajax( {
							type:'POST',					
							url: url,
							data: {Req_cod:Req_cod, FrD_Cor:FrD_Cor, For_Cod:For_Cod, For_Cor:For_Cor,VFL_Id:VFL_Id,FLU_CodPas:FLU_CodPas},
							success: function ( data ) {
								param = data.split(sas)
								if(param[0]==200){
                                    
									$(frmid).html(param[1]);
									$(modalid).modal("show")
								}
							},
							error: function(XMLHttpRequest, textStatus, errorThrown){

							}
						});	
                        
					});
					
				}
			});
		}	

        $("#formularioWorkFlowPenv1").on("click","#btn_wrkpenfinalizar",function(e){
            e.preventDefault();
            e.stopImmediatePropagation();
            e.stopPropagation();

            formValidate("#frmbtn_workflowpenv1")
			if($("#frmbtn_workflowpenv1").valid()){
                swalWithBootstrapButtons.fire({
                    title: '¿Quieres Finalizar este Requerimiento?',
                    text: "Este requerimiento es de una versión anterior por lo que al cerrarlo solo podrás visualizarlo en le bandeja de requerimientos antiguos.",
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: '<i class="fas fa-thumbs-up"></i> Finalizar',
                    cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar'
                }).then((result) => {
                    if (result.value) {
                        $.ajax( {
                            type:'POST',
                            url: "/finaliza-requerimiento-boletas-v1",
                            data: {Req_Cod:$("#Req_codBoletas").val(),FrD_Data:$("#FrD_DataBoletas").val()},
                            success: function ( data ) {
                                param = data.split(sas)
                                if(param[0]==200){                        
                                    requerimientosTable.ajax.reload();
                                    console.log("1")
                                    $("#formularioWorkFlowPenv1").modal("hide");
                                    Toast.fire({
                                        icon: 'success',
                                        title: 'Finalización del requerimiento exitosa'
                                    });			
                                }
                            },
                            error: function(XMLHttpRequest, textStatus, errorThrown){

                            }
                        })
                    }
                })
            }
        });

		$(".content-nav").tabsmaterialize({},function(){
           var FLU_Id = $(this.toString()).data("sis");
					
			if ( ! $.fn.DataTable.isDataTable( '#tblreq-' + FLU_Id ) ) {
				tableRequerimientos(FLU_Id)
                console.log("2")
			}else{
				requerimientosTable.ajax.reload();
                console.log("3")
			}			
		});	

        jQuery.fn.DataTable.Api.register( 'buttons.exportData()', function ( options ) {            
            if ( this.context.length ) {
                var tableid=this.context[0].sTableId;                
				var row = [];
                var FLU_Id = 2;
                console.log(this.context)
                var jsonResult = $.ajax({
                    url:"/requerimientos-pendientes-antiguos",
                    data:{FLU_Id:FLU_Id},
                    success: function (result) {
                        //Do nothing
                    },
                    async: false,
					type:"POST"
                });				
				$("#"+tableid).DataTable().columns().header().each(function(e,i){
					row.push(e.innerText.replace(/(\r\n|\n|\r)/gm, ""))
				});                
				return {body: JSON.parse(jsonResult.responseText).data, header: row};
            }
        } );
		var buttonCommon = {
			exportOptions: {
				format: {
					body: function ( data, row, column, node ) {
						// Strip $ from salary column to make it numeric
						//nothing
					}
				}
			}
		};

        $('body').on('click','.dowadj', function () {
            var INF_Arc;
            var SIS_Id;
            var arc;
            INF_Arc = $(this).data("arc");
            SIS_Id = $(this).data("sis");
            arc = INF_Arc.split('/');            
            $.ajax({
                url: '/bajar-archivo',
                data:{INF_Arc:INF_Arc, SIS_Id:SIS_Id},
                method: 'POST',
                xhrFields: {
                    responseType: 'blob'
                },
                success: function (data) {
                    var a = document.createElement('a');
                    var url = window.URL.createObjectURL(data);
                    a.href = url;
                    a.download = arc[1];
                    document.body.append(a);
                    a.click();
                    a.remove();
                    window.URL.revokeObjectURL(url);
                }
            });
        });

        $('body').on('click','.reqdata', function () {
            var Req_cod;                        
            Req_cod = $(this).data("req");                        

            $.ajax( {
                type:'POST',					
                url: "/datos-workflowv1",
                data: {Req_cod:Req_cod},
                success: function ( data ) {
                    param = data.split(sas)
                    if(param[0]==200){                        
                        $("#frmbtn_datosWorkFlowPenv1").html(param[1]);
			            $("#datosWorkFlowPenv1").modal("show")
                    }
                },
                error: function(XMLHttpRequest, textStatus, errorThrown){

                }
            });	            
        });

        $('body').on('click','.downcer', function () {
            var Req_cod;                        
            Req_cod = $(this).data("req");            
            $.ajax( {
                type:'POST',					
                url: "/genera-informe-pdf-legacy",
                data: {Req_cod:Req_cod, INF_Id:1},
                success: function ( data ) {
					var param = data.split(sas)
					if(param[0]=="200"){						
                        $("body").append("<div id='pry-reportpdf'></div>")							
                        $("#pry-reportpdf").html(param[1]);
                        //$("#pry-reportpdf").remove();
                        ajax_icon_handling('load','Buscando informes','','');
                        var waitfld = setInterval(function(){                            
                            $.ajax({
                                type: 'POST',								
                                url:'/lista-informes-legacy',				
                                data:{INF_Id:1,Req_cod:Req_cod},
                                success: function(data) {
                                    var param=data.split(bb);			
                                    if(param[0]=="200"){				
                                        ajax_icon_handling(true,'Listado de informes creado.','',param[1]);
                                        $(".swal2-popup").css("width","60rem");
                                        loadtables("#tbl-" + param[1]);
                                        $(".arcinf").click(function(){
                                            var INF_Arc = $(this).data("file");							
                                            var data = {INF_Id:1,Req_cod:Req_cod,INF_Arc:INF_Arc};
                                            
                                            $.ajax({
                                                url: "/bajar-archivo-legacy",
                                                method: 'POST',
                                                data:data,
                                                xhrFields: {
                                                    responseType: 'blob'
                                                },
                                                success: function (data) {
                                                    var a = document.createElement('a');
                                                    var url = window.URL.createObjectURL(data);
                                                    a.href = url;
                                                    a.download = INF_Arc;
                                                    document.body.append(a);
                                                    a.click();
                                                    a.remove();
                                                    window.URL.revokeObjectURL(url);
                                                }
                                            });	
                                            
                                        })
                                    }else{
                                        ajax_icon_handling(false,'No fue posible crear el listado de informes.','','');
                                    }						
                                },
                                error: function(XMLHttpRequest, textStatus, errorThrown){				
                                    ajax_icon_handling(false,'No fue posible crear el listado de informes.','','');	
                                },
                                complete: function(){																		
                                }
                            })
                            clearInterval(waitfld)
                        },3000)
                    }
                },
                error: function(XMLHttpRequest, textStatus, errorThrown){

                }
            });	              
        });

        $('body').on('click','.downdoc', function () {
            var Req_cod;                        
            Req_cod = $(this).data("req");
            var INF_Id = $(this).data("inf");
            $.ajax( {
                type:'POST',					
                url: "/genera-informe-pdf-legacy",
                data: {Req_cod:Req_cod, INF_Id:INF_Id},
                success: function ( data ) {
					var param = data.split(sas)
					if(param[0]=="200"){						
                        $("body").append("<div id='pry-reportpdf'></div>")							
                        $("#pry-reportpdf").html(param[1]);
                        $("#pry-reportpdf").remove();
                        ajax_icon_handling('load','Buscando informes','','');
                        var waitfld = setInterval(function(){                            
                            $.ajax({
                                type: 'POST',								
                                url:'/lista-informes-legacy',				
                                data:{INF_Id:INF_Id,Req_cod:Req_cod},
                                success: function(data) {
                                    var param=data.split(bb);			
                                    if(param[0]=="200"){				
                                        ajax_icon_handling(true,'Listado de informes creado.','',param[1]);
                                        $(".swal2-popup").css("width","60rem");
                                        loadtables("#tbl-" + param[1]);
                                        $(".arcinf").click(function(){
                                            var INF_Arc = $(this).data("file");							
                                            var data = {INF_Id:INF_Id,Req_cod:Req_cod,INF_Arc:INF_Arc};
                                            
                                            $.ajax({
                                                url: "/bajar-archivo-legacy",
                                                method: 'POST',
                                                data:data,
                                                xhrFields: {
                                                    responseType: 'blob'
                                                },
                                                success: function (data) {
                                                    var a = document.createElement('a');
                                                    var url = window.URL.createObjectURL(data);
                                                    a.href = url;
                                                    a.download = INF_Arc;
                                                    document.body.append(a);
                                                    a.click();
                                                    a.remove();
                                                    window.URL.revokeObjectURL(url);
                                                }
                                            });	
                                            
                                        })
                                    }else{
                                        ajax_icon_handling(false,'No fue posible crear el listado de informes.','','');
                                    }						
                                },
                                error: function(XMLHttpRequest, textStatus, errorThrown){				
                                    ajax_icon_handling(false,'No fue posible crear el listado de informes.','','');	
                                },
                                complete: function(){																		
                                }
                            })
                            clearInterval(waitfld)
                        },3000)
                    }
                },
                error: function(XMLHttpRequest, textStatus, errorThrown){

                }
            });	              
        });
    })
</script>