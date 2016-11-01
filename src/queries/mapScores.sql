/*
	Author: Daphne Jenkins
	Purpose: Aggregated MAP scores
	Notes:  I updated the script because I forgot about adding the director’s names.  J  So, that has been added but it has not been accurately maintained.

*/
Declare @endYear as int
set @endYear = 2017

select distinct cc.value as director, s.name
	--p.personID, p.stateID, s.name, e.grade, i.lastName, i.firstName, ISNULL(i.middleName, '') As middleName
	, i.gender
	, case i.raceEthnicityFed when 1 then 'His' when 2 then 'Ind' when 3 then 'Asi' when 4 then 'Blk' when 5 then 'Isl' 
		when 6 then 'Wht' else 'Oth' end as Race
	, case when (e.specialEdStatus IN ('A','AR') or (e.specialEdStatus = 'I' and e.spedExitDate between e.startDate and e.endDate)) 
		then 'Yes' Else '' End as SpEd
	, case when l.lepID IS NOT NULL then 'Yes' Else '' End as LEP
	, case when pe.eligibility Is not null then 'Yes' else '' End as FRed
	, case when g.giftedID Is not null then 'Yes' else '' End as GT
	, t.name as test
	, AVG (ts.scaleScore) as meanScore, STDEVP (ts.scaleScore) as stanDevP, STDEV (ts.scaleScore) as stanDev
	, count(distinct p.personID) as stuCnt
from Person p With(NoLock) 
	Inner Join [Identity] i With(NoLock) on i.identityID = p.currentIdentityID 
	Inner Join Enrollment e With(NoLock) on p.personID = e.personID and ISNULL(e.noShow,0)=0 and ISNULL(e.stateExclude,0)=0 
		and e.serviceType = 'p' 
	Inner Join Calendar c With(NoLock) on e.calendarID = c.calendarID
	Inner Join School s With(NoLock) on c.schoolID = s.schoolID
	Inner Join SchoolYear sy With(NoLock) on c.endYear = sy.endYear
	Inner Join TestScore ts With(NoLock) on p.personID = ts.personID and ts.testID IN (1427,1428)
		and ts.date between sy.startDate and sy.endDate
	Inner Join Test t With(NoLock) on ts.testID = t.testID
	Left Join CustomCalendar cc With(NoLock) on c.calendarID = cc.calendarID and cc.attributeID = 2336
	--LEP
	Left Join Lep l With(NoLock) on p.personID = l.personID and ((l.programStatus = 'LEP' and (l.exitDate > e.startDate or l.exitDate IS NULL))
		or (l.programStatus = 'Exited LEP' and (l.exitDate between e.startDate and ISNULL(e.endDate,GETDATE()) or l.exitDate > e.endDate)))
	--Free/Reduced
	Left Join POSEligibility pe With(NoLock) on p.personID = pe.personID and e.endYear = pe.endYear  
		and pe.eligibility IN ('F','R')
		--FRED at the beginning of the year is very tricky due to files not being loaded until after the year starts and not being able
		--to backdate some things - Dana has more info.
	--GT --category 12 is Primary Talent Pool - Decide to include or not depending on need
	Left Outer Join GiftedStatusKY g on g.personID = p.personID and g.endDate IS NULL --and g.category <> 12 --12 is PTP
	
where e.endYear = @endYear  
	and e.endDate IS NULL
	and e.grade IN (00,01,02,03,04,05,06,07,08,09,10,11,12,14)
group by cc.value, s.name, i.gender
	, case i.raceEthnicityFed when 1 then 'His' when 2 then 'Ind' when 3 then 'Asi' when 4 then 'Blk' when 5 then 'Isl' 
		when 6 then 'Wht' else 'Oth' end
	, case when (e.specialEdStatus IN ('A','AR') or (e.specialEdStatus = 'I' and e.spedExitDate between e.startDate and e.endDate)) 
		then 'Yes' Else '' End
	, case when l.lepID IS NOT NULL then 'Yes' Else '' End
	, case when pe.eligibility Is not null then 'Yes' else '' End
	, case when g.giftedID Is not null then 'Yes' else '' End
	, t.name
order by s.name