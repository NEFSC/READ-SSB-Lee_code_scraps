/* Set up the mata program */
clear all
do "/home/mlee/Documents/Workspace/technical folder/do file scraps/mata/sppips.do"


/* Read polygon 1 into mata*/


/* read the "data" for each of the HMAs into mata */

cd "/home/mlee/Documents/Herring PDT work/fw3"
use "/home/mlee/Documents/Herring PDT work/fw3/HMAs/HMA_coords.dta"

levelsof _ID, local(myv)
local mycounter=0
foreach v of local myv {
	preserve 
	keep if _ID==`v'
	putmata myPoly`v'=(_X _Y)
	restore
	local ++mycounter
}

/* There are `mycounter'=4 distinct _IDs in HMA_coords. Now I have mycounter=4 matrices which are Rx2 in mata. */

/* next step is to send the point data into mata: that's not hard */
/* put point dataset into memory*/
use "/home/mlee/Documents/Herring PDT work/fw3/herring_landings_and_trip_chars_by_gearid2.dta"
putmata tgid lon lat

/* initialize a matrix that has rows=size of tgid and columns equal to number of areas, and entries=0*/
timer clear
timer on 1
mata
pip_results=J(rows(tgid),`mycounter',0)

/* After that, I need to loop through the point data and run the sp_pips program */

/*I haven't figured out how to nicely loop over the four myPoly matrices.*/

for (i=1; i<=rows(tgid); i++) {
if (lat[i]~=0 & lon[i]~=0){

	pip_results[i,5]=sp_pips(lon[i], lat[i],myPoly5) 
	pip_results[i,4]=sp_pips(lon[i], lat[i],myPoly4) 
	pip_results[i,2]=sp_pips(lon[i], lat[i],myPoly2)
	if (pip_results[i,2]==0 & pip_results[i,4]==0 & pip_results[i,5]==0 ){
	pip_results[i,1]=sp_pips(lon[i], lat[i],myPoly1) 
	}
	if (pip_results[i,1]==0 & pip_results[i,2]==0 & pip_results[i,4]==0 & pip_results[i,5]==0 ){
	pip_results[i,3]=sp_pips(lon[i], lat[i],myPoly3) 
}
}
}
end

timer off 1
timer list


/* This exports 4 variables from mata to stata. the sj variables are zero if the point is outside the HMA. It is positive if the point is inside the HMA.*/
getmata (SJ*)=pip_results

/* check that everything is in an area, with some exceptions for lat=0 and lon=0 */
gen str4 HMA="none" 
replace HMA= "1A" if SJ1>=1
replace HMA= "3" if SJ2>=1
replace HMA= "2" if SJ3>=1
replace HMA= "1B" if SJ4>=1
replace HMA= "3" if SJ5>=1

save "/home/mlee/Documents/Herring PDT work/fw3/herring_landings_and_trip_chars_by_gearid3.dta", replace




