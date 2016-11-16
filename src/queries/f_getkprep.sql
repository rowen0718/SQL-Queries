IF object_id(N'dbo.F_GET_KPREP', N'TF') IS NOT NULL
    DROP FUNCTION dbo.F_GET_KPREP;

GO

CREATE FUNCTION dbo.F_GET_KPREP(@schyr SMALLINT)

	RETURNS @retval TABLE (
			sasid VARCHAR(15) NOT NULL,
			pid INT ,
      schyr INT NOT NULL,
      mthsc INT,
      mthlev TINYINT,
      rlasc INT,
      rlalev TINYINT
		) AS
		     		
		BEGIN
		
				DECLARE @students TABLE(sasid VARCHAR(15) NOT NULL,
			pid INT PRIMARY KEY,
		      schyr INT NOT NULL);

      INSERT @students (sasid, pid, schyr)
      SELECT DISTINCT p.stateID AS sasid, p.personID AS pid, @schyr AS schyr
      FROM fayette.dbo.person p
      Inner JOIN fayette.dbo.enrollment e ON e.personID = p.personID AND e.active = 1 AND e.endYear = @schyr AND e.grade BETWEEN '03' AND '14' AND ISNULL(e.noShow, 0) = 0 AND e.serviceType = 'p'
      Inner JOIN fayette.dbo.TestScore ts ON p.personID = ts.personID AND ts.testID IN (1642, 1648, 1641, 1650);
		
		INSERT @retval(sasid, pid, schyr, mthsc, mthlev, rlasc, rlalev)
		SELECT ret.*
		FROM (	SELECT DISTINCT	a.*, 
						CAST(m.scalescore AS INT) AS mthsc, 
						CASE 
							WHEN m.result = 'N' THEN 1 
							WHEN m.result = 'A' THEN 2 
							WHEN m.result = 'P' THEN 3 
							WHEN m.result = 'D' THEN 4 
							ELSE NULL 
						END AS mthlev,
						CAST(r.scalescore AS INT) AS rlasc,
						CASE
							WHEN r.result = 'N' THEN 1
							WHEN r.result = 'A' THEN 2
							WHEN r.result = 'P' THEN 3
							WHEN r.result = 'D' THEN 4
							ELSE NULL
						END AS rlalev			
				FROM @students a
				LEFT JOIN fayette.dbo.TestScore m ON	m.personID = a.pid AND 
												m.testID IN (1642, 1648) AND 
												FCPS_BB.dbo.F_ENDYEAR(m.date, DEFAULT) = @schyr AND m.scaleScore IS NOT NULL
					
				LEFT JOIN fayette.dbo.TestScore r ON	r.personID = a.pid AND 
												r.testID IN (1641, 1650) AND 
												FCPS_BB.dbo.F_ENDYEAR(r.date, DEFAULT) = @schyr AND r.scaleScore IS NOT NULL
	) AS ret
	WHERE (ret.mthlev IS NOT NULL or ret.rlalev IS NOT NULL)
	
	RETURN;	
	
	END
	
GO
			