/* This illustrates drawing from a probability distribution using mata */
/* As written, this is not going to run faster than the stata version: the element-wise loop takes a very long time*/


/* Min-Yang Lee */


version 12
set more off
timer clear
mata:mata clear

/* The first part loads the auto database, contracts to form a probability distribution of mpg, and sends the data to stata matrix*/

cd "/home/mlee/Documents/Workspace/recreational_simulations/cod_and_haddock"

set seed 10
global haddock_upper_bound 30 
global cod_upper_bound 108
global cod_min_keep 18
global codmin=3
global codmax=47
global haddmin=4
global haddmax=28



global numtrips 465000
global codbag 10
global haddockbag 35
global cod_min_keep 24
global cod_max_keep 100
global hadd_min_keep 18
global hadd_max_keep 100

global mt_to_kilo=1000
global kilo_to_lbs=2.20462262
global cm_to_inch=0.39370787


global cod_lwa -11.7231
global cod_lwb 3.0521
global had_lwa 0.00000987
global had_lwe 3.0987

/*THIS IS THE Line Drop and Trips SECTION*/
/**************************************************************/
/**************************************************************/
use cod_length_count.dta, clear
sort length
quietly do "process_cod_selectivity.do"
use cod_length_count.dta, clear
do "process_cod.do"

use haddock_length_count.dta, clear
sort length
do "process_haddock_selectivity.do"
use haddock_length_count.dta, clear

do "process_haddock.do"

preserve
use haddock_line_drops.dta, clear
sort hlinedrops
putmata myhaddpdf=(hlinedrops hpdf), replace
global haddock_upper_bound=hlinedrops[_N]

use cod_line_drops.dta, clear
sort clinedrops
putmata mycodpdf=(clinedrops cpdf), replace
global cod_upper_bound=clinedrops[_N]
restore







/* I'm using dtemp.dta as a placeholder in order to hold onto certain things (hrand, crand, and the label definitions in particular)*/


timer on 1

mata
/* This code gets the number of linedrops for haddock. I wrote it in two lines to make it explicit:
temp1=rdiscrete($numtrips,1 ,myhadd[.,2])
hrand=myhadd[temp1,1]*/

/* This code gets the number of linedrops  (expected and actual) for cod and haddock. I wrote it in one line to make it faster*/
hrand=myhaddpdf[rdiscrete($numtrips,1 ,myhaddpdf[.,2]),1]
crand=mycodpdf[rdiscrete($numtrips,1 ,mycodpdf[.,2]),1]
ehrand=myhaddpdf[rdiscrete($numtrips,1 ,myhaddpdf[.,2]),1]
ecrand=mycodpdf[rdiscrete($numtrips,1 ,mycodpdf[.,2]),1]


/* This code constructs the matrices of fish which are caught/released */

/* we can do this in 1 step*/
expected_haddock_lengths=rowshape(matahadd_pdf[rdiscrete($numtrips*$haddock_upper_bound,1 ,matahadd_pdf[.,2]),1], $numtrips)
expected_cod_lengths=rowshape(matacod_pdf[rdiscrete($numtrips*$cod_upper_bound,1 ,matacod_pdf[.,2]),1], $numtrips)
haddock_lengths=rowshape(matahadd_pdf[rdiscrete($numtrips*$haddock_upper_bound,1 ,matahadd_pdf[.,2]),1], $numtrips)
cod_lengths=rowshape(matacod_pdf[rdiscrete($numtrips*$cod_upper_bound,1 ,matacod_pdf[.,2]),1], $numtrips)


/* THIS PART IS EXPECTED COD*/
/* HERE IS THE GENERAL STRATEGY */

/* 
1.  Construct an Expected Keep matrix=1 for keepable and a expected release matrix=1 for released a <:+> operation will summ to a matrix of 1's.  
2.  Check the line-drops.  Set entries the keep-length and and release-length matrices equal to zero for fish which are never caught.
3.  Check the bag limit and the line drop limit
4.  Compute expected kept and released.
*/


/* 1.  Construct a Keep matrix=1 for keepable and a release matrix=1 for released a <:+> operation will summ to a matrix of 1's.  [we don't actually need this matrix]*/
/*Count the number of expected ffish which are greater than or equal to the min size) */
/* I haven't figured hout how to code a 'slot' in an elegant way.  what i've done is to code a pair of 0/1 matrices for the upper and lower limits.  Then I've colon-multiplied them together.
Ugly, but works */
t1=expected_cod_lengths:>=$cod_min_keep
t2=expected_cod_lengths:<=$cod_max_keep
eckeepable=t1:*t2
ecreleasable=eckeepable:==0

mata drop t1 t2


/*2.  Check the line-drops.  Set entries the keep-length and and release-length matrices equal to zero for fish which are never caught */
for (i=1; i<=rows(eckeepable); i++) {
	if (ecrand[i,1]<$cod_upper_bound){
		eckeepable[|i,ecrand[i,1]+1\ i,$cod_upper_bound|]=J(1,$cod_upper_bound-ecrand[i,1],0)
		ecreleasable[|i,ecrand[i,1]+1\ i,$cod_upper_bound|]=J(1,$cod_upper_bound-ecrand[i,1],0)
	}
	else { /* DON'T DO anything if CRAND=the upper bound */
	}	
	
}


/* 4.  Check the bag limit: This takes a very long time. */
/* initialize the matrix which is 1 when the trip can continue 
	1== Bag not hit AND CRAND not hit
	0 == bag hit OR CRAND hit*/


/* Increment if fish is long enough to keep: This is the running number of fish in the bag.*/
leq_ecbag_limit_and_ecrand=J($numtrips, $cod_upper_bound,0)
for (i=1; i<=rows(eckeepable); i++) {
	leq_ecbag_limit_and_ecrand[i,.] =runningsum(eckeepable[|i,1\i,$cod_upper_bound|])
}
/* LOGICAL SETS TO 1 if bag not hit and 0 if bag hit.*/
leq_ecbag_limit_and_ecrand=leq_ecbag_limit_and_ecrand:<=$codbag


/* LOGICAL SETS TO 1 if bag not hit and 0 if bag hit OR ECRAND hit. <-- I believe this step is not strictly necessary since we've marked the uncaught fish in the eckeepable matrix already. */
for (i=1; i<=rows(leq_ecbag_limit_and_ecrand); i++) {
	if (ecrand[i,1]<$cod_upper_bound){
		leq_ecbag_limit_and_ecrand[|i,ecrand[i,1]+1\ i,$cod_upper_bound|]=J(1,$cod_upper_bound-ecrand[i,1],0)
	}
	else {
	}
}

/*Compute expected cod kept and expected cod released */
/* These are matrices which are ($numtrips x $cod_upper_bound).  The entries are either zeros or ones.  */
ecod_kept=leq_ecbag_limit_and_ecrand:*eckeepable 
ecod_released=leq_ecbag_limit_and_ecrand:*ecreleasable



/* These are counts in each trip */
eckept=rowsum(ecod_kept)
ecrel=rowsum(ecod_released)



/* We don't need to do weights for expected cod kept and released */ 
/*

cod_lengths_kept=cod_kept:*cod_lengths
cod_lengths_released=cod_released:*cod_lengths


/* Add up the weights of cod_kept and cod_released */
/* These are matrices which are ($numtrips x $cod_upper_bound).  The entries are either zeros or the length of a fish.  */
 


ckeptweight=$kilo_to_lbs:*exp($cod_lwa:+$cod_lwb:*ln(cod_lengths_kept:/$cm_to_inch))
creleasedweight=$kilo_to_lbs:*exp($cod_lwa:+$cod_lwb:*ln(cod_lengths_released:/$cm_to_inch))

/*These are weights in each trip */
ckeptweight=rowsum(ckeptweight)
creleasedweight=rowsum(creleasedweight)

/* kept_cod is a matrix which contains 0's for individuals which were not kept and the lengths of cod which were kept*/
/* released_cod is a matrix which contains 0's for individuals which were not released and the lengths of cod which were released*/
/* these lines of code convert the matrices which have lots of  zeros in them into vectors which do not have zeros.  Easiest to export to stata and then 'contract' 
them to get a frequency/count dataset*/
/* You still need to figure out how to 'mark' the trips which occurred and the trips which did not */
/* best idea so far:  Send the trip_occur data from stata to mata.  Append that column to the 'kept_cod' matrix.  Then do a select on trip_occur=1. */

kc=vec(cod_lengths_kept)
kc=select(kc,kc:>0)

rc=vec(cod_lengths_released)
rc=select(rc,rc:>0)


*/

/*keptweight and released weight are the total weights, in lbs of caught and released cod */
/* ckept and crel should be 'posted back' to  stata for the WTP calculations*/


/* THIS PART IS EXPECTED HADDOCK */

/* 1.  Construct a Keep matrix=1 for keepable and a release matrix=1 for released a <:+> operation will summ to a matrix of 1's.  [we don't actually need this matrix]*/
/*Count the number of expected haddock which are greater than or equal to the min size) */
/* I haven't figured hout how to code a 'slot' in an elegant way.  what i've done is to code a pair of 0/1 matrices for the upper and lower limits.  Then I've colon-multiplied them together.
Ugly, but works */
t1=expected_haddock_lengths:>=$hadd_min_keep
t2=expected_haddock_lengths:<=$hadd_max_keep
ehkeepable=t1:*t2
ehreleasable=ehkeepable:==0

mata drop t1 t2 
/* NOT QUITE FINISHED YET */

/* END OF  EXPECTED HADDOCK */

/*2.  Check the line-drops.  Set entries the keep-length and and release-length matrices equal to zero for fish which are never caught */
for (i=1; i<=rows(ehkeepable); i++) {
	if (ehrand[i,1]<$haddock_upper_bound){
		ehkeepable[|i,ehrand[i,1]+1\ i,$haddock_upper_bound|]=J(1,$haddock_upper_bound-ehrand[i,1],0)
		ehreleasable[|i,ehrand[i,1]+1\ i,$haddock_upper_bound|]=J(1,$haddock_upper_bound-ehrand[i,1],0)
	}
	else { /* DON'T DO anything if CRAND=the upper bound */
	}	
	
}


/* 4.  Check the bag limit: This takes a very long time. */
/* initialize the matrix which is 1 when the trip can continue 
	1== Bag not hit AND CRAND not hit
	0 == bag hit OR CRAND hit*/


/* Increment if fish is long enough to keep: This is the running number of fish in the bag.*/
leq_ehbag_limit_and_ehrand=J($numtrips, $haddock_upper_bound,0)
for (i=1; i<=rows(ehkeepable); i++) {
	leq_ehbag_limit_and_ehrand[i,.] =runningsum(ehkeepable[|i,1\i,$haddock_upper_bound|])
}
/* LOGICAL SETS TO 1 if bag not hit and 0 if bag hit.*/
leq_ehbag_limit_and_ehrand=leq_ehbag_limit_and_ehrand:<=$codbag


/* LOGICAL SETS TO 1 if bag not hit and 0 if bag hit OR EHRAND hit. <-- I believe this step is not strictly necessary since we've marked the uncaught fish in the eckeepable matrix already. */
for (i=1; i<=rows(leq_ehbag_limit_and_ehrand); i++) {
	if (ehrand[i,1]<$haddock_upper_bound){
		leq_ehbag_limit_and_ehrand[|i,ehrand[i,1]+1\ i,$haddock_upper_bound|]=J(1,$haddock_upper_bound-ehrand[i,1],0)
	}
	else {
	}
}

/*Compute expected cod kept and expected cod released */
/* These are matrices which are ($numtrips x $haddock_upper_bound).  The entries are either zeros or ones.  */
ehadd_kept=leq_ehbag_limit_and_ehrand:*ehkeepable 
ehadd_released=leq_ehbag_limit_and_ehrand:*ehreleasable



/* These are counts in each trip */
ehkept=rowsum(ehadd_kept)
ehrel=rowsum(ehadd_released)



end
timer off 1
timer list
clear

getmata ehkept ehrel ehrand eckept ecrel ecrand
