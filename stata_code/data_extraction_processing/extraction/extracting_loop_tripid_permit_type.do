cd "/home/mlee/Documents/Workspace/technical folder/do file scraps"

/* ORACLE SQL IN UBUNTU using Stata's connectstring feature.*/



clear
#delimit ;

/* Here are the 'boring things' -- I've stored the connection strings and the components of them in a local*/
local mydriver `"Driver={/usr/lib/oracle/10.2.0.5/client/lib/libsqora.so.10.1}"';
local mysole "Dbq=sole";
local mynova "Dbq=nova";
local myuid "uid=mlee";
local mypwd "pwd=abcd1234";

/*Temporarily set the delimiter to "carriage return" so that I can assemble the connection strings to pass to odbc */
#delimit cr
local mysole_conn `mydriver'; `mysole'; `myuid'; `mypwd'
local mynova_conn `mydriver'; `mynova'; `myuid'; `mypwd'

#delimit ;


/* Read in data from SOLE
odbc load,  exec("<YOUR COMMAND GOES HERE>") conn("`mysole_conn'") lower;
*/

/* Read in data from NOVA
odbc load,  exec("<YOUR COMMAND GOES HERE>") conn("`mynova_conn'") lower;
*/




/*I've selected tripid from veslogT and plan and cat from vps_fishery_ner and matched on permit number and datelnd1 being between the permit start date and the permit end date. 
In theory, this should give me the vessel's portfolio of permits for each tripid without duplicates. 
However, there are some entries which are duplicated. See AP_NUMS 1173155 and 1177044 for example.
So, after running, this ODBC Load, clean out duplicate tripid, plan, cat combinations.

In addition, there may be tripids with no plans.  Set these plans equal to "NONE" and categories equal to "NONE"
*/
local first= 2004;
local last= 2012;
local second= `first'+1; /* don't change this local*/
local schema "veslog";
local prefix "tripids_plans";

forvalues yr =`first'/`last'{;
	clear;
	odbc load,  exec("select t.tripid, vps.plan, vps.cat from `schema'`yr't t
	left outer join vps_fishery_ner vps ON
	t.permit=vps.vp_num AND
	trunc(t.datelnd1) between trunc(vps.start_date) and trunc(vps.end_date);")
	conn("`mysole_conn'") lower;
	
	/* fill in tripids which do not have an associated plan and cat */
	replace cat="NON" if strmatch(plan, "")==1;
	replace plan="NON" if strmatch(plan, "")==1;
	dups tripid plan cat, drop terse;
	drop _expand;

	gen plan_cat=plan+ "_"+cat;
	drop plan cat;
	gen valid=1;
	reshape wide valid, i(tripid) j(plan_cat) string; 

	/* replace nulls with zeros */
	foreach var of varlist valid*{;
		quietly replace `var'=0 if `var'==.;
	};
	save "`prefix'_`yr'.dta", replace;
};
use "`prefix'_`first'.dta", replace;
/* Appending loop */
forvalues yr=`second'/`last' {;
	append using "`prefix'_`yr'.dta";
};
	compress;

save "`prefix'.dta", replace;

/* delete the temporary files*/
forvalues yr=`first'/`last' {;
	erase "`prefix'_`yr'.dta";
};




