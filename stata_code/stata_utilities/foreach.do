foreach var of varlist j2vtr-vmsstell5{
	replace `var' = 0 if `var'==.
}

foreach var of varlist fishing10m-fishing40all{
	by companyid: gen l7`var'=l.`var' + l2.`var' + l3.`var' + l4.`var' + l5.`var' + l6.`var' + l7.`var'
}
foreach var of varlist fishing10m-fishing40all{
	by companyid: gen f7`var'=f.`var' + f2.`var' + f3.`var' + f4.`var' + f5.`var' + f6.`var' + f7.`var'
}
foreach var of varlist fishing10m-fishing40all{	
	by companyid: gen l5`var'=l.`var' + l2.`var' + l3.`var' + l4.`var' + l5.`var' 
}
foreach var of varlist fishing10m-fishing40all{
	by companyid: gen f5`var'=f.`var' + f2.`var' + f3.`var' + f4.`var' + f5.`var'
}

forvalues a = 1/10{
	gen var`a' = var*`a'
}