<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
    
<!DOCTYPE html>

<html>

<head>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Documentation</title>
	
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
	<link rel="stylesheet" href="css/nav-css.css">
	
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
</head>

<style>
	#header {
    	text-align: center;
	}
</style>

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
						<li><a href="index.jsp">Home</a></li>
						<li><a href="regular-report.jsp">Regular Report</a></li>
						<li><a href="deferred.jsp">Deferred Report</a></li>
						<li><a href="reportcaster.jsp">ReportCaster</a></li>
						<li class="active"><a href="#">Documentation</a></li>
					</ul>
					<ul class="nav navbar-nav navbar-right">
						<li><a href="logout.jsp" id="log-out">
						<span class="glyphicon glyphicon-log-out"></span> Log Out</a></li>
					</ul>
				</div>
			</div>
		</nav>
		
		<div id="header">
   		 <h2>Documentation</h2>
   		 <p>Click <a href="Embedding Applications with Java FINAL.pdf" target="_blank" style="font-style: oblique; font-weight: bold;"> here </a> to open the documentation in a new window!</p>
   		 <br></br>
   	 	</div>
		
		<iframe style="width:100%; height:750px;" src="Embedding Applications with Java FINAL.pdf"></iframe>

	</div>
 
</body>

</html>