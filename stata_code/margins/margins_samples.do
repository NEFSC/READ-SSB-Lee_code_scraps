/* This do file contains my notes for Stata's margins command */
/* In stata, 'margins' can be used for a few things:
1.  Calculate the predicted values and standard errors for the sample 
	a.  Evaluated at the actual values of the observations (a bit redundant to 'predict xb // summ xb'
	b.  Evaluated at DIFFERENT values of the observations to produce some sort of counterfactual
2.  Calcuate derivates, marginal effects, and elasticities
	a.  For the whole sample, then reporting some sort of summary statistic
	b.  At a particular value or set of values of the independant variable
	
*/


set more off
use http://www.stata-press.com/data/r12/margex, clear
/* I rename sex=female, just for clarity */
rename sex female

/* Must use the `factor notation' for stata's margins to work properly */
/* See 'help fvvarlist'
The i prefix is used for Indicator variables
The c prefix is used for Continous variables
These can be grouped and there is fine control over them (see help fvvarlist)
Be very carefull about the 'base' when using the indicator variables.
*/

/* This happens if you don't use indicators 
regress y age female group
margins 
*/

/*****************************************************/
/** PART  1  -- The boring stuff*/

/*****************************************************/
/* 1a.  Use of 'grand' request the grand margin -- aka the grand predicted value */
regress y c.age i.female i.group
est store boring_ols
margins 
margins, grand
quietly predict xb
summ xb
drop xb

/* 1b.  Calculate the predicted values as they are for observations in the dataset, then split the reporting by FEMALE=0 and FEMALE=1*/
/* these are the three ways to do this */

/*method 1 */
margins, over(female)

/*method 2*/

gen p1=_b[_cons]+_b[age]*age
replace p1=p1+_b[3.group] if group==3
replace p1=p1+_b[2.group] if group==2
replace p1=p1+_b[1.female] if female==1

bysort female: summ p1

/*method 3 */
predict xb
bysort female: summ xb

drop p1 xb

est restore boring_ols


/* 1b.  Calculate the predicted value if everyone was female=1*/
margins, at(female=1)

/*solution 2 */
gen p1=_b[_cons]+_b[age]*age
replace p1=p1+_b[3.group] if group==3
replace p1=p1+_b[2.group] if group==2
replace p1=p1+_b[1.female] 
summ p1
drop p1

/* 1b.  "DECOMPOSING MARGINS (manual 1041).  Calculate predicted values for only for female*/
margins if female==1, at(female=(0 1))
margins if female==0, at(female=(0 1))


/* 1c. predict y as if everyone was male, then as if everyone was female*/

gen p1=_b[_cons]+_b[age]*age
replace p1=p1+_b[3.group] if group==3
replace p1=p1+_b[2.group] if group==2

gen pfemale=p1+_b[1.female] 
rename p1 pmale

summ pmale pfemale
margins female

drop pmale pfemale

/* 2a.  These commands produce the derivative of y with respect to age sex and group*/
margins, dydx(age female group)
/* 2b.  These commands produce the derivative of y with respect to age for the two groups defined by female=0 and female=1*/
/* Note, since there's no interaction term -- the derivative is the same for both groups */
margins, dydx(age) over(female)


/* 2a.  This is the elasticity with respect to age */
margins, eyex(age) 
/* 2b.  These commands produce the derivative of y with respect to age for the two groups defined by female=0 and female=1*/
/* Note: Over(VAR) == if(VAR==a, b,c individually) */
/* Note that these are SLIGHTLY different - probably because y is different */
margins, eyex(age) over(female)
margins if female==0, eyex(age)
margins if female==1, eyex(age)


/*****************************************************/
/** PART  2 -- Interactions
'Margins' shines when there is a regression with interactions*/

/*****************************************************/

regress y c.age##ib(0).female ib(freq).group
est store interact_ols
/* 1a.  Use of 'grand' request the grand margin -- aka the grand predicted value */

margins 
margins, grand
quietly predict xb
summ xb
drop xb

/* 1b.  Calculate the predicted value for both female=0 and female=1*/
margins, over(female)
est restore interact_ols


/* 1b.  Calculate the predicted value if everyone was female=1*/
margins, at(female=1)
/* 1b.  "DECOMPOSING MARGINS (manual 1041).  Calculate predicted values for only for female*/
margins if female==1, at(female=(0 1))
margins if female==0, at(female=(0 1))

/* 2a.  This command produces the derivative of y with respect to age */
/* This takes into account both the effect of age [beta_{age}] and the cross effect of age*female [beta_{age, female}] */
/* Note, more negative than the age coefficient because the female_age coefficient is negative*/
margins, dydx(age)


/* Note, This is just the age coefficient, since the interaction term for males is zero*/
margins if female==0, dydx(age)

/* The marginal effect of age for MEN evaluated as if they were female (and had all other characteristics the same)*/
margins if female==0, dydx(age) at(female==1)

/* The marginal effect of age for MEN evaluated as if they were male or female*/
margins if female==0, dydx(age) at(female==(0 1))

/* 2a.  This command produces the `discrete effect' of y with respect to female*/
/* This takes into account both the effect of female[beta_{female}] and the cross effect of age*female [beta_{age, female}] */
margins, dydx(female)

/* 2b.  These commands produce the derivative of y with respect to age for the two groups defined by female=0 and female=1*/
margins, eyex(age) over(female)
margins if female==0, eyex(age)
margins if female==1, eyex(age)



/* Now, we will test for equality of 2 (or more) margins*/
/* H_o: the marginal effect of age is the same for males and females */
est restore interact_ols
margins, dydx(age) over(female) coeflegend
margins, dydx(age) over(female) post

test _b[0bn.female]=_b[1.female]
est restore interact_ols




/* A little bit more stuff */

/* options
grand -- the 'overall' margin aka predict
atmeans -- evaluate at the mean value of the independent variables 
at( var1 list var2 list2) -- at values of the independent variables 
	This performs policy simulation -- what if the independent variables were different
over() -- estimated margins at the unique values of the specified variables
	Equivalent to looped 'if' on the specified variables
coeflegend - tells you the name of the parameter
post - send the coefficients and variance-covariance matrix to matrices. This overwrites the current model results */


/* Here is a fancy model
y= a female + b group + c age + d distance + e female*group + f female*age + g female*distance + h group*age + i group*distance + g age distance + u
Here is the model in stata:
	a.  Note that the ib(0).female is 'distributed' across group age and distance and the ## notation INCLUDES levels and interactions
	b.  The ib(freq).group is 'distributed' across age and distance and the # notation EXCLUDES age and distance (already in part a)
	c.  Finally, the c.age#c.distance variables also EXCLUDES age and distance (already in part a)

*/

regress y ib(0).female## (ib(freq).group c.age c.distance) ib(freq).group#(c.age c.distance) c.age#c.distance
est store big
/* partial effect of age for male observations and female observations*/
margins , dydx(age) over(female)
margins if female==0, dydx(age) 
margins if female==1, dydx(age)

/* partial effect of female*/
margins , dydx(female)

/* partial effect of age, for observations which are set to female=0 and female=1*/
margins , dydx(age) at(female=(0 1))

