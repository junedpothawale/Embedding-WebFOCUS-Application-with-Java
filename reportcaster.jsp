<!DOCTYPE html>

<%@ page
    import="java.util.*,
	java.net.*,
	java.io.*,
	java.text.*,
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
		* Variable hostname is defined and then pulled from the user's computer
		* Variable addr is defined and then pulled from the user's computer
		* Exceptions are caught if the program can't access the users hostname
		*/
	String hostname = "Unknown";
	
	try {
		InetAddress addr;
		addr = InetAddress.getLocalHost();
		hostname = addr.getHostName();
	} catch (UnknownHostException ex) {
		System.out.println("Hostname cannot be resolved");
	}
	
	/**
		* This is done in order to maintain a session
		* The cookies array stores the cookies so they can be maintained on other webpages
		* A client is also opened in order to maintain the session
		*/
	Header[] cookies = null;
	CloseableHttpClient client = HttpClients.createDefault();
	
	/**
		* String url is constructed using the hostname
		*/
	String url = "http://" + hostname +  ".ibi.com:8080/ibi_apps/rs/ibfs";
	HttpPost method =  new HttpPost(url);
	
	/**
		* NameValuePair[] is made in order to save the users credentials and maintain the session
		*/
	ArrayList<NameValuePair> parameters = new ArrayList<NameValuePair>();
	parameters.add(new BasicNameValuePair("IBIRS_action","signOn"));
	parameters.add(new BasicNameValuePair("IBIRS_userName","admin"));
	parameters.add(new BasicNameValuePair("IBIRS_password","admin"));
	
	/**
		* This try catch is there to catch an error for a missing parameter saved in the above arraylist
		*/
	try {
		method.setEntity(new UrlEncodedFormEntity(parameters));
	} catch (Exception ex) {
		System.out.println("Set Parameters Error: +"+ex.getMessage());
	}
	
	/**
		* Sets httpResponse equal to the post method
		* Saves the cookies for use on other pages
		* Sets session attributes for use on other pages
		*/
	try {
		HttpResponse httpResponse = client.execute(method);
		int statusCode = httpResponse.getStatusLine().getStatusCode();
		 
		cookies = method.getHeaders("Set-Cookie");
		cookies = httpResponse.getHeaders("Set-Cookie");
		 
		session.setAttribute("cookies", cookies);
		session.setAttribute("client", client);
		session.setAttribute("user", "IBIRS_userName");
		session.setAttribute("hostname", hostname);
	} catch (Exception ex) {
		System.out.println("HttpResponse: "+ex.getMessage());
	}

//==========================================================================================================

   	 /**
   	  * Creates the folderURL using the user's hostname
   	  */
   	 String folderURL = "http://" + hostname
   			 + ".ibi.com:8080/ibi_apps/rs/ibfs/WFC/Repository/Public?IBIRS_action=get";
   	 /**
   	  * Defines getFolderXML as get request using the folderURL
   	  */
   	  
   	 HttpGet getFolderXML = new HttpGet(folderURL);
   	 
   	 /**
   	  * For loop attaches cookies to the "getFolderXML" get request
   	  */
   	 for (int h = 0; h < cookies.length; h++) {
   		 getFolderXML.addHeader(cookies[h].getName(), cookies[h].getValue());
   	 }
   	 
   	 /**
   	  * Defines httpResponse outside the try block so it can be called outside of it
   	  */
   	 HttpResponse httpResponse = null;
   			  
   	 /**
   	  * Executes the get request
   	  * Gets status code for possible error
   	  * Catch displays possible error message
   	  */
   	 try {
   		 httpResponse = client.execute(getFolderXML);
   		 int statusCode = httpResponse.getStatusLine().getStatusCode();
   	 } catch (Exception ex) {
   		 System.out.println("HttpResponse Error: " + ex.getMessage());
   	 }
   	 
   	 /**
   	  * Creates ArrayLists for the report names, report titles, to emails, from emails, start times, end times, and rest urls
   	  */
   	 List<String> reportNames = new ArrayList<String>();
   	 List<String> reportTitles = new ArrayList<String>();
   	 List<String> toEmails = new ArrayList<String>();
   	 List<String> fromEmails = new ArrayList<String>();
   	 List<String> startTimes = new ArrayList<String>();
   	 List<String> endTimes = new ArrayList<String>();
   	 List<String> restUrls = new ArrayList<String>();

   	 /**
   	  * Creates rstream and br to read the XML
   	  */
   	 try {
   		 InputStream rstream = httpResponse.getEntity().getContent();
   		 BufferedReader br = new BufferedReader(new InputStreamReader(rstream));		 
   		 /**
   		  * Defines string line and newOutput
   		  */
   		 String line;
   		 String newOutput = null;
   		 /**
   		  * While loop reads through the XML line by line
   		  */
   		 while ((line = br.readLine()) != null) {
   			 newOutput = line;
   			 /**
   			  * The lines are split up by spaces into stringArray[]
   			  * For loop goes through the stringArray to see if one of the strings contains "rsPath=" and "sch"
   			  * Gets the path and adds it to a complete url and adds that url to restUrls
   			  */
   			 String[] stringArray = line.split("\\s+");
   			 for (int i = 0; i < stringArray.length; i++) {
   				 if (stringArray[i].contains("rsPath=") && stringArray[i].contains("sch")) {
   					 String temp = stringArray[i].replace("rsPath=\"", "");
   					 String temp2 = temp.replace("\"", "?IBIRS_action=get");
   					 String sub = "http://" + hostname + ".ibi.com:8080" + temp2;
   					 restUrls.add(sub);
   				 }
   			 }
   			 /**
   			  * Splits up XML by "<" into samp[]
   			  * Checks to each in samp[] to see if it contains "description=" & "typeDescription=\"Schedule\"
   			  * If so, it is saved to descLine
   			  * descLine is the split up by quote space (" ), into samp2[]
   			  * Each string in samp2[] is checked if it contains "description"
   			  * The contents of the description tag are saved to "reportTitles[]"
   			  */
   			 String[] samp = line.split("<");
   			 for (int i = 0; i < samp.length; i++) {
   				 if (samp[i].contains("description=\"")
   						 && samp[i].contains("typeDescription=\"Schedule\"")) {
   					 String descLine = samp[i];
   					 String[] samp2 = descLine.split("\"\\s+");
   					 for (int j = 0; j < samp2.length; j++) {
   						 String descLine2 = samp2[j];
   						 if (descLine2.contains("description")) {
   							 String descLine3 = descLine2.replace("description=\"", "").replace("\"", "");
   							 reportTitles.add(descLine3);
   						 }
   						 /**
   						  * If descLine 2 has "name=" the it is saved to reportNames
   						  */
   						 if (descLine2.contains("name=\"")) {
   							 String nameLines = descLine2.replace("name=\"", "").replace("\"", "");
   							 reportNames.add(nameLines);
   						 }
   					 }
   				 }
   			 }
   		 }
   		 /**
   		  * The buffered reader is closed
   		  * Catch displays possible error message
   		  */
   		 br.close();
   	 } catch (Exception ex) {
   		 System.out.println("RStream Error: " + ex.getMessage());
   	 }
   	 
   	 //For Displaying Information About Schedules------------------------------------------------------
   	 for (int i = 0; i < restUrls.size(); i++) {
   		 String tempRestURL = restUrls.get(i);
   		 
   		 /**
   		  * Executes all HttpGet requests in restUrls[]
   		  */
   		 HttpGet getReport = new HttpGet(tempRestURL);
   		 
   		 /**
   		  * Defines httpResponse2 outside of the try block
   		  */
   		 HttpResponse httpResponse2 = null;
   				  
   		 /**
   		  * Executes the get request
   		  * Gets status code for possible error
   		  * Catch displays possible error message
   		  */
   		 try {
   			 httpResponse2 = client.execute(getReport);
   			 int statusCode = httpResponse2.getStatusLine().getStatusCode();
   		 } catch (Exception ex) {
   			 System.out.println("HttpResponse2 Error: " + ex.getMessage());
   		 }
   		 
   		 /**
   		  * Creates rstream and br to read the XML
   		  */
   		 try {
   			 InputStream rstream = httpResponse2.getEntity().getContent();
   			 BufferedReader br = new BufferedReader(new InputStreamReader(rstream));
   			 /**
   			  * Defines string line outside the while loop for use outside of it
   			  */
   			 String line;
   			 /**
   			  * Splits the line containing the XML response by spaces into stringArray[]
   			  * Checks each string in stringArray[] for "destinationAddress="
   			  * Saves destination address in the toEmails[]
   			  */
   			 while ((line = br.readLine()) != null) {
   				 String[] stringArray = line.split("\\s+");
   				 for (int j = 0; j < stringArray.length; j++) {
   					 if (stringArray[j].contains("destinationAddress=")) {
   						 String temp = stringArray[j].replace("destinationAddress=\"", "");
   						 String temp2 = temp.replace("\"", "");
   						 toEmails.add(temp2);
   					 }
   					 /**
   					  * Checks each string in stringArray[] for "mailReplyAddress="
   					  * Saves destination address in the fromEmails[]
   					  */
   					 if (stringArray[j].contains("mailReplyAddress=")) {
   						 String temp = stringArray[j].replace("mailReplyAddress=\"", "");
   						 String temp2 = temp.replace("\"", "");
   						 fromEmails.add(temp2);
   					 }
   				 }
   				 /**
   				  * Splits up "line" by "<" and saves it tostringArray2[]
   				  */
   				 String[] stringArray2 = line.split("<");
   				 for (int j = 0; j < stringArray2.length; j++) {
   					 /**
   					  * Checks each string in stringArray2[] if it contains "startTime"
   					  * If so, it replaces the beginning and end of it with nothing, leaving behind the unix time
   					  * It is then parsed into the gregorian calendar format
   					  * Then it is saved to startTimes[]
   					  */
   					 if (stringArray2[j].contains("startTime")) {
   						 String temp = stringArray2[j].replace("startTime _jt=\"gregCalendar\" time=\"", "");
   						 String temp2 = temp.replace("\" timeZone=\"America/New_York\"/>", "");
   						 long temp3 = Long.parseLong(temp2);
   						 Date date = new Date(temp3);
   						 SimpleDateFormat jdf = new SimpleDateFormat("MM-dd-yyyy HH:mm:ss z");
   						 String java_date = jdf.format(date);
   						 startTimes.add(java_date);
   					 }
   					 /**
   					  * Checks each string in stringArray2[] if it contains "endTime"
   					  * If so, it replaces the beining and end of it with nothing, leaving behind the unix time
   					  * It is then parsed into the gregorian calendar format
   					  * Then it is saved to endTimes[]
   					  */
   					 if (stringArray2[j].contains("endTime")) {
   						 String temp = stringArray2[j].replace("endTime _jt=\"gregCalendar\" time=\"", "");
   						 String splitBySpace = temp;
   						 String[] split = temp.split("\\s+");
   						 String temp2 = temp.replace("\" timeZone=\"America/New_York\"/>", "");
   						 long temp3 = Long.parseLong(temp2);
   						 Date date = new Date(temp3);
   						 SimpleDateFormat jdf = new SimpleDateFormat("MM-dd-yyyy HH:mm:ss z");
   						 String java_date = jdf.format(date);
   						 endTimes.add(java_date);
   					 }
   				 }

   				 /**
   				  * If report does not have an endtime (aka it is only scheduled to be sent out once) then add a blank string
   				  */
   				 if (!line.contains("endTime")) {
   					 endTimes.add("");
   				 }
   			 }
   			 /**
   			  * The buffered reader is then closed
   			  * Catch displays possible error message
   			  */
   			 br.close();
   		 } catch (Exception ex) {
   			 System.out.println("RStream Error: " + ex.getMessage());
   		 }
   	 }
%>

<html lang="en">

<head>
<title>ReportCaster</title>

<link rel="stylesheet"
    href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link rel="stylesheet" href="css/nav-css.css">
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
.button {
    background-color: rgba(0, 0, 0, 0);
    color: #2496EF;
    border: none;
    cursor: pointer;
    transition: all 0.2s ease-in-out;
    font-weight: 600;
}

.button:hover {
    color: #79bff5;
}

.noframe {
    display: none;
}

.showframe {
    display: block;
}

.theFrame {
    height: 350px;
    border-style:
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

td {
    width: 15%;
    border:;
}

th, tr {
    text-align: center;
}

th {
    width: 15%;
}

iframe {
    margin: 10px
}

tr:nth-child(even) {
    background-color: #f2f2f2;
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
   					 <li><a href="regular-report.jsp">Regular Report</a></li>
   					 <li><a href="deferred.jsp">Deferred Report</a></li>
   					 <li class="active"><a href="#">ReportCaster</a></li>
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
   		 <h2>ReportCaster</h2>
   		 <p>Click to view or delete your scheduled reports!</p>
   		 <br></br>
   	 </div>

   	 <table>
   		 <tr>
   			 <th>Report Name</th>
   			 <th>To Email</th>
   			 <th>From Email</th>
   			 <th>Start Time</th>
   			 <th>End Time</th>
   			 <th>Delete</th>
   		 </tr>
   	 </table>

   	 <div id=tabdiv>
   		 <table>
   			 <%
   				 for (int i = 0; i < reportNames.size(); i++) {
   			 %>
   			 <tr>
   				 <td>
   					 <form name="x" action="rc-redirect.jsp" target="name_of_iframe"
   						 onclick="clearFrame()">
   						 <input type="hidden" name="x" value="<%=reportNames.get(i)%>"></input>
   						 <button class="button" type="submit"><%=reportTitles.get(i)%></button>
   					 </form>
   				 </td>
   				 <td><%=toEmails.get(i)%></td>
   				 <td><%=fromEmails.get(i)%></td>
   				 <td><%=startTimes.get(i)%></td>
   				 <td><%=endTimes.get(i)%></td>
   				 <td id="delete_icon">
   					 <form action="delete-redirect.jsp">
   						 <input type="hidden" name="x" value="<%=reportNames.get(i)%>" />
   						 <input type="image"
   							 src="https://image.flaticon.com/icons/svg/69/69324.svg"
   							 height=20px width=20px>
   					 </form>
   				 </td>
   			 </tr>
   			 <%
   				 }
   			 %>
   		 </table>
   	 </div>

   	 <div class="theFrame" id="theFrameDiv">
   		 <iframe onLoad="loadFrame()" name="name_of_iframe" id="theFrame"
   			 width="100%" height="450px" style="border-style: none;"></iframe>
   	 </div>

    </div>
</body>

</html>

<%
    }
%>