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
     * Redirects the user to the login page if they no longer have an active session
     */
    String user = (String) session.getAttribute("user");
    if (user == null) {
   	 response.sendRedirect("login.jsp");
    } else {
%>

<%
    /**
   	* Defines hostname, cookies[], client, which are pulled from logincheck.jsp to maintain the session
   	* Defines arrayLists to hold urls, report titles, and report names
   	*/
   	 String hostname = (String) session.getAttribute("hostname");
   	 Header[] cookies = (Header[]) session.getAttribute("cookies");
   	 CloseableHttpClient client = (CloseableHttpClient) session.getAttribute("client");
   	 List<String> urls = new ArrayList<String>();
   	 List<String> reportTitles = new ArrayList<String>();
   	 List<String> reportNames = new ArrayList<String>();
    
   	 /**
   	  * folderURL is put together using hostname to access the XML file for the public folder
   	  */
   	 String folderURL = "http://" + hostname
   			 + ".ibi.com:8080/ibi_apps/rs/ibfs/WFC/Repository/Public?IBIRS_action=get";
   	 
   	 /**
   	  * Defines getFolderContent as get request using the folderURL
   	  */
   	 HttpGet getFolderContent = new HttpGet(folderURL);
   	 
   	 /**
   	  * For loop attaches cookies to "getFolderContent"
   	  */
   	 for (int h = 0; h < cookies.length; h++) {
   		 getFolderContent.addHeader(cookies[h].getName(), cookies[h].getValue());
   	 }
   	 
   	 /**
   	  * Defines HttpResponse outside of the try block so it can be called outside of it
   	  */
   	 HttpResponse httpResponse = null;
   	 
   	/**
   	  * Executes getFolderContent
   	  * Gets the status code for possible errors
   	  * Catch displays possible error messages
   	  */
   	 try {
   		 httpResponse = client.execute(getFolderContent);
   		 int statusCode = httpResponse.getStatusLine().getStatusCode();
   	 } catch (Exception ex) {
   		 System.out.println("HttpResponse Error: " + ex.getMessage());
   	 }
   	 
   	 /**
   	  * Defines HttpResponse outside of the try block so it can be called outside of it
   	  */
   	 try {
   		 InputStream rstream = httpResponse.getEntity().getContent();
   		 BufferedReader br = new BufferedReader(new InputStreamReader(rstream));
   		 String line;
   		 String newOutput = null;
   		 
   		 /**
   		  * While loop reads the webpage line by line
   		  * Each line is concatenated into "line"
   		  */
   		 while ((line = br.readLine()) != null) {
   			 newOutput = line;
   			 /**
   			  * "line" is split up by "<" into an array "stringArray"
   			  * Each line is checked to see if it contains "description=" & typeDescription="report"
   			  * If it fits that criteria it is saved to "descLine"
   			  */
   			 String[] stringArray = line.split("<");
   			 for (int i = 0; i < stringArray.length; i++) {
   				 if (stringArray[i].contains("description=\"")
   						 && stringArray[i].contains("typeDescription=\"Report\"")) {
   					 String descLine = stringArray[i];
   					 /**
   					  * descLine is split up by spaces into stringArray2[]
   					  * for loop iterates through the strings to see if they contain "description"
   					  * if they do, they are saved tp reportTitles[]
   					  */
   					 String[] stringArray2 = descLine.split("\"\\s+");
   					 for (int j = 0; j < stringArray2.length; j++) {
   						 String descLine2 = stringArray2[j];
   						 if (descLine2.contains("description")) {
   							 String descLine3 = descLine2.replace("description=\"", "").replace("\"", "");
   							 reportTitles.add(descLine3);
   						 }
   						 /**
   						  * if descLine2 line contains "name=" then the name is saved to "reportNames[]"
   						  */
   						 if (descLine2.contains("name=\"")) {
   							 String nameLines = descLine2.replace("name=\"", "").replace("\"", "");
   							 reportNames.add(nameLines);;
   						 }
   					 }
   				 }
   			 }
   		 }

		/**
   		  * The buffered reader is closed
   		  * Catch makes sure to keep any errors from executing and displays the error message
   		  */
   		 br.close();
   	 } catch (Exception ex) {
   		 System.out.println("RStream Error: " + ex.getMessage());
   	 }
   	 
   	 /**
   	  * urls array is iterated through and each string in it is split by "/"
   	  * From the url, the reportTitle is pulled and saved into reportTitles[]
   	  */
   	 for (int i = 0; i < urls.size(); i++) {
   		 String[] sub = urls.get(i).split("/");
   		 for (int j = 0; j < sub.length; j++) {
   			 if (sub[j].contains(".fex")) {
   				 reportTitles.add(sub[j].replace(".fex", ""));
   			 }
   		 }
   	 }
%>

<html lang="en">

<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Regular Report</title>

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
.noframe {
    display: none;
}

.showframe {
    display: block;
}

.theFrame {
    height: 350px;
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
    border-radius: 4px;
    transition: all 0.2s ease-in-out;
}

.button:hover {
    background-color: #79bff5;
}

th, tr {
    text-align: center;
}

td {
    width: 68%;
}

table {
    border: 1px solid black;
    overflow: scroll;
    border-collapse: collapse;
    width: 100%;
}

#tabdiv {
    display: block;
    height: 200px;
    overflow-y: scroll;
    overflow: auto;
}

tr:nth-child(even) {
    background-color: #f2f2f2;
}

form {
    width: 100%;
}

#header {
    text-align: center;
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
   					 <li class="active"><a href="#">Regular Report</a></li>
   					 <li><a href="deferred.jsp">Deferred Report</a></li>
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
   		 <h2>Available Reports</h2>
   		 <p>Click to view your reports!</p>
   		 <br></br>
   	 </div>

   	 <table>
   		 <tr>
   			 <th class="titletext">Report Name</th>
   			 <th class="titletext">Action</th>
   		 </tr>
   	 </table>

   	 <div id=tabdiv>
   		 <table>
   			 <tr>
   				 <%
   					 for (int i = 0; i < reportTitles.size(); i++) {
   				 %>
   				 <td class="titletext"><%=reportTitles.get(i)%></td>
   				 <td>
   					 <form name="x" action="regular-redirect.jsp"
   						 target="name_of_iframe" onclick="clearFrame()">
   						 <input class="button" type="hidden" name="x"
   							 value="<%=reportNames.get(i)%>"></input>
   						 <button type="submit" class="button">View Report</button>
   					 </form>
   				 </td>
   			 </tr>
   			 <%
   				 }
   			 %>
   		 </table>
   	 </div>

   	 <br> <br>

   	 <div class="theFrame" id="theFrameDiv">
   		 <iframe style="border: none;" onLoad="loadFrame()"
   			 name="name_of_iframe" id="theFrame" width="100%" height="350px"></iframe>
   	 </div>

    </div>
</body>

</html>

<%
    }
%>
