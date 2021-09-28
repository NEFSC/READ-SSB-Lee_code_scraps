/* this is code that reproduces Table 2 of Halleck Vega and Ellhorst, 2015.  The SLX model. Journal of Regional Science. 55(3) 339-363 */


clear
global wd "C:/Users/Min-Yang.Lee/Documents/technical/do file scraps/spatial"

cd "$wd"


use elhorst_smoke_weights_matrix.dta, clear
gen state=_n
spset state
spmatrix fromdata Wspectral=A-AT, normalize(spectral) replace
spmatrix fromdata Wrow=A-AT, normalize(row) replace
spmatrix fromdata Wraw=A-AT, normalize(none) replace



use elhorst_smoke.dta, clear

/* this reproduces OLS (Table 2, column 1)*/
reghdfe logc logp logy, absorb(year state)
assert state~=.
assert  year~=.
bysort state year: assert _N==1
xtset state year
spbalance
spset state 



/* so does this, although the LL doesn't match  */
spregress logc logp logy i.year i.state, ml

/* this is a different estimator, so not surprising that it doesn't match the ml */
spregress logc logp logy i.year i.state, gs2sls
/* so does this, LL doesn't quite match */
spxtregress logc logp logy i.year, fe

/* Vega and Elhorst use row-normalized contiguity */
/*col 2 (SAR), this mostly matches*/
spxtregress logc logp logy i.year, fe dvarlag(Wrow)
estat impact logp logy

/*col 3 (SEM)*/
spxtregress logc logp logy i.year, fe error(Wrow)
/*col 4 (SLX)*/
spxtregress logc logp logy i.year, fe ivarlag(Wrow: logp logy)
estat impact logp logy




/*col 5 (SAC)
This mostly matches*/
spxtregress logc logp logy i.year, fe dvarlag(Wrow) error(Wrow)
estat impact logp logy

/*col 6 (SDM)
This mostly matches*/
spxtregress logc logp logy i.year, fe dvarlag(Wrow) ivarlag(Wrow: logp logy )
estat impact logp logy


/*col 7 (SDEM)
This mostly matches*/
spxtregress logc logp logy i.year, fe error(Wrow) ivarlag(Wrow: logp logy )
estat impact logp logy

/*col 8 (GNS)
This does not match*/
spxtregress logc logp logy i.year, fe  dvarlag(Wrow) error(Wrow) ivarlag(Wrow: logp logy )
estat impact logp logy


/* setup to do some of these by hand */

gen Wp=.
gen Wy=.
gen Wc=.


/* I have 30 years, but I only have a nxn spatial matrix stored. So I have to fill in my spatial lags in a loop. 
The loop isn't needed if  i have an nTx nT spatial weights matrix*/

forvalues t=0/30 {
capture drop tmp tmp2 tmp3
	capture spgenerate tmp = Wrow*logp if year == `t'
	capture spgenerate tmp2 = Wrow*logy if year == `t'
	capture spgenerate tmp3 = Wrow*logc if year == `t'


	capture replace Wp = tmp if year == `t'
	capture replace Wy = tmp2 if year == `t'
	capture replace Wc = tmp3 if year == `t'

} 


/* just for fun, here's the SLX without time effects */
spxtregress logc logp logy, fe ivarlag(Wrow: logp logy)
est store slxFE



/* These are all the same */
/* just for fun, here's the SLX with time effects AGAIN*/
spxtregress logc logp logy i.year, fe ivarlag(Wrow: logp logy)
est store slxFEY




/*col 4 (SLX) by hand*/
/* by hand */
xtreg logc logp logy Wp Wy i.year, fe 
est store slx_by_handFE

areg logc logp logy Wp Wy i.year, absorb(state) 

reghdfe logc logp logy Wp Wy , absorb(state year) 
est store reghdfe

regress logc logp logy Wp Wy ib0.year ib1.state 


/* 27 parameters -- 4 main, 3 year, 19 state, and a constant . the "base" is state 1 in year 0 */
gmm (logc- {xb: logp logy Wp Wy ib0.year ib1.state} -{_cons}), instruments(logp logy Wp Wy  ib0.year ib1.state) onestep
est store gmmSLX

