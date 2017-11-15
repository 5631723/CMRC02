using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CMRC02.Models
{
    public class OrderList
    {
        public int OrderID { get; set; }
        public DateTime OrderDate { get; set; }
        public DateTime ShipDate { get; set; }
        public decimal SumTotal { get; set; }
    }
}