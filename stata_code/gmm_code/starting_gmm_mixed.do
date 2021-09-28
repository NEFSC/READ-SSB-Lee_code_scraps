webuse hsng2, clear

gen cons=1
/* biased OLS */

regress rent pcturban hsngval
est store OLS

/* biased OLS by GMM*/
gmm (rent - pcturban*{b1} - hsngval*{b2} - {b3}), instruments(pcturban hsngval) 
est store OGMM

/* model 1 */
gmm (rent -{xb: pcturban  hsngval cons}), instruments(pcturban hsngval cons)  onestep
est store OGMM2


/*Two stage least squares by hand (SEs are wrong) */
qui regress hsngval faminc i.region pcturban
predict first, xb
predict u, resid

regress rent pcturban first
est store hand_2sls
/*Control function approach (SEs are wrong) */

regress rent pcturban hsngval u
est store CF

/* with correct standard errors */
ivregress 2sls rent pcturban (hsngval = faminc i.region), small
est store IVREG


/* a GMM estimator */
gmm (rent -{xb: pcturban  hsngval cons}), instruments(pcturban faminc i.region cons) onestep

est store GMM_2sls
est table hand_2sls CF IVREG GMM_2sls, b se





/* this is a two step estimator */
ivregress gmm rent pcturban (hsngval = faminc i.region)
est store iv2

gmm (rent -{xb: hsngval pcturban cons}), instruments(pcturban faminc i.region cons) twostep
est store gmm2

est table iv2 gmm2






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

global bootreps 1



local days 2000
local trades 20
local QSUT .2
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


local b 1
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

gmm (price -{xb: 1.small i.small#(c.Q_S c.Q_L) X1 X2} - {b0}), instruments(1.small i.small#(c.zt c.z2t) X1 X2 ) onestep

gmm (price -{xb: 1.small c.Q_S#1.small c.Q_L#1.small c.Q_S c.Q_L X1 X2} - {b0}), instruments(small c.zt#i.small c.z2t#i.small c.zt c.z2t X1 X2 ) onestep
gmm (price -{xb:X1 X2}-  {a0} -{b1}*1.small - {cS}*c.Q_S#1.small - {cL}*c.Q_L#1.small -  {eL}*0.small#c.Q_L -{eS}*0.small#c.Q_S  ), instruments(small c.zt#i.small c.z2t#i.small c.zt c.z2t X1 X2 ) onestep


*replace price=$a0 + $b1*small + $cS*small*Q_S +  $cL*small*Q_L + ut*small +   $f*X1 + $g*X2 + eit

egen td=tag(day)
regress Q_S c.zt c.z2t if td==1

est store first_stage
local s1_r2 =e(r2)
predict errors1, resid

regress Q_L c.zt c.z2t if td==1
predict errors2, resid

/*
The following mixed command is estimating:
price= $a0 + $b1*small + $c*small*Q_S + $f*X1 + $g*X2  + (junk*c.errors+ ut)*small + eit
*/

mixed price i.small c.Q_S#1.small c.Q_L#1.small X1 X2 c.errors1#1.small c.errors2#1.small || day: small, noc emonly
est store control

areg price i.small c.Q_S#1.small c.Q_L#1.small X1 X2 c.errors1#1.small c.errors2#1.small, absorb(day)

gen smQ=Q_S*small
gen smQL=Q_L*small
gen cons=1
gen inst1=zt*small
gen inst2=z2t*small

gmm (price -{xb: small smQ smQL X1 X2}), instruments(small inst1 inst2 X1 X2 ) onestep

regress price i.small c.Q_S#1.small c.Q_L#1.small X1 X2 c.errors1#1.small c.errors2#1.small, vce(cluster day)

regress price 1.small 1.small#(c.Q_S c.Q_L c.errors1 c.errors2) X1 X2, vce(cluster day)



/* these two are equivalent */
gmm (price -{xb: small smQ smQL X1 X2}-{b0}), instruments(small inst1 inst2 X1 X2 ) onestep
gmm (price -{xb: 1.small c.Q_S#1.small c.Q_L#1.small X1 X2} - {b0}), instruments(small c.zt#i.small c.z2t#i.small X1 X2 ) onestep

gmm (price -{xb: i.small c.Q_S#i.small c.Q_L#i.small X1 X2} - {b0}), instruments(i.small c.zt#i.small c.z2t#i.small X1 X2 ) onestep


