/* reproduce P and W 2008 */

local wd "/home/mlee/Desktop/scallop temp"
cd "`wd'"
use meap92_01.dta, clear
tsset distid year
/*
bysort year: centile(found)
bysort year: centile(rexppp), centile(10 25 50 75 90)*/

/*linear model 5.1 */

xtreg math4 c.lavgrexp c.lunch c.lenroll  i.year if year>=1995, fe vce(cluster distid)
est store pw51


/*fractional probit QMLE under exogeneity */
fracreg probit math4 c.lavgrexp c.lunch c.lenroll alunch alenroll alavgrexp i.year if year>=1995, vce(cluster distid)
est store pw53_frac_prob

/*scale factor */
predict xb1hat, xb

gen scale=normalden(xb1hat)
summ scale
scalar sf1=r(mean)

/*
The bootstrap routines compute standard errors of the APE's with a block bootstrap.  It takea about a minute to run the block bootstrap on the sample dataset.
It doesn't quite match, but my guess is that is because something is a little different with the RNG between stata 14 and whatever version P&W used.
fracreg probit goes slightly faster than glm
xtgee is a bit slower.*/



xtgee math4 c.lavgrexp c.lunch c.lenroll alunch alenroll alavgrexp i.year if year>=1995, link(probit) family(binomial) corr(exch) robust
est store pw53_gee

predict xb2hat, xb

gen scale2=normalden(xb2hat)
summ scale2
scalar sf2=r(mean)

/*The corr(exch) means that the correlation matrix has 1 on the diagonal and the same entry (rho) in all the off diagonal terms. The e(R) matrix is 7x7, since this is a panel with 7 repeated observations per cross-sectional unit */

mat rho=e(R)
mat list rho

/* IV methods  Table 5  
Stage 1: regress lavgrexp on the existing RHS variables and log(found), log(rexpp in 1994)
*/

regress lavgrexp c.lfound#i.year c.lunch c.alunch c.lenroll c.alenroll i.year i.year#c.lexppp94, cluster(distid)
predict resid, resid



/*These standard errors are wrong, but the coefficients are correct. The SEs should be adjusted for the first stage regression. Or you can Bootstrap like P and W did. */
fracreg probit math4 c.lavgrexp resid c.lunch c.lenroll alunch alenroll i.year i.year#c.lexppp94 if year>=1995, vce(cluster distid)

regress math4 c.lavgrexp resid c.lunch c.lenroll alunch alenroll i.year i.year#c.lexppp94 if year>=1995, vce(cluster distid)

