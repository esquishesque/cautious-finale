###list of things that won't work with real data:
# - need to use real way of getting pnum from file rather than doing it from order in list of files


#####load and format files
filepath<-'/Users/emcee/Documents/school/dissertation/ex5/cautious-finale/R/analysis/stimuli_lists'
block1_start = 1
block2_start = block1_start + 116*2+8*2
block3_start = block2_start + 113*2+8*2


###loop through folder and load them all in
filenames <- list.files(filepath, pattern="*.csv", full.names=TRUE)
fields = c(rep("character",3))
all=NULL
for (i in 1:length(filenames))
{
  read.csv(filenames[i],header=FALSE,colClasses=fields)->temp
  temp$num<-seq(1,nrow(temp))
  temp$pnum<-i
  rbind(all,temp)->all
}
colnames(all)<-c('stimulus','left','right','trial','pnum')



###separate fric level and vow level
all$stimtype<-as.factor(substr(as.character(all$stimulus),1,1))
all$stimulus<-substr(as.character(all$stimulus), 2, nchar(as.character(all$stimulus)))
temp<-(unlist(strsplit(as.character(all$stimulus),'-')))
all$fric<-as.factor(temp[c(TRUE,FALSE)])
all$vow<-as.factor(temp[!c(TRUE,FALSE)])
as.factor(all$stimulus)->all$stimulus

###separate block
all$block <- 3
all[all$trial<block3_start,]$block <- 2
all[all$trial<block2_start,]$block <- 1
all$block<-as.factor(all$block)

#####visualise
{
  ###setup
  {
    require(ggplot2)
    require(gridExtra)
    require(grid)
    library(dplyr)
  }
  
  allAgg<-all %>% count(stimulus,fric,vow,pnum,block)
  #allAgg<-aggregate(all$stimtype,list(all$fric,all$vow,all$pnum),count)
  summary(allAgg)
  allAgg$fric<-as.numeric(as.character(allAgg$fric))
  allAgg$vow<-as.numeric(as.character(allAgg$vow))
  allAgg$block<-as.factor(allAgg$block)
  
  (plot_together <- ggplot(allAgg, aes(fric, vow)) +
    geom_tile(aes(fill = n)) + 
    scale_fill_gradient(low = "white", high = "darkred") +
    ggtitle("all together"))
  
  (plot_block1 <- ggplot(allAgg[allAgg$block==1,], aes(fric, vow)) +
      geom_tile(aes(fill = n)) + 
      scale_fill_gradient(low = "white", high = "darkred") +
      ggtitle("block1"))
  
  (plot_block2 <- ggplot(allAgg[allAgg$block==2,], aes(fric, vow)) +
      geom_tile(aes(fill = n)) + 
      scale_fill_gradient(low = "white", high = "darkred") +
      ggtitle("block2"))
  
  (plot_block3 <- ggplot(allAgg[allAgg$block==3,], aes(fric, vow)) +
      geom_tile(aes(fill = n)) + 
      scale_fill_gradient(low = "white", high = "darkred") +
      ggtitle("block3"))
  
  
}
