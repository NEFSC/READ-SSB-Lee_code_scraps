# 
############################################################
#This is my attempt to get R to run stata. It's not quite working properly, so I've commented it out.
# This bit of code will run some stata.  
#stata_exec<-"/usr/local/stata15/stata-mp"
#This one for windows0
#stata_opts<-" /b do" 
#this one for *nix
#stata_opts <- "-b do"
#stata_codedir <-"/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/preprocessing/economic"
#stata_dofiles<-c("wrapperAB.do")
#stata_dofiles<-c("asclogit_coef_export.do", "stocks_in_model.do", "recode_catch_limits.do", "multiplier_prep.do","price_prep.do","econ_data_split.do")
#stata_dofiles_list<-as.list(stata_dofiles)


# doesn't quite work -- the quotes aren't in the right place
#full_cmd<-paste(stata_exec, stata_opts,file.path(stata_codedir,stata_dofiles) , sep=" ") 
#system(full_cmd, timeout=0, intern=FALSE)
############################################################

