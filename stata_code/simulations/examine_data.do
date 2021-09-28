
use "/home/mlee/Documents/Workspace/technical folder/do file scraps/simulations/temp_pollock_pre_testing_prodreg_equivalency.dta"

/* areg or reghdfe */
reghdfe logh log_crew log_trip_days log_trawl_survey_weight  i.month prim_*, absorb(hullnum2)
est store myhdfe
gen linear_samp=e(sample)

/*Full Poisson model*/
ppmlhdfe qtykept log_crew log_trip_days log_trawl_survey_weight  i.month prim_*, absorb(hullnum2)
est store ppml_full

/*Just on the positives */
ppmlhdfe qtykept log_crew log_trip_days log_trawl_survey_weight  i.month prim_* if linear_samp==1, absorb(hullnum2)
est store ppml0

est table myhdfe ppml_full ppml0, equation(1) stats(N aic)



/*Full xtnbreg model*/
xtnbreg qtykept log_crew log_trip_days log_trawl_survey_weight  i.month prim_*, i(hullnum2)
est store nb_full

/*Just on the positives */
xtnbreg qtykept log_crew log_trip_days log_trawl_survey_weight  i.month prim_* if linear_samp==1, i(hullnum2)
est store nb0
