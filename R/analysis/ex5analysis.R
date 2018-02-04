#####load and format files

filepath<-'/Users/emcee/Documents/school/dissertation/ex5/R/analysis/stimuli_lists/'

###loop through folder and load them all in
filenames <- list.files(filepath, pattern="*.csv", full.names=TRUE)
fields = c(rep("character",3))
all=NULL
for (i in 1:length(filenames))
{
  read.csv(filenames[i],header=TRUE,colClasses=fields)->temp
  temp$num<-seq(1,nrow(temp))
  temp$pnum<-i
  rbind(all,temp)->all
}
colnames(all)<-c('stimulus','left','right','trial','pnum')



###separate fric level and vow level
all$stimtype<-as.factor(substr(as.character(all$stimulus),1,1))
all$stimulus<-substr(as.character(all$stimulus), 2, nchar(as.character(all$stimulus)))
temp<-(unlist(strsplit(as.character(all$stimulus),'-')))
all$fric<-temp[c(TRUE,FALSE)]
all$vow<-temp[!c(TRUE,FALSE)]
as.factor(all$stimulus)->all$stimulus

