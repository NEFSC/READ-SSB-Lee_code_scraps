use "/home/mlee/Documents/Workspace/technical folder/do file scraps/greene_examples/greenef51.dta"
gen qdate=yq(Year, qtr)
order qdate
format qdate %tq
tsset qdate
*tsline realcons realdpi

/* example 12.3 -- phillips curve*/
replace infl=. if _n==1
replace realint=. if _n==1
gen lc=ln(realcons)
gen linc=ln(realdpi)

regress d.infl u
*NAIRU
nlcom -_b[_cons]/_b[unemp]

predict u, resid
regress u l1.u
test L.u=0

/* fig 19.3 */
*tsline lc linc


/* example 19.4 an ARDL(3,3) -- this doesn't quite match*/
regress lc l(0/3).linc l(1/3).lc ibn.qtr, noc


*19.5
/* */
gen dlc=d.lc
gen llc=l1.lc
gen llinc=l1.linc
gen dlinc=d.linc
nl (dlc = {b0} + ({b1}-1)*(llc-{a0}*llinc) +   {b3}*dlinc) if _n>=3
