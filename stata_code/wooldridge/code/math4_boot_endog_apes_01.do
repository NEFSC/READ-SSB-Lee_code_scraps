capture program drop math4_boot

program math4_boot, rclass

* First Stage
reg lavgrexp lfound lfndy96-lfndy01 lunch alunch lenroll alenroll y96-y01 lexppp94 le94y96-le94y01 if year>1994, robust cluster(distid)
predict v2hat, resid
* Second Stage
glm math4 lavgrexp v2hat lunch alunch lenroll alenroll y96-y01 lexppp94 le94y96-le94y01 if year>1994, fa(bin) link(probit) cluster(distid)

predict x1b1hat, xb
gen x1b1hat05 = x1b1hat - _b[lavgrexp]*lavgrexp + _b[lavgrexp]*log(5943)
gen scale05 = normden(x1b1hat05)
gen pe05 = scale05*_b[lavgrexp] if y01
sum pe05 if y01
return scalar ape05 = r(mean)
gen x1b1hat25 = x1b1hat - _b[lavgrexp]*lavgrexp + _b[lavgrexp]*log(6317)
gen scale25 = normden(x1b1hat25)
gen pe25 = scale25*_b[lavgrexp] if y01
sum pe25 if y01
return scalar ape25 = r(mean)
gen x1b1hat50 = x1b1hat - _b[lavgrexp]*lavgrexp + _b[lavgrexp]*log(6623)
gen scale50 = normden(x1b1hat50)
gen pe50 = scale50*_b[lavgrexp] if y01
sum pe50 if y01
return scalar ape50 = r(mean)
gen x1b1hat75 = x1b1hat - _b[lavgrexp]*lavgrexp + _b[lavgrexp]*log(7136)
gen scale75 = normden(x1b1hat75)
gen pe75 = scale75*_b[lavgrexp] if y01
sum pe75 if y01
return scalar ape75 = r(mean)
gen x1b1hat95 = x1b1hat - _b[lavgrexp]*lavgrexp + _b[lavgrexp]*log(8744)
gen scale95 = normden(x1b1hat95)
gen pe95 = scale95*_b[lavgrexp] if y01
sum pe95 if y01
return scalar ape95 = r(mean)
gen diff95_05 = pe95 - pe05
sum diff95_05
return scalar apediff = r(mean)

drop v2hat x1b1hat x1b1hat05 scale05 pe05 x1b1hat25 scale25 pe25 x1b1hat50 scale50 pe50 x1b1hat75 scale75 pe75 x1b1hat95 scale95 pe95 diff95_05


end


*Bootstrapped SE within districts
bootstrap r(ape05) r(ape25) r(ape50) r(ape75) r(ape95) r(apediff), reps(500) seed(123) cluster(distid) idcluster(newid): math4_boot

program drop math4_boot



