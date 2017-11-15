using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace CMRC02.Models
{
    /// <summary>
    /// 订单
    /// </summary>
    public class CMRC_Orders
    {
        /// <summary>
        /// 订单编号
        /// </summary>
        public int OrderID { get; set; }
        /// <summary>
        /// 客户编号
        /// </summary>
        public int CustomerID { get; set; }
        /// <summary>
        /// 订单生成日期
        /// </summary>
        public DateTime OrderDate { get; set; }
        /// <summary>
        /// 订单发货日期
        /// </summary>
        public DateTime ShipDate { get; set; }

        /// <summary>
        /// 创建订单，并返回订单编号
        /// </summary>
        /// <returns></returns>
        public int CreateOrder()
        {
            string customerid = Common.GetShoppingCartID();
            return int.Parse(SqlHelper.ExecuteScalar(SqlHelper.Constr,
                "insert into CMRC_Orders (CustomerID)values(@CustomerID);select @@identity",
                CommandType.Text,
                new SqlParameter("@CustomerID", customerid)).ToString());
        }

        /// <summary>
        /// 订单列表
        /// </summary>
        /// <returns></returns>
        public List<OrderList> OrderList()
        {
            string cmdstr = @"SELECT CMRC_Orders.OrderID,OrderDate,ShipDate, sum(Quantity*UnitCost) as SumTotal FROM CMRC_OrderDetails INNER JOIN CMRC_Orders ON CMRC_OrderDetails.OrderID = CMRC_Orders.OrderID where CustomerID=@CustomerID group by CMRC_Orders.OrderID,OrderDate,ShipDate order by OrderID desc";

            List<OrderList> list = new List<OrderList>();
            SqlDataReader dr = SqlHelper.ExecuteReader(SqlHelper.Constr, cmdstr, CommandType.Text,
                new SqlParameter("@CustomerID", Common.GetShoppingCartID())
            );
            while (dr.Read())
            {
                list.Add(new OrderList()
                {
                    OrderID = int.Parse(dr["OrderID"].ToString()),
                    OrderDate = DateTime.Parse(dr["OrderDate"].ToString()),
                    ShipDate = DateTime.Parse(dr["ShipDate"].ToString()),
                    SumTotal = decimal.Parse(dr["SumTotal"].ToString())
                });
            }
            return list;

        }
        public OrderList GetOrderByID(int OrderID)
        {
            string cmdstr = @"SELECT CMRC_Orders.OrderID,OrderDate,ShipDate, sum(Quantity*UnitCost) as SumTotal FROM CMRC_OrderDetails INNER JOIN CMRC_Orders ON CMRC_OrderDetails.OrderID = CMRC_Orders.OrderID where cmrc_orders.OrderID=@OrderID group by CMRC_Orders.OrderID,OrderDate,ShipDate order by OrderID desc";

            SqlDataReader dr = SqlHelper.ExecuteReader(SqlHelper.Constr, cmdstr, CommandType.Text,
                new SqlParameter("@OrderID", OrderID));

            dr.Read();
            return new OrderList()
            {
                OrderID = int.Parse(dr["OrderID"].ToString()),
                OrderDate = DateTime.Parse(dr["OrderDate"].ToString()),
                ShipDate = DateTime.Parse(dr["ShipDate"].ToString()),
                SumTotal = decimal.Parse(dr["SumTotal"].ToString())
            };



        }

    }
}