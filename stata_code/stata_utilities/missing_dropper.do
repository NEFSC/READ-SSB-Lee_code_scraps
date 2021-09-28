foreach varname of varlist * {
 quietly sum `varname'
 if `r(N)'==0 {
  drop `varname'
  disp "dropped `varname' for too much missing data"
 }
}
