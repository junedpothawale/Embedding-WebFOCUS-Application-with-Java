<!DOCTYPE html>

<html lang="en">

<head>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Log In</title>
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
	<link rel="stylesheet" href="css/log-in.css">
</head>

<body>

	<div class="container" id="mainContainer">

		<form class="form" role="form" method="post" action="logincheck.jsp" accept-charset="UTF-8" id="login-nav">
			<div class="form-group">
				<label class="sr-only" for="enterUserId">User ID</label> 
				<input type="text" class="form-control" id="enterUserId" name="enterUserId" placeholder="Enter User ID" required>
			</div>
			<div class="form-group">
				<label class="sr-only" for="userPassword">Password</label> 
				<input type="password" class="form-control" id="userPassword" name="userPassword" placeholder="Password" required>
			</div>
			<div class="form-group">
				<button type="submit" class="btn btn-primary btn-block">Sign in</button>
			</div>
		</form>

	</div>

</body>

</html>
