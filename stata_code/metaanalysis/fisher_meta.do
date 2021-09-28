/* To illustrate an interpretational problem that can arise when using Fisher's combined  probability test (or Tippett's test; see next section) to pool results from independent tests,  
consider the extreme case in which the plant with the target genotype has the lowest level  of disease damage in year 1, but the most damage in year 2. 
Let the null hypothesis (HO)  be that the target genotype has no effect on disease resistance and the alternative hypothesis  (HA) be that the rare genotype confers resistance to the disease.
 Applying Fisher's combined  probability test to the results of the two years yields  PFisher = {Pr(x2 4 -2[ln(1/120) + ln(120/120)]l = .049.
   The combined P-value is statistically significant at the 5% level despite the fact that the  data are clearly equivocal
   
   A Consensus Combined P-Value Test and the Family-Wide Significance of Component Tests 
   Author(s): William R. Rice 
   Source: Biometrics,  Vol. 46, No. 2 (Jun., 1990), pp. 303-308 
   Published by: International Biometric Society Stable 
   URL: http://www.jstor.org/stable/2531435
   
   */
   
   
   di -2*(ln(1/120) + ln(1))
di chi2(4, -2*(ln(1/120) + ln(1)))
di 1-chi2(4, -2*(ln(1/120) + ln(1)))



/* 
 A test that includes a transformation which is not differentially sensitive to data that  support or refute a common HO, is the z-transform test originally proposed by Stouffer et  al. (1949; cited in Folks, 1984).
 In this test each of a group of k P-values is transformed  to a corresponding z-value (a standard normal variable, z1,) such that Pr[N(O, 1) S  zj,] = P-value. 
 A test of HO: Paverage = .5, which implies that Zp(average) = 0, and  HA: Paverage < .5, which implies that Zp(average) < 0, 
 
	is carried out by calculating Z =  Zp(average)/(1/k) /2. The distribution of Z is N(0, 1) on HO and the corresponding combined  P-value is Pr[N(0, 1) - Z]

If there are 4 experiments and the P's are 

1/120
120/120
.6
.016

pbar=(1/120+120/120+.6+.016)/4


*/

set obs 4
gen p=.
replace p=1/120 in 1
replace p=120/120 in 2
replace p=1-(.5/120) in 2
replace p=.6 in 3

replace p=0.16 in 4

gen zi=invnorm(p)

collapse (sum) zi
replace zi=zi/(sqrt(4))
gen newp=normal(zi)

/* -.47569339 */

