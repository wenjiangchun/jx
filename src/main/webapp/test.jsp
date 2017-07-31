<%@ page contentType="text/html; charset=utf-8"%>
<%
    response.setContentType("application/csv");
    response.setHeader("content-disposition","attachment; filename=test.csv"); // set the file name to whatever required..
    ServletOutputStream pt = null;
    try {
        pt = response.getOutputStream();
        pt.println("a,b,c,d,e,f");
        pt.println("1,2,3,4,5,6");
        pt.flush();
    } catch (Exception e) {

    } finally {
        if (pt != null) {
            pt.close();
        }
    }
    out.clear();
    out=pageContext.pushBody();
%>
