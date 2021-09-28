
pause off
quietly do "/home/mlee/Documents/Workspace/technical folder/do file scraps/odbc_connection_macros.do"
local solesql "select * from vlsppsyn;"
local novasql "select * from area;"
cd "/home/mlee/Desktop/"
#delimit cr

/* I have a dataset with imgid*/
use "/run/user/1877/gvfs/smb-share:server=net,share=home2/aharris/port_corrections/missing_images_Aug20.dta" , clear
tempfile loudata
drop if image_blob~=""
drop image_blob source extension retrieved 

save `loudata'

qui levelsof imgid, local(myloc) separate(,)

local ratsql1 "select * from avtr.image_scan_blob where imgid in(`myloc');" 
#delimit ;
clear;
odbc load,  exec("`ratsql1'") dsn("cuda") user(mlee) password($mynero_pwd) lower clear;

merge 1:1 imgid using `loudata';
drop placenm-namelsad;
	drop _merge;
save "/run/user/1877/gvfs/smb-share:server=net,share=home2/mlee/carr_harris/data cleaning/updated_images_Aug20.dta", replace;
/*
qui summ;
global count=r(N);

gen out=0;
forvalues i=1/$count{;
local filename=imgid[1];
replace out=filewrite("imgid_`filename'.pdf", image_blob) if _n==`i' & image_blob~="";
*/
