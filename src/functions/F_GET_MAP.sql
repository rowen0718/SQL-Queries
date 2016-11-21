
-- Checks if the function exists in the database
IF object_id(N'dbo.F_GET_MAP', N'TF') IS NOT NULL

	  -- Drops the function if it already exists
  DROP FUNCTION dbo.F_GET_MAP;

-- End of batch block
GO

-- Defines the function F_GET_MAP
CREATE FUNCTION dbo.F_GET_MAP(@schyr SMALLINT, @persid INT = NULL)

  -- Defines the table that the function returns
  RETURNS @retval TABLE (
	        sasid VARCHAR(15) NOT NULL,
		        pid INT,
			        schyr INT NOT NULL,
				        mapmthsc1 SMALLINT,
					        mapmthpct1 TINYINT,
						        maprlasc1 SMALLINT,
							        maprlapct1 TINYINT,
								        maplansc1 SMALLINT,
									        maplanpct1 TINYINT,
										        mapmthsc2 SMALLINT,
											        mapmthpct2 TINYINT,
												        maprlasc2 SMALLINT,
													        maprlapct2 TINYINT,
														        maplansc2 SMALLINT,
															        maplanpct2 TINYINT,
																        mapmthsc3 SMALLINT,
																	        mapmthpct3 TINYINT,
																		        maprlasc3 SMALLINT,
																			        maprlapct3 TINYINT,
																				        maplansc3 SMALLINT,
																					        maplanpct3 TINYINT
																						  ) AS

																						  -- Starts the function body
  BEGIN

	    -- Declares a table variable that holds the initial query from which the joins
    -- are performed
    DECLARE @students TABLE(sasid VARCHAR(15) NOT NULL,
	                            pid INT,
				                            schyr INT NOT NULL,
							                            sc SMALLINT,
										                            tid INT,
													                            pct TINYINT,
																                            period TINYINT);

																		    -- If no personID is passed
    IF @persid IS NULL

	      -- Get all of the data for a given year for all students in the table
      INSERT @students (sasid, pid, schyr, sc, tid, pct, period)
      SELECT DISTINCT p.stateID AS sasid,
                      ts.personID AS pid,
		                      @schyr AS schyr,
				                      CAST(ts.scaleScore AS SMALLINT) AS sc,
						                      ts.testID AS tid,
								                      CAST(ts.percentile AS TINYINT) AS pct,
										                      dbo.F_MAP_PERIODS(ts.date) AS period
												      FROM            [fayette].[dbo].[TestScore] AS ts
												      INNER JOIN      [fayette].[dbo].[person] p ON p.personID = ts.personID
												      WHERE           ts.testID BETWEEN 1427 AND 1429 AND
												                      dbo.F_ENDYEAR(ts.date, DEFAULT) = @schyr;

														    -- If a person ID is passed to the function
    ELSE

	      -- Get the data for just that individual student
      INSERT @students (sasid, pid, schyr, sc, tid, pct, period)
      SELECT DISTINCT p.stateID AS sasid,
                      ts.personID AS pid,
		                      @schyr AS schyr,
				                      CAST(ts.scaleScore AS SMALLINT) AS sc,
						                      ts.testID AS tid,
								                      CAST(ts.percentile AS TINYINT) AS pct,
										                      dbo.F_MAP_PERIODS(ts.date) AS period
												      FROM            [fayette].[dbo].[TestScore] AS ts
												      INNER JOIN      [fayette].[dbo].[person] p ON p.personID = ts.personID
												      WHERE           ts.testID BETWEEN 1427 AND 1429 AND
												                      dbo.F_ENDYEAR(ts.date, DEFAULT) = @schyr AND
														                      ts.personID = @persid;

																    -- Put the data into the
    INSERT @retval(sasid, pid, schyr,
	                  mapmthsc1, mapmthpct1, maprlasc1, maprlapct1, maplansc1, maplanpct1,
			                  mapmthsc2, mapmthpct2, maprlasc2, maprlapct2, maplansc2, maplanpct2,
					                  mapmthsc3, mapmthpct3, maprlasc3, maprlapct3, maplansc3, maplanpct3)
						    SELECT DISTINCT   a.sasid, a.pid, a.schyr,
						                      CASE WHEN b.period = 1 THEN b.sc END AS mapmthsc1,
									                      CASE WHEN b.period = 1 THEN b.pct END AS mapmthpct1,
												                      CASE WHEN c.period = 1 THEN c.sc END AS maprlasc1,
															                      CASE WHEN c.period = 1 THEN c.pct END AS maprlapct1,
																		                      CASE WHEN d.period = 1 THEN d.sc END AS maplansc1,
																					                      CASE WHEN d.period = 1 THEN d.pct END AS maplanpct1,
																								                      CASE WHEN b.period = 2 THEN b.sc END AS mapmthsc2,
																											                      CASE WHEN b.period = 2 THEN b.pct END AS mapmthpct2,
																														                      CASE WHEN c.period = 2 THEN c.sc END AS maprlasc2,
																																	                      CASE WHEN c.period = 2 THEN c.pct END AS maprlapct2,
																																				                      CASE WHEN d.period = 2 THEN d.sc END AS maplansc2,
																																							                      CASE WHEN d.period = 2 THEN d.pct END AS maplanpct2,
																																										                      CASE WHEN b.period = 3 THEN b.sc END AS mapmthsc3,
																																													                      CASE WHEN b.period = 3 THEN b.pct END AS mapmthpct3,
																																																                      CASE WHEN c.period = 3 THEN c.sc END AS maprlasc3,
																																																			                      CASE WHEN c.period = 3 THEN c.pct END AS maprlapct3,
																																																						                      CASE WHEN d.period = 3 THEN d.sc END AS maplansc3,
																																																									                      CASE WHEN d.period = 3 THEN d.pct END AS maplanpct3
																																																												    FROM @students AS a
																																																												    LEFT JOIN @students AS b ON a.sasid = b.sasid AND a.pid = b.pid AND
																																																												                                a.schyr = b.schyr AND b.tid = 1427
																																																																    LEFT JOIN @students AS c ON a.sasid = c.sasid AND a.pid = c.pid AND
																																																																                                a.schyr = c.schyr AND c.tid = 1428
																																																																				    LEFT JOIN @students AS d ON a.sasid = d.sasid AND a.pid = d.pid AND
																																																																				                                a.schyr = d.schyr AND d.tid = 1429

																																																																								  -- Returns the table valued return object
  RETURN;

  -- End of the function body
  END

-- End of the batch statement
GO

-- Use example
SELECT *
FROM dbo.F_GET_MAP(2017, 10);


