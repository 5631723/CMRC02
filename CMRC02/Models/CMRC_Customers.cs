using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace CMRC02.Models
{
    /// <summary>
    /// 客户信息
    /// </summary>
    public class CMRC_Customers
    {

        /// <summary>
        /// 客户编号
        /// </summary>
        public int CustomerID { get; set; }
        /// <summary>
        /// 用户昵称
        /// </summary>
        public string FullName { get; set; }
        /// <summary>
        /// 邮箱账号
        /// </summary>
        public string EmailAddress { get; set; }
        /// <summary>
        /// 密码
        /// </summary>
        public string Password { get; set; }

        public bool CheckUser(string EmailAddress, string Password, out string CustomerID)
        {
            SqlDataReader dr=SqlHelper.ExecuteReader(SqlHelper.Constr,
                "select * from CMRC_Customers where EmailAddress=@EmailAddress and Password=@Password",
                CommandType.Text,
                new SqlParameter("@EmailAddress", EmailAddress),
                new SqlParameter("@Password", Password)
            );

            if (dr.Read())
            {
                CustomerID = dr[0].ToString();
                return true;
            }
            else
            {
                CustomerID = null;
                return false;
            }
        }

    }


}