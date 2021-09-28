/* This loop creates a tempfile called new and builds a local which contains the location of that tempfile. It does some stuff, and saves the generated dataset to the tempfile.  
Then */

forvalues i=1/1000{
	/* pass the iteration to the simulating_rhs1.do file */
	tempfile new
	local files `"`files'"`new'" "'  
	global myiter=`i'
	quietly do simulating_rhs1.do
	quietly save `new', emptyok
}
clear
append using `files'

