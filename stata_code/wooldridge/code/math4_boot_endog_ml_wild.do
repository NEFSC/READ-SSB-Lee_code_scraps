use meap92_01, clear
global bootreps 30

tempname myposter
tempfile main bootsave 
qui postfile `myposter' b1 b2 b3 b4 ape1 ape2 ape3 using `bootsave' , replace 

* First Stage
*reg lavgrexp lfound lfndy96-lfndy01 lunch alunch lenroll alenroll y96-y01 lexppp94 le94y96-le94y01 if year>1994, robust cluster(distid)
regress lavgrexp c.lfound#i.year c.lunch c.alunch c.lenroll c.alenroll i.year i.year#c.lexppp94 if year>=1995, cluster(distid)
predict v2hat, resid
* Second Stage
*glm math4 lavgrexp v2hat lunch alunch lenroll alenroll y96-y01 lexppp94 le94y96-le94y01 if year>1994, fa(bin) link(probit) cluster(distid)
fracreg probit math4 c.lavgrexp v2hat c.lunch c.lenroll alunch alenroll i.year i.year#c.lexppp94 if year>=1995, vce(cluster distid)

 scalar blavgrexp = _b[lavgrexp]
 scalar blunch = _b[lunch]
 scalar blenroll = _b[lenroll]
scalar bv2hat = _b[v2hat]

predict x1b1hat, xb

gen scale=normalden(x1b1hat)
gen pe1=scale*_b[lavgrexp]
summarize pe1
 scalar ape1=r(mean)
gen pe2=scale*_b[lunch]
summarize pe2
 scalar ape2=r(mean)
gen pe3=scale*_b[lenroll]
summarize pe3
 scalar ape3=r(mean)


predict resid, resid
predict yhat, cm 

save `main', replace
forvalues b = 1/$bootreps { 
use `main', replace
gen temp=runiform()
gen pos = (temp < .5) 
gen wildresid = epshat * (2*pos - 1) ;
gen wildy = yhat + wildresid ;

qui fracreg probit wildy c.lavgrexp v2hat c.lunch c.lenroll alunch alenroll i.year i.year#c.lexppp94 if year>=1995, vce(cluster distid)
 scalar blavgrexp = _b[lavgrexp]
 scalar blunch = _b[lunch]
 scalar blenroll = _b[lenroll]
scalar bv2hat = _b[v2hat]
gen scale=normalden(x1b1hat)
gen pe1=scale*_b[lavgrexp]
summarize pe1
 scalar ape1=r(mean)
gen pe2=scale*_b[lunch]
summarize pe2
 scalar ape2=r(mean)
gen pe3=scale*_b[lenroll]
summarize pe3
 scalar ape3=r(mean)
post `myposter' (scalar(blavgrexp)) (scalar(blunch)) (scalar(blenroll))  (scalar(bv2hat))  (scalar(ape1)) (scalar(ape2))  (scalar(ape3)) , replace 

}


postclose `myposter'




