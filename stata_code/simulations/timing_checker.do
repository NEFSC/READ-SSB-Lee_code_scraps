clear
timer clear
set obs 40
set seed 123
gen id=_n
gen ui=rnormal()
expand 300
bysort id: gen t=_n

gen vt=.25*rnormal()
bysort t (id): replace vt=vt[1]

gen x=runiform()
gen eit=rnormal()
gen y=x+ui + vt+eit
regress y x

tsset id t


timer on 1
xtreg y x i.t, fe 
est store xt_id
timer off 1

tsset t id

timer on 2
xtreg y x i.id, fe
est store xt_t

timer off 2



timer on 3
areg y x i.id, absorb(t)
est store areg_t

timer off 3

timer on 4
areg y x i.t, absorb(id)
est store areg_id
timer off 4

est table xt_id xt_t areg_t areg_id, keep(x) b se
timer list


/*All give the exact same coefficient results. 
setting the panel id to the "big" dimension or absorbing the big dimension makes the model go faster.
*/





