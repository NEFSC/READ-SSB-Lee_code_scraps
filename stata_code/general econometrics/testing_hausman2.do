webuse nlswork, clear
gen age2=age^2


/* fixed effects */
xtreg ln_w  age age#age, fe
est store fe_factor

xtreg ln_w  age age2, fe
est store fe_by_hand

/* random effects */
xtreg ln_w  age age#age, re
est store re_factor

xtreg ln_w  age age2, re mle
est store re_by_hand


/* xtmixed */
xtmixed ln_w  age age#age || idcode:, mle
est store mixed_factor

xtmixed ln_w  age age2 || idcode:, mle
est store mixed_by_hand

/* display regression results */
est table fe_factor fe_by_hand re_factor re_by_hand mixed_factor mixed_by_hand, se equations(1)

/*Hausman test for random vs fixed effects */
hausman fe_by_hand re_by_hand, equations(1:1)

/*Using factor notation, I get an error*/
hausman fe_factor re_factor, equations(1:1)


/*Hausman test for random vs fixed effects */
hausman fe_by_hand mixed_by_hand, equations(1:1)

/*Using factor notation, I get an error*/
hausman fe_factor mixed_factor, equations(1:1)


/* Note: If I use
xtreg ln_w age##age, fe

I also get an error.*/

/* The "i" notation seems to work properly: */
xtreg ln_w age i.union, fe
est store fe_i

xtreg ln_w age i.union, re mle
est store re_i

xtmixed ln_w  age i.union || idcode:, mle
est store mixed_i

hausman fe_i re_i, equations(1:1)
hausman fe_i mixed_i, equations(1:1)

est table fe_i re_i mixed_i, se equations(1)
