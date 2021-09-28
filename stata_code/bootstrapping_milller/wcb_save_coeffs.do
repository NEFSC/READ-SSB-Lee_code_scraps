#delimit ;
cd "/home/mlee/Documents/Workspace/technical folder/do file scraps/bootstrapping_milller";

version 14 ;

clear ;
set mem 5m ;
set more off ;
set seed 365476247 ;
pause on;
use collapsed ;
global bootreps 99;
capture keep year self has post post_self;

tempfile main bootsave;


*iid standard errors;
regress has self post post_self, cluster(year);

preserve;
mat m=e(b);
clear;
local names: colnames m;
local names: subinstr local names "_cons" "constant";
mat colnames m= `names';
svmat m, names(col);
gen replicate=0;
save results.dta, replace;


restore;

est store CRVE;
*When we cluster on year, CRSE is 0.0074;

global mainbeta = _b[post_self] ;
global maint = (_b[post_self]) / _se[post_self] ; 


*Predict residuals and fitted values;
predict epshat , resid;
predict yhat , xb ;

sort year self ;
qui save `main' , replace ;

/* Do the pairs cluster bootstrap-t */

/* You will want to 
save the results of the data to a temporary file and append.
*/
qui forvalues b = 1/$bootreps { ;
use `main', clear;

/* Do the wild cluster bootstrap-t*/

/* by cluster, assign postive and negative values for the residuals with equal probability (Rademacher weights) */
 by year: gen temp = uniform() ;
by year: gen resid_mul = 2*(temp[1] < .5)-1 ;

gen wildresid = epshat*resid_mul ;
gen wildy = yhat+ wildresid ;
reg wildy selfemployed post post_self , cluster(year) ;
mat m=e(b);
clear;
local names: colnames m;
local names: subinstr local names "_cons" "constant";
mat colnames m= `names';
svmat m, names(col);
gen replicate=`b';

append using results;
save results, replace;
};
/*

qui postclose bskeep;
clear;
set obs 1;
gen t_wild=$maint;
append using `bootsave';



qui gen n = . ;
foreach stat in t_wild { ;
qui summ `stat' ;
local bign = r(N) ;
sort `stat' ;
qui replace n = _n ;
qui summ n if abs(`stat' - $maint) < .000001 ;
local myp = r(mean) / `bign' ;
global pctile_`stat' = 2 * min(`myp',(1-`myp')) ;
} ;


global mainp = normal($maint) ;
global pctile_main = 2 * min($mainp,(1-$mainp)) ;

local myfmt = "%7.5f" ;

di "Main Beta  " $mainbeta ; 
di "T-stat  " $maint ; 
di "Percentile main  " $pctile_main;
di "Percentile Wild  " $pctile_t_wild;







*/








