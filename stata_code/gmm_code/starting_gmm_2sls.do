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


