/*Sample code fragment to read in stored estimation results from an .ster, save them to memory, and make a table. */

cap log close
local mylogfile "${my_results}/N01A_churdle_readin.smcl" 
log using `mylogfile', replace

#delimit cr
version 15.1

est  drop _all


local linear_hurdle ${my_results}/linear_hurdle_${vintage_string}.ster




/* load in linear hurdle */
qui est describe using `linear_hurdle'

local numest=r(nestresults)
forvalues est=1(1)`numest'{
	est use `linear_hurdle', number(`est')
	est store linear_`est'
}











/* linear-log models */

est table linear_*, star(0.10 .05 .01 )
 
log close
