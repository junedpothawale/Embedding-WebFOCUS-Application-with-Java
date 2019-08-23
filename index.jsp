<!DOCTYPE html>

<%
	String user = (String) session.getAttribute("user");
	if (user == null) {
		response.sendRedirect("login.jsp");
	} else {
%>

<html lang="en">

<head>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Home</title>
	
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
	<link rel="stylesheet" href="css/nav-css.css">
	
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
</head>

<body>

	<div class="container" id="mainContainer">

		<nav class="navbar navbar-default" id="page-nav">
			<div class="container-fluid">
				<div class="navbar-header">
					<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#myNavbar">
						<span class="icon-bar"></span> 
						<span class="icon-bar"></span> 
						<span class="icon-bar"></span>
					</button>
					<a class="navbar-brand" href="#">Company ABC</a>
				</div>
				<div class="collapse navbar-collapse" id="myNavbar">
					<ul class="nav navbar-nav">
						<li class="active"><a href="#">Home</a></li>
						<li><a href="regular-report.jsp">Regular Report</a></li>
						<li><a href="deferred.jsp">Deferred Report</a></li>
						<li><a href="reportcaster.jsp">ReportCaster</a></li>
						<li><a href="documentation.jsp">Documentation</a></li>
					</ul>
					<ul class="nav navbar-nav navbar-right">
						<li><a href="logout.jsp" id="log-out">
						<span class="glyphicon glyphicon-log-out"></span> Log Out</a></li>
					</ul>
				</div>
			</div>
		</nav>

		<div class="row" id="salesRow">
			<img src="image/wide1.jpg" class="col-sm-12" id="topImage">
		</div>

		<div class="row" id="credits" style="text-align: center;"> &copy; Colin & Joanne. 2019. All rights reserved</div>

	</div>
</body>

</html>

<%
	}
%>
