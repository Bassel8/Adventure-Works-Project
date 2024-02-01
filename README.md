# Adventure-Works-Project
For this project I used the Adventure Works Database made by Microsoft.
First I skimmed through it to understand the context of the data, then I chose two subjects for my project these subjects being (Sales & HR) with two different schemas assigned to each of them (Erp & Hr) Respectively to simulate getting them from different systems.
After that I made a list of the tables and columns that I will need for my analysis and based on that, I designed a Staging layer data wrehouse and another Data warehouse for Analysis purposes using SQL in MS SQL Server. 
I then went to SSIS to design some packages and implement ETL process to populate the staging layer datawarehouse -in which I created some views with joins to avoid merging data in SSIS in order optimze performance-.
AFter the staging layer was populated, I created some stored procedures in the data warehouse that will populate the dimension tables there from the staging layer's views, and went to SSIS and called these procedures there, for fact tables however I desigen some specifec SSIS packages to populate them by calling in the surrogate keys from each dimension table as I have already established the relashionship between them by refrencing each Primary key in a dim table as a foriegn key in the fact table using SQL script.
After that I ran some Exploratory and statistical analysis on the data that I have to get intial insights, detect patterns and outliers and document any issues with the data before visualizing it in a BI tool.
And Finally connected to Power BI to design a dashboard for the Sales data mart: [Click here](https://app.powerbi.com/view?r=eyJrIjoiODQyMWRkY2YtNjAwNS00ZjIyLWE4YjYtMjM2MGFiZDcwY2YzIiwidCI6ImRmODY3OWNkLWE4MGUtNDVkOC05OWFjLWM4M2VkN2ZmOTVhMCJ9) to view the Dashboard.
The dashboard aims answers the the following business questions and also to give a comprehensive overview of overall performance and KPIs over years, quarters and months: 
1- What Products are the most profitable ?
2- Does a higher quantity of sold products mean higher revenue ?
3- Who are our most valuable customers ?
4- Which order line should we focus on more and which should we not ? / Which order line has the the highest volum of order
5- At what time of the year are our sales at the highest and what time are they at the lowest ? / Sales figure for each year, quarter and month
6- Which country is generating us the most revenue, and which region specifecally in that country ?
