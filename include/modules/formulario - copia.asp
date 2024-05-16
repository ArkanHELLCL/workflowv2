<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<!-- #INCLUDE FILE="functions.inc" -->
<%	
	DRE_Id=request("DRE_Id")	'Continuacion

	id=request("id")
	modo=request("modo")	
	Departamento=request("Departamento")
	action="/formulario-grabar"	
	VerFor = ""
	disabled = ""
	readonly = false

	'Listas desplegables
	TipoDocumento=14
	TipoMoneda=4
	
	if(modo="") then
		modo=2
	end if
	If(id="") then
		id=0
	end if

	if(DRE_Id="" or DRE_Id=0) then
		ErrMsg="No fue posible encontrar el registro del detalle del requerimiento"
		response.Write("404/@/Error : " & ErrMsg)
		response.End()
	end if

	if(session("wk2_usrperfil")=5) then		
		modo=4
		disabled="readonly dta='1'"
	end if

	lblClass=""
				
	set cnn = Server.CreateObject("ADODB.Connection")
	on error resume next	
	cnn.open session("DSN_WorkFlowv2")
	if cnn.Errors.Count > 0 then 
	   ErrMsg = cnn.Errors(0).description	   
	   cnn.close
	   response.Write("503/@/Error Conexión 1:" & ErrMsg)
	   response.End() 			   
	end if

	ssql="exec spDatoRequerimiento_Consultar " & DRE_Id		
	set rs = cnn.Execute(ssql)		
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 2:" & ErrMsg)
		response.End()		
	end if

	if not rs.eof then
		FLD_Id								= rs("FLD_Id")
		ESR_DescripcionFlujoDatos 			= rs("ESR_DescripcionFlujoDatos")
		ESR_IdFlujoDatos					= rs("ESR_IdFlujoDatos")
		ESR_AccionFlujoDatos				= rs("ESR_AccionFlujoDatos")
		VFO_Id 								= rs("VFO_Id")
		VerFor 								= "V." & VFO_Id
		DRE_FechaEdit						= rs("DRE_FechaEdit")
		REQ_Descripcion 					= rs("REQ_Descripcion")
		IdEditor							= rs("IdEditor")			
		USR_JefaturaCreador					= rs("USR_JefaturaCreador")
		NombreEditor						= rs("NombreEditor")
		ApellidoEditor						= rs("ApellidoEditor")
		USR_JefaturaEditor					= rs("USR_JefaturaEditor")
		DEP_IdActual						= rs("DEP_IdActual")
		DEP_IdFlujo							= rs("DEP_Id")		'NULL si es jefatura
		DepDescripcionActual				= rs("DepDescripcionActual")
		ESR_IdDatoRequerimiento				= rs("ESR_IdDatoRequerimiento")
		ESR_DescripcionDatoRequerimiento	= rs("ESR_DescripcionDatoRequerimiento")
		ESR_AccionDatoRequerimiento			= rs("ESR_AccionDatoRequerimiento")
		VFL_Id								= rs("VFL_Id")
		REQ_Id								= rs("REQ_Id")
		ReqNro								= "R." & REQ_Id
		FLD_Prioridad						= rs("FLD_Prioridad")
		DRE_SubEstado						= rs("DRE_SubEstado")
		FLD_InicioTermino					= rs("FLD_InicioTermino")
		FLD_IdHijoSi						= rs("FLD_IdHijoSi")
		VRE_Id								= rs("VRE_Id")
		FLU_Id								= rs("FLU_Id")
		DRE_Observaciones					= rs("DRE_Observaciones")

		accion								= ESR_AccionFlujoDatos
		estado								= ESR_DescripcionFlujoDatos
		if(IsNULL(IdEditor)) then
			IdEditor=0
		end if		
		if(ESR_IdDatoRequerimiento=1 or ESR_IdDatoRequerimiento=7 or ESR_IdDatoRequerimiento=5) then
			'Creacion, Cierre y Rechazo
			accion								= ESR_AccionDatoRequerimiento
			estado								= ESR_DescripcionDatoRequerimiento
		end if
		acc=accion
		est=estado
	else
		ErrMsg="No fue posible encontrar el registro del detalle del requerimiento"
		response.Write("404/@/Error : " & ErrMsg)
		response.End()
	end if

	'Preguntar si el perfil actual tiene permiso para el flujo actual
    FLU_IdPerfil=false
    tl="exec [spUsuarioVersionFlujo_Listar] 1," & session("wk2_usrid")       'Todos flujos asociados al usuario actual
    set tr = cnn.Execute(tl)
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description
		response.write("Error [spUsuarioVersionFlujo_Listar]")
		cnn.close 		
		response.end
	End If	
    do while not tr.eof
        if(FLU_Id=tr("FLU_Id")) then
            'tiene asignado este flujo
            FLU_IdPerfil=true
            exit do
        end if
        tr.movenext
    loop

	'Buscar el ultimo regitro del flujo
	lr="exec [spFlujoDatosUltimoRegistro_Consultar] " & VFL_Id & ",1"		
	set ww = cnn.Execute(lr)		
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 2:" & ErrMsg)
		response.End()		
	end if

	if not ww.eof then
		if(CInt(FLD_Id) = CInt(ww("FLD_Id"))) then
			accion = "Finalizar - " & accion
		end if
		FLD_IdFlujoMax = ww("FLD_Id")
	end if	
	'Buscar el ultimo regitro del flujo

	'Buscar paso de bifurcacion
	if(FLD_IdHijoSi<>0 and not IsNULL(FLD_IdHijoSi)) then
		rl="exec spFlujoDatos_Consultar " & FLD_IdHijoSi		
		set sw = cnn.Execute(rl)		
		on error resume next
		if cnn.Errors.Count > 0 then 
			ErrMsg = cnn.Errors(0).description			
			cnn.close 			   
			response.Write("503/@/Error Conexión 2:" & ErrMsg)
			response.End()		
		end if

		if not sw.eof then
			DEP_IdActualD						= sw("DEP_Id")
			DepDescripcionActualD				= sw("DEP_Descripcion")			
		end if
	end if

	editor=0
	if(IsNULL(VFO_Id) and DRE_SubEstado=1 and IdEditor=session("wk2_usrid")) then	'Solo en estado creación
		accion="Creación"
		VerFor=""
		txtBoton="<i class='fas fa-paper-plane'></i> " & abreviar(Departamento)
		btnColor="btn-success"
		btnname="btn_frm10s1"
		tooltip="Guardar y enviar"
	else
		if(ESR_IdDatoRequerimiento=2) and (IdEditor=session("wk2_usrid") and DRE_SubEstado=1) then
			'accion=ESR_DescripcionFlujoDatos
			'accion=estado
			if(CInt(FLD_InicioTermino)=2) then
				txtBoton5="&nbsp;<i class='fas fa-check-square'></i>&nbsp;"
				btnColor5="btn-secondary"
				btnname5="btn_frm10s5"
				tooltip5="Guardar y finalizar"
			end if

			if(FLD_IdHijoSi<>0) and (CInt(FLD_InicioTermino)<>2) then
				txtBoton6="<i class='fas fa-paper-plane'></i> " & abreviar(DepDescripcionActualD)
				btnColor6="btn-success"
				if(CInt(FLD_InicioTermino)<>3) then
					btnname6="btn_frm10s6"
				else
					btnname6="btn_frm10s1"
				end if
				tooltip6="Guardar y enviar"				
			end if

			if(CInt(FLD_InicioTermino)<>3 and CInt(FLD_IdFlujoMax)<>CINt(FLD_Id)) then
				'Solo si no es tl ultimo registro del flujo
				txtBoton="<i class='fas fa-paper-plane' style='transform: rotate(270deg)'></i> " & abreviar(Departamento)
				btnColor="btn-success"
				btnname="btn_frm10s1"
				tooltip="Guardar y enviar"
			end if
			
			editor=1

			txtBoton3="&nbsp;<i class='fas fa-times'></i>&nbsp;"
			btnColor3="btn-danger"
			btnname3="btn_frm10s3"
			tooltip3="Rechazar"

			if(FLD_InicioTermino<>1) then
				txtBoton4="&nbsp;<i class='fas fa-undo'></i>&nbsp;"
				btnColor4="btn-warning"
				btnname4="btn_frm10s4"
				tooltip4="Devolver"

				txtBoton9="&nbsp;<i class='fas fa-sign-out-alt'></i>&nbsp;"
				btnColor9="btn-primary"
				btnname9="btn_frm10s9"
				tooltip9="Liberar"
			end if

			'Agregando boton Finalizar, Nuevo fin, estado 4, todas las opciones mas finalizar el flujo
			'if(CInt(ESR_IdFlujoDatos)=7) then
			if(CInt(FLD_InicioTermino)=4) then			
				txtBoton5="&nbsp;<i class='fas fa-check-square'></i>&nbsp;"
				btnColor5="btn-secondary"
				btnname5="btn_frm10s5"
				tooltip5="Guardar y finalizar"
			end if
		else
			'Se debe revisar propiedad del estado actual del requerimiento, perfil y departamento del perfil actual.
			'1=Super Admin, puede tomar cualquier requerimiento de cualquier flujo y de cualquier departamento.
			'2=Administrador, puede tomar cualquier requerimeinto simpre y cuando sea de la mismo departamento que el.
			'3=Revisor, puede tomar cualquier requerimiento de su departamento, siempre y cuando ya no este tomado. y este no sea ESR_Id=4 (Visado) ni ESR_Id=8 (Aprobado)
			'//***4=Solcitante, solo puede tomar los requerimeinto de su departamento, que no esten tomados.***//
			'4=Solcitante : actualización, solo puede crear he interactuar, cuando corresponda, con los requerimientos, no puede tomarlos, a menos que sea jefatura
			'5=Auditor, solo pude ver los requerimiento, cualquiera sea su estado o propietario.
			'if(session("wk2_usrperfil")=1) and (IdEditor<>session("wk2_usrid") and DRE_SubEstado=1) then
			'if(session("wk2_usrperfil")=1) and (IdEditor<>session("wk2_usrid") and DRE_SubEstado=1) or (session("wk2_usrperfil")=2 and IdEditor<>session("wk2_usrid") and DRE_SubEstado=1 and FLU_IdPerfil) or (IdEditor<>session("wk2_usrid") and DRE_SubEstado=1 and session("wk2_usrdepid")=DEP_IdACtual and IsNULL(DEP_IdFlujo) and session("wk2_usrjefatura")=1) or (IdEditor<>session("wk2_usrid") and DRE_SubEstado=1 and session("wk2_usrdepid")=DEP_IdACtual and not IsNULL(DEP_IdFlujo) and session("wk2_usrperfil")<>4) or (IdEditor<>session("wk2_usrid") and DRE_SubEstado=1 and session("wk2_usrdepid")=DEP_IdACtual and session("wk2_usrjefatura")=1) then			
			if(session("wk2_usrperfil")=1) and (IdEditor<>session("wk2_usrid") and DRE_SubEstado=1) or (session("wk2_usrperfil")=2 and IdEditor<>session("wk2_usrid") and DRE_SubEstado=1 and FLU_IdPerfil) or (IdEditor<>session("wk2_usrid") and DRE_SubEstado=1 and session("wk2_usrdepid")=DEP_IdACtual and IsNULL(DEP_IdFlujo) and session("wk2_usrjefatura")=1) or (IdEditor<>session("wk2_usrid") and DRE_SubEstado=1 and session("wk2_usrdepid")=DEP_IdACtual and not IsNULL(DEP_IdFlujo) and (session("wk2_usrperfil")=1 or session("wk2_usrperfil")=2 or (session("wk2_usrperfil")=3 and (ESR_IdFlujoDatos<>4 and ESR_IdFlujoDatos<>8)))) or (IdEditor<>session("wk2_usrid") and DRE_SubEstado=1 and session("wk2_usrdepid")=DEP_IdACtual and session("wk2_usrjefatura")=1) then			
				'1=Super Admin, y no es propietario del requerimiento, cualquier estado, cualquier departamento
				'2=Administrador y pertenece al mismo flujo del requerimiento.
				'3=Revisor que pertenece el mismo departamento del requerimiento //Y que el ESR_Id sea <> 4 (Visado) y ESR_Id<>8 (Aprobado) (Agregar logica)
				'//***4=Solcitante que pertenece el mismo departamento del requerimiento***//
				txtBoton2="<i class='fas fa-hand-holding'></i> Tomar"
				btnColor2="btn-primary"
				btnname2="btn_frm10s2"
				accion="Tomar"
				readonly=true
			else
				if(DRE_SubEstado=1) then
					accion="Visualizar - " & estado & " pendiente "
				else
					accion="Visualizar - " & estado & " por: " & NombreEditor & " " & ApellidoEditor & " - " & DRE_FechaEdit
				end if
				txtBoton=""
				btnColor=""
				btnname=""
				readonly=true				

				'Botones para avanzar o retroceder
				if(id>1) then
					txtBoton7="&nbsp;<i class='fas fa-backward'></i>&nbsp;"
					btnColor7="btn-info"
					btnname7="btn_frm10s7"
					tooltip7="Retroceder"
				end if
				if(CInt(FLD_IdFlujoMax)>CInt(FLD_Id) and ESR_IdDatoRequerimiento<>5 and ESR_IdDatoRequerimiento<>7) and (IdEditor<>0) then
					txtBoton8="&nbsp;<i class='fas fa-forward'></i>&nbsp;"
					btnColor8="btn-info"
					btnname8="btn_frm10s8"
					tooltip8="Avanzar"
				end if

				'Abrir requerimiento solo cuando se haya cerrado.
				'Super siempre, sea propietario o no
				'Admin solo si pertenece al flujo sea propietario o no
				if(session("wk2_usrperfil")=1 and ESR_IdDatoRequerimiento=7) or (session("wk2_usrperfil")=2 and ESR_IdDatoRequerimiento=7 and FLU_IdPerfil) then
					txtBoton10="&nbsp;<i class='fas fa-lock-open'></i>&nbsp;"
					btnColor10="btn-secondary"
					btnname10="btn_frm10s10"
					tooltip10="Abrir"
				end if				
			end if
		end if
	end if	

	'Buscar informe obligatorio que aun este pendiente de creacion
    tsql="exec [spInformesCertificadosxVersion_Listar] " & REQ_Id & "," & VFL_Id & "," & FLD_Id & ", 1"
    set rs = cnn.Execute(tsql)		
    on error resume next
    if cnn.Errors.Count > 0 then 
        ErrMsg = cnn.Errors(0).description			
        cnn.close 			   
        response.Write("503/@/Error Conexión 2:" & ErrMsg)
        response.End()
    End If
	informeslistos=0
    informespendientes=0
    certificadoslistos=0
    certificadospendientes=0
    pendientes=0
    listos=0
	do while not rs.eof
        if(rs("INF_Obligatorio")) then
            'Solo si es obligatorio    
			if(IsNULL(rs("CER_Id"))) then
				'El informe no es certificado            
				if(rs("INF_Estado")=1) then
					'Ya se encuentra disponible
					informeslistos=informeslistos+1
				else
					'Se debe crear
					informespendientes=informespendientes+1
				end if            
			else
				'El informe es un certificado
				if(not IsNULL(rs("VCE_Id"))) then
					'El informe tiene un certificado generado
					certificadoslistos=certificadoslistos+1
				else
					'No existe ningun certificado generado
					certificadospendientes=certificadospendientes+1
				end if
			end if		
		end if
        rs.movenext
    loop
	pendientes=certificadospendientes+informespendientes
    listos=informeslistos+certificadoslistos	

	sql="exec spVersionxPrioridad_Listar " & session("wk2_usrid") & "," & VFL_Id
	set rs = cnn.Execute(sql)	
	on error resume next
	if cnn.Errors.Count > 0 then 
		ErrMsg = cnn.Errors(0).description			
		cnn.close 			   
		response.Write("503/@/Error Conexión 3:" & ErrMsg)
		response.End()
	End If	
	
	'response.write("200/@/formulario.asp DRE_Id: " & DRE_Id & ",FLD_Id: " & FLD_Id & ",FLD_Prioridad: " & FLD_Prioridad & ",FLD_inicioTermino:" & FLD_InicioTermino & ",modo: " & modo & ",id: " & id & ", readonly: " & readonly & ", disbaled: " & disabled & ",Id_DepActual: " & DEP_IdActual & ",IdEditor: " & IdEditor & ",ESR_Id: " & ESR_Id & ",ultimo: " & ultimo)
	response.write("200/@/")%>

<form role="form" action="<%=action%>" method="POST" name="frm10s1" id="frm10s1" class="needs-validation">
	<div id="pry-scrollconten">
		<% 	
			if(DRE_Observaciones<>"") then%>
				<h5 style="float: right;"><i class="fa fa-info-circle verobs" aria-hidden="true" title="Ver observaciones" style="cursor:pointer;margin: 0;width: auto;"></i></h5><%
			end if
		%>
		<h5><%=accion%></h5>
		<h5><%=REQ_Descripcion%></h5>
		<br>
		<h6>Datos del formulario <%=VerFor%></h6><%
		adjuntos = "{"
		ruts = "{"
		cont = 0	'Adjuntos
		conr = 0	'Ruts
		regcont=0
		proveedor=false%>
		<div class="row"><%
		do while not rs.eof
			regcont=regcont+1
			FDI_Id = rs("FDI_Id")
			DFO_Dato=""	
			descargar = false	
			if(DRE_Id<>0 and DRE_Id<>"") then		'Solo cuando el formulario exista
				zzql="exec spDatosFormularioxVersion_Consultar " & DRE_Id & "," & FDI_Id
				set rz = cnn.Execute(zzql)		
				on error resume next
				if cnn.Errors.Count > 0 then 
					ErrMsg = cnn.Errors(0).description			
					cnn.close 			   
					response.Write("503/@/Error Conexión 6:" & ErrMsg)
					response.End()
				End If
				if not rz.eof then
					DFO_Dato = rz("DFO_Dato")
					Sindato=false
				else
					Sindato=true
				end if
			end if
			
			if(CInt(rs("FDI_PasoActivacion")) <= CInt(FLD_Prioridad)) and (rs("FDI_Estado")=1) then
			'Paso de activacion desde el inicio o en el paso que se encuentra o si esditable siempre no importa el paso en que este el requerimiento
			'Ademas cuando el formulario existe pero no tiene todos los campos almacenados(por diseño) mostrar los los campos grabados
				if(CInt(rs("FDI_NuevaLineaDiseno"))=1) then%>
					</div>
					<div class="row"><%
				end if%>
				<div class="col-sm-12 col-md-<%=rs("FDI_TamanoDiseno")%> col-lg-<%=rs("FDI_TamanoDiseno")%>">
					<div class="md-form input-with-post-icon">
						<div class="error-message">								
							<i class="<%=rs("FDI_IconoDiseno")%> input-prefix"></i><%
							if(not readonly) then
								'Campos del formulario editable					
								disselect=false				
								'if(CInt(rs("FDI_PasoActivacion")) <> CInt(FLD_Prioridad)) and (CInt(rs("FDI_EditableSiempre"))<>1) then
								if(CInt(rs("FDI_PasoActivacion")) <> CInt(FLD_Prioridad)) and ((CInt(rs("FDI_EditableSiempre"))<>1) or (CInt(rs("FDI_EditableSiempre"))=1) and (ESR_IdFlujoDatos = 4 or ESR_IdFlujoDatos = 22)) then
									disabled="readonly dta='5'"
									seleccion="disabled dta='5'"
									disselect = true
									calendar = ""
								else
									'Activacion por el paso actual o si el campo es editable siempre
									if((session("wk2_usrid")<>IdEditor) and modo<>1) then						
										disabled="readonly dta='6'"
										seleccion="disabled dta='6'"
										disselect = true
										calendar = ""
									else
										if(rs("FDI_CampoObligatorio")=1) then
											disabled="required"
											seleccion="required"
											disselect = false
											calendar = "calendario"
										else
											disabled=""
											seleccion=""
											disselect = false
											calendar = ""
										end if					
									end if
								end if
								Select Case trim(ucase(rs("FDI_TipoCampo")))
									Case "T"	'TextArea%>
										<textarea id="dta-<%=rs("FDI_NombreHTML")%>" name="dta-<%=rs("FDI_NombreHTML")%>" class="md-textarea form-control" rows="3" <%=disabled%>><%=DFO_Dato%></textarea><%
									Case "A"	'Adjunto
										if(cont=0) then
											adjuntos = adjuntos & """adjunto""" & ":" &	"""dta-" & rs("FDI_NombreHTML") & """"
										else
											adjuntos = adjuntos & "," & """adjunto""" & """dta-" & rs("FDI_NombreHTML") & """"
										end if
										cont = cont + 1													
										if(not disselect) then%>
											<input type="text" id="dta-<%=rs("FDI_NombreHTML")%>X" name="dta-<%=rs("FDI_NombreHTML")%>X" class="form-control" <%=seleccion%>>
											<input type="file" id="dta-<%=rs("FDI_NombreHTML")%>" name="dta-<%=rs("FDI_NombreHTML")%>" readonly="" multiple accept="image/png,image/x-png,image/jpg,image/jpeg,image/gif,application/x-msmediaview,application/vnd.openxmlformats-officedocument.presentationml.presentation,	application/vnd.openxmlformats-officedocument.wordprocessingml.document,application/pdf, application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/msword,application/vnd.ms-powerpoint" style="display: none;width: 0;height: 0;"><%
										else%>
											<input type="text" class="form-control dowadj" <%=disabled%> data-vfo="<%=VFO_id%>" data-dre="<%=DRE_Id%>" value="Descargar Adjuntos" style="cursor:pointer"><%
											descargar = true
										end if
									Case "F"	'Fecha%>
										<input type="text" id="dta-<%=rs("FDI_NombreHTML")%>" name="dta-<%=rs("FDI_NombreHTML")%>" class="form-control <%=calendar%>" <%=disabled%> value="<%=DFO_Dato%>"><%
									Case "V"	'Fecha Vencimiento%>
										<input type="text" id="dta-<%=rs("FDI_NombreHTML")%>" name="dta-<%=rs("FDI_NombreHTML")%>" class="form-control <%=calendar%>" <%=disabled%> value="<%=DFO_Dato%>"><%
									Case "R"	'Rut
										if(conr=0) then
											ruts = ruts & """rut""" & ":" &	"""dta-" & rs("FDI_NombreHTML") & """"
										else
											ruts = ruts & "," & """rut""" & """dta-" & rs("FDI_NombreHTML") & """"
										end if
										conr = conr + 1%>
										<input type="text" id="dta-<%=rs("FDI_NombreHTML")%>" name="dta-<%=rs("FDI_NombreHTML")%>" class="form-control rut" <%=disabled%> value="<%=DFO_Dato%>"><%
									Case "N"	'Numero
										DFO_Dato=replace(DFO_Dato,",",".")
										splitdato=split(trim(DFO_Dato),".")
										ultimo=ubound(splitdato)
										if(len(splitdato(ultimo))=3) then
											DFO_Dato = replace(DFO_Dato,".","")
										else
											paso=""
											if(ultimo-1)>0 then
												for i=0 to (ultimo-1)
													paso=paso & splitdato(i) 
												next
												DFO_Dato=paso & "," & splitdato(ultimo)
											else
												DFO_Dato=DFO_Dato
											end if
										end if%>
										<input type="number" id="dta-<%=rs("FDI_NombreHTML")%>" name="dta-<%=rs("FDI_NombreHTML")%>" class="form-control" <%=disabled%> value="<%=DFO_Dato%>" step="1"><%
									Case "D"	'Decimal
										DFO_Dato=replace(DFO_Dato,",",".")
										splitdato=split(trim(DFO_Dato),".")
										ultimo=ubound(splitdato)
										if(len(splitdato(ultimo))=3) then
											DFO_Dato = replace(DFO_Dato,".","")
										else
											paso=""
											if(ultimo-1)>0 then
												for i=0 to (ultimo-1)
													paso=paso & splitdato(i) 
												next
												DFO_Dato=paso & "," & splitdato(ultimo)
											else
												DFO_Dato=DFO_Dato
											end if
										end if%>
										<input type="number" id="dta-<%=rs("FDI_NombreHTML")%>" name="dta-<%=rs("FDI_NombreHTML")%>" class="form-control" <%=disabled%> value="<%=DFO_Dato%>" step=".01" data-msg-step="Debes ingresar solo 2 decimales"><%
									Case "L"	'Lista Desplegable
										if(not disselect) then
											ILD_Descripcion=""
											if(not IsNULL(DFO_Dato) and DFO_Dato<>"") then
												yql="exec spItemListaDesplegable_Consultar " & CInt((DFO_Dato))
												set yx = cnn.Execute(yql)
												on error resume next
												if cnn.Errors.Count > 0 then 
													ErrMsg = cnn.Errors(0).description			
													cnn.close 			   
													response.Write("503/@/Error Conexión 3:" & ErrMsg)
													response.End()		
												end if												
												if not yx.eof then
													ILD_Descripcion = yx("ILD_Descripcion")
												end if
											end if%>
											<div class="select">
												<input list="list-<%=rs("FDI_NombreHTML")%>" type="text" class="validate form-control datalist" id="input-<%=rs("FDI_NombreHTML")%>" value="<%=ILD_Descripcion%>" <%=disabled%>>
												<datalist name="list-<%=rs("FDI_NombreHTML")%>" id="list-<%=rs("FDI_NombreHTML")%>"><%
													xql="exec spItemListaDesplegable_Listar " & rs("LID_Id") & ", 1"
													set rx = cnn.Execute(xql)		
													on error resume next
													if cnn.Errors.Count > 0 then 
														ErrMsg = cnn.Errors(0).description			
														cnn.close 			   
														response.Write("503/@/Error Conexión 3:" & ErrMsg)
														response.End()		
													end if
													do while not rx.eof%>
														<option data-value="<%=rx("ILD_Id")%>" value="<%=rx("ILD_Descripcion")%>"></option><%
														rx.movenext												
													loop%>
												</datalist>
												<span class="select-highlight"></span>
												<span class="select-bar"></span><%
												if(trim(DFO_Dato)<>"") then%>
													<label for="input-<%=rs("FDI_NombreHTML")%>" class="select-label active"><%=rs("FDI_Descripcion")%></label><%
												else%>
													<label for="input-<%=rs("FDI_NombreHTML")%>" class="select-label"><%=rs("FDI_Descripcion")%></label><%
												end if%>
											</div>
											<input type="hidden" id="dta-<%=rs("FDI_NombreHTML")%>" name="dta-<%=rs("FDI_NombreHTML")%>" value="<%=CInt(DFO_Dato)%>" <%=disabled%>><%
										else
											set rw = cnn.Execute("exec spItemListaDesplegable_Consultar " & CInt(DFO_Dato))
											on error resume next												
											if not rw.eof then%>															
												<input type="text" class="form-control" <%=disabled%> value="<%=rw("ILD_Descripcion")%>">
												<input type="hidden" id="dta-<%=rs("FDI_NombreHTML")%>" name="dta-<%=rs("FDI_NombreHTML")%>" class="form-control" <%=disabled%> value="<%=rw("ILD_Id")%>"><%												
											end if												
											rw.Close
										end if
									Case "U"	'Usuario
										if(not disselect) then
											USR_NombreApellido=""
											if(not IsNULL(DFO_Dato) and DFO_Dato<>"") then
												wql="exec spUsuario_Consultar " & CInt(DFO_Dato)
												set wr = cnn.Execute(wql)
												on error resume next
												if cnn.Errors.Count > 0 then 
													ErrMsg = cnn.Errors(0).description			
													cnn.close 			   
													response.Write("503/@/Error Conexión 3:" & ErrMsg)
													response.End()		
												end if												
												if not wr.eof then
													USR_NombreApellido=wr("USR_Nombre") & " " & wr("USR_Apellido")
												end if
											end if%>
											<div class="select">
												<input list="list-<%=rs("FDI_NombreHTML")%>" type="text" class="validate form-control datalist" id="input-<%=rs("FDI_NombreHTML")%>" value="<%=USR_NombreApellido%>" <%=disabled%>>
												<datalist name="list-<%=rs("FDI_NombreHTML")%>" id="list-<%=rs("FDI_NombreHTML")%>"><%
													xql="exec spUsuario_Listar 1"
													set rx = cnn.Execute(xql)		
													on error resume next
													if cnn.Errors.Count > 0 then 
														ErrMsg = cnn.Errors(0).description			
														cnn.close 			   
														response.Write("503/@/Error Conexión 3:" & ErrMsg)
														response.End()		
													end if
													do while not rx.eof%>
														<option data-value="<%=rx("USR_Id")%>" value="<%=rx("USR_Nombre") & " " & rx("USR_Apellido")%>"></option><%
														rx.movenext												
													loop%>
												</datalist>
												<span class="select-highlight"></span>
												<span class="select-bar"></span><%
												if(trim(DFO_Dato)<>"") then%>
													<label for="input-<%=rs("FDI_NombreHTML")%>" class="select-label active"><%=rs("FDI_Descripcion")%></label><%
												else%>
													<label for="input-<%=rs("FDI_NombreHTML")%>" class="select-label"><%=rs("FDI_Descripcion")%></label><%
												end if%>
											</div>
											<input type="hidden" id="dta-<%=rs("FDI_NombreHTML")%>" name="dta-<%=rs("FDI_NombreHTML")%>" value="<%=CInt(DFO_Dato)%>" <%=disabled%>>
											<input type="hidden" id="DepDestinatario" name="DepDestinatario" value="1"><%
										else
											set rw = cnn.Execute("exec spUsuario_Consultar " & CInt(DFO_Dato))
											on error resume next												
											if not rw.eof then%>															
												<input type="text" class="form-control" <%=disabled%> value="<%=rw("USR_Nombre") & " " & rw("USR_Apellido")%>">
												<input type="hidden" id="dta-<%=rs("FDI_NombreHTML")%>" name="dta-<%=rs("FDI_NombreHTML")%>" class="form-control" <%=disabled%> value="<%=rw("USR_Id")%>"><%	
											end if												
											rw.Close
										end if
									Case "C"	'Texto%>
										<input type="text" id="dta-<%=rs("FDI_NombreHTML")%>" name="dta-<%=rs("FDI_NombreHTML")%>" class="form-control" <%=disabled%> value="<%=DFO_Dato%>"><%
									Case "S"	'Switch
										check=""													
										if(trim(DFO_Dato)="1") then
											check="checked"														
										end if%>
										<div class="switch">
											<input type="checkbox" id="dta-<%=rs("FDI_NombreHTML")%>-Y" class="switch__input" name="dta-<%=rs("FDI_NombreHTML")%>-Y" <%=check%> data-dat="<%=DFO_Dato%>" <%=seleccion%>>
											<label for="dta-<%=rs("FDI_NombreHTML")%>-Y" class="switch__label">Documento Pagado?</label>
										</div><%
									Case "X1"	'Externo 1 Proveedores
										proveedor=true
										if(not disselect) then
											PRO_RazonSocial=""
											if(not IsNULL(DFO_Dato) and DFO_Dato<>"") then
												yql="exec spProveedores_Consultar " & CInt(DFO_Dato)
												set yx = cnn.Execute(yql)
												on error resume next
												if cnn.Errors.Count > 0 then 
													ErrMsg = cnn.Errors(0).description			
													cnn.close 			   
													response.Write("503/@/Error Conexión 3:" & ErrMsg)
													response.End()		
												end if												
												if not yx.eof then
													PRO_RazonSocial = yx("PRO_RazonSocial")
													PRO_Rut = yx("PRO_Rut")
													ProveedorDes = PRO_RazonSocial & " - " & PRO_Rut
												end if
											end if%>
											<input type="text" class="form-control datalist" id="input-<%=rs("FDI_NombreHTML")%>" value="<%=ProveedorDes%>" <%=disabled%>><%
											
										else
											set rw = cnn.Execute("exec spProveedores_Consultar " & CInt(DFO_Dato))
											on error resume next												
											if not rw.eof then
												ProveedorDes = rw("PRO_RazonSocial") & " - " & rw("PRO_Rut")%>															
												<input type="text" class="form-control" <%=disabled%> value="<%=ProveedorDes%>">
												<input type="hidden" id="dta-<%=rs("FDI_NombreHTML")%>" name="dta-<%=rs("FDI_NombreHTML")%>" class="form-control" <%=disabled%> value="<%=rw("PRO_Id")%>"><%												
											end if												
											rw.Close
										end if
									Case else%>
										<input type="text" id="dta-<%=rs("FDI_NombreHTML")%>" name="dta-<%=rs("FDI_NombreHTML")%>" class="form-control" <%=disabled%> value="<%=DFO_Dato%>"><%
								End Select
								if((trim(ucase(rs("FDI_TipoCampo")))<>"L") or (trim(ucase(rs("FDI_TipoCampo")))="L" and disselect)) and ((trim(ucase(rs("FDI_TipoCampo")))<>"U") or (trim(ucase(rs("FDI_TipoCampo")))="U" and disselect)) and ((trim(ucase(rs("FDI_TipoCampo")))<>"S")) and ((trim(ucase(rs("FDI_TipoCampo")))<>"X1") or (trim(ucase(rs("FDI_TipoCampo")))="X1" and disselect)) then%>
									<span class="select-bar"></span><%
									if(trim(DFO_Dato)<>"" or descargar) then%>
										<label for="dta-<%=rs("FDI_NombreHTML")%>" class="select-label active"><%=rs("FDI_Descripcion")%></label><%
									else%>
										<label for="dta-<%=rs("FDI_NombreHTML")%>" class="select-label"><%=rs("FDI_Descripcion")%></label><%
									end if
								end if
							else
								disabled="readonly dta='7'"
								seleccion="disabled dta='7'"
								disselect = true
								
								'Campos del formulario no editable
								Select Case trim(ucase(rs("FDI_TipoCampo")))
									Case "T"%>
										<textarea class="md-textarea form-control" rows="3" <%=disabled%>><%=DFO_Dato%></textarea><%
									Case "A"%>
										<input type="text" class="form-control dowadj" <%=disabled%> data-vfo="<%=VFO_id%>" data-dre="<%=DRE_Id%>" value="Descargar Adjuntos" style="cursor:pointer"><%
										descargar = true
									Case "L"
										set rw = cnn.Execute("exec spItemListaDesplegable_Consultar " & CInt(DFO_Dato))
										on error resume next												
										if not rw.eof then%>															
											<input type="text" class="form-control" <%=disabled%> value="<%=rw("ILD_Descripcion")%>"><%
										end if												
										rw.Close
									Case "F"%>
										<input type="text" class="form-control" <%=disabled%> value="<%=DFO_Dato%>"><%
									Case "V"%>
										<input type="text" class="form-control" <%=disabled%> value="<%=DFO_Dato%>"><%
									Case "R"%>
										<input type="text" class="form-control" <%=disabled%> value="<%=DFO_Dato%>"><%
									Case "N"%>
										<input type="number" class="form-control" <%=disabled%> value="<%=DFO_Dato%>"><%
									Case "D"%>
										<input type="number" class="form-control" <%=disabled%> value="<%=DFO_Dato%>"><%
									Case "L"
										set rw = cnn.Execute("exec spItemListaDesplegable_Consultar " & CInt(DFO_Dato))
										on error resume next												
										if not rw.eof then%>															
											<input type="text" class="form-control" <%=disabled%> value="<%=rw("ILD_Descripcion")%>"><%
										end if												
										rw.Close
									Case "U"
										set rw = cnn.Execute("exec spUsuario_Consultar " & CInt(DFO_Dato))
										on error resume next												
										if not rw.eof then%>															
											<input type="text" class="form-control" <%=disabled%> value="<%=rw("USR_Nombre") & " " & rw("USR_Apellido")%>"><%
										end if												
										rw.Close
									Case "C"%>
										<input type="text" class="form-control" <%=disabled%> value="<%=DFO_Dato%>"><%
									Case "S"
										check=""													
										if(trim(DFO_Dato)="1") then
											check="checked"														
										end if%>
										<div class="switch">
											<input type="checkbox" class="switch__input" <%=check%> disabled id="dta-<%=rs("FDI_NombreHTML")%>-Y">
											<label for="dta-<%=rs("FDI_NombreHTML")%>-Y" class="switch__label">Documento Pagado?</label>
										</div><%
									Case "X1"
										set rw = cnn.Execute("exec spProveedores_Consultar " & CInt(DFO_Dato))
										on error resume next												
										if not rw.eof then%>															
											<input type="text" class="form-control" <%=disabled%> value="<%=rw("PRO_RazonSocial")%> - <%=rw("PRO_Rut")%>"><%
										end if												
										rw.Close
								End Select
								if((trim(ucase(rs("FDI_TipoCampo")))<>"L") or (trim(ucase(rs("FDI_TipoCampo")))="L" and disselect)) and ((trim(ucase(rs("FDI_TipoCampo")))<>"U") or (trim(ucase(rs("FDI_TipoCampo")))="U" and disselect)) and ((trim(ucase(rs("FDI_TipoCampo")))<>"S")) and ((trim(ucase(rs("FDI_TipoCampo")))<>"X1") or (trim(ucase(rs("FDI_TipoCampo")))="X1" and disselect)) then%>
									<span class="select-bar"></span><%
									if(trim(DFO_Dato)<>"" or descargar) then%>
										<label for="dta-<%=rs("FDI_NombreHTML")%>" class="select-label active"><%=rs("FDI_Descripcion")%></label><%
									else%>
										<label for="dta-<%=rs("FDI_NombreHTML")%>" class="select-label"><%=rs("FDI_Descripcion")%></label><%
									end if
								end if
							end if%>
						</div>
					</div>
				</div>
				<input type="hidden" name="dta-<%=rs("FDI_NombreHTML")%>-id" id="dta-<%=rs("FDI_NombreHTML")%>-id" value="<%=rs("FDI_Id")%>"><%
			end if
			rs.movenext
		loop%>
					</div><% 		'Cierre del row
		adjuntos = adjuntos & "}"
		ruts = ruts & "}"%>	
		<input type="hidden" name="ESR_Id" id="ESR_Id" value="<%=ESR_Id%>">
		<input type="hidden" name="modo" id="modo" value="<%=modo%>">
		<input type="hidden" name="VFL_Id" id="VFL_Id" value="<%=VFL_Id%>">
		<input type="hidden" name="DRE_Id" id="DRE_Id" value="<%=DRE_Id%>">
	</div>	
	<div class="row">	
		<div class="footer">
			<%if(btnname<>"") then%>
				<button type="button" class="btn <%=btnColor%> btn-md waves-effect waves-dark" id="<%=btnname%>" name="<%=btnname%>" title="<%=tooltip%>"><%=txtBoton%></button>
			<%end if%>			
			<%if(btnname2<>"") then%>
				<button type="button" class="btn <%=btnColor2%> btn-md waves-effect waves-dark" id="<%=btnname2%>" name="<%=btnname2%>" title="<%=tooltip2%>"><%=txtBoton2%></button>
			<%end if%>
			<%if(btnname6<>"") then%>
				<button type="button" class="btn <%=btnColor6%> btn-md waves-effect waves-dark" id="<%=btnname6%>" name="<%=btnname6%>" title="<%=tooltip6%>"><%=txtBoton6%></button>
			<%end if%>
			<%if(btnname9<>"") then%>
				<button type="button" class="btn <%=btnColor9%> btn-md waves-effect waves-dark" id="<%=btnname9%>" name="<%=btnname9%>" title="<%=tooltip9%>"><%=txtBoton9%></button>
			<%end if%>
			<%if(btnname5<>"") then%>
				<button type="button" class="btn <%=btnColor5%> btn-md waves-effect waves-dark" id="<%=btnname5%>" name="<%=btnname5%>" title="<%=tooltip5%>"><%=txtBoton5%></button>
			<%end if%>			
			<%if(btnname4<>"") then%>
				<button type="button" class="btn <%=btnColor4%> btn-md waves-effect waves-dark" id="<%=btnname4%>" name="<%=btnname4%>" title="<%=tooltip4%>"><%=txtBoton4%></button>
			<%end if%>
			<%if(btnname3<>"") then%>
				<button type="button" class="btn <%=btnColor3%> btn-md waves-effect waves-dark" id="<%=btnname3%>" name="<%=btnname3%>" title="<%=tooltip3%>"><%=txtBoton3%></button>
			<%end if%>
			<%if(btnname10<>"") then%>
				<button type="button" class="btn <%=btnColor10%> btn-md waves-effect waves-dark" id="<%=btnname10%>" name="<%=btnname10%>" title="<%=tooltip10%>"><%=txtBoton10%></button>
			<%end if%>

			<%if(btnname7<>"") then%>
				<button type="button" class="btn <%=btnColor7%> btn-md waves-effect waves-dark" id="<%=btnname7%>" name="<%=btnname7%>" title="<%=tooltip7%>" data-id="<%=id-1%>"><%=txtBoton7%></button>
			<%end if%>
			<%if(btnname8<>"") then%>
				<button type="button" class="btn <%=btnColor8%> btn-md waves-effect waves-dark" id="<%=btnname8%>" name="<%=btnname8%>" title="<%=tooltip8%>" data-id="<%=id+1%>"><%=txtBoton8%></button>
			<%end if%>
		</div>		
	</div>	
</form>

<%if(DRE_Observaciones<>"") then%>
	<!-- Modal Ver Observaciones-->
	<div class="modal fade bd-example-modal-lg" id="verObservacionesModal" tabindex="-1" role="dialog" aria-labelledby="verObservacionesModalLabel" aria-hidden="true">
		<div class="modal-dialog cascading-modal narrower modal-lg modal-bottom" role="document">  		
			<div class="modal-content">		
				<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
					<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-comments"></i> Observaciones</div>				
				</div>				
				<div class="modal-body" style="padding:0px;">				
					<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">											
						<div class="px-4">
							<div class="table-wrapper col-sm-12" id="container-table-mensajesreq">
								<textarea class="md-textarea form-control" rows="10" disabled readonly><%=DRE_Observaciones%></textarea>								
							</div>
						</div>							
					</div>									
				</div>
				<!--body-->
				<div class="modal-footer">					
					<div style="float:right;" class="btn-group" role="group" aria-label="">						
						<button type="button" class="btn btn-secondary btn-md waves-effect" data-dismiss="modal" data-toggle="tooltip" title="Salir"><i class="fas fa-sign-out-alt"></i></button>
					</div>					
				</div>		  
				<!--footer-->				
			</div>
		</div>
		<!--modal-dialogo-->
	</div>
	<!-- Modal Ver Observaciones-->
<%end if%>

<%if(proveedor) then%>
	<!-- Modal Proveedores-->
	<div class="modal fade bottom" id="proveedoresModalfrm" tabindex="-1" role="dialog" aria-labelledby="proveedoresModalfrmLabel" aria-hidden="true">
		<div class="modal-dialog cascading-modal narrower modal-xl" role="document">  		
			<div class="modal-content">		
				<div class="modal-header view view-cascade gradient-card-header blue-gradient narrower py-2 mx-4 mb-3 d-flex justify-content-center align-items-center" style="height: 3rem;">
				<div class="text-left" style="font-size:1.25rem;"><i class="fas fa-server"></i> Proveedores</div>				
				</div>				
				<div class="modal-body" style="padding:0px;">
					<div id="divfrmproveedores" class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
						<div class="px-4">						
							<form role="form" action="/agregar-proveedores" method="POST" name="frmproveedoresfrm" id="frmproveedoresfrm" class="needs-validation">
								<div class="row">
									<div class="col-sm-12 col-md-4 col-lg-5">
										<div class="md-form input-with-post-icon">
											<div class="error-message">								
												<i class="fas fa-user input-prefix"></i>
												<input type="text" id="PRO_RazonSocial" name="PRO_RazonSocial" class="form-control" required value="<%=PRO_RazonSocial%>" data-msg="Debes ingresar una razon social">
												<span class="select-bar"></span>
												<label for="PRO_RazonSocial" class="<%=lblClass%>">Razon Social</label>
											</div>
										</div>
									</div>							
									<div class="col-sm-12 col-md-4 col-lg-2">
										<div class="md-form input-with-post-icon">
											<div class="error-message">								
												<i class="fas fa-tag input-prefix"></i>
												<input type="text" id="PRO_Rut" name="PRO_Rut" class="form-control" required value="<%=PRO_Rut%>" data-msg="Debes ingresar un RUT válido">
												<span class="select-bar"></span>
												<label for="PRO_Rut" class="<%=lblClass%>">Rut</label>
											</div>
										</div>
									</div>
									<div class="col-sm-12 col-md-4 col-lg-5">
										<div class="md-form input-with-post-icon">
											<div class="error-message">								
												<i class="fas fa-user input-prefix"></i>
												<input type="text" id="PRO_Direccion" name="PRO_Direccion" class="form-control" value="<%=PRO_Direccion%>">
												<span class="select-bar"></span>
												<label for="PRO_Direccion" class="<%=lblClass%>">Dirección</label>
											</div>
										</div>
									</div>
								</div>
								<div class="row">
									<div class="col-sm-12 col-md-4 col-lg-4">
										<div class="md-form input-with-post-icon">
											<div class="error-message">								
												<i class="fas fa-phone input-prefix"></i>
												<input type="text" id="PRO_Telefono" name="PRO_Telefono" class="form-control"  value="<%=PRO_Telefono%>" pattern="^[0-9,$]{9}$" title="Debes ingresar un numero de 9 digitos">
												<span class="select-bar"></span>
												<label for="PRO_Telefono" class="<%=lblClass%>">Teléfono</label>
											</div>
										</div>
									</div>
									<div class="col-sm-12 col-md-4 col-lg-8">
										<div class="md-form input-with-post-icon">
											<div class="error-message">								
												<i class="fas fa-envelope input-prefix"></i>
												<input type="email" id="PRO_Mail" name="PRO_Mail" class="form-control" value="<%=PRO_Mail%>">
												<span class="select-bar"></span>
												<label for="PRO_Mail" class="<%=lblClass%>">Correo</label>
											</div>
										</div>
									</div>
								<div>
								</div class="row">
									<div class="col-sm-12 col-md-4 col-lg-4">
										<div class="md-form input-with-post-icon">
											<div class="error-message">
												<div class="select">
													<select name="ILD_Id" id="ILD_Id" class="select-text form-control" required data-msg="Debes ingresar un Banco">
														<option value="" disabled selected></option><%														
														set rs = cnn.Execute("exec spItemListaDesplegable_Listar 2, 1")
														on error resume next					
														do While Not rs.eof
															if(rs("ILD_Id")>0) then%>
																<option value="<%=rs("ILD_Id")%>"><%=rs("ILD_Descripcion")%></option><%
															end if
															rs.movenext						
														loop
														rs.Close%>
													</select>
													<i class="fas fa-tag input-prefix"></i>											
													<span class="select-highlight"></span>
													<span class="select-bar"></span>
													<label class="select-label <%=lblSelect%>">Banco</label>
												</div>
											</div>
										</div>
									</div>
									<div class="col-sm-12 col-md-4 col-lg-4">
										<div class="md-form input-with-post-icon">
											<div class="error-message">
												<div class="select">
													<select name="TCU_Id" id="TCU_Id" class="select-text form-control" required data-msg="Debes ingresar un tipo de cuenta">
														<option value="" disabled selected></option><%														
														set rs = cnn.Execute("exec spTipoCuenta_Listar 1")
														on error resume next					
														do While Not rs.eof
															if(rs("TCU_Id")>0) then%>																
																<option value="<%=rs("TCU_Id")%>"><%=rs("TCU_Descripcion")%></option><%
															end if
															rs.movenext						
														loop
														rs.Close%>
													</select>
													<i class="fas fa-tag input-prefix"></i>											
													<span class="select-highlight"></span>
													<span class="select-bar"></span>
													<label class="select-label <%=lblSelect%>">Tipo Cuenta</label>
												</div>
											</div>
										</div>
									</div>
									<div class="col-sm-12 col-md-4 col-lg-4">
										<div class="md-form input-with-post-icon">
											<div class="error-message">								
												<i class="fas fa-envelope input-prefix"></i>
												<input type="text" id="PRO_NumCuentaBancaria" name="PRO_NumCuentaBancaria" class="form-control" value="<%=PRO_NumCuentaBancaria%>" required data-msg="Debes ingresar un número de cuenta">
												<span class="select-bar"></span>
												<label for="PRO_NumCuentaBancaria" class="<%=lblClass%>">Número</label>
											</div>
										</div>
									</div>
								</div>								
							</form>
							<!--form-->
						</div>
						<!--px-4-->
					</div>
					<!--divfrmproveedores-->												
				</div>
				<!--body-->
				<div class="modal-footer">					
					<div style="float:left;" class="btn-group" role="group" aria-label="">
						<button class="btn btn-success btn-md waves-effect" type="button" data-url="" title="Agregar Proveedor" id="btn_frmproveedoresfrm" name="btn_frmproveedoresfrm"><i class='fas fa-plus ml-1'></i> Agregar</button>
					</div>
					<div style="float:right;" class="btn-group" role="group" aria-label="">					
						<button type="button" class="btn btn-secondary btn-md waves-effect" data-dismiss="modal" data-toggle="tooltip" title="Salir"><i class="fas fa-sign-out-alt"></i> Salir</button>
					</div>					
				</div>		  
				<!--footer-->	
			</div>
		</div>
	</div>
	<!-- Modal Proveedores-->
<%end if%>

<script>
	//Formulario
	var ss = String.fromCharCode(47) + String.fromCharCode(47);
	var s = String.fromCharCode(47);
	var bb = String.fromCharCode(92) + String.fromCharCode(92);
	var b = String.fromCharCode(92);
	var sas = String.fromCharCode(47) + String.fromCharCode(64) + String.fromCharCode(47);

	$(".datalist").on("change", function(e){
		e.preventDefault();
		e.stopPropagation();
		var id = $(this).attr("id").replace("input-","");
		var value = $(this).val();
		if(document.querySelector("#list-" + id + " option[value='" + value + "']")!=null){
			$("#dta-" + id).val(document.querySelector("#list-" + id + " option[value='" + value + "']").dataset.value);
		}else{
			$("#dta-" + id).val("");
			$("#input-" + id).val("");
		}
	})

	var titani = setInterval(function(){
		$("h5").slideDown("slow",function(){
			$("h6").slideDown("slow",function(){
				$(".verobs").addClass("shake");
				clearInterval(titani);
				$("#pry-scrollconten").mCustomScrollbar({
					theme:scrollTheme			
				});	
			});
		})
	},2300);
	if ($(".calendario").val() ==  null){
		$(".calendario").datepicker().datepicker("setDate", new Date());
	}else{
		$(".calendario").datepicker();
	}
	var ruts = <%=ruts%>;
	$.each (ruts,function(i,item){
		var rut = ( function rut_ch(){
			$('#' + item).Rut({
				format_on: 'keyup'				
			});		
		})		
		rut();
		if($("#" + item).val()!=undefined){
			$("#" + item).val($.Rut.formatear($("#" + item).val(),true));
		}
	})

	$(function () {
		$('[data-toggle="tooltip"]').tooltip({
			trigger : 'hover'
		})
		$('[data-toggle="tooltip"]').on('click', function () {
			$(this).tooltip('hide')
		})		
	});	

	$(document).ready(function() {
		var VFL_Id = <%=VFL_Id%>
		var modo = <%=modo%>;
		var editor=<%=editor%>
		var pendientes=<%=pendientes%>
		var $elemshake = $($(".inf").parent());

		var ss = String.fromCharCode(47) + String.fromCharCode(47);	
		var bb = String.fromCharCode(92) + String.fromCharCode(92);	
		
		$("#btn_frmproveedoresfrm").click(function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();			
			var id=$(this).data("id");
			
			formValidate("#frmproveedoresfrm");			
			if($("#frmproveedoresfrm").valid()){										
				$.ajax({
					type: 'POST',
					url: $("#frmproveedoresfrm").attr("action"),
					data: $("#frmproveedoresfrm").serialize(),
					dataType: "json",
					success: function(data) {						
						if(data.state=="200"){							
							
							$("#dta-"+id).val(data.data.PRO_Id);
							$("#input-"+id).val(data.data.PRO_RazonSocial);
							$("#input-"+id).siblings(".select-label").addClass("active")
							Toast.fire({
							  icon: 'success',
							  title: 'Proveedor agregado exitosamente.'
							});
							$("#frmproveedoresfrm")[0].reset();
							$("#proveedoresModalfrm").modal("hide");			
							getListaProveedores(null);
						}else{
							if(data.state=="401"){
								swalWithBootstrapButtons.fire({
									icon:'warning',
									title:'Ingreso/Modificación de Proveedor Fallido',
									text:data.message + " " + data.data.PRO_RazonSocial
								});
							}else{
								swalWithBootstrapButtons.fire({
									icon:'error',
									title:'Ingreso/Modificación de Proveedor Fallido',
									text:data.message
								});
							}
						}
					},
					error: function(XMLHttpRequest, textStatus, errorThrown){						
						swalWithBootstrapButtons.fire({
							icon:'error',								
							title: 'Ups!, no pude cargar el menú del proyecto',					
						});				
					}
				})
			}
		})

		//$('input.suggestions').keyup( $.debounce( 300, getListaProveedores ) );
		
		function getListaProveedores(){
			var search = $(this).val() ? $(this).val() : null;
			var id = $(this).attr("id").replace("input-","");

			//console.log(search,id)
			$.ajax({
				type: 'POST',
				url: '/listar-proveedores',
				data: {search:search},
				success: function(data) {						
					params = data.split(bb);									
					if(params[0]=="200"){
						if((params[1]).trim().length>0){
							$("#list-"+id).css("display","grid")
							$("#list-"+id).html(params[1]);
						}
					}else{
						Toast.fire({
							icon:'error',								
							title: 'Ups!, no pude cargar la lista de proveedors.',	
						});
					}
				},
				error: function(XMLHttpRequest, textStatus, errorThrown){						
					Toast.fire({
						icon:'error',								
						title: 'Ups!, no pude cargar la lista de proveedors.',	
					});				
				}
			});
		}

		if(pendientes>0 && editor==1){
			Toast.fire({
				icon: 'info',
				title: 'Existe(n) ' + pendientes + ' informe(s) pendiente(s) de creación'
			});			
			if($elemshake!=undefined){
				if($elemshake.hasClass("shake")){
					$elemshake.removeClass("shake")
				}
				var titani = setInterval(function(){				
					$elemshake.addClass("shake")
				},2300);				
			}			
		}
		$("#PRO_Rut").val($.Rut.formatear($("#PRO_Rut").val(),true));
		var rut = ( function rut_ch(){
			$('#PRO_Rut').Rut({
				format_on: 'keyup'				
			});			
		})		
		rut();		

		$('#proveedoresModalfrm').on('shown.bs.modal', function (e) {
			e.preventDefault();			
			$("#btn_frmproveedoresfrm").attr("data-id",$(e.relatedTarget).data("id"));
		})

		$("#frm10s1").on("click", ".verobs",function(e){
			e.preventDefault();
			e.stopPropagation();
			
			$("#verObservacionesModal").modal("show");			
			$("body").addClass("modal-open");
		})
		//Observaciones
		const obsmsg = (_callback) => {
			var resp=false,respTXT='Error en la ejecución';
			//Ingresar Observación
			swalWithBootstrapButtons.fire({
				icon:'info',
				title: 'Ingresa una Observación',
				input: 'textarea',
				inputValue: "",
				showCancelButton: true,
				confirmButtonText: '<i class="fas fa-check"></i> Agregar Observacion',
				cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar',
				inputValidator: (value) => {
					if (!value) {
						return 'Debes escribir una observación';
					}
				}
			}).then((result) => {
				if(result.value){	
					respTXT = result.value
					resp = true;
				}else{
					respTXT = 'Proceso cancelado'
					resp = false;
				}
				return _callback(null, {
					error: resp,
					value: respTXT
				});
			})			
		}

		const obs = (ESR_Id, _callback) => {
			var resp=false,respTXT='Error en la ejecución';
			$.ajax( {				
				type:'POST',					
				url: '/observaciones',
				data: {ESR_Id:ESR_Id},				
				success: function ( data ) {
					param = data.split(sas);
					if(param[0]==200){
						if(param[1]==1){							
							resp = true;
							respTXT = 'Obligatorio'
						}else{
							resp = false;
							respTXT = 'Opcional'
						}
					}else{
						resp = false;
						respTXT = 'Condición no encontrada'
					}
				},
				complete: function(){
					return _callback(null, {
						error: resp,
						value: respTXT
					});
				}
			})						
		}
		//Observaciones

		<%if(btnname2<>"") then%>
		//Tomar requerimiento
		$("#btn_frm10s2").click(function(e){
			swalWithBootstrapButtons.fire({
			title: '¿Quieres Tomar este Requerimiento?',
			text: "Al tomar este requerimiento ya no será visible para el resto de los usuarios de la misma unidad.",
			icon: 'question',
			showCancelButton: true,
			confirmButtonColor: '#3085d6',
			cancelButtonColor: '#d33',
			confirmButtonText: '<i class="fas fa-thumbs-up"></i> Tomar',
			cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar'
			}).then((result) => {
				if (result.value) {
					obs(9,(err, result)=>{					
						if(result.error){
							obsmsg((err, result) =>{								
								if(result.error){
									var data={DRE_Id:<%=DRE_Id%>,DRE_Observaciones:result.value};
									$.ajax( {
										type:'POST',					
										url: '/tomar-requerimiento',
										data: data,
										success: function ( data ) {
											param = data.split(sas)					
											if(param[0]==200){
												var DRE_Id=param[1];
												var modo = <%=modo%>;							
												var data = {modo:modo, DRE_Id:DRE_Id};
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
											}else{				
												//mensaje de error en la toma del requerimiento
												swalWithBootstrapButtons.fire({
													icon:'error',								
													title: 'ERROR: No fue posible tomar el requerimiento actual.'					
												});	
											}			
										},
										error: function(XMLHttpRequest, textStatus, errorThrown){				
											swalWithBootstrapButtons.fire({
												icon:'error',								
												title: 'Ups!, no pude cargar los campos del proyecto'					
											});				
										},
										complete: function(){
											$(".loader_wrapper").remove();
										}
									});	
								}
							})
						}else{
							var data={DRE_Id:<%=DRE_Id%>};
							$.ajax( {
								type:'POST',					
								url: '/tomar-requerimiento',
								data: data,
								success: function ( data ) {
									param = data.split(sas)					
									if(param[0]==200){
										var DRE_Id=param[1];
										var modo = <%=modo%>;							
										var data = {modo:modo, DRE_Id:DRE_Id};
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
									}else{				
										//mensaje de error en la toma del requerimiento
										swalWithBootstrapButtons.fire({
											icon:'error',								
											title: 'ERROR: No fue posible tomar el requerimiento actual.'					
										});	
									}			
								},
								error: function(XMLHttpRequest, textStatus, errorThrown){				
									swalWithBootstrapButtons.fire({
										icon:'error',								
										title: 'Ups!, no pude cargar los campos del proyecto'					
									});				
								},
								complete: function(){
									$(".loader_wrapper").remove();
								}
							});	
						}
					})
				}
			})	
		})
		<%end if%>		

		<%if(btnname3<>"") then%>
		//Rechazar requerimiento
		$("#btn_frm10s3").click(function(e){
			swalWithBootstrapButtons.fire({
				title: '¿Quieres Rechazar este Requerimiento?',
				text: "Al Rechazar este requerimiento solo quedará disponible como visualización y ya no podrá ser modificado por ningún perfil.",
				icon: 'question',
				showCancelButton: true,
				confirmButtonColor: '#3085d6',
				cancelButtonColor: '#d33',
				confirmButtonText: '<i class="fas fa-thumbs-up"></i> Rechazar',
				cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar'
			}).then((result) => {
			if (result.value) {
					//Observaciones					
					obs(5,(err, result)=>{						
						if(result.error){
							obsmsg((err, result) =>{								
								if(result.error){
									var data={DRE_Id:<%=DRE_Id%>,DRE_Observaciones:result.value};
									$.ajax( {
										type:'POST',					
										url: '/rechazar-requerimiento',
										data: data,
										success: function ( data ) {
											param = data.split(sas);
											modificaurl(VFL_Id,DRE_Id,'visualizar')
											if(param[0]==200){
												var DRE_Id=param[1];
												var modo = <%=modo%>;							
												var data = {modo:modo, DRE_Id:DRE_Id};
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
											}else{				
												//mensaje de error en la toma del requerimiento
												swalWithBootstrapButtons.fire({
													icon:'error',								
													title: 'ERROR: No fue posible rechazar el requerimiento actual.'					
												});	
											}			
										},
										error: function(XMLHttpRequest, textStatus, errorThrown){				
											swalWithBootstrapButtons.fire({
												icon:'error',								
												title: 'Ups!, no pude cargar los campos del proyecto'					
											});				
										},
										complete: function(){
											$(".loader_wrapper").remove();
										}
									});	
								}
							})
						}else{
							var data={DRE_Id:<%=DRE_Id%>};
							$.ajax( {
								type:'POST',					
								url: '/rechazar-requerimiento',
								data: data,
								success: function ( data ) {
									param = data.split(sas);
									modificaurl(VFL_Id,DRE_Id,'visualizar')
									if(param[0]==200){
										var DRE_Id=param[1];
										var modo = <%=modo%>;							
										var data = {modo:modo, DRE_Id:DRE_Id};
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
									}else{				
										//mensaje de error en la toma del requerimiento
										swalWithBootstrapButtons.fire({
											icon:'error',								
											title: 'ERROR: No fue posible rechazar el requerimiento actual.'					
										});	
									}			
								},
								error: function(XMLHttpRequest, textStatus, errorThrown){				
									swalWithBootstrapButtons.fire({
										icon:'error',								
										title: 'Ups!, no pude cargar los campos del proyecto'					
									});				
								},
								complete: function(){
									$(".loader_wrapper").remove();
								}
							});	
						}
					})					
				}
			})
					
		})
		<%end if%>

		<%if(btnname5<>"") then%>
		//Cerrar requerimiento
		$("#btn_frm10s5").click(function(e){
			if(pendientes==0 || id=="btn_frm10s4"){
				formValidate("#frm10s1")
				if($("#frm10s1").valid()){
					swalWithBootstrapButtons.fire({
						title: '¿Quieres Finalizar este Requerimiento?',
						text: "Al Finalizar este requerimiento solo quedará disponible como visualización y ya no podrá ser modificado por ningún perfil.",
						icon: 'question',
						showCancelButton: true,
						confirmButtonColor: '#3085d6',
						cancelButtonColor: '#d33',
						confirmButtonText: '<i class="fas fa-thumbs-up"></i> Finalizar',
						cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar'
					}).then((result) => {
						if (result.value) {
							//Observaciones							
							obs(7,(err, result)=>{								
								if(result.error){
									obsmsg((err, result) =>{								
										if(result.error){
											var data={DRE_Id:<%=DRE_Id%>,DRE_Observaciones:result.value};											
											$.ajax( {
												type:'POST',					
												url: '/finalizar-requerimiento',
												data: data,
												success: function ( data ) {
													param = data.split(sas);
													modificaurl(VFL_Id,DRE_Id,'visualizar')
													if(param[0]==200){
														var DRE_Id=param[1];
														var modo = <%=modo%>;							
														var data = {modo:modo, DRE_Id:DRE_Id};
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
													}else{				
														//mensaje de error en la toma del requerimiento
														swalWithBootstrapButtons.fire({
															icon:'error',								
															title: 'ERROR: No fue posible finalzar el requerimiento actual.'					
														});	
													}			
												},
												error: function(XMLHttpRequest, textStatus, errorThrown){				
													swalWithBootstrapButtons.fire({
														icon:'error',								
														title: 'Ups!, no pude cargar los campos del proyecto'					
													});				
												},
												complete: function(){
													$(".loader_wrapper").remove();
												}
											});	
										}
									})
								}else{
									//Grabando ultimo formulario
									
									var formdata = new FormData();
									var data = $("#frm10s1").serializeArray();
									var file_data;
									var file_name;
									$.each (adjuntos,function(i,item){			
										file_name = $("#"+ item);					
										file_data = $(file_name).prop('files');
										if(file_data!=undefined){
											if(file_data[0]!=undefined){					
												formdata.append(item, "1")
											}else{
												formdata.append(item, "0")
											}			
											for (var i = 0; i < file_data.length; i++) {
												formdata.append(file_data[i].name, file_data[i])
											}
										}else{
											formdata.append(item, "0")
										}
									})									
									formdata.append('sw',2);
									//Finalización del flujo
									$.each(data, function(i, field) { 
										formdata.append(field.name,field.value);
									});
									if(modo==1){
										var msg='Creación'
									}else{
										var msg='Modificación'
									}
									$.ajax({
										type: 'POST',			
										url: $("#frm10s1").attr("action"),
										data: formdata,
										enctype: 'multipart/form-data',
										cache: false,
										contentType: false,
										processData: false,
										success: function(data) {						
											param=data.split(bb);						
											if(param[0]=="200"){
												Toast.fire({
													icon: 'success',
													title: msg + ' grabada correctamente'
												});							
												//Desplegar versión del formulario creado
												var VFO_Id = param[1];
												var FLD_Id = param[2];
												var DRE_Id = param[3];
												
												modificaurl(VFL_Id,DRE_Id,'modificar')

												$($("h6").after("<h6>Versión: " + VFO_Id + "</h6>")).slideDown("slow");

												//Cerrando el requerimiento
												$.ajax( {
													type:'POST',					
													url: '/finalizar-requerimiento',
													data: {DRE_Id:DRE_Id},
													success: function ( data ) {
														param = data.split(sas);
														modificaurl(VFL_Id,DRE_Id,'visualizar')
														if(param[0]==200){
															var DRE_Id=param[1];
															var modo = <%=modo%>;							
															var data = {modo:modo, DRE_Id:DRE_Id};
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
														}else{				
															//mensaje de error en la toma del requerimiento
															swalWithBootstrapButtons.fire({
																icon:'error',								
																title: 'ERROR: No fue posible finalzar el requerimiento actual.'					
															});	
														}			
													},
													error: function(XMLHttpRequest, textStatus, errorThrown){				
														swalWithBootstrapButtons.fire({
															icon:'error',								
															title: 'Ups!, no pude cargar los campos del proyecto'					
														});				
													},
													complete: function(){
														$(".loader_wrapper").remove();
													}
												});	
												var modo = <%=modo%>;							
												var data = {modo:modo, DRE_Id:DRE_Id};
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
												
											}else{
												swalWithBootstrapButtons.fire({
													icon:'error',								
													title: 'Ups!, no pude grabar los datos del proyecto'								
												});
											}
										},
										error: function(XMLHttpRequest, textStatus, errorThrown){
											swalWithBootstrapButtons.fire({
												icon:'error',								
												title: 'Ups!, no pude cargar el menú del proyecto'							
											});
										}
									});									
								}
							})
						}
					})
				}else{
					Toast.fire({
						icon: 'error',
						title: 'Corrige los campos con error antes de guardar el formulario'
					});			
				}
			}else{
				swalWithBootstrapButtons.fire({
					icon:'error',								
					title: 'ERROR: No es posible avanzar al siguiente paso.',
					text: 'Debes crear ' + pendientes + ' informe(s) pendiente(s) antes de enviar el requerimiento al siguiente paso'
				}).then((result) => {
					if($elemshake.hasClass("shake")){
						$elemshake.removeClass("shake")
					}					
				});
			}
					
		})
		<%end if%>
				
		//Bajar adjuntos
		$("#frm10s1").on("click",".dowadj",function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();						

			var VFO_Id = $(this).data("vfo");
			var DRE_Id = $(this).data("dre");
		
			ajax_icon_handling('load','Buscando adjuntos','','');
			$.ajax({
				type: 'POST',								
				url:'/listar-adjuntos',				
				data:{VFO_Id:VFO_Id,DRE_Id,DRE_Id},
				success: function(data) {
					var param=data.split(bb);			
					if(param[0]=="200"){				
						ajax_icon_handling(true,'Listado de adjuntos creado.','',param[1]);
						$(".swal2-popup").css("width","60rem");
						loadtables("#tbl-adjuntos");
						$(".arcreq").click(function(){
							var INF_Arc = $(this).data("file");							
							var data = {VFO_Id:VFO_Id,DRE_Id,DRE_Id,INF_Arc:INF_Arc};
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
						ajax_icon_handling(false,'No fue posible crear el listado de adjuntos.','','');
					}						
				},
				error: function(XMLHttpRequest, textStatus, errorThrown){				
					ajax_icon_handling(false,'No fue posible crear el listado de verificadores.','','');	
				},
				complete: function(){																		
				}
			})
		})

		//btnname4 devolver requerimiento
		
		<%if(btnname<>"" or btnname4<>"" or btnname6<>"") then%>
		//Grabar formulario		
		var adjuntos = <%=adjuntos%>;		
		$("#btn_frm10s1, #btn_frm10s4, #btn_frm10s6").click(function(){
			var id=$(this)[0].id;			
			if(id=="btn_frm10s4"){
				$("#frm10s1").find(':input').each(function(){
					$(this).removeAttr("required")
				})
			}
			if(pendientes==0 || id=="btn_frm10s4"){
				formValidate("#frm10s1")
				if($("#frm10s1").valid()){
					var formdata = new FormData();
					var data = $("#frm10s1").serializeArray();
					var file_data;
					var file_name;
					$.each (adjuntos,function(i,item){			
						file_name = $("#"+ item);					
						file_data = $(file_name).prop('files');
						if(file_data!=undefined){
							if(file_data[0]!=undefined){					
								formdata.append(item, "1")
							}else{
								formdata.append(item, "0")
							}			
							for (var i = 0; i < file_data.length; i++) {
								formdata.append(file_data[i].name, file_data[i])
							}
						}else{
							formdata.append(item, "0")
						}
					})
					
					$.each(data, function(i, field) { 
						formdata.append(field.name,field.value);
					});
					var swobs = false
					if(id=="btn_frm10s4"){
						formdata.append('sw',-1);						
						swobs=true;
					}					
					if(id=="btn_frm10s6"){
						formdata.append('sw',1);
					}
					if(modo==1){
						var msg='Creación'
					}else{
						if(id=="btn_frm10s4"){
							var msg='Devolucón'
						}else{
							var msg='Modificación'							
						}
					}
					$('input[type=checkbox]').each(function(){
						if($(this).prop("checked")){
							formdata.append($(this).attr("name").replace("-Y",""),1)
						}else{
							formdata.append($(this).attr("name").replace("-Y",""),0)
						}
					})
					if(swobs){
						swalWithBootstrapButtons.fire({
							title: '¿Quieres Devolver este Requerimiento?',
							text: "Al devolver este requerimiento quedará disponible para los usuarios de la unidad anterior.",
							icon: 'question',
							showCancelButton: true,
							confirmButtonColor: '#3085d6',
							cancelButtonColor: '#d33',
							confirmButtonText: '<i class="fas fa-thumbs-up"></i> Devolver',
							cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar'
						}).then((result) => {
							if (result.value) {
								//Observaciones						
								obs(6,(err, result)=>{
									if(result.error){
										obsmsg((err, result) =>{								
											if(result.error){
												formdata.append('DRE_Obervaciones',result.value);
												$.ajax({
													type: 'POST',			
													url: $("#frm10s1").attr("action"),
													data: formdata,
													enctype: 'multipart/form-data',
													cache: false,
													contentType: false,
													processData: false,
													success: function(data) {						
														param=data.split(bb);						
														if(param[0]=="200"){
															Toast.fire({
																icon: 'success',
																title: msg + ' grabada correctamente'
															});							
															//Desplegar versión del formulario creado
															var VFO_Id = param[1];
															var FLD_Id = param[2];
															var DRE_Id = param[3];
															
															modificaurl(VFL_Id,DRE_Id,'modificar')

															$($("h6").after("<h6>Versión: " + VFO_Id + "</h6>")).slideDown("slow")
															var modo = <%=modo%>;							
															var data = {modo:modo, DRE_Id:DRE_Id};
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
															
														}else{
															swalWithBootstrapButtons.fire({
																icon:'error',								
																title: 'Ups!, no pude grabar los datos del proyecto'								
															});
														}
													},
													error: function(XMLHttpRequest, textStatus, errorThrown){
														swalWithBootstrapButtons.fire({
															icon:'error',								
															title: 'Ups!, no pude cargar el menú del proyecto'							
														});
													}
												});
											}
										})
									}
								})
							}
						})
					}else{
						$.ajax({
							type: 'POST',			
							url: $("#frm10s1").attr("action"),
							data: formdata,
							enctype: 'multipart/form-data',
							cache: false,
							contentType: false,
							processData: false,
							success: function(data) {						
								param=data.split(bb);						
								if(param[0]=="200"){
									Toast.fire({
									icon: 'success',
									title: msg + ' grabada correctamente'
									});							
									//Desplegar versión del formulario creado
									var VFO_Id = param[1];
									var FLD_Id = param[2];
									var DRE_Id = param[3];
									
									modificaurl(VFL_Id,DRE_Id,'modificar')

									$($("h6").after("<h6>Versión: " + VFO_Id + "</h6>")).slideDown("slow")
									var modo = <%=modo%>;							
									var data = {modo:modo, DRE_Id:DRE_Id};
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
									
								}else{
									swalWithBootstrapButtons.fire({
										icon:'error',								
										title: 'Ups!, no pude grabar los datos del proyecto'								
									});
								}
							},
							error: function(XMLHttpRequest, textStatus, errorThrown){
								swalWithBootstrapButtons.fire({
									icon:'error',								
									title: 'Ups!, no pude cargar el menú del proyecto'							
								});
							}
						});
					}
				}else{
					Toast.fire({
						icon: 'error',
						title: 'Corrige los campos con error antes de guardar el formulario'
					});			
				}
			}else{
				swalWithBootstrapButtons.fire({
					icon:'error',								
					title: 'ERROR: No es posible avanzar al siguiente paso.',
					text: 'Debes crear ' + pendientes + ' informe(s) pendiente(s) antes de enviar el requerimiento al siguiente paso'
				}).then((result) => {
					if($elemshake.hasClass("shake")){
						$elemshake.removeClass("shake")
					}					
				});
			}
		});		
		$.each (adjuntos,function(i,item){			
			$("#"+ item +"X").click(function(e){
				e.preventDefault();
				e.stopImmediatePropagation();
				e.stopPropagation();
				$("#"+ item).click();
			})
			$("#"+ item).change(function(click){								
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
					$("#"+ item +"X").val(doc);					
				});				
			})
		})
		<%end if%>

		<%if(btnname7<>"" or btnname8<>"") then%>
		//Avanzar y retroceder
		$("#btn_frm10s7, #btn_frm10s8").on("click",function(e){
			e.preventDefault();
			e.stopPropagation();			
			var id		= $(this).data("id");
			
			$.each ($(".step"),function(i,item){				
				if($(item).data("id")==id){					
					$(item).click();
				}
			})			
		})
		<%end if%>

		<%if(btnname9<>"") then%>
		//Liberar requerimiento
		$("#btn_frm10s9").click(function(e){
			swalWithBootstrapButtons.fire({
				title: '¿Quieres Liberar este Requerimiento?',
				text: "Al liberar este requerimiento quedará disponible para el resto de los usuarios de la misma unidad.",
				icon: 'question',
				showCancelButton: true,
				confirmButtonColor: '#3085d6',
				cancelButtonColor: '#d33',
				confirmButtonText: '<i class="fas fa-thumbs-up"></i> Liberar',
				cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar'
			}).then((result) => {
				if (result.value) {
					//Observaciones					
					obs(15,(err, result)=>{
						if(result.error){
							obsmsg((err, result) =>{								
								if(result.error){
									var data={DRE_Id:<%=DRE_Id%>,DRE_Observaciones:result.value};
									$.ajax( {
										type:'POST',					
										url: '/liberar-requerimiento',
										data: data,
										success: function ( data ) {
											param = data.split(sas)					
											if(param[0]==200){
												var DRE_Id=param[1];
												var modo = <%=modo%>;							
												var data = {modo:modo, DRE_Id:DRE_Id};
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
											}else{				
												//mensaje de error en la toma del requerimiento
												swalWithBootstrapButtons.fire({
													icon:'error',								
													title: 'ERROR: No fue posible liberar el requerimiento actual.'					
												});	
											}			
										},
										error: function(XMLHttpRequest, textStatus, errorThrown){				
											swalWithBootstrapButtons.fire({
												icon:'error',								
												title: 'Ups!, no pude cargar los campos del proyecto'					
											});				
										},
										complete: function(){
											$(".loader_wrapper").remove();
										}
									});
								}
							})
						}else{
							var data={DRE_Id:<%=DRE_Id%>};
							$.ajax( {
								type:'POST',					
								url: '/liberar-requerimiento',
								data: data,
								success: function ( data ) {
									param = data.split(sas)					
									if(param[0]==200){
										var DRE_Id=param[1];
										var modo = <%=modo%>;							
										var data = {modo:modo, DRE_Id:DRE_Id};
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
									}else{				
										//mensaje de error en la toma del requerimiento
										swalWithBootstrapButtons.fire({
											icon:'error',								
											title: 'ERROR: No fue posible liberar el requerimiento actual.'					
										});	
									}			
								},
								error: function(XMLHttpRequest, textStatus, errorThrown){				
									swalWithBootstrapButtons.fire({
										icon:'error',								
										title: 'Ups!, no pude cargar los campos del proyecto'					
									});				
								},
								complete: function(){
									$(".loader_wrapper").remove();
								}
							})
						}
					})
				}
			})
		})
		<%end if%>

		<%if(btnname10<>"") then%>
		//Abrir requerimiento
		$("#btn_frm10s10").click(function(e){
			swalWithBootstrapButtons.fire({
				title: '¿Quieres Abrir este Requerimiento?',
				text: "Al Abrir este requerimiento quedará disponible para el resto de los usuarios de la misma unidad.",
				icon: 'question',
				showCancelButton: true,
				confirmButtonColor: '#3085d6',
				cancelButtonColor: '#d33',
				confirmButtonText: '<i class="fas fa-thumbs-up"></i> Abrir',
				cancelButtonText: '<i class="fas fa-thumbs-down"></i> Cancelar'
			}).then((result) => {
				if (result.value) {
					//Observaciones					
					obs(16,(err, result)=>{
						if(result.error){
							obsmsg((err, result) =>{								
								if(result.error){
									var data={DRE_Id:<%=DRE_Id%>,DRE_Observaciones:result.value};
									$.ajax( {
										type:'POST',					
										url: '/abrir-requerimiento',
										data: data,
										success: function ( data ) {
											param = data.split(sas);
											modificaurl(VFL_Id,DRE_Id,'modificar')
											if(param[0]==200){
												var DRE_Id=param[1];
												var modo = <%=modo%>;							
												var data = {modo:modo, DRE_Id:DRE_Id};
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
											}else{				
												//mensaje de error en la toma del requerimiento
												swalWithBootstrapButtons.fire({
													icon:'error',								
													title: 'ERROR: No fue posible abrir el requerimiento actual.'					
												});	
											}			
										},
										error: function(XMLHttpRequest, textStatus, errorThrown){				
											swalWithBootstrapButtons.fire({
												icon:'error',								
												title: 'Ups!, no pude cargar los campos del proyecto'					
											});				
										},
										complete: function(){
											$(".loader_wrapper").remove();
										}
									});	
								}
							})
						}else{
							var data={DRE_Id:<%=DRE_Id%>};
							$.ajax( {
								type:'POST',					
								url: '/abrir-requerimiento',
								data: data,
								success: function ( data ) {
									param = data.split(sas);
									modificaurl(VFL_Id,DRE_Id,'modificar')
									if(param[0]==200){
										var DRE_Id=param[1];
										var modo = <%=modo%>;							
										var data = {modo:modo, DRE_Id:DRE_Id};
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
									}else{				
										//mensaje de error en la toma del requerimiento
										swalWithBootstrapButtons.fire({
											icon:'error',								
											title: 'ERROR: No fue posible abrir el requerimiento actual.'					
										});	
									}			
								},
								error: function(XMLHttpRequest, textStatus, errorThrown){				
									swalWithBootstrapButtons.fire({
										icon:'error',								
										title: 'Ups!, no pude cargar los campos del proyecto'					
									});				
								},
								complete: function(){
									$(".loader_wrapper").remove();
								}
							});	
						}
					})
				}
			})
					
		})
		<%end if%>

		//Lista de ordenes de compra		
		$("#frm10s1").on('click','.searchoc',function(e){
			ajax_icon_handling('load','Creando listado de Ordenes de Compra','','');			
			$.ajax({
				type: 'POST',								
				url:'/listar-ordenes-de-compra',					
				success: function(data) {						
					var param=data.split(sas);						
					if(param[0]=="200"){
						ajax_icon_handling(true,'Listado de versiones de Ordenes de Compra creado.','',param[1]);
						$(document).off('focusin.bs.modal');
						$(".swal2-popup").css("width","60rem");																		
						$("#tbl-ordenesdecompra").on("click","tr.oc",function(){
							$(this).find("td").each(function(e){								
								if([e]==5){
									OC=this.innerText;
									$("#PAG_OrdenCompra").val(OC);
									$("#PAG_OrdenCompra").siblings("label").addClass("active");
									//$("#PAG_OrdenCompra").siblings("i.fas").addClass("active");
								}
							});								
							Swal.close();
							changedata=true;
							$(document).off('focusin.bs.modal');								
						})
					}else{
						ajax_icon_handling(false,'No fue posible crear el listado de ordenes de compra.','','');
					}						
				},
				error: function(XMLHttpRequest, textStatus, errorThrown){				
					ajax_icon_handling(false,'No fue posible crear el listado de ordenes de compra.','','');	
				},
				complete: function(){															
				}
			})
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
		cargabreadcrumb("/breadcrumbs","");
	}	
</script>