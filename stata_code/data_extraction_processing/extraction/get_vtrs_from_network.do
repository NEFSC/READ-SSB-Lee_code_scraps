/* VTR Extraction code from the "network" */


/********************************************************************/
/********************************************************************/
/*If we don't need to actually get the image files, we can comment this out. */
/********************************************************************/
/********************************************************************/





/* OLD METHOD */
/* You need a dataset with permit serial_num full_file directory sideid;*/
/* loop over the "full_files".  Copy them from the network into our working directory.  give them the name PPPPPP_SSSSSSSS.tif*/

/* I've set the variable retrieved =1 when the file is retrieved.
I run "capture confirm" before copying. This checks to see if the file exists. If the file exists, it is copied and "retrieved" is set to zero.  Otherwise, nothing happens.
This prevents the loop from breaking.
*/
#delimit ;
keep if _n<=30;
gen retrieved=0;
quietly count;
local myobs =r(N);


/*assemble the file names and directories */
gen extension=lower(sideid);
gen full_file= filename + "." + extension;



/* Clean up directory naming
1.  X01 through X05 map to img1 to img5
2.  img7-8
3.  img10-12
4.  don't know what happened to img9 or img6
*/
egen p=sieve(sideid), omit(X);
gen str8 directory= "img"+p;
replace directory="img1" if strmatch(directory, "img01");
replace directory="img2" if strmatch(directory, "img02");
replace directory="img3" if strmatch(directory, "img03");
replace directory="img4" if strmatch(directory, "img04");
replace directory="img5" if strmatch(directory, "img05");
replace directory="img7-8" if strmatch(directory, "img07");
replace directory="img7-8" if strmatch(directory, "img08");
replace directory="img7-8/img8" if strmatch(directory, "img08");
replace directory="img10-12/img10" if strmatch(directory, "img10");
replace directory="img10-12/img11" if strmatch(directory, "img11");
replace directory="img10-12/img12" if strmatch(directory, "img12");

replace directory="img7-8/img8" if strmatch(extension, "x08");





/* BEFORE YOU CAN RUN THIS CODE, You need to makes sure that the symbolic link in '/home/mlee/mounts/permit_img' works.
open up nautlius, and connect to smb://net/permit_img
THen got to /home/mlee/mounts. the permit_img symlink should be working  THen you can run this code.
*/
quietly forvalues i=1/`myobs'{;
	local serverdir=directory[`i'];
	local serverfile=full_file[`i'];
	local myperm=permit[`i'];
	local myserial=serial_num[`i'];
	capture confirm file "/home/mlee/mounts/permit_img/`serverdir'/`serverfile'";
	if _rc==0{;
	copy "/home/mlee/mounts/permit_img/`serverdir'/`serverfile'" "P`myperm'_S`myserial'.tif", replace;
	replace retrieved=1 if _n==`i';
	};
	else{;
	display "the file `i' is missing";
	};
	else;
};



drop sideid ;

/* NOTE: ON WINDOWS, the copy statement will be a bit different. I think the slashes will be reversed and you may have to use the drive letter that you mapped to 'net' 
so this might be something like:

    capture confirm file "U:/`serverdir'/`serverfile'";
    if _rc==0{;
    copy "U:/`serverdir'/`serverfile'" "P`myperm'_S`myserial'.tif", replace;
Where U is mapped to net\\permit_img 

*/



/* NEW METHOD 
Put it into the dataset as a strL
*/




/* You need a dataset with permit serial_num full_file directory sideid;*/

/* loop over the "full_files".  Copy them from the network into our working directory.  give them the name PPPPPP_SSSSSSSS.tif*/

/* I've set the variable retrieved =1 when the file is retrieved.
I run "capture confirm" before copying. This checks to see if the file exists. If the file exists, it is copied and "retrieved" is set to zero.  Otherwise, nothing happens.
This prevents the loop from breaking.
*/
#delimit ;
gen retrieved=0;
gen strL image=" ";

quietly count;
local myobs =r(N);


quietly forvalues i=1/`myobs'{;
	local serverdir=directory[`i'];
	local serverfile=full_file[`i'];
	capture confirm file "/home/mlee/mounts/permit_img/`serverdir'/`serverfile'";
	if _rc==0{;
	replace image=fileread("/home/mlee/mounts/permit_img/`serverdir'/`serverfile'") if _n==`i';
	replace retrieved=1 if _n==`i';
	};
	else{;
	display "the file `i' is missing";
	};
	else;
};
drop sideid ;

/* NOTE: ON WINDOWS, the copy statement will be a bit different. I think the slashes will be reversed and you may have to use the drive letter that you mapped to 'net' 
so this might be something like:

    capture confirm file "U:/`serverdir'/`serverfile'";
    if _rc==0{;
    copy "U:/`serverdir'/`serverfile'" "P`myperm'_S`myserial'.tif", replace;
Where U is mapped to net\\permit_img 

*/





/*THIS IS HOW TO WRITE THE FILES*/


quietly count;
local myobs =r(N);

gen q=0;
quietly forvalues i=1/`myobs'{;
	local myperm=permit[`i'];
	local myserial=serial_num[`i'];
	replace q=filewrite( "P`myperm'_S`myserial'.tif",image) if _n==`i';
};












