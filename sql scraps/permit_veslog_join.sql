
/* This code associates a "tripid-permit" combination with the CATEGORY of Herring Permit */
/* This can produce "null" values for Herring Categories if a "tripid-permit" did not hold  a HERRING Permit*/
/* Min-Yang.Lee <Min-Yang.Lee@noaa.gov>*/
/* Version 1.1 */



/* This way involves writing 2 queries */
/* Part 1.  create a table called myperms which holds the permit data which I am interested in.  I used HER and HRG because the name of this plan changed when the fishery switched from OA to LA. */
 create table myperms as select vp_num, plan, cat, start_date, end_date from vps_fishery_ner where plan in ('HER', 'HRG') and ap_year>=2002;



/* Part 2 Select data from veslogXXXXT, and do a left outer join to 'myperms' based on landed date, start_date and end_date fields
A few notes:
1.  The left outer join is used to make sure that any entries in VESLOG are retained if a vessel did not hold a herring permit.
2.  "Duplicates" are possible if a vessel has a "combination" permit.  In the herring fishery, some vessels hold B & C category permits at the same time.  I decided to deal with this in Stata because my SQL skills aren't that great.
3.  Start_date and end_date are not "perfect" in vps_fishery_ner.  
	3a. There are 809 entries in vps_fishery_ner with "null" start_dates and 14 with null end_dates.  All are from before 2001. 
	3b. Be aware of the time in the date fields. 
		If a permit ends on April 30, it ends at midnight (00:00:00) on April 30.
		The next permit might start at midnight on May 1.  
		Therefore, there is a 24 hour gap from 00:00:01 April30 to 23:59:59 April30. 
		I chose to handle this by using the 'to_date' function. You could also use the trunc() function.
	3c. I believe that an active "plan-cat" combination will have only 1 entry.  That is, if a vessel has a cancelled permit, there are no overlapping periods (See vp_num 102030 and ap_year 2011 for an example).
4.  "Between A and B" is mathematically defined as "greater than or equal to A" and "less than or equal to B"
*/


select t.permit, t.tripid, t.datelnd1, v.plan, v.cat, v.start_date, v.end_date  from veslog2010t t 
	left outer join myperms v
	on t.permit=v.vp_num and to_date(t.datelnd1, 'DD-MON-YYYY') between to_date(v.start_date,'DD-MON-YYYY') and to_date(v.end_date,'DD-MON-YYYY')  
		where t.tripid in 
			(select  distinct  tripid from veslog2010s where sppcode like '%HERR%' ) 



/* There are 1990 entries, of which 1849 had a HRG permit and the remainder did not. */
/* There are 51 'duplicated' permit-tripid-datelnd1 combinations.  These correspond to combination B/C permit holders */


/*Alternatively, this can be done in a single step, although this is a bit harder to follow. */



select t.permit, t.tripid, t.datelnd1, v.plan, v.cat, v.start_date, v.end_date  from veslog2010t t 
	left outer join (select vp_num, plan, cat,   start_date,  end_date from vps_fishery_ner where plan in ('HER', 'HRG') and ap_year>=2002)  v
	on t.permit=v.vp_num and to_date(t.datelnd1, 'DD-MON-YYYY') between to_date(v.start_date,'DD-MON-YYYY') and to_date(v.end_date,'DD-MON-YYYY')  
		where t.tripid in 
			(select  distinct  tripid from veslog2010s where sppcode like '%HERR%' ) order by permit , tripid;






