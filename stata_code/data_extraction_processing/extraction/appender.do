use "C:\Users\Min-Yang\Documents\NMFS-synch\Natural Resource\Dissertation Travel Grant\Data\WWtrip data\Everything\monthlyvms\glou5_02effort.dta", clear
forvalues i=3/6{
	forvalues j=5/10{
		append using "C:\Users\Min-Yang\Documents\NMFS-synch\Natural Resource\Dissertation Travel Grant\Data\WWtrip data\Everything\monthlyvms\glou`j'_0`i'effort.dta"
	}
}
forvalues k=6/10{
	append using "C:\Users\Min-Yang\Documents\NMFS-synch\Natural Resource\Dissertation Travel Grant\Data\WWtrip data\Everything\monthlyvms\glou`k'_02effort.dta"
}
save "C:\Users\Min-Yang\Documents\NMFS-synch\Natural Resource\Dissertation Travel Grant\Data\WWtrip data\Everything\monthlyvms\gloutotaleffort", replace