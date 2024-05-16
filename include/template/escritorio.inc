<%
'--------------------------------------------------------------------
' Archivo de cabecera BANDEJAHEAD.INC
'
'--------------------------------------------------------------------
HostName = "https://" & Request.ServerVariables("SERVER_NAME")
%>
<link rel="shortcut icon" type="image/x-icon" href="<%=HostName%>/img/gobcl-favicon.ico"  />

<!--jquery-->
<link  href="<%=HostName%>/vendor/jquery/css/jquery-ui.min.css" rel="stylesheet" id="ui-theme">
<link  href="<%=HostName%>/vendor/jquery/css/theme.jui.css" rel="stylesheet">
<link  href="<%=HostName%>/vendor/jquery/css/jquery.timepicker.min.css" rel="stylesheet">

<script type="text/javascript" src="<%=HostName%>/vendor/jquery/js/jquery-3.6.0.min.js"></script>
<script type="text/javascript" src="<%=HostName%>/vendor/jquery/js/jquery-ui.min.js"></script>
<script type="text/javascript" src="<%=HostName%>/vendor/jquery/js/jquery.timepicker.min.js"></script>
<!--jquery-->

<!--jspdf-->
<script type="text/javascript" src="<%=HostName%>/vendor/jspdf/modules/html2canvas.js"></script>
<script type="text/javascript" src="<%=HostName%>/vendor/jspdf/js/jspdf.min.js"></script>
<!--jspdf-->

<!--Bootstrap-->
<script type="text/javascript" src="<%=HostName%>/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<link  href="<%=HostName%>/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-theme">
<!--Bootstrap-->

<!--MDB-->
<script type="text/javascript" src="<%=HostName%>/vendor/mdb/js/mdb.min.js"></script>
<link  href="<%=HostName%>/vendor/mdb/css/mdb.min.css" rel="stylesheet">
<!--<link  href="<%=HostName%>/vendor/mdb/css/addons/datatables.min.css" rel="stylesheet">
<link  href="<%=HostName%>/vendor/mdb/css/addons/datatables-select.min.css" rel="stylesheet">-->

<!--<script type="text/javascript" src="<%=HostName%>/vendor/mdb/js/addons/datatables.min.js"></script>
<script type="text/javascript" src="<%=HostName%>/vendor/mdb/js/addons/tableedit.js"></script>
<script type="text/javascript" src="<%=HostName%>/vendor/mdb/js/addons/datatables-select.min.js"></script>-->
<!--MDB-->

<!--DataTable-->
<link  href="<%=HostName%>/vendor/datatable/datatables.min.css" rel="stylesheet">
<link  href="<%=HostName%>/vendor/datatable/Select-1.3.3/css/select.dataTables.min.css" rel="stylesheet">
<link  href="<%=HostName%>/vendor/datatable/Select-1.3.3/css/select.dataTables.min.css" rel="stylesheet">
<link  href="<%=HostName%>/vendor/datatable/Responsive-2.2.7/css/responsive.dataTables.min.css" rel="stylesheet">

<script type="text/javascript" src="<%=HostName%>/vendor/datatable/datatables.min.js"</script>
<script type="text/javascript" src="<%=HostName%>/vendor/datatable/Select-1.3.3/js/dataTables.select.min.js"</script>
<script type="text/javascript" src="<%=HostName%>/vendor/datatable/FixedColumns-3.3.2"></script>
<script type="text/javascript" src="<%=HostName%>/vendor/datatable/Responsive-2.2.7/js/dataTables.responsive.min.js"></script>

<script type="text/javascript" src="<%=HostName%>/vendor/mdb/js/addons/tableedit.js"></script>


<!--DataTable-->

<!--Materialize-->
<link  href="<%=HostName%>/vendor/materializecss/select.css?v=2.1" rel="stylesheet">
<link  href="<%=HostName%>/vendor/materializecss/accordion.css" rel="stylesheet">
<link  href="<%=HostName%>/vendor/materializecss/chkbox.css" rel="stylesheet">
<link  href="<%=HostName%>/vendor/materializecss/radiobutton.css" rel="stylesheet">
<link  href="<%=HostName%>/vendor/materializecss/tabs.css?v=3.1" rel="stylesheet">
<link  href="<%=HostName%>/vendor/materializecss/switch.css" rel="stylesheet">

<script type="text/javascript" src="<%=HostName%>/vendor/materializecss/tabs.js?v1.9"></script>
<script type="text/javascript" src="<%=HostName%>/vendor/materializecss/exportabletotcsv.js?ver=1.0"></script>
<script type="text/javascript" src="<%=HostName%>/vendor/materializecss/chkbox.js"></script>
<!--Materialize-->

<!--validator-->
<script type="text/javascript" src="<%=HostName%>/vendor/validator/jquery.validate.js"></script>
<script type="text/javascript" src="<%=HostName%>/vendor/validator/localization/messages_es.min.js"></script>
<script type="text/javascript" src="<%=HostName%>/vendor/validator/additional-methods.min.js"></script>
<!--validator-->

<!--rut-->
<script type="text/javascript" src="<%=HostName%>/vendor/rut/jquery.Rut.js"></script>
<!--rut-->

<!--sweetalert-->
<script src="<%=HostName%>/vendor/sweetalert2/js/sweetalert2.all.min.js"></script>
<link rel="stylesheet" href="<%=HostName%>/vendor/sweetalert2/css/sweetalert2.min.css" />

<script src="<%=HostName%>/vendor/sweetalert2/js/sweetalert2-wait.js"></script>
<link rel="stylesheet" href="<%=HostName%>/vendor/sweetalert2/css/sweetalert2-wait.css" />
<!--sweetalert-->

<!--Fonts-->
<link href="<%=HostName%>/fonts/foundation/foundation-icons.css" rel="stylesheet" media="screen">
<link href="<%=HostName%>/fonts/fontawezome/css/all.min.css" rel="stylesheet" media="screen">
<!--Fonts-->

<!--Legacy-->
<link  href="<%=HostName%>/vendor/legacy/css/ie10-viewport-bug-workaround.css" rel="stylesheet">
<script type="text/javascript" src="<%=HostName%>/vendor/legacy/js/ie10-viewport-bug-workaround.js"></script>
<!--Legacy-->

<!-- mCustomScrollbar -->
<link rel="stylesheet" href="<%=HostName%>/vendor/mCustomScrollbar/css/jquery.mCustomScrollbar.css" />
<script src="<%=HostName%>/vendor/mCustomScrollbar/js/jquery.mCustomScrollbar.concat.min.js"></script>
<!-- mCustomScrollbar -->

<!-- Text Editor -->
<link rel="stylesheet" href="<%=HostName%>/vendor/jQuery-TE/jquery-te-1.4.0.css" />
<script src="<%=HostName%>/vendor/jQuery-TE/jquery-te-1.4.0.min.js"></script>
<!-- Text Editor -->

<!--Custom Site Style-->
<link href="<%=HostName%>/css/escritorio.css?v4.4" rel="stylesheet">
<link href="<%=HostName%>/css/descargas.css?v1.2" rel="stylesheet">
<link href="<%=HostName%>/css/breadcrumb.css?v3.4" rel="stylesheet">
<link href="<%=HostName%>/css/perfil.css?v3.8" rel="stylesheet">
<link href="<%=HostName%>/css/transitions.css?v1.0" rel="stylesheet">
<link href="<%=HostName%>/css/suggestions.css?v1.6" rel="stylesheet">
<link href="<%=HostName%>/css/tailwindcss.css?v1.2" rel="stylesheet">

<script type="text/javascript" src="<%=HostName%>/js/escritorio.js?v5.1"></script>
<!--Custom Site Style-->
