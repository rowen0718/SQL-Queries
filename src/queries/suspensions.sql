/*
	Author: Daphne Jenkins
	Purpose: Aggregate for Student Suspensions
	Notes: student demographics for primary enrollments (K-12 only) and indicator if they've had at least one out of school suspension
			FRED status is if they were ever marked as Free/Reduced for the year (not just the date range listed)	
*/

Declare @start datetime
set @start = '08/10/2016'
Declare @end datetime
set @end = '08/31/2016'
Declare @endYear int
set @endYear = 2017

select distinct p.personID, s.name
	, case when e.grade IN (00,01,02,03,04,05) then 'elem' when e.grade IN (06,07,08) then 'mid' when e.grade IN (09,10,11,12,14) 
		then 'high' End as GrdLvl
	--, i.lastName, i.firstName, ISNULL(i.middleName, '') As midName
	--, i.gender
	, case i.raceEthnicityFed when 1 then 'Hisp' when 2 then 'Ind' when 3 then 'Asi' when 4 then 'Blk' when 5 then 'Isl' 
		when 6 then 'Wht' else 'Oth' end as Race
	, case when (e.specialEdStatus IN ('A','AR') or (e.specialEdStatus = 'I' and e.spedExitDate between @start and @end)) 
		then 'Yes' Else '' End as SpEd
	, case when l.lepID IS NOT NULL then 'Yes' Else '' End as LEP
	, case when pe.eligibility Is not null then 'Yes' else '' End as FRed
	, case when x.personID IS NOT NULL then 'Yes' else '' End as Susp

from Person p With(NoLock) 
	Inner Join [Identity] i With(NoLock) on i.identityID = p.currentIdentityID 
	Inner Join Enrollment e With(NoLock) on p.personID = e.personID and ISNULL(e.noShow,0)=0 and ISNULL(e.stateExclude,0)=0 
		and e.serviceType = 'p' 
	Inner Join Calendar c With(NoLock) on e.calendarID = c.calendarID
	
	--Max Enrollment for School
	Inner Join (Select e.personID, MAX(e.startDate) as maxStart
		From Enrollment e With(NoLock) 
		where ISNULL(e.noShow,0)=0 and ISNULL(e.stateExclude,0)=0 and e.serviceType = 'p' 
			and e.startDate <= @end and ISNULL(e.endDate, GETDATE()) >= @start
			and e.endYear = @endYear
		group by e.personID
		) y on e.personID = y.personID and e.startDate = y.maxStart
	
	Inner Join School s With(NoLock) on c.schoolID = s.schoolID
	
	--Behavior (using portion of Jill's script from EquityScorecard report)
	Left Join (Select distinct bRes.personID
		From BehaviorIncident bi with(nolock) 
		INNER JOIN BehaviorEvent be with(nolock) on bi.incidentID = be.incidentID and bi.calendarID = be.calendarID 
			and CAST(CONVERT(varchar, bi.timestamp, 101) AS datetime)  between @start and @end 
		INNER JOIN BehaviorRole bRole with(nolock) on be.eventID = bRole.eventID and bRole.role in ('offender','participant') 
		INNER JOIN BehaviorResolution bRes with(nolock) on bRole.roleID = bRes.roleID 
		INNER JOIN BehaviorResType bResType with(nolock) on bRes.typeID = bResType.typeID and bResType.code = 'ssp3'
		) x on e.personID = x.personID
	--LEP
	Left Join Lep l With(NoLock) on p.personID = l.personID and ((l.programStatus = 'LEP' and (l.exitDate > @start or l.exitDate IS NULL))
		or (l.programStatus = 'Exited LEP' and (l.exitDate between @start and @end or l.exitDate > @end)))
	--Free/Reduced
	Left Join POSEligibility pe With(NoLock) on p.personID = pe.personID and e.endYear = pe.endYear  
		and pe.eligibility IN ('F','R')
		--FRED at the beginning of the year is very tricky due to files not being loaded until after the year starts and not being able
		--to backdate some things - Dana has more info.
		--and pe.startDate <= @end and ISNULL(pe.endDate,GETDATE())>=@start
	
where c.endYear = @endYear  
	and e.grade IN (00,01,02,03,04,05,06,07,08,09,10,11,12,14)
	and e.startDate <= @end and ISNULL(e.endDate, GETDATE()) >= @start
order by p.personID
