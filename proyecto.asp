<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="include\template\session.min.inc" -->
<%	
	VFL_Id=request("key1")	
	DRE_Id=request("key2")
	FLU_Id=request("key3")
	modo=request("modo")
	tabId = request("tabId")
		
	if(VFL_Id="") then
		VFL_Id=0
	end if
	if(DRE_Id="") then
		DRE_Id=0
	end if
	if(FLU_Id="") then
		FLU_Id=0
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

	if (DRE_Id<>"" and DRE_Id<>0) then		'Cuando el requerimiento ya existe
		sql="exec spDatoRequerimiento_Consultar " & DRE_Id 
		set rs = cnn.Execute(sql)
		if not rs.eof then		
			VFL_Id = rs("VFL_Id")
			REQ_Id = rs("REQ_Id")
			titulo = rs("FLU_Descripcion") & " V." & VFL_Id & " R." & REQ_Id
			FLD_Id = rs("FLD_Id")	
			REQ_Ano = rs("REQ_Ano")
		else
			FLD_Id=0
		end if
	else
		if(VFL_Id=0 and FLU_Id<>0) then
			sql="exec spUltimaVersionFlujo_Consultar " & FLU_Id
			set rs = cnn.Execute(sql)
			if not rs.eof then				
				VFL_Id = rs("VFL_Id")
				titulo = rs("FLU_Descripcion") & " V." & VFL_Id
			end if
		end if
		if VFL_Id<>"" and VFL_Id<>0 then
			sql="exec spFlujoDatos_Listar " & VFL_Id & ", 1"
			set rs = cnn.Execute(sql)
			if not rs.eof then		
				titulo = rs("FLU_Descripcion") & " V." & VFL_Id
				FLD_Id = rs("FLD_Id")
			end if
		else
			VFL_Id=0
		end if	
	end if
	
	if(VFL_Id="" or VFL_Id=0) and (FLU_Id="" or FLU_Id=0) then
		ErrMsg="No se pudo encontrar Flujo/Formulrio"
		response.Write("404/@/Error :" & ErrMsg)
	   	response.End()		   
	end if

	if(session("wk2_usrperfil")=5) then		'Auditor		
		modo=4
	end if			

	gradiente="blue-gradient"	
				
	'response.write("200/@/ proyecto.asp VFL_Id: " & VFL_Id & ",FLD_Id: " & FLD_Id & ", modo: " & modo)	
	response.write("200/@/")
	'response.end

	anio=year(date())
	if(modo=1) then
		PRY_Anio = anio
	else
		PRY_Anio = REQ_Ano
	end if
	titulo = titulo & " - " & PRY_Anio
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
				<a href="" class="white-text mx-3"><i class="fas fa-sitemap"></i> <%=titulo%></a>
				<div>
				</div>
			</div>
			<!--/Card image-->
			<div class="px-4">
				<div class="row flex-nowrap" style="overflow:hidden">
					<div class="col-auto div">
						<div id="pry-menu">
							<div class="res" id="pasos" disabled></div>
							<!--<div class="res" id="hitos" disabled></div>-->
							<div class="res" id="menus" disabled></div>							
							<i class="fas fa-thumbtack pin text-primary"></i>
							<div id="pry-menucontent"></div>
						</div>
					</div>
					<div class="col">
						<!--<div id="pry-scrollconten">-->
							<div id="pry-content"></div>
						<!--</div>-->
					</div>
				</div>
			</div>
		</div>
		<!-- Table with panel -->		
	</div>	  	
</div>
<input type="hidden" id="VFL_Id" name="VFL_Id" value="<%=VFL_Id%>"/>
<input type="hidden" id="DRE_Id" name="DRE_Id" value="<%=DRE_Id%>"/>
<input type="hidden" id="FLU_Id" name="FLU_Id" value="<%=FLU_Id%>"/>
<!--container-body-->


<!-- Modal Informes-->
<div class="modal fade bottom" id="informesflujoModal" tabindex="-1" role="dialog" aria-labelledby="informesflujoModalLabel" aria-hidden="true">		
</div>
<!-- Modal Informes-->
<!-- Modal Mensajes-->
<div class="modal fade bottom" id="mensajesreqModal" tabindex="-1" role="dialog" aria-labelledby="mensajesreqModalLabel" aria-hidden="true">		
</div>
<!-- Modal Mensajes-->
<!-- Modal Adjuntos-->
<div class="modal fade bottom" id="adjuntosreqModal" tabindex="-1" role="dialog" aria-labelledby="adjuntosreqModalLabel" aria-hidden="true">		
</div>
<!-- Modal Adjuntos-->

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
		//Requerimiento
		//var VFL_Id=$("#VFL_Id").val();						
		var ss = String.fromCharCode(47) + String.fromCharCode(47);
		var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);
		var bb = String.fromCharCode(92) + String.fromCharCode(92);	
		var data;
		var modo=<%=modo%>
		var REQ_Descripcion="";	
		var DRE_Id=<%=DRE_Id%>;
		var VFL_Id=<%=VFL_Id%>;
		var tabId="<%=tabId%>";
		$("#pry-menu, #pry-scrollconten").mCustomScrollbar({
			theme:scrollTheme			
		})		
		$("#pry-menu").mCustomScrollbar("scrollTo","bottom")
		
		if(modo==1 && DRE_Id==0){
			//Preguntar si mi perfil puede crear un proyecto para el flujo actual
			$.ajax( {
				type:'POST',					
				url: '/consulta-permiso-creacion',
				data: {VFL_Id:VFL_Id},
				dataType: "json",
				success: function ( json ) {					
					if(json.data[0].code=="200" && json.data[0].response=="1"){
						swalWithBootstrapButtons.fire({
							icon:'info',
							title: 'Nuevo Requerimiento \n <%=titulo%>',
							text: 'Ingresa una descripción resumida para identificar a este nuevo Requerimiento',
							input: 'textarea',
							inputValue: "",
							showCancelButton: true,
							confirmButtonText: '<i class="fas fa-check"></i> Crear Requerimiento',
							cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar',
							inputValidator: (value) => {
							if (!value) {
								return 'Debes escribir una descripción para crear este Requerimiento';
							}
							if (value.length < 10) {
								return 'La descripción debe tener al menos 10 caracteres';
							}
							if (value.length > 100) {
								return 'La descripción no debe exceder los 100 caracteres';
							}							
						}
						}).then((result) => {
							if(result.value){	
								REQ_Descripcion = result.value
								data   = {modo:modo,VFL_Id:<%=VFL_Id%>,REQ_Descripcion:REQ_Descripcion,tabId:tabId};
								//Creacion del requerimiento					
								var content;
								$("#pry-content").html("Cargando el modulo...");
								$("#pry-content").append("<div class='loader_wrapper'><div class='loader'></div></div>");
								$.ajax( {
									type:'POST',					
									url: '/crear-requerimiento',
									data: data,
									success: function ( datos ) {
										param = datos.split(sas)			
										if(param[0]==200){                
											if(modo==1){
												$.ajax( {
													type:'POST',					
													url: '/formulario',
													data: {modo:modo,REQ_Id:param[1],VRE_Id:param[2],DRE_Id:param[3]},
													success: function ( dato ) {
														param2 = dato.split(sas)                            
														if(param2[0]==200){    
															content=param2[1]
															$("#pry-content").css("display","none")
															//$("#pry-content").hide();
															$("#pry-content").html(content);				
															//$("#pry-content").show("fast")
															$("#pry-content").css("display","block")
															data   = {modo:modo,VFL_Id:<%=VFL_Id%>,DRE_Id:param[3],tabId:tabId};
															cargamenu();
														}
													}
												})								
											}								
										}else{				
											$("#pry-content").css("display","none")
											//$("#pry-content").hide();
											$("#pry-content").html("<div class='row'><h5 style='padding-right: 15px; padding-left: 15px; display: block;'>ERROR: No fue posible encontrar el módulo correspondiente.</h5></div>");
											//$("#pry-content").show("fast")
											$("#pry-content").css("display","block")
										}			
									},
									error: function(XMLHttpRequest, textStatus, errorThrown){				
										swalWithBootstrapButtons.fire({
											icon:'error',								
											title: 'Ups!, no pude cargar los campos del Requerimiento'					
										});				
									},
									complete: function(){
										$(".loader_wrapper").remove();
									}
								});
							}else{
								cargacomponente("/bandeja-de-entrada",{});														
								var newurl="/home/bandeja-de-entrada"									
								window.history.replaceState(null, "", newurl);
								cargabreadcrumb("/breadcrumbs",{tabId:tabId});
							}
						})
					}else{
						swalWithBootstrapButtons.fire({
							icon:'error',								
							title: 'Ups!, Tu perfil no permite crear requerimientos para este flujo',
						});
						cargacomponente("/bandeja-de-entrada",{});														
						var newurl="/home/bandeja-de-entrada"									
						window.history.replaceState(null, "", newurl);
						cargabreadcrumb("/breadcrumbs",{tabId:tabId});
					}
				}
			})

			
		}else{
			data   = {modo:modo,DRE_Id:<%=DRE_Id%>,tabId:tabId};
			cargamenu();
		}
				
		//cargabreadcrumb("/breadcrumbs","");				
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
				url: '/menu-flujo',
				data: data,
				success: function ( data ) {
					param = data.split(sas)
					if(param[0]==200){						
						$("#pry-menucontent").html(param[1]);						
						var pasosPos = $("#pry-menu ul").find("li.category.pasos").position();
						var menusPos = $("#pry-menu ul").find("li.category.menus").position();						
						if(pasosPos!=undefined && menusPos!=undefined){
							if($("li.category.pasos").index()==0){
								$("#pasos").css("top",pasosPos.top + "px")
								$("#pasos").show();
							}else{
								$("#pasos").css("top",(pasosPos.top + 2) + "px")
								$("#pasos").show();
							}						
							if(menusPos!=undefined){
								if($("li.category.menus").index()==0){
									$("#menus").css("top",menusPos.top + "px")
									$("#menus").show();
								}else{
									$("#menus").css("top",(menusPos.top + 18) + "px")
									$("#menus").show();
								}
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
									moveMark(true);									
									if(!pinmenu){
										setTimeout(function() {			
											//$("#pry-menu").toggleClass("show");
										}, 500);
									}
								}, 500);				
							}, 500);
						}else{
							setTimeout(function() {						
								moveMark(true);								
							}, 500);		
						}
						
					}else{
						swalWithBootstrapButtons.fire({
							icon:'error',								
							title: 'Ups!, no pude cargar el menú del Requerimiento',					
							text:param[1]
						});				
					}
				},
				error: function(XMLHttpRequest, textStatus, errorThrown){					
					swalWithBootstrapButtons.fire({
						icon:'error',								
						title: 'Ups!, no pude cargar el menú del Requerimiento',					
					});				
				}
			});
		};
				
		$("#pry-menu").on("click",".menus",function(e){
			e.preventDefault();
			e.stopPropagation();
			
			data   = {modo:modo,DRE_Id:<%=DRE_Id%>};
			$(".menus").removeClass("active");
			$(".menus a").removeClass("current");
			$(this).addClass("active");
			moveMark(false);			
			var ajaxurl=$(this).children().data("url");							
			$.ajax( {
				type:'POST',					
				url: ajaxurl,
				data: data,
				success: function ( data ) {
					param = data.split(bb)
					if(param[0]==200){							
						$(param[1]).html(param[2]);						
						moveMark(false);
					}else{
						swalWithBootstrapButtons.fire({
							icon:'error',								
							title: 'Ups!, no pude cargar el menú del Requerimiento.',					
							text:param[1]
						});				
					}
				},
				error: function(XMLHttpRequest, textStatus, errorThrown){					
					swalWithBootstrapButtons.fire({
						icon:'error',								
						title: 'Ups!, no pude cargar el menú del Requerimiento',					
					});				
				}
			});			
		})		
																				
		$(".modal").on('hidden.bs.modal', function(){
			$(".menus").removeClass("active");
			$(".menus a").removeClass("current");
			$(".menus").first("li").addClass("active")						
			moveMark(false);				
		});											
		
		$("#pry-menu").on("click",".step",function(e){
			e.preventDefault();
			e.stopPropagation();
			//var sPRY_Hito = $(this).data("hito");
			var DRE_Id 	= $(this).data("dre");
			var VFL_Id	= $(this).data("vfl");
			var id		= $(this).data("id");
			var smodo	= $(this).data("mode");	
			var ss		= String.fromCharCode(47) + String.fromCharCode(47);
			var	pasos	= false;			
			var	menus	= false;

			if($(this).parent(".pasos")){
				pasos = true
			};			
			if($(this).parent(".menus")){
				menus = true
			};							
			var data   = {modo:smodo,DRE_Id:DRE_Id,id:id};
			var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);			
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
							title: 'Ups!, no pude cargar el menú del Requerimiento1',					
							text:param[1]
						});				
					}
				},
				error: function(XMLHttpRequest, textStatus, errorThrown){					
					swalWithBootstrapButtons.fire({
						icon:'error',								
						title: 'Ups!, no pude cargar el menú del Requerimiento',					
					});				
				}
			});
		})
		
	});
	function modificaurl(VFL_Id, DRE_Id,mode){
		var href = window.location.href;
		var newhref = href.substr(href.indexOf("/home")+6,href.length);
		var href_split = newhref.split("/")

		href_split[1]=mode;
		href_split[2]=VFL_Id;
		href_split[3]=DRE_Id;									
		var newurl="/home"
		$.each(href_split, function(i,e){
			newurl=newurl + "/" + e
		});
		window.history.replaceState(null, "", newurl);
		cargabreadcrumb("/breadcrumbs",{tabId:"<%=tabId%>"});
	}
</script>