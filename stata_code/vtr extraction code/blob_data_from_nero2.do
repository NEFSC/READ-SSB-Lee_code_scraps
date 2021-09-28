
pause off
quietly do "/home/mlee/Documents/Workspace/technical folder/do file scraps/odbc_connection_macros.do"
local solesql "select * from vlsppsyn;"
local novasql "select * from area;"
cd "/home/mlee/Desktop/"
#delimit cr
/* I have a dataset with dbyear and tripid. I should also drop duplicate ("permit-dbyear-tripids") I need to loop over the dbyears, and make a local of tripids. The, I need to pull out the "filenames" from VESLOG G (renaming as "imgid")

Then I need to assemble the dataset of dbyear, tripid, and imgid. Then I need to pull out all the "images" from avtr corresponding to that imgid and stick it in a tripid 

*/
cd "/home/mlee/Desktop"
use tester.dta, replace
dups permit tripid dbyear, drop

/*comment this out later---randomly select 20 per year
gen p=runiform()
sort dbyear p
tab dbyear
bysort dbyear (p): keep if _n<=6
count
 */

levelsof dbyear, local(myyear) 


#delimit ;
save original_holder, replace;

qui foreach yr of local myyear{;

	keep if dbyear==`yr';
	di `yr';
	
	global chunks 900;
	qui count;
	global myloops=r(N);
	global myloops=ceil($myloops/$chunks);
		forvalues ch=1/$myloops{;
		tempfile new9;
		local NEWfiles9 `"`NEWfiles9'"`new9'" "'  ;
		preserve;
		local lower=(`ch'-1)*$chunks+1;
		local upper=`ch'*$chunks;
		keep if _n>=`lower' & _n<=`upper';
		levelsof tripid, local(trips) separate(,);
		clear;
		odbc load,  exec("select tripid, serial_num, filename as imgid from vtr.veslog`yr'g where tripid in (`trips');") conn("$mysole_conn") lower;
		quietly count;
		scalar pp=r(N);
			if pp==0{;
			set obs 1;
			};
			else{;
			};
		gen dbyear=`yr';      
		quietly save `new9';
		restore;
	};
	clear;
	use original_holder, replace;
};


dsconcat `NEWfiles9';

/*these vtrs were entered using the FVTR system and therefore will have no images */
	drop if strmatch(imgid,"FVTR");
	renvarlab, lower;
	destring, replace;
	compress;

save img_source.dta, replace;
pause;
sort imgid;
global chunks 200;
qui count;
global myloops=r(N);
global myloops=ceil($myloops/$chunks);

forvalues ch=1/$myloops{;

	use img_source.dta, replace;
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

tempfile t1;
save `t1', replace;






use img_source, clear;

merge m:1 imgid using `t1';
/* This drop statement looks a little strange. If the query makes an empty dataset, I set the observations to 0. This is creating the "mis-merge"*/
drop if _merge==2;

rename _merge merge_blob;
save img_source, replace;

use original_holder.dta, replace;
keep permit tripid dbyear ;
merge 1:m tripid dbyear using "img_source.dta";
drop _merge;
drop merge_blob;
save img_source, replace;



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
