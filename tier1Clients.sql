select casenum, 
matcode as casetype, 
date_opened, 
sp_first_party(casenum) as client, 
sp_name(referred_link,1) as referrer,
(select
  count(sp_name(referred_link,1))
  from cases
  where sp_name(referred_link,1) = referrer
  --and date_opened&gt;='##STARTDATE##' 
  --and date_opened&lt;='##ENDDATE##'
  group by cases.referred_link
) as num_refs,
(case when mailing_list is null then 'No' else 'Yes' end) as old_mattar_star, 
'repeat client' as reason 
from cases
inner join party on cases.casenum=party.case_id
left join (select * from mailing_list_defined where mailing_list='Mattar Stars') a on party.party_id=a.names_id
where party.role='Plaintiff' 
and party.our_client='Y' 
and date_opened&gt;='##STARTDATE##' 
and date_opened&lt;='##ENDDATE##'
and cases.case_date_6 is null
and party.party_id IN 
  (select 
    party_id 
    from 
      (select 
        count(casenum) as casecount, 
        party_id 
        from cases
        inner join party on cases.casenum=party.case_id
        where party.role='Plaintiff' 
        and party.our_client='Y'
        and matcode IN ('PMV','MVA','IMV','GPI','IGP','S%F','ISF')
        group by party_id) multicases
        where multicases.casecount>=2)
group by cases.referred_link, cases.casenum, cases.matcode, date_opened, mailing_list
UNION ALL
select casenum, 
matcode, 
date_opened, 
sp_first_party(casenum) as client, 
sp_name(referred_link,1) as referrer, 
count(sp_name(referred_link,1)) as num_refs,
(case when mailing_list is null then 'No' else 'Yes' end) as old_mattar_star, 
'personal referrer' as reason  
from cases 
inner join names on cases.referred_link=names.names_id
left join (select * from mailing_list_defined where mailing_list='Mattar Stars') a on names.names_id=a.names_id
left join provider on names.names_id=provider.name_id
left join party on cases.casenum=party.case_id 
where names.person='Y' 
and date_opened&gt;='##STARTDATE##' 
and date_opened&lt;='##ENDDATE##' 
and party.our_client='Y' 
and party.role='Plaintiff' 
and party.party_id != referred_link
and ((code not like '%Attorney%' and code not like '%Established%' and code not like '%Doctor%' and code not like '%Chiropractor%') or provider.code is null) 
and matcode in ('PMV','IMV','MVA','S%F', 'ISF', 'GPI', 'IGP')
group by cases.referred_link, casenum, cases.matcode, date_opened, mailing_list
order by num_refs desc, date_opened asc