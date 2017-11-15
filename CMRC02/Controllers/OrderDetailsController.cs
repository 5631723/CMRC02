using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using CMRC02.Models;

namespace CMRC02.Controllers
{
    public class OrderDetailsController : Controller
    {
        //
        // GET: /OrderDetails/

        public ActionResult OrderDetails(int id)
        {
            //订单详情
            ViewBag.info=new CMRC_Orders().GetOrderByID(id);
            

            //订单列表详情
            ViewBag.list = new CMRC_OrderDetails().GetDetailsByOrderID(id);

            return View();
        }

        

    }
}
