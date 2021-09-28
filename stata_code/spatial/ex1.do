/* code to follow along with the help on spregress in stata 15 */


clear
global wd "C:/Users/Min-Yang.Lee/Documents/technical/do file scraps/spatial/tl_2016_us_county"

cd "$wd"

/* run once 
spshape2dta tl_2016_us_county 
copy http://www.stata-press.com/data/r15/texas_ue.dta .


use tl_2016_us_county, clear

generate long fips = real(STATEFP + COUNTYFP)
bysort fips: assert _N==1
assert fips != .

spset fips, modify replace

spset, modify coordsys(latlong, miles)
save tl_2016_us_county, replace
use "${wd}/tl_2016_us_county/tl_2016_us_county.dta", clear

*/




use "${wd}/texas_ue.dta", clear
desc
merge 1:1 fips using "${wd}/tl_2016_us_county.dta"
keep if _merge==3
count
browse
scatter _CX _CY
scatter _CY _CX
rename NAME countyname


drop STATEFP COUNTYFP COUNTYNS GEOID _merge
 drop NAMELSAD LSAD CLASSFP MTFCC CSAFP
 drop CBSAFP METDIVFP FUNCSTAT
 drop ALAND AWATER INTPTLAT INTPTLON
 
 grmap unemployment
 
 regress unemployment college
 
 spmatrix create contiguity W, replace
 
 spregress unemployment college, gs2sls dvarlag(W)
 
 spregress unemployment college, gs2sls ivarlag(W: college)
 
 estat impact
