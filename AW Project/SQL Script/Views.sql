/****** This script is to create views with joins in the staging layer database to join some tables that will be transferred later to the actual datawarehouse ******/
USE [ADV.Works_STG]
GO

/****** Object:  View [dbo].[Stg_view_Erp_Fact_InternetSales] ******/
--This view creates a join between SalesHeader, SalesOrderDetail and Product
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[Stg_view_Erp_Fact_InternetSales]
as
select h.[SalesOrderID],
 row_number() over(partition by h.[SalesOrderID] order by h.modifieddate) as saleLineNumber,
p.ProductNumber,
cast(h.[OrderDate] as date) [OrderDate] ,
cast(h.[DueDate] as Date) [DueDate],
cast(h.[ShipDate] as date) [ShipDate],
[CustomerID],
[TerritoryID],
N'USD' Currency,  
null [RevisionNumber],
[OrderQty],
[UnitPrice],
[UnitPriceDiscount],
[LineTotal],
0 [TaxAmt]

 from [erp].[SalesHeader] h
left join [erp].[SalesOrderDetail]  o
on h.SalesOrderID = o.SalesOrderID

left join [erp].[Product] p 
on o.[ProductID] = p.ProductID
where OnlineOrderFlag =1 -- This is to filter Internet Sales, as I want to avoid including transactions done by resellers, as this will be in a separate table.

GO
/****** Object:  View [dbo].[Stg_view_Erp_Fact_ResellerSales] ******/
--This view creates a join between SalesHeader, SalesOrderDetail, Product, Customer and Employee
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[Stg_view_Erp_Fact_ResellerSales]
as
select h.[SalesOrderID],
 row_number() over(partition by h.[SalesOrderID] order by h.modifieddate) as saleLineNumber,
p.ProductNumber,
cast(h.[OrderDate] as date) [OrderDate] ,
cast(h.[DueDate] as Date) [DueDate],
cast(h.[ShipDate] as date) [ShipDate],
 cast(c.[StoreID] as nvarchar(15)) ResellerID,
h.[TerritoryID],
e.NationalIDNumber,
N'USD' Currency,  
null [RevisionNumber],
[OrderQty],
[UnitPrice],
[UnitPriceDiscount],
[LineTotal],
0 [TaxAmt]

 from [erp].[SalesHeader] h
left join [erp].[SalesOrderDetail]  o
on h.SalesOrderID = o.SalesOrderID

left join [erp].[Product] p 
on o.[ProductID] = p.ProductID

left join [erp].[Customer] c
on h.[CustomerID] = c.[CustomerID]

left join [hr].[Employee] e
on e.[BusinessEntityID] = h.SalesPersonID
where OnlineOrderFlag=0 -- This is to filter ResellerSales

GO
/****** Object:  View [dbo].[Stg_view_Erp_Fact_EmployeePayHistory] ******/
--This view creates a join between EmployeePayHistory, Employee and DimDate as this view was created after creating the date table in the datawarehouse which was auto genrated using a script
CREATE view [dbo].[Stg_view_Erp_Fact_EmployeePayHistory]
as
Select b.NationalIDNumber,dt.MonthStart SalaryMonth, eh.Rate,eh.PayFrequency


from [hr].[EmployeePayHistory] eh

inner join  ( 

			SELECT [BusinessEntityID]
				  ,max([RateChangeDate]) CurrentRateDate
     
			  FROM [hr].[EmployeePayHistory]

			  group by [BusinessEntityID]

   ) Mxdt

   on eh.BusinessEntityID = Mxdt.BusinessEntityID
   and eh.RateChangeDate = Mxdt.CurrentRateDate


   Left Join [hr].[Employee] b
   on b.BusinessEntityID = eh.BusinessEntityID

   cross Join (
   
   select CalendarYear,EnglishMonthName, min(fullDateAlternateKey) MonthStart, Max(FullDateAlterNateKey) MonthEnd
   
    from [ADV.Works_DW].[dbo].[DimDate]
	where CalendarYear=2014
	group by CalendarYear,EnglishMonthName
	
	 )  dt
GO

/****** Object:  View [dbo].[Stg_view_Erp_Product] ******/
--This view creates a join between Product, ProductSubCategory, and ProductCategory
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




Create View [dbo].[Stg_view_Erp_Productv]
as

select  p.[ProductNumber],
        p.[Name],
		p.[StandardCost],
		p.[Color],
		p.[Size],
		null SizeRange,
		p.[Name] [EnglishDescription],
		sc.[Name]  as [ProductSubcategoryCode],
		c.[Name]   as  [ProductCategory]

 from [erp].[Product] p

left join [erp].[ProductSubCategory] sc
on p.ProductID = sc.ProductSubcategoryID

left join [erp].[ProductCategory] c
on sc.ProductSubcategoryID = c.ProductCategoryID

GO

/****** Object:  View [dbo].[Stg_view_Erp_Reseller] ******/
--This view creates a join between Customer and Store
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[Stg_view_Erp_Reseller]
as
SELECT distinct 
       [StoreID]
	  ,s.Name [ResellerName]
      ,null  [YearOpened]
      ,0 [NumberEmployees]
	  ,null [BusinessType]
	 
    
  FROM [erp].[Customer] c
  left join [erp].[Store] s
  on c.StoreId = s.BusinessEntityId

  where PersonID
is null