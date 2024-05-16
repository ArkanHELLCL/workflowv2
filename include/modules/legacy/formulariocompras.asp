<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!-- #INCLUDE FILE="session.min.inc" -->
<!-- #INCLUDE FILE="functions.inc" -->
<%
Req_cod = request("Req_cod")

set cnn = Server.CreateObject("ADODB.Connection")
on error resume next	
cnn.open session("DSN_WorkFlowv2")
if cnn.Errors.Count > 0 then 
    ErrMsg = cnn.Errors(0).description	   
    cnn.close
    response.Write("503/@/Error Conexión:" & ErrMsg)
    response.End() 			   
end if
sql="exec [spCompras_Listar] " + Req_cod
set rs = cnn.Execute(sql)
on error resume next
if not rs.eof then
    response.write("200/@/")
else
    response.write("404/@/")
    response.end()
end if
%>
<div class="modal-body">
    <h4>Requerimiento N° <%=Req_cod%></h4>
    <div class="row">
        <div class="col-sm-12 col-md-12 col-lg-6">
            <div class="md-form input-with-post-icon">
                <div class="error-message">								
                    <i class="fas fa-user input-prefix"></i>															
                    <input type="text" class="form-control" readonly="" value="<%=rs("nombres")%>">                    
                    <span class="select-bar"></span>
                    <label for="" class="select-label active">Creador</label>
                </div>
            </div>
        </div>
        <div class="col-sm-12 col-md-12 col-lg-6">
            <div class="md-form input-with-post-icon">
                <div class="error-message">								
                    <i class="fas fa-calendar input-prefix"></i>															
                    <input type="text" class="form-control" readonly="" value="<%=rs("fecha_ingreso")%>">                    
                    <span class="select-bar"></span>
                    <label for="" class="select-label active">Fecha de Solicitud</label>
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-sm-12 col-md-12 col-lg-12">
            <div class="md-form input-with-post-icon">
                <div class="error-message">								
                    <i class="fas fa-building input-prefix"></i>															
                    <input type="text" class="form-control" readonly="" value="<%=rs("dependencia")%>">                    
                    <span class="select-bar"></span>
                    <label for="" class="select-label active">Unidad Solicitante</label>
                </div>
            </div>
        </div>
    </div>    
    <div class="row">
        <div class="col-sm-12 col-md-12 col-lg-12">
            <div class="md-form input-with-post-icon">
                <div class="error-message">								
                    <i class="fas fa-edit input-prefix"></i>															
                    <textarea type="text" class="md-textarea form-control" readonly="" rows="5"><%=LimpiarUrl(rs("descripcion"))%></textarea>
                    <span class="select-bar"></span>
                    <label for="" class="select-label active">Descripción</label>
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-sm-12 col-md-12 col-lg-12">
            <div class="md-form input-with-post-icon">
                <div class="error-message">								
                    <i class="fas fa-edit input-prefix"></i>															
                    <textarea type="text" class="md-textarea form-control" readonly="" rows="5"><%=LimpiarUrl(rs("justificacion"))%></textarea>
                    <span class="select-bar"></span>
                    <label for="" class="select-label active">Justificación</label>
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-sm-12 col-md-12 col-lg-12">
            <div class="md-form input-with-post-icon">
                <div class="error-message">								
                    <i class="fas fa-edit input-prefix"></i>															
                    <textarea type="text" class="md-textarea form-control" readonly="" rows="5"><%=LimpiarUrl(rs("especificaciones"))%></textarea>
                    <span class="select-bar"></span>
                    <label for="" class="select-label active">Especificación</label>
                </div>
            </div>
        </div>
    </div>
    <div class="row">            
        <div class="col-sm-12 col-md-12 col-lg-4">
            <div class="md-form input-with-post-icon">
                <div class="error-message">								
                    <i class="fas fa-calendar input-prefix"></i>															
                    <input type="text" class="form-control" readonly="" value="<%=rs("fecha_autoriza_jefe")%>">                    
                    <span class="select-bar"></span>
                    <label for="" class="select-label active">Autorización jefatura</label>
                </div>
            </div>
        </div>
    
        <div class="col-sm-12 col-md-12 col-lg-4">
            <div class="md-form input-with-post-icon">
                <div class="error-message">								
                    <i class="fas fa-calendar input-prefix"></i>															
                    <input type="text" class="form-control" readonly="" value="<%=rs("fecha_autoriza_daf")%>">                    
                    <span class="select-bar"></span>
                    <label for="" class="select-label active">Autorización DAF</label>
                </div>
            </div>
        </div>
    
        <div class="col-sm-12 col-md-12 col-lg-4">
            <div class="md-form input-with-post-icon">
                <div class="error-message">								
                    <i class="fas fa-calendar input-prefix"></i>															
                    <input type="text" class="form-control" readonly="" value="<%=rs("fecha_inicio_compra")%>">                    
                    <span class="select-bar"></span>
                    <label for="" class="select-label active">Inicio compra</label>
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-sm-12 col-md-12 col-lg-4">
            <div class="md-form input-with-post-icon">
                <div class="error-message">								
                    <i class="fas fa-dollar-sign input-prefix"></i>															
                    <input type="text" class="form-control" readonly="" value="<%=FormatNumber(rs("costo"),0,0,0,-1)%>">                    
                    <span class="select-bar"></span>
                    <label for="" class="select-label active">Costo</label>
                </div>
            </div>
        </div>
        <div class="col-sm-12 col-md-12 col-lg-4">
            <div class="md-form input-with-post-icon">
                <div class="error-message">								
                    <i class="fas fa-calendar input-prefix"></i>															
                    <input type="text" class="form-control" readonly="" value="<%=rs("fecha_adjudicacion")%>">                    
                    <span class="select-bar"></span>
                    <label for="" class="select-label active">Adjudicación</label>
                </div>
            </div>
        </div>    
        <div class="col-sm-12 col-md-12 col-lg-4">
            <div class="md-form input-with-post-icon">
                <div class="error-message">								
                    <i class="fas fa-calendar input-prefix"></i>															
                    <input type="text" class="form-control" readonly="" value="<%=rs("fecha_entrega")%>">                    
                    <span class="select-bar"></span>
                    <label for="" class="select-label active">Entrega producto/servicio</label>
                </div>
            </div>
        </div>
    </div>
</div>				
<div class="modal-footer">
    <button type="button" class="btn btn-secondary btn-md waves-effect" data-dismiss="modal"><i class="fas fa-times"></i> Cerrar</button>
</div>