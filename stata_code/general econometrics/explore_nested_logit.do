


webuse restaurant, clear

nlogitgen type = restaurant(fast: Freebirds | MamasPizza, family:  CafeEccell | LosNortenos | WingsNmore, fancy: Christophers | MadCows)
	    
nlogittree restaurant type, choice(chosen) case(family_id)
 
 
nlogit chosen cost distance rating || type: income kids, base(family) || restaurant:, noconst case(family_id)

est store restaurant
mat b=e(b)

/* COMPUTE XBs2 */
/* in this example, the first level is the "type" type \in (fast, family, fancy) */
predict xb1, xb hlevel(1)

gen my_xb1=0
replace my_xb1=income*b[1,4]+kids*b[1,5] if type==1
replace my_xb1=income*b[1,6]+kids*b[1,7] if type==3
gen del=my_xb1-xb1

assert abs(del)<=1e-8
drop del my_xb1

/* in this example, the second level is the actual restaurant name \in (Freebirds, MamasPizza, CafeEccell, LostNortenos, WingsNmore, Christophers, MadCows) */
predict xb2, xb hlevel(2)
gen my_xb2=b[1,1]*cost+b[1,2]*distance+b[1,3]*rating

gen del=my_xb2-xb2

assert abs(del)<=1e-8
drop del my_xb2


/* COMPUTE Conditional Probabilities (See equation 4 in the stata manual for nlogit, page 1801) */
gen sxb=0
replace sxb=xb2/b[1,8] if type==1
replace sxb=xb2/b[1,9] if type==2
replace sxb=xb2/b[1,10] if type==3

gen exb=exp(sxb)
bysort family_id type: egen myt=total(exb)
gen mycp=exb/myt


predict condp2, condp hlevel(2)
order type, after(family_id)


gen del=mycp-condp2
assert abs(del)<=1e-8
drop del mycp

/* compute the inclusive values */

gen inc1=0
replace inc1=xb2/b[1,8] if type==1
replace inc1=xb2/b[1,9] if type==2
replace inc1=xb2/b[1,10] if type==3
replace inc1=exp(inc1)
bysort family_id type: egen inc=total(inc1)
replace inc=ln(inc)
predict iv, iv
gen del=iv-inc
assert abs(del)<=1e-8
drop del inc

gen tau_iv=iv*b[1,8] if type==1
replace tau_iv=iv*b[1,9] if type==2
replace tau_iv=iv*b[1,10] if type==3


/* compute probabilities for the first level */

gen num=exp(tau_iv+xb1)
egen t=tag(family_id type)
replace num=. if t==0
bysort family_id: egen den=total(num)

gen my_pr1=num/den
bysort family type: replace my_pr1=my_pr1[1] if my_pr1==.

/* COMPUTE Probabilities (See equation 5 in the stata manual for nlogit, page 1802)*/

/* do the type predictions */
predict pr1, pr hlevel(1) 
gen del=pr1-my_pr1
assert abs(del)<=1e-8
drop my_pr1




/*stata's notation 
T ={1,2,3} are the types of restaurant  in the first level 
R_t ={R_1,R_2,R_3} are the restaurants partitioned into types 
	R1={1,2} = {Freebirds , MamasPizza}
	R2={3,4,5}={CafeEccell, LosNortenos, WingsNmore}
	R3={6,7}={Christophers ,MadCows}
C1 is the first level choice ( from T={1,2,3}.
C2 is the second level choice (from the appropriate set R in the first choice)

z are explanatory variables for the first level with coefficients alpha
x are explanatory variables for the second level with coefficients beta

\nu is xbeta+zalpha
Tau_t are the dissimilarity parameters 
m is a choice in the R_t

*/


