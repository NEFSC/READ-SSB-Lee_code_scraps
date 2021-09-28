use "/run/user/1877/gvfs/smb-share:server=net,share=home2/mlee/regulations/scallop/timeline.dta"


/* See spells DM0029.pdf
You have a regular time series with no gaps. This constructs a variable that is 0 if closed. It is the number of days open.
*/
foreach var of varlist DMV ET NLS CA1 CA2 HC{

gen byte begin`var' = `var'!= `var'[_n-1]
gen spell_`var'=sum(begin`var')

by spell_`var', sort: gen days_open_`var'=_n
replace days_open_`var'=0 if `var'==0
}
