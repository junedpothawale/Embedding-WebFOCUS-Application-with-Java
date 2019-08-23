<%@ page import="java.util.*,
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
	org.apache.commons.io.IOUtils" %>

<%
	/**
	 * Defines hostname and sets it equal to attribute "hostname" from logincheck.jsp
	 * cookies are defined and filled with "cookies" pulled from logincheck.jsp
	 * client is defined and set equal to attribute "client" pulled from logincheck.jsp
	 * scheduleName is defined and pulled from the "x" parameter when a user selects a report to view in reportcaster.jsp
	 */
	String hostname = (String) session.getAttribute("hostname");
	Header[] cookies = (Header[]) session.getAttribute("cookies");
	CloseableHttpClient client = (CloseableHttpClient) session.getAttribute("client");
	String scheduleName = request.getParameter("x");
	String reportURL = "";

	/**
 	* Defines scheduleURL and sets it to a constructed url by using hostname and scheduleName
 	*/
	String scheduleURL = "http://" + hostname + ".ibi.com:8080/ibi_apps/rs/ibfs/WFC/Repository/Public/" + scheduleName + "?IBIRS_action=get";
	
	/**
 	*Defines getXML and sets it equal to get request using scheduleURL
 	*/
	HttpGet getXML = new HttpGet(scheduleURL);
	
	/**
 	* Creates a for loop to attach cookies to the getXML get request to access the reports
 	*/
	for (int h = 0; h < cookies.length; h++) {
    	getXML.addHeader(cookies[h].getName(), cookies[h].getValue());
	}
   
	HttpResponse httpResponse = null;
	
	/**
 	* Sets the newly defined httpResponse to execute the getXML response
 	*/
	try {
    	httpResponse = client.execute(getXML);
    	int statusCode = httpResponse.getStatusLine().getStatusCode();
	} catch (Exception ex) {
    	System.out.println("HttpResponse Error: " + ex.getMessage());
	}
 	
 	/**
  	* Gets the XML response and reads through it line by line
  	*/
	try {
    	InputStream rstream = httpResponse.getEntity().getContent();

    	BufferedReader br = new BufferedReader(new InputStreamReader(rstream));
    	String line;
    	String newOutput = "";
    	
    	/**
     	* While loop puts the lines into the newOutputString
     	*/
    	while ((line = br.readLine()) != null) {
        	newOutput = newOutput + line;
    	}
    	
    	/**
     	* newOutput is split up by spaces and saved to the stringArray array
     	* For loop is created to check for a line that has "procedureName" & ".fex" (this line will contain the report name)
     	* temp is set equal to the new complete URL
     	* The buffered reader is now closed
     	*/
    	String[] stringArray = newOutput.split("\\s+");
    	for (int i = 0; i < stringArray.length; i++) {
        	if (stringArray[i].contains("procedureName") && stringArray[i].contains(".fex")) {
            	String temp = stringArray[i].replace("procedureName=\"IBFS:/", "http://" + hostname + ".ibi.com:8080/ibi_apps/rs?IBIRS_path=");
            	reportURL = temp.replace("\"", "&IBIRS_action=run&IBIRS_service=ibfs");
        	}
    	}
    	br.close();
	} catch (Exception ex) {
    	System.out.println("RStream Error: " + ex.getMessage());
	}
    
	/**
 	* getReport is set equal to the getRequest
 	*/
	HttpGet getReport = new HttpGet(reportURL);
	
	/**
 	* For loop attaches the cookies to the get request
 	*/
	for (int h = 0; h < cookies.length; h++) {
    	getReport.addHeader(cookies[h].getName(), cookies[h].getValue());
	}

	HttpResponse httpResponse2 = null;
	String replacedString = "";
	
	/**
 	* The getReport request is executed 
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
 	* The proper report is sent to the iFrame on the ReportCaster page
 	*/
%>

<%= replacedString %>
