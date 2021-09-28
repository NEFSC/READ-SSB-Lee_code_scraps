clear
local myvariables tot_cat 

set obs 100
	gen x1=runiform()
	gen x2=runiform()

foreach myv of local myvariables{
	disp "`myv'"
	rename x1 `myv'
}
