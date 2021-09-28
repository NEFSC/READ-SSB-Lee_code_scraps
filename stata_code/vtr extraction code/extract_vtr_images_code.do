
pause on
cd "/home/mlee/Desktop/vtrs"
quietly do "/home/mlee/Documents/Workspace/technical folder/do file scraps/odbc_connection_macros.do"

/* I have a dataset with dbyear and tripid. I should also drop duplicate ("permit-dbyear-tripids") I need to loop over the dbyears, and make a local of tripids. The, I need to pull out the "filenames" from VESLOG G (renaming as "imgid")

Then I need to assemble the dataset of dbyear, tripid, and imgid. Then I need to pull out all the "images" from avtr corresponding to that imgid and stick it in a tripid 
*/


#delimit ;


use images_nero.dta, replace;
drop image_blob;
sort imgid;
save images_nero.dta, replace;



/*comment this out later---randomly select 20 per year*/
gen p=runiform();
sort dbyear p;
tab dbyear;
bysort dbyear (p): keep if _n<=20;
count;


global chunks 200;
qui count;
global myloops=r(N);
global myloops=ceil($myloops/$chunks);

forvalues ch=1/$myloops{;

	use images_nero.dta, replace;
	local lower=(`ch'-1)*$chunks+1;
	local upper=`ch'*$chunks;
	keep if _n>=`lower' & _n<=`upper';
	qui levelsof imgid, local(myloc) separate(,);
	#delimit cr
	local ratsql1 "select * from avtr.image_scan_blob where imgid in(`myloc');" 
	#delimit ;
	tempfile imgs;
	local NEWimgs `"`NEWimgs'"`imgs'" "'  ;
	clear;
	odbc load,  exec("`ratsql1'") dsn("cuda") user(mlee) password($mynero_pwd) lower clear;
	
	quietly count;
	scalar pp=r(N);
	if pp==0{;
		set obs 1;
	};
	else{;
	};
	save `imgs';
};
dsconcat `NEWimgs';
gen str source="nero";

tempfile t1;
save `t1', replace;




use images_nero, clear;

merge m:1 imgid using `t1';
/* This drop statement looks a little strange. If the query makes an empty dataset, I set the observations to 0. This is creating the "mis-merge"*/
drop if _merge==2;
rename _merge mergeblob;
save images_nero, replace;

/*
use images_local;
append using images_nero;
*/
/*

append using images_local;

use veslog_species_research2.dta, replace;
merge 1:m tripid dbyear using "images_nero.dta";
drop _merge;
drop mergeblob;
save images_final, replace;

*/

/*
qui summ;
global count=r(N);
gen out=0;
cd "/vtr_images";
forvalues i=1/$count{;
local perm=permit[`i'];
local trip=tripid[`i'];
replace out=filewrite("P`perm'_T`trip'.pdf", image_blob) if _n==`i' & image_blob~="";
};



*/
