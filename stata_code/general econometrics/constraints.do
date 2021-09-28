sysuse auto

/* no constraints  - sureg and gmm produce identical results except for Standard errors*/
sureg (prs: price gear_ratio turn) (miless: mpg gear turn), isure
gmm(pr:price - {a1}*gear_ratio - {a2}*turn -{a0}) (miles: mpg-{b1}*gear_ratio -{b2}*turn  -{b0}), instruments(gear_ratio turn) winitial(identity) igmm


/* gear equal - sureg and gmm produce similar results */
constraint 1 [prs]gear=[miless]gear
sureg (prs: price gear_ratio turn) (miless: mpg gear turn), isure constraints(1)
gmm(pr:price - {a1}*gear_ratio - {a2}*turn -{a0}) (miles: mpg-{a1}*gear_ratio -{b2}*turn  -{b0}), instruments(gear_ratio turn) winitial(identity) igmm


/* constrain gear to sum to -1200 across equations */
constraint 2 [prs]gear+[miless]gear=-1200
constraint 3 a1+b1=-1200

sureg (prs: price gear_ratio turn) (miless: mpg gear turn), isure constraints(2)
gmm(pr:price - {a1}*gear_ratio - {a2}*turn -{a0}) (miles: mpg-{b1}*gear_ratio -{b2}*turn  -{b0}), instruments(gear_ratio turn) winitial(identity) igmm constraints(3)
