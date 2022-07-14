use homicide1990
spset
spmatrix create contiguity W
spregress hrate ln_population ln_pdensity gini, gs2sls dvarlag(W) impower(1)
est store sp1

spregress hrate ln_population ln_pdensity gini, gs2sls dvarlag(W) impower(2)
est store sp2

/* make spatial lags */
spgenerate Wh=W*hrate
spgenerate Wpop=W*ln_population
spgenerate Wpdens=W*ln_pdensity
spgenerate Wgini=W*gini


spgenerate WWh=W*Wh
spgenerate WWpop=W*Wpop
spgenerate WWpdens=W*Wpdens
spgenerate WWgini=W*Wgini

/* In this model, we want to have a spatial lag of the independent variable (SAR). Simply putting wh on the RHS is not okay, it is simultanous, by construction and the parameter estimates are biased.*/
/* Here is a way to see it*/

regress hrate ln_population ln_pdensity gini Wh
est store naive_sp

est table sp1 sp2 naive_sp, equations(1:1:1, 2:2:.) b se

/* here is a 'simple IV procedure, where I instrument by hand */
ivregress 2sls hrate ln_population ln_pdensity gini (Wh=Wpop Wpdens Wgini)
est store naive_2sls

/*The naive 2sls estimates are really close to the g2sls model.  But not identical */
est table sp1 naive_sp naive_2sls, equations(1:1:1, 2:.:.) b se


/*********************Control Function approach exactly matches the IV approach ******************************/

regress Wh Wpop Wpdens Wgini ln_population ln_pdensity gini
cap drop r1
predict r1, resid

/* estimate with a control function */
regress hrate ln_population ln_pdensity gini Wh r1
est store cf

est table sp1 naive_sp naive_2sls cf , equations(1:1:1:1, 2:.:.:.) b se


/******************************2nd spatial lags as instruments also *********************************/
ivregress 2sls hrate ln_population ln_pdensity gini (Wh=Wpop Wpdens Wgini WWpop WWpdens WWgini)
est store IM2_2sls


/*********************Control Function approach exactly matches the IV approach ******************************/
regress Wh Wpop Wpdens Wgini ln_population ln_pdensity gini WWpop WWpdens WWgini
predict r2, resid
regress hrate ln_population ln_pdensity gini Wh r2
est store cf2

est table cf cf2, b se
est table cf2 sp2 IM2_2sls, equations(1:1:1)


spregress hrate ln_population ln_pdensity gini, gs2sls dvarlag(W) impower(1)
est store sp
spregress hrate ln_population ln_pdensity gini, ml dvarlag(W)
est store spml

