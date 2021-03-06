USE [master]
GO
/****** Object:  Database [Commerce]    Script Date: 2017/10/28 21:46:56 ******/
CREATE DATABASE [Commerce]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Commerce', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Commerce.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Commerce_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Commerce_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Commerce] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Commerce].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Commerce] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Commerce] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Commerce] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Commerce] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Commerce] SET ARITHABORT OFF 
GO
ALTER DATABASE [Commerce] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Commerce] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [Commerce] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Commerce] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Commerce] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Commerce] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Commerce] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Commerce] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Commerce] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Commerce] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Commerce] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Commerce] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Commerce] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Commerce] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Commerce] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Commerce] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Commerce] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Commerce] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Commerce] SET RECOVERY FULL 
GO
ALTER DATABASE [Commerce] SET  MULTI_USER 
GO
ALTER DATABASE [Commerce] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Commerce] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Commerce] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Commerce] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Commerce', N'ON'
GO
USE [Commerce]
GO
/****** Object:  StoredProcedure [dbo].[CMRC_CustomerAdd]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_CustomerAdd]
(
    @FullName   nvarchar(50),
    @Email      nvarchar(50),
    @Password   nvarchar(50),
    @CustomerID int OUTPUT
)
AS

INSERT INTO CMRC_Customers
(
    FullName,
    EmailAddress,
    Password
)

VALUES
(
    @FullName,
    @Email,
    @Password
)

SELECT
    @CustomerID = @@Identity



GO
/****** Object:  StoredProcedure [dbo].[CMRC_CustomerAlsoBought]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_CustomerAlsoBought]
(
    @ProductID int
)
As

/* We want to take the top 5 products contained in
    the orders where someone has purchased the given Product */
SELECT  TOP 5 
    CMRC_OrderDetails.ProductID,
    CMRC_Products.ModelName,
    SUM(CMRC_OrderDetails.Quantity) as TotalNum

FROM    
    CMRC_OrderDetails
  INNER JOIN CMRC_Products ON CMRC_OrderDetails.ProductID = CMRC_Products.ProductID

WHERE   OrderID IN 
(
    /* This inner query should retrieve all orders that have contained the productID */
    SELECT DISTINCT OrderID 
    FROM CMRC_OrderDetails
    WHERE ProductID = @ProductID
)
AND CMRC_OrderDetails.ProductID != @ProductID 

GROUP BY CMRC_OrderDetails.ProductID, CMRC_Products.ModelName 

ORDER BY TotalNum DESC



GO
/****** Object:  StoredProcedure [dbo].[CMRC_CustomerDetail]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_CustomerDetail]
(
    @CustomerID int,
    @FullName   nvarchar(50) OUTPUT,
    @Email      nvarchar(50) OUTPUT,
    @Password   nvarchar(50) OUTPUT
)
AS

SELECT 
    @FullName = FullName, 
    @Email    = EmailAddress, 
    @Password = Password

FROM 
    CMRC_Customers

WHERE 
    CustomerID = @CustomerID


GO
/****** Object:  StoredProcedure [dbo].[CMRC_CustomerLogin]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_CustomerLogin]
(
    @Email      nvarchar(50),
    @Password   nvarchar(50),
    @CustomerID int OUTPUT
)
AS

SELECT 
    @CustomerID = CustomerID
    
FROM 
    CMRC_Customers
    
WHERE 
    EmailAddress = @Email
  AND 
    Password = @Password

IF @@Rowcount < 1 
SELECT 
    @CustomerID = 0


GO
/****** Object:  StoredProcedure [dbo].[CMRC_OrdersAdd]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[CMRC_OrdersAdd]
(
    @CustomerID int,
    @CartID     nvarchar(50),
    @OrderDate  datetime,        
    @ShipDate   datetime,
    @OrderID    int OUTPUT
)
AS

BEGIN TRAN AddOrder

/* Create the Order header */
INSERT INTO CMRC_Orders
(
    CustomerID, 
    OrderDate, 
    ShipDate
)
VALUES
(   
    @CustomerID, 
    @OrderDate, 
    @ShipDate
)

SELECT
    @OrderID = @@Identity    

/* Copy items from given shopping cart to OrdersDetail table for given OrderID*/
INSERT INTO CMRC_OrderDetails
(
    OrderID, 
    ProductID, 
    Quantity, 
    UnitCost
)

SELECT 
    @OrderID, 
    CMRC_ShoppingCart.ProductID, 
    Quantity, 
    CMRC_Products.UnitCost

FROM 
    CMRC_ShoppingCart 
  INNER JOIN CMRC_Products ON CMRC_ShoppingCart.ProductID = CMRC_Products.ProductID
  
WHERE 
    CartID = @CartID

/* Removal of  items from user's shopping cart will happen on the business layer*/
EXEC CMRC_ShoppingCartEmpty @CartID

COMMIT TRAN AddOrder



GO
/****** Object:  StoredProcedure [dbo].[CMRC_OrdersDetail]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_OrdersDetail]
(
    @OrderID    int,
    @CustomerID int,
    @OrderDate  datetime OUTPUT,
    @ShipDate   datetime OUTPUT,
    @OrderTotal money OUTPUT
)
AS

/* Return the order dates from the Orders
    Also verifies the order exists for this customer. */
SELECT 
    @OrderDate = OrderDate,
    @ShipDate = ShipDate
    
FROM    
    CMRC_Orders
    
WHERE   
    OrderID = @OrderID
    AND
    CustomerID = @CustomerID

IF @@Rowcount = 1
BEGIN

/* First, return the OrderTotal out param */
SELECT  
    @OrderTotal = Cast(SUM(CMRC_OrderDetails.Quantity * CMRC_OrderDetails.UnitCost) as money)
    
FROM    
    CMRC_OrderDetails
    
WHERE   
    OrderID= @OrderID

/* Then, return the recordset of info */
SELECT  
    CMRC_Products.ProductID, 
    CMRC_Products.ModelName,
    CMRC_Products.ModelNumber,
    CMRC_OrderDetails.UnitCost,
    CMRC_OrderDetails.Quantity,
    (CMRC_OrderDetails.Quantity * CMRC_OrderDetails.UnitCost) as ExtendedAmount

FROM
    CMRC_OrderDetails
  INNER JOIN CMRC_Products ON CMRC_OrderDetails.ProductID = CMRC_Products.ProductID
  
WHERE   
    OrderID = @OrderID

END



GO
/****** Object:  StoredProcedure [dbo].[CMRC_OrdersList]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE Procedure [dbo].[CMRC_OrdersList]
(
    @CustomerID int
)
As

SELECT  
    CMRC_Orders.OrderID,
    Cast(sum(CMRC_OrderDetails.Quantity*CMRC_OrderDetails.UnitCost) as money) as OrderTotal,
    CMRC_Orders.OrderDate, 
    CMRC_Orders.ShipDate

FROM    
    CMRC_Orders 
  INNER JOIN CMRC_OrderDetails ON CMRC_Orders.OrderID = CMRC_OrderDetails.OrderID

GROUP BY    
    CustomerID, 
    CMRC_Orders.OrderID, 
    CMRC_Orders.OrderDate, 
    CMRC_Orders.ShipDate
HAVING  
    CMRC_Orders.CustomerID = @CustomerID



GO
/****** Object:  StoredProcedure [dbo].[CMRC_ProductCategoryList]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_ProductCategoryList]

AS

SELECT 
    CategoryID,
    CategoryName

FROM 
    CMRC_Categories

ORDER BY 
    CategoryName ASC



GO
/****** Object:  StoredProcedure [dbo].[CMRC_ProductDetail]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_ProductDetail]
(
    @ProductID    int,
    @ModelNumber  nvarchar(50) OUTPUT,
    @ModelName    nvarchar(50) OUTPUT,
    @ProductImage nvarchar(50) OUTPUT,
    @UnitCost     money OUTPUT,
    @Description  nvarchar(4000) OUTPUT
)
AS

SELECT 
    @ProductID    = ProductID,
    @ModelNumber  = ModelNumber,
    @ModelName    = ModelName,
    @ProductImage = ProductImage,
    @UnitCost     = UnitCost,
    @Description  = Description

FROM 
    CMRC_Products

WHERE 
    ProductID = @ProductID

GO
/****** Object:  StoredProcedure [dbo].[CMRC_ProductsByCategory]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_ProductsByCategory]
(
    @CategoryID int
)
AS

SELECT 
    ProductID,
    ModelName,
    UnitCost, 
    ProductImage

FROM 
    CMRC_Products

WHERE 
    CategoryID = @CategoryID

ORDER BY 
    ModelName, 
    ModelNumber



GO
/****** Object:  StoredProcedure [dbo].[CMRC_ProductSearch]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_ProductSearch]
(
    @Search nvarchar(255)
)
AS

SELECT 
    ProductID,
    ModelName,
    ModelNumber,
    UnitCost, 
    ProductImage

FROM 
    CMRC_Products

WHERE 
    ModelNumber LIKE '%' + @Search + '%' 
   OR
    ModelName LIKE '%' + @Search + '%'
   OR
    Description LIKE '%' + @Search + '%'


GO
/****** Object:  StoredProcedure [dbo].[CMRC_ProductsMostPopular]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_ProductsMostPopular]

AS

SELECT TOP 5 
    CMRC_OrderDetails.ProductID, 
    SUM(CMRC_OrderDetails.Quantity) as TotalNum, 
    CMRC_Products.ModelName
    
FROM    
    CMRC_OrderDetails
  INNER JOIN CMRC_Products ON CMRC_OrderDetails.ProductID = CMRC_Products.ProductID
  
GROUP BY 
    CMRC_OrderDetails.ProductID, 
    CMRC_Products.ModelName
    
ORDER BY 
    TotalNum DESC



GO
/****** Object:  StoredProcedure [dbo].[CMRC_ReviewsAdd]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE Procedure [dbo].[CMRC_ReviewsAdd]
(
    @ProductID     int,
    @CustomerName  nvarchar(50),
    @CustomerEmail nvarchar(50),
    @Rating        int,
    @Comments      nvarchar(3850),
    @ReviewID      int OUTPUT
)
AS

INSERT INTO CMRC_Reviews
(
    ProductID, 
    CustomerName, 
    CustomerEmail, 
    Rating, 
    Comments
)
VALUES
(
    @ProductID, 
    @CustomerName, 
    @CustomerEmail, 
    @Rating, 
    @Comments
)

SELECT 
    @ReviewID = @@Identity



GO
/****** Object:  StoredProcedure [dbo].[CMRC_ReviewsList]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE Procedure [dbo].[CMRC_ReviewsList]
(
    @ProductID int
)
AS

SELECT 
    ReviewID, 
    CustomerName, 
    Rating, 
    Comments
    
FROM 
    CMRC_Reviews
    
WHERE 
    ProductID = @ProductID



GO
/****** Object:  StoredProcedure [dbo].[CMRC_ShoppingCartAddItem]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_ShoppingCartAddItem]
(
    @CartID nvarchar(50),
    @ProductID int,
    @Quantity int
)
As

DECLARE @CountItems int

SELECT
    @CountItems = Count(ProductID)
FROM
    CMRC_ShoppingCart
WHERE
    ProductID = @ProductID
  AND
    CartID = @CartID

IF @CountItems > 0  /* There are items - update the current quantity */

    UPDATE
        CMRC_ShoppingCart
    SET
        Quantity = (@Quantity + CMRC_ShoppingCart.Quantity)
    WHERE
        ProductID = @ProductID
      AND
        CartID = @CartID

ELSE  /* New entry for this Cart.  Add a new record */

    INSERT INTO CMRC_ShoppingCart
    (
        CartID,
        Quantity,
        ProductID
    )
    VALUES
    (
        @CartID,
        @Quantity,
        @ProductID
    )



GO
/****** Object:  StoredProcedure [dbo].[CMRC_ShoppingCartEmpty]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_ShoppingCartEmpty]
(
    @CartID nvarchar(50)
)
AS

DELETE FROM CMRC_ShoppingCart

WHERE 
    CartID = @CartID


GO
/****** Object:  StoredProcedure [dbo].[CMRC_ShoppingCartItemCount]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_ShoppingCartItemCount]
(
    @CartID    nvarchar(50),
    @ItemCount int OUTPUT
)
AS

SELECT 
    @ItemCount = COUNT(ProductID)
    
FROM 
    CMRC_ShoppingCart
    
WHERE 
    CartID = @CartID


GO
/****** Object:  StoredProcedure [dbo].[CMRC_ShoppingCartList]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_ShoppingCartList]
(
    @CartID nvarchar(50)
)
AS

SELECT 
    CMRC_Products.ProductID, 
    CMRC_Products.ModelName,
    CMRC_Products.ModelNumber,
    CMRC_ShoppingCart.Quantity,
    CMRC_Products.UnitCost,
    Cast((CMRC_Products.UnitCost * CMRC_ShoppingCart.Quantity) as money) as ExtendedAmount

FROM 
    CMRC_Products,
    CMRC_ShoppingCart

WHERE 
    CMRC_Products.ProductID = CMRC_ShoppingCart.ProductID
  AND 
    CMRC_ShoppingCart.CartID = @CartID

ORDER BY 
    CMRC_Products.ModelName, 
    CMRC_Products.ModelNumber


GO
/****** Object:  StoredProcedure [dbo].[CMRC_ShoppingCartMigrate]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_ShoppingCartMigrate]
(
    @OriginalCartId nvarchar(50),
    @NewCartId      nvarchar(50)
)
AS

UPDATE 
    CMRC_ShoppingCart
    
SET 
    CartID = @NewCartId 
    
WHERE 
    CartID = @OriginalCartId


GO
/****** Object:  StoredProcedure [dbo].[CMRC_ShoppingCartRemoveAbandoned]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_ShoppingCartRemoveAbandoned]

AS

DELETE FROM CMRC_ShoppingCart

WHERE 
    DATEDIFF(dd, DateCreated, GetDate()) > 1



GO
/****** Object:  StoredProcedure [dbo].[CMRC_ShoppingCartRemoveItem]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_ShoppingCartRemoveItem]
(
    @CartID nvarchar(50),
    @ProductID int
)
AS

DELETE FROM CMRC_ShoppingCart

WHERE 
    CartID = @CartID
  AND
    ProductID = @ProductID



GO
/****** Object:  StoredProcedure [dbo].[CMRC_ShoppingCartTotal]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_ShoppingCartTotal]
(
    @CartID    nvarchar(50),
    @TotalCost money OUTPUT
)
AS

SELECT 
    @TotalCost = SUM(CMRC_Products.UnitCost * CMRC_ShoppingCart.Quantity)

FROM 
    CMRC_ShoppingCart,
    CMRC_Products

WHERE
    CMRC_ShoppingCart.CartID = @CartID
  AND
    CMRC_Products.ProductID = CMRC_ShoppingCart.ProductID


GO
/****** Object:  StoredProcedure [dbo].[CMRC_ShoppingCartUpdate]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CMRC_ShoppingCartUpdate]
(
    @CartID    nvarchar(50),
    @ProductID int,
    @Quantity  int
)
AS

UPDATE CMRC_ShoppingCart

SET 
    Quantity = @Quantity

WHERE 
    CartID = @CartID 
  AND 
    ProductID = @ProductID


GO
/****** Object:  Table [dbo].[CMRC_Admin]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMRC_Admin](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](max) NULL,
	[Password] [nvarchar](50) NULL,
	[Sex] [bit] NULL,
	[CreateDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMRC_Categories]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMRC_Categories](
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMRC_Customers]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMRC_Customers](
	[CustomerID] [int] IDENTITY(1,1) NOT NULL,
	[FullName] [nvarchar](50) NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[Password] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMRC_OrderDetails]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMRC_OrderDetails](
	[ODID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitCost] [money] NOT NULL,
 CONSTRAINT [PK_CMRC_OrderDetails_1] PRIMARY KEY CLUSTERED 
(
	[ODID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMRC_Orders]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMRC_Orders](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[ShipDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMRC_Products]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMRC_Products](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryID] [int] NOT NULL,
	[ModelNumber] [nvarchar](50) NULL,
	[ModelName] [nvarchar](50) NULL,
	[ProductImage] [nvarchar](50) NULL,
	[UnitCost] [money] NOT NULL,
	[Description] [nvarchar](3800) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMRC_Reviews]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMRC_Reviews](
	[ReviewID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[CustomerName] [nvarchar](50) NULL,
	[CustomerEmail] [nvarchar](50) NULL,
	[Rating] [int] NOT NULL,
	[Comments] [nvarchar](3850) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CMRC_ShoppingCart]    Script Date: 2017/10/28 21:46:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMRC_ShoppingCart](
	[RecordID] [int] IDENTITY(1,1) NOT NULL,
	[CartID] [nvarchar](50) NULL,
	[Quantity] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[CMRC_Admin] ON 

INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (11, N'admin', N'123', 0, CAST(0x0000A80B00F332FA AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (13, N'a', N'1', 0, CAST(0x0000A80B01094DC9 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (14, N'b', N'1', 0, CAST(0x0000A80B01094E4E AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (28, N'e', N'1', 0, CAST(0x0000A80B01095267 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (29, N'er', N'1', 0, CAST(0x0000A80B010952DC AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (30, N't', N'1', 0, CAST(0x0000A80B01095335 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (31, N'et', N'1', 0, CAST(0x0000A80B01095339 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (32, N'er', N'1', 0, CAST(0x0000A80B01095372 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (33, N'we', N'1', 0, CAST(0x0000A80B010953A8 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (35, N'ery', N'1', 0, CAST(0x0000A80B0109541F AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (36, N'ry', N'1', 0, CAST(0x0000A80B01095499 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (37, N'e', N'1', 0, CAST(0x0000A80B010954A0 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (38, N're', N'1', 0, CAST(0x0000A80B010954E5 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (39, N'wr', N'1', 0, CAST(0x0000A80B0109552B AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (40, N'wr', N'1', 0, CAST(0x0000A80B0109559C AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (41, N'w', N'1', 0, CAST(0x0000A80B010C4BAD AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (50, N'4324', N'1', 0, CAST(0x0000A80E00BB4C27 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (51, N'34', N'1', 0, CAST(0x0000A80E00BB4C8B AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (52, N'34', N'1', 0, CAST(0x0000A80E00BB4CD8 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (53, N'5', N'1', 0, CAST(0x0000A80E00BB4D1F AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (54, N'65', N'1', 0, CAST(0x0000A80E00BB4D5A AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (55, N'7', N'1', 0, CAST(0x0000A80E00BB4DA1 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (56, N'43', N'1', 0, CAST(0x0000A80E00BB4DD4 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (57, N'8', N'1', 0, CAST(0x0000A80E00BB4E04 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (58, N'5', N'1', 0, CAST(0x0000A80E00BB4E51 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (59, N'9', N'1', 0, CAST(0x0000A80E00BB4E78 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (60, N'6', N'1', 0, CAST(0x0000A80E00BB4ED6 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (61, N'54', N'1', 0, CAST(0x0000A80E00BB4EDB AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (62, N'7777', N'123456', 0, CAST(0x0000A80E00BB4EF9 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (63, N'8888', N'321', 0, CAST(0x0000A80E00BB500A AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (64, N'raoqi', N'123', 1, CAST(0x0000A80F00B6C540 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (65, N'test', N'123', 0, CAST(0x0000A80F00B8B37E AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (68, N'xiongxiong', N'123', 0, CAST(0x0000A80F00F7887B AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (69, N'huahua', N'123', 1, CAST(0x0000A80F00F7CE88 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (70, N'lili', N'321', 0, CAST(0x0000A81000B269A2 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (71, N'hanmeimei', N'123', 0, CAST(0x0000A81000B5AC17 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (72, N'huhu', N'123', 1, CAST(0x0000A81000E09A12 AS DateTime))
INSERT [dbo].[CMRC_Admin] ([Id], [Username], [Password], [Sex], [CreateDate]) VALUES (73, N'niuniu', N'123', 0, CAST(0x0000A81000E18CC8 AS DateTime))
SET IDENTITY_INSERT [dbo].[CMRC_Admin] OFF
SET IDENTITY_INSERT [dbo].[CMRC_Categories] ON 

INSERT [dbo].[CMRC_Categories] ([CategoryID], [CategoryName]) VALUES (14, N'Communications')
INSERT [dbo].[CMRC_Categories] ([CategoryID], [CategoryName]) VALUES (15, N'Deception')
INSERT [dbo].[CMRC_Categories] ([CategoryID], [CategoryName]) VALUES (16, N'Travel')
INSERT [dbo].[CMRC_Categories] ([CategoryID], [CategoryName]) VALUES (17, N'Protection')
INSERT [dbo].[CMRC_Categories] ([CategoryID], [CategoryName]) VALUES (18, N'Munitions')
INSERT [dbo].[CMRC_Categories] ([CategoryID], [CategoryName]) VALUES (19, N'Tools')
INSERT [dbo].[CMRC_Categories] ([CategoryID], [CategoryName]) VALUES (20, N'General')
INSERT [dbo].[CMRC_Categories] ([CategoryID], [CategoryName]) VALUES (56, N'seafood')
INSERT [dbo].[CMRC_Categories] ([CategoryID], [CategoryName]) VALUES (57, N'raoqi')
SET IDENTITY_INSERT [dbo].[CMRC_Categories] OFF
SET IDENTITY_INSERT [dbo].[CMRC_Customers] ON 

INSERT [dbo].[CMRC_Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (1, N'Raoqi', N'raoqi@163.com', N'123')
INSERT [dbo].[CMRC_Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (2, N'laoshi', N'laoshi@163.com', N'123')
INSERT [dbo].[CMRC_Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (3, N'Gordon Que', N'gq@ibuyspy.com', N'15-72-5B-0E-E7-A6-5E-A3-4A-BF-84-C8-58-93-18-FA')
INSERT [dbo].[CMRC_Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (20, N'hash test', N'hash@hash.com', N'5F-A2-85-E1-BE-BE-0A-66-23-E3-3A-FC-04-A1-FB-D5')
INSERT [dbo].[CMRC_Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (19, N'Guest Account', N'guest', N'D0-09-1A-0F-E2-B2-09-34-D8-8B-46-06-84-F5-97-89')
INSERT [dbo].[CMRC_Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (16, N'Test Account', N'd', N'2B-9D-4F-A8-5C-8E-82-13-2B-DE-46-B1-43-04-01-42')
SET IDENTITY_INSERT [dbo].[CMRC_Customers] OFF
SET IDENTITY_INSERT [dbo].[CMRC_OrderDetails] ON 

INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (1, 99, 404, 2, 459.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (2, 93, 363, 1, 1.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (3, 101, 378, 2, 14.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (4, 102, 372, 1, 129.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (5, 96, 378, 1, 14.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (6, 103, 363, 1, 1.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (7, 104, 355, 1, 1499.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (8, 104, 378, 1, 14.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (9, 104, 406, 1, 399.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (10, 100, 404, 2, 459.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (11, 101, 401, 1, 599.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (12, 102, 401, 1, 599.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (13, 104, 362, 1, 1.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (14, 104, 404, 1, 459.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (15, 105, 355, 2, 1499.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (16, 106, 401, 1, 599.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (17, 106, 404, 2, 459.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (18, 107, 368, 2, 19999.9800)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (19, 108, 378, 1, 14.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (20, 109, 374, 1, 999.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (21, 109, 385, 1, 13.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (22, 109, 360, 1, 49.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (23, 109, 404, 1, 459.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (24, 110, 377, 1, 6.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (25, 111, 374, 1, 999.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (26, 112, 367, 1, 1.4900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (27, 112, 385, 1, 13.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (28, 113, 360, 2, 49.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (29, 113, 376, 1, 9999.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (30, 113, 384, 1, 99.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (31, 114, 404, 1, 459.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (32, 115, 357, 2, 2.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (33, 115, 374, 1, 999.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (34, 115, 397, 1, 29.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (35, 116, 397, 1, 29.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (36, 117, 368, 1, 19999.9800)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (37, 117, 404, 1, 459.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (38, 118, 384, 1, 99.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (39, 118, 401, 1, 599.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (40, 119, 397, 1, 29.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (41, 120, 377, 1, 6.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (42, 121, 359, 1, 1299.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (43, 121, 360, 3, 49.9900)
INSERT [dbo].[CMRC_OrderDetails] ([ODID], [OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (44, 121, 397, 1, 29.9900)
SET IDENTITY_INSERT [dbo].[CMRC_OrderDetails] OFF
SET IDENTITY_INSERT [dbo].[CMRC_Orders] ON 

INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (99, 19, CAST(0x00008F670010C110 AS DateTime), CAST(0x00008F680010C110 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (93, 16, CAST(0x00008F640010C110 AS DateTime), CAST(0x00008F650010C110 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (101, 16, CAST(0x00008F6B0010C110 AS DateTime), CAST(0x00008F6C0010C110 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (103, 16, CAST(0x00008F6B0010C110 AS DateTime), CAST(0x00008F6B0010C110 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (96, 19, CAST(0x00008F640010C110 AS DateTime), CAST(0x00008F640010C110 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (104, 19, CAST(0x00008F6B0010C110 AS DateTime), CAST(0x00008F6C0010C110 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (105, 16, CAST(0x00008FDB0010C110 AS DateTime), CAST(0x00008FDC0010C110 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (106, 16, CAST(0x00008FDB0010C110 AS DateTime), CAST(0x00008FDB0010C110 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (107, 16, CAST(0x00008FDB0010C110 AS DateTime), CAST(0x00008FDC0010C110 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (100, 19, CAST(0x00008F670010C110 AS DateTime), CAST(0x00008F690010C110 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (102, 16, CAST(0x00008F6B0010C110 AS DateTime), CAST(0x00008F6D0010C110 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (108, 1, CAST(0x0000932A00BE1874 AS DateTime), CAST(0x0000932A00BE1874 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (109, 1, CAST(0x0000A80800BA810C AS DateTime), CAST(0x0000A80800BA810C AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (110, 1, CAST(0x0000A80800BBB20D AS DateTime), CAST(0x0000A80800BBB20D AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (111, 1, CAST(0x0000A80800BBC975 AS DateTime), CAST(0x0000A80800BBC975 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (113, 1, CAST(0x0000A80800FE59F3 AS DateTime), CAST(0x0000A80800FE59F3 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (115, 1, CAST(0x0000A80900C97D9F AS DateTime), CAST(0x0000A80900C97D9F AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (116, 1, CAST(0x0000A80900C9C589 AS DateTime), CAST(0x0000A80900C9C589 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (117, 1, CAST(0x0000A80900FDCA18 AS DateTime), CAST(0x0000A80900FDCA18 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (118, 1, CAST(0x0000A80900FE5A87 AS DateTime), CAST(0x0000A80900FE5A87 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (120, 1, CAST(0x0000A80901004C0D AS DateTime), CAST(0x0000A80901004C0D AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (121, 1, CAST(0x0000A80A00924A68 AS DateTime), CAST(0x0000A80A00924A68 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (112, 1, CAST(0x0000A80800BCE6F8 AS DateTime), CAST(0x0000A80800BCE6F8 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (114, 1, CAST(0x0000A80801104563 AS DateTime), CAST(0x0000A80801104563 AS DateTime))
INSERT [dbo].[CMRC_Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate]) VALUES (119, 1, CAST(0x0000A80900FEEB60 AS DateTime), CAST(0x0000A80900FEEB60 AS DateTime))
SET IDENTITY_INSERT [dbo].[CMRC_Orders] OFF
SET IDENTITY_INSERT [dbo].[CMRC_Products] ON 

INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (355, 16, N'RU007', N'Rain Racer 2000', N'image.gif', 1499.9900, N'Looks like an ordinary bumbershoot, but don''t be fooled! Simply place Rain Racer''s tip on the ground and press the release latch. Within seconds, this ordinary rain umbrella converts into a two-wheeled gas-powered mini-scooter. Goes from 0 to 60 in 7.5 seconds - even in a driving rain! Comes in black, blue, and candy-apple red.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (356, 20, N'STKY1', N'Edible Tape', N'image.gif', 3.9900, N'The latest in personal survival gear, the STKY1 looks like a roll of ordinary office tape, but can save your life in an emergency.  Just remove the tape roll and place in a kettle of boiling water with mixed vegetables and a ham shank. In just 90 minutes you have a great tasking soup that really sticks to your ribs! Herbs and spices not included.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (357, 16, N'P38', N'Escape Vehicle (Air)', N'image.gif', 2.9900, N'In a jam, need a quick escape? Just whip out a sheet of our patented P38 paper and, with a few quick folds, it converts into a lighter-than-air escape vehicle! Especially effective on windy days - no fuel required. Comes in several sizes including letter, legal, A10, and B52.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (358, 19, N'NOZ119', N'Extracting Tool', N'image.gif', 199.0000, N'High-tech miniaturized extracting tool. Excellent for extricating foreign objects from your person. Good for picking up really tiny stuff, too! Cleverly disguised as a pair of tweezers. ')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (359, 16, N'PT109', N'Escape Vehicle (Water)', N'image.gif', 1299.9900, N'Camouflaged as stylish wing tips, these ''shoes'' get you out of a jam on the high seas instantly. Exposed to water, the pair transforms into speedy miniature inflatable rafts. Complete with 76 HP outboard motor, these hip heels will whisk you to safety even in the roughest of seas. Warning: Not recommended for beachwear.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (360, 14, N'RED1', N'Communications Device', N'3.jpg', 49.9900, N'Subversively stay in touch with this miniaturized wireless communications device. Speak into the pointy end and listen with the other end! Voice-activated dialing makes calling for backup a breeze. Excellent for undercover work at schools, rest homes, and most corporate headquarters. Comes in assorted colors.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (362, 14, N'LK4TLNT', N'Persuasive Pencil', N'image.gif', 1.9900, N'Persuade anyone to see your point of view!  Captivate your friends and enemies alike!  Draw the crime-scene or map out the chain of events.  All you need is several years of training or copious amounts of natural talent. You''re halfway there with the Persuasive Pencil. Purchase this item with the Retro Pocket Protector Rocket Pack for optimum disguise.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (363, 18, N'NTMBS1', N'Multi-Purpose Rubber Band', N'image.gif', 1.9900, N'One of our most popular items!  A band of rubber that stretches  20 times the original size. Uses include silent one-to-one communication across a crowded room, holding together a pack of Persuasive Pencils, and powering lightweight aircraft. Beware, stretching past 20 feet results in a painful snap and a rubber strip.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (364, 19, N'NE1RPR', N'Universal Repair System', N'image.gif', 4.9900, N'Few people appreciate the awesome repair possibilities contained in a single roll of duct tape. In fact, some houses in the Midwest are made entirely out of the miracle material contained in every roll! Can be safely used to repair cars, computers, people, dams, and a host of other items.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (365, 19, N'BRTLGT1', N'Effective Flashlight', N'image.gif', 9.9900, N'The most powerful darkness-removal device offered to creatures of this world.  Rather than amplifying existing/secondary light, this handy product actually REMOVES darkness allowing you to see with your own eyes.  Must-have for nighttime operations. An affordable alternative to the Night Vision Goggles.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (367, 18, N'INCPPRCLP', N'The Incredible Versatile Paperclip', N'image.gif', 1.4900, N'This 0. 01 oz piece of metal is the most versatile item in any respectable spy''s toolbox and will come in handy in all sorts of situations. Serves as a wily lock pick, aerodynamic projectile (used in conjunction with Multi-Purpose Rubber Band), or escape-proof finger cuffs.  Best of all, small size and pliability means it fits anywhere undetected.  Order several today!')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (368, 16, N'DNTRPR', N'Toaster Boat', N'image.gif', 19999.9800, N'Turn breakfast into a high-speed chase! In addition to toasting bagels and breakfast pastries, this inconspicuous toaster turns into a speedboat at the touch of a button. Boasting top speeds of 60 knots and an ultra-quiet motor, this valuable item will get you where you need to be ... fast! Best of all, Toaster Boat is easily repaired using a Versatile Paperclip or a standard butter knife. Manufacturer''s Warning: Do not submerge electrical items.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (370, 17, N'TGFDA', N'Multi-Purpose Towelette', N'image.gif', 12.9900, N'Don''t leave home without your monogrammed towelette! Made from lightweight, quick-dry fabric, this piece of equipment has more uses in a spy''s day than a Swiss Army knife. The perfect all-around tool while undercover in the locker room: serves as towel, shield, disguise, sled, defensive weapon, whip and emergency food source. Handy bail gear for the Toaster Boat. Monogram included with purchase price.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (371, 18, N'WOWPEN', N'Mighty Mighty Pen', N'image.gif', 129.9900, N'Some spies claim this item is more powerful than a sword. After examining the titanium frame, built-in blowtorch, and Nerf dart-launcher, we tend to agree! ')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (372, 20, N'ICNCU', N'Perfect-Vision Glasses', N'image.gif', 129.9900, N'Avoid painful and potentially devastating laser eye surgery and contact lenses. Cheaper and more effective than a visit to the optometrist, these Perfect-Vision Glasses simply slide over nose and eyes and hook on ears. Suddenly you have 20/20 vision! Glasses also function as HUD (Heads Up Display) for most European sports cars manufactured after 1992.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (373, 17, N'LKARCKT', N'Pocket Protector Rocket Pack', N'image.gif', 1.9900, N'Any debonair spy knows that this accoutrement is coming back in style. Flawlessly protects the pockets of your short-sleeved oxford from unsightly ink and pencil marks. But there''s more! Strap it on your back and it doubles as a rocket pack. Provides enough turbo-thrust for a 250-pound spy or a passel of small children. Maximum travel radius: 3000 miles.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (374, 15, N'DNTGCGHT', N'Counterfeit Creation Wallet', N'image.gif', 999.9900, N'Don''t be caught penniless in Prague without this hot item! Instantly creates replicas of most common currencies! Simply place rocks and water in the wallet, close, open up again, and remove your legal tender!')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (375, 16, N'WRLD00', N'Global Navigational System', N'image.gif', 29.9900, N'No spy should be without one of these premium devices. Determine your exact location with a quick flick of the finger. Calculate destination points by spinning, closing your eyes, and stopping it with your index finger.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (376, 15, N'CITSME9', N'Cloaking Device', N'image.gif', 9999.9900, N'Worried about detection on your covert mission? Confuse mission-threatening forces with this cloaking device. Powerful new features include string-activated pre-programmed phrases such as "Danger! Danger!", "Reach for the sky!", and other anti-enemy expressions. Hyper-reactive karate chop action deters even the most persistent villain.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (377, 15, N'BME007', N'Identity Confusion Device', N'image.gif', 6.9900, N'Never leave on an undercover mission without our Identity Confusion Device! If a threatening person approaches, deploy the device and point toward the oncoming individual. The subject will fail to recognize you and let you pass unnoticed. Also works well on dogs.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (379, 17, N'SHADE01', N'Ultra Violet Attack Defender', N'image.gif', 89.9900, N'Be safe and suave. A spy wearing this trendy article of clothing is safe from ultraviolet ray-gun attacks. Worn correctly, the Defender deflects rays from ultraviolet weapons back to the instigator. As a bonus, also offers protection against harmful solar ultraviolet rays, equivalent to SPF 50.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (378, 17, N'SQUKY1', N'Guard Dog Pacifier', N'image.gif', 14.9900, N'Pesky guard dogs become a spy''s best friend with the Guard Dog Pacifier. Even the most ferocious dogs suddenly act like cuddly kittens when they see this prop.  Simply hold the device in front of any threatening dogs, shaking it mildly.  For tougher canines, a quick squeeze emits an irresistible squeak that never fails to  place the dog under your control.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (382, 20, N'CHEW99', N'Survival Bar', N'image.gif', 6.9900, N'Survive for up to four days in confinement with this handy item. Disguised as a common eraser, it''s really a high-calorie food bar. Stranded in hostile territory without hope of nourishment? Simply break off a small piece of the eraser and chew vigorously for at least twenty minutes. Developed by the same folks who created freeze-dried ice cream, powdered drink mix, and glow-in-the-dark shoelaces.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (402, 20, N'C00LCMB1', N'Telescoping Comb', N'image.gif', 399.9900, N'Use the Telescoping Comb to track down anyone, anywhere! Deceptively simple, this is no normal comb. Flip the hidden switch and two telescoping lenses project forward creating a surprisingly powerful set of binoculars (50X). Night-vision add-on is available for midnight hour operations.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (384, 19, N'FF007', N'Eavesdrop Detector', N'image.gif', 99.9900, N'Worried that counteragents have placed listening devices in your home or office? No problem! Use our bug-sweeping wiener to check your surroundings for unwanted surveillance devices. Just wave the frankfurter around the room ... when bugs are detected, this "foot-long" beeps! Comes complete with bun, relish, mustard, and headphones for privacy.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (385, 16, N'LNGWADN', N'Escape Cord', N'image.gif', 13.9900, N'Any agent assigned to mountain terrain should carry this ordinary-looking extension cord ... except that it''s really a rappelling rope! Pull quickly on each end to convert the electrical cord into a rope capable of safely supporting up to two agents. Comes in various sizes including Mt McKinley, Everest, and Kilimanjaro. WARNING: To prevent serious injury, be sure to disconnect from wall socket before use.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (386, 17, N'1MOR4ME', N'Cocktail Party Pal', N'image.gif', 69.9900, N'Do your assignments have you flitting from one high society party to the next? Worried about keeping your wits about you as you mingle witih the champagne-and-caviar crowd? No matter how many drinks you''re offered, you can safely operate even the most complicated heavy machinery as long as you use our model 1MOR4ME alcohol-neutralizing coaster. Simply place the beverage glass on the patented circle to eliminate any trace of alcohol in the drink.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (387, 20, N'SQRTME1', N'Remote Foliage Feeder', N'image.gif', 9.9900, N'Even spies need to care for their office plants.  With this handy remote watering device, you can water your flowers as a spy should, from the comfort of your chair.  Water your plants from up to 50 feet away.  Comes with an optional aiming system that can be mounted to the top for improved accuracy.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (388, 20, N'ICUCLRLY00', N'Contact Lenses', N'image.GIF', 59.9900, N'Traditional binoculars and night goggles can be bulky, especially for assignments in confined areas. The problem is solved with these patent-pending contact lenses, which give excellent visibility up to 100 miles. New feature: now with a night vision feature that permits you to see in complete darkness! Contacts now come in a variety of fashionable colors for coordinating with your favorite ensembles.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (389, 20, N'OPNURMIND', N'Telekinesis Spoon', N'image.gif', 2.9900, N'Learn to move things with your mind! Broaden your mental powers using this training device to hone telekinesis skills. Simply look at the device, concentrate, and repeat "There is no spoon" over and over.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (390, 19, N'ULOST007', N'Rubber Stamp Beacon', N'image.gif', 129.9900, N'With the Rubber Stamp Beacon, you''ll never get lost on your missions again. As you proceed through complicated terrain, stamp a stationary object with this device. Once an object has been stamped, the stamp''s patented ink will emit a signal that can be detected up to 153.2 miles away by the receiver embedded in the device''s case. WARNING: Do not expose ink to water.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (391, 17, N'BSUR2DUC', N'Bullet Proof Facial Tissue', N'image.gif', 79.9900, N'Being a spy can be dangerous work. Our patented Bulletproof Facial Tissue gives a spy confidence that any bullets in the vicinity risk-free. Unlike traditional bulletproof devices, these lightweight tissues have amazingly high tensile strength. To protect the upper body, simply place a tissue in your shirt pocket. To protect the lower body, place a tissue in your pants pocket. If you do not have any pockets, be sure to check out our Bulletproof Tape. 100 tissues per box. WARNING: Bullet must not be moving for device to successfully stop penetration.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (393, 20, N'NOBOOBOO4U', N'Speed Bandages', N'image.GIF', 3.9900, N'Even spies make mistakes.  Barbed wire and guard dogs pose a threat of injury for the active spy.  Use our special bandages on cuts and bruises to rapidly heal the injury.  Depending on the severity of the wound, the bandages can take between 10 to 30 minutes to completely heal the injury.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (394, 15, N'BHONST93', N'Correction Fluid', N'image.gif', 1.9900, N'Disguised as typewriter correction fluid, this scientific truth serum forces subjects to correct anything not perfectly true. Simply place a drop of the special correction fluid on the tip of the subject''s nose. Within seconds, the suspect will automatically correct every lie. Effects from Correction Fluid last approximately 30 minutes per drop. WARNING: Discontinue use if skin appears irritated.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (396, 19, N'BPRECISE00', N'Dilemma Resolution Device', N'image.gif', 11.9900, N'Facing a brick wall? Stopped short at a long, sheer cliff wall?  Carry our handy lightweight calculator for just these emergencies. Quickly enter in your dilemma and the calculator spews out the best solutions to the problem.   Manufacturer Warning: Use at own risk. Suggestions may lead to adverse outcomes.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (397, 14, N'LSRPTR1', N'Nonexplosive Cigar', N'image.gif', 29.9900, N'Contrary to popular spy lore, not all cigars owned by spies explode! Best used during mission briefings, our Nonexplosive Cigar is really a cleverly-disguised, top-of-the-line, precision laser pointer. Make your next presentation a hit.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (399, 20, N'QLT2112', N'Document Transportation System', N'image.gif', 299.9900, N'Keep your stolen Top Secret documents in a place they''ll never think to look!  This patent leather briefcase has multiple pockets to keep documents organized.  Top quality craftsmanship to last a lifetime.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (400, 15, N'THNKDKE1', N'Hologram Cufflinks', N'image.gif', 799.9900, N'Just point, and a turn of the wrist will project a hologram of you up to 100 yards away. Sneaking past guards will be child''s play when you''ve sent them on a wild goose chase. Note: Hologram adds ten pounds to your appearance.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (401, 14, N'TCKLR1', N'Fake Moustache Translator', N'image.gif', 599.9900, N'Fake Moustache Translator attaches between nose and mouth to double as a language translator and identity concealer. Sophisticated electronics translate your voice into the desired language. Wriggle your nose to toggle between Spanish, English, French, and Arabic. Excellent on diplomatic missions.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (404, 14, N'JWLTRANS6', N'Interpreter Earrings', N'image.gif', 459.9900, N'The simple elegance of our stylish monosex earrings accents any wardrobe, but their clean lines mask the sophisticated technology within. Twist the lower half to engage a translator function that intercepts spoken words in any language and converts them to the wearer''s native tongue. Warning: do not use in conjunction with our Fake Moustache Translator product, as the resulting feedback loop makes any language sound like Pig Latin.')
INSERT [dbo].[CMRC_Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (406, 19, N'GRTWTCH9', N'Multi-Purpose Watch', N'image.gif', 399.9900, N'In the tradition of famous spy movies, the Multi Purpose Watch comes with every convenience! Installed with lighter, TV, camera, schedule-organizing software, MP3 player, water purifier, spotlight, and tire pump. Special feature: Displays current date and time. Kitchen sink add-on will be available in the fall of 2001.')
SET IDENTITY_INSERT [dbo].[CMRC_Products] OFF
SET IDENTITY_INSERT [dbo].[CMRC_Reviews] ON 

INSERT [dbo].[CMRC_Reviews] ([ReviewID], [ProductID], [CustomerName], [CustomerEmail], [Rating], [Comments]) VALUES (21, 404, N'Sarah Goodpenny', N'sg@ibuyspy.com', 5, N'Really smashing! &nbsp;Don''t know how I''d get by without them!')
INSERT [dbo].[CMRC_Reviews] ([ReviewID], [ProductID], [CustomerName], [CustomerEmail], [Rating], [Comments]) VALUES (22, 378, N'James Bondwell', N'jb@ibuyspy.com', 3, N'Well made, but only moderately effective. &nbsp;Ouch!')
INSERT [dbo].[CMRC_Reviews] ([ReviewID], [ProductID], [CustomerName], [CustomerEmail], [Rating], [Comments]) VALUES (23, 360, N'小付', N'xiaofu@qq.com', 3, N'我来测试一下')
SET IDENTITY_INSERT [dbo].[CMRC_Reviews] OFF
SET IDENTITY_INSERT [dbo].[CMRC_ShoppingCart] ON 

INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (1, N'22', 1, 372, CAST(0x0000A80700A73C1B AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (45, N'2', 1, 401, CAST(0x0000A80900991F4A AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (48, N'2', 1, 360, CAST(0x0000A80900BB6119 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (4, N'c3583586-8878-409f-b084-e1c717531128', 3, 359, CAST(0x0000A80700AEE760 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (8, N'5a17d33c-cdc4-437d-9676-60a987bd2a3a', 1, 360, CAST(0x0000A80700C1A557 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (16, N'527e68e5-3dbc-45c7-b3a0-513d14daeb0d', 1, 377, CAST(0x0000A807010BB533 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (17, N'5469aae8-0f14-4cd8-b643-7072b3488081', 1, 371, CAST(0x0000A80701103900 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (54, N'4e653c7c-3e75-494f-97e7-5916eace716e', 1, 376, CAST(0x0000A80900F49DBC AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (31, N'9ca27969-09bf-4b6e-ac34-0e27bfe12063', 1, 367, CAST(0x0000A80800E51E48 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (32, N'9ca27969-09bf-4b6e-ac34-0e27bfe12063', 1, 396, CAST(0x0000A80800E521A5 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (33, N'906afd31-5bfc-438c-9985-67376d86b8b1', 1, 397, CAST(0x0000A80800E9FCE3 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (34, N'906afd31-5bfc-438c-9985-67376d86b8b1', 1, 378, CAST(0x0000A80800E9FFD2 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (37, N'906afd31-5bfc-438c-9985-67376d86b8b1', 1, 372, CAST(0x0000A80800EA0827 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (58, N'7b7e61ab-2ddd-44ed-921c-6aba18da3a72', 1, 362, CAST(0x0000A80900F8B58A AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (71, N'0151f12b-6721-40e3-bb28-81a8c942df42', 1, 397, CAST(0x0000A80A00979D24 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (72, N'0151f12b-6721-40e3-bb28-81a8c942df42', 60, 401, CAST(0x0000A80A0097AB84 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (78, N'5dcf6685-67d8-4e50-ba8f-05e18c811dff', 1, 401, CAST(0x0000A80A00EB7424 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (81, N'deeb3eba-7a03-4d53-a317-082735db3313', 1, 360, CAST(0x0000A819009F728B AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (30, N'9ca27969-09bf-4b6e-ac34-0e27bfe12063', 1, 356, CAST(0x0000A80800E514C8 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (73, N'0061598c-5565-4c01-97f9-98075660d494', 1, 360, CAST(0x0000A80A009A2F29 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (76, N'raoqi', 1, 401, CAST(0x0000A80A00EA3283 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (6, N'9198c23a-8e10-4e58-bb16-098eb7b5fa5c', 31, 360, CAST(0x0000A80700BF4B98 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (7, N'9198c23a-8e10-4e58-bb16-098eb7b5fa5c', 5, 362, CAST(0x0000A80700BB8AC2 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (9, N'5a17d33c-cdc4-437d-9676-60a987bd2a3a', 1, 400, CAST(0x0000A80700C19D2B AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (18, N'0b6849f9-c4dd-4b0e-844e-f685e1c1cd8a', 1, 404, CAST(0x0000A807011244AB AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (47, N'2dbe009c-dafc-48b2-be99-66a4dc380d29', 1, 368, CAST(0x0000A80900A046FF AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (10, N'5a17d33c-cdc4-437d-9676-60a987bd2a3a', 1, 371, CAST(0x0000A80700C1A9BF AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (11, N'8bb58bca-23c9-4aea-aec6-b3ef96eb0c4a', 1, 360, CAST(0x0000A80700E96DC8 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (36, N'906afd31-5bfc-438c-9985-67376d86b8b1', 1, 406, CAST(0x0000A80800EA0524 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (74, N'0061598c-5565-4c01-97f9-98075660d494', 1, 401, CAST(0x0000A80A009A9486 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (75, N'raoqi', 3, 397, CAST(0x0000A80A00E6DE60 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (77, N'019a6799-c54f-4d1e-b8ab-b5921ec2b57b', 6, 401, CAST(0x0000A80A00EB581F AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (43, N'2', 1, 386, CAST(0x0000A8080110795B AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (46, N'2dbe009c-dafc-48b2-be99-66a4dc380d29', 1, 360, CAST(0x0000A80900A03A88 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (70, N'3d8654aa-9bc6-4281-b003-738c2da44eb0', 1, 371, CAST(0x0000A80A00974991 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (35, N'906afd31-5bfc-438c-9985-67376d86b8b1', 1, 367, CAST(0x0000A80800EA01B5 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (42, N'2', 1, 401, CAST(0x0000A80801107592 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (68, N'3d8654aa-9bc6-4281-b003-738c2da44eb0', 1, 401, CAST(0x0000A80A009730F3 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (53, N'4e653c7c-3e75-494f-97e7-5916eace716e', 3, 360, CAST(0x0000A80900F48B95 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (69, N'3d8654aa-9bc6-4281-b003-738c2da44eb0', 1, 400, CAST(0x0000A80A0097426F AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (79, N'c1389d98-2604-45ba-a8ef-0cdbfb6d464d', 4, 397, CAST(0x0000A80A00EBE7E5 AS DateTime))
INSERT [dbo].[CMRC_ShoppingCart] ([RecordID], [CartID], [Quantity], [ProductID], [DateCreated]) VALUES (80, N'c1389d98-2604-45ba-a8ef-0cdbfb6d464d', 3, 401, CAST(0x0000A80A00EBEB40 AS DateTime))
SET IDENTITY_INSERT [dbo].[CMRC_ShoppingCart] OFF
/****** Object:  Index [PK_CMRC_Categories]    Script Date: 2017/10/28 21:46:56 ******/
ALTER TABLE [dbo].[CMRC_Categories] ADD  CONSTRAINT [PK_CMRC_Categories] PRIMARY KEY NONCLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_CMRC_Customers]    Script Date: 2017/10/28 21:46:56 ******/
ALTER TABLE [dbo].[CMRC_Customers] ADD  CONSTRAINT [PK_CMRC_Customers] PRIMARY KEY NONCLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Customers]    Script Date: 2017/10/28 21:46:56 ******/
ALTER TABLE [dbo].[CMRC_Customers] ADD  CONSTRAINT [IX_Customers] UNIQUE NONCLUSTERED 
(
	[EmailAddress] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_CMRC_Orders]    Script Date: 2017/10/28 21:46:56 ******/
ALTER TABLE [dbo].[CMRC_Orders] ADD  CONSTRAINT [PK_CMRC_Orders] PRIMARY KEY NONCLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_CMRC_Products]    Script Date: 2017/10/28 21:46:56 ******/
ALTER TABLE [dbo].[CMRC_Products] ADD  CONSTRAINT [PK_CMRC_Products] PRIMARY KEY NONCLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_CMRC_ShoppingCart]    Script Date: 2017/10/28 21:46:56 ******/
ALTER TABLE [dbo].[CMRC_ShoppingCart] ADD  CONSTRAINT [PK_CMRC_ShoppingCart] PRIMARY KEY NONCLUSTERED 
(
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ShoppingCart]    Script Date: 2017/10/28 21:46:56 ******/
CREATE NONCLUSTERED INDEX [IX_ShoppingCart] ON [dbo].[CMRC_ShoppingCart]
(
	[CartID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CMRC_Admin] ADD  DEFAULT ((0)) FOR [Sex]
GO
ALTER TABLE [dbo].[CMRC_Admin] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[CMRC_Orders] ADD  CONSTRAINT [DF_Orders_OrderDate]  DEFAULT (getdate()) FOR [OrderDate]
GO
ALTER TABLE [dbo].[CMRC_Orders] ADD  CONSTRAINT [DF_Orders_ShipDate]  DEFAULT (getdate()) FOR [ShipDate]
GO
ALTER TABLE [dbo].[CMRC_ShoppingCart] ADD  CONSTRAINT [DF_ShoppingCart_Quantity]  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[CMRC_ShoppingCart] ADD  CONSTRAINT [DF_ShoppingCart_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
USE [master]
GO
ALTER DATABASE [Commerce] SET  READ_WRITE 
GO
