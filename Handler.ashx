<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Collections;
using System.Data;
using System.Text;
using System.Threading;
using System.Web;

public class Handler : IHttpHandler
{
    HttpContext context = null;
    private string postStr = "";
    public void ProcessRequest(HttpContext httpContext)
    {

        context = httpContext;
        // valid();//验证 用一次就行了
        if (context.Request.HttpMethod.ToLower() == "post")
        {
            System.IO.Stream inputStream = context.Request.InputStream;
            int strLen = Convert.ToInt32(inputStream.Length);
            byte[] strArr = new byte[strLen];
            inputStream.Read(strArr, 0, strLen);
            postStr = Encoding.UTF8.GetString(strArr);
            inputStream.Flush();
            inputStream.Close();
            inputStream.Dispose();
            if (!string.IsNullOrEmpty(postStr))
            {
                handleMsg(postStr);
                weixinHelper.WriteLog(postStr);
            }

        }
        else
        {
            context.Response.End();
        }
    }
    public void handleMsg(string str)
    {
        System.Xml.XmlDocument postObj = new System.Xml.XmlDocument();
        postObj.LoadXml(str);

        System.Xml.XmlNodeList toUsernameList = postObj.GetElementsByTagName("ToUserName");
        System.Xml.XmlNodeList FromUserNameList = postObj.GetElementsByTagName("FromUserName");
        //System.Xml.XmlNodeList CreateTimeList = postObj.GetElementsByTagName("CreateTime");
        System.Xml.XmlNodeList MsgTypeList = postObj.GetElementsByTagName("MsgType");

        string ToUserName = toUsernameList[0].ChildNodes[0].Value;
        string FromUserName = FromUserNameList[0].ChildNodes[0].Value;
        //string CreateTime = CreateTimeList[0].ChildNodes[0].Value;
        string MsgType = MsgTypeList[0].ChildNodes[0].Value;

        switch (MsgType.ToLower())
        {
            case "text":
                System.Xml.XmlNodeList ContentList = postObj.GetElementsByTagName("Content");
                string Content = ContentList[0].ChildNodes[0].Value;
                //文本处理
               sendMsg(ToUserName, FromUserName, Content);

               // sendNews(ToUserName, FromUserName);
                break;
            case "image":
                System.Xml.XmlNodeList PicUrlList = postObj.GetElementsByTagName("PicUrl");
                string PicUrl = PicUrlList[0].ChildNodes[0].Value;
                //图片处理
                break;
            case "location":

                System.Xml.XmlNodeList Location_XList = postObj.GetElementsByTagName("Location_X");
                System.Xml.XmlNodeList Location_YList = postObj.GetElementsByTagName("Location_Y");
                System.Xml.XmlNodeList ScaleList = postObj.GetElementsByTagName("Scale");
                System.Xml.XmlNodeList LabelList = postObj.GetElementsByTagName("Label");
                string Location_X = Location_XList[0].ChildNodes[0].Value;
                string Location_Y = Location_YList[0].ChildNodes[0].Value;
                string Scale = ScaleList[0].ChildNodes[0].Value;
                string Label = LabelList[0].ChildNodes[0].Value;
                //坐标处理
                break;
            case "link":
                System.Xml.XmlNodeList TitleList = postObj.GetElementsByTagName("Title");
                System.Xml.XmlNodeList DescriptionList = postObj.GetElementsByTagName("Description");
                System.Xml.XmlNodeList UrlList = postObj.GetElementsByTagName("Url");
                string Title = TitleList[0].ChildNodes[0].Value;
                string Description = DescriptionList[0].ChildNodes[0].Value;
                string Url = UrlList[0].ChildNodes[0].Value;
                //链接处理
                break;
            case "event":

                break;
        }


    }
    
    //发送文本
    //可扩展智能回复
    public void sendMsg(string ToUserName, string FromUserName, string content)
    {

        string replyContent = "";
        content = content.Replace("－", "-").Trim();
        weixinHelper.WriteLog(content);
        if (content.ToLower().Replace("－", "-") == "-h") //帮助信息可以扩展 -h vip 回复-vip hd:最新活动 -vip zk:最新折扣 -vip 商家名称:折扣信息
        {

            replyContent = "你可以发送:\r\n-vip 最新活动信息\r\n-tuan 查看最新团购\r\n-rc 查看最新职位\r\n-114 商家名称 查看商家信息";
        }
        else if (content.ToLower() == "-vip")
        {
            DataSet dataSet = weixinHelper.Ds("-vip", "", "vip");
            for (int i = 0; i < dataSet.Tables[0].Rows.Count; i++)
            {
                replyContent += dataSet.Tables[0].Rows[i]["info"] + "。\r\n";
            }


        }
        else if (content.ToLower().IndexOf("-114", System.StringComparison.Ordinal) != -1)
        {
            string key = content.Replace("-114", "").Trim();
            weixinHelper.WriteLog("key:" + key);
            if (key != "")
            {
                DataSet dataSet = weixinHelper.Ds("-114", key, "114");
                if (dataSet.Tables[0].Rows.Count == 0)
                {
                    replyContent = "没有查到" + key + "相关信息！";
                }
                else
                {
                    for (int i = 0; i < dataSet.Tables[0].Rows.Count; i++)
                    {
                        string str = jsb.StringUtil.NoHtml(dataSet.Tables[0].Rows[i]["jieshao"].ToString().Replace("性", "*").Replace("小姐", "*"));
                        replyContent += "店名:" + dataSet.Tables[0].Rows[i]["shopname"] + "\r\n" + (str.Length > 50 ? str.Substring(0, 50) : str) + "\r\n促销:" + (dataSet.Tables[0].Rows[i]["cx"] == DBNull.Value ? "暂无促销" : dataSet.Tables[0].Rows[i]["cx"]) + "\r\n电话:" + dataSet.Tables[0].Rows[i]["tel"] + "\r\n地址:" + dataSet.Tables[0].Rows[i]["address"] + "\r\n\r\n";

                    }

                }

            }
            else
            {
                replyContent = "请输入-114 商家名称\r\n如：-114 安阳信息网";
            }


        }
        else if (content.ToLower() == "-rc")
        {
            try
            {
                DataSet dataSet = weixinHelper.Ds("-rc", "", "rc");
                for (int i = 0; i < dataSet.Tables[0].Rows.Count; i++)
                {
                    replyContent += dataSet.Tables[0].Rows[i]["worksite"] + ":\r\n" + jsb.StringUtil.NoHtml(dataSet.Tables[0].Rows[i]["NeedDeal"].ToString()).Replace("性", "*").Replace("小姐", "*") + "....\r\n【工资】：" + dataSet.Tables[0].Rows[i]["gz"] + "\r\n【公司】：" + dataSet.Tables[0].Rows[i]["UserCoName"] + "\r\n\r\n";
                }
            }
            catch (Exception ex)
            {

                replyContent = ex.Message;

            }
        }
        else if (content.ToLower() == "-tuan")
        {

        }
        else
        {
            replyContent = "你好，发送-h可以查看更多功能";

        }

        replyContent = weixinHelper.returnMsg(replyContent, FromUserName, ToUserName);
        weixinHelper.WriteLog(replyContent);
        context.Response.Write(replyContent);
        context.Response.End();

    }

    //发送图文
    public void sendNews(string ToUserName, string FromUserName)
    {
        ArrayList Titles = new ArrayList();
        ArrayList Descriptions = new ArrayList();
        ArrayList PicUrls = new ArrayList();
        ArrayList Urls = new ArrayList();

        Titles.Add("title1");
        Titles.Add("title2");
        Descriptions.Add("baidu");
        Descriptions.Add("google");
        PicUrls.Add("http://www.baidu.com/img/shouye_b5486898c692066bd2cbaeda86d74448.gif");
        PicUrls.Add("http://www.google.com.hk/images/srpr/logo4w.png");
        Urls.Add("http://baidu.com");
        Urls.Add("http://google.com.hk");
        string replyContent = weixinHelper.returnImage(2, Titles, Descriptions, PicUrls, Urls, FromUserName, ToUserName);

        context.Response.Write(replyContent);
        context.Response.End();

    }



    public void valid()
    {
        string signature = context.Request.QueryString["signature"];
        string timestamp = context.Request.QueryString["timestamp"];
        string nonce = context.Request.QueryString["nonce"];
        string echostr = context.Request.QueryString["echostr"];
        const string token = "zcl1314520";
        string[] list = { token, timestamp, nonce };
        Array.Sort(list);
        string tmplist = string.Join("", list);
        string sha1List = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(tmplist, "SHA1");
        if (sha1List != null) sha1List = sha1List.ToLower();
        if (sha1List == signature)
        {
            context.Response.Write(echostr);
            context.Response.End();
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }



}
