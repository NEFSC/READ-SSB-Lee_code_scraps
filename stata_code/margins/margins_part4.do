log using "margins_checking.smcl", replace
version
about

clear
scalar drop _all
macro drop _all
set obs 1000
set seed 12345
pause off

gen x=runiform(1,8)
generate e = rnormal(0,5)
/* y=2*x^2 + 3*x + e */

gen y=2*x^2 + 3*x + e

regress y c.x##c.x 


/* Mathematically from the DGP
dydx = 4x + 3
eydx =(4x+3)/y
dyex = (4x+3)*x
eyex= (4x+3)*(x/y)

*/

/* pull out the ybar,  xbar , and xb_bar*/
summ

qui summ y
local ybar=r(mean)
qui summ x
local xbar=r(mean)

predict xb, xb
qui  summ xb
local xbbar=r(mean)

/* This works */
/* dydx by hand */

/* a. atmeans */

scalar dydx=(_b[x]+ 2*_b[c.x#c.x]*`xbar')
scalar list dydx
margins, dydx(x) atmeans

pause




/* b. over the sample*/

gen dydx=(_b[x]+ 2*_b[c.x#c.x]*x)
egen tdydx=total(dydx)
replace tdydx=tdydx/e(N)
list tdydx in 1

margins, dydx(x)
pause







/* dyex by hand */

/* a. atmeans */

scalar dyex=(_b[x]+ 2*_b[c.x#c.x]*`xbar') *`xbar'
scalar list dyex
margins, dyex(x) atmeans

pause

/* b. over the sample*/

gen dyex=(_b[x]+ 2*_b[c.x#c.x]*x)*x
egen tdyex=total(dyex)
replace tdyex=tdyex/e(N)
list tdyex in 1

margins, dyex(x)


pause








/* Now this works! */
/* eydx by hand */

/* a. atmeans */

scalar eydx_wrong=(_b[x]+ 2*_b[c.x#c.x]*`xbar' )/`ybar'
scalar eydx=(_b[x]+ 2*_b[c.x#c.x]*`xbar' )/(_b[x]*`xbar'+ _b[c.x#c.x]*`xbar'*`xbar'+_b[_cons])


scalar list eydx eydx_wrong
margins, eydx(x) atmeans
/* b. over the sample*/
pause
gen eydx_wrong=(_b[x]+ 2*_b[c.x#c.x]*x)/y

gen eydx=(_b[x]+ 2*_b[c.x#c.x]*x)/(_b[x]*x+ _b[c.x#c.x]*x*x+_b[_cons])

egen teydx=total(eydx)
egen teydx_wrong=total(eydx_wrong)
replace teydx_wrong=teydx_wrong/e(N)

replace teydx=teydx/e(N)
list teydx in 1

margins, eydx(x)


pause





















/* This does not work */
/* eyex by hand */

/* a. atmeans */

scalar eyex_wrong=(_b[x]+ 2*_b[c.x#c.x]*`xbar' )/(`ybar'/`xbar')
 scalar eyex=(_b[x]+ 2*_b[c.x#c.x]*`xbar' )/(((_b[x]*`xbar'+ _b[c.x#c.x]*`xbar'*`xbar'+_b[_cons]))/`xbar')
scalar list eyex
margins, eyex(x) atmeans
/* b. over the sample*/
pause
gen eyex=(_b[x]+ 2*_b[c.x#c.x]*x)/(((_b[x]*x+ _b[c.x#c.x]*x*x+_b[_cons]))/x)
egen teyex=total(eyex)
replace teyex=teyex/e(N)
list teyex in 1

margins, eyex(x)




log close











