using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CMRC02.Models
{
    public class CartList
    {
        public int RecordID { get; set; }
        public int ProductID { get; set; }
        public string ModelName { get; set; }
        public string ModelNumber { get; set; }
        public decimal UnitCost { get; set; }
        public int Quantity { get; set; }

    }
}