cd "/home/mlee/Desktop/scallop temp"

*global url "https://mitpress.mit.edu/sites/default/files/titles/content/wooldridge/"
*copy $url/statafiles.zip woold2nd.zip, replace
*unzipfile woold2nd.zip
use meap94_98, clear

gen tobs3=tobs==3
gen tobs4=tobs==4

*egen lavgrexpb = mean(lavgrexp), by(schid)
*egen lunchb = mean(lunch), by(schid)
*egen lenrolb = mean(lenrol), by(schid)
*egen y95b = mean(y95), by(schid)
*egen y96b = mean(y96), by(schid)
*egen y97b = mean(y97), by(schid)
*egen y98b = mean(y98), by(schid)
gen tobs3_lavgrexp = tobs3*lavgrexp
gen tobs4_lavgrexp =tobs4*lavgrexp

xtreg math4 lavgrexp lunch lenrol y95 y96 y97 y98, fe cluster(schid)
xtreg math4 lavgrexp tobs3_lavgrexp tobs4_lavgrexp lunch lenrol y95 y96 y97 y98, fe cluster(schid)


replace math4 = math4/100
replace lunch = lunch/100

/* wooldridge codes this as an MLE by hand */

fracreg probit math4 lavgrexp lunch lenrol y95 y96 y97 y98 lavgrexpb lunchb lenrolb y95b y96b y97b y98b tobs3 tobs4, het(tobs3 tobs4) vce(cluster schid)

fracreg probit math4 lavgrexp lunch lenrol y95 y96 y97 y98 lavgrexpb lunchb lenrolb y95b y96b y97b y98b tobs3 tobs4, vce(cluster schid)
glm math4 lavgrexp lunch lenrol y95 y96 y97 y98 lavgrexpb lunchb lenrolb y95b y96b y97b y98b tobs3 tobs4, fam(bin) link(probit) vce(cluster schid)
/* note that this produces the same coeff estimates and regular probit and the GLM produce the same estimates because they're the same thing.
The heteroskedastic probit is a little different.

The year_"b" dummies are now a little different -- they're capturing some of the unbalanced nature of the data. 
*/
