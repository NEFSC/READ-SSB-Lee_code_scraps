/* https://www.statalist.org/forums/forum/general-stata-discussion/general/1378491-bootstrapping-multinomial-logit-model-with-endogenous-predictor-using-control-function-approach */

cap program drop  bsses 
cap program drop  bsses_1marg 
cap program drop  margins 


est drop _all
sysuse auto, clear
rename rep78  y
rename weight  x
rename length  z
 
* Control function approach:
reg x z headroom                        // first stage
predict x_res, residuals               // cf
mlogit y x headroom x_res          //second stage
est store mlogit_results
margins, dydx(x headroom) post
est store mlogit_margins
drop x_res



/*bootstrap the standard errors of the coeffs */
/* note, if I have panel data, I can't use lags */
/* I'm not sure if I should cluster (block) bootstrap */



/* estimate the model and get the bootstrapped standard errors */
cap program drop  bsses 
program bsses, rclass
            reg x z headroom                                    
            predict x_res, residuals                      
            mlogit y x headroom x_res                      
			drop x_res
end program
 
*bootstrap _b, reps(20): bsses



/* estimate the model, get the bootstrapped standard errors, and get a margin */

cap program drop  bsses_1marg 
program bsses_1marg, rclass
            reg x z headroom                                    
            predict x_res, residuals                      
            mlogit y x headroom x_res                      
            margins, dydx(x headroom)
			matrix list r(b)
			tempname M
			matrix `M' = r(b)
			local M_cols = colsof(`M')
			forvalues j = 1/`M_cols' {
				return scalar margin_`j' = `M'[1, `j']
			}
			drop x_res
end program
 
bootstrap _b m1 = r(margin_1) m2 = r(margin_2) m10 = r(margin_10) , reps(20) saving(bsauto): bsses_1marg
est store mlogit_boot

est replay  mlogit_results 
est replay mlogit_margins

/* estimate the model and post the margins margin (but not the coefficients)*/

cap program drop  margins 
program margins
            reg x z headroom                                    
            predict x_res, residuals                      
            mlogit y x headroom x_res                      
			margins, dydx(x headroom) post
            drop x_res

end program
*bootstrap, reps(20): margins



/*
...
tempname myb
_estimates hold `myb' , copy
margins ... , post
...
_estimates unhold `myb'
...
*/

