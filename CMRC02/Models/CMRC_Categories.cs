using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;

namespace CMRC02.Models
{
    /// <summary>
    /// 产品分类
    /// </summary>
    public class CMRC_Categories
    {
        /// <summary>
        /// 产品分类编号
        /// </summary>
        public int CategoryID { get; set; }
        /// <summary>
        /// 产品分类名称
        /// </summary>
        public string CategoryName { get; set; }

        /// <summary>
        /// 获取所有分类
        /// </summary>
        /// <returns></returns>
        public List<CMRC_Categories> GetAll()
        {
            SqlDataReader dr = SqlHelper.ExecuteReader(SqlHelper.Constr, "select * from CMRC_Categories", CommandType.Text);
            List<CMRC_Categories> list = new List<CMRC_Categories>();
            while (dr.Read())
            {
                CMRC_Categories c = new CMRC_Categories()
                {
                    CategoryID = int.Parse(dr[0].ToString()),
                    CategoryName = dr[1].ToString()
                };
                list.Add(c);
            }
            return list;
        }

    }
  
}