SELECT *, 
(a.googleCount+a.facebookCount+a.yelpCount+a.avvoCount+a.testimonialCount) as totalCount,

(SELECT AVG(c)
FROM   (SELECT a.googleStars
    UNION ALL
    SELECT a.facebookStars
    UNION ALL
    SELECT a.yelpStars
    UNION ALL
    SELECT a.avvoStars
    UNION ALL
    SELECT a.testimonialStars) T (c)) AS totalAvg2

FROM 
(SELECT cases.staff_1, 
avg(user_case_data.Google_#_of_Stars) as googleStars, 
avg(user_case_data.Facebook_#_of_Stars) as facebookStars,
avg(user_case_data.Yelp_#_of_Stars) as yelpStars, 
avg(user_case_data.AVVO_#_of_Stars) as avvoStars, 
avg(user_case_data.Testimonial_#_of_Stars) as testimonialStars,
count(user_case_data.Google_#_of_Stars) as googleCount, 
count(user_case_data.Facebook_#_of_Stars) as facebookCount,
count(user_case_data.Yelp_#_of_Stars) as yelpCount, 
count(user_case_data.AVVO_#_of_Stars) as avvoCount, 
count(user_case_data.Testimonial_#_of_Stars) as testimonialCount
FROM CASES
INNER JOIN user_case_data ON CASES.casenum=user_case_data.casenum
INNER JOIN staff on CASES.staff_2=staff.staff_code
WHERE staff.active='Y' and cases.close_date&gt;='##STARTDATE##' and cases.close_date&lt;='##ENDDATE##'
group by cases.staff_1) a 
WHERE NOT (a.googleStars is null and facebookStars is null and yelpStars is null
and avvoStars is null and testimonialStars is null) 
order by totalAvg2 desc