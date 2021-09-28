gen double mysetbeg = clock(setbegin, "DM20Yhm")
gen double mysetend = clock(setend, "DM20Yhm")


drop setbegin setend start_set_hour start_set_min end_set_hour end_set_min datesbeg datesend timesbeg timesend


gen haulbegin=datehbeg+ " " + string(start_haul_hour) + ":" + string(start_haul_min)
gen haulend=datehend+ " " + string(end_haul_hour) + ":" + string(end_haul_min)


gen double myhbeg = clock(haulbegin, "DM20Yhm")
gen double myhend = clock(haulend, "DM20Yhm")

drop datehbeg datehend timehbeg timehend start_haul_hour start_haul_min end_haul_hour end_haul_min



gen fishbegin=datefbeg+ " " + string(start_fish_hour) + ":" + string(start_fish_min)
gen fishend=dategonbd+ " " + string(end_fish_hour) + ":" + string(end_fish_min)



gen double myfishbegin = clock(fishbegin, "DM20Yhm")
gen double myfishend = clock(fishend, "DM20Yhm")

drop datefbeg timefbeg dategonbd timegonbd start_fish_hour start_fish_min end_fish_hour end_fish_min
