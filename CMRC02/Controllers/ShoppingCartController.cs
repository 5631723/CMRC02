using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using CMRC02.Models;

namespace CMRC02.Controllers
{
    public class ShoppingCartController : Controller
    {

        CMRC_ShoppingCart cart = new CMRC_ShoppingCart();
        //
        // GET: /ShoppingCart/

        public ActionResult List()
        {

            ViewBag.name = Common.GetShoppingCartID();

            ViewBag.list = cart.GetShoppingCartByCartID();

            return View();
        }

        //给参数添加默认值，不给数量，默认1个
        public ActionResult AddToCart(int? id, int? num = 1)
        {
            if (!id.HasValue)
                return RedirectToAction("List");

            //添加购物车的逻辑
            string cartid = Common.GetShoppingCartID();

            if (cart.Exist(cartid, id.Value))
            {
                cart.UpdateQuantity(cartid, id.Value, num.Value);
            }
            else
            {
                cart.Insert(cartid, id.Value, num.Value);
            }

            return RedirectToAction("List");

        }
        public ActionResult AddOne(int? id)
        {
            //添加购物车的逻辑
            string cartid = Common.GetShoppingCartID();

            if (cart.Exist(cartid, id.Value))
            {
                cart.UpdateQuantity(cartid, id.Value, 1);
            }
            else
            {
                cart.Insert(cartid, id.Value, 1);
            }

            return Json(new {result = "success"});

        }
        public ActionResult Remove(int id)
        {
            try
            {
                cart.RemoveCart(id);
                return Content("sucess");
            }
            catch (Exception)
            {

                return Content("error");
            }
        }

        public ActionResult UpdateNum(int id, int num)
        {
            try
            {
                new CMRC_ShoppingCart().UpdateQuantity(Common.GetShoppingCartID(), id, num);
                return Content("sucess");
            }
            catch (Exception)
            {
                return Content("error");
            }
        }


        //Authorize表示当前功能需要授权才能访问
        [Authorize]
        public ActionResult CheckOut()
        {
            ViewBag.list = cart.GetShoppingCartByCartID();
            return View();
        }

        public ActionResult GetCount()
        {
            return Json(new {count = new CMRC_ShoppingCart().GetCount()});
        }


    }
}
