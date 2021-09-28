This archive contains Stata code for replicating the Monte Carlo tables in 
Kline and Santos (2011) "A Score Based Approach to Wild Bootstrap Inference." 
The following is an inventory of the relevant files and what they produce:

MC_OLS8.do -- This produces the bulk of the estimates in Table 1. 
It implements analytical, score bootstrapped, and wild bootstrapped tests.

MC_OLS8_pairs.do -- This produces the nonparametric pairs bootstrapped 
results in Table 1.

MC_PROBIT8.do -- This produces the bulk of the estimates in Table 2. 
It implements analytic and score bootstrapped tests.

MC_PROBIT8_pairs.do -- This produces the nonparametric pairs bootstrapped 
results in Table 2.

MC_MTEST2_8.do -- This produces the estimates in Table 3.

OLS_time2.do -- This produces the OLS benchmarking results in Table 4.

PROBIT_time2.do -- This produces the probit benchmarking results in Table 4.


To generate results call the do file with the relevant arguments from Stata. 
For example "do MC_OLS8 10 20 0 0 10000" runs the OLS Monte Carlos with 
10 clusters, 20 observations per cluster, Monte Carlo design I 
(no misspecification, no mixture in regressor of interest) and 10,000 Monte 
Carlo repetitions.

