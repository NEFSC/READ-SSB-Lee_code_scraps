/* You find string particularly un-intuitive

Here is a way to deal with them */



/* You can "stringify" a local 
In this local, you loop over the years 1996-2014.  
You pull out the last 2 digits and zero pad them
Then you copy files
*/



forvalues folder=1996(1)2014{
	local stub=string(mod(`folder',100),"%02.0f")
	di "`stub'"
	*copy   http://www2.census.gov/programs-surveys/cbp/datasets/`folder'/cbp`stub'co.zip cpb`folder'.zip
}

