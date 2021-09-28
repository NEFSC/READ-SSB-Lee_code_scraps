
for (myc in 0:1)  {
  do some stuff that produces the "thing" aggregate
  
  for (myr in 1:nrow(fl1)){
    #REad in raster
    temp<-extend(raster(file.path(fl1$FILEPATH[myr])), f3, value=0)
    aggregate<-temp+aggregate
  }
 #Assign the name aggregate_0 to the thing aggregate
  assign(paste("aggregate",myc, sep=""), aggregate)
  
}
