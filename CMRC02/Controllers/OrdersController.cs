using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using CMRC02.Models;

namespace CMRC02.Controllers
{
    [Authorize]
    public class OrdersController : Controller
    {


        public ActionResult CreateOrder()
        {
            int OrderID = new CMRC_Orders().CreateOrder();

            new CMRC_OrderDetails().InsertDetailsByOrderID(OrderID);

            string CustomerID = Common.GetShoppingCartID();

            new CMRC_ShoppingCart().RemoveCart(CustomerID);

            return Json(new {OrderID = OrderID});
        }

        public ActionResult OrderList()
        {
            ViewBag.list=new CMRC_Orders().OrderList();
            return View();
        }



    }
}
