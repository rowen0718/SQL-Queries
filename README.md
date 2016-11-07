# FCPS Queries
Repository containing combination of queries, functions, and stored procedures used by FCPS data team to get data from data system more efficiently and consistently.  Also promotes code reuse and maintainability.

# Directory Structure
All SQL is located in the src subdirectory.  This is further divided by SQL type areas (e.g., scripts, functions, stored procedures, etc...).

# Queries
(Section will list individual file names and purposes)

# Functions

## F_ELTMONTHS
Function used to get something analogous to an *"array"* of dates based on the passed parameters that can be used in subsequent queries to avoid hardcoding dates into the query bodies and to make the code base more modular and portable.

__PARAMETERS__ 
\@mnth - The numeric value for the month of interest (e.g., for October use the value 10)
\@yr   - The numeric value for the current year of interest (e.g., to get the dates for October of the 2013-2014 and 2014-2015 school year pass a value of 2014 to this parameter)

__EXAMPLE__

SELECT *
FROM F_ELTMONTHS(2, 2017);


Date Type | Starting Date | Ending Date 
--------- | ------------- | -----------
1         | 2017-07-01    | 2017-02-28
2         | 2017-02-01    | 2017-02-28
3         | 2016-02-01    | 2016-02-29









# Stored Procedures
(Section will list individual file names and purposes)



