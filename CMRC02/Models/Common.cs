using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;

namespace CMRC02.Models
{
    public class Common
    {
        public static string GetShoppingCartID()
        {
            HttpContext hc = HttpContext.Current;

            //获取登录身份
            if (!string.IsNullOrEmpty(hc.User.Identity.Name))
            {
                return hc.User.Identity.Name;
            }

            //获取临时身份
            if (hc.Request.Cookies["CMRC_SHOPPINGCARTID"] != null)
            {
                return hc.Request.Cookies["CMRC_SHOPPINGCARTID"].Value;
            }
            else {

                //创建新身份，并保存为临时身份
                Guid g = Guid.NewGuid();
                hc.Response.Cookies["CMRC_SHOPPINGCARTID"].Value = g.ToString();
                return g.ToString();
            }
        }

        public static string PICURL = ConfigurationManager.AppSettings["url"].ToString();

    }
}