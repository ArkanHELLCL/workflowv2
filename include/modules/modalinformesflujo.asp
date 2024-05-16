<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%	
	splitruta=split(ruta,"/")    
	xm=splitruta(5)
    DRE_Id=splitruta(7)
	if(xm="modificar") then
		modo=2	
		required="required"
	end if
	if(xm="visualizar") or (session("ds5_usrperfil")=5) then
		modo=4	
		required="disabled"
	end if		

    if(modo="") then
        modo=4
    end if
    if(IsNULL(DRE_Id) or DRE_Id="") then
        response.write("404\\ERROR: No fue posible encontrar registro de DatosRequerimiento")
        response.end()
    end if    
		
	columnsDefsInformesflujo="[]"
	response.write("200\\#informesflujoModal\\")%>
	<div class="modal-dialog cascading-modal narrower modal-full-height modal-bottom" role="document">
		<div class="modal-content">		
			<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
				<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-file-alt"></i> Informes</div>				
			</div>				
			<div class="modal-body" style="padding:0px;">
                <div id="frmInforme" class="px-4">
					
				</div>
				<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">											
					<div class="px-4">
						<div class="table-wrapper col-sm-12" id="container-table-informes">						
							<table id="tbl-Informesflujo" class="ts table table-striped table-bordered dataTable table-sm" data-id="Informesflujo" data-page="true" data-selected="true" data-keys="1"> 
								<thead> 
									<tr> 
										<th style="width:10px;">Id</th>
										<th>Descripción</th>								 
										<th>Creador</th>
										<th>Fecha</th>										
										<th style="width:100px;">Acciones</th>
									</tr> 
								</thead>					
								<tbody>					
								</tbody>
							</table>
						</div>
					</div>
				</div>
			</div>
			<!--body-->
			<div class="modal-footer">
				<div style="float:right;" class="btn-group" role="group" aria-label="">
					<button class="btn btn-default buttonExport btn-md waves-effect" data-toggle="tooltip" title="Exportar datos de la tabla" data-id="Informesflujo"><i class="fas fa-download ml-1"></i></button>
					<button type="button" class="btn btn-secondary btn-md waves-effect" data-dismiss="modal" data-toggle="tooltip" title="Salir"><i class="fas fa-sign-out-alt"></i></button>
				</div>					
			</div>		  
			<!--footer-->				
		</div>
	</div>
	<!--modal-dialogo-->	
	
<script>	
	$(document).ready(function() {				
		var ss = String.fromCharCode(47) + String.fromCharCode(47);
		var bb = String.fromCharCode(92) + String.fromCharCode(92);
		var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);
		var s  = String.fromCharCode(47);
		var b  = String.fromCharCode(92);		
				
		var InformesflujoTable;		
		var disabled={};
		var VPV_Id=0;
		var VCE_Id=0;
		var INF_Id=0;
				
		$("#informesflujoModal").on('shown.bs.modal', function(e){		
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			
			$("body").addClass("modal-open");			
			exportTable();
		});			
		
		$("#informesflujoModal").on('hidden.bs.modal', function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			
            //Modal de informe
            $("body").removeClass("modal-open")
			$("#frmInforme").css("height","0");
            $('#container-table-informes').animate({
				height: $('#container-table-informes').get(0).scrollHeight
			}, 700, function(){
				$(this).height('auto');
			});
            //Modal de informe			
			var data = {modo:<%=modo%>, DRE_Id:getparam(3)};            
			$.ajax( {
				type:'POST',					
				url: '/menu-flujo',
				data: data,
				success: function ( data ) {
					param = data.split(sas)
					if(param[0]==200){						
						$("#pry-menucontent").html(param[1]);
						moveMark(false);
					}else{
						swalWithBootstrapButtons.fire({
							icon:'error',								
							title: 'Ups!, no pude cargar el menú del requerimiento',					
							text:param[1]
						});				
					}
				},
				error: function(XMLHttpRequest, textStatus, errorThrown){					
					swalWithBootstrapButtons.fire({
						icon:'error',								
						title: 'Ups!, no pude cargar el menú del requerimiento',					
					});				
				}
			});
			
		});											
		
        function cerdis(e,VCE_Id,INF_Id,FLD_IdInforme){
            e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();            
			$.ajax({
				type:'POST',					
				url: '/certificado-disponibilidad',
				data:{VCE_Id:VCE_Id,INF_Id:INF_Id,FLD_IdInforme:FLD_IdInforme},
				success: function ( data ) {
					var param = data.split(ss)
					if(param[0]=="200"){
						$("#frmInforme").html(param[1]);
                        var titani = setInterval(function(){				
                            $("h5").slideDown("fast",function(){
                                $("h6").slideDown("fast",function(){
                                    clearInterval(titani)
                                });
                            })
                        },500);
                        //carga de tabla de imputaciones
                    }
                }
            })
        }

		function provid(e,VPV_Id,INF_Id,FLD_IdInforme){
            e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();            
			$.ajax({
				type:'POST',					
				url: '/providencia',
				data:{VPV_Id:VPV_Id,INF_Id:INF_Id,FLD_IdInforme:FLD_IdInforme},
				success: function ( data ) {
					var param = data.split(ss)
					if(param[0]=="200"){
						$("#frmInforme").html(param[1]);
                        var titani = setInterval(function(){				
                            $("h5").slideDown("fast",function(){
                                $("h6").slideDown("fast",function(){
                                    clearInterval(titani)
                                });
                            })
                        },500);
                        //carga de tabla de imputaciones
                    }
                }
            })
        }

        function muestramodalinforme(e,VCE_Id,VPV_Id,INF_Id,FLD_IdInforme,tipo){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			if(tipo===1){
				cerdis(e,VCE_Id,INF_Id,FLD_IdInforme);
			}
			if(tipo===2){
				provid(e,VPV_Id,INF_Id,FLD_IdInforme);
			}
			$("#btn_frmaddinforme").show();
			if($("#frmInforme").css("height")=="500px"){
				$("#frmInforme").css("height","0");								
				$('#container-table-informes').animate({
					height: $('#container-table-informes').get(0).scrollHeight
				}, 700, function(){
					$(this).height('auto');
				});				
				
			}else{								
				$("#frmInforme").css("height","500px");				
				$("#container-table-informes").css("height","0");				
			}
		}

        $("#informesflujoModal").on("click",".desinf",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
						
			var INF_Id = $(this).data("inf");			
		
			ajax_icon_handling('load','Buscando informes','','');
			$.ajax({
				type: 'POST',								
				url:'/listar-informes',				
				data:{INF_Id:INF_Id,DRE_Id:getparam(3)},
				success: function(data) {
					var param=data.split(bb);			
					if(param[0]=="200"){				
						ajax_icon_handling(true,'Listado de informes creado.','',param[1]);
						$(".swal2-popup").css("width","60rem");
						loadtables("#tbl-informesgenerados");
						$(".arcinf").click(function(){
							var INF_Arc = $(this).data("file");							
							var data = {INF_Id:INF_Id,DRE_Id:getparam(3),INF_Arc:INF_Arc};
							$.ajax({
								url: "/bajar-archivo",
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
		})

        $("#informesflujoModal").on("click",".geninf",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();

            var INF_Id = $(this).data("inf");
			var PRT_Informe = $(this).data("prt");
			var PRT_FileName = $(this).data("file");
			wrk_informes(PRT_Informe,PRT_FileName,<%=DRE_Id%>,INF_Id,InformesflujoTable,<%=session("wk2_usrid")%>,'<%=session("wk2_usrtoken")%>','<%=session("wk2_usrperfil")%>');
        })

        $("#informesflujoModal").on("click",".addcer, .modcer, .viscer, .visprv, .addprv",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();			
			            
            VCE_Id = $(this).data("vce");
			VPV_Id = $(this).data("vpv");
			INF_Id = $(this).data("inf");
			FLD_IdInforme = $(this).data("fld");
			if($(this).hasClass("addcer") || $(this).hasClass("viscer")){
				tipo=1;
			}
			if($(this).hasClass("addprv") || $(this).hasClass("visprv")){
				tipo=2;
			}
			muestramodalinforme(e,VCE_Id,VPV_Id,INF_Id,FLD_IdInforme,tipo);
		})

        $("#informesflujoModal").on("click","#btn_salirinformes",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();			
			
			if($("#frmInforme").css("height")=="500px"){				
				$("#frmInforme").css("height","0");				
				$('#container-table-informes').animate({
					height: $('#container-table-informes').get(0).scrollHeight
				}, 700, function(){
					$(this).height('auto');					
					var xtitani = setInterval(function(){                                
						InformesflujoTable.ajax.reload();
						clearInterval(xtitani)                                                            
					},2300);
				});				
			}			
		})	

		function exportTable(){
			$(".buttonExport").click(function(e){
				e.preventDefault();
				e.stopImmediatePropagation();
				e.stopPropagation();
				var idTable = $(this).data("id")
						
				const inputValue=idTable + '.csv';
				const { value: csvFilename } = swalWithBootstrapButtons.fire({
					icon:'info',
					title: 'Ingresa el nombre del archivo',
					input: 'text',
					inputValue: inputValue,
					showCancelButton: true,
					confirmButtonText: '<i class="fas fa-sync-alt"></i> Generar',
					cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar',
					inputValidator: (value) => {
					if (!value) {
					  return 'Debes escribir un nombre de archivo!';
					}
				  }
				}).then((result) => {
					if(result.value){				
						$('#tbl-'+idTable).exporttocsv({
							fileName  : result.value,
							separator : ';',
							table	  : 'dt'
						});				
					}

				});							
			});
		}		
								
		var InformesflujoTable;		
		loadTableImputaciones();
        $('#tbl-Informesflujo').css('width','100%')
		
		function loadTableImputaciones() {
			if($.fn.DataTable.isDataTable( "#tbl-Informesflujo")){				
				$('#tbl-Informesflujo').dataTable().fnClearTable();
    			$('#tbl-Informesflujo').dataTable().fnDestroy();
			}	
			
			InformesflujoTable = $('#tbl-Informesflujo').DataTable({				
				lengthMenu: [ 10,15,20 ],
				ajax:{
					url:"/listado-informe",
					type:"POST",					
                    data:{},
					complete: function(data){						
						$("i.pendiente").parents('td').css("background", "rgba(217, 83, 79, .3)");
                        $("i.generado").parents('td').css("background", "rgba(91, 192, 222, .3)");						
					}
				},				
				order: [
					[0, 'asc']
				],
				/*columnDefs:[
					{"targets": [ 4,7,10,13,16 ],"visible": false,"searchable": false},
					{"targets": [17],"width":"100px"}
				],*/
				autoWidth: false
			});						
		}
		
		$("body").append("<button id='btn_modalInformesflujo' name='btn_modalInformesflujo' style='visibility:hidden;width:0;height:0'></button>");
		$("#btn_modalInformesflujo").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			$("#informesflujoModal").modal("show");
			$("body").addClass("modal-open");
				
		});
		$("#btn_modalInformesflujo").click();
		$("#btn_modalInformesflujo").remove();
	})

	function getparam(id){
		var href = window.location.href;
		var newhref = href.substr(href.indexOf("/home")+6,href.length);
		var href_split = newhref.split("/")

		return href_split[id];			
	}
	
</script>