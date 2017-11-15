using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using CMRC02_Admin.Models;

namespace CMRC02_Admin.Controllers
{
    public class CategoriesController : Controller
    {
        //
        // GET: /Categories/

        public ActionResult List()
        {
            return View();
        }

        public ActionResult GetAll()
        {
            List<string[]> list = new List<string[]>();

            foreach (var c in new Categories().GetAll())
            {
                list.Add(new string[]
                {
                    c.CategoryID.ToString(),
                    c.CategoryName,
                    c.CategoryID.ToString()
                });
            }

            return Json(new { data = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult Delete(int id)
        {
            try
            {
                new Categories().Delete(id);
                return Content("success");
            }
            catch (Exception e)
            {
                return Content(e.Message);
            }

        }

        public ActionResult AddModal()
        {
            return PartialView();
        }


        public ActionResult EditModal(string id)
        {
            ViewBag.CategoryName = id;
            return PartialView();

        }

        public ActionResult Add(CMRC_Categories c)
        {
            try
            {
                new Categories().Add(c);
                return Content("success");
            }
            catch (Exception e)
            {
                return Content(e.Message);
            }
        }

        public ActionResult Update(CMRC_Categories c)
        {
            try
            {
                new Categories().Update(c);
                return Content("success");
            }
            catch (Exception e)
            {
                return Content(e.Message);
            }
        }
    }
}
