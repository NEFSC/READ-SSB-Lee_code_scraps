/*Convert to DST.  whalewatching starts at earliest in the middle of april and ends in mid october.  My interest
is only when there is DST, so i want to subtract off 4 hours from all times, since they are recorded in
UTC.  */

gen subtractor=msofhours(4)
gen double newpdate=pdate-subtractor
drop pdate
rename newpdate pdate
order pdate
drop subtractor

/*done for both glou and nh datasets*/