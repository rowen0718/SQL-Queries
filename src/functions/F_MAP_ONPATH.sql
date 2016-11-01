-- Drops table if it already exists and then rebuilds it
IF OBJECT_ID('dbo.MAP_CCR', 'U') IS NOT NULL
	DROP TABLE dbo.MAP_CCR;


	-- Drops table if it already exists and then rebuilds it
IF OBJECT_ID('dbo.MAP_SUBJECTS', 'U') IS NOT NULL
	DROP TABLE dbo.MAP_SUBJECTS;

	-- Builds a table of MAP subject areas
CREATE TABLE dbo.MAP_SUBJECTS (
	id INT NOT NULL PRIMARY KEY,
	content_area VARCHAR(23) NOT NULL
);

-- Inserts the data into the table to provide a mapping from numeric codes to subject area strings
INSERT dbo.MAP_SUBJECTS
VALUES (1431, 'Concepts and Processes'), (1430, 'General Science'),
   (1429, 'Language Usage'), (1427, 'Mathematics'), (1428, 'Reading');


-- Builds a table that stores the look up values used for the college/career on-path indicator for the score card
CREATE TABLE dbo.MAP_CCR (
	id TINYINT IDENTITY PRIMARY KEY,
	subject INT REFERENCES dbo.MAP_SUBJECTS (id),
	grade VARCHAR(2) NOT NULL,
	threshold DECIMAL(6, 3) NOT NULL
);

-- Inserts the subject area codes, grade levels, and threshold values for the on-path indicators
INSERT dbo.MAP_CCR
VALUES   (1427, '05', 225.0), (1428, '05', 214.0),
   (1427, '06', 232.0), (1428, '06', 219.0),
   (1427, '07', 238.0), (1428, '07', 223.0),
     (1427, '08', 242.0), (1428, '08', 227.0),
   (1427, '09', 246.0), (1428, '09', 229.0);

-- Generates on-path to college/career readiness indicator
CREATE FUNCTION dbo.MAP_ONPATH(@grade VARCHAR(2), @content INT, @rit DECIMAL)

	RETURNS DECIMAL AS

	BEGIN

		 DECLARE @threshold DECIMAL;

		 DECLARE @onpath DECIMAL;

		 SET @threshold = (
		  SELECT threshold
		  FROM dbo.MAP_CCR
		  WHERE subject = @content AND grade = @grade
		 );

		IF ( @grade NOT BETWEEN 5 AND 9 ) SET @onpath = NULL;

		ELSE IF (@threshold < @rit) SET @onpath = 1.0;

		ELSE SET @onpath = 0.0;

		RETURN(@onpath);

	END

GO
