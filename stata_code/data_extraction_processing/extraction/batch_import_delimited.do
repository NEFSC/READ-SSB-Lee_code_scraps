cd "/home/mlee/Documents/projects/demand_project/nsar"

local mylist: dir . files "*.CSV"

foreach l of local mylist{
	tempfile new
	local files `"`files'"`new'" "'  
	clear
	import delimited `l'
	qui save `new', emptyok
}
clear
append using `files'
save "NSAR_East_coast.dta", replace
