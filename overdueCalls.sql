SELECT * FROM
(
SELECT DISTINCT cases.casenum AS "Casenum",
cases.staff_1 AS "Staff_1",
cases.case_title AS "Title", 
cases.date_of_incident AS "DOI",
sp_first_party(cases.casenum) AS "Client",
cases.matcode AS "Matcode",
negotiation.kind AS "Kind",
ROW_NUMBER() over(partition by cases.casenum order by cases.casenum) as rn
FROM cases 
LEFT JOIN case_checklist ON cases.casenum = case_checklist.case_id
LEFT JOIN negotiation ON case_checklist.case_id = negotiation.case_id
WHERE (cases.matcode IN ('GPI', 'S&amp;F', 'MVA')
AND case_checklist.code='212' AND case_checklist.status='Open')
AND cases.open_status='O'
AND cases.case_date_9 IS NULL
AND negotiation.Kind='Atty Call Made'
AND negotiation.neg_date&lt;=DATEADD(day, -30, today())
AND cases.casenum NOT IN (
    SELECT cases.casenum FROM cases
    LEFT JOIN negotiation ON cases.casenum=negotiation.case_id
    WHERE cases.open_status='O'
    AND negotiation.kind='Atty Call Made'
    AND cases.case_date_9 IS NULL
    AND negotiation.neg_date&gt;=DATEADD(day, -30, today())
    )
AND cases.casenum NOT IN (
    SELECT cases.casenum from cases
    left join negotiation on cases.casenum=negotiation.case_id
    where cases.open_status='O'
    and negotiation.kind='Atty Note'
    AND negotiation.neg_date&gt;=DATEADD(day, -30, today())
    )
GROUP BY Casenum, Staff_1, Title, DOI, Client, Matcode, Kind
ORDER BY Staff_1
) a
WHERE rn = 1
