 gen byte notnumeric = real(number)==. /*makes indicator for obs w/o numeric values*/
tab notnumeric /*==1 where nonnumeric characters*/
list number if notnumeric==1 /*will show which have nonnumeric*/
