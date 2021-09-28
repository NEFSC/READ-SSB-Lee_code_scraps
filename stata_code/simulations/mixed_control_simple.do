/*OLS type DGP */
/* AN RC perspective 
sales nested inside days
*/

/* 
gen price=$a0 + $b1*small + $c*Q_S + ut*small + $f*X1 + $g*X2 + eit


t=1,..., 50 
I am concerned that b1t and Q_s are simultaneous and that Q_s and u_t are no longer independent

reduced form is 

price_it= a0 + b1*small  + c*Q_s*small  + u_t*small + f*X1 + g*X2 e_it


be careful on the rnormal
rnormal() is mean 0, STD DEV=1
*/


set seed 89753
global b1 1
global c .5
global f 2
global g 1
global a0 2

global qz .5
global zu 0

timer clear
timer on 1

global bootreps 10



tempfile bootsave
postfile bskeep variant days trades QSUT rep b1 c f g a0 var_sm stage1_r2 endog strength using `bootsave' , replace 

qui foreach days of numlist 100 { 
foreach trades of numlist 20  {
foreach QSUT of numlist 0 .2 .6{




/* this is the setup to draw the daily parameters or data*/
global qu `QSUT'
mat myCov=(1, $qz, $qu \ $qz, 1, $zu \ $qu, $zu, 1)
matrix rownames myCov= qs zt ut 
matrix colnames myCov= qs zt ut 
matrix myMeans=(0, 0, 0)

/* end setup to draw the daily parameters or data*/



/* this is the setup to draw the trade level parameters*/
mat tradeCov=(1, .05, 0\ .05, 1, 0 \ 0, 0, 1 )
matrix rownames tradeCov= X1 X2 eit 
matrix colnames tradeCov= X1 X2 eit 
matrix tradeMeans=(0, 0, 0)

/* end setup to draw the daily parameters or data*/




nois _dots 0, title(Loop running - `days' days, `trades' trades, and QSUT -`QSUT' ) reps(100)

forvalues b = 1/$bootreps { 
nois _dots `b' 0     

drawnorm Q_S zt ut, means(myMeans) cov(myCov) n(`days') clear

corr Q_S zt
mat rc=r(C)
local strength=rc[1,2]
gen day=_n
tsset day
gen z2=l1.Q_S
qui expand `trades'
sort day
bysort day: gen rep=_n

gen small=0
replace small=1 if rep<=`trades'/2


/*draw the `data' */
drawnorm X1 X2 eit, means(tradeMeans) cov(tradeCov)

gen price=$a0 + $b1*small + $c*Q_S + ut + $f*X1 + $g*X2 + eit

regress Q_S c.zt i.small X1 X2 
est store first_stage
local s1_r2 =e(r2)
predict errors, resid

/*
The following mixec command is estimating:
gen price=$a0 + $b1*small + $c*Q_S + $f*X1 + $g*X2+ junk*c.errors+ ut) + eit

These all produce the same coefficient estimates and wrong estimates fo the variance of the day fixed effects
xtivreg price small X1 X2 (Q_S = zt), re
xtreg price i.small c.Q_S c.X1 c.X2 c.errors
mixed price i.small c.Q_S c.X1 c.X2 c.errors || day: , emonly

*/

mixed price i.small c.Q_S c.X1 c.X2 c.errors || day: , emonly

est store control
local sm =_b[1.small]
local inter =_b[c.Q_S]
local x1 =_b[X1]
local x2 =_b[X2]
local cons =_b[_cons]
local var_sm =exp(_b[lns1_1_1:_cons])^2
local err= _b[c.errors]
post bskeep (1) (`days') (`trades') (`QSUT') (`b') (`sm') (`inter') (`x1') (`x2') (`cons') (`var_sm') (`s1_r2') (`err') (`strength')


mixed price i.small c.Q_S c.X1 c.X2  || day: , emonly
est store exog
local sm =_b[1.small]
local inter =_b[c.Q_S]
local x1 =_b[X1]
local x2 =_b[X2]
local cons =_b[_cons]
local var_sm =exp(_b[lns1_1_1:_cons])^2
local err= .
post bskeep (2) (`days') (`trades') (`QSUT') (`b') (`sm') (`inter') (`x1') (`x2') (`cons') (`var_sm') (`s1_r2') (`err') (`strength')

			}
		}
	}
}
qui postclose bskeep

/*
timer off 1
use `bootsave', clear
qui compress
save "mixed_simple_1.dta", replace
*/



