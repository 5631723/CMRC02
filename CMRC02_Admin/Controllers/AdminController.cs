using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using CMRC02_Admin.Models;

namespace CMRC02_Admin.Controllers
{
    public class AdminController : Controller
    {
        Admin admin=new Admin();
        //
        // GET: /Admin/

        public ActionResult Management()
        {
            return View();
        }
            
        public ActionResult GetAdmin()
        {
            var result = admin.GetAll();

            //创建满足DataTable插件的数据结构
            List<string[]> list=new List<string[]>();
            foreach (var item in result)
            {
                list.Add(new string[]
                {
                    item.Id.ToString(),
                    item.Username,
                    item.Password,
                    item.Sex.Value?"男":"女",
                    item.CreateDate.Value.ToShortDateString(),
                    item.Id.ToString()
                });
            }
            var data = new {data = list};

            //生成JSON格式，并返回到页面
            return Json(data, JsonRequestBehavior.AllowGet);
        }

        public ActionResult Delete(int id)
        {
            try
            {
                admin.Delete(id);
                return Content("success");
            }
            catch (Exception e)
            {
                return Content("error");
            }
        }

        public ActionResult Add(CMRC_Admin admin)
        {
            try
            {
                admin.CreateDate = DateTime.Now;
                this.admin.Add(admin);
                return Content("success");
            }
            catch (Exception e)
            {
                return Content("error");
            }
        }

        public ActionResult Update(CMRC_Admin a)
        {
            try
            {
                admin.Update(a);
                return Content("success");
            }
            catch (Exception e)
            {
                return Content("error");
            }

        }

    }
}
