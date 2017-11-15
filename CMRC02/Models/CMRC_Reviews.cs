using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace CMRC02.Models
{
    /// <summary>
    /// 留言评论
    /// </summary>
    public class CMRC_Reviews
    {
        /// <summary>
        /// 留言编号
        /// </summary>
        public int ReviewID { get; set; }
        /// <summary>
        /// 产品编号
        /// </summary>
        public int ProductID { get; set; }
        /// <summary>
        /// 客户姓名
        /// </summary>
        public string CustomerName { get; set; }
        /// <summary>
        /// 客户邮箱
        /// </summary>
        public string CustomerEmail { get; set; }
        /// <summary>
        /// 评分
        /// </summary>
        public int Rating { get; set; }
        /// <summary>
        /// 留言内容
        /// </summary>
        public string Comments { get; set; }

        /// <summary>
        /// 添加留言
        /// </summary>
        /// <param name="reviews"></param>
        public void AddReviews(CMRC_Reviews reviews)
        {
            SqlHelper.ExecuteNonQuery(SqlHelper.Constr,
                "insert into CMRC_Reviews (ProductID,CustomerName,CustomerEmail,Rating,Comments)values(@ProductID,@CustomerName,@CustomerEmail,@Rating,@Comments)",
                CommandType.Text,
                new SqlParameter("@ProductID", reviews.ProductID),
                new SqlParameter("@CustomerName", reviews.CustomerName),
                new SqlParameter("@CustomerEmail", reviews.CustomerEmail),
                new SqlParameter("@Rating", reviews.Rating),
                new SqlParameter("@Comments", reviews.Comments)
            );
        }

        public List<CMRC_Reviews> GetAllByProductID(int productid)
        {
            SqlDataReader dr = SqlHelper.ExecuteReader(SqlHelper.Constr, "select * from CMRC_Reviews where ProductID=@ProductID order by ReviewID desc", CommandType.Text,
                new SqlParameter("@ProductID", productid));
            List<CMRC_Reviews> list = new List<CMRC_Reviews>();
            while (dr.Read())
            {
                list.Add(new CMRC_Reviews()
                {
                    ReviewID = int.Parse(dr[0].ToString()),
                    ProductID = productid,
                    CustomerName = dr[2].ToString(),
                    CustomerEmail = dr[3].ToString(),
                    Rating = int.Parse(dr[4].ToString()),
                    Comments = dr[5].ToString()
                });
            }
            return list;
        }
    }
}