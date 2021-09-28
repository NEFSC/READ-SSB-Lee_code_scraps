


est drop _all
clear
webuse fitness






/*********************************************************************/
/*********************************************************************/
/*Stata user written twopm just does a ols regression and a probit together */
/*********************************************************************/
/*********************************************************************/


twopm hours age i.smoke distance, ll(0) firstpart(probit) secondpart(regress)
est store twopm_linear

/* twopm and churdle do the equations backwards*/
/* the probit part is the same, but not the linear part */
est table twopm_linear ch, equations(1:2, 2:1)


/* twopm is just a convenicence function 

Partha Deb: -twopm- is a "convenience" command, indeed a wrapper for the hurdle first and second parts. So, although Will's code is correct for unconditional -margins- based on the sample of positives, if Guillaume wants -margins- for the conditional second part, he should estimate the -glm- on the subsample of positives as he has suggested. -twopm- produces -margins- for the unconditional, composite model, which is not completely straightforward to construct if one estimates the two parts separately. Hope this helps.

 https://www.statalist.org/forums/forum/general-stata-discussion/general/1338242-conditional-and-unconditional-margins-after-two-part-model
 
 probit and ols separately */

est table twopm_linear ols prob, equations(1:.:1, 2:1:.) b se


/*
Dhreg, Xtdhreg, and Bootdhreg: Commands to Implement Double-Hurdle Regression


https://journals.sagepub.com/doi/abs/10.1177/1536867X1401400405 */