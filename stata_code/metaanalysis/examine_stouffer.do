clear
/* 1000 trials, with uniformly distributed p values on 0-.999 */
set obs 1000
local counter=r(N)

gen n=_n
replace n=0+n/1000
summ n
rename n pval
gen sval=invnormal(pval)
drop if sval==.
egen ts=total(sval)
replace ts=ts/sqrt(`counter')
gen stouffer=normal(ts)
list stouffer if _n==1


/* 100 trials, with p-vals uniform .01 to 0.2*/
clear
set obs 100
qui count
local counter=r(N)

gen pval=2*runiform()/10

gen sval=invnormal(pval)
drop if sval==.
egen ts=total(sval)
replace ts=ts/sqrt(`counter')
gen stouffer=normal(ts)
list stouffer if _n==1

/* massive reject */



/* 100 trials, with p-vals uniform .1 to .3*/


clear
set obs 100
qui count
local counter=r(N)

gen pval=2*runiform()/10+.1

gen sval=invnormal(pval)
drop if sval==.
egen ts=total(sval)
replace ts=ts/sqrt(`counter')
gen stouffer=normal(ts)
list stouffer if _n==1
/* massive reject */



/* 100 trials, with p-vals uniform .2 to .4*/

clear
set obs 100
qui count
local counter=r(N)

gen pval=2*runiform()/10+.2

gen sval=invnormal(pval)
drop if sval==.
egen ts=total(sval)
replace ts=ts/sqrt(`counter')
gen stouffer=normal(ts)
list stouffer if _n==1
/* massive reject */


/* 100 trials, with p-vals uniform .3 to .5*/

clear
set obs 100
qui count
local counter=r(N)

gen pval=2*runiform()/10+.3

gen sval=invnormal(pval)
drop if sval==.
egen ts=total(sval)
replace ts=ts/sqrt(`counter')
gen stouffer=normal(ts)
list stouffer if _n==1
/* massive reject */


/* 100 trials, with p-vals uniform .4 to .5*/

clear
set obs 100
qui count
local counter=r(N)

gen pval=runiform()/10+.4

gen sval=invnormal(pval)
drop if sval==.
egen ts=total(sval)
replace ts=ts/sqrt(`counter')
gen stouffer=normal(ts)
list stouffer if _n==1
/*.09 -- borderline */


/* 100 trials, most with pvals around .8 to .9
and a few between .2 and .3
*/

clear
set obs 100
qui count
local counter=r(N)

gen pval=runiform()/10+.8

replace pva=runiform()/10+.2 if _n<=10
gen sval=invnormal(pval)
drop if sval==.
egen ts=total(sval)
replace ts=ts/sqrt(`counter')
gen stouffer=normal(ts)
list stouffer if _n==1
/* fail to Reject */



/* 100 trials, most with pvals around .6 to .7
and a few between .2 and .3
*/

clear
set obs 100
qui count
local counter=r(N)

gen pval=runiform()/10+.6

replace pva=runiform()/10+.2 if _n<=10
gen sval=invnormal(pval)
drop if sval==.
egen ts=total(sval)
replace ts=ts/sqrt(`counter')
gen stouffer=normal(ts)
list stouffer if _n==1
/* fail to Reject */


/* 100 trials, most with pvals around .6 to .7
and a few between .1 and .2
*/

clear
set obs 100
qui count
local counter=r(N)

gen pval=runiform()/10+.6

replace pva=runiform()/10+.1 if _n<=10
gen sval=invnormal(pval)
drop if sval==.
egen ts=total(sval)
replace ts=ts/sqrt(`counter')
gen stouffer=normal(ts)
list stouffer if _n==1
/* fail to Reject */


/* 100 trials, most with pvals around .4 to .5
and a few between .1 and .2
*/

clear
set obs 100
qui count
local counter=r(N)

gen pval=runiform()/10+.4

replace pva=runiform()/10+.1 if _n<=10
gen sval=invnormal(pval)
drop if sval==.
egen ts=total(sval)
replace ts=ts/sqrt(`counter')
gen stouffer=normal(ts)
list stouffer if _n==1
/* Reject */




/* 100 trials, most with pvals around .6 to .7
and a few between .01 and .1
*/

clear
set obs 100
qui count
local counter=r(N)

gen pval=runiform()/10+.6

replace pva=runiform()/10+.01 if _n<=10
gen sval=invnormal(pval)
drop if sval==.
egen ts=total(sval)
replace ts=ts/sqrt(`counter')
gen stouffer=normal(ts)
list stouffer if _n==1
/* Accept */

/* 100 trials, most with pvals around .5 to .6
and a few between .01 and .1
*/

clear
set obs 100
qui count
local counter=r(N)

gen pval=runiform()/10+.5

replace pva=runiform()/10+.01 if _n<=10
gen sval=invnormal(pval)
drop if sval==.
egen ts=total(sval)
replace ts=ts/sqrt(`counter')
gen stouffer=normal(ts)
list stouffer if _n==1
/* Accept */




/* 100 trials, most with pvals around .5
and a 20% between .01 and .1
*/

clear
set obs 100
qui count
local counter=r(N)

gen pval=runiform()/10+.5

replace pva=runiform()/20+.01 if _n<=10
gen sval=invnormal(pval)
drop if sval==.
egen ts=total(sval)
replace ts=ts/sqrt(`counter')
gen stouffer=normal(ts)
list stouffer if _n==1
/* Accept */

/* 100 trials, most with pvals around .5
and a 5% between .01 and .05
*/

clear
set obs 100
qui count
local counter=r(N)

gen pval=runiform()/10+.5

replace pva=runiform()/20+.0001 if _n<=5
gen sval=invnormal(pval)
drop if sval==.
egen ts=total(sval)
replace ts=ts/sqrt(`counter')
gen stouffer=normal(ts)
list stouffer if _n==1
/* Accept */





/* 
1. If i get lots of 'meh' evidence, say everything around p=.3 to .4, it'll reject. (or less) 
2. If i get uniform on 0 to 1 -- accept
3. If i get lots of really meh evedence (p .5 to .6) and handful of good evidence it will reject.
*/






