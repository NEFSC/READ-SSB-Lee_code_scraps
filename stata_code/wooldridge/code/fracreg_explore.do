cd "/home/mlee/Documents/Workspace/technical folder/do file scraps/wooldridge"

use "/home/mlee/Documents/Workspace/technical folder/do file scraps/wooldridge/data/401kpart.dta", clear
/*fracreg probit prate mrate c.age i.sole
est store prob
predict xb, xb
*/


fracreg probit prate mrate c.age i.sole, het(totemp)
est store hetprob


gen xbhand=mrate*_b[prate:mrate] + age*_b[prate:age] + sole*_b[prate:1.sole] +1*_b[prate:_cons]
gen zgamma=_b[lnsigma:totemp]*totemp

gen meat=xbhand/(exp(zgamma))
gen cm_hand=normal(meat) /* this is the conditional mean prediction  and is equal to predict cm, cm*/

drop xbhand meat cm_hand

/* APEs for age */
gen scale=normalden(xbhet/exp(zgamma))
gen ape_age=_b[prate:age]*scale

/*discrete effects for sole are */
gen xb_sole0=xbhet-sole*_b[prate:1.sole] + 0*_b[prate:1.sole]
gen xb_sole1=xbhet-sole*_b[prate:1.sole] + 1*_b[prate:1.sole]

gen scale_sole0=normal(xb_sole0/(exp(zgamma)))
gen scale_sole1=normal(xb_sole1/(exp(zgamma)))
gen ape_sole=scale_sole1-scale_sole0


clear
use "/home/mlee/Documents/Workspace/technical folder/do file scraps/wooldridge/data/meap94_98.dta", clear

gen tobs3_lavgrexp = tobs3*lavgrexp
gen tobs4_lavgrexp =tobs4*lavgrexp

xtreg math4 lavgrexp lunch lenrol y95 y96 y97 y98, fe cluster(schid)
xtreg math4 lavgrexp tobs3_lavgrexp tobs4_lavgrexp lunch lenrol y95 y96 y97 y98, fe cluster(schid)

replace math4=math4/100
replace lunch=lunch/100

gen tobs3=tobs==3
gen tobs4=tobs==4

fracreg probit math4 c.(lavgrexp lunch lenrol  lavgrexpb) ib1994.(year) c.(lunchb lenrolb y95b y96b y97b y98b tobs3 tobs4), het(i.tobs3 i.tobs4) vce(cluster schid)
est store fracprob1


xtset, clear
fracreg probit math4 c.(lavgrexp lunch lenrol  lavgrexpb) ib1994.year c.(lunchb lenrolb y95b y96b y97b y98b tobs3 tobs4), het(i.tobs3 i.tobs4) vce(bootstrap, seed(123) cluster(schid) idcluster(newid) group(newid) reps(200fracreg probit math4 c.(lavgrexp lunch lenrol  lavgrexpb) ib1994.(year) c.(lunchb lenrolb y95b y96b y97b y98b tobs3 tobs4), het(i.tobs3 i.tobs4) vce(cluster schid)
est store fracprob1


xtset, clear
fracreg probit math4 c.(lavgrexp lunch lenrol  lavgrexpb) ib1994.year c.(lunchb lenrolb y95b y96b y97b y98b tobs3 tobs4), het(i.tobs3 i.tobs4) vce(bootstrap, seed(123) cluster(schid) idcluster(newid) group(newid) reps(300))
est store fracprob_boots

est store fracprob_boots

