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
	java.util.ArrayList,
	org.apache.http.Header,
	org.apache.http.HttpResponse,
	org.apache.http.NameValuePair,
	org.apache.http.client.*,
	org.apache.http.client.entity.UrlEncodedFormEntity,
	org.apache.http.client.methods.*,
	org.apache.http.impl.client.CloseableHttpClient,
	org.apache.http.impl.client.HttpClients,
	org.apache.http.message.BasicNameValuePair" %>

<%
    /**
    * String hostname is defined and set equal to attribute pulled from logincheck.jsp
    * Cookies are saved into an array, which are pulled from logincheck.jsp (session.getAttribute)
    * Client is pulled from logincheck.jsp (session.getAttribute)
    * getParameter x gets the specific schedule name that is being deleted
    */
	String hostname = (String) session.getAttribute("hostname");
	Header[] cookies = (Header[]) session.getAttribute("cookies");
	CloseableHttpClient client = (CloseableHttpClient) session.getAttribute("client");
	String scheduleName = request.getParameter("x");
	
	/**
 	* deleteURL is defined as a constructed url that uses the host name and the schedule name
 	*/
	String deleteURL = "http://" + hostname + ".ibi.com:8080/ibi_apps/rs/ibfs/WFC/Repository/Public/" + scheduleName;

	/**
 	* HTTP request is made to delete a particular schedule using the "deleteURL" made in the previous line
 	*/
	HttpDelete delete = new HttpDelete(deleteURL);
	
	/**
 	* For loop is made to delete all the cookies in the cookie array
 	*/
	for (int h = 0; h < cookies.length; h++) {
    	delete.addHeader(cookies[h].getName(), cookies[h].getValue());
    	System.out.println("delete cookies= " + cookies[h].getName() + ": " + cookies[h].getValue());
	}
	
	/**
 	* httpResponse is defined
 	* Try is made to execute a delete response
 	* Catch is there to catch an error if there was no schedule to delete
 	*/
	HttpResponse httpResponse = null;
	try {
    	httpResponse = client.execute(delete);
    	int statusCode = httpResponse.getStatusLine().getStatusCode();
	} catch (Exception ex) {
    	System.out.println("HttpResponse Error: " + ex.getMessage());
	}

	/**
 	* This redirect updates the reportcaster page after the delete is executed
 	*/
 	response.sendRedirect("reportcaster.jsp");
%>
