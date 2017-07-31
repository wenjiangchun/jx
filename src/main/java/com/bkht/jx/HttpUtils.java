package com.bkht.jx;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;

import java.io.IOException;

public final class HttpUtils {
    public static String getString(String url) throws IOException {
        try (CloseableHttpClient httpclient = HttpClients.createDefault()) {
            HttpGet httpget = new HttpGet(url);
            ResponseHandler<String> responseHandler = new ResponseHandler<String>() {
                @Override
                public String handleResponse(
                        final HttpResponse response) throws IOException {
                    int status = response.getStatusLine().getStatusCode();
                    if (status >= 200 && status < 300) {
                        HttpEntity entity = response.getEntity();
                        return entity != null ? EntityUtils.toString(entity) : null;
                    } else {
                        throw new ClientProtocolException("Unexpected response status: " + status);
                    }
                }
            };
            return httpclient.execute(httpget, responseHandler);
        }
    }

    public static void main(String[] args) {
        try {
            String content = HttpUtils.getString("http://permit.mep.gov.cn/permitExt/outside/Publicity?pageno=3&enterName=&province=&city=&treadcode=&treadname=");
            //System.out.println(content);

            Document doc = Jsoup.connect("http://permit.mep.gov.cn/permitExt/outside/Publicity?pageno=3&enterName=&province=&city=&treadcode=&treadname=").get();
            Elements newsHeadlines = doc.getElementsByClass("page");
            String s = newsHeadlines.first().text();
            String totalPage = s.substring(1,4);
            System.out.println(totalPage);
            Elements elements = doc.select("div[class=tb-con]");
            Elements trs = elements.first().getElementsByTag("tr");
            trs.forEach(element -> {
                if (!element.hasClass("tbhead")) {
                    Elements tds = element.getElementsByTag("td");
                    tds.forEach(td -> {
                        if (td.hasClass("bgcolor1")) {
                            System.out.println("http://permit.mep.gov.cn/" + td.getElementsByTag("a").attr("href"));
                            /*try {
                                //System.out.println(Jsoup.connect("http://permit.mep.gov.cn/permitExt/syssb/wysb/hpsp/hpsp-company-sewage!getxxgkContent.action?dataid=ddcc1c16ff5846fdb60ba8aba73f888f").get().html());
                            } catch (IOException e) {
                                e.printStackTrace();
                            }*/
                        } else {
                            System.out.println(td.text());
                        }

                    });
                }
            });
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
