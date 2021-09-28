quietly do "/home/mlee/Documents/Workspace/technical folder/do file scraps/odbc_connection_macros.do"
local solesql "select * from vlsppsyn;"
local novasql "select * from area;"
local ratsql "select * from avtr.image_scan_blob where imgid in (select distinct filename from veslog1998g@sole where tripid in (873853, 873819, 873853));"
local ratsql1 "select * from avtr.image_scan_blob where imgid in(`myloc');"

#delimit;
/*test nero */
/*
/* for some reason I can't use the normal "conn" string to connect to nero. I think it's a "wildcard" issue*/
odbc load,  exec("`ratsql'") dsn("cuda") user(mlee) password($mynero_pwd) lower clear;

gen p=.;

cd "/home/mlee/Desktop";

qui count;
global count=r(N);

forvalues i=1/$count{;
replace p=filewrite("mine`i'.pdf",image_blob);
};
*/
*gen p=filewrite("mine.pdf",image_blob);
*assert p~=0;
*assert p ~=.;
*shell rm "mine.pdf";

#delimit cr
/* Pretend I have a dataset with "filename" and _n is relatively small (4M characters allowed in a macro)
select * from veslog2001g where gearid in (1423345, 1423350,1416319);

*/
clear
set obs 3
gen imgid=1423345
replace imgid=1423350 in 2
replace imgid=1416319 in 3
gen data=runiform()








levelsof imgid, local(myloc) separate(,)
preserve


local ratsql1 "select * from avtr.image_scan_blob where imgid in(`myloc');"
#delimit ;
odbc load,  exec("`ratsql1'") dsn("cuda") user(mlee) password($mynero_pwd) lower clear;

tempfile t1;

save `t1';
restore;
merge m:1 imgid using `t1';

/* THIS PART WRITE THE FILES TO PDFs, USING THE IMGID/GEARID as a FILE NAME */
qui count;
global count=r(N);
gen p=.;
forvalues i=1/$count{;
local myi=imgid[`i'];
replace p=filewrite("`myi'.tif",image_blob) if _n==`i';
};

