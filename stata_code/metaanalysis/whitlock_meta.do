
/* figure 1 bottom left panel
 true mean 0.1
 alpha=.01
 constant sample size
 
 319 experiments of 8 replicates
 nt=2552
 
 variance=1
 
 for each dataset, do a t test and save the p value
 
 subset the data
 
 
 tab mu0  if stoufferp<=.05
 
 */
 set seed 50
 tempname my_diag 

local diag_out "fig1bottom_left.dta"
postfile `my_diag' mu0 replicate truep stoufferp fisher_chi using `diag_out', replace

local mulist -.02 -.06 -.08
timer clear
timer on 11
nois _dots 0, title(Loop running) reps(100)

foreach mymu of local mulist{


quietly forvalues myrep=1/1000{
 
 clear
 set obs 8
 gen experiment=_n
 expand 319
 
 gen myvar=rnormal(`mymu')
 
 ttest myvar=0
 /* this is the true p value */
 /*you need to do a one-tailed test.  therefore, you need to pick the correct tail. */
 
 local truep=r(p_l)
 
 local cumul=0
 local fisher=0
 forvalues mye = 1/8{
	ttest myvar==0 if exper==`mye'
	local m=r(p_l)
	local fisher=`fisher'+ln(`m')
	local cumul=`cumul'+invnormal(`m')
}
local stouffer = normal(`cumul'/sqrt(8))
local fisher = -2*`fisher'

di `m'

nois _dots `myrep' 0     

post `my_diag' (`mymu') (`myrep') (`truep') (`stouffer') (`fisher')
}
}

postclose `my_diag'
timer off 11
use `diag_out', clear
 tab mu0 if stoufferp<=.05

