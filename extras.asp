<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="include\template\session.min.inc" -->
<%
	tipo=request("type")
	key1=request("key1")
	key2=request("key2")
	
	if(tipo="") then
		tipo=mid(key1,1,3)
	end if
	
	if(tipo="man") then
		titulo="<i class='fas fa-server'></i> Mantenedores"
	end if
	if(tipo="rep") then
		titulo="<i class='fas fa-print'></i> Reportes"
	end if
	soloreportes = false
	if(session("wk2_usrperfil")=3) or (session("wk2_usrperfil")=4) then
		soloreportes = true
	end if
	
	gradiente="blue-gradient"	
	
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
	'response.write(tipo & "-" & key1 & "-" & key2)
	'response.end	
		
	'response.write(archivo)
	'response.write(CRT_Step)
	'response.write("mode: " & mode)
%>
<div class="row container-header">

</div>
<!--container-body-->
<div class="row container-body">	
	<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">						
		<!-- Table with panel -->					
		<div class="card card-cascade narrower">
			<!--Card image-->
			<div class="view view-cascade gradient-card-header <%=gradiente%> narrower py-2 mx-4 mb-3 d-flex justify-content-between align-items-center" style="height:3rem;">
				<div>
				</div>
				<a href="" class="white-text mx-3"><i class="fas fa-network-wired"></i> Funcionalidades extras</a>
				<div>
				</div>
			</div>
			<!--/Card image-->
			<div class="px-4">
				<div class="row">
					<div class="col-auto div">						
						<div id="pry-menu">							
							<div class="res" id="reportes" disabled></div><%
							if(not soloreportes) then%>
								<div class="res" id="mantenedores" disabled></div><%
							end if%>
							<i class="fas fa-thumbtack pin text-primary"></i>
							<div id="pry-menucontent"></div>						
						</div>
					</div>
					<div class="col">
						<div id="pry-scrollconten">
							<div id="pry-content"></div>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- Table with panel -->		
	</div>	  	
</div>
<!--container-body--><%

if(session("wk2_usrperfil")<>3 and session("wk2_usrperfil")<>4) then 'todos menos revisor y solicitante%>	
	
	<!-- Modal Departamentos-->
	<div class="modal fade bottom" id="departamentosModal" tabindex="-1" role="dialog" aria-labelledby="departamentosLabel" aria-hidden="true">		
	</div>
	<!-- Modal Departamentos-->	
    <!-- Modal Regiones-->
	<div class="modal fade bottom" id="regionesModal" tabindex="-1" role="dialog" aria-labelledby="regionesLabel" aria-hidden="true">		
	</div>
	<!-- Modal Regiones-->
    <!-- Modal Comunas-->
	<div class="modal fade bottom" id="comunasModal" tabindex="-1" role="dialog" aria-labelledby="comunasLabel" aria-hidden="true">		
	</div>
	<!-- Modal Comunas-->
    <!-- Modal Sexo-->
	<div class="modal fade bottom" id="sexoModal" tabindex="-1" role="dialog" aria-labelledby="sexoLabel" aria-hidden="true">		
	</div>
	<!-- Modal Sexo-->
	<!-- Modal Festivos-->
	<div class="modal fade bottom" id="festivoModal" tabindex="-1" role="dialog" aria-labelledby="festivoLabel" aria-hidden="true">		
	</div>	
	<!-- Modal Festivos-->
    <!-- Modal Listas Desplegables-->
	<div class="modal fade bottom" id="lstdesplegableModal" tabindex="-1" role="dialog" aria-labelledby="lstdesplegableModalLabel" aria-hidden="true">		
	</div>	
	<!-- Modal Listas Desplegables-->
    <!-- Modal Itemes Lista Desplegable-->
	<div class="modal fade bottom" id="itemslistadesplegableModal" tabindex="-1" role="dialog" aria-labelledby="itemslistadesplegableModalLabel" aria-hidden="true">		
	</div>	
	<!-- Modal Itemes Lista Desplegable-->
	<!-- Modal Usuarios-->
	<div class="modal fade bottom" id="usuariosModal" tabindex="-1" role="dialog" aria-labelledby="usuariosModalLabel" aria-hidden="true" data-backdrop="false" data-keyboard="false">		
	</div>
	<!-- Modal Usuarios-->
	<!-- Modal Proveedores-->
	<div class="modal fade bottom" id="proveedoresModal" tabindex="-1" role="dialog" aria-labelledby="proveedoresLabel" aria-hidden="true">		
	</div>
	<!-- Modal Proveedores-->	<%
end if
if(session("wk2_usrperfil")<>4) then%>
	<!--Reportes-->
	<!--Estados de Alumnos-->
	<div class="modal fade bottom" id="repestadosalumnosModal" tabindex="-1" role="dialog" aria-labelledby="repestadosalumnosModalLabel" aria-hidden="true">		
	</div>
	<!--Estados de Alumnos-->
	<!--Reportes--><%
end if%>
	
<script>
	$(function () {
		$('[data-toggle="tooltip"]').tooltip({
			trigger : 'hover'
		})
		$('[data-toggle="tooltip"]').on('click', function () {
			$(this).tooltip('hide')
		})		
	});
	
	$(document).ready(function() {		
		var ss = String.fromCharCode(47) + String.fromCharCode(47);
		var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);
		var bb = String.fromCharCode(92) + String.fromCharCode(92);		
		
		$("#pry-menu, #pry-scrollconten").mCustomScrollbar({
			theme:scrollTheme,
			advanced:{
				autoExpandHorizontalScroll:true,
				updateOnContentResize:true,
				autoExpandVerticalScroll:true
			},
		});		
		
		cargamenu();
		cargabreadcrumb("/breadcrumbs","");				
		$.fn.modal.Constructor.prototype.enforceFocus = function () {
		$(document)
		  .off('focusin.bs.modal') // guard against infinite focus loop
		  .on('focusin.bs.modal', $.proxy(function (e) {
			if (this.$element[0] !== e.target && !this.$element.has(e.target).length) {
			  this.$element.focus()
			}
		  }, this))
		}
		
		function cargamenu(){
			$.ajax( {
				type:'POST',
				url: '/mnu-extras',
				data:{type:'<%=tipo%>',subtype:'<%=key2%>'},
				success: function ( data ) {
					param = data.split(sas)
					if(param[0]==200){						
						$("#pry-menucontent").html(param[1]);
						var tipo='<%=tipo%>'
						if(tipo=="man"){
							animateMenu(".manmenu","mantenedores",".repmenu","reportes");
						}
						if(tipo=="rep"){
							animateMenu(".repmenu","reportes",".manmenu","mantenedores");
						}
						var reporPos = $("#pry-menu ul").find("li.category.reportes").position();
						var mantePos = $("#pry-menu ul").find("li.category.mantenedores").position();						
						
						if(reporPos!=undefined){
							if($("li.category.reportes").index()==0){
								$("#menus").css("top",reporPos.top + "px")
								$("#menus").show();
							}else{
								$("#menus").css("top",(reporPos.top + 18) + "px")
								$("#menus").show();
							}
						}
						if(mantePos!=undefined){
							if($("li.category.mantenedores").index()==0){
								$("#menus").css("top",mantePos.top + "px")
								$("#menus").show();
							}else{
								$("#menus").css("top",(mantePos.top + 18) + "px")
								$("#menus").show();
							}
						}
						
						if(pinmenu){							
							$("#pry-menu").addClass("show");
						}else{							
						}
						
						$(".pin").click(function(){
							$("#pry-menu").toggleClass("show");
							if(pinmenu){
								pinmenu = false;
							}else{
								pinmenu = true;
							}							
						});
						if(firsttimenu && !pinmenu){
							setTimeout(function() {
								$("#pry-menu").toggleClass("show");	
								firsttimenu = false;
								setTimeout(function() {									
									moveMark_2(true);
									if(!pinmenu){
										setTimeout(function() {			
											//$("#pry-menu").toggleClass("show");
										}, 1000);
									}
								}, 1000);				
							}, 1000);
						}else{
							setTimeout(function() {								
								moveMark_2(true);
							}, 1000);		
						}
						
					}else{
						swalWithBootstrapButtons.fire({
							icon:'error',								
							title: 'Ups!, no pude cargar el menú del proyecto',					
							text:param[1]
						});				
					}
				},
				error: function(XMLHttpRequest, textStatus, errorThrown){					
					swalWithBootstrapButtons.fire({
						icon:'error',								
						title: 'Ups!, no pude cargar el menú del proyecto',					
					});				
				}
			});
		};										
		
		$("#pry-menu").on("click",".repmenu",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
						
			animateMenu(".repmenu","reportes",".manmenu","mantenedores");
			
		})				
		
		$("#pry-menu").on("click",".manmenu",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();												
									
			animateMenu(".manmenu","mantenedores",".repmenu","reportes");
		})				
		
		$("#pry-menu").on("click",".mnustep",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();												
			
			var url = $(this).data("url");
			if($(this).hasClass("reportes")){
				$(".reportes").removeClass("active");				
			}
			if($(this).hasClass("mantenedores")){
				$(".mantenedores.active").removeClass("active");				
				$(".mantenedores").find(".globo.act").removeClass("act");
				$(".mantenedores").find(".globo.on").removeClass("on");
				$(".mantenedores").find("a.current").removeClass("current");
				var menu=".mantenedores";
			}
			
			if($(this).hasClass("reportes")){
				$(".reportes.active").removeClass("active");				
				$(".reportes").find(".globo.act").removeClass("act");
				$(".reportes").find(".globo.on").removeClass("on");
				$(".reportes").find("a.current").removeClass("current");
				var menu=".reportes";
			}
			
			$(this).addClass("active")
			$(this).find("a i.globo").addClass("act");			
			moveMark_2(false);			
			
			pryarc(menu);
		})
		
		function animateMenu(menu,submenu,menu2,submenu2){
			$(menu).toggleClass("openmenu");
			
			$(menu).addClass("disabled");
			$(menu2).removeClass("disabled");
			
			$('li[class*="' + submenu + '"]:not(.category)').each(function(){
				$(this).toggleClass("menuToggle");
				var x_1 = setInterval(function(){ 
					moveMark_2(false);
					clearTimeout(x_1);
				},600)				
			});
						
			$(menu2).removeClass("openmenu");
			$('li[class*="' + submenu2 + '"]:not(.category)').each(function(){
				$(this).removeClass("menuToggle");						
			});
			
			$("#reportes").css("width","0");
			$("#mantenedores").css("width","0");

			var timerMenu_1 = setInterval(function(){
				moveMark_2(false);

				clearTimeout(timerMenu_1);
				var timerMenu_2 = setInterval(function(){
					$("#reportes").css("width","calc(100% + 10px)");
					$("#mantenedores").css("width","calc(100% + 10px)");					
					clearTimeout(timerMenu_2);
				}, 600);							
			}, 600);
			
			if($(menu).hasClass("openmenu")){				
				pryarc("." + submenu)
			};
		}
		
		function pryarc(menu){			
			var url=$(menu + ".mnustep.active").data("url");				
			var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);
			$.ajax( {
				type:'POST',
				url: url,					
				success: function ( data ) {
					param = data.split(sas);						
					if(param[0]==200){	
						$("#pry-content").hide();																		
						$("#pry-content").html(param[1]);
						$("#pry-content").show("slow");
						moveMark_2(false);
					}else{
						$("#pry-content").hide();
						$("#pry-content").html("<div class='row'><h5 style='padding-right: 15px; padding-left: 15px; display: block;'>ERROR: No fue posible encontrar el módulo correspondiente. (" + url + ")</h5></div>");
						$("#pry-content").show("slow")				
					}					
					changeURL(menu.replace(".",""),url.replace("/",""));
				},
				error: function(XMLHttpRequest, textStatus, errorThrown){					
					swalWithBootstrapButtons.fire({
						icon:'error',								
						title: 'Ups!, no pude cargar el menú del proyecto',					
					});				
				}
			});
		}
		
		function changeURL(menu,submenu){
			var href = window.location.href;
			var newhref = href.substr(href.indexOf("/home")+6,href.length);
			var href_split = newhref.split("/");			
						
			href_split[0]=menu;
			href_split[1]=submenu;
			
			var newurl="/home"
			$.each(href_split, function(i,e){
				newurl=newurl + "/" + e
			});			
			window.history.replaceState(null, "", newurl);
			cargabreadcrumb("/breadcrumbs","");
			
		};
		
		function exportTable(){
			$(".buttonExport").click(function(e){
				e.preventDefault();
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
		
	});
</script>