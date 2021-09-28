nois _dots 0, title(Loop running) reps(100)


qui forvalues subset=1/`max'{
	/*DO some stuff here */
	nois _dots `subset' 0     
}

			
