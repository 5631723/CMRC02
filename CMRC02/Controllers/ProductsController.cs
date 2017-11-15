using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using CMRC02.Models;

namespace CMRC02.Controllers
{
    public class ProductsController : Controller
    {
        CMRC_Products p = new CMRC_Products();
        //
        // GET: /Products/

        public ActionResult List(int CategoryID)
        {
            var data = p.GetAllByCid(CategoryID);
            ViewBag.list = data;

            if (data.Count == 0)
            {
                ViewBag.tips = "没有任何产品匹配您的关键字!";
            }

            return View();
        }

        public ActionResult Search(string Key)
        {
            var data = p.SearchResult(Key);
            ViewBag.list = data;

            if (data.Count == 0)
            {
                ViewBag.tips = "没有任何产品匹配您的关键字!";
            }

            return View("List");
        }

        public ActionResult Details(int? id)
        {
            //必须要传一个参数
            if (id.HasValue)
            {
                //获取产品详细
                var data = p.GetInfo(id.Value);
                ViewBag.info = data;

                //获取所有留言
                ViewBag.Reviews = new CMRC_Reviews().GetAllByProductID(id.Value);

                //不能乱写参数
                if (data == null)
                    return View("Error");

                return View();
            }
            else
            {
                //显示一个错误页面
                return View("Error");
            }
        }

    }
}
