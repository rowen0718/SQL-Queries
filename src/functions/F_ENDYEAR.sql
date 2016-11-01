/***
 *
 * This function makes it easier to overload the method by extracting the data type from the
 * argument passed to it. Then IF/ELSE Blocks can be used in the function/procedure bodies to
 * simulate an overloaded method.  Just make sure to specify the input parameter as a
 * SQL_VARIANT data type.
 *
 * @param torecast A SQL_VARIANT (e.g., generic) type whose datatype will be returned as a
 *				    character string.
 *
*/
-- DROP FUNCTION [dbo].TYPECAST;
CREATE FUNCTION [dbo].TYPECAST(@torecast SQL_VARIANT)

	-- Returns a character string with the data type
	RETURNS VARCHAR(20) AS

	-- Start function body
	BEGIN

		-- Declare a return variable
		DECLARE @newtype VARCHAR(20)

		-- Select the base type property from the parameter passed to the function
		SELECT @newtype = CONVERT(VARCHAR(20), SQL_VARIANT_PROPERTY(@torecast, 'BaseType'));

		-- Return the base type
		RETURN(@newtype);

	-- End of Function body
	END

-- End of Batch/Block
GO


/***
 *
 * Function to return the academic year ending given a date input
 * Examples:
 *		SELECT dbo.F_ENDYEAR('12/22/2003', DEFAULT); -- Returns 2004
 *		SELECT dbo.F_ENDYEAR(GETDATE(), DEFAULT); -- Returns 2016 as of 11/16/2015
 * @param datewhen A string or date/datetime value for which the end value of the academic year is requested
 * @param dateType An integer value used to specify the date-time format used for the input
 *					see the section titled Date and Time Styles https://msdn.microsoft.com/en-us/library/ms187928(v=sql.100).aspx
 *					for additional information.
*/
-- DROP FUNCTION [dbo].F_ENDYEAR;
CREATE FUNCTION [dbo].F_ENDYEAR(@datewhen SQL_VARIANT, @dateType INT=101)

	-- Returns the integer value of the end of the academic year
	RETURNS INT AS

	-- Begin the function definition
	BEGIN

		-- Declare a local variable of type INT
		DECLARE @yearending INT, @dataType VARCHAR(25)

		-- Store the data type of the input parameter
		SELECT @dataType = [dbo].TYPECAST(@datewhen);

		-- If user passes date type argument to the first parameter
		IF @dataType IN ('date', 'datetime', 'datetime2', 'smalldatetime')

			-- Start the function body for date arguments
			BEGIN

				-- If the date passed to the function is between January and June
				IF MONTH(CONVERT(DATE, @datewhen, @dateType)) <= 6

					-- Select the year from the date
					SELECT @yearending = YEAR(CONVERT(DATE, @datewhen, @dateType));

				-- If the date passed to the function is between July and December
				ELSE

					-- Increment the year of the date to reflect the end of the academic year
					SELECT @yearending = YEAR(CONVERT(DATE, @datewhen, @dateType)) + 1;

			-- End of IF Block for date type arguments
			END

		-- If user passes charater type arguments
		ELSE IF @dataType IN ('char', 'nchar', 'nvarchar', 'varchar')

			-- Start the alternate function body
			BEGIN

				-- Convert the input parameter to character string then to date type
				-- And test whether the month is <= June
				IF MONTH(CAST(CONVERT(VARCHAR(25), @datewhen, @dateType)AS DATE)) <= 6

					-- For months January - June take the calendar year
					SELECT @yearending = YEAR(CAST(CONVERT(VARCHAR(25), @datewhen, @dateType) AS DATE));

				-- For all other months
				ELSE

					-- Add one to the value of the calendar year to get the academic year ending
					SELECT @yearending = YEAR(CAST(CONVERT(VARCHAR(25), @datewhen, @dateType) AS DATE)) + 1;

			-- End of ELSE Block for string arguments
			END

		-- For any other case, the function should return NULL values
		ELSE SELECT @yearending = NULL

		-- Return the value from the function
		RETURN(@yearending);

	-- End of the function definition
	END

-- Process this batch
GO