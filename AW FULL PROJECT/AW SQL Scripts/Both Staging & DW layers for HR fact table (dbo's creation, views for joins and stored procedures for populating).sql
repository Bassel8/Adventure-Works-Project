


--ETL Extract from OLTP to Staging

use [AW_STG]
go
if object_id('hr.EmployeePayHistory') >0
 drop table [hr].[EmployeePayHistory]


select * into [AW_STG].[hr].[EmployeePayHistory] 
from [AdventureWorks2022].[HumanResources].[EmployeePayHistory]



--ETL / Prepare the staging view
Use [AW_STG]
go


if object_id('dbo.Stg_vw_Erp_Fact_EmployeePayHistory') >0
 drop view [dbo].[Stg_vw_Erp_Fact_EmployeePayHistory]
 go

Create view [dbo].[Stg_vw_Erp_Fact_EmployeePayHistory]
as



Select b.NationalIDNumber,dt.MonthStart SalaryMonth, eh.Rate,eh.PayFrequency


from [AW_STG].[hr].[EmployeePayHistory] eh

inner join  ( 

			SELECT [BusinessEntityID]
				  ,max([RateChangeDate]) CurrentRateDate
     
			  FROM [AW_STG].[hr].[EmployeePayHistory]

			  group by [BusinessEntityID]

   ) Mxdt

   on eh.BusinessEntityID = Mxdt.BusinessEntityID
   and eh.RateChangeDate = Mxdt.CurrentRateDate


   Left Join [hr].[Employee] b
   on b.BusinessEntityID = eh.BusinessEntityID

   cross Join (
   
   select CalendarYear,EnglishMonthName, min(fullDateAlternateKey) MonthStart, Max(FullDateAlterNateKey) MonthEnd
   
    from [AW_STG].[dbo].[DimDate]
	where CalendarYear=2014
	group by CalendarYear,EnglishMonthName
	
	 )  dt



--Load Fact 
go

use [AW_DW]
go




if object_id('dbo.Refresh_FactEmployeePay') >0
 drop proc [dbo].[Refresh_FactEmployeePay]
 go

 
if OBJECT_ID ('dbo.FactEmployeePay')>0
 drop table [dbo].[FactEmployeePay]

 
CREATE TABLE [dbo].[FactEmployeePay](
	[EmployeeKey] [int] NULL,
	[DateKey] [int] NULL,
	[PayFrequency] [tinyint] NOT NULL,
	[Rate] [money] NOT NULL
) ON [PRIMARY]

GO



ALTER TABLE [dbo].[FactEmployeePay]  ADD  CONSTRAINT [FK_FactEmployeePay_emp] FOREIGN KEY([EmployeeKey])
REFERENCES [dbo].[DimEmployee]([EmployeeKey])
GO


ALTER TABLE [dbo].[FactEmployeePay]  ADD  CONSTRAINT [FK_FactEmployeePay_dt] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimDate]([DateKey])
GO


Create Procedure [dbo].[Refresh_FactEmployeePay]
as

Begin



 insert into   [AW_DW].[dbo].[FactEmployeePay]

select e.EmployeeKey,d.DateKey,s.PayFrequency,s.Rate 


from [AW_STG].[dbo].[Stg_vw_Erp_Fact_EmployeePayHistory] s

left join [AW_DW].[dbo].[DimEmployee] e   
on e.[EmployeeNationalIDAlternateKey] = s.NationalIDNumber


left join [AW_DW].[dbo].[DimDate] d
on s.SalaryMonth = d.FullDateAlternateKey



end
go

exec [dbo].[Refresh_FactEmployeePay]