/* small bit of code . Get all the files with a csv extension. Save to dta. */
/* this only needs to be run one time */
cd "$my_workdir/itis122018"

local mylist: dir . files "*.csv"



foreach l of local mylist{
	local temp: subinstr local l ".csv" ".dta"
	import delimited `l'
	save `temp'
	clear
}
