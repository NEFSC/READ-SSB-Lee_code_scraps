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
keep if _n<=5
putmata tgid lon lat

/* initialize a matrix that has rows=size of tgid and columns equal to number of areas, and entries=0*/
mata
pip_results=J(rows(tgid),`mycounter',0)
/*
for (i=1; i<=rows(tgid); i++) {
	sp_pips(lon[i], lat[i],myPoly3)
}
*/

for (i=1; i<=4; i++) {
	sp_pips(lon[2], lat[2],myPoly`i')
}
end

/* After that, I need to loop through the point data and run the sp_pips program */



/*
real scalar sp_pips(real scalar x, real scalar y, real matrix POLY)
*/

/* check that everything is in an area, with some exceptions for lat=0 and lon=0 */
macro list
