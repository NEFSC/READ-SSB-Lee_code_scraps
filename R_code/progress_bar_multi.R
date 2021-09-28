

#### Set up environment ####

# empty the environment
rm(list=ls())

mproc<-matrix(rexp(10),3)
nrep<-2
fyear<-35
nyear<-45

#### Top rep Loop ####

maxyc<-nrep*nrow(mproc)*(nyear-fyear+1)
pb <- txtProgressBar(min = 1, max = maxyc, style = 3)
yearcounter<-0
showProgBar<-TRUE    
#showProgBar<-FALSE    

  

for(r in 1:nrep){
  # inside the nrep loop
  #### Top MP loop ####
  for(m in 1:nrow(mproc)){
    
    
    # Inside the mproc loop
    
    #### Top year loop ####
    for(y in fyear:nyear){
      yearcounter<-yearcounter+1
      
     if(showProgBar==TRUE){
       setTxtProgressBar(pb, yearcounter)
}
            Sys.sleep(0.1)
       #Inside the year loop      
    }
  }
}

