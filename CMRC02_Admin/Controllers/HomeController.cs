using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using CMRC02_Admin.Models;

namespace CMRC02_Admin.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        //
        // GET: /Home/

        public ActionResult Index()
        {
            return View();
        }

        [AllowAnonymous]
        public ActionResult Login()
        {
            return View();
        }

        [AllowAnonymous]
        public ActionResult CheckUser(string username, string password, bool? remember = false)
        {
            int id;

            if (new Admin().CheckUser(username, password, out id))
            {
                FormsAuthentication.SetAuthCookie(id.ToString(), remember.Value);
                return RedirectToAction("Index");
            }
            else
            {
                return RedirectToAction("Login", new { msg = "error" });
            }

        }

    }
}
