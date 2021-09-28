/* A small program to compute the Gini coefficient */

/* Min-Yang.Lee@noaa.gov */
/* (508) 495-2026*/
/* August 2, 2012 */


/* Algebraic formula found in Hale, 2003 "The Theoretical Basis of Popular Inequality Measures"

     Sum(   (2*Rank_i)- (N-1))*Rev_i)/(N**2*Rev_average)

     where Rank_i is rank for the ith vessel sorted in ascending order, Rev_i is revenue (can use pounds) for the ith vessel,
     N is total number of vessels, N**2 denotes number of vessels squared, and Rev_average is mean revenue*/

/* Read in the dataset */
/* the dataset contains a variable "ground" which is revenue.  It probably also contains other stuff.  */
cd "/home/mlee/Documents/Workspace/technical folder/do file scraps"
use "gini_data_revenue.dta", clear


/* Compact and hard to follow code.  */
/* Replace the variable "ground" with the name of the revenue variable.*/

quietly summarize ground, meanonly
scalar Rev_average=r(mean)
sort ground, stable
egen gini=total(((2*_n)-(_N-1))*ground/(_N^2*Rev_average))

disp gini[1]

/* 0.68922794 */



/**************  This section computes the gini coefficient in a way which is easier to follow **************/
/**************  The only output is a scalar which contains the Gini coefficient **************/

/*Denominator */
/*Extract Average revenue. Then store the "denominator" in a scalar.*/
quietly summarize ground, meanonly
scalar Rev_average=r(mean)
scalar denom=_N^2*Rev_average

/*Assign tempnames for rank, numerator, summand, and gini */ 
tempvar rank numerator summand gini2

/*Numerator*/
/* Construct rank for each observation -- note the stable option is probably overkill */
sort ground, stable
gen `numerator'=((2*_n)-(_N-1))*ground

/*Generate the Summand*/
gen `summand'=`numerator'/denom
/* Sum everything up */
egen `gini2'=total(`summand')

/* Put it in a scalar and display it */
scalar gini_coeff=`gini2'[1]
disp scalar(gini_coeff)

egen mde=mdev(ground)


/* compute the Absolute Mean Difference */
quietly summarize ground, meanonly
scalar Rev_average=r(mean)

tempfile t2
preserve
rename ground g2
save `t2'

restore


cross using `t2'
count


/*compute the AMD */
gen double rd=abs(ground-g2)
egen double td=total(rd)

scalar AMD=td[1]/_N

scalar RMD=AMD/(2*Rev_average)

scalar list



/* This section computes the Gini as 1-"O"
O=sum (min(pi, 1/S))
pi is the share of total
 it doesnt work yet

use "gini_data_revenue.dta", clear

egen double td=total(ground)
gen share=ground/td

gen summand=min(share, 1/_N)
collapse (sum) summand
gen Gini=1-summand

list Gini

*/

