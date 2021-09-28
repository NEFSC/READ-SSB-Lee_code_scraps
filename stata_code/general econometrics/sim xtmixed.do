/* Simulating data for xtmixed */
/* This creates some data for a 2-level nested model which is similar to the RP model that I want to build
price_{it}=b_1t D_large + b_2t D_Med + b_3t D_small + g_1t*tripdays + u_it
b_1t = f1(qlarge, q_med, q_small, e_1t)
b_2t = f2(qlarge, q_med, q_small, e_2t)
b_3t = f3(qlarge, q_med, q_small, e_3t)
g_1t = f(daily average trip length, e_4t)

The E E is:

price_{it}=b_1 Dlarge + b11 qlarge*Dlarge + b12 qmed*Dlarge + b13 qsmall*Dlarge + e1tDlarge  + 
b_2 DMed+ b21 qlarge*DMed + b22 qmed*DMed + b23 qsmall*DMed + e2tDMed  +
b_3 DSmall+ b21 qlarge*DSmall + b22 qmed*DSmall + b23 qsmall*DSmall + e2tDSmall  +
g_1*tripdays + g2*bartripdays + e4ttripdays + u_it


I'll divide the quantities roughly evenly
I'll let tripdays be poisson with mean variance = 2

I'll set up the coefficients in f1, f2, f3 to be negative with the own quantity effects larger in magnitude than the cross effects 
I want the coefficient in f to be negative as well

I'll set it up so that The number of observations is 50 times larger than number of days 


*/


/* The first step is to create the `daily' (level 2) errors: e_1t through e_4t */
clear
set more off
set seed 8675309
local t 100
set obs `t'
gen t=_n
gen e1t = rnormal(0,1)
gen e2t = rnormal(0,.75)
gen e3t = rnormal(0,1.25)
gen e4t = rnormal(0,1.5)


/* The next step is to create individual data */
expand 50
bysort t: gen i=_n
order i t
gen uit=10*rnormal()
gen sizecat=1+int((3-1+1)*runiform())
xi i.sizecat, noomit
rename _Isizecat_1 large
rename _Isizecat_2 medium
rename _Isizecat_3 small
gen quantity=25*rpoisson(20)
gen tripdays=rpoisson(2)

/* Now create daily data -- demeaned large q, medium q, small q, and bar(tripdays)*/
bysort t sizecat: egen sizebar=total(quantity)
gen qlarge=.
replace qlarge=sizebar if large==1
bysort t (qlarge): replace qlarge=qlarge[1] if qlarge==.
replace qlarge=0 if qlarge==.
gen qmedium=.
replace qmedium=sizebar if medium==1
bysort t (qmedium): replace qmedium=qmedium[1] if qmedium==.
replace qmedium=0 if qmedium==.

gen qsmall=.
replace qsmall=sizebar if small==1
bysort t (qsmall): replace qsmall=qsmall[1] if qsmall==.
replace qsmall=0 if qsmall==.

bysort sizecat: egen gmean=total(quantity)
replace gmean=gmean/`t'


replace qlarge=qlarge-gmean
replace qmedium=qmedium-gmean
replace qsmall=qsmall-gmean

/*bar trip days*/
bysort t: egen daysland=total(quantity)
gen t1=tripdays*quantity
bysort t: egen tripbar=total(t1)
replace tripbar=tripbar/daysland

/* initialize parameters */
/* parameters in the main equation */
/* Sizecat parameters */
local b1=1.5
local b2 = 1.2
local b3=0.9

/* Quantity effects for qlarge */
local b11=-1
local b12=-.5
local b13=-.1

/* quantity effects for qmedium */

local b21=-.75
local b22=-2
local b23=-.25

/* quantity effects for qsmall */

local b31=-1
local b32=-4
local b33=-1.5


/* main effect for tripdays */
local g1=-5

/* quantity effect for bartripdays */
local g2=10

gen price=`b1'*large + `b11'*large*qlarge + `b21'*large*qmedium + `b31'*large*qsmall + e1t*large + `b2'*medium+ `b12'*medium*qlarge + `b22'*medium*qmedium + `b32'*medium*qsmall + e2t*medium + `b3'*small+ `b13'*small*qlarge + `b23'*small*qmedium + `b33'*small*qsmall + e3t*small + `g1'*tripdays + `g2'*tripdays*tripbar + e4t*tripdays


xtmixed price ibn.sizecat i.sizecat#(c.qlarge c.qmedium c.qsmall) c.tripdays c.tripdays#c.tripbar, noconstant || t: large medium small tripdays, noconstant
