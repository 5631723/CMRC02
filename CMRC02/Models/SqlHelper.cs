using System;
using System.Collections.Generic;

using System.Text;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace CMRC02.Models
{
    public class SqlHelper
    {
        /// <summary>
        /// 数据库连接语句
        /// </summary>
        public static string Constr = ConfigurationManager.ConnectionStrings["Constr"].ConnectionString;

        public static SqlDataReader ExecuteReader(string constr, string cmdstr, CommandType type, params SqlParameter[] ps)
        {
            SqlConnection conn = new SqlConnection(constr);
            conn.Open();
            SqlCommand cmd = new SqlCommand(cmdstr, conn);

            cmd.CommandType = type;

            if (ps.Length > 0)
            {
                cmd.Parameters.AddRange(ps);
            }

            SqlDataReader dr = cmd.ExecuteReader(CommandBehavior.CloseConnection);

            return dr;
        }


        public static int ExecuteNonQuery(string constr, string cmdstr, CommandType type, params SqlParameter[] ps)
        {
            SqlConnection conn = new SqlConnection(constr);
            conn.Open();
            SqlCommand cmd = new SqlCommand(cmdstr, conn);

            cmd.CommandType = type;

            if (ps.Length > 0)
            {
                cmd.Parameters.AddRange(ps);
            }

            int i = cmd.ExecuteNonQuery();
            conn.Close();
            return i;
        }


        public static DataSet ExecuteDataSet(string constr, string cmdstr, CommandType type, params SqlParameter[] ps)
        {
            SqlConnection conn = new SqlConnection(constr);

            SqlDataAdapter sda = new SqlDataAdapter(cmdstr, conn);

            sda.SelectCommand.CommandType = type;

            if (ps.Length > 0)
            {
                sda.SelectCommand.Parameters.AddRange(ps);
            }

            DataSet ds = new DataSet();

            sda.Fill(ds);
            conn.Close();
            return ds;
        }


        public static object ExecuteScalar(string constr, string cmdstr, CommandType type, params SqlParameter[] ps)
        {
            SqlConnection conn = new SqlConnection(constr);
            conn.Open();
            SqlCommand cmd = new SqlCommand(cmdstr, conn);

            cmd.CommandType = type;

            if (ps.Length > 0)
            {
                cmd.Parameters.AddRange(ps);
            }

            object o = cmd.ExecuteScalar();
            conn.Close();
            return o;
        }

    }
}
