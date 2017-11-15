using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using CMRC02.Models;

namespace CMRC02.Controllers
{
    public class ReviewController : Controller
    {
        //
        // GET: /Review/

        public ActionResult ReviewAdd(int? id)
        {
            if (!id.HasValue)
            {
                return View("Error");
            }

            ViewBag.ProductID = id.Value;
            ViewBag.ModelName = new CMRC_Products().GetInfo(id.Value).ModelName;

            return View();
        }

        public ActionResult Add(CMRC_Reviews reviews)
        {
            new CMRC_Reviews().AddReviews(reviews);

            return RedirectToAction("Details", "Products", new { id = reviews.ProductID });
        }

    }
}
