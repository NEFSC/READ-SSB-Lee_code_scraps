/*testing margins */

webuse margex
regress y i.sex##i.group c.distance, robust

/* 
y= a1*female + b2*group2 + b3*group3 + c2*female*group2 + c3*female*group3 + c4*distance +error
dy/d

*/


predict xb, xb

margins, vce(unconditional)



/* simple 
This is the predicted Y where we treat everyone as SEX=0 and then SEX=1*/
margins sex

/* by hand*/

gen p1=_b[_cons] + distance*_b[distance]
replace p1=p1+_b[2.group] if group==2
replace p1=p1+_b[3.group] if group==3

gen malep=p1

replace p1=p1+_b[1.sex#2.group] if group==2
replace p1=p1+_b[1.sex#3.group] if group==3
replace p1=p1+_b[1.sex]
rename p1 femalep


/* this is the marginal effect of group */
margins, dydx(group)

/* predict a group=1 */
gen p1=_b[_cons] + distance*_b[distance]+_b[1.sex]*sex

/*predict group=2*/
gen p2=_b[_cons] + distance*_b[distance]+_b[1.sex]*sex + _b[2.group] + sex*_b[1.sex#2.group]

/*predict group=3*/
gen p3=_b[_cons] + distance*_b[distance]+_b[1.sex]*sex + _b[3.group] + sex*_b[1.sex#3.group]


/* compute differences */

gen marg2=p2-p1
gen marg3=p3-p1

summ marg2 marg3
margins, dydx(group)

drop p1 p2 p3 marg2 marg3





webuse nhanes2
regress bpsystol agegrp##sex


/*If you flip the order of the margins interactions, the marginsplot comes out different */
/*You don't need to do this, you can just change xdimension */

margins agegrp#sex
marginsplot, name(order1, replace) title("")

margins sex#agegrp
marginsplot, name(order2, replace) title("") legend(rows(2))
graph combine order1 order2

marginsplot, recast(line) recastci(rarea)


margins, dydx(agegrp) over(sex)
marginsplot, name(mfx_os, replace) title("")

margins, dydx(sex) over(agegrp)
marginsplot, name(mfx_o_agegrp, replace) title("") legend(rows(2))
graph combine mfx_os mfx_o_agegrp


/* only do margins for some of the values of agegrp */
margins, dydx(agegrp) over(sex)
margins, dydx(i(2/4).agegrp) over(sex)
margins, dydx(i(2 3 6).agegrp) over(sex)

margins if sex==1, dydx(agegrp) over(sex)


/* only do margins for some of the values of agegrp */
margins, dydx(sex) over(agegrp)
margins if agegrp<=3, dydx(sex) over(agegrp)



regress bpsystol agegrp##sex##c.bmi

/* marginal effect of agegroup, by male/female, at various bmis */
margins, dydx(agegrp) over(sex) at(bmi=(10(10)50))
marginsplot, bydim(bmi)





