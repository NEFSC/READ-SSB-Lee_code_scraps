/* Partialling out -- Frisch Waugh.

Greene , page 26-27 

you partition your RHS variables into X1 and X2. For now, X2 only contains 1 variable:
Y=XB+ epsilon
Y=X1b1 + X2b2 + epsilon

The coefficient on X2 is obtained by
1. Regress Y on X1.  Predict residuals u1
2. Regress X2 on X1. Predict residuals u2
3. Regress u1 on u2.

4. check by regress Y on X1, X2
*/
clear all
sysuse auto, clear

regress price mpg rep78 trunk

global check =_b[mpg]
/* partial out 1 variable  -- mpg */


regress price rep78 trunk
predict u1, resid

regress mpg rep78 trunk
predict u2, resid
regress u1 u2
di $check



/* Same as above, but X2 has more than 1 variable.  
you partition your RHS variables into X1 and X2.
Y=XB+ epsilon
Y=X1b1 + X2b2 + epsilon

The coefficient on X2 is obtained by
1. Regress Y on X1.  Predict residuals u1
2. Regress X2 on X1. Predict residuals u2
3. Regress u1 on u2.

4. check by regress Y on X1, X2
*/

/* we will put mpg and rep78 into X2.  trunk and i.foreign in X1*/

regress price mpg rep78 trunk i.foreign
global check_m =_b[mpg]
global check_r =_b[rep78]

regress price trunk i.foreign

predict uu1, resid
regress mpg trunk i.foreign
predict resid_m, resid

regress rep78 trunk i.foreign
predict resid_rep, resid

regress uu1 resid_m resid_rep

di $check_m
di $check_r
