/* this do file fragment takes the file img_source.dta and writes the pdfs in "image_blob" to pdfs*/
#delimit;
use img_source.dta;
sort permit dbyear tripid;
qui summ;
global count=r(N);
gen out=0;
cd "/vtr_images"; /*change the directory to a reasonable directory */
forvalues i=1/$count{;
local perm=permit[`i'];
local trip=tripid[`i'];
replace out=filewrite("P`perm'_T`trip'.pdf", image_blob) if _n==`i' & image_blob~="";
};
