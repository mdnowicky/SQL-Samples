
begin

declare @startdate datetime, @enddate datetime
set @startdate=##STARTDATE##
set @enddate=##ENDDATE##

SELECT 
staff.staff_code as staff,
ts.CL_40_trials_sched,
ctt.CL_42_consent_to_trial,
scttr.CL_43_signed_consent_to_trial,
ctldm.CL_44_CTDL_drafted_mailed,
ed.CL_56_expert_disc_mailed,
tde.CL_59_draft_trial_expenses,
noi.CL_62_NOI_filed,
lcp.CL_63_LCP_requested,
cm.CL_64_client_meetings,
fs.CL_66_fee_sched_from_witness,
eptc.CL_69_witness_sched_PCT,
et.CL_70_witness_sched_trial,
smr.CL_72_subpeona_for_medrec,
smrs.CL_73_sumpeona_for_medrec_sent_fs,
dsd.CL_75_def_subpeonas_drafted,
dss.CL_76_def_subpeonas_sent,
fws.CL_78_fact_wit_subpeonas_drafted,
fwss.CL_79_FWS_sent_for_service,
js.CL_81_jud_sub_for_off_drafted,
jss.CL_89_jus_sub_sent_for_serv,
cplr.CL_83_CPLR_3122s_drafted,
tb.CL_84_trial_binders,
cd.ConfDoctor,
ce.ConfExpert,
inv.Investigation,
scc.SecondChairConversations,
ma.MaximizerAgenda,
tr.Trial

INTO #WKM_TS_Temp

FROM staff 


--Trials Scheduled
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_40_trials_sched FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T40' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) ts
ON staff.staff_code=ts.staff_assigned

--Consent to Trial
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_42_consent_to_trial FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T42' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) ctt
ON staff.staff_code=ctt.staff_assigned

--Signed consent to trial received back
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_43_signed_consent_to_trial FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T43' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) scttr
ON staff.staff_code=scttr.staff_assigned

--Client Trial Date Letters drafted and mailed
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_44_CTDL_drafted_mailed FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T44' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) ctldm
ON staff.staff_code=ctldm.staff_assigned

--Expert disclosures drafted and mailed to defense
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_56_expert_disc_mailed FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T56' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) ed
ON staff.staff_code=ed.staff_assigned

--Draft trial expenses drafted for attorney review
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_59_draft_trial_expenses FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T59' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) tde
ON staff.staff_code=tde.staff_assigned

--Draft trial expenses drafted for attorney review
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_62_NOI_filed FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T62' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) noi
ON staff.staff_code=noi.staff_assigned

--Draft trial expenses drafted for attorney review
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_63_LCP_requested FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T63' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) lcp
ON staff.staff_code=lcp.staff_assigned

--Client meetings scheduled with trial attorney
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_64_client_meetings FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T64' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) cm
ON staff.staff_code=cm.staff_assigned

--Fee schedules recd from expert witness
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_66_fee_sched_from_witness FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T66' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) fs
ON staff.staff_code=fs.staff_assigned

--Expert witness sched for PTC
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_69_witness_sched_PCT FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T69' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) eptc
ON staff.staff_code=eptc.staff_assigned

--Expert witness sched for trial
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_70_witness_sched_trial FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T70' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) et
ON staff.staff_code=et.staff_assigned

--Subpeona for medical records
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_72_subpeona_for_medrec FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T72' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) smr
ON staff.staff_code=smr.staff_assigned

--Subpeona for medical records
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_73_sumpeona_for_medrec_sent_fs FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T73' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) smrs
ON staff.staff_code=smrs.staff_assigned


--Defendant subpeonas drafted
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_75_def_subpeonas_drafted FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T75' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) dsd
ON staff.staff_code=dsd.staff_assigned


--Defendant subpeonas sent
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_76_def_subpeonas_sent FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T76' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) dss
ON staff.staff_code=dss.staff_assigned

--Fact witness subpeonas drafted
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_78_fact_wit_subpeonas_drafted FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T78' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) fws
ON staff.staff_code=fws.staff_assigned

--Fact witness subpeonas sent for service
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_79_FWS_sent_for_service FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T79' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) fwss
ON staff.staff_code=fwss.staff_assigned

--Judicial subpeonas for officers drafted
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_81_jud_sub_for_off_drafted FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T81' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) js
ON staff.staff_code=js.staff_assigned

--Judicial subpeonas sent for service
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_89_jus_sub_sent_for_serv FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T89' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) jss
ON staff.staff_code=jss.staff_assigned

--Notice to pursuant CPLR 3122's
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_83_CPLR_3122s_drafted FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T83' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) cplr
ON staff.staff_code=cplr.staff_assigned

--Trial binders completed
LEFT JOIN (
	SELECT case_checklist.staff_assigned, count(case_checklist.checklist_id) as CL_84_trial_binders FROM CASES 
	LEFT JOIN case_checklist ON cases.casenum=case_checklist.case_id
	WHERE case_checklist.code='T84' and case_checklist.status='Done'
	and cases.open_status='O'
	and case_checklist.date_of_modification&gt;=@startdate
	and case_checklist.date_of_modification&lt;=@enddate
	group by case_checklist.staff_assigned
	) tb
ON staff.staff_code=tb.staff_assigned

--Conf Doctor
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as ConfDoctor FROM case_notes
	WHERE case_notes.topic='Conf/Doctor'
	and note_date&gt;=@startdate
	and note_date&lt;=@enddate
	group by case_notes.staff_id
	) cd
ON staff.staff_code=cd.staff_id

--Conf Expert
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as ConfExpert FROM case_notes
	WHERE case_notes.topic='Conf/Expert'
	and note_date&gt;=@startdate
	and note_date&lt;=@enddate
	group by case_notes.staff_id
	) ce
ON staff.staff_code=ce.staff_id

--Investigation
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as Investigation FROM case_notes
	WHERE case_notes.topic='Investigation'
	and note_date&gt;=@startdate
	and note_date&lt;=@enddate
	group by case_notes.staff_id
	) inv
ON staff.staff_code=inv.staff_id

--Second Chair Conversations
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as SecondChairConversations FROM case_notes
	WHERE case_notes.topic='Second Chair Conversations'
	and note_date&gt;=@startdate
	and note_date&lt;=@enddate
	group by case_notes.staff_id
	) scc
ON staff.staff_code=scc.staff_id

--Maximizer Agenda
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as MaximizerAgenda FROM case_notes
	WHERE case_notes.topic='Maximizer Agenda'
	and note_date&gt;=@startdate
	and note_date&lt;=@enddate
	group by case_notes.staff_id
	) ma
ON staff.staff_code=ma.staff_id

--Trial
LEFT JOIN (
	SELECT case_notes.staff_id, count(case_notes.note_key) as Trial FROM case_notes
	WHERE case_notes.topic='Trial'
	and note_date&gt;=@startdate
	and note_date&lt;=@enddate
	group by case_notes.staff_id
	) tr
ON staff.staff_code=tr.staff_id


WHERE staff.job_title='Litigation' and staff.active='Y'

SELECT * FROM #WKM_TS_TEMP
UNION 
SELECT 'TOTALS:',
sum(CL_40_trials_sched),
sum(CL_42_consent_to_trial),
sum(CL_43_signed_consent_to_trial),
sum(CL_44_CTDL_drafted_mailed),
sum(CL_56_expert_disc_mailed),
sum(CL_59_draft_trial_expenses),
sum(CL_62_NOI_filed),
sum(CL_63_LCP_requested),
sum(CL_64_client_meetings),
sum(CL_66_fee_sched_from_witness),
sum(CL_69_witness_sched_PCT),
sum(CL_70_witness_sched_trial),
sum(CL_72_subpeona_for_medrec),
sum(CL_73_sumpeona_for_medrec_sent_fs),
sum(CL_75_def_subpeonas_drafted),
sum(CL_76_def_subpeonas_sent),
sum(CL_78_fact_wit_subpeonas_drafted),
sum(CL_79_FWS_sent_for_service),
sum(CL_81_jud_sub_for_off_drafted),
sum(CL_89_jus_sub_sent_for_serv),
sum(CL_83_CPLR_3122s_drafted),
sum(CL_84_trial_binders),
sum(ConfDoctor),
sum(ConfExpert),
sum(Investigation),
sum(SecondChairConversations),
sum(MaximizerAgenda),
sum(Trial)

FROM #WKM_TS_TEMP
end
