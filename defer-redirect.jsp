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
	java.nio.charset.StandardCharsets,
	java.util.ArrayList,
	org.apache.http.Header,
	org.apache.http.HttpResponse,
	org.apache.http.NameValuePair,
	org.apache.http.client.*,
	org.apache.http.client.entity.UrlEncodedFormEntity,
	org.apache.http.client.methods.*,
	org.apache.http.impl.client.CloseableHttpClient,
	org.apache.http.impl.client.HttpClients,
	org.apache.http.message.BasicNameValuePair,
	org.apache.commons.io.IOUtils"%>

<%
    /**
    * Defines hostname, cookies[], client, pulled from logincheck.jsp to maintain the session
    * Defines reportTitle which is pulled from the form block in deferred.jsp
    */
    String hostname = (String) session.getAttribute("hostname");
    Header[] cookies = (Header[]) session.getAttribute("cookies");
    CloseableHttpClient client = (CloseableHttpClient) session.getAttribute("client");
    String reportTitle = request.getParameter("x");
    String ticket = "";
    
    /**
     * Gets the url for all deferred report tickets
     */
    String listTicketsURL = "http://" + hostname
   		 + ".ibi.com:8080/ibi_apps/rs?IBIRS_action=listTickets&IBIRS_service=defer";
    
    /**
     * getTickets is defined to send the get request using listTicketsURL
     */
    HttpGet getTickets = new HttpGet(listTicketsURL);
    
    /**
     * For loop attaches the cookies to the http get request (getTickets)
     */
    for (int h = 0; h < cookies.length; h++) {
   	 getTickets.addHeader(cookies[h].getName(), cookies[h].getValue());
    }
    
    /**
     * Defines HttpResponse outside the try block
     */
    HttpResponse httpResponse = null;
    
    /**
     * httpResponse is set to the executed getTickets request
     * Gets status code for possible error message
     * Catch makes sure to prevent executing any errors
     */
    try {
   	 httpResponse = client.execute(getTickets);
   	 int statusCode = httpResponse.getStatusLine().getStatusCode();
    } catch (Exception ex) {
   	 System.out.println("HttpResponse Error: " + ex.getMessage());
    }
    
    /**
     * Creates and defines rstream and br to read a webpage
     */
    try {
	   	 InputStream rstream = httpResponse.getEntity().getContent();
	   	 BufferedReader br = new BufferedReader(new InputStreamReader(rstream));
	   	 String line;
	   	 String newOutput = "";
	   	 
	   	 /**
	   	  * While loop reads the page line by line and sets it to a "newOutput" string
	   	  */
	   	 while ((line = br.readLine()) != null) {
	   		 newOutput = newOutput + line;
	   	 }
	   	
	   	 /**
	   	  * newOutput string is split up by "<" and put into "stringArray" array
	   	  * Each line in "stringArray" is checked to see if it contains "description=" + reportTitle & "item _jt="IBFSMRDefTicketObject""
	   	  * if it does, then that is split up by spaces and pulls out the ticket for that particular deferred report
	   	  * closes the buffered reader
	   	  */
	   	 String[] stringArray = newOutput.split("<");
	   	 for (int i = 0; i < stringArray.length; i++) {
	   		 if (stringArray[i].contains("description=\"" + reportTitle)
	   				 && stringArray[i].contains("item _jt=\"IBFSMRDefTicketObject\"")) {
	   			 String[] stringArray2 = stringArray[i].split("\\s+");
	   			 for (int j = 0; j < stringArray2.length; j++) {
	   				 if (stringArray2[j].contains("name=")) {
	   					 ticket = stringArray2[j].replace("name=\"", "");
	   					 ticket = ticket.replace("\"", "");
	   				 }
	   			 }
	   		 }
	   	 }
	   	 br.close();
    } catch (Exception ex) {
   	 System.out.println("RStream Error: " + ex.getMessage());
    }
    
    /**
     * Creates the url for getting a deferred report using the newly received "ticket"
     */
    String deferredReportURL = "http://" + hostname
   		 + ".ibi.com:8080/ibi_apps/rs?IBIRS_action=getReport&IBIRS_ticketName=" + ticket
   		 + "&IBIRS_service=defer";
    
    /**
     * Executes the get request using the "deferredReportURL"
     */
    HttpGet getReport = new HttpGet(deferredReportURL);
    
    /**
     * For loop attaches cookies to the "getReport" get request
     */
    for (int h = 0; h < cookies.length; h++) {
   	 getReport.addHeader(cookies[h].getName(), cookies[h].getValue());
    }
    
    /**
     * Defines httpResponse2 and replacedString outside the try block
     */
    HttpResponse httpResponse2 = null;
    String replacedString = "";
    		 
    /**
     * Executes the "getReport" get request
     * Gets status code for possible error
     * Gets the response for the request
     */
    try {
   	 httpResponse2 = client.execute(getReport);
   	 int statusCode = httpResponse2.getStatusLine().getStatusCode();
   	 String result = IOUtils.toString(httpResponse2.getEntity().getContent(), StandardCharsets.UTF_8);
   	 replacedString = result.replace("/ibi_apps/", "http://" + hostname + ".ibi.com:8080/ibi_apps/");
    } catch (Exception ex) {
   	 System.out.println("HttpResponse2 Error: " + ex.getMessage());
    }

    /**
     * Sends the deferred report to the iFrame in deferred.jsp
     */
%>

<%=replacedString%>
