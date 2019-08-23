<%@ page
    import="java.util.*,
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
	org.apache.http.message.BasicNameValuePair,
	java.net.InetAddress,
	java.net.UnknownHostException"%>

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
    	response.sendRedirect("index.jsp");
	} catch (Exception ex) {
    	System.out.println("HttpResponse: "+ex.getMessage());
	}
%>
