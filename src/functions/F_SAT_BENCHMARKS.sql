/*

	To use for SAT Reading Score lookups:

	SELECT a.*, F_SAT_BENCHMARKS('SAT', DEFAULT, 1, ts.scaleScore) AS satrlalev
	FROM table AS a

	For PSAT the grade level is required and passing a value of 0 to the third parameter should look up math scores:

	SELECT a.*, F_SAT_BENCHMARKS('PSAT', '10', 0, ts.scaleScore) AS satmthlev
	FROM table AS a


*/

-- Drops the function if it is already defined in the database/schema
IF object_id('F_SAT_BENCHMARKS', 'FN') IS NOT NULL
    DROP FUNCTION [dbo].F_SAT_BENCHMARKS;
GO

-- Defines the function F_SAT_BENCHMARKS
CREATE FUNCTION dbo.F_SAT_BENCHMARKS(@test VARCHAR(4), @grade VARCHAR(2) = '', 
									 @reading BIT, @score DOUBLE PRECISION)

  -- Declares what will be returned by the function
  RETURNS VARCHAR(6) AS

  -- Begins the body of the function
  BEGIN

  	-- Declares a look up table variable to use for the function
  	DECLARE @lookup TABLE (
  		test VARCHAR(4) NOT NULL,
  		grade VARCHAR(2),
  		rla BIT NOT NULL,
  		level VARCHAR(6) NOT NULL,
  		min DOUBLE PRECISION NOT NULL,
  		max DOUBLE PRECISION NOT NULL
  	);

  	-- Declares variable used to store the return value from the function
  	DECLARE @returnValue VARCHAR(6);

  	-- Populates the look up table
  	INSERT @lookup (test, grade, rla, level, min, max)
  	VALUES 	('SAT', '', 1, 'red', 200, 450), ('SAT', '', 1, 'yellow', 460, 470), ('SAT', '', 1, 'green', 480, 800), 
  			('SAT', '', 0, 'red', 200, 500), ('SAT', '', 0, 'yellow', 510, 520), ('SAT', '', 0, 'green', 530, 800), 
  			('PSAT', '11', 1, 'red', 160, 420), ('PSAT', '11', 1, 'yellow', 430, 450), ('PSAT', '11', 1, 'green', 460, 760), 
  			('PSAT', '11', 0, 'red', 160, 470), ('PSAT', '11', 0, 'yellow', 480, 500), ('PSAT', '11', 0, 'green', 510, 760), 
  			('PSAT', '10', 1, 'red', 160, 400), ('PSAT', '10', 1, 'yellow', 410, 420), ('PSAT', '10', 1, 'green', 430, 760), 
  			('PSAT', '10', 0, 'red', 160, 440), ('PSAT', '10', 0, 'yellow', 450, 470), ('PSAT', '10', 0, 'green', 480, 760), 
  			('PSAT', '09', 1, 'red', 120, 380), ('PSAT', '09', 1, 'yellow', 390, 400), ('PSAT', '09', 1, 'green', 410, 720), 
  			('PSAT', '09', 0, 'red', 120, 420), ('PSAT', '09', 0, 'yellow', 430, 440), ('PSAT', '09', 0, 'green', 450, 720), 
  			('PSAT', '08', 1, 'red', 120, 360), ('PSAT', '08', 1, 'yellow', 370, 380), ('PSAT', '08', 1, 'green', 390, 720), 
  			('PSAT', '08', 0, 'red', 120, 400), ('PSAT', '08', 0, 'yellow', 410, 420), ('PSAT', '08', 0, 'green', 430, 720);

  	-- Looks up the proficiency level and returns the value
  	SELECT @returnValue = (
  		SELECT a.level
  		FROM  @lookup AS a
  		WHERE a.test = @test AND a.grade = @grade AND
  			  a.rla = @reading AND @score BETWEEN a.min AND a.max
  	);
   

    -- Returns the table variable
    RETURN(@returnValue);

  -- End of the function body
  END;

-- End of the function declaration
GO

