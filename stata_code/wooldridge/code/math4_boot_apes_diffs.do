capture program drop math4_boot

program math4_boot, rclass

glm math4 lavgrexp alavgrexp lunch alunch lenroll alenroll y96-y01 if year>1994, fa(bin) link(probit) cluster(distid)

/* predict xb.  Then make a new variable that subtracts off the 'actual' b1x1 and then adds back on b1 * x1 evaluated at particular values. Then do the normalden transform */

predict x1b1hat, xb
gen x1b1hat05 = x1b1hat - _b[lavgrexp]*lavgrexp + _b[lavgrexp]*log(5943)
gen scale05 = normalden(x1b1hat05)
gen pe05 = scale05*_b[lavgrexp] if y01
gen x1b1hat25 = x1b1hat - _b[lavgrexp]*lavgrexp + _b[lavgrexp]*log(6317)
gen scale25 = normalden(x1b1hat25)
gen pe25 = scale25*_b[lavgrexp] if y01
gen x1b1hat50 = x1b1hat - _b[lavgrexp]*lavgrexp + _b[lavgrexp]*log(6623)
gen scale50 = normalden(x1b1hat50)
gen pe50 = scale50*_b[lavgrexp] if y01
gen x1b1hat75 = x1b1hat - _b[lavgrexp]*lavgrexp + _b[lavgrexp]*log(7136)
gen scale75 = normalden(x1b1hat75)
gen pe75 = scale75*_b[lavgrexp] if y01
gen x1b1hat95 = x1b1hat - _b[lavgrexp]*lavgrexp + _b[lavgrexp]*log(8744)
gen scale95 = normalden(x1b1hat95)
gen pe95 = scale95*_b[lavgrexp] if y01

* First Stage
reg lavgrexp lfound lfndy96-lfndy01 lunch alunch lenroll alenroll y96-y01 lexppp94 le94y96-le94y01 if year>1994, robust cluster(distid)
predict v2hat, resid
* Second Stage
glm math4 lavgrexp v2hat lunch alunch lenroll alenroll y96-y01 lexppp94 le94y96-le94y01 if year>1994, fa(bin) link(probit) cluster(distid)

predict x1b1hata, xb
gen x1b1hat05a = x1b1hata - _b[lavgrexp]*lavgrexp + _b[lavgrexp]*log(5943)
gen scale05a = normalden(x1b1hat05a)
gen pe05a = scale05a*_b[lavgrexp] if y01
gen x1b1hat25a = x1b1hata - _b[lavgrexp]*lavgrexp + _b[lavgrexp]*log(6317)
gen scale25a = normalden(x1b1hat25a)
gen pe25a = scale25a*_b[lavgrexp] if y01
gen x1b1hat50a = x1b1hata - _b[lavgrexp]*lavgrexp + _b[lavgrexp]*log(6623)
gen scale50a = normalden(x1b1hat50a)
gen pe50a = scale50a*_b[lavgrexp] if y01
gen x1b1hat75a = x1b1hata - _b[lavgrexp]*lavgrexp + _b[lavgrexp]*log(7136)
gen scale75a = normalden(x1b1hat75a)
gen pe75a = scale75a*_b[lavgrexp] if y01
gen x1b1hat95a = x1b1hata - _b[lavgrexp]*lavgrexp + _b[lavgrexp]*log(8744)
gen scale95a = normalden(x1b1hat95a)
gen pe95a = scale95a*_b[lavgrexp] if y01


gen diff05 = pe05a - pe05
sum diff05 if y01
return scalar dape05 = r(mean)
gen diff25 = pe25a - pe25
sum diff25 if y01
return scalar dape25 = r(mean)
gen diff50 = pe50a - pe50
sum diff50 if y01
return scalar dape50 = r(mean)
gen diff75 = pe75a - pe75
sum diff75 if y01
return scalar dape75 = r(mean)
gen diff95 = pe95a - pe95
sum diff95 if y01
return scalar dape95 = r(mean)

drop v2hat x1b1hat x1b1hata x1b1hat05 x1b1hat05a scale05 scale05a pe05 pe05a diff05 x1b1hat25 x1b1hat25a scale25 scale25a pe25 pe25a diff25 x1b1hat50 x1b1hat50a scale50 scale50a pe50 pe50a diff50 x1b1hat75 x1b1hat75a scale75 scale75a pe75 pe75a diff75 x1b1hat95 x1b1hat95a scale95 scale95a pe95 pe95a diff95 


end


*Bootstrapped SE within districts
bootstrap r(dape05) r(dape25) r(dape50) r(dape75) r(dape95), reps(500) seed(123) cluster(distid) idcluster(newid): math4_boot

program drop math4_boot



