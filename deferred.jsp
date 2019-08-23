<!DOCTYPE html>

<%@ page
    import="java.util.*,
	java.net.*,
	java.io.*,
	java.awt.Frame,
	java.io.BufferedReader,
	java.io.File,
	java.io.FileOutputStream,
	java.io.IOException,
	java.io.InputStream,
	java.io.InputStreamReader,
	java.io.PrintWriter,
	java.io.UnsupportedEncodingException,
	java.util.ArrayList,
	org.apache.http.Header,
	org.apache.http.HttpResponse,
	org.apache.http.NameValuePair,
	org.apache.http.client.*,
	org.apache.http.client.entity.UrlEncodedFormEntity,
	org.apache.http.client.methods.*,
	org.apache.http.impl.client.CloseableHttpClient,
	org.apache.http.impl.client.HttpClients,
	org.apache.http.message.BasicNameValuePair"%>

<%
    /**
     * Redirects the user to the login page if they don't have an active session
     */
    String user = (String) session.getAttribute("user");
    if (user == null) {
   	 response.sendRedirect("login.jsp");
    } else {
%>

<%
   	/**
   	* Defines hostname, cookies[], client, which are pulled from logincheck.jsp to maintain the session
   	*/
   	 String hostname = (String) session.getAttribute("hostname");
   	 Header[] cookies = (Header[]) session.getAttribute("cookies");
   	 CloseableHttpClient client = (CloseableHttpClient) session.getAttribute("client");
   	 
   	 /**
   	  * Defines ArrayLists: reportNames, reportStatus, reportTickets
   	  */
   	 List<String> reportNames = new ArrayList<String>();
   	 List<String> reportStatus = new ArrayList<String>();
   	 List<String> reportTickets = new ArrayList<String>();
   	 
   	 /**
   	  * Creates the listTicketsURL using the user's hostname
   	  */
   	 String listTicketsURL = "http://" + hostname
   			 + ".ibi.com:8080/ibi_apps/rs?IBIRS_action=listTickets&IBIRS_service=defer";
   	 
   	 /**
   	  * Defines getCall as get request using the listTicketsURL
   	  */
   	 HttpGet getCall = new HttpGet(listTicketsURL);
   	 
   	 /**
   	  * For loop attaches cookies to the "getCall" get request
   	  */
   	 for (int h = 0; h < cookies.length; h++) {
   		 getCall.addHeader(cookies[h].getName(), cookies[h].getValue());
   	 }
   	 
   	 /**
   	  * Defines httpResponse outside the try block so it can be called outside the try block
   	  */
   	 HttpResponse httpResponse = null;
   	 
   	/**
   	  * Executes the get request
   	  * Gets status code for possible error
   	  * Catch prevents from executing any errors and displays error message
   	  */
   	 try {
   		 httpResponse = client.execute(getCall);
   		 int statusCode = httpResponse.getStatusLine().getStatusCode();
   	 } catch (Exception ex) {
   		 System.out.println("HttpResponse Error: " + ex.getMessage());
   	 }
   	 
   	 /**
   	  * Creates rstream and br to read the XML
   	  */
   	 try {
   		 InputStream rstream = httpResponse.getEntity().getContent();
   		 BufferedReader br = new BufferedReader(new InputStreamReader(rstream));
   		 /**
   		  * Defines string line outside the while loop for use outside of it
   		  */
   		 String line;
   		 /**
   		  * While loop reads through the XML line by line
   		  */
   		 while ((line = br.readLine()) != null) {

   			 String[] tempNameArray;
   			 String tempName;
   			 String[] tempNameArrayStatus;
   			 String tempStatus;
   			 /**
   			  * Splits up each line by "<"
   			  * For loop iterates through all lines
   			  * Checks if particular line contains: item _jt="IBFSMRDefTicketObject"
   			  * If so, that line is broken down by spaces
   			  * Iterates through those lines to get the report name and is added to reportNames[]
   			  */
   			 String[] stringArray = line.split("<");
   			 for (int i = 0; i < stringArray.length; i++) {
   				 if (stringArray[i].contains("item _jt=\"IBFSMRDefTicketObject\"")) {
   					 tempNameArray = stringArray[i].split("\"\\s+");
   					 for (int j = 0; j < tempNameArray.length; j++) {
   						 if (tempNameArray[j].contains("description=")) {
   							 tempName = tempNameArray[j].replace("description=\"", "");
   							 reportNames.add(tempName);
   						 }
   					 }
   				 }
   				 /**
   				  * Checks for lines if they contain "CTH_DEFER_"
   				  * Those lines are saved and then split by spaces
   				  * Pulls out the deferred report status
   				  * If the status equals "CTH_DEFER_READY" then it is saved to the reportStatus array as "COMPLETE" otherwise "NOT COMPLETE"
   				  * Buffered reader is closed
   				  * Catch displays the error status message
   				  */
   				 if (stringArray[i].contains("CTH_DEFER_")) {
   					 tempNameArrayStatus = stringArray[i].split("\\s+");
   					 for (int j = 0; j < tempNameArrayStatus.length; j++) {
   						 if (tempNameArrayStatus[j].contains("name=\"CTH_DEFER_")) {
   							 tempStatus = tempNameArrayStatus[j].replace("name=\"", "");
   							 tempStatus = tempStatus.replace("\"/>", "");
   							 if (tempStatus.equals("CTH_DEFER_READY")) {
   								 tempStatus = "COMPLETE";
   							 } else {
   								 tempStatus = "NOT COMPLETE";
   							 }
   							 reportStatus.add(tempStatus);
   						 }
   					 }
   				 }
   			 }

   		 }
   		 br.close();
   	 } catch (Exception ex) {
   		 System.out.println("RStream Error: " + ex.getMessage());
   	 }
%>

<html lang="en">

<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Deferred Report</title>

<link rel="stylesheet"
    href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link rel="stylesheet" href="css/nav-css.css">
<link rel="stylesheet" href="css/sales-portal.css">

<script
    src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
<script
    src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>

<script type="text/javascript">
    function clearFrame() {
   	 document.getElementById("theFrame").className = "noframe";
   	 document.getElementById("theFrameDiv").style.background = "url(https://mir-s3-cdn-cf.behance.net/project_modules/disp/09b24e31234507.564a1d23c07b4.gif) center center no-repeat";
    }
    function loadFrame() {
   	 document.getElementById("theFrame").className = "showframe";
   	 document.getElementById("theFrameDiv").style.background = "url(white_background.png)";
    }
</script>

<style>
th, tr {
    text-align: center;
    width: 34%;
}

td {
    width: 34%;
}

.button {
    background-color: #2496EF;
    border: none;
    color: white;
    padding: 8px 32px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 16px;
    margin: 4px 2px;
    cursor: pointer;
    width: 80%;
    transition: all 0.2s ease-in-out;
    border-radius: 4px;
}

.button:hover {
    background-color: #79bff5;
}

table {
    border: 1px solid black;
    overflow: scroll;
    border-collapse: collapse;
    width: 100%;
}

tr:nth-child(even) {
    background-color: #f2f2f2;
}

.noframe {
    display: none;
}

.showframe {
    display: block;
}

.theFrame {
    height: 350px;
}

#tabdiv {
    display: block;
    height: 200px;
    overflow-y: scroll;
    overflow: auto;
}

form {
    width: 100%;
}

#header {
    text-align: center;
}

#complete {
    color: #4CB04E;
    font-weight: bold;
}

#not_complete {
    color: red;
    font-weight: bold;
}
</style>
</head>

<body>
    <div class="container" id="mainContainer">

   	 <nav class="navbar navbar-default" id="page-nav">
   		 <div class="container-fluid">
   			 <div class="navbar-header">
   				 <button type="button" class="navbar-toggle" data-toggle="collapse"
   					 data-target="#myNavbar">
   					 <span class="icon-bar"></span> <span class="icon-bar"></span> <span
   						 class="icon-bar"></span>
   				 </button>
   				 <a class="navbar-brand" href="index.jsp">Company ABC</a>
   			 </div>
   			 <div class="collapse navbar-collapse" id="myNavbar">
   				 <ul class="nav navbar-nav">
   					 <li><a href="index.jsp">Home</a></li>
   					 <li><a href="regular-report.jsp">Regular Report</a></li>
   					 <li class="active"><a href="#">Deferred Report</a></li>
   					 <li><a href="reportcaster.jsp">ReportCaster</a></li>
   					 <li><a href="documentation.jsp">Documentation</a></li>
   				 </ul>
   				 <ul class="nav navbar-nav navbar-right">
   					 <li><a href="logout.jsp" id="log-out"><span
   							 class="glyphicon glyphicon-log-out"></span> Log Out</a></li>
   				 </ul>
   			 </div>
   		 </div>
   	 </nav>

   	 <div id="header">
   		 <h2>Deferred Reports</h2>
   		 <p>View the status of your deferred reports and click to view
   			 them!</p>
   		 <br></br>
   	 </div>

   	 <table>
   		 <tr>
   			 <th>Report Name</th>
   			 <th>Report Status</th>
   			 <th>Action</th>
   		 </tr>
   	 </table>

   	 <div id=tabdiv>
   		 <table>
   			 <%
   				 for (int i = 0; i < reportStatus.size(); i++) {
   			 %>
   			 <tr>
   				 <%
   					 if (reportStatus.get(i).equals("COMPLETE")) {
   				 %>

   				 <td><%=reportNames.get(i)%></td>
   				 <td id="complete"><%=reportStatus.get(i)%></td>
   				 <td>
   					 <form name="x" action="defer-redirect.jsp" target="name_of_iframe"
   						 onclick="clearFrame()">
   						 <input type="hidden" name="x" value="<%=reportNames.get(i)%>" />
   						 <button class="button" type="submit">View Report</button>
   					 </form>
   				 </td>

   				 <%
   					 } else {
   				 %>
   				 <td><%=reportNames.get(i)%></td>
   				 <td id="not_complete"><%=reportStatus.get(i)%></td>
   				 <td></td>
   				 <%
   					 }
   				 %>
   			 </tr>
   			 <%
   				 }
   			 %>
   		 </table>
   	 </div>

   	 <div class="theFrame" id="theFrameDiv">
   		 <div>
   			 <iframe onLoad="loadFrame()" name="name_of_iframe" id="theFrame"
   				 width="100%" height="450px" style="border: none"></iframe>
   		 </div>
   	 </div>

    </div>
</body>

</html>

<%
    }
%>