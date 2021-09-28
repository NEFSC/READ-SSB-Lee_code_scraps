/*this ugly scrap of code is used to generate orthogonal deviations of the form:
fwd_dev_w=sqrt[T_{it}/(T_{it}+1]*(w-1/T_{it} \sum_{t+1}^T w_{ik}.
0.  Sort on the id and time variables
1.  create a local variable list called <myvariables> that contains the variables that the transformation will be applied to
2.  generate T_{it}, the number of subsequent observations
3.  sort in backwards order by generating a negative of the time it and then sorting on it.
4.  while backwards, sum across variables of interest
5.  reverse the sorting, drop the negative time variable
6.  remove the current period value of each variable from the summation. This generate the term inside the summation sign.
7.  Do the rest of the transformation.

*/
sort idcode year
local myvariables ln_w grade age* ttl_exp* tenure* black not_smsa south
by idcode: gen capT=_N-_n
by idcode: gen minust=-_n
sort idcode minust 
foreach var of varlist `myvariables'{
	by id: gen minus_sum_`var'=sum(`var') 
}
sort idcode year
drop minust

foreach var of varlist `myvariables'{
	gen fwdsum_`var'=minus_sum_`var'-`var' 
	gen fwd_dev_`var'=sqrt(capT/(capT+1))*(`var'-fwdsum_`var'/(capT))
}
drop minus_sum_* fwdsum*
