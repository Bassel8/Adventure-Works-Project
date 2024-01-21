# Adventure-Works-Project
For this project I used the Adventure Works Database made by Microsoft.
First I skimmed through it to understand the context of the data, then I chose two subjects for my project these subjects being (Sales & HR).
After that I made a list of the tables and columns that I will need for my analysis and based on that, I designed a Staging layer and a Data warehouse for Analysis purposes using T-SQL in MS SQL Server. 
I then went to SSIS to design some packages and implement ETL process to populate the staging layer in which I created some views with joins to avoid merging data in SSIS to optimze performance.
AFter the staging layer was populated, I created some stored procedures in the data warehouse that will populate the dimension tables there from the staging layer's views, and went to SSIS and called these procedures there, for fact tables however I desigen some specifec SSIS packages for them to populate them.
After that I ran some Exploratory and statistical analysis on the data that I have to get intial insights that will help me visualize it better.
And Finally connected to Power BI to design a dashboard for the Sales data mart.
