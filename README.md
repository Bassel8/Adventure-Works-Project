# AdventureWorks BI Project

## Defining business process:

First I skimmed through the data to understand its context, the business process, and to choose the business subjects that I will base my analysis on.

I chose two subjects for my project (Sales & HR).

## Defining business KPIs: (data warehouse objectives)

I then defined KPIs for each business subject to establish the objectives for my data warehouse, as shown below:

### Sales KPIs:

1- What Products are the most profitable ?

2- Does a higher quantity of sold products mean higher revenue ?

3- Who are our most valuable customers ?

4- Which order line should we focus on more and which should we not ? / Which order line has the highest volume of order ?

5- At what time of the year are our sales at the highest and what time are they at the lowest ? / Sales figure for each year, quarter and month.

6- Which region is generating the most revenue for us, and which country specifically in that region ?

### Hr:

1- Employees Attrition Rate by department ?

2- Employee Age distribution ?

3- Employee Gender by pay rate and frequency


## Defining granularity:

In this step I defined the level of granularity to be on the individual transaction level for dates and measurements, which is the highest level of granularity in this case.

## Defining dim and fact tables:

After that I made a list with the needed columns and tables that I will need to create 3 fact tables and their dimensions -7 dims in total- :

FactInternetSales (DimCurrency, DimCustomer, DimDate, DimProduct, DimSalesTerritory)

FactResellerSales (DimCurrency, DimReseller, DimDate, DimProduct, DimSalesTerritory)

FactEmployeePay (DimEmployee, DimDate)

## Data warehouse modelling:

Based on the previous steps I modelled the data warehouse in a star schema as shown below in the diagram:

![DW Diagram](https://github.com/Bassel8/Adventure-Works-Project/assets/128324838/0ad36b21-2328-4edc-8bc0-a246232048f9)

## Defining the physical model:

I then developed a SQL script in MS SQL Server to create both the Staging layer [STG layer Script](https://github.com/Bassel8/Adventure-Works-Project/blob/main/AW%20Project/SQL%20Script/STG%20creation.sql) and the Data warehouse (OLAP) [DW Script](https://github.com/Bassel8/Adventure-Works-Project/blob/main/AW%20Project/SQL%20Script/DW%20creation.sql). 

## Data integration: (ETL)

I then went to SSIS to design the needed packages and implement a full ETL process to populate the staging layer as shown below, 

![Employee](https://github.com/Bassel8/Adventure-Works-Project/assets/128324838/e5e4b04a-b993-42e8-bd78-4e6b8b7e96ba)

![Sales (Incremental)](https://github.com/Bassel8/Adventure-Works-Project/assets/128324838/ce3c139b-efb5-4c27-8076-4480dd297086)

![The rest](https://github.com/Bassel8/Adventure-Works-Project/assets/128324838/45a663a4-b122-4477-9036-f26f047357c0)




After the tables in the staging layer were populated, I created 5 [Views](https://github.com/Bassel8/Adventure-Works-Project/blob/main/AW%20Project/SQL%20Script/Views.sql) there to create joins between the following tables to minimise the use of merge in SSIS as it will impact performance: 

View [dbo].[Stg_view_Erp_Fact_InternetSales] which creates a join between SalesHeader, SalesOrderDetail and Product

View [dbo].[Stg_view_Erp_Fact_ResellerSales] which creates a join between SalesHeader, SalesOrderDetail, Product, Customer and Employee

View [dbo].[Stg_view_Erp_Fact_EmployeePayHistory] which creates a join between EmployeePayHistory, Employee and DimDate which i auto generated using a stored procedure

View [dbo].[Stg_view_Erp_Product] which creates a join between Product, ProductSubCategory, and ProductCategory

View [dbo].[Stg_view_Erp_Reseller] which creates a join between Customer and Store




I also created 3 [Stored Procedures](https://github.com/Bassel8/Adventure-Works-Project/blob/main/AW%20Project/SQL%20Script/Stored%20Procedure.sql) in the data warehouse that will populate these 3 tables (DimProduct, DimReseller -using their views- and dim table -auto generated via script-)




After that I went again to SSIS to populate the tables in the data warehouse as follows:

![DimCurrency](https://github.com/Bassel8/Adventure-Works-Project/assets/128324838/5ed8daee-bbca-48db-bb41-5073b68b3fb0)

![DimCustomer](https://github.com/Bassel8/Adventure-Works-Project/assets/128324838/9f742aea-5fa4-4cb1-97cf-e2ecf3c74b7e)

![DimEmployee (SCD)](https://github.com/Bassel8/Adventure-Works-Project/assets/128324838/9f3acfa5-2a24-40c3-b13a-7a18b38eb689)

![DimSales Territory](https://github.com/Bassel8/Adventure-Works-Project/assets/128324838/e869b396-acc5-4bad-ba21-07f1931362c2)

![Exec Stored Procedures (Dim Product, Date   Reseller](https://github.com/Bassel8/Adventure-Works-Project/assets/128324838/250bd0fe-ce21-46cd-9a69-36e32412eaf7)

![FactEmployeePay](https://github.com/Bassel8/Adventure-Works-Project/assets/128324838/442a623e-4e0f-4f3a-8c6d-91911a383615)

![FactInternetSales](https://github.com/Bassel8/Adventure-Works-Project/assets/128324838/e6476718-aef7-4f8f-8542-dcb454f983a4)

![FactResellerSales](https://github.com/Bassel8/Adventure-Works-Project/assets/128324838/2843427b-41a4-42c4-8252-fc23789d0a9f)

## Extracting insights:

After populating the data warehouse, I connected to power BI and designed a comprehensive live [Dashboard](https://app.powerbi.com/view?r=eyJrIjoiODQyMWRkY2YtNjAwNS00ZjIyLWE4YjYtMjM2MGFiZDcwY2YzIiwidCI6ImRmODY3OWNkLWE4MGUtNDVkOC05OWFjLWM4M2VkN2ZmOTVhMCJ9) to communicate insights visually for the sales department, where i used dax to create some additional custom measures.
![Sales Dashboard](https://github.com/Bassel8/Adventure-Works-Project/assets/128324838/8e29f111-e01c-46a4-a393-a94eccd727b7)


