log using myt.smcl, replace
about
webuse nlswork, clear
gen age2=age^2

/* I want to estimate:
lnw_{it} = b1*age_it + b2*age_it^2 + u_i + e_it
and perform a hausman test for the appropriateness of RE vs. FE. 
*/


/* fixed effects */
xtreg ln_w  c.age c.age#c.age, fe
est store fe_factor

xtreg ln_w  age age2, fe
est store fe_by_hand

/* random effects */
xtreg ln_w  c.age c.age#c.age, re
est store re_factor

xtreg ln_w  age age2, re mle
est store re_by_hand


/* xtmixed */
xtmixed ln_w  c.age c.age#c.age || idcode:, mle
est store mixed_factor

xtmixed ln_w  age age2 || idcode:, mle
est store mixed_by_hand

/* display regression results */
est table fe_factor fe_by_hand re_factor re_by_hand mixed_factor mixed_by_hand, se equations(1)

/*Hausman test for random vs fixed effects */
hausman fe_by_hand re_by_hand, equations(1:1)
hausman fe_by_hand mixed_by_hand, equations(1:1)

/*Using factor notation, I get the error message:
age#c:  operator invalid
*/
hausman fe_factor re_factor, equations(1:1)
hausman fe_factor mixed_factor, equations(1:1)


/* Note: If I use
xtreg ln_w c.age##c.age, fe

I also get an error.*/

/**** BEGIN COMMENTED OUT ***

The "i" notation seems to work properly: 
xtreg ln_w age i.union, fe
est store fe_i

xtreg ln_w age i.union, re mle
est store re_i
xtmixed ln_w  age i.union || idcode:, mle
est store mixed_i

hausman fe_i re_i, equations(1:1)
hausman fe_i mixed_i, equations(1:1)

est table fe_i re_i mixed_i, se equations(1)


***END COMMENTED OUT****/
log close
