/* reproduce mcdowell */
clear
log using "mcdowell_reproduce.smcl", replace
version 8.1
set seed 2004
mat c1 = (1, .9, .6 \ .9, 1, .75 \ .6, .75, 1)

/*3 error terms, one for each equation, with correlated errors */
drawnorm e1 e2 e3, n(100) mean(0 0 0) sds(10 15 20) corr(c1)
 
mat c2 = (1,-.6,-.009,.49,-.38,.002\-.6,1,-.59,-.608, -.08,-.338\-.009,   -.59,1,-.18,-.11,.144\.49,-.608,-.18,1,.46,.18\-.3 8,-.08,-.11,.46,1,  .004\.002,-.338,.144,.18,.004,1)
 
/*6 explanatory variables with varying amounts of correlations */
drawnorm x11 x12 x21 x22 x31 x32, mean(10 5 19 20 15 12) sds(13 20 27 2 8 22) corr(c2)
 
generate y1 = 100 + 15*x11 + .7*x12 + e1 
generate y2 = 75 + 25*x21 + 20*x22 + e2 
generate y3 = 50 + 15*x31 + 19*x32 + e3


replace y1 =. in 1/3
replace y2 =. in 97/100

replace x31 = . in 25

gen time= _n
save wide, replace
/* This matches exactly */
sureg (y1 x11 x12) (y2 x21 x22) (y3 x31 x32)


quietly regress y1 x11 x12 
foreach v of var y1 x11 x12 { 
replace `v' = `v'/ e(rmse)
}
generate cons1 = 1/e(rmse)


quietly  regress y2 x21 x22

foreach v of var y2 x21 x22 { 
	replace `v' = `v'/ e(rmse)
}
generate cons2 = 1/e(rmse)

foreach v of var y3 x31 x32 { 
	replace `v' = `v'/ e(rmse)
}
generate cons3 = 1/e(rmse)

save rescaled, replace

preserve 
 keep y1 x11 x12 cons1 time
 mark sample 
 markout sample y1 x11 x12 cons1 
 rename y1 y 
 gen id = 1 
 save data1, replace
 
 restore
 preserve 

  keep y2 x21 x22 cons2 time
 mark sample 
 markout sample y2 x21 x22 cons2 
 rename y2 y 
 gen id = 2 
 save data2, replace
 restore

 preserve 
  keep y3 x31 x32 cons3 time
 mark sample 
 markout sample y3 x31 x32 cons3 
 rename y3 y 
 gen id = 3 
 save data3, replace
restore
clear

 
 use data1
 append using data2 
 append using data3
 
 
 
 mvencode x* cons* if sample, mv(0)
 tsset time id
 
 /* this does not quite match */
 xtgee y x* cons*, family(gaussian) link(identity) corr(unstructured) noconstant
 
 
 
 log close
 
 
