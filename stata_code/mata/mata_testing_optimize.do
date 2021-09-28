/* It seems like i can use either the "d0" or "gf0" method of coding the function which recovers "F" from the sub-ACL*/

version 12
cd "/home/mlee/Documents/Workspace/recreational_simulations/cod_and_haddock"

mata: mata clear
global total_reps=1
global numtrips 50000
global codbag 10
global haddockbag 35
global cod_min_keep 24
global cod_max_keep 100
global hadd_min_keep 18
global hadd_max_keep 100
global FMax 25
global maxfiter 30



/* Retention of sub-legal fish */
/* cod_relax: window below the minimum size that anglers might retain sublegal fish */
/* cod_sublegal_keep: probability that an angler will retain a sublegal cod in that size window*/

global cod_relax=2
global cod_sublegal_keep=0

/* hadd_relax: window below the minimum size that anglers might retain sublegal fish */
/* haddock_sublegal_keep: probability that an angler will retain a sublegal haddock in that size window*/

global hadd_relax=1
global haddock_sublegal_keep=0


/* discard of legal sized fish */
global dl_cod=0
global dl_hadd=0


/* Ignoring the Possession Limit */
/* For GOM Cod, approximately 1.5% of trips which kept cod kept more than the 10 fish possession limit */
/* These 11th and higher fish caught on these trips were responsible for 5.5% of all kept cod (by numbers).*/
/* In order to address this, i'll set 2 globals which are the probability which an angler will `comply with the bag limit'  */

global pcbag_comply=1
global phbag_comply=1



/* These globals contain the locations of the cod age-length key raw data */
global codalkey cod_al_key.dta
global haddalkey haddock_al_key9max.dta


/* Here are some parameters */
global mt_to_kilo=1000
global kilo_to_lbs=2.20462262
global cm_to_inch=0.39370787


/* NOTE cTAC and hTAC should be in lbs */
global cTAC= 2824*$mt_to_kilo*$kilo_to_lbs
global hTAC= 1000*$mt_to_kilo*$kilo_to_lbs

global cod_lwa -11.7231
global cod_lwb 3.0521
global had_lwa 0.00000987
global had_lwe 3.0987


/* min and max sizes of cod and haddock in inches */
global codmin=3
global codmax=47
global haddmin=4
global haddmax=28



/* These are some Economic parameters */
/* This is the Probability Mass Function of shore, boat, party/head, and charter  See section WTP */

scalar shore=0.20
scalar boat=0.20
scalar party=0.20
scalar charter=0.40

/* This is the Probability Mass Function of Trip lengthSee section WTP */
scalar hour4=0.5
scalar hour8= 0.4
scalar hour12=0.1

/* These are scalars for the marginal and total costs of various types trips */
/* TC is total cost per trip, c is "pseudo-"marginal cost of trip length */
scalar c_chart=30
scalar c_party=11
scalar tc_boat=165
scalar tc_shore=105

/* logit coefficients */
global pi_cod_keep 0.3243 
global pi_cod_release 0.0942
global pi_hadd_keep 0.3195 
global pi_hadd_release 0.1063 
global pi_cost "-0.005392"
global pi_trip_length 0.0743 
global pi_trip_length2 "-0.003240"

/* cutoff probability for Logit trip occurrence=1 */
global cutoff_prob 0.50

/*
These are the length-weight relationships for Cod and Haddock
GOM Cod Formula:
ln Weight (kg, live) = -11.7231 + 3.0521 ln Length (cm)
http://www.nefsc.noaa.gov/publications/crd/crd0903/
Haddock Weight length formula 
Autumn: Wlive (kg) = 0.00000987·L(fork cm)3.0987 (p < 0.0001, n=4890)
http://nefsc.noaa.gov/publications/crd/crd0815/pdfs/garm3r.pdf
Fork length and total length are the same for haddock.
Most haddock are caught in the fall (Sept.-Oct) and it just doesn't look like there's a significant difference between the formulas anyway*/


/* END of Global macros */
/**************************************************************/
/**************************************************************/

/* Begin the section of temporary macro adjustment */
/* Use this section to temporarily set macros to smaller values.  
This is useful for troubleshooting and debugging  */

/* Once we go to production, this entire section should be empty*/
global cTAC= 2824*$mt_to_kilo*$kilo_to_lbs
global hTAC= 500*$mt_to_kilo*$kilo_to_lbs
/* END:section of temporary macro adjustment */

/*************************************************************/

/* Specify commerical quota1  */
/* IN LBS */
/*These are set to actual landings (NERO) for the 2010 fishing year*/
global haddock_quota1=(367.8+6.9)*$mt_to_kilo*$kilo_to_lbs
global cod_quota1=(3537.1+195.2)*$mt_to_kilo*$kilo_to_lbs

global haddock_quota2=$haddock_quota1
global haddock_quota3=$haddock_quota1

global cod_quota2=$cod_quota1
global cod_quota3=$cod_quota1


/* Hinge value for Cod recruitment (KG)*/
global cod_SSBHinge=7300*$mt_to_kilo*$kilo_to_lbs

/* Mortality rate of the released fish (UNIT FREE) */
scalar mortality_release=0.3

/*****************************************************************************************/
/* how many years does the model run */
/*****************************************************************************************/
global replicate =1
/* Maximum iterations and maximum F for the commercial fishery (UNIT FREE)*/
global maxiterations=30
global maxfishingmortality=25


/***************************BEGIN HADDOCK SETUP ******************************/
/*****************************************************************************************/
/* BIOLOGICAL PARAMETERS FOR Natural Mortality, fishing mortality, SELECTIVITY, WEIGHTS (kg) */
/* These are from Paul N.  From the 2012 Haddock Assessment Update */
/* Time constant and no uncertainty about them */
/*****************************************************************************************/
/* Pre-spawn natural and fishing mortality 
hMp1 == haddock Mortality part 1.  This is a feature present in AgePro 4, but not in AgePro 3
hFp1 == haddock Fishing mortality part 1.  (UNIT FREE)  */
/* total natural mortality */

local hMp1=0.25
local hFp1=0.25
local hM=.2

/* selectivity  -- at least one of the columns here must be 1*/
mata:
haddock_age_selectivity=(0.009, 0.017, 0.091, 0.297, 0.672, 0.660, 1, 1, 1)'
/* Haddock (h) January weights(hj1w) , Catch weights (hcw), midyear weights (hmyw), and spawning weights (hssbw), discard weights (hdw) all of these weights are taken from AgePro/Pop Dynamics
and are in kilograms*/


/* fraction discarded (hfdis) and maturity hmaturity are UNIT FREE*/
haddock_jan1_weights=(0.100, 0.298, 0.706, 0.984,1.208,1.498,1.650,1.786, 1.967)'
haddock_midyear_weights=(0.178, 0.603, 0.905, 1.075, 1.357, 1.629, 1.699, 1.879, 1.967)'

haddock_catch_weights= haddock_midyear_weights
haddock_ssb_weights=haddock_jan1_weights
haddock_discard_weights=haddock_catch_weights
haddock_discard_fraction=(0, 0, 0, 0, 0, 0, 0, 0, 0)'
haddock_maturity=(0.027,0.236,0.773,0.974,0.998,1, 1,  1,  1)'


/* this step converts Haddock (h) January weights(hj1w) , Catch weights (hcw), midyear weights (hmyw), and spawning weights (hssbw), discard weights (hdw) to lbs */
haddock_jan1_weights=$kilo_to_lbs*haddock_jan1_weights
haddock_catch_weights=$kilo_to_lbs*haddock_catch_weights
haddock_midyear_weights=$kilo_to_lbs*haddock_midyear_weights
haddock_ssb_weights=$kilo_to_lbs*haddock_ssb_weights
haddock_discard_weights=$kilo_to_lbs*haddock_discard_weights
end

/***************************END Haddock SETUP ******************************/
/***************************** ******************************/







use "haddock_numbers_at_age.dta", clear
keep if year>=2007 & year<=2009
collapse (mean) age1-age9
save "haddock_age_count.dta", replace
keep age*
scalar hreplicate=1
putmata haddock_initial_counts=(age*)


mata:
haddock_after_rec_age_structure=haddock_initial_counts:-dead_haddock
haddock_biomass_after_rec_weight=haddock_after_rec_age_structure*haddock_catch_weights'
end



/* This section applies the commercial (sub)-ACL to the fishery using the ``fishing mortality method.'' */
/* I need to pick an Fh such that the total weight of fish is equal to the sub ACL AND the selectivity is correct */
/* See pages 2-5 and 53 of the AgePro manual */
/* Commercial Mortality */
mata:
hac=cols(haddock_age_selectivity)
haddock_after_rec_weight = haddock_initial_counts:*haddock_catch_weights
haddock_intermed_counts=haddock_after_rec_age_structure
nhm=J(1,hac,`hM')
ones=J(1, hac,1)

iter=0
/* AGEPRO uses Newtons method to compute F if there is an ACL/TAC.
It is easier to code up the secant method as a derivative free method.
This method requires 2 starting points but this is not so bad. Approximate the derivative by calculating 2 values of the objective function. */

/* See Miranda and Fackler, Page 36-37 for details of the secant method 

I would like L(F)-Q=0 [Rootfinding ].  Alternatively F=F-[L(F)-Q].

in M&F notation: 
f=L(F)-Q
x=Fishing mortality
*/


/*initial values */
Fh0= 0
Fh1=.001

/* The code is a little sensitive to starting values it might be a good idea to start at small numbers and approach from one side.  Also terminate at a maximum. */


/* Wrap a do , while  loop around this */
iter=0
do {
mcca = (Fh0*haddock_age_selectivity) :/ (Fh0*haddock_age_selectivity:+nhm )
mccb =  (ones - exp( -nhm- Fh0*haddock_age_selectivity)) :* haddock_intermed_counts
my_catch_counts0= mcca :*mccb
my_catch_weights0 = my_catch_counts0:*haddock_catch_weights
my_landings0=(my_catch_counts0:*haddock_catch_weights):*(ones-haddock_discard_fraction)

mccc = (Fh1*haddock_age_selectivity) :/ (Fh1*haddock_age_selectivity+nhm )
mccd =  (ones - exp( -nhm- Fh1*haddock_age_selectivity)) :* haddock_intermed_counts
my_catch_counts1= mccc :*mccd
my_catch_weights1 = my_catch_counts1:*haddock_catch_weights
my_landings1=(my_catch_counts1:*haddock_catch_weights):*(ones-haddock_discard_fraction)

fprime_upper = (rowsum(my_landings1)-$haddock_quota1)-(rowsum(my_landings0)-$haddock_quota1)
fprime_lower=Fh1-Fh0

fprime=fprime_upper:/fprime_lower
Fh2=Fh1-fprime^-1*(rowsum(my_landings1)-$haddock_quota1)

delta=Fh2-Fh1

Fh0=Fh1
Fh1=Fh2
iter=iter+1
}while (abs(delta>=1e-6) & iter<=$maxfiter & Fh2~=.)


/* Infeasible F: AGEPRO uses FMax=25.   
if F>FMax then set F=FMax and recompute my_landings1 */

if (Fh1>=$FMax) {
Fh1=$FMax
mccc = (Fh1*haddock_age_selectivity) :/ (Fh1*haddock_age_selectivity+nhm )
mccd =  (ones - exp( -nhm- Fh1*haddock_age_selectivity)) :* haddock_intermed_counts
my_catch_counts1= mccc :*mccd
my_catch_weights1 = my_catch_counts1:*haddock_catch_weights
my_landings1=(my_catch_counts1:*haddock_catch_weights):*(ones-haddock_discard_fraction)
}

/* Negative F?
Set F=0
 */

if (Fh1<0) {
Fh1=0

mccc = (Fh1*haddock_age_selectivity) :/ (Fh1*haddock_age_selectivity+nhm )
mccd =  (ones - exp( -nhm- Fh1*haddock_age_selectivity)) :* haddock_intermed_counts
my_catch_counts1= mccc :*mccd
my_catch_weights1 = my_catch_counts1:*haddock_catch_weights
my_landings1=(my_catch_counts1:*haddock_catch_weights):*(ones-haddock_discard_fraction)

}
st_numscalar("F_COMM_HADDOCK", Fh1)
end
