/*Sometimes, the coefficient names in e(b) do not lend themselves to exporting back to a matrix. For example: 

	_cons is an illegal variable name
	1_* is an illegal variable name
	var#var is an illegal variable name
So, we will need to clean them up a bit.  


We will fix this by reading the names of the matrix columns into a local, making some changes, and renaming the matrix with that local.
	 */
#delimit;
sysuse auto;
regress price c.mpg##c.rep78;
mat m=e(b);
clear;
mat list m;
/* this line breaks 
svmat m, names(col)
*/

mat m=e(b);


local names: colfullnames m;


/*These are some substitutions */
local names: subinstr local names "_cons" "constant", all ;
local names: subinstr local names "fishing_year" "FY", all ;
local names: subinstr local names "#" "X", all;
local names: subinstr local names "." "_", all;



/*There is a canned strtoname local extended function.  This replaces everything illegal with underscores.   */
local newnames ;
foreach name of local names {;
    local newnames `newnames' `=strtoname("`name'")';
};




mat colnames m=`newnames';
clear;
svmat m, names(col);

list;











log close;
