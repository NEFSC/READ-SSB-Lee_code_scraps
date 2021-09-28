
fl<-matrix(0,nrow=50, ncol=6)

# create progress bar
pb <- txtProgressBar(min = 0, max = nrow(fl), style = 3)
for(i in 1:total){
  Sys.sleep(0.1)
  # update progress bar
  setTxtProgressBar(pb, i)
}
close(pb)
