/* code to follow along with the help on spregress in stata 15 */


clear
global wd "C:/Users/Min-Yang.Lee/Documents/technical/do file scraps/spatial/"

cd "$wd"

copy https://www.stata-press.com/data/r15/homicide1990.dta homicide1990.dta
copy https://www.stata-press.com/data/r15/homicide1990_shp.dta homicide1990_shp.dta


use homicide1990.dta, clear
spset

spmatrix create contiguity W

regress hrate

estat moran, errorlag(W)

/* spatial autoregressive */
spregress hrate ln_population ln_pdensity gini, gs2sls dvarlag(W)

/* spatial autoregressive */
spregress hrate ln_population ln_pdensity gini, gs2sls dvarlag(W)


/* spatial error, spatial autoregressive */
spregress hrate ln_population ln_pdensity gini, gs2sls dvarlag(W) errorlag(W)


/* spatial error, spatial autoregressive, spatial lag */

spregress hrate ln_population ln_pdensity gini, gs2sls dvarlag(W) errorlag(W) ivarlag(W: ln_population ln_pdensity gini)
