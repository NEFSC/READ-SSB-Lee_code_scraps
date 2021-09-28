/* This file is a generic template that modifies date and time files */
/* Here is a good way to do it.  smash together, then convert.  First check for errors */
replace trip_start_time="00:00" if missing(trip_start_time)==1
replace trip_end_time="23:59" if missing(trip_end_time)==1

gen str20 newvar1=trip_start_date +" " +  trip_start_time
gen str20 newvar2=trip_end_date +" " +  trip_end_time

gen double mystart=clock(newvar1, "MDYhm")
gen double myend=clock(newvar2, "MDYhm")

format mystart %tc
format myend %tc

drop newvar newvar2


/*here is one way to do it...convert the date to statadate format.  Then convert the hours and minutes.  Then smash together*/
gen mystart=date(trip_start_date,"MDY")
format mystart %td
gen myend=date(trip_end_date,"MDY")
format myend %td

gen starthour=substr(trip_start_time ,1,2)
destring starthour, gen(mystarthour)
replace mystarthour=0 if mystarthour==.

gen startmin=substr(trip_start_time ,-2,.)
destring startmin, gen(mystartmin)
replace mystartmin=0 if mystartmin==.

drop starthour startmin


gen endhour=substr(trip_end_time ,1,2)
destring endhour, gen(myendhour)
replace myendhour=0 if myendhour==.

gen endmin=substr(trip_end_time ,-2,.)
destring endmin, gen(myendmin)
replace myendmin=0 if myendmin==.

drop endhour endmin




/* HERE IS ANOTHER WAY*/

gen starthour=floor(timesail/100)
gen startmin=mod(timesail,100)

gen endhour=floor(timelnd1/100)
gen endmin=mod(timelnd1,100)

gen startstring=datesail+ " " + string(starthour) + ":" + string(startmin)
gen endstring=dateland+ " " + string(endhour) + ":" + string(endmin)
gen double mystart=clock(startstring, "DM20Yhm")
gen double myend=clock(endstring, "DM20Yhm")
format mystart %tc
