set more off
cd "/home/mlee/Documents/technical folder/do file scraps"
tempname sim
postfile `sim' betahat beta using results, replace

global beta=1


quietly forvalues i=1/1000{
	drop _all
	set obs 100
	gen e=rnormal()
	gen x=rnormal()
	gen y=$beta*x + e
	regress y x
	post `sim' (_b[x]) ($beta)
}
postclose `sim'

use results, clear
summ beta
