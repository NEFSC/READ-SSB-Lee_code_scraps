cd "/home/mlee/Desktop/scallop temp"
use "/home/mlee/Desktop/scallop temp/zzzz_5.dta", clear
set matsize 4000
set scheme s2color
*twoway (kdensity perc_U) (kdensity perc_11)(kdensity perc_21) (kdensity perc_31) (kdensity perc_u), legend(rows(2) order(1 "U10" 2 "11-20" 3 "21-30" 4 "31+" 5 "unclassified"))
*graph export fractions.png, as(png) replace

local areas CA1_first_yr CA1_second_yr CA1_third_yr  CA2_first_yr CA2_second_yr CA2_third_yr  DMV_first_yr DMV_second_yr DMV_third_yr NLSAA_first_yr NLSAA_second_yr NLSAA_third_yr ETAA_first_yr ETAA_second_yr ETAA_third_yr ETAA_fourth_yr HC_first_yr HC_second_yr HC_third_yr HC_fourth_yr HC_fifth_yr
egen Ti=sum(1), by(permit)

drop if Ti==1

/*This has no unobserved het */
fracreg probit perc_U10_landed i.group2 i.group2_treat1  i.group2_treat2  i.group3  i.group3_treat1  i.group3_treat2 i.fishing_year ib3.month i.(`areas') i.Trawl_gear c.Latitude

foreach var of varlist jan-dec FY2004-FY2015 Latitude Trawl_gear{
	egen `var'b=mean(`var'), by(permit)
}

/*Plain old Fractional Probit */
fracreg probit perc_U10_landed i.group2 i.group2_treat1  i.group2_treat2  i.group3  i.group3_treat1  i.group3_treat2 i.fishing_year ib3.month  i.(`areas') i.Trawl_gear c.Latitude janb-Latitudeb

foreach var of local areas{
egen `var'b=mean(`var'), by(permit)
}


/* CRE Fractional Probit */

fracreg probit perc_U10_landed i.group2 i.group2_treat1  i.group2_treat2  i.group3  i.group3_treat1  i.group3_treat2 i.fishing_year ib3.month  i.(`areas') i.Trawl_gear c.Latitude janb-Trawl_gearb CA1_first_yrb-HC_fifth_yrb

/* this runs the fracreg with 10 bootstrap reps it takes a while.
fracreg probit perc_U10_landed i.group2 i.group2_treat1  i.group2_treat2  i.group3  i.group3_treat1  i.group3_treat2 i.fishing_year ib3.month  i.(`areas') i.Trawl_gear c.Latitude janb-Trawl_gearb CA1_first_yrb-HC_fifth_yrb, vce(bootstrap, rep(10) cluster(permit))
*/

/*wooldridge suggests modeling heteroskedsaticity where the variance of the fixed effect is related to the number of times a cross-sectional unit appears in the dataset. remember, small T.
Instead, I'll generate T_i, and then include T_i, T_i^2, and T_i^3 in the heteroskedastic eqn.
*/

/* CRE Heteroskedastic Fractional Probit */

fracreg probit perc_U10_landed i.group2 i.group2_treat1  i.group2_treat2  i.group3  i.group3_treat1  i.group3_treat2 i.fishing_year ib3.month  i.(`areas') i.Trawl_gear c.Latitude janb-Trawl_gearb CA1_first_yrb-HC_fifth_yrb, het(c.Ti##c.Ti##c.Ti)
est store p10_hetprob
/*

fracreg probit perc_11  i.group2 i.group2_treat1  i.group2_treat2  i.group3  i.group3_treat1  i.group3_treat2 i.fishing_year ib3.month  i.(`areas') i.Trawl_gear c.Latitude janb-Trawl_gearb CA1_first_yrb-HC_fifth_yrb, het(c.Ti##c.Ti##c.Ti)
est store p11_hetprob


fracreg probit perc_21 i.group2 i.group2_treat1  i.group2_treat2  i.group3  i.group3_treat1  i.group3_treat2 i.fishing_year ib3.month  i.(`areas') i.Trawl_gear c.Latitude janb-Trawl_gearb CA1_first_yrb-HC_fifth_yrb, het(c.Ti##c.Ti##c.Ti)
est store p21_hetprob


fracreg probit perc_31 i.group2 i.group2_treat1  i.group2_treat2  i.group3  i.group3_treat1  i.group3_treat2 i.fishing_year ib3.month  i.(`areas') i.Trawl_gear c.Latitude janb-Trawl_gearb CA1_first_yrb-HC_fifth_yrb, het(c.Ti##c.Ti##c.Ti)
est store p31_hetprob

fracreg probit perc_un i.group2 i.group2_treat1  i.group2_treat2  i.group3  i.group3_treat1  i.group3_treat2 i.fishing_year ib3.month  i.(`areas') i.Trawl_gear c.Latitude janb-Trawl_gearb CA1_first_yrb-HC_fifth_yrb, het(c.Ti##c.Ti##c.Ti)
est store punc_hetprob


est table p10_hetprob p11_hetprob p21_hetprob, b se keep(group2  group2_treat1  group2_treat2  group3  group3_treat1 group3_treat2) equations(1)*/
/*****************************************************************************/
/*****************************************************************************/
/* Average Partial effects */
/*****************************************************************************/
/*****************************************************************************/


/*Predict at actual data */
est restore p10_hetprob
est replay
predict xb1, xb
gen scale0=normalden(xb1)


/*to get the APE of a continuous variable, multiply the coefficient by the scale factor (phi(xb)). Then averge over the obs */
gen ape_lat=_b[Latitude]*scale0
qui summ ape_lat
*return scalar r(mean)


/*to get the APE of a single binary variable, Predict with this variable set to 0 and set to 1.*/

gen xb_A0=xb1-_b[perc_U10_landed:Trawl_gear]*Trawl_gear

gen scale_A0=normalden(xb_A0)
gen xb_A1=xb1-_b[perc_U10_landed:Trawl_gear]*Trawl_gear +  _b[perc_U10_landed:Trawl_gear]*1
gen scale_A1=normalden(xb_A1)

gen ape_Trawl=scale_A1-scale_A0

qui summ ape_Trawl
*return scalar r(mean)






/*Lets do NO IFQ program at all(group2_treat2)=0; group2_treat1=0; group3_treat1=0; group3_treat2=0 */
foreach var of varlist group2_treat1 group2_treat2 group3_treat1 group3_treat2 {
replace `var'=0
}
predict xb_null, xb
gen scale2=normalden(xb_null)
summ scale scale2



/* predict at group2treat2=1 IFQ program*/
gen xb_IFQ=xb_null+_b[group2_treat2]*1 + _b[group2]*1
gen scale3=normalden(xb_IFQ)
summ scale scale3

gen pe=scale3-scale2


/* predict at group2treat2=0 for group2*/
gen xb_IFQa=xb_null + _b[group2]*1
gen scale4=normalden(xb_IFQa)
summ scale*


/* APE of the treatement on the treated group */
gen pe1=scale3-scale4 






/*This is the average discrete effect of IFQ - NO IFQ for the GROUP 2 boats */
summ pe1 if group2==1
summ pe1 if group2==1 | group3==1



