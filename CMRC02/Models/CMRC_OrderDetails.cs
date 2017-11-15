using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace CMRC02.Models
{
    /// <summary>
    /// 订单明细
    /// </summary>
    public class CMRC_OrderDetails
    {
        /// <summary>
        /// 订单明细编号
        /// </summary>
        public int ODID { get; set; }
        /// <summary>
        /// 订单编号
        /// </summary>
        public int OrderID { get; set; }
        /// <summary>
        /// 产品编号
        /// </summary>
        public int ProductID { get; set; }
        /// <summary>
        /// 数量
        /// </summary>
        public int Quantity { get; set; }
        /// <summary>
        /// 单价
        /// </summary>
        public decimal UnitCost { get; set; }

        public void InsertDetailsByOrderID(int OrderID)
        {
            var cartlist = new CMRC_ShoppingCart().GetShoppingCartByCartID();

            foreach (var cart in cartlist)
            {
                SqlHelper.ExecuteNonQuery(SqlHelper.Constr,
                    "insert into CMRC_OrderDetails (OrderID,ProductID,Quantity,UnitCost)values(@OrderID,@ProductID,@Quantity,@UnitCost)",
                    CommandType.Text,
                    new SqlParameter("@OrderID", OrderID),
                    new SqlParameter("@ProductID", cart.ProductID),
                    new SqlParameter("@Quantity", cart.Quantity),
                    new SqlParameter("@UnitCost", cart.UnitCost)
                );
            }
        }

        public List<CartList> GetDetailsByOrderID(int OrderID)
        {
            string cmdstr = @"SELECT  CMRC_Products.ModelName, CMRC_Products.ModelNumber, CMRC_OrderDetails.Quantity, 
            CMRC_OrderDetails.UnitCost
                FROM      CMRC_OrderDetails INNER JOIN
                CMRC_Products ON CMRC_OrderDetails.ProductID = CMRC_Products.ProductID
            where orderid=@OrderID";
            SqlDataReader dr = SqlHelper.ExecuteReader(SqlHelper.Constr, cmdstr, CommandType.Text, new SqlParameter("@OrderID", OrderID));
            List<CartList> list = new List<CartList>();

            while (dr.Read())
            {
                list.Add(new CartList()
                {
                    ModelName = dr["ModelName"].ToString(),
                    ModelNumber = dr["ModelNumber"].ToString(),
                    Quantity = int.Parse(dr["Quantity"].ToString()),
                    UnitCost = decimal.Parse(dr["UnitCost"].ToString())
                });
            }

            return list;
        }

        public List<Popular> GetMostPopular()
        {
            SqlDataReader dr = SqlHelper.ExecuteReader(SqlHelper.Constr, "CMRC_ProductsMostPopular",
                CommandType.StoredProcedure);
            List<Popular> list=new List<Popular>();
            while (dr.Read())
            {
                list.Add(new Popular()
                {
                    ProductID = int.Parse(dr["ProductID"].ToString()),
                    TotalNum = int.Parse(dr["TotalNum"].ToString()),
                    ModelName = dr["ModelName"].ToString()
                });
            }
            return list;

        }


    }
}