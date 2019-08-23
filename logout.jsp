<%@ page
    import="java.util.*,
	org.apache.http.Header,
	org.apache.http.HttpResponse,
	org.apache.http.NameValuePair,
	org.apache.http.impl.client.CloseableHttpClient,
	org.apache.http.impl.client.HttpClients,
	org.apache.http.message.BasicNameValuePair"%>

<%
	/**
	 * Getting cookies to maintain the session
	 * Creating a client for the session use
	 *
	 * Cookies are set to null to delete them and the session is invalidated
	 * The user is then sent to the login page
	 */
	Header[] cookies = (Header[]) session.getAttribute("cookies");
	CloseableHttpClient client = (CloseableHttpClient) session.getAttribute("client");
    
	cookies = null;
	session.invalidate();
    
	response.sendRedirect("login.jsp");
%>
