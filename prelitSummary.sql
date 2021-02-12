SELECT 

staff.staff_code as staff, 
tot_cases.totalCases as total_cases, 
act_cases.activeCases as active_cases, 
cast((tot_cases.totalCases*0.2) as int) as expected_AChats,
a_chats_made.AChats as Achats_made, 
(case when expected_AChats='0' then null when expected_AChats is null then null else (cast(cast((coalesce(a_chats_made.AChats,0)*1.0/expected_AChats*100) as int) as varchar)+'%') end) as Perc_AChats_Made,
needs_a_chat.needsChat as needs_chats,
(case when activeCases='0' then null when activeCases is null then null else (cast(cast((coalesce(needs_chats,0)*1.0/activeCases*100) as int) as varchar)+'%') end) as Perc_Needs_Chats,
cast((tot_cases.totalCases*0.08) as int) as expected_adj_calls,
adj_calls_made.adj_calls as adj_calls_made, 
(case when expected_adj_calls='0' then null when expected_adj_calls is null then null else (cast(cast((coalesce(adj_calls_made,0)*1.0/expected_adj_calls*100) as int) as varchar)+'%') end) as Perc_adjCalls_Made,
demands_sent.demands as demands,
demands_year.demandsForYear as demands_ytd,
demands_unsent.demandsUnsent as demands_need_drafting,
late_demands.lateDemands as demands_late_drafting,
mailed_demands.demandsMailed as demands_mailed,
demands_finalizing.demandsFinalizing as demands_need_finalizing,
checklist_items.checklistItems as check_items_due,
checklist_done.checklistDone as check_done,
check_mod.checkMod as check_mod,
cal_entries.cal_created as cal_created,
c_112.c112 as c112,
c_204.c204 as c204,
c_504.c504 as c504,
SUM_Insurance.SumInsurance,
N_Liability.Liability,
No_Fault.NoFault,
PIP_Ledger.PIPLedger,
N_IME.IME,
Workers_Comp.WorkersComp,
Conf_Client.ConfClient,
Conf_Adjuster.ConfAdjuster,
Conf_Doctor.ConfDoctor,
Tele_Conf_Client.TeleConfClient,
Helping_People.HelpingPeople,
cs.Counts_ConfClient_Through_HPeople


INTO #WKM_PLS_Temp

FROM staff 

-- totalCases
LEFT JOIN (
	SELECT cases.staff_2, count(cases.casenum) as totalCases FROM CASES
	WHERE cases.open_status='O' and cases.matcode IN ('GPI','S&amp;F','MVA') GROUP BY cases.staff_2) tot_cases
ON staff.staff_code=tot_cases.staff_2

--activeCases
LEFT JOIN (
	SELECT cases.staff_2, count(cases.casenum) as activeCases FROM cases
	WHERE cases.casenum NOT IN (
		SELECT cases.casenum FROM cases 
		LEFT JOIN value on cases.casenum=value.case_id
		WHERE value.code='RECOVERY' and cases.open_status='O'
		) 
	and cases.open_status='O' and cases.matcode IN ('GPI','S&amp;F','MVA')
	group by cases.staff_2
	) act_cases
ON staff.staff_code=act_cases.staff_2

--AChats
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as AChats FROM case_notes
	WHERE case_notes.topic='A Chat w/Client'
	and note_date&gt;=##STARTDATE##
	and note_date&lt;=##ENDDATE##
	group by case_notes.staff_id
	) a_chats_made
ON staff.staff_code=a_chats_made.staff_id

--Needs AChat
LEFT JOIN (
	SELECT cases.staff_2, count(cases.casenum) as needsChat FROM CASES
	WHERE cases.open_status='O' AND 
	cases.casenum NOT IN (
		SELECT cases.casenum FROM cases
		LEFT JOIN case_notes ON cases.casenum=case_notes.case_num
		WHERE cases.open_status='O' and case_notes.topic='A Chat w/Client'
		and cases.staff_2=case_notes.staff_id
		and case_notes.note_date&gt;=DATEADD(day, -60, today())
		)
	GROUP BY cases.staff_2
	) needs_a_chat
ON 	staff.staff_code=needs_a_chat.staff_2
	
--adjuster calls
LEFT JOIN (
	SELECT negotiation.staff, count(negotiation.neg_id) as adj_calls FROM negotiation
	WHERE kind='Staff Call Made'
	and neg_date&gt;=##STARTDATE##
	and neg_date&lt;=##ENDDATE##
	group by negotiation.staff
	) adj_calls_made
ON 	staff.staff_code=adj_calls_made.staff

--Demands
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as demands FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='206' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=##STARTDATE##
	and case_checklist.date_of_modification&lt;=##ENDDATE##
	group by case_checklist.staff_assigned
	) demands_sent
ON staff.staff_code=demands_sent.staff_assigned

--Demands drafted for year
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as demandsForYear FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='206' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=datepart(year, today())
	group by case_checklist.staff_assigned
	) demands_year
ON staff.staff_code=demands_year.staff_assigned

--Demands needing drafting
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as demandsUnsent FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='206' and case_checklist.status='Open'
	and cases.open_status='O'
	group by case_checklist.staff_assigned
	) demands_unsent
ON staff.staff_code=demands_unsent.staff_assigned

--Demands Late
LEFT JOIN (
	SELECT DISTINCT cases.staff_2, count(cases.casenum) as lateDemands FROM CASES
	LEFT JOIN (SELECT status as c200, case_id, date_of_modification from CASE_CHECKLIST WHERE CODE='200') a
	ON CASES.casenum=a.case_id
	LEFT JOIN (SELECT status as c206, case_id from CASE_CHECKLIST WHERE CODE='206') b
	ON CASES.casenum=b.case_id
	WHERE cases.open_status='O' AND a.c200='Done' AND b.c206='Open' AND a.date_of_modification&lt;=(TODAY()-5)
	AND cases.open_status='O' 
	group by cases.staff_2
	) late_demands
ON staff.staff_code=late_demands.staff_2

--Demands Mailed
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as demandsMailed FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='210' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=##STARTDATE##
	and case_checklist.date_of_modification&lt;=##ENDDATE##
	group by case_checklist.staff_assigned
	) mailed_demands
ON staff.staff_code=mailed_demands.staff_assigned

--Demands Needing Finalization
LEFT JOIN (
	SELECT DISTINCT cases.staff_2, count(cases.casenum) as demandsFinalizing FROM CASES
	LEFT JOIN (SELECT status as c207, case_id, date_of_modification from CASE_CHECKLIST WHERE CODE='207') a
	ON CASES.casenum=a.case_id
	LEFT JOIN (SELECT status as c210, case_id from CASE_CHECKLIST WHERE CODE='210') b
	ON CASES.casenum=b.case_id
	WHERE cases.open_status='O' AND a.c207='Done' AND b.c210='Open' AND a.date_of_modification&lt;=(TODAY()-3)
	AND cases.open_status='O' 
	group by cases.staff_2
	) demands_finalizing
ON staff.staff_code=demands_finalizing.staff_2

--Checklist Items on Welcome Page
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as checklistItems
	FROM CASE_CHECKLIST 
	INNER JOIN cases ON cases.casenum=case_checklist.case_id
	WHERE cases.open_status='O' and case_checklist.status='Open'
	and case_checklist.due_date&lt;=today()
	group by case_checklist.staff_assigned
	) checklist_items
ON staff.staff_code=checklist_items.staff_assigned

--checklist items done
LEFT JOIN (
select case_checklist.staff_modified, count(case_checklist.checklist_id) as checklistDone
from case_checklist where status='Done' 
and due_date&gt;=##STARTDATE##
and due_date&lt;=##ENDDATE##
group by staff_modified
) checklist_done
on staff.staff_code=checklist_done.staff_modified

--checklist items modified
LEFT JOIN (
select staff_modified, count(checklist_id) as checkMod from case_checklist 
where status='Open' 
and date_of_modification&gt;=##STARTDATE##
and date_of_modification&lt;=##ENDDATE## and
staff_assigned=staff_modified and
(STRING(date_of_modification,' ',time_of_modification)&lt;&gt;DATEFORMAT(date_created,'YYYY-MM-DD HH-NN-SS')
or date_created is null)
group by staff_modified
) check_mod
on staff.staff_code=check_mod.staff_modified

--cal entries created
LEFT JOIN(
select staff_created, count(start_date) as cal_created from (
select distinct start_date, start_time, stop_date, stop_time, subject, staff_created
from calendar where 
date_created&gt;=##STARTDATE##
and date_created&lt;=##ENDDATE##) a
group by staff_created
) cal_entries
on staff.staff_code=cal_entries.staff_created

--c112
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as c112 FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='112' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=##STARTDATE##
	and case_checklist.date_of_modification&lt;=##ENDDATE##
	group by case_checklist.staff_assigned
	) c_112
ON staff.staff_code=c_112.staff_assigned

--c204
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as c204 FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='204' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=##STARTDATE##
	and case_checklist.date_of_modification&lt;=##ENDDATE##
	group by case_checklist.staff_assigned
	) c_204
ON staff.staff_code=c_204.staff_assigned

--c504
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as c504 FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='504' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=##STARTDATE##
	and case_checklist.date_of_modification&lt;=##ENDDATE##
	group by case_checklist.staff_assigned
	) c_504
ON staff.staff_code=c_504.staff_assigned

--SUM Insurance
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as SumInsurance FROM case_notes
	WHERE case_notes.topic='SUM Insurance'
	and note_date&gt;=##STARTDATE##
	and note_date&lt;=##ENDDATE##
	group by case_notes.staff_id
	) SUM_Insurance
ON staff.staff_code=SUM_Insurance.staff_id

--Liability
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as Liability FROM case_notes
	WHERE case_notes.topic='Liability'
	and note_date&gt;=##STARTDATE##
	and note_date&lt;=##ENDDATE##
	group by case_notes.staff_id
	) N_Liability
ON staff.staff_code=N_Liability.staff_id

--No-Fault
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as NoFault FROM case_notes
	WHERE case_notes.topic='No-Fault'
	and note_date&gt;=##STARTDATE##
	and note_date&lt;=##ENDDATE##
	group by case_notes.staff_id
	) No_Fault
ON staff.staff_code=No_Fault.staff_id

--PIP Ledger
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as PipLedger FROM case_notes
	WHERE case_notes.topic='PIP Ledger'
	and note_date&gt;=##STARTDATE##
	and note_date&lt;=##ENDDATE##
	group by case_notes.staff_id
	) Pip_Ledger
ON staff.staff_code=Pip_Ledger.staff_id

--IME
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as IME FROM case_notes
	WHERE case_notes.topic='IME'
	and note_date&gt;=##STARTDATE##
	and note_date&lt;=##ENDDATE##
	group by case_notes.staff_id
	) N_IME
ON staff.staff_code=N_IME.staff_id

--Workers Compensation
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as WorkersComp FROM case_notes
	WHERE case_notes.topic='Workers Compensation'
	and note_date&gt;=##STARTDATE##
	and note_date&lt;=##ENDDATE##
	group by case_notes.staff_id
	) Workers_Comp
ON staff.staff_code=Workers_Comp.staff_id

--ConfClient
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as ConfClient FROM case_notes
	WHERE case_notes.topic='Conf/Client'
	and note_date&gt;=##STARTDATE##
	and note_date&lt;=##ENDDATE##
	group by case_notes.staff_id
	) Conf_Client
ON staff.staff_code=Conf_Client.staff_id

--ConfAdjuster
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as ConfAdjuster FROM case_notes
	WHERE case_notes.topic='Conf/Adjuster'
	and note_date&gt;=##STARTDATE##
	and note_date&lt;=##ENDDATE##
	group by case_notes.staff_id
	) Conf_Adjuster
ON staff.staff_code=Conf_Adjuster.staff_id

--ConfDoctor
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as ConfDoctor FROM case_notes
	WHERE case_notes.topic='Conf/Doctor'
	and note_date&gt;=##STARTDATE##
	and note_date&lt;=##ENDDATE##
	group by case_notes.staff_id
	) Conf_Doctor
ON staff.staff_code=Conf_Doctor.staff_id

--Tele ConfClient
Left JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as TeleConfClient FROM case_notes
	WHERE case_notes.topic='Tele Conf/Client'
	and note_date&gt;=##STARTDATE##
	and note_date&lt;=##ENDDATE##
	group by case_notes.staff_id
	) Tele_Conf_Client
ON staff.staff_code=Tele_Conf_Client.staff_id

--HelpingPeople
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as HelpingPeople FROM case_notes
	WHERE case_notes.topic='Helping People'
	and note_date&gt;=##STARTDATE##
	and note_date&lt;=##ENDDATE##
	group by case_notes.staff_id
	) Helping_People
ON staff.staff_code=Helping_People.staff_id

--HelpingPeople
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as Counts_ConfClient_Through_HPeople FROM case_notes
	where (case_notes.topic='Helping People' or case_notes.topic='Tele Conf/Client' or case_notes.topic='Conf/Doctor' or case_notes.topic='Conf/Adjuster' or case_notes.topic='Conf/Client')
	and note_date&gt;=##STARTDATE##
	and note_date&lt;=##ENDDATE##
	group by case_notes.staff_id
	) cs
ON staff.staff_code=cs.staff_id


WHERE staff.job_title='Pre-Litigation' and staff.active='Y'
order by staff.staff_code

SELECT * FROM #WKM_PLS_TEMP
UNION 
SELECT 'TOTALS:',sum(total_cases), sum(active_cases), sum(expected_AChats), 
sum (AChats_made), 
cast(cast((sum(AChats_made)*1.0/sum(expected_AChats)*100) as int) as varchar)+'%',
sum(needs_chats), 
cast(cast((sum(needs_chats)*1.0/sum(active_cases)*100) as int) as varchar)+'%',
sum(expected_adj_calls),
sum(adj_calls_made), 
cast(cast((sum(adj_calls_made)*1.0/sum(expected_adj_calls)*100) as int) as varchar)+'%',
sum(demands), sum(demands_ytd), sum(demands_need_drafting), 
sum(demands_late_drafting), sum(demands_mailed), sum(demands_need_finalizing), sum(check_items_due),
sum(check_done), sum(check_mod), sum(cal_created),
sum(c112),
sum(c204),
sum(c504),
sum(SumInsurance),
sum(Liability),
sum(NoFault),
sum(PIPLedger),
sum(IME),
sum(WorkersComp),
sum(ConfClient),
sum(ConfAdjuster),
sum(ConfDoctor),
sum(TeleConfClient),
sum(HelpingPeople),
sum(Counts_ConfClient_Through_HPeople)
FROM #WKM_PLS_TEMP
end