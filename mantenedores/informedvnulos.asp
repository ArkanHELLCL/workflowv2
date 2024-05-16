<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE file="session.min.inc" -->
<%
    perfil=session("wk2_usrperfil")
    depid=session("wk2_usrdepid")

    disabled="required"	
	if mode="add" then
		mode="mod"		
	end if	
	if(session("wk2_usrperfil")>2) then	'Solo Super y Adminsitrador puede modificar, el resto solo visualizar
		mode="vis"
		modo=4		
	end if	
	disabled="required"		
	if mode="mod" then
		modo=2
		
	end if
	if(session("wk2_usrperfil")=3 or session("wk2_usrperfil")=4) then
		mode="vis"
		modo=4
		disabled="readonly disabled"				
	end if	
	if mode="vis" then
		modo=4
		
	end if
				
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión:" & ErrMsg)
	   response.End() 			   
	end if
	
	lblClass=""
	if(mode="mod" or mode="vis") then		
		
		
	end if	

	response.write("200/@/")%>

	<h5>Informe de Devengos Nulos</h5>
    </br>
    </br>
    <div class="row">
        <div class="col align-self-end">
            <button type="button" class="btn btn-primary btn-md waves-effect waves-dark buttonExport" style="float: right;"><i class="fas fa-file-excel"></i>  Descargar Informe</button>
        </div>
    </div>
	<div class="row">
        <div class="col-12">
            <table id="tbldvnulos" class="ts table table-striped table-bordered dataTable table-sm" cellspacing="0" data-id="">
			    <thead>
                    <th>Id.</th>
                    <th>Req.</th>
                    <th>Descripción</th>
                    <th>Fecha</th>
                    <th>Usuario</th>
                    <th>Estado</th>
                    <th>Estado Req.</th>
                    <th>Estado Doc.</th>
                    <th>Usuario</th>
                    <th>Fecha</th>
                    <th>Flujo</th>
                    <th>V.Flujo</th>
                    <th>V.Form</th>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
    </div>
        
	
	<div class="row">
		<div class="footer">		
		</div>
	</div>
	
<script>
	$(document).ready(function() {		
        var ss = String.fromCharCode(47) + String.fromCharCode(47);
        var s = String.fromCharCode(47);
        var bb = String.fromCharCode(92) + String.fromCharCode(92);
        var b = String.fromCharCode(92);
        var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);			
		var infdiasusrTable;
		var titani = setInterval(function(){
			$("h5").slideDown("slow",function(){
				$("h6").slideDown("slow",function(){
					clearInterval(titani)
				});
			})
		},2300);

		$(function () {
			$('[data-toggle="tooltip"]').tooltip({
				trigger : 'hover'
			})
			$('[data-toggle="tooltip"]').on('click', function () {
				$(this).tooltip('hide')
			})		
		});

        var dvnulosTabla = $('#tbldvnulos').DataTable({
            lengthMenu: [ 10,15,20 ],
            stateSave: true,
            processing: true,
            serverSide: true,
            ajax:{
                url:"/devengos-nulos-listar",
                type:"POST",					
                dataSrc:function(json){
                    return json.data;                    
                },
                error:function(){
                    console.log("Error en el proceso");
                }
            },	
            columnDefs: [
                {
                "targets": [5,9,10],
                "visible": false,
                "searchable": false,
                }
            ],
            /*dom: 'lBfrtip',
            	buttons: [					
					$.extend( true, {}, buttonCommon, {
						extend: 'excelHtml5'
					} ),					
				],*/
            autoWidth: false,                
            fnRowCallback: function( nRow, aData, iDisplayIndex, iDisplayIndexFull ) {                    
                if(<%=perfil%><=2 || <%=depid%>===48){
                    $(nRow).click(function(e){
                        e.preventDefault();
                        e.stopImmediatePropagation();
                        e.stopPropagation();						
                        //console.log($(nRow).find("td").eq(5))                        
                        var REQ_Id = aData[1];
                        var REQ_Descripcion = aData[2];
                        var REQ_Estado = aData[5];
                        var REQ_EstadoDescripcion = aData[6];

                        //console.log(REQ_Id, REQ_Descripcion, REQ_Estado)
                        swalWithBootstrapButtons.fire({
                            icon:'info',
                            title: 'Actualizar Folio Devengo vacio',
                            text: 'Ingresa Folio Devengo para el requerimiento:' + REQ_Id + ' - ' + REQ_Descripcion,
                            //input: 'number',
                            //inputValue: "",
                            html: `<form id="frmfoliodv"><div class="row"><div class="col-12"><input type="number" id="folioDV" name="folioDV" class="swal2-input form-control" placeholder="Folio DV" style="max-width: 100%;"></div><div class="col-12"><input type="text" id="adjuntoDVX" name="adjuntoDVX" class="swal2-input form-control" placeholder="Adjunto"><input type="file" id="adjuntoDV" name="adjuntoDV" readonly="" multiple accept="image/png,image/x-png,image/jpg,image/jpeg,image/gif,application/x-msmediaview,application/vnd.openxmlformats-officedocument.presentationml.presentation,	application/vnd.openxmlformats-officedocument.wordprocessingml.document,application/pdf, application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/msword,application/vnd.ms-powerpoint" style="display: none;width: 0;height: 0;"></div></div></form>`,
                            
                            showCancelButton: true,
                            confirmButtonText: '<i class="fas fa-check"></i> Actualizar Folio DV',
                            cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar',
                            focusConfirm: false,
                            preConfirm: () => {
                                const folioDV = Swal.getPopup().querySelector('#folioDV').value
                                const adjuntoDV = Swal.getPopup().querySelector('#adjuntoDV').value
                                if (!folioDV || !adjuntoDV) {
                                    Swal.showValidationMessage(`Debes ingresar un Folio númerico y adjuntar un archivo`)
                                }
                                return { folioDV: folioDV, adjuntoDV: adjuntoDV }
                            }                            							
                        }).then((result) => {
                            if(result.value){
                                FolioDV = result.value.folioDV;
                                adjuntoDV = result.value.adjuntoDV;

                                var formdata = new FormData();
                                var data = $("#frmfoliodv").serializeArray();
                                var file_data;
                                var file_name;
                                
                                file_name = $("#adjuntoDV");                                
                                file_data = $(file_name).prop('files');                                
                                if(file_data!=undefined){                                                			
                                    for (var i = 0; i < file_data.length; i++) {
                                        formdata.append(file_data[i].name, file_data[i])                                
                                    }
                                }else{
                                    //formdata.append(item, "0")
                                }                                                                                        
                                $.each(data, function(i, field) { 
                                    formdata.append(field.name,field.value);                                    
                                });
                                formdata.append("VRE_Id",REQ_Id);

                                var text
                                if(REQ_Estado == 7){
                                    text = "Al aceptar esta acción se actualizará el folio devengo vacio del requerimiento: " + REQ_Id + " - " + REQ_Descripcion + " a: " + FolioDV + '. El requerimiento quedará en estado pendiente de cierre para su aprobación final.'
                                }else{
                                    text = "Al aceptar esta acción se actualizará el folio devengo vacio del requerimiento: " + REQ_Id + " - " + REQ_Descripcion + " a: " + FolioDV
                                }
                                swalWithBootstrapButtons.fire({
                                    title: '¿Estas seguro?',
                                    text: text,
                                    icon: 'warning',
                                    showCancelButton: true,
                                    confirmButtonColor: '#3085d6',
                                    cancelButtonColor: '#d33',
                                    confirmButtonText: '<i class="fas fa-thumbs-up"></i> Si, Actualizar!',
                                    cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar'
                                    }).then((result) => {
                                        if (FolioDV && adjuntoDV) {                                            
                                            $.ajax( {
                                                type:'POST',					
                                                url: '/devengos-nulos-actualizar',                                                
                                                data: formdata,
                                                enctype: 'multipart/form-data',
                                                cache: false,
                                                contentType: false,
                                                processData: false,
                                                dataType:"json",
                                                success: function ( json ) {                                                    
                                                    if(json.data[0].code=="200"){                                                        
                                                        Toast.fire({
                                                            icon: 'success',
                                                            title: 'Se ha modificado el Folio Devengo del requerimiento nro.: ' + REQ_Id
                                                        });
                                                        dvnulosTabla.ajax.reload();
                                                    }
                                                },
                                                error: function(XMLHttpRequest, textStatus, errorThrown){

                                                },
                                                complete: function(){
                                                    dvnulosTabla.ajax.reload();   
                                                }
                                            });                                            
                                        }else{
                                            Toast.fire({
                                                icon: 'error',
                                                title: 'Se ha cancelado la actualización del Folio Devengo'
                                            });			
                                        }
                                    })
                            }else{
                                Toast.fire({
                                    icon: 'error',
                                    title: 'Se ha cancelado la actualización del Folio Devengo'
                                });			
                            }
                        })
                    
                });
                }
            }
        });        

        $(".buttonExport").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();			
			var idTable = $(this).data("id");
			var FLU_Id = $(this).data("flu");			
			var Tipo = $(this).data("tpo");
            var columns;
            columns = ["Id","Nro. Req.","Descripción","Fecha","Usuario","Id.Est.Req.","Estado Req.","Estado Doc.","Usuario","Fecha Mod.","Flujo","V.Flujo","V.Form"]

			wrk_informesgenerales("/prt-devengodnulos","/wrk-informesgenerales",'devengosnulos', columns, null, null, null, '<%=session("wk2_usrid")%>','<%=session("wk2_usrtoken")%>');            
		});
        
		$("body").on("click", "#adjuntoDVX",function(e){
            e.preventDefault();
            e.stopImmediatePropagation();
            e.stopPropagation();
            $("#adjuntoDV").click();
        })

        $("body").on("change", "#adjuntoDV",function(click){        
            click.preventDefault();
            click.stopImmediatePropagation();
            click.stopPropagation();
            var fakepath_1 = "C:" + ss + "fakepath" + ss
            var fakepath_2 = "C:" + bb + "fakepath" + bb
            var fakepath_3 = "C:" + s + "fakepath" + s
            var fakepath_4 = "C:" + b + "fakepath" + b	

            var cont = 0;
            var doc,docN;
            var separ="; "
            $.each (this.files,function(e){
                cont = cont +1;					
                docN = this.name.replace(fakepath_4,"") 
                if(cont==1){												
                    doc = docN
                }else{
                    doc = doc + separ + docN;
                }					
                $("#adjuntoDVX").val(doc);					
            });
            //console.log(this.files)
        })
	});
</script>