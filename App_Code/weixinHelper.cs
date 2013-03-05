using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Data.SqlClient;
/// <summary>
///weixinHelper 的摘要说明
/// </summary>

public class weixinHelper
{
    private const string rc = "Data Source=;Initial Catalog=;User ID=;pwd=;Connect Timeout=40;pooling=true;Max Pool Size=600";
    private const string vip = "Data Source=;Initial Catalog=;User ID=;pwd=;Connect Timeout=40;pooling=true;Max Pool Size=600";
    private static readonly string tuan = "";


    public static string ReturnConn(string str)
    {
        string conn = string.Empty;
        switch (str)
        {
            case "rc":
                conn = rc;
                break;
            case "vip":
                conn = vip;
                break;
            case "tuan":
                conn = tuan;
                break;
            case "114":
                conn = vip;
                break;
        }
        return conn;
    }
    public static string returnSql(string str, string key)
    {
        string sql = "";
        //if(key.Trim()=="")
        //{
        //     key = " 1=1 ";
        //}
        switch (str)
        {
            case "-vip"://默认 最新活动
                sql = "select top 10 info from indexvip_info where lbid='23' order by id desc";
                break;
            case "-rc"://默认 最新职位
                sql = "select top 10 worksite,left(NeedDeal,45) as NeedDeal,UserCoName,gz from [WorkSite] where ToDate>'" + DateTime.Now + "' and stop=0 order by PDate desc";
                break;
            case "-tuan"://默认 最新团购
                sql = "";
                break;
            case "-114"://
                sql = "select top 10 jieshao,address,tel,cx,shopname from shop where shopname like '%" + key + "%' and shenhe=1 order by id desc";
                break;
            //case "-vip":
            //    sql = "";
            //    break;
            //case "-vip":
            //    sql = "";
            //    break;
            //case "-vip":
            //    sql = "";
            //    break;
            //case "-vip":
            //    sql = "";
            //    break;
        }
        WriteLog("sql" + sql);
        return sql;
    }

    public static DataSet Ds(string sql, string key, string constr)
    {
        using (SqlConnection conn = new SqlConnection(ReturnConn(constr)))
        {
            SqlDataAdapter sqlData = new SqlDataAdapter(returnSql(sql, key), conn);
            DataSet dataSet = new DataSet();
            sqlData.Fill(dataSet);
            return dataSet;
        }

    }


    public static string returnMsg(string content, string FromUserName, string ToUserName)
    {

        return "<xml><ToUserName><![CDATA[" + FromUserName + "]]></ToUserName>" +
               "<FromUserName><![CDATA[" + ToUserName + "]]></FromUserName>" +
               "<CreateTime>" + ReturnCreateTime() + "</CreateTime><MsgType><![CDATA[text]]></MsgType>" +
               "<Content><![CDATA[" + content + "]]></Content><FuncFlag>0</FuncFlag></xml>";
    }

    public static string returnImage(int ArticleCount, ArrayList Titles, ArrayList Descriptions, ArrayList PicUrls, ArrayList Urls, string FromUserName, string ToUserName)
    {
        //ArticleCount 图文消息个数，限制为10条以内
        string news = "<xml>" +
                      "<ToUserName><![CDATA[" + FromUserName + "]]></ToUserName>" +
                      "<FromUserName><![CDATA[" + ToUserName + "]]></FromUserName>" +
                      "<CreateTime>" + ReturnCreateTime() + "</CreateTime>" +
                      "<MsgType><![CDATA[news]]></MsgType>" +
                      "<ArticleCount>" + ArticleCount + "</ArticleCount>" +
                      "<Articles>";
        int i = 0;
        string Articles = "";
        while (ArticleCount > 0)
        {
            Articles += "<item>" +
                        "<Title><![CDATA[" + Titles[i] + "]]></Title>" +
                        "<Description><![CDATA[" + Descriptions[i] + "]]></Description>" +
                        "<PicUrl><![CDATA[" + PicUrls[i] + "]]></PicUrl>" +
                        "<Url><![CDATA[" + Urls[i] + "]]></Url>" +
                        "</item>";
            ArticleCount--;
            i++;
        }

        news += Articles +
              "</Articles>" +
              "<FuncFlag>1</FuncFlag>" +
              "</xml>";
        WriteLog(news);
        return news;
    }


    public static int ReturnCreateTime()
    {
        DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1));
        return (int)(DateTime.Now - startTime).TotalSeconds;
    }
    public static void WriteLog(string strMemo)
    {
        string filename = "e:/0372web/qiche/log.txt";
        if (!System.IO.Directory.Exists("e:/0372web/qiche/"))
            System.IO.Directory.CreateDirectory("e:/0372web/qiche/");
        System.IO.StreamWriter sr = null;
        try
        {
            if (!System.IO.File.Exists(filename))
            {
                sr = System.IO.File.CreateText(filename);
            }
            else
            {
                sr = System.IO.File.AppendText(filename);
            }
            sr.WriteLine(strMemo);
        }
        catch
        {
        }
        finally
        {
            if (sr != null)
                sr.Close();
        }
    }

}

