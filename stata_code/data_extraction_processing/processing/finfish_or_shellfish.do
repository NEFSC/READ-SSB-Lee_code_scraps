gen finfish=1
replace finfish=0 if nespp3>=700
gen shellfish=0
replace shellfish=1 if nespp>=700 & nespp3<=804
replace shellfish=1 if nespp3==899
gen other_stuff=0
replace other_stuff=1 if nespp3>=805 & nespp3<=888
