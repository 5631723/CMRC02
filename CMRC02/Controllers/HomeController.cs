using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using CMRC02.Models;
using System.Web.Security;

namespace CMRC02.Controllers
{
    public class HomeController : Controller
    {
        //
        // GET: /Home/

        public ActionResult Index()
        {
            ViewBag.list = new CMRC_OrderDetails().GetMostPopular();
            return View();
        }

        public ActionResult Menu()
        {
            //获取所有的分类
            ViewBag.list = new CMRC_Categories().GetAll();

            return PartialView();
        }


        public ActionResult Demo()
        {

            return View();

        }

        public ActionResult Login()
        {

            return View();

        }

        public ActionResult CheckUser(string email, string password,string ReturnUrl, bool? RememberLogin = false)
        {

            //3.1 获取临时ID
            string CartID = Common.GetShoppingCartID();

            //3.2 定义一个变量用户保存用户身份
            string CustomerID;

            //1、判断是否登录成功
            if (new CMRC_Customers().CheckUser(email, password, out CustomerID))
            {
                //2、登录成功后，保存用户身份到验证Cookie
                FormsAuthentication.SetAuthCookie(CustomerID, RememberLogin.Value);

                //3.3 合并购物车
                new CMRC_ShoppingCart().MergeCart(CustomerID, CartID);

                if (ReturnUrl == null)
                {
                    return RedirectToAction("Index", "Home");
                }
                else
                {
                    return Redirect(ReturnUrl);
                }
            }
            else
            {
                return RedirectToAction("Login", new { msg = "登录失败" });
            }

            //     return Content(email + "|" + password + "|" + RememberLogin);
        }

        public ActionResult SignOut()
        {
            FormsAuthentication.SignOut();
            return RedirectToAction("Login", "Home");
        }

    }
}