
pause on

use "/home/mlee/Documents/projects/spacepanels/scallop/data_lock_june17/veslog_species_huge.dta", clear



gen missing_port_tag=1 if namelsad==""
summ(missing_port_tag) 
keep if missing_port_tag==1
save "/home/mlee/Desktop/vtrs/veslog_species_research.dta", replace
drop if tripid==.
dups permit tripid dbyear portlnd1 state1, drop terse
keep permit tripid dbyear portlnd1 state1 date

save "/home/mlee/Desktop/vtrs/veslog_species_research2.dta", replace


quietly do "/home/mlee/Documents/Workspace/technical folder/do file scraps/odbc_connection_macros.do"
local solesql "select * from vlsppsyn;"
local novasql "select * from area;"
#delimit cr

cd "/home/mlee/Desktop/vtrs"

/* I have a dataset with dbyear and tripid. I should also drop duplicate ("permit-dbyear-tripids") I need to loop over the dbyears, and make a local of tripids. The, I need to pull out the "filenames" from VESLOG G (renaming as "imgid")

Then I need to assemble the dataset of dbyear, tripid, and imgid. Then I need to pull out all the "images" from avtr corresponding to that imgid and stick it in a tripid 

*/
use "/home/mlee/Desktop/vtrs/veslog_species_research2.dta", replace
/*
comment this out later---randomly select 20 per year
gen p=runiform()
sort dbyear p
tab dbyear
bysort dbyear (p): keep if _n<=20
count
*/

levelsof dbyear, local(myyear) 


#delimit ;
save veslog_species_research2, replace;

quietly foreach yr of local myyear{;

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
		odbc load,  exec("select g.tripid, g.serial_num, to_char(g.filename) as imgid, g.sideid, t.portlnd1, t.state1, t.datelnd1, t.permit, g.imgtype from vtr.veslog`yr'g g, vtr.veslog`yr't t where g.tripid in (`trips') and t.tripid=g.tripid;") conn("$mysole_conn") lower;
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
	use veslog_species_research2, replace;
};


dsconcat `NEWfiles9';

/*these vtrs were entered using the FVTR system and therefore will have no images */
	drop if strmatch(imgid,"FVTR");
	renvarlab, lower;
	compress;

save img_source.dta, replace;



/* THIS BIT OF CODE IS USED TO GRAB THE FILES OFF OUR NETWORK */
/*assemble the file names and directories */
gen extension=lower(sideid);
gen str full_file= imgid + "." + extension;



/* Clean up directory naming
1.  X01 through X05 map to img1 to img5
2.  img7-8
3.  img10-12
4.  don't know what happened to img9 or img6
*/
pause;
egen p=sieve(sideid), omit(X);
gen str8 directory= "img"+p;
replace directory="img1" if strmatch(directory, "img01");
replace directory="img2" if strmatch(directory, "img02");
replace directory="img3" if strmatch(directory, "img03");
replace directory="img4" if strmatch(directory, "img04");
replace directory="img5" if strmatch(directory, "img05");

replace directory="img7-8" if strmatch(directory, "img07");
replace directory="img7-8" if strmatch(directory, "img08");

replace directory="img10-12\img10" if strmatch(directory, "img10");
replace directory="img10-12\img11" if strmatch(directory, "img11");
replace directory="img10-12\img12" if strmatch(directory, "img12");

drop p;
sort permit dbyear serial_num;
/* loop over the "full_files".  Copy them from the network into our working directory.  give them the name PPPPPP_SSSSSSSS.tif*/

quietly count;
local myobs =r(N);



gen retrieved=0;
quietly count;
local myobs =r(N);

gen strL image_blob=" ";

quietly forvalues i=1/`myobs'{;
	local serverdir=directory[`i'];
	local serverfile=full_file[`i'];
	local myperm=permit[`i'];
	local myserial=serial_num[`i'];
	capture confirm file "/run/user/1877/gvfs/smb-share:server=net,share=permit_img/`serverdir'/`serverfile'";
	if _rc==0{;
	replace image_blob=fileread("/run/user/1877/gvfs/smb-share:server=net,share=permit_img/`serverdir'/`serverfile'") if _n==`i';
	replace retrieved=1 if _n==`i';
	};
	else{;
	display "the file `i' is missing";
	};
	else;
};
drop sideid ;
order permit tripid serial_num dbyear;
sort permit tripid serial dbyear;
drop full_file directory;

destring imgid, replace;

gen str source="local";

tempfile t11;
save `t11';

keep if retrieved==0;
drop source;
save images_nero.dta, replace;


use `t11', clear;

keep if retrieved==1;
save images_local.dta, replace;



