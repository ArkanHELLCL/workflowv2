var host	= window.location.hostname;
var count	= 1;
var theme	= 'cupertino';
var scrollbarTheme = 'inset-3';
var bootstrapTheme = 'bootstrap.min.css';
var changedata=false;
var wf='';
var modos=[undefined,"agregar","modificar",undefined,"visualizar"];
var pinmenu = false;
var firsttimenu = true;
var paramUrlFile = "";
var objFileupdate ={};
var error = false;
var scrollTheme = 'dark-thin';
var activeWorkers = [];

if (darkmode()){
	wf='waves-dark';
	scrollTheme = 'light-thin'
}

const Toast = Swal.mixin({
  toast: true,
  position: 'top-end',
  showConfirmButton: false,
  timer: 3000,
  timerProgressBar: true,
  onOpen: (toast) => {
    toast.addEventListener('mouseenter', Swal.stopTimer)
    toast.addEventListener('mouseleave', Swal.resumeTimer)
  }
})
const swalWithBootstrapButtons = Swal.mixin({
  customClass: {
    confirmButton: 'btn btn-primary btn-md waves-effect ' + wf,
    cancelButton: 'btn btn-secondary btn-md waves-effect '	+ wf	
  },
  buttonsStyling: false
})

//datatable
$.extend( true, $.fn.dataTable.defaults, {
    //"searching": false,
    //"ordering": false
	"language": {
		"lengthMenu": "Mostrando _MENU_ registros",
		"zeroRecords": "Sin coincidencia",
		//"info": "Mostrando del _PAGE_ de _PAGES_",
		"info": "Mostrando del _START_ al _END_ de _TOTAL_ registros",
		"infoEmpty": "No hay registros",
		"infoFiltered": "(Filtrado por _MAX_ registros máximo)",
		
		"decimal":        ",",
		"emptyTable":     "Tabla sin datos",						
		"infoPostFix":    "",
		"thousands":      ".",		
		"loadingRecords": "Leyendo...",
		"processing":     "Procesando...",
		"search":         "Buscar:",		
		"paginate": {
			"first":      "Primero",
			"last":       "Último",
			"next":       "Siguiente",
			"previous":   "Anterior"
		},
		"aria": {
			"sortAscending":  ": activar para oderden ascendente",
			"sortDescending": ": activar para oderden descendente"
		}
	}
	
} );
//calendario
jQuery(function($){
	$.datepicker.regional['es'] = {
		closeText: 'Cerrar',
		prevText: '&#x3c;Ant',
		nextText: 'Sig&#x3e;',
		currentText: 'Hoy',
		monthNames: ['Enero','Febrero','Marzo','Abril','Mayo','Junio',
		'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'],
		monthNamesShort: ['Ene','Feb','Mar','Abr','May','Jun',
		'Jul','Ago','Sep','Oct','Nov','Dic'],
		dayNames: ['Domingo','Lunes','Martes','Mi&eacute;rcoles','Jueves','Viernes','S&aacute;bado'],
		dayNamesShort: ['Dom','Lun','Mar','Mi&eacute;','Juv','Vie','S&aacute;b'],
		dayNamesMin: ['Do','Lu','Ma','Mi','Ju','Vi','S&aacute;'],
		weekHeader: 'Sm',
		//dateFormat: 'dd-mm-yy',
		//dateFormat: 'yy-M-D',
		dateFormat: 'yy-mm-dd',
		firstDay: 1,
		isRTL: false,
		showMonthAfterYear: false,
		yearSuffix: '',
		changeYear: true,
		changeMonth: true,
		yearRange: '-100:+2',
		timeFormat:  "hh:mm:ss"
		};
	$.datepicker.setDefaults($.datepicker.regional['es']);
});    

function blink(id)
{
	$(id).fadeTo(100, 0.1).fadeTo(200, 1.0);
}
$.validator.setDefaults( {
	submitHandler: function (e) {		
		$.ajax({
			type: 'POST',
			url:$(e).attr('action'),			
			data:$(e).serialize(),
			success: function(data) {
				var param=data.split("/@/");									
				if(param[0]=="200"){					
					changedata=false;
					swalWithBootstrapButtons.fire({
					  icon: 'success',					  
					  title: param[1],					  
					  text: param[2]
					  //footer: '<a href>Why do I have this issue?</a>'
					});
					$("#camPassModal").modal("hide");					
				}else{
					if(parseInt(param[0])<200){
						swalWithBootstrapButtons.fire({
						  icon: 'error',
						  title: 'Oops...',
						  text: param[1],
						  //footer: '<a href>Why do I have this issue?</a>'
						});						
					}else{
						errors(param[0]);
					}					
				}				
			},
			error: function(XMLHttpRequest, textStatus, errorThrown){				
				//Swal.fire({
				swalWithBootstrapButtons.fire({
				  icon: 'error',
				  title: 'Oops...',
				  text: 'Hubo un problema al procesar la llamada.',
				  //footer: '<a href>Why do I have this issue?</a>'
				})		
			},
			complete: function(){						
				
			}
		});
		//Fin ajax		
	}
} );
function smooth(e,id){
	var clase = 'ripple' + id;
	if($(e).find('.' + clase).length === 0) {
		$(e).append('<span class="' + clase + '"></span>');
	}
	var ripple = $(e).find('.' + clase);
	eWidth = $(e).outerWidth() + 10;
	eHeight = $(e).outerHeight() + 10;
	size = Math.max(eWidth, eHeight);		
	ripple.css({'width': size, 'height': size});		
	ripple.css({'top':'-5px', 'left':'-5px'});
	ripple.addClass('animated');		
	var timerSmooth = setTimeout(function () {
		ripple.removeClass('animated');
		clearTimeout(timerSmooth);
	}, 400);

}
function round(value, precision) {
    var multiplier = Math.pow(10, precision || 0);
    return Math.round(value * multiplier) / multiplier;
}

function loadtables(id,data,columns){
	$(".table").removeClass("table-dark");

	if ($("body").hasClass("bootstrap-dark")){
		theme='ui-darkness';
		$(".table").addClass("table-dark");
	}			
}
function cargacomponente(target,data,content, callback){
	var xtarget=target.replace(/[.]/gi,'/')
	error=false;
	if(content==undefined || content==""){
		content="#contenbody";
	}
	changedata=false;
	$.ajax({
		type: 'POST',								
		url:xtarget,			
		data:data,
		success: function(data) {
			var param=data.split("/@/");									
			if(param[0]=="200"){				
				$(content).html(param[1]);
							
				if (typeof callback == 'function') { // make sure the callback is a function
					//callback.call({"response":"ok"}); // brings the scope to the callback
					//const myTimeout = setTimeout(callback(), 1000);
					//clearTimeout(myTimeout)
					callback()
				}			
		
			}else{
				errors(param[0],content);
			}								
		},
		error: function(XMLHttpRequest, textStatus, errorThrown){				
			$(content).load("/error404");			
			//$('#loading-image').fadeOut(200);
		},
		complete: function(){}
	});
}
function iniButtonsActions(){
	if(darkmode()){
		if($(".card").hasClass("modificar")){
			$(".card.modificar .card-header").removeClass("bg-warning border-warning");
			$(".card.modificar .card-header").removeClass("text-white");
			$(".card.modificar .card-header").removeClass("border-warning");
			$(".card.modificar .card-footer").removeClass("text-warning");
			$(".card.modificar .card-body").removeClass("bg-light");
			$(".card.modificar .card-footer").removeClass("bg-light border-warning");
			$(".card.modificar .card-header button.close").removeClass("text-white");

			$(".card.modificar").addClass("bg-dark text-warning border-warning");
			$(".card.modificar .card-header").addClass("border-warning");
			$(".card.modificar .card-header button.close").addClass("text-warning");
			
			
		}				
		if($(".card").hasClass("agregar")){
			$(".card.agregar .card-header").removeClass("bg-success border-success");
			$(".card.agregar .card-header").removeClass("text-white");
			$(".card.agregar .card-header").removeClass("border-success");
			$(".card.agregar .card-footer").removeClass("text-success");
			$(".card.agregar .card-body").removeClass("bg-light");
			$(".card.agregar .card-footer").removeClass("bg-light border-success");
			$(".card.agregar .card-header button.close").removeClass("text-white");

			$(".card.agregar").addClass("bg-dark text-success border-success");	
			$(".card.agregar .card-header").addClass("border-success");
			$(".card.agregar .card-header button.close").addClass("text-success");
		}
		if($(".card").hasClass("visualizar")){
			$(".card.visualizar .card-header").removeClass("bg-primary border-primary");
			$(".card.visualizar .card-header").removeClass("text-white");
			$(".card.visualizar .card-header").removeClass("border-primary");
			$(".card.visualizar .card-footer").removeClass("text-primary");
			$(".card.visualizar .card-body").removeClass("bg-light");
			$(".card.visualizar .card-footer").removeClass("bg-light border-primary");
			$(".card.visualizar .card-header button.close").removeClass("text-white");

			$(".card.visualizar").addClass("bg-dark text-primary border-primary");	
			$(".card.visualizar .card-header").addClass("border-primary");
			$(".card.visualizar .card-header button.close").addClass("text-primary");
		}
		if($(".card").hasClass("eliminar")){
			$(".card.eliminar .card-header").removeClass("bg-danger border-danger");
			$(".card.eliminar .card-header").removeClass("text-white");
			$(".card.eliminar .card-header").removeClass("border-danger");
			$(".card.eliminar .card-footer").removeClass("text-danger");
			$(".card.eliminar .card-body").removeClass("bg-light");
			$(".card.eliminar .card-footer").removeClass("bg-light border-danger");
			$(".card.eliminar .card-header button.close").removeClass("text-white");

			$(".card.eliminar").addClass("bg-dark text-danger border-danger");	
			$(".card.eliminar .card-header").addClass("border-danger");
			$(".card.eliminar .card-header button.close").addClass("text-danger");
		}
	}else{
		if($(".card").hasClass("modificar")){
			$(".card.modificar .card-header").removeClass("text-warning border-warning");
			$(".card.modificar .card-header button.close").removeClass("text-warning");
			
			$(".card.modificar .card-header").addClass("bg-warning border-warning");
			$(".card.modificar .card-header").addClass("text-white");
			$(".card.modificar .card-footer").addClass("text-warning");
			$(".card.modificar .card-body").addClass("bg-light");
			$(".card.modificar .card-footer").addClass("bg-light border-warning");						
			$(".card.modificar .card-header button.close").addClass("text-white");

		}
		if($(".card").hasClass("agregar")){
			$(".card.agregar .card-header").removeClass("text-success border-success");
			$(".card.agregar .card-header button.close").removeClass("text-success");

			$(".card.agregar .card-header").addClass("bg-success border-success");
			$(".card.agregar .card-header").addClass("text-white");
			$(".card.agregar .card-footer").addClass("text-success");
			$(".card.agregar .card-body").addClass("bg-light");
			$(".card.agregar .card-footer").addClass("bg-light border-success");
			$(".card.agregar .card-header button.close").addClass("text-white");
		}
		if($(".card").hasClass("visualizar")){
			$(".card.visualizar .card-header").removeClass("text-primary border-primary");
			$(".card.visualizar .card-header button.close").removeClass("text-primary");

			$(".card.visualizar .card-header").addClass("bg-primary border-primary");
			$(".card.visualizar .card-header").addClass("text-white");
			$(".card.visualizar .card-footer").addClass("text-primary");
			$(".card.visualizar .card-body").addClass("bg-light");
			$(".card.visualizar .card-footer").addClass("bg-light border-primary");
			$(".card.visualizar .card-header button.close").addClass("text-white");
		}
		if($(".card").hasClass("eliminar")){
			$(".card.eliminar .card-header").removeClass("text-danger border-danger");
			$(".card.eliminar .card-header button.close").removeClass("text-danger");

			$(".card.eliminar .card-header").addClass("bg-danger border-danger");
			$(".card.eliminar .card-header").addClass("text-white");
			$(".card.eliminar .card-footer").addClass("text-danger");
			$(".card.eliminar .card-body").addClass("bg-light");
			$(".card.eliminar .card-footer").addClass("bg-light border-danger");
			$(".card.eliminar .card-header button.close").addClass("text-white");
		}								
	}

	$(".card.modificar .card-footer .btn.modificar").addClass("btn-warning text-white");
	$(".card.agregar .card-footer .btn.agregar").addClass("btn-success text-white");
	$(".card.eliminar .card-footer .btn.eliminar").addClass("btn-danger text-white");
	$(".card .card-header .close").addClass("text-white");
	
	$("input, select, texarea").change(function(){
		changedata=true;
	})	
};

function exit(objeto){
	if (!changedata){
		changedata=false;
		var url=$(objeto).data("url");
		cargacomponente(url,"");
		window.history.replaceState(null, "", "/home"+url);
		cargabreadcrumb("/breadcrumbs","");
	}else{		
		swalWithBootstrapButtons.fire({
		  title: '¿Estas seguro?',
		  text: "Aún no has guardado los datos en esta página!",
		  icon: 'warning',
		  showCancelButton: true,
		  confirmButtonColor: '#3085d6',
		  cancelButtonColor: '#d33',
		  confirmButtonText: '<i class="fas fa-thumbs-up"></i> Si, salir igual!',
		  cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar'
		}).then((result) => {
		  if (result.value) {			
			changedata=false;
			var url=$(objeto).data("url");
			cargacomponente(url,"");
			window.history.replaceState(null, "", "/home"+url);
			cargabreadcrumb("/breadcrumbs","");
		  }
		})
	}
}
function errors(code,target){
	error=true;
	if(target==undefined || target==""){
		target="#contenbody";
	}
	if(code==403){
		$(target).load("/error403");
	}else{
		if(code==500){
			$(target).load("/error500");
		}else{
			if(code==503){
				$(target).load("/error503");
			}else{
				if(code==404){
					$(target).load("/error404");
				}else{
					if(code==504){
						$(target).load("/error504");
					}else{
						$(target).load("/error418");
					}
				}
			}	
		}								
	}
}
function salir(){
	swalWithBootstrapButtons.fire({
		title: '¿Estas seguro?',
		text: "Esta acción hará que cierres tu sesión en el sitio!",
		icon: 'warning',
		showCancelButton: true,
		confirmButtonColor: '#3085d6',
		cancelButtonColor: '#d33',
		confirmButtonText: '<i class="fas fa-thumbs-up"></i> Si, salir igual!',
		  cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar'
	}).then((result) => {
		if (result.value) {						  	
			window.location.href="/ingreso-de-credenciales"
		}else{
			//window.history.go(0)
		}
	});
}
function cargabreadcrumb(target,data){	
	$.ajax({
		type: 'POST',								
		url:target,			
		data:data,
		success: function(data) {
			var param=data.split("/@/");			
			if(param[0]=="200"){				
				$('#breadcrumbbody').html(param[1]);
			}else{
				//errors(param[0]);
				$('#breadcrumbbody').html(param[0] + "</br>" + param[1]);
			}
		},
		error: function(XMLHttpRequest, textStatus, errorThrown){				
			$("#breadcrumbbody").load("/error404");						
		},
		complete: function(){			
			$("nav li a").click(function(e){
				e.stopPropagation();
				e.preventDefault();					
				var url=$(this).data("url");
				var keys=$(this).data("keys");
				var target=$(this).data("target");
				var tabId=$(this).data("tab");
				//console.log(tabId)
				if (url!=undefined){
					if(url=="salir"){
						salir();
					}else{
						if(url=="workflowv1"){
							window.open('http://v1.workflow.subtrab.gob.cl/','_blank');
						}else{
							if(keys!=undefined && keys>0){	
								var varValue;
								var varName;
								var data=[];
								var objeto={};
								var key=''							

								for(var i= 0; i < keys; i++) {
									varValue=$(this).data("key"+(i+1));
									varName = "key"+(i+1);			
									objeto[varName]=varValue;				
									key=key + '/' + varValue
								}								
								cargacomponente($(this).data("url"),objeto,target);
								window.history.replaceState(null, "", "/home"+$(this).data("url") + key);	
								cargabreadcrumb("/breadcrumbs","");
							}else{
								//console.log(tabId)
								cargacomponente($(this).data("url"),"",target,function(){									
									setTimeout(function(){
										$(tabId).click();
									},100);
								});
								window.history.replaceState(null, "", "/home"+$(this).data("url"));	
								cargabreadcrumb("/breadcrumbs","");
							}																												
						}
					}
				}
			});
			
			$('.content-sistema ul li, .content-mantenedores ul li, .content-informes ul li, .content-acciones ul li').click(function(e){
				e.preventDefault();
				e.stopPropagation();
				var url=$(this).data("url");
				var keys=$(this).data("keys");
				var target=$(this).data("target");				
				if (url!=undefined){
					//if(keys!=undefined && keys>0){	
					var varValue;
					var varName;
					var data=[];
					var objeto={};
					var key='';
					var id = $(this).attr("id");
					var modo = $(this).data("modo");
					var acciones = false;
					var accion = false;
					var k=0;						
					if(modo==undefined){
						modo=4;
					}
					var path = location.pathname.replace($(this).parent().parent().parent().attr("id"),modos[modo]);

					if($(this).parent().hasClass("acciones")){
						acciones=true;
					}

					var split_path=window.location.pathname.split("/");
					if(acciones){
						for(i=2;i<split_path.length;i++){
							if(accion && $.isNumeric(split_path[i])){
								k=k+1;
								varValue=split_path[i];
								varName = "key"+k;
								objeto[varName]=varValue;													
							}
							if(split_path[i]=="modificar" || split_path[i]=="visualizar" || split_path[i]=="agregar"){
								accion=true;				
							}								
						}
						k=k+1;
						varValue=modo;
						varName = "key"+k;
						objeto[varName]=varValue;
					}else{
						for(var i= 0; i < keys; i++) {
							varValue=$(this).data("key"+(i+1));
							varName = "key"+(i+1);
							objeto[varName]=varValue;				
							key=key + '/' + varValue
						}
					};						
					cargacomponente($(this).data("url"),objeto,target);
					if(!acciones){
						window.history.replaceState(null, "", "/home"+$(this).data("url") + key);	
						cargabreadcrumb("/breadcrumbs","");
					}else{
						window.history.replaceState(null, "", path);	
						cargabreadcrumb("/breadcrumbs","");
					}					
				}
			})
		}
	});
}
function moveMark(animation){						
	var pos = $("#pry-menu ul").find("li.active.pasos").position();
	if(pos!=undefined){
		var posTop = pos.top + 4;
		if($("li.active.pasos").css("visibility")!="hidden") {
			$("#pasos").css("top",posTop + "px");
			if(animation){
				$("#pasos").on('transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd', 
					function() {
						smooth(".pasos.active .globo.act","Pasos");
						$(".pasos.active .globo.act").addClass("on");
						$(".pasos.active a").addClass("current");
					});
			}else{
				smooth(".pasos.active .globo.act","Pasos");
				$(".pasos.active .globo.act").addClass("on");
				$(".pasos.active a").addClass("current");
			}
		}else{
			var pos = $("#pry-menu ul").find("li.category.pasos").position();
			var posTop = pos.top
			$("#pasos").css("top",posTop + "px");
		}		
	}
		
	var pos = $("#pry-menu ul").find("li.active.hitos").position();
	if(pos!=undefined){
		var posTop = pos.top + 4;
		if($("li.active.hitos").css("visibility")!="hidden") {
			$("#hitos").css("top",posTop + "px");		
			if(animation){

				$("#hitos").on('transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd', 
					function() {
						smooth(".hitos.active .globo.act","Hitos");
						$(".hitos.active .globo.act").addClass("on")
						$(".hitos.active a").addClass("current");
					});
			}else{
				smooth(".hitos.active .globo.act","Hitos");
				$(".hitos.active .globo.act").addClass("on")
				$(".hitos.active a").addClass("current");
			}
		}else{
			var pos = $("#pry-menu ul").find("li.category.hitos").position();
			var posTop = pos.top
			$("#hitos").css("top",posTop + "px");
		}
	}

	var pos = $("#pry-menu ul").find("li.active.menus").position();
	if(pos!=undefined){
		if($("li.active.menus").css("visibility")!="hidden") {
			if(pos!=undefined){		
				var posTop = pos.top
				$("#menus").css("top",posTop + "px");
				if(animation){

					$("#menus").on('transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd', 
						function() {
							smooth(".menus.active .globo.act","Menus");
							$(".menus.active .globo.act").addClass("on")
							$(".menus.active a").addClass("current");
						});
				}else{
					smooth(".menus.active .globo.act","Menus");
					$(".menus.active .globo.act").addClass("on")
					$(".menus.active a").addClass("current");
				}
			}else{
				if(pos==undefined){	
					var pos = $("#pry-menu ul").find("li.category.menus").position();
					if(pos==undefined){
						$("#menus").hide();
					}else{
						var posTop = pos.top
						$("#menus").css("top",posTop + "px");
					}
				}
			}
		}else{
			if(pos==undefined){	
				var pos = $("#pry-menu ul").find("li.category.menus").position();
				if(pos==undefined){
					$("#menus").hide();
				}else{
					var posTop = pos.top
					$("#menus").css("top",posTop + "px");
				}
			}
		}
	}
		
}

function moveMark_2(animation){
	var pos = $("#pry-menu ul").find("li.active.reportes").position();
	if(pos!=undefined){
		if($("li.active.reportes").css("visibility")!="hidden") {		
			if(pos!=undefined){		
				var posTop = pos.top
				$("#reportes").css("top",posTop + "px");
				if(animation){
					$("#reportes").on('transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd', 
						function() {
							smooth(".reportes.active .globo.act","Reportes");
							$(".reportes.active .globo.act").addClass("on")
							$(".reportes.active a").addClass("current");
						});
				}else{
					smooth(".reportes.active .globo.act","Reportes");
					$(".reportes.active .globo.act").addClass("on")
					$(".reportes.active a").addClass("current");
				}
			}else{						
				var pos = $("#pry-menu ul").find("li.category.reportes").position();
				var posTop = pos.top
				$("#reportes").css("top",posTop + "px");
			}
		}else{
			var pos = $("#pry-menu ul").find("li.category.reportes").position();
			var posTop = pos.top
			$("#reportes").css("top",posTop + "px");
		}
	}	
	var pos = $("#pry-menu ul").find("li.active.mantenedores").position();
	if(pos!=undefined){
		if($("li.active.mantenedores").css("visibility")!="hidden") {		
			if(pos!=undefined){		
				var posTop = pos.top
				$("#mantenedores").css("top",posTop + "px");
				if(animation){
					$("#mantenedores").on('transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd', 
						function() {
							smooth(".mantenedores.active .globo.act","Mantenedores");
							$(".mantenedores.active .globo.act").addClass("on")
							$(".mantenedores.active a").addClass("current");
						});
				}else{
					smooth(".mantenedores.active .globo.act","Mantenedores");
					$(".mantenedores.active .globo.act").addClass("on")
					$(".mantenedores.active a").addClass("current");
				}
			}else{			
				var pos = $("#pry-menu ul").find("li.category.mantenedores").position();
				var posTop = pos.top
				$("#mantenedores").css("top",posTop + "px");	
			}
		}else{
			var pos = $("#pry-menu ul").find("li.category.mantenedores").position();
			var posTop = pos.top
			$("#mantenedores").css("top",posTop + "px");
		}
	}	
}

function cargaperfil(){	
	var target="/perfil";
	var data="";
	$.ajax({
		type: 'POST',								
		url:target,			
		data:data,
		success: function(data) {
			var param=data.split("/@/");			
			if(param[0]=="200"){				
				$('#perfilbody').html(param[1]);				
			}else{			
				$('#perfilbody').html(param[0] + "</br>" + param[1]);
			}
		},
		error: function(XMLHttpRequest, textStatus, errorThrown){				
			$("#perfilbody").load("/error404");						
		},
		complete: function(){												
			$(".perfil span").click(function(e){
				e.stopPropagation();
				$(".content-perfil").toggle("slow");							
			})
			
			$(".menuperfil li").click(function(e){
				e.preventDefault();
				$(".content-perfil").toggle("slow");
				var url=$(this).data("url");
				if (url!=undefined){
					if(url=="salir"){						
						salir();
					}else{
						if(url=="workflowv1"){
							window.open('http://v1.workflow.subtrab.gob.cl/','_blank');
						}else{
							if(url=="/cambiar-clave"){
								$.ajax({
									type: 'POST',								
									url:url,			
									//data:data,
									success: function(data) {
										var param=data.split("/@/");			
										if(param[0]=="200"){				
											$('#perfilbody').html(param[1]);
										}else{
											//errors(param[0]);
											$('#perfilbody').html(param[0] + "</br>" + param[1]);
										}
									},
									error: function(XMLHttpRequest, textStatus, errorThrown){				
										$("#perfilbody").load("/error404");						
									},
									complete: function(){	
									}
								});
							}else{							
								cargacomponente($(this).data("url"),"");
								window.history.replaceState(null, "", "/home"+$(this).data("url"));	
								cargabreadcrumb("/breadcrumbs","");
							}
						}
					}
				}
			});
			var images = $(".imgPerfil");
			$(images).on("error", function(event) {
				$(event.target).css("display", "none");
			});
		}
	});
}

$(document).mouseup(e => {
	//const $menu = $(".content-perfil, .content-sistema, .content-mantenedores, .content-acciones");
	//const $container = $(".perfil, .sistema, .mantenedores, .acciones");
	const $menu = $(".content-perfil");
	const $container = $(".perfil");
   	if (!$container.is(e.target) // if the target of the click isn't the container...
   		&& $container.has(e.target).length === 0) // ... nor a descendant of the container
   	{
    	$menu.hide("slow");
  	}
});

function iniActions(){
	$('body').on('click','.btn-acc, .icon, .link',function(e){
		e.preventDefault();
		e.stopPropagation();		
				
		var keys;
		if ($(this).hasClass("btn") || $(this).hasClass("link")) {
			var keys=$(this).data("keys");			
			
			var varValue;
			var varName;
			var data=[];
			var objeto={};
			var url=$(this).data("url")
			for(var i= 0; i < keys; i++) {
				varValue=$(this).data("key"+(i+1));
				varName = "key"+(i+1);								
				url=url+"/"+varValue;				
				objeto[varName]=varValue;
				
				$("body").data(varName,varValue);
			}			
			cargacomponente($(this).data("url"),objeto);
			window.history.replaceState(null, "", "/home"+url);
			cargabreadcrumb("/breadcrumbs","");
			$("body").data("id",url.replace(/[/]/gi,'.'));
			$("body").data("keys",keys);
						
		}else{
			cargacomponente($(this).data("url"),"");
			window.history.replaceState(null, "", "/home"+$(this).data("url"));	
			cargabreadcrumb("/breadcrumbs","");
		}
	})
}
function darkmode(){
	if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
		// dark mode
		$("html").addClass("dark");
		return true
	}else{
		$("html").removeClass("dark");
		return false
	}	
}
function formValidate(id){	
	//Validate	
	$.validator.addMethod("regex",function(value, element, regexp) 
		{
			if (regexp.constructor != RegExp)
				regexp = new RegExp(regexp);
			else if (regexp.global)
				regexp.lastIndex = 0;
			return this.optional(element) || regexp.test(value);
		},
		"Please check your input."
    );	
	
	$.validator.addMethod("rutValido", function(value, element) {
	  return this.optional(element) || $.Rut.validar(value);
	}, "Este campo debe ser un rut valido.");

	$.validator.addMethod("rutMin", function(value, element) {
	  var rut=parseInt(value.replace(/[.-]/gi,'').substr(0,value.length-3));		  
	  if(rut<50000){
		return false;
	  }else{
		return true;
	  }		  
	}, "Este campo debe ser un rut valido.");

	$.validator.addMethod("extFile", function(value, element) {
		var fileName = value;
		var idxDot = fileName.lastIndexOf(".") + 1;
		var extFile = fileName.substr(idxDot, fileName.length).toLowerCase();
		if (extFile=="jpg" || extFile=="jpeg" || extFile=="png" || extFile=="gif" || extFile=="xls" || extFile=="xlsx" || extFile=="doc" || extFile=="docx" || extFile=="ppt" || extFile=="pptx" || extFile=="pdf" || fileName==""){
		   return true
		}else{
		   return false
		}   
	}, "Formato de archivo no válido.");
	
	$.validator.addMethod('filesize', function (value, element, param) {
		let sizeFiles = 0;
		for(var i=0;i<element.files.length;i++) {
			const file = element.files[i];
			sizeFiles += file.size;
		}
		//console.log(sizeFiles, (param * (1024*1024)))
		if(sizeFiles > (param * (1024*1024))){
			return false;
		}else{
			return true;
		}
	}, 'El o los archivo(s) debe(n) ser menor a {0} MB');

	$.validator.addMethod("maxNameFile", function(value, element) {
		var fileName = value;
		var idxDot = fileName.lastIndexOf(".");
		var nameFile = fileName.substr(0,idxDot).toLowerCase();
		if (nameFile.length<=60){
		   return true
		}else{
		   return false
		}   
	}, "Nombre de archvo superior a 60 caracteres");
	
	$( id ).validate( {
		ignore: [],
		rules: {
			USR_Rut:{
				required: true,
				minlength:7,
				rutValido:true,
				rutMin:true
			},
			PRO_Rut:{
				required: true,
				minlength:7,
				rutValido:true,
				rutMin:true
			}
		},
		messages: {},
		errorElement: "div",
		errorPlacement: function ( error, element ) {
			if(error[0].innerHTML!=""){
				if(element.prev("i.prefix").length>0){					
					error.css("padding-left","2.5rem");
				}else{
					error.css("padding-left","0rem");					
				}
				let addclassError = '';
				if ( $(element).prop( "type" ) === "file" ) {
					addclassError = ' error-adjuntos'
				}
				// Add the `help-block` class to the error element				
				error.addClass( "invalid-feedback" + addclassError);
				if ( element.prop( "type" ) === "checkbox" ) {					
					error.insertAfter( element.parent(".error-message") );				
				} else {
					if ( element.prop( "type" ) === "select-one" ) {																		
						error.insertAfter( element );	
					} else {						
						if ( element.prop( "type" ) === "textarea" ) {
							error.addClass( "textarea" );
							error.insertAfter( element );	
						} else {					
							if ( element.prop( "type" ) === "file" ) {
								element.each(function(){		
									error.addClass( "error-adjuntos");							
									error.insertAfter($($($($(this).parent()).parent()).parent()).parent())
								});
							} else {	
								//error.insertAfter( element );
								error.insertAfter( element.parent(".error-message") );
							}
						}
					}
				}
			}
		},
		success: function ( label, element ) {		
		},
		highlight: function ( element, errorClass, validClass ) {			
			$( element ).addClass( "is-invalid" ).removeClass( "is-valid" );
			$(element).siblings("span.select-bar").addClass( "is-invalid" ).removeClass( "is-valid" );
			if ( $(element).prop( "type" ) === "file" ) {
				$(element).parent().addClass( "is-invalid" ).removeClass( "is-valid" );
			}
		},
		unhighlight: function (element, errorClass, validClass) {
			let addclassError = '';
			if ( $(element).prop( "type" ) === "file" ) {
				addclassError = ' error-adjuntos'
				$(element).parent().addClass("is-valid").removeClass("is-invalid");
			}
			$(element).addClass("is-valid").removeClass( "is-invalid" );
			$(element).parent().next().remove('.invalid-feedback' + addclassError);
			$(element).siblings("span.select-bar").addClass( "is-valid" ).removeClass( "is-invalid" );			
		}		
	})
	$.validator.methods.range = function (value, element, param) {
		var globalizedValue = value.replace(",", ".");
		return this.optional(element) || (globalizedValue >= param[0] && globalizedValue <= param[1]);
	}
	 
	$.validator.methods.number = function (value, element) {
		return this.optional(element) || /^-?(?:\d+|\d{1,3}(?:[\s\.,]\d{3})+)(?:[\.,]\d+)?$/.test(value);
	}	

	$(id + " .rut").each(function () {
		$(this).rules('add', {
			required: true,
			minlength:7,
			rutValido:true,
			rutMin:true
		});
	});

	$(id).find("input[type=file]").each(function () {
		$(this).rules('add', {			
			extFile:true,
			maxNameFile:true,
			filesize: 15
		});
	})
}

$(document).ready(function(e) {
	"use strict";	
	if (window.history && window.history.pushState) {
		window.history.pushState('forward', null, window.location.href);
		$(window).on('popstate', function() {
			//alert('Back button was pressed.');
			salir();
			window.history.forward();
		});
	}	
	window.history.replaceState(null, "", window.location.href);        
	window.onpopstate = function() {
		window.history.replaceState(null, "", window.location.href);
	};	
	$('body').addClass("bootstrap");
	$('body').removeClass("bootstrap-dark");
	$(".waves-effect").addClass("waves-light");
	$(".waves-effect").removeClass("waves-dark");
	
	//if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
	if(darkmode()){
		// dark mode		
		$('body').addClass("bootstrap-dark");
		$('body').removeClass("bootstrap");
		theme='ui-darkness';
		scrollbarTheme='inset-3-dark'
		bootstrapTheme="bootstrap-dark.css"
		$(".waves-effect").removeClass("waves-light");
		$(".waves-effect").addClass("waves-dark");
	}
	var urltheme = "https://" + host + "/vendor/jquery/css/" + theme + ".jquery-ui.css";
	$("#ui-theme").attr('href',urltheme);
	
	urltheme = "https://" + host + "/vendor/bootstrap/css/" + bootstrapTheme;
	$("#bootstrap-theme").attr('href',urltheme);

	//Carga escritorio o cualquier otro elemento
	var keys=$("body").data("keys");			
	if(keys!=undefined && keys>0){	
		var varValue;
		var varName;
		var data=[];
		var objeto={};		
		
		for(var i= 0; i < keys; i++) {
			varValue=$("body").data("key"+(i+1));
			varName = "key"+(i+1);			
			objeto[varName]=varValue;				
		}			
		cargacomponente("/"+$("body").data("id"),objeto);
		cargabreadcrumb("/breadcrumbs","");
	}else{
		cargacomponente("/"+$("body").data("id"),"");
		cargabreadcrumb("/breadcrumbs","");
	}
	if(!error){
		cargaperfil();
		iniActions();				
		$(window).keydown(function(event){
			//if((event.which== 13) && ($(event.target)[0]!=$("#NUM_NumeralMultas")[0]) && $(event.target)[0]!=$(".jqte_editor")[0]) {
			//if((event.which== 13) && ($(event.target)[0]!=$(".jqte_editor")[0])) {
			if((event.which== 13) && !$(event.target).hasClass("jqte_editor")) {			
			  event.preventDefault();
			  return false;
			}
		});
	}

	//Descargar
	clearInterval(titdesani);
	var titdesani = setInterval(function(){		
		$("#descargas").css("bottom",-($("#descargas").height()+1) + "px");
		clearInterval(titdesani);
	},4000);
	$(".desarrow").on('click',function(){
		clearInterval(titdesani);
		$(this).toggleClass("openmenu");		
		if($("#descargas").css("bottom")=="-" + ($("#descargas").height()+1) + "px"){
			$("#descargas").css("bottom","5px");
		}else{			
			$("#descargas").css("bottom","-" + ($("#descargas").height()+1) + "px");
		}				
	});
});

//Session
function confirmarCierre() {    
	let timerInterval
	swalWithBootstrapButtons.fire({
	  title: 'Cierre de sesión.',
	  html: 'Su sesión expirará en <b></b> segundos. </br>Presione OK para mantenerse activo.',
	  timer: 20000,
	  timerProgressBar: true,
	  allowOutsideClick: false,
	  allowEscapeKey: false,
	  showConfirmButton: true,
	  icon:'warning',
	  onBeforeOpen: () => {		
		timerInterval = setInterval(() => {
		  const content = swalWithBootstrapButtons.getContent()
		  if (content) {
			const b = content.querySelector('b')
			if (b) {
			  b.textContent = Math.trunc(swalWithBootstrapButtons.getTimerLeft() / 1000)
			}
		  }
		}, 100)
	  },
	  onClose: () => {
		clearInterval(timerInterval)
	  }
	}).then((result) => {
	  /* Read more about handling dismissals below */
	  if (result.dismiss === swalWithBootstrapButtons.DismissReason.timer) {		
		cerrarSesion();
	  }else{	  	
		clearTimeout(temp); //elimino el tiempo a la funcion confirmarCierre
		$.ajax({
			type: 'POST',								
			url:"/reactivar-session",		
			success: function(data) {
				swalWithBootstrapButtons.fire(
					'Sesión',
					'Su cierre de sesión ha sido cancelado.',
					'info'
				  )
			},
			error: function(XMLHttpRequest, textStatus, errorThrown){				

			},
			complete: function(){

			}
		})		
	  }
	})
}

function cerrarSesion() {
    $.ajax({
		type: 'POST',								
		url:"/cerrar-session",		
		success: function(data) {
			swalWithBootstrapButtons.fire(
				'Sesión',
				'Su sesión ha sido cerrada',
				'info'
			  ).then((result) => {		
				  window.location.href="/sesion-finalizada"
			  })
		},
		error: function(XMLHttpRequest, textStatus, errorThrown){				
			
		},
		complete: function(){
			
		}
	});	    	 
}

var temp = setTimeout(confirmarCierre, 60000*15);

$( document ).on('click keyup keypress keydown blur change', function(e) {    
    clearTimeout(temp);    
    temp = setTimeout(confirmarCierre, 60000*15);    
});

function calculardiferencia(HraIni,HraIFin,HraTot){
	var hora_inicio = HraIni
	var hora_final = HraIFin
	var HraTot;

	// Expresión regular para comprobar formato
	var formatohora = /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/;

	// Si algún valor no tiene formato correcto sale
	if (!(hora_inicio.match(formatohora)
		&& hora_final.match(formatohora))){
	return;
	}

	// Calcula los minutos de cada hora
	var minutos_inicio = hora_inicio.split(':')
	.reduce((p, c) => parseInt(p) * 60 + parseInt(c));
	var minutos_final = hora_final.split(':')
	.reduce((p, c) => parseInt(p) * 60 + parseInt(c));

	// Si la hora final es anterior a la hora inicial sale
	if (minutos_final < minutos_inicio) return;

	// Diferencia de minutos
	var diferencia = minutos_final - minutos_inicio;

	// Cálculo de horas y minutos de la diferencia
	var horas = Math.floor(diferencia / 45);
	var minutos = diferencia % 45;

	/*$(HraTot).val(horas + ':'
	+ (minutos < 10 ? '0' : '') + minutos);  */
	
	HraTot = horas + ':'
	+ (minutos < 10 ? '0' : '') + minutos;
	
	return HraTot
}
$.fn.clearValidation = function(){
	var v = $(this).validate();
	$('[name]',this).each(function(){
		v.successList.push(this);
		v.showErrors();
	});
	v.resetForm();
	v.reset();
};

function shake(thing) {
  var interval = 100;
  var distance = 10;
  var times = 6;

  for (var i = 0; i < (times + 1); i++) {
    $(thing).animate({
      left:
        (i % 2 == 0 ? distance : distance * -1)
    }, interval);
  }
  $(thing).animate({
    left: 0,
    top: 0
  }, interval);
}
// end SHAKE

function bounce(thing) {
  var interval = 100;
  var distance = 20;
  var times = 6;
  var damping = 0.8;

  for (var i = 0; i < (times + 1); i++) {
    var amt = Math.pow(-1, i) * distance / (i * damping);
    $(thing).animate({
      top: amt
    }, 100);
  }
  $(thing).animate({
    top: 0
  }, interval);
}
// end BOUNCE

function hinge(thing) {
	$(thing).addClass('animated hinge');
  $(thing).on('animationend mozanimationend webkitAnimationEnd oAnimationEnd msanimationend', function() {
		$(thing).remove();
    // add a new button to restore the images, which were just removed
    $('div').append('<button id="restore">Restore</button>');
    // clicking that button runs this to rewrite the removed images
    // into the HTML where they were previously 
    $('#restore').click(function() {
			$('div').after(allImages);
      $('#restore').remove();
		});
	});
}
// end HINGE 

//Workers
function download_csv_file(csvFileData,header,filename) {
	var rowheader='';
	var csv='';
	header.forEach(function(field) {
			//rowheader += row.join(';');
			rowheader += field + ";";					
	});			
	//merge the data with CSV
	//console.log(header)
	csvFileData.forEach(function(row) {
			csv += row.join(';');
			csv += "\n";
	});
	//console.log(csvFileData)
	csv = '\uFEFF' + rowheader + "\n" + csv	
	//document.write(csv);			

	var hiddenElement = document.createElement('a');
	hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
	hiddenElement.target = '_blank';
		
	hiddenElement.download = filename + '.csv';
	hiddenElement.click();			
}

function wrk_reportes(worker,idTable,Tipo,FLU_Id,USR_Id,USR_Identificador){	
	if("undefined" !== typeof Worker){
		var miWorker = new Worker(worker); // Como argumento le pasamos la ruta del script
		var csvFileData;
		var row = [];

		$("#" + idTable).DataTable().columns().header().each(function(e,i){			
			row.push(e.innerText.replace(/(\r\n|\n|\r)/gm, ""))
		});
		//console.log(idTable, row)
		var data={Tipo:Tipo,USR_Id:USR_Id,USR_Identificador:USR_Identificador,FLU_Id:FLU_Id};
		//console.log(data)
		geninfo(idTable + '.csv',true)
		miWorker.postMessage(data);
		activeWorkers.push(worker.replace('/',''));
		//console.log(activeWorkers);		
		miWorker.onmessage = function(evento){			
			//console.log(evento.data.status);
			if(evento.data.status=='0'){
				csvFileData = evento.data.data;
								
				//console.log(row)
				//console.log(evento.data.data);				
				download_csv_file(csvFileData,row,idTable);
				geninfo(name,false,'Generado')
				if(activeWorkers.indexOf(worker.replace('/',''))!==-1){
					activeWorkers.splice(activeWorkers.indexOf(worker.replace('/','')),1);
				}
				//console.log(activeWorkers);
				miWorker.terminate();
			}
		}
	}
}

function wrk_informesgenerales(Informe,worker,infname,columns,INF_Anio, INF_Mes, EST_Id,USR_Id,USR_Identificador){
	if("undefined" !== typeof Worker){
		var miWorker = new Worker(worker); // Como argumento le pasamos la ruta del script
		var csvFileData;
		var row = [];

		$(columns).each(function(e,i){			
			row.push(i.replace(/(\r\n|\n|\r)/gm, ""))			
		});				

		var data={Informe:Informe,INF_Anio:INF_Anio,INF_Mes:INF_Mes,EST_Id:EST_Id,USR_Id:USR_Id,USR_Identificador:USR_Identificador};
		console.log(data)		
		geninfo(infname + '.csv',true)
		miWorker.postMessage(data);
		activeWorkers.push(worker.replace('/',''));
		//console.log(activeWorkers);		
		miWorker.onmessage = function(evento){			
			//console.log(evento.data.status);
			if(evento.data.status=='0'){
				csvFileData = evento.data.data;
								
				//console.log(row)
				//console.log(evento.data.data);				
				download_csv_file(csvFileData,row,infname);
				geninfo(infname,false,'Generado')
				if(activeWorkers.indexOf(worker.replace('/',''))!==-1){
					activeWorkers.splice(activeWorkers.indexOf(worker.replace('/','')),1);
				}
				//console.log(activeWorkers);
				miWorker.terminate();
			}
		}
	}
}

function wrk_informes(worker,name,DRE_Id, INF_Id,table,wk2_usrid,wk2_usrtoken,wk2_usrperfil){
	if("undefined" !== typeof Worker){
		var miWorker = new Worker('/wrk-informes'); // Como argumento le pasamos la ruta del script
		geninfo(name ,true)
		miWorker.postMessage({worker:worker,DRE_Id:DRE_Id,INF_Id:INF_Id,wk2_usrid:wk2_usrid,wk2_usrtoken:wk2_usrtoken,wk2_usrperfil:wk2_usrperfil});
		activeWorkers.push(worker.replace('/',''));
		miWorker.onmessage = function(evento){	
			//console.log(evento.data);		
			if(evento.data.status=='0'){
				geninfo(name,false,'Generado')
				if(activeWorkers.indexOf(worker.replace('/',''))!==-1){
					activeWorkers.splice(activeWorkers.indexOf(worker.replace('/','')),1);
				}				
				miWorker.terminate();
				table.ajax.reload();
			}else{
				geninfo(name,false,'Error!')
				miWorker.terminate();
				console.log('Error 1: ' + evento.data.message)
			}
		}
	}
}

function geninfo(name, tipo, msg){	
	progressArea = document.querySelector("#descargas .progress-area"),
	uploadedArea = document.querySelector("#descargas .uploaded-area");
	
	if(tipo){
		let progressHTML = `<li class="row">
							<div class="content">
								<i class="fas fa-file-alt"></i>							
								<div class="details">
									<span class="name">${name} • Generando...</span>                              
								</div>
								<i class="loader"></i>
							</div>
							</li>`;		
		uploadedArea.classList.add("onprogress");
		progressArea.innerHTML = progressHTML;
		clearInterval(titdesani);
		var titdesani = setInterval(function(){
			$(".desarrow").removeClass("openmenu")
			$("#descargas").css("bottom",-($("#descargas").height()+1) + "px");
			clearInterval(titdesani);
		},4000);
	}else{
		var icon=icon='<i class="fas fa-check"></i>'
		if(msg==="Error!"){
			icon='<i class="fas fa-times error"></i>'
		}
		progressArea.innerHTML = "";
		let uploadedHTML = `<li class="row">
                            <div class="content upload">
                              <i class="fas fa-file-alt"></i>
                              <div class="details">
                                <span class="name">${name} • ${msg}</span>                                
                              </div>
                            </div>
							${icon}
                          </li>`;
		uploadedArea.classList.remove("onprogress");
		uploadedArea.insertAdjacentHTML("afterbegin", uploadedHTML);		
	}
	$(".desarrow").addClass("openmenu")
	$("#descargas").css("bottom","5px");
}

$(".input-list").focus(function(){
	$(this).siblings("i").toggleClass("active");
})