clear
/*I need  */
/*OLS type DGP */
/* AN RC perspective 
sales nested inside days
*/

/* 
price_it= a0 + b1t*small + e_it
b1t	= b1 + c*Q_s + d*Q_l + u_t 

t=1,..., 50 
I am concerned that b1t and Q_s are simultaneous and that Q_s and u_t are no longer independent

reduced form is 

price_it= a0 + b1*small  + c*Q_s*small + d*Q_l*small  + u_t*small + f*X1 + g*X2 e_it


be careful on the rnormal
rnormal() is mean 0, STD DEV=1
*/


set seed 89751
global b1 1
global cS -.5
global cL -.20
global f 2
global g 1
global a0 2

global eL -.75
global eS -.4


global qz .6
global zu 0
global SL 0.1
global Lz .3


timer clear
timer on 1

global bootreps 100

tempfile bootsave

postfile bskeep variant days trades QSUT rep b1 cS cL a0 using `bootsave' , replace 


qui foreach days of numlist 100 1000 { 
foreach trades of numlist 20  {
foreach QSUT of numlist 0 .2 {


local Lut 0.2
local Sut 0.2


/* this is the setup to draw the daily parameters or data*/
global qu `QSUT'
global Lu `Lut'

global Sz2 .5
global Lz2 .5
global zz2 .05
global zu2  0

mat myCov=(1, $SL, $qz, $Sz2, $qu \ $SL, 1, $Lz, $Lz2, $Lu \ $qz, $Lz, 1, $zz2, $zu \ $Sz2, $Lz2 , $zz2, 1, $zu2 \  $qu, $Lu, $zu, $zu2, 1)

matrix rownames myCov= qs ql zt z2t ut 
matrix colnames myCov= qs ql zt z2t ut 
matrix myMeans=(0, 0, 0, 0, 0)

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

drawnorm Q_S Q_L zt z2t ut, means(myMeans) cov(myCov) n(`days') clear

corr Q_S zt
mat rc=r(C)
local strength=rc[1,2]
gen day=_n
tsset day


qui expand `trades'
sort day
bysort day: gen rep=_n

gen small=0
replace small=1 if rep<=`trades'/2

gen large=0
replace large=1 if small==0
/*draw the `data' */
drawnorm X1 X2 eit, means(tradeMeans) cov(tradeCov)

gen price=$a0 + $b1*small + $cS*small*Q_S +  $cL*small*Q_L + ut*small + $eL*Q_L*large + $eS*Q_S*large +   $f*X1 + $g*X2 + eit


/* all of these do the same thing, but the coeffs get reported slightly differently */
gmm (price -{xb: 1.small i.small#(c.Q_S c.Q_L) X1 X2} - {b0}), instruments(1.small i.small#(c.zt c.z2t) X1 X2 ) onestep

*gmm (price -{xb: 1.small i.small#(c.Q_S c.Q_L) X1 X2} - {b0}), instruments(1.small i.small#(c.zt c.z2t) X1 X2 ) onestep

*gmm (price -{xb: 1.small c.Q_S#1.small c.Q_L#1.small c.Q_S c.Q_L X1 X2} - {b0}), instruments(small c.zt#i.small c.z2t#i.small c.zt c.z2t X1 X2 ) onestep
*gmm (price -{xb:X1 X2}-  {a0} -{b1}*1.small - {cS}*c.Q_S#1.small - {cL}*c.Q_L#1.small -  {eL}*0.small#c.Q_L -{eS}*0.small#c.Q_S  ), instruments(small c.zt#i.small c.z2t#i.small c.zt c.z2t X1 X2 ) onestep


*replace price=$a0 + $b1*small + $cS*small*Q_S +  $cL*small*Q_L + ut*small +   $f*X1 + $g*X2 + eit

egen td=tag(day)

sureg (Q_S Q_L =c.zt c.z2t) if td==1
predict errorsS, resid equation(Q_S)
predict errorsL, resid equation(Q_L)
predict xbS, xb equation(Q_S)
predict xbL, xb equation(Q_L)


/* control function  - SEs are wrong*/
reg price i.small c.Q_S#1.small c.Q_L#1.small X1 X2 c.errorsS#1.small c.errorsL#1.small, cluster(day)

/*Heckman and Vytlacil CRC */
regress price 1.small c.xbS#1.small c.xbL#1.small X1 X2, vce(cluster day)

est store heck
local sm =_b[1.small]
local int1= _b[1.small#c.xbS]
local int2= _b[1.small#c.xbL]
local cons =_b[_cons]
post bskeep (1) (`days') (`trades') (`QSUT') (`b') (`sm') (`int1') (`int2') (`cons')


/* these very similar */
gmm (price -{xb: 1.small c.Q_S#1.small c.Q_L#1.small X1 X2} - {b0}), instruments(small c.zt#i.small c.z2t#i.small X1 X2 ) twostep
local sm =_b[1.small]
local int1= _b[1.small#c.Q_S]
local int2= _b[1.small#c.Q_L]
local cons =_b[b0:_cons]


post bskeep (2) (`days') (`trades') (`QSUT') (`b') (`sm') (`int1') (`int2') (`cons')


*ivregress gmm price  i.small  X1 X2 (c.Q_S#1.small c.Q_L#1.small = c.zt#i.small c.z2t#i.small )


			}
		}
	}
}
qui postclose bskeep


use `bootsave', clear
save "starting_gmm_CRC.dta", replace
