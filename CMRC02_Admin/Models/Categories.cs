using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CMRC02_Admin.Models
{
    public class Categories
    {
        CMRCDataContext dc=new CMRCDataContext();
        public IEnumerable<CMRC_Categories> GetAll()
        {
            return dc.CMRC_Categories;
        }

        public void Delete(int id)
        {
            dc.CMRC_Categories.DeleteAllOnSubmit(dc.CMRC_Categories.Where(x => x.CategoryID == id));
            dc.SubmitChanges();
        }

        public void Add(CMRC_Categories c)
        {
            dc.CMRC_Categories.InsertOnSubmit(c);
            dc.SubmitChanges();
        }

        public void Update(CMRC_Categories category)
        {
            var result = from c in dc.CMRC_Categories
                         where c.CategoryID == category.CategoryID
                         select c;

            foreach (var c in result)
            {
                c.CategoryName = category.CategoryName;
            }

            dc.SubmitChanges();
        }
    }
}