<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Login.aspx.vb" Inherits="newlogin" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CES / CIC</title>
    <link href="assets_login/css/bootstrap.css" rel="stylesheet">
    <!--external css-->
    <link href="assets_login/font-awesome/css/font-awesome.css" rel="stylesheet" />
        
    <!-- Custom styles for this template -->
    <link href="assets_login/css/style.css" rel="stylesheet">
    <link href="assets_login/css/style-responsive.css" rel="stylesheet">

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

<body>
  
   <div id="login-page">
	  	<div class="container">
	  	
		        <form id="form1" runat="server" class="form-login" >
		        <h2 class="form-login-heading">Ingreso CIC</h2>
		        <div class="login-wrap">
		            <asp:TextBox ID="txtnombre" runat="server" AutoPostBack="false" CssClass="form-control" placeholder="User Id" autofocus></asp:TextBox>
		            <br/>
		            <asp:TextBox ID="txtcontrasena" runat="server" TextMode="Password" placeholder="Password" CssClass="form-control"></asp:TextBox></td>
		            
		            <br />
		            <asp:Label ID="mensaje" runat="server"></asp:Label>
		            <br />
		              <asp:Button ID="ACEPTAR" runat="server" Text="Ingresar" OnClick="ACEPTAR_Click" CssClass="btn btn-theme btn-block" />
		            <hr>
		        </div>
		
		
		      </form>
	  	
	  	</div>
	  </div>

    <!-- js placed at the end of the document so the pages load faster -->
    <script src="assets_login/js/jquery.js"></script>
    <script src="assets_login/js/bootstrap.min.js"></script>

    <!--BACKSTRETCH-->
    <!-- You can use an image of whatever size. This script will stretch to fit in any screen size.-->
    <script type="text/javascript" src="assets_login/js/jquery.backstretch.min.js"></script>
    <script>
        $.backstretch("assets_login/img/paipaiv.jpg", {speed: 500});
    </script>
    
</body>
</html>
