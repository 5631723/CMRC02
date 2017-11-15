using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace CMRC02.Models
{
    /// <summary>
    /// 产品
    /// </summary>
    public class CMRC_Products
    {
        /// <summary>
        /// 产品编号
        /// </summary>
        public int ProductID { get; set; }
        /// <summary>
        /// 分类编号
        /// </summary>
        public int CategoryID { get; set; }
        /// <summary>
        /// 产品型号
        /// </summary>
        public string ModelNumber { get; set; }
        /// <summary>
        /// 产品名称
        /// </summary>
        public string ModelName { get; set; }
        /// <summary>
        /// 产品图片
        /// </summary>
        public string ProductImage { get; set; }
        /// <summary>
        /// 单价
        /// </summary>
        public decimal UnitCost { get; set; }
        /// <summary>
        /// 产品描述
        /// </summary>
        public string Description { get; set; }

        /// <summary>
        /// 根据分类编号查询所有产品
        /// </summary>
        /// <param name="cid"></param>
        /// <returns></returns>
        public List<CMRC_Products> GetAllByCid(int cid)
        {
            SqlDataReader dr=SqlHelper.ExecuteReader(SqlHelper.Constr, "select * from CMRC_Products where CategoryID=@cid",
                CommandType.Text, new SqlParameter("@cid", cid));
            List<CMRC_Products> list=new List<CMRC_Products>();
            while (dr.Read())
            {
                CMRC_Products p = new CMRC_Products()
                {
                    ProductID = int.Parse(dr[0].ToString()),
                    CategoryID = cid,
                    ModelNumber = dr[2].ToString(),
                    ModelName = dr[3].ToString(),
                    ProductImage = dr[4].ToString(),
                    UnitCost = decimal.Parse(dr[5].ToString()),
                    Description = dr[6].ToString()
                };
               list.Add(p);
            }
            return list;
        }

        /// <summary>
        /// 模糊查询产品（型号/描述/名称）
        /// </summary>
        /// <param name="Key"></param>
        /// <returns></returns>
        public List<CMRC_Products> SearchResult(string Key)
        {
            SqlDataReader dr = SqlHelper.ExecuteReader(SqlHelper.Constr,
                "select * from CMRC_Products where ModelName like @key or [Description] like @key or ModelNumber like @key",
                CommandType.Text,
                new SqlParameter("@key", "%" + Key + "%"));
            List<CMRC_Products> list = new List<CMRC_Products>();
            while (dr.Read())
            {
                CMRC_Products p = new CMRC_Products()
                {
                    ProductID = int.Parse(dr[0].ToString()),
                    CategoryID = int.Parse(dr[1].ToString()),
                    ModelNumber = dr[2].ToString(),
                    ModelName = dr[3].ToString(),
                    ProductImage = dr[4].ToString(),
                    UnitCost = decimal.Parse(dr[5].ToString()),
                    Description = dr[6].ToString()
                };
                list.Add(p);
            }
            return list;
        }

        /// <summary>
        /// 获取产品详细
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public CMRC_Products GetInfo(int id)
        {
            SqlDataReader dr = SqlHelper.ExecuteReader(SqlHelper.Constr,
                "select * from CMRC_Products where productid=@id",
                CommandType.Text
                , new SqlParameter("@id", id));

            if (dr.Read())
            {
                CMRC_Products p = new CMRC_Products()
                {
                    ProductID = int.Parse(dr[0].ToString()),
                    CategoryID = int.Parse(dr[1].ToString()),
                    ModelNumber = dr[2].ToString(),
                    ModelName = dr[3].ToString(),
                    ProductImage = dr[4].ToString(),
                    UnitCost = decimal.Parse(dr[5].ToString()),
                    Description = dr[6].ToString()
                };
                return p;
            }
            else
            {
                return null;
            }
        }
    }
}