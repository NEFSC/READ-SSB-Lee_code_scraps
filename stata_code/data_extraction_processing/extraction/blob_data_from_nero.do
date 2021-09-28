#delimit;
clear;
macro drop _all;
set more off;
pause on;
/*MIN-yang's bit to connect to oracle and set up home directory */  
quietly do "/home/mlee/Documents/Workspace/technical folder/do file scraps/odbc_connection_macros.do";
global oracle_cxn "conn("$mysole_conn") lower";




#delimit cr
/* Pretend I have a dataset with "filename" and _n is relatively small (4M characters allowed in a macro)*/
clear
set obs 2
gen imgid=873853
replace imgid=873819 in 2
gen data=runiform()

levelsof imgid, local(mytrips) separate(,)


preserve


local ratsql1 "select i.docid, blob.imgid, blob.image_blob from avtr.image_scan_blob blob, images i where i.docid in (`mytrip') and i.imgid=blob.imgid;"


#delimit ;
odbc load,  exec("`ratsql1'") dsn("cuda") user(mlee) password($mynero_pwd) lower clear;


tempfile t1;

save `t1';
restore;
merge m:1 tripid using `t1';







/*THIS IS HOW TO WRITE THE FILES*/

quietly count;
local myobs =r(N);
local mylocation "/home/mlee/Documents/projects/spacepanels/scallop/image_checkers";

gen q=0;
quietly forvalues i=1/`myobs'{;
	local myperm=permit[`i'];
	local mytripid=tripid[`i'];

replace q=filewrite("`mylocation'/GARFO/P`myperm'_T`mytripid'.tif",image_blob[`i']);
};


