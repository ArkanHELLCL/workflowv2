var host= window.location.hostname;
var bootstrapTheme = 'bootstrap.min.css';
// jquery extend function
$.extend(
{
    redirectPost: function(location, args)
    {
        var form = $('<form></form>');
        form.attr("method", "post");
        form.attr("action", location);

        $.each( args, function( key, value ) {
            var field = $('<input></input>');

            field.attr("type", "hidden");
            field.attr("name", key);
            field.attr("value", value);

            form.append(field);
        });
        $(form).appendTo('body').submit();
    }
});

//window.history.forward(0);
//window.history.back(0);

$.validator.setDefaults( {
	submitHandler: function (e) {		
		$.ajax({
			type: 'POST',								
			url:$(e).attr('action'),			
			data:$(e).serialize(),
			success: function(data) {
				var param=data.split("//");									
				if(param[0]=="0"){
					Swal.fire({					  
					  icon: 'success',
					  title: 'Credenciales correctas',
					  showConfirmButton: false,
					  timer: 1500					  	
					}).then(function(){
						$.redirectPost('https://' + host , {Page:1,Error:0});
					})
									
				}else{	
					if(param[0]=="-1"){
						Swal.fire({
						  icon: 'info',
						  title: 'Solicitud Exitosa',
						  text: param[1]						  
						}).then(function(){
							$('.form-container').toggleClass('flipped');												
						});
					}else{
						if(param[0]=="-2"){	//Cambio de clave ok
							Swal.fire({					  
								  icon: 'success',
								  title: 'Cambio de Clave exitoso!',
								  text: 'Ingresando al sistema...',
								  showConfirmButton: false,
								  timer: 1500					  	
								}).then(function(){
									$.redirectPost('https://' + host , {Page:1,Error:0});
								})													
						}else{												
							if(param[0]=="3"){	//Clave provisoria
								$("#usr_cod2").val($($("#login")[0][0]).val());
								$("#usr_pass2").val($($("#login")[0][1]).val());
								$('.form-container').toggleClass('flipped2');
								fnvalidate("#new-pass");							
							}else{
								Swal.fire({
								  icon: 'error',
								  title: 'Oops...',
								  text: param[1]						  
								});
							}
						}
					}					
				}									
			},
			error: function(XMLHttpRequest, textStatus, errorThrown){				
				Swal.fire({
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

$(document).ready(function() {
	//'use strict';	
	window.history.forward();
	$('body').addClass("bootstrap");
	$('body').removeClass("bootstrap-dark");
	$(".waves-effect").addClass("waves-light");
	$(".waves-effect").removeClass("waves-dark");
	if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
		// dark mode		
		$('body').addClass("bootstrap-dark");
		$('body').removeClass("bootstrap");
		$(".waves-effect").removeClass("waves-light");
		$(".waves-effect").addClass("waves-dark");
		bootstrapTheme="bootstrap-dark.css";
	}
	var urltheme = "https://" + host + "/vendor/bootstrap/css/" + bootstrapTheme;
	$("#bootstrap-theme").attr('href',urltheme);
	/* CapsLock */    
    $(window).bind("capsOn", function() {
        $("#statetext").html("Bloq Mayus Activado");
    });
    $(window).bind("capsOff", function() {
        $("#statetext").html("");
    });
    
    $(window).capslockstate();    
	
	$("#copyright").show("slow");
	$("#forgot").show("slow");
	
	$("#USR_Cod").focusout(function(){
		var usr_cod=$("#USR_Cod").val();
		$('#UsrPhoto').hide().html("");
		$('#UsrPhoto').fadeIn("slow").html('<img class="image" src="foto/' + usr_cod + '"/>');
		var images = $(".image");
		$(images).on("error", function(event) {
			$(event.target).css("display", "none");			
		});
	});
	$('.toggle').click(function(){
		$('.form-container').toggleClass('flipped');
		$("#copyright2").show("slow");
		$("#forgot2").show("slow");
		fnvalidate("#forgot-pass");
	});
	$('#forgot3').click(function(){
		$('.form-container').toggleClass('flipped2');
	});
	/*$('#forgot3').on("click",".form-container",function(){
		$('.form-container').toggleClass('flipped2');
	});*/
	//Validacion login
	fnvalidate("#login");
	
	$(".viewpass").mousedown(function(){		
		event.preventDefault();        
        key=$(this).data("key");
        $(key).attr('type', 'text');
		$(this).removeClass("fa-eye-slash");
		$(this).addClass("fa-eye");
	}).mouseup(function(){
		event.preventDefault();        
		$('#USR_Pass').attr('type', 'password');
		$('#inputPassword').attr('type', 'password');
		$('#inputPasswordConfirm').attr('type', 'password');
		$(this).addClass("fa-eye-slash");
		$(this).removeClass("fa-eye");
	});
	$("html").mouseup(function(){
		event.preventDefault();        
		$('#USR_Pass').attr('type', 'password');
		$('#inputPassword').attr('type', 'password');
		$('#inputPasswordConfirm').attr('type', 'password');
		$(".viewpass").addClass("fa-eye-slash");
		$(".viewpass").removeClass("fa-eye");
	});
});
function fnvalidate(id){
	$.validator.addMethod(
            "regex",
            function(value, element, regexp) 
            {
                if (regexp.constructor != RegExp)
                    regexp = new RegExp(regexp);
                else if (regexp.global)
                    regexp.lastIndex = 0;
                return this.optional(element) || regexp.test(value);
            },
            "Please check your input."
    );
	$( id ).validate( {
		rules: {			
			USR_Cod: {
				required: true,
				minlength: 4,
				normalizer: function(value) {
					return $.trim(value);
				}
			},
			USR_Pass: {
				required: true,
				minlength: 6
			},
			USR_Mail: {
				required: true
			},
			inputPassword : {
				required: true,
				minlength : 8,
				maxlength : 16,
				regex: /^(?=.*\d)(?=.*[\u0021-\u002b\u003c-\u0040])(?=.*[A-Z])(?=.*[a-z])\S{8,16}$/
			},
			inputPasswordConfirm : {
				required: true,
				minlength : 8,
				maxlength : 16,
				regex: /^(?=.*\d)(?=.*[\u0021-\u002b\u003c-\u0040])(?=.*[A-Z])(?=.*[a-z])\S{8,16}$/,
				equalTo : "#inputPassword"
			}
		},
		messages: {			
			USR_Cod: {
				required: "Por favor, Ingresa tu Usuario",
				minlength: "Tu Usuario debe contener al menos 4 caracteres"
			},
			USR_Pass: {
				required: "Por favor, ingrese tu Clave",
				minlength: "Tu Clave debe contener al menos 8 caracteres"
			},
			USR_Mail: {
				required: "Por favor, ingrese un correo válido",
			},
			inputPassword: {
				required: "Por favor, ungresa una clave",
				minlength: "Tu Clave debe contener al menos 8 caracteres",
				maxlength : "Tu Clave debe ser menor a 16 caracteres",
				equalTo: "Ups!, las claves no coinciden",
				regex: "Debe tener: mayúsculas, minúsculas, número y caracter especial"
			}
		},
		errorElement: "div",
		errorPlacement: function ( error, element ) {
			if(error[0].innerHTML!=""){				
				if(element.prev("i.prefix").length>0){				
					error.css("padding-left","2.5rem");
				}else{
					error.css("padding-left","0rem");					
				}
				error.addClass( "invalid-feedback" );

				if ( element.prop( "type" ) === "checkbox" ) {					
					error.insertAfter( element.parent(".error-message") );				
				} else {					
					error.insertAfter( element.parent(".error-message") );				
				}				
			}
		},
		success: function ( label, element ) {			
		},
		highlight: function ( element, errorClass, validClass ) {			
			$( element ).addClass( "is-invalid" ).removeClass( "is-valid" );
			$(element).siblings("span.select-bar").addClass( "is-invalid" ).removeClass( "is-valid" );		
		},
		unhighlight: function (element, errorClass, validClass) {			
			$( element ).addClass( "is-valid" ).removeClass( "is-invalid" );
			$(element).parent().next().remove();
			$(element).siblings("span.select-bar").addClass( "is-valid" ).removeClass( "is-invalid" );
		}			
	});
}