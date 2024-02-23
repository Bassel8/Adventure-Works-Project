/****** This script it for creating stored procedures that will generate a dim date table and populate DimProduct and DimReseller tables ******/
USE [ADV.Works_DW]
GO
/****** Object:  StoredProcedure [dbo].[Refresh_DimDate] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[Refresh_DimDate]
as
Begin

declare @startdate date = '2005-01-01',
    @enddate date = '2014-12-31'

IF @startdate IS NULL
    BEGIN
        Select Top 1 @startdate = FulldateAlternateKey
        From DimDate 
        Order By DateKey ASC 
    END

Declare @datelist table (FullDate date)

while @startdate <= @enddate

Begin 
    Insert into @datelist (FullDate)
    Select @startdate

    Set @startdate = dateadd(dd,1,@startdate)

end 

 Insert into dbo.DimDate 
    (DateKey, 
        FullDateAlternateKey, 
        DayNumberOfWeek, 
        EnglishDayNameOfWeek, 
      
        DayNumberOfMonth, 
        DayNumberOfYear, 
        WeekNumberOfYear, 
        EnglishMonthName, 
     
        MonthNumberOfYear, 
        CalendarQuarter, 
        CalendarYear, 
        CalendarSemester, 
        FiscalQuarter, 
        FiscalYear, 
        FiscalSemester)


select convert(int,convert(varchar,dl.FullDate,112)) as DateKey,
    dl.FullDate,
    datepart(dw,dl.FullDate) as DayNumberOfWeek,
    datename(weekday,dl.FullDate) as EnglishDayNameOfWeek,
    
    
    datepart(d,dl.FullDate) as DayNumberOfMonth,
    datepart(dy,dl.FullDate) as DayNumberOfYear,
    datepart(wk, dl.FUllDate) as WeekNumberOfYear,
    datename(MONTH,dl.FullDate) as EnglishMonthName,
   
   
    Month(dl.FullDate) as MonthNumberOfYear,
    datepart(qq, dl.FullDate) as CalendarQuarter,
    year(dl.FullDate) as CalendarYear,
    case datepart(qq, dl.FullDate)
        when 1 then 1
        when 2 then 1
        when 3 then 2
        when 4 then 2
    end as CalendarSemester,
    case datepart(qq, dl.FullDate)
        when 1 then 3
        when 2 then 4
        when 3 then 1
        when 4 then 2
    end as FiscalQuarter,
    case datepart(qq, dl.FullDate)
        when 1 then year(dl.FullDate)
        when 2 then year(dl.FullDate)
        when 3 then year(dl.FullDate) + 1
        when 4 then year(dl.FullDate) + 1
    end as FiscalYear,
    case datepart(qq, dl.FullDate)
        when 1 then 2
        when 2 then 2
        when 3 then 1
        when 4 then 1
    end as FiscalSemester

from @datelist dl left join 
    DimDate dd 
        on dl.FullDate = dd.FullDateAlternateKey
Where dd.FullDateAlternateKey is null 


End
GO

/****** Object:  StoredProcedure [dbo].[Refresh_DimProduct] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[Refresh_DimProduct]

as
begin


set nocount on 
Insert into [dbo].[DimProduct]

(

       [ProductAlternateKey]
      ,[EnglishProductName]
      ,[StandardCost]
      ,[Color]
      ,[Size]
      ,[SizeRange]
      ,[EnglishDescription]
      ,[FrenchDescription]
      ,[ArabicDescription]
      ,[ProductSubcategoryCode]
      ,[ProductcategoryCode]
      ,[Status]
)


SELECT stg.[ProductNumber]
      ,stg.[Name]
      ,stg.[StandardCost]
      ,Isnull(stg.[Color],'NA')
      ,stg.[Size]
      ,stg.[SizeRange]
      ,stg.[EnglishDescription]
	  ,null 
      ,null
	  ,stg.[ProductSubcategoryCode]
      ,stg.[ProductCategory]   
	  ,null [Status]
  FROM [ADV.Works_STG].[dbo].[Stg_view_Erp_Product] stg (nolock)
    left join [dbo].[DimProduct] Dim  (nolock)
  on Dim.[ProductAlternateKey] = stg.[ProductNumber]
    where Dim.[ProductAlternateKey] is null


  Update Dim
  set Dim.[EnglishDescription]= stg.[EnglishDescription]

   
  from  [dbo].[DimProduct] Dim   (nolock)
  inner join [ADV.Works_STG].[dbo].[Stg_view_Erp_Product] stg (nolock)
  on Dim.[ProductAlternateKey] = stg.[ProductNumber]


   set nocount off


end 


GO

/****** Object:  StoredProcedure [dbo].[Refresh_Reseller] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Procedure [dbo].[Refresh_Reseller]

as
begin


set nocount on 
Insert into  [dbo].[DimReseller]

(
[ResellerAlternateKey]
,[ResellerName]

,[NumberEmployees]
,[YearOpened]
)


SELECT  Stg.[StoreID]
       ,Stg.[ResellerName]
     
	  ,Stg.[NumberEmployees] 
	  ,Stg.[YearOpened] 
  FROM [ADV.Works_STG].[dbo].[Stg_view_Erp_Reseller] stg (nolock)
    left join  [dbo].[DimReseller] Dim  (nolock)
  on stg.[StoreID] = Dim.[ResellerAlternateKey]
    where Dim.[ResellerAlternateKey] is null


  Update Dim

  Set  
   Dim.[ResellerName]=stg.[ResellerName]
, Dim.[NumberEmployees]=stg.[NumberEmployees]
  from [dbo].[DimReseller] Dim  (nolock)
  inner join  [ADV.Works_STG].[dbo].[Stg_view_Erp_Reseller]  stg  (nolock)
  on  stg.[StoreID] = Dim.[ResellerAlternateKey]


   set nocount off


end 



GO
