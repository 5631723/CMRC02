using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.SqlClient;
using System.Data;

namespace CMRC02.Models
{
    /// <summary>
    /// 购物车
    /// </summary>
    public class CMRC_ShoppingCart
    {
        /// <summary>
        /// 记录编号
        /// </summary>
        public int RecordID { get; set; }
        /// <summary>
        /// 购物车编号
        /// </summary>
        public string CartID { get; set; }
        /// <summary>
        /// 数量
        /// </summary>
        public int Quantity { get; set; }
        /// <summary>
        /// 产品编号
        /// </summary>
        public int ProductID { get; set; }
        /// <summary>
        /// 添加时间
        /// </summary>
        public DateTime DateCreated { get; set; }

        /// <summary>
        /// 判断当前用户是否购买过此商品
        /// </summary>
        /// <param name="CartID"></param>
        /// <param name="ProductID"></param>
        /// <returns></returns>
        public bool Exist(string CartID, int ProductID)
        {
            int i = int.Parse(SqlHelper.ExecuteScalar(SqlHelper.Constr, "select count(*) from CMRC_ShoppingCart where CartID=@CartID and ProductID=@ProductID",
                System.Data.CommandType.Text,
                new SqlParameter("@CartID", CartID),
                new SqlParameter("@ProductID", ProductID)
                ).ToString());

            if (i > 0)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        /// <summary>
        /// 修改购物车商品数量
        /// </summary>
        /// <param name="CartID"></param>
        /// <param name="ProductID"></param>
        /// <param name="Quantity"></param>
        public void UpdateQuantity(string CartID, int ProductID, int Quantity)
        {
            SqlHelper.ExecuteNonQuery(SqlHelper.Constr, "update CMRC_ShoppingCart set Quantity=Quantity+@Quantity ,DateCreated=getdate()  where CartID=@CartID and ProductID=@ProductID", System.Data.CommandType.Text,
                new SqlParameter("@CartID", CartID),
                new SqlParameter("@Quantity", Quantity),
                 new SqlParameter("@ProductID", ProductID)
                );
        }

        /// <summary>
        /// 向购物车中添加商品
        /// </summary>
        /// <param name="CartID"></param>
        /// <param name="ProductID"></param>
        /// <param name="Quantity"></param>
        public void Insert(string CartID, int ProductID, int Quantity)
        {
            SqlHelper.ExecuteNonQuery(SqlHelper.Constr, "insert into CMRC_ShoppingCart (CartID,Quantity,ProductID)values(@CartID,@Quantity,@ProductID)", System.Data.CommandType.Text,
                new SqlParameter("@CartID", CartID),
                new SqlParameter("@Quantity", Quantity),
                 new SqlParameter("@ProductID", ProductID)
                );
        }

        public List<CartList> GetShoppingCartByCartID()
        {
            string CartID = Common.GetShoppingCartID();

            string cmdstr = "SELECT CMRC_ShoppingCart.RecordID, CMRC_ShoppingCart.ProductID, CMRC_Products.ModelName, CMRC_Products.ModelNumber, CMRC_Products.UnitCost, CMRC_ShoppingCart.Quantity FROM CMRC_Products INNER JOIN CMRC_ShoppingCart ON CMRC_Products.ProductID = CMRC_ShoppingCart.ProductID WHERE   (CMRC_ShoppingCart.CartID = @CartID) ORDER BY CMRC_ShoppingCart.DateCreated DESC";
            List<CartList> list = new List<CartList>();
            SqlDataReader dr=SqlHelper.ExecuteReader(SqlHelper.Constr, cmdstr, CommandType.Text,
                new SqlParameter("@CartID", CartID)
                );

            while (dr.Read())
            {
                list.Add(new CartList() {
                    ModelName = dr["ModelName"].ToString(),
                    ModelNumber = dr["ModelNumber"].ToString(),
                    ProductID=int.Parse(dr["ProductID"].ToString()),
                    Quantity = int.Parse(dr["Quantity"].ToString()),
                    RecordID = int.Parse(dr["RecordID"].ToString()),
                    UnitCost = decimal.Parse(dr["UnitCost"].ToString())
                });
            }
            return list;
        }

        public void RemoveCart(int RecordID)
        {
            SqlHelper.ExecuteNonQuery(SqlHelper.Constr, "delete from CMRC_ShoppingCart where RecordID=@RecordID", System.Data.CommandType.Text,
              new SqlParameter("@RecordID", RecordID)
              );
        }
        public void RemoveCart(string CartID)
        {
            SqlHelper.ExecuteNonQuery(SqlHelper.Constr, "delete from CMRC_ShoppingCart where CartID=@CartID", System.Data.CommandType.Text,
              new SqlParameter("@CartID", CartID)
              );
        }
        //合并购物车
        public void MergeCart(string NewCartID,string OldCartID)
        {
            SqlHelper.ExecuteNonQuery(SqlHelper.Constr,
                "update CMRC_ShoppingCart set CartID=@NewCartID where CartID=@OldCartID",
                CommandType.Text,
                new SqlParameter("@NewCartID", NewCartID),
                new SqlParameter("@OldCartID", OldCartID)
            );
        }

        public int GetCount()
        {
            try
            {
                int i = int.Parse(SqlHelper.ExecuteScalar(SqlHelper.Constr, "select sum(quantity) from CMRC_ShoppingCart where CartID=@CartID",
                    System.Data.CommandType.Text,
                    new SqlParameter("@CartID", Common.GetShoppingCartID())
                ).ToString());
                return i;
            }
            catch (Exception e)
            {
                return 0;
            }
        }

    }
}