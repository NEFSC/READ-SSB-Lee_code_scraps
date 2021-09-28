/*OLS type DGP */
/* AN RC perspective 
sales nested inside days
*/

/* 
gen price2=$a0 + $b1*small + $c*small*Q_S + ut*small + $f*X1 + $g*X2 + trend*$tfx*small + eit



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

global tfx=1/2000

timer clear
timer on 1



local days 2000

local trades 20
local QSUT 0

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
gen trend=day
gen price2=$a0 + $b1*small + $c*small*Q_S + ut*small + $f*X1 + $g*X2 + trend*$tfx*small + eit


/*
The following mixec command is estimating:
price= $a0 + $b1*small + $c*small*Q_S + $f*X1 + $g*X2  + (junk*c.errors+ ut)*small + eit

*/

mixed price2 i.small c.Q_S#1.small X1 X2 i.small#c.trend  || day: small, noc 




