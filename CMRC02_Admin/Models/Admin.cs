using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CMRC02_Admin.Models
{
    public class Admin
    {
        CMRCDataContext dc=new CMRCDataContext();
        /// <summary>
        /// 后台管理员登陆
        /// </summary>
        /// <param name="username">账户</param>
        /// <param name="password">密码</param>
        /// <param name="id">返回管理员编号</param>
        /// <returns></returns>
        public bool CheckUser(string username, string password, out int id)
        {
            var result = from admin in dc.CMRC_Admin
                where admin.Username == username && admin.Password == password
                select admin;

            if (result.Count() > 0)
            {
                id = result.First().Id;
                return true;
            }
            else
            {
                id = 0;
                return false;
            }
        }

        public IEnumerable<CMRC_Admin> GetAll()
        {
            var result = from admin in dc.CMRC_Admin
                         orderby admin.Id descending 
                select admin;

            return result;
        }

        public void Delete(int id)
        {
            dc.CMRC_Admin.DeleteOnSubmit(dc.CMRC_Admin.Where(x => x.Id == id).FirstOrDefault());
        }

        public void Add(CMRC_Admin admin)
        {
            dc.CMRC_Admin.InsertOnSubmit(admin);
            dc.SubmitChanges();
        }

        public void Update(CMRC_Admin admin)
        {
            var result = from a in dc.CMRC_Admin
                where a.Id == admin.Id
                select a;

            foreach (var item in result)
            {
                item.Username = admin.Username;
                item.Password = admin.Password;
                item.Sex = admin.Sex;
            }
            dc.SubmitChanges();
        }
    }
}