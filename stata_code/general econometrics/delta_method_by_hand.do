clear
webuse margex

replace y=30 if y==0

regress y c.distance c.age#c.distance
est store main_reg
/* 
y =  a1*treatment + a2*group + a3*age + a4*distance + a5*age*distance + a0 

*/
mat v=e(V)

/* get the means */
foreach var of varlist y-arm{
	qui summ `var'
	scalar m`var'=r(mean)
}


/* 
what is the marginal effect of age, at means of the data
atmeans is a bit easier 


a3 + a5*distance

the Jacobian is:
0
0
1
0
distance
0

At the means of the data, distance= 58.585665

*/

scalar mfx_age=scalar(mdistance)*_b[c.age#c.distance]


mat Jac = (0 \ scalar(mdistance) \ 0)
mat v=e(V)
mat GVG=Jac'*v*Jac
 scalar se_mfx=sqrt(el(GVG,1,1))
scalar list mfx_age se_mfx 

/* This matches perfectly with the "atmeans" */

gen mfx_age2=_b[c.age#c.distance]*distance
egen ame_age=total(mfx_age2)

replace ame_age=ame_age/e(N)

list ame_age in 1


margins, dydx(age) 















/*  Lets try margins eyex by hand. */
/* This is at means*/
scalar eyex_age=(_b[c.age#c.distance]*scalar(mdistance))/(scalar(my)/scalar(mage))
mat Jac2 = (0 \ scalar(mdistance)*scalar(mage)/scalar(my)  \ 0)


mat v=e(V)
mat GVG2=Jac2'*v*Jac2
scalar se_mfx2=sqrt(el(GVG2,1,1))
scalar list eyex_age se_mfx2 

margins, eyex(age) atmeans





/* and not at means. Evaluated over the data and then averaged*/


gen eyex_age_eval=(_b[c.age#c.distance]*distance*age)/y


egen t_eyex=total(eyex_age_eval)

replace t_eyex=t_eyex/e(N)

margins, eyex(age) 




