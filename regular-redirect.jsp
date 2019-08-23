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
    * Defines hostname, cookies[], client, which are pulled from logincheck.jsp to maintain the session
    * Defines reportName by pulling it from the form block in regular-report.jsp
    */
    String hostname = (String) session.getAttribute("hostname");
    Header[] cookies = (Header[]) session.getAttribute("cookies");
    CloseableHttpClient client = (CloseableHttpClient) session.getAttribute("client");
    String reportName = request.getParameter("x");
    
    /**
    * Defines reportURL to access the reports, using the hostname and reportName
    */
    String reportURL = "http://" + hostname + ".ibi.com:8080/ibi_apps/rs?IBIRS_path=WFC/Repository/Public/"
   		 + reportName + "&IBIRS_action=run&IBIRS_service=ibfs";
    
    /**
     * getReport is defined to send the get request using reportURL
     */
    HttpGet getReport = new HttpGet(reportURL);
    
    /**
     * For loop attaches the cookies to the get request
     */
    for (int h = 0; h < cookies.length; h++) {
   	 getReport.addHeader(cookies[h].getName(), cookies[h].getValue());
    }
    
    /**
     * Defines HttpResponse and replaceString outside the try block
     */
    HttpResponse httpResponse = null;
    String replacedString = "";
    
    /**
     * httpResponse is set to execute getReport
     * Gets status code for possible error message
     */
    try {
   	 httpResponse = client.execute(getReport);
   	 int statusCode = httpResponse.getStatusLine().getStatusCode();
   	 String result = IOUtils.toString(httpResponse.getEntity().getContent(), StandardCharsets.UTF_8);
   	 replacedString = result.replace("/ibi_apps/", "http://" + hostname + ".ibi.com:8080/ibi_apps/");
    } catch (Exception ex) {
   	 System.out.println("HttpResponse Error: " + ex.getMessage());
    }
    
    /**
     * Sends the report back to the iFrame
     */
%>

<%=replacedString%>

