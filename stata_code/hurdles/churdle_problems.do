version 16.1
clear 
est drop _all
webuse fitness
churdle linear hours age i.smoke distance, ll(0) select(age i.smoke distance)
/* all of these margins work fine */
margins, dydx(age) predict(ystar(0,.))
margins, dydx(age) predict(e(0,.))
margins, dydx(age) predict(pr(0,.))
margins, dydx(age)

/* this does not */
margins, dydx(distance) predict(ystar)
/* Error code is:
variable __marg_pvar_1 not found
r(111);*/

/*Furthermore, this works*/
predict ys 
/*while this does nothing */
predict ys1, ystar

/* I understand that ystar is the default option for both predict and margins after churdle.  But I like to write it explicitly to help me remember what I'm doing in my code. 
This feels like a bug.  
 */