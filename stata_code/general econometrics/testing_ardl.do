webuse lutkepohl2, clear


sort qtr
/* manually restrict the estimation sample */
gen m=0
replace m=1 if qtr>=4

local depvar ln_consump
local indepvar ln_inc





/* All four of these commands will estimate a ARDL(1,1) with 1 RHS variable. */
/* these are identical */
regress `depvar' L(1).`depvar' L(0/1).`indepvar' if m
ardl `depvar' `indepvar' if m, lags(1 1) 


/* these are identical 
BUT ARDL will cast the independent variable to a long-run format.
*/
regress D.`depvar' L(1/1).`depvar' L(0/0).`indepvar' D(1/1).`indepvar' if m
ereturn list
test L1.ln_consump ln_inc 
ardl `depvar' `indepvar' if m, lags(1 1)  ec btest






/* All four of these commands will estimate a ARDL(1,1) with 2 RHS variables. */
local depvar ln_consump
local indepvar ln_inc ln_inv
regress `depvar' L(1).`depvar' L(0/1).(`indepvar') if m
ardl `depvar' `indepvar' if m, lags(1 1 1) 


/* these are identical 
BUT ARDL will cast the independent variable to a long-run format.
*/
regress D.`depvar' L(1/1).`depvar' L(0/0).(`indepvar') D(1/1).(`indepvar') if m
*ereturn list
test L1.ln_consump ln_inc ln_inv
ardl `depvar' `indepvar' if m, lags(1 1 1)  ec btest




/* All four of these commands will estimate a ARDL(1,0) with 1 RHS. */
local depvar ln_consump
local indepvar ln_inc 
regress `depvar' L(1).`depvar' `indepvar' if m
ardl `depvar' `indepvar' if m, lags(1 0) 

/* these are identical 
BUT ARDL will cast the independent variable to a long-run format.
*/
regress D.`depvar' L(1/1).`depvar' `indepvar' if m
*ereturn list
test L1.ln_consump ln_inc 
ardl `depvar' `indepvar' if m, lags(1 0)  ec btest





/* All four of these commands will estimate a ARDL(1,0) with 2 RHS variables. */
local depvar ln_consump
local indepvar ln_inc ln_inv
regress `depvar' L(1).`depvar' L(0).(`indepvar') if m
ardl `depvar' `indepvar' if m, lags(1 0 0) 


/* these are identical 
BUT ARDL will cast the independent variable to a long-run format.
*/
regress D.`depvar' L(1/1).`depvar' L(0/0).(`indepvar') if m
*ereturn list
test L1.ln_consump ln_inc ln_inv
ardl `depvar' `indepvar' if m,  lags(1 0 0)   ec btest


/*This treats the constant as restricted */
regress D.`depvar' L(1/1).`depvar' L(0/0).(`indepvar') if m
test L1.ln_consump ln_inc ln_inv _cons
ardl `depvar' `indepvar' if m,  lags(1 0 0)   ec btest restricted


