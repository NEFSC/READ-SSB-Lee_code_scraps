/* exporting centiles */


sysuse auto
levelsof foreign, local(myl)
foreach ll of local myl {
	quietly estpost summarize price if foreign==`ll', detail
	disp `ll'
	esttab . , cells("p50 p25 p75") noobs
}
