<%
'--------------------------------------------------------------------
' Archivo de cabecera HEAD.INC
'
'--------------------------------------------------------------------
HostName = "https://" & Request.ServerVariables("SERVER_NAME")
%>
<link rel="shortcut icon" type="image/x-icon" href="<%=HostName%>/img/gobcl-favicon.ico"  />

<!--jquery-->
<link  href="<%=HostName%>/vendor/jquery/css/jquery-ui.css" rel="stylesheet">

<script type="text/javascript" src="<%=HostName%>/vendor/jquery/js/jquery-3.6.0.min.js"></script>
<script type="text/javascript" src="<%=HostName%>/vendor/jquery/js/jquery-ui.min.js"></script>
<!--jquery-->

<!--Bootstrap-->
<script type="text/javascript" src="<%=HostName%>/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<link  href="<%=HostName%>/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-theme">
<!--Bootstrap-->

<!--MDB-->
<script type="text/javascript" src="<%=HostName%>/vendor/mdb/js/mdb.min.js"></script>
<link  href="<%=HostName%>/vendor/mdb/css/mdb.min.css" rel="stylesheet">
<!--MDB-->

<!--capslockstate-->
<script type="text/javascript" src="<%=HostName%>/vendor/capslockstate/js/jquery.capslockstate.js"></script>
<!--capslockstate-->

<!--validator-->
<script type="text/javascript" src="<%=HostName%>/vendor/validator/jquery.validate.min.js"></script>
<script type="text/javascript" src="<%=HostName%>/vendor/validator/localization/messages_es.min.js"></script>
<!--validator-->

<!--sweetalert-->
<script src="<%=HostName%>/vendor/sweetalert2/js/sweetalert2.all.min.js"></script>
<link rel="stylesheet" href="<%=HostName%>/vendor/sweetalert2/css/sweetalert2.min.css" />
<!--sweetalert-->

<!--Fonts-->
<link href="<%=HostName%>/fonts/foundation/foundation-icons.css" rel="stylesheet" media="screen">
<link href="<%=HostName%>/fonts/fontawezome/css/all.min.css" rel="stylesheet" media="screen">
<!--Fonts-->

<!--Legacy-->
<link  href="<%=HostName%>/vendor/legacy/css/ie10-viewport-bug-workaround.css" rel="stylesheet">
<script type="text/javascript" src="<%=HostName%>/vendor/legacy/js/ie10-viewport-bug-workaround.js"></script>
<!--Legacy-->

<!--Custom Site Style-->
<link  href="<%=HostName%>/vendor/materializecss/select.css" rel="stylesheet">
<link href="<%=HostName%>/css/signin.css?v2.7" rel="stylesheet">
<link href="<%=HostName%>/css/transitions.css?v1.0" rel="stylesheet">
<script type="text/javascript" src="<%=HostName%>/js/signin.js?v2.7"></script>
<!--Custom Site Style-->
