###list of things that won't work with real data:


#####load and format files
{
    
  filepath<-'/Users/emcee/Documents/school/dissertation/ex5/cautious-finale/R/analysis/data'
  #filenamewordsbeforepnum<-"stimuli_lists/P"
  #block1_start = 1
  #block2_start = block1_start + 116*2+8*2
  #block3_start = block2_start + 113*2+8*2
  
  
  ###loop through folder and load them all in
  filenames <- list.files(filepath, pattern="*.csv", full.names=TRUE)
  fields = c("NULL",rep("character",3),"NULL","numeric",rep("NULL",5),"numeric",rep("character",3),"numeric","character","numeric",rep("NULL",2))
  all=NULL
  for (i in 1:length(filenames))
  {
    read.csv(filenames[i],header=TRUE,colClasses=fields)->temp
    #temp$num<-seq(1,nrow(temp))
    #temp$pnum<-filenames[i] #was from checking stimuli lists
    rbind(all,temp)->all
  }
  colnames(all)<-c('stimulus','right','left','block','trial','response','rt','gender','age','handed','pnum')
  all<-all[!(all$response==""),] #remove the break ones
  summary(all)
  head(all)
  
  ###make things factors
  all$right<-as.factor(all$right)
  all$left<-as.factor(all$left)
  all$gender<-as.factor(all$gender)
  all$handed<-as.factor(all$handed)
  
  ###for reference from cleaning pnum
  # temp<-do.call(rbind,strsplit(all$pnum,split="/"))
  # all$pnum<-temp[(seq(1,nrow(temp)/2,1)),2]
  # all$pnum<-as.factor(all$pnum)
  
  ###separate fric level and vow level
  all$stimulus<-do.call(rbind,strsplit(all$stimulus,split="/"))[,2]
  all$stimulus<-do.call(rbind,strsplit(all$stimulus,split=".w"))[,1]
  all$stimtype<-as.factor(substr(as.character(all$stimulus),1,1))
  all$stimulus<-substr(as.character(all$stimulus), 2, nchar(as.character(all$stimulus)))
  temp<-(unlist(strsplit(as.character(all$stimulus),'-')))
  all$fric<-as.factor(temp[c(TRUE,FALSE)])
  all$vow<-as.factor(temp[!c(TRUE,FALSE)])
  as.factor(all$stimulus)->all$stimulus
  
  ###separate group&condition
  all$group <- 0
  all[all$pnum%%2==0,]$group <- 1 
  all[all$pnum%%2==1,]$group <- 2 
  all$group<-as.factor(all$group)
  all$condition <- ""
  all[(all$group==1 & all$block<=1) | (all$group==2 & all$block>=4),]$condition <- "fric" #TODO check what these actually should be
  all[(all$group==1 & all$block>=4) | (all$group==2 & all$block<=1),]$condition <- "vow"
  all[all$block==2 | all$block==3,]$condition <- "both"
  all$condition<-as.factor(all$condition)

  ###translate responses
  ##remove ones with multiple answers in a terrible haxor function that i think works :) okay fine it says for all the responses that are longer than 9 chars, find the first ['num] in them and make them that one by taking the string of 7 char at that index and adding ]
  all[which(nchar(all$response)>9),]$response<-paste(substr(all[which(nchar(all$response)>9),]$response, regexpr("[\'num",all[which(nchar(all$response)>9),]$response,fixed=T)[1], regexpr("[\'num",all[which(nchar(all$response)>9),]$response,fixed=T)[1]+7),']',sep='')
  all[all$right=='SA' & all$response == '[\'num_4\']',]$response<-'z'
  all[all$right=='SA' & all$response == '[\'num_6\']',]$response<-'s'
  all[all$right=='ZA' & all$response == '[\'num_4\']',]$response<-'s'
  all[all$right=='ZA' & all$response == '[\'num_6\']',]$response<-'z'
  all$isZ<-all$response=='z'
  all$response<-as.factor(all$response)
  xtabs(~right+response,all)
  all$rt<-as.numeric(substr(all$rt,2,nchar(all$rt)-1))
  
  summary(all)
  head(all)
}

#####visualise stimuli exposure
{
  ###setup
  {
    require(ggplot2)
    require(gridExtra)
    require(grid)
    library(dplyr)
 
    plot_heatmap <- function(df,title){
      ph <- ggplot(df, aes(as.numeric(as.character(fric)), as.numeric(as.character(vow)))) +
        geom_tile(aes(fill = n)) + 
        geom_text(aes(label = n)) +
        scale_fill_gradient(low = "white", high = "darkred") +
        ggtitle(title)
      return(ph)
    }
    
 }
  
  agg_together<-all %>% count(stimulus,fric,vow)
  (plot_heatmap(agg_together,"together"))
  
  ###by block
  {
  agg_block1<-all[all$block==1,] %>% count(stimulus,fric,vow)
  plot_block1<-plot_heatmap(agg_block1,"block1")
  
  agg_block2<-all[all$block==2,] %>% count(stimulus,fric,vow)
  plot_block2<-plot_heatmap(agg_block2,"block2")
  
  agg_block3<-all[all$block==3,] %>% count(stimulus,fric,vow)
  plot_block3<-plot_heatmap(agg_block3,"block3")
  
  multi_block<-arrangeGrob(plot_block1,plot_block2,plot_block3,ncol=3)
  grid.draw(multi_block)
  
  }
  
  ###by group
  {
    agg_group1<-all[all$group==1,] %>% count(stimulus,fric,vow)
    plot_group1<-plot_heatmap(agg_group1,"group1")
    
    agg_group2<-all[all$group==2,] %>% count(stimulus,fric,vow)
    plot_group2<-plot_heatmap(agg_group2,"group2")
    
    multi_group<-arrangeGrob(plot_group1,plot_group2,ncol=2)
    grid.draw(multi_group)
    
  }
  
  ###by condition
  {
    agg_condition_fric<-all[all$condition=="fric",] %>% count(stimulus,fric,vow)
    plot_condition_fric<-plot_heatmap(agg_condition_fric,"condition_fric")
    
    agg_condition_vow<-all[all$condition=="vow",] %>% count(stimulus,fric,vow)
    plot_condition_vow<-plot_heatmap(agg_condition_vow,"condition_vow")
    
    agg_condition_both<-all[all$condition=="both",] %>% count(stimulus,fric,vow)
    plot_condition_both<-plot_heatmap(agg_condition_both,"condition_both")
    
    multi_condition<-arrangeGrob(plot_condition_fric,plot_condition_both,plot_condition_vow,ncol=3)
    grid.draw(multi_condition)
    
  }
  
}

#####visualise results
{
  ###setup
  {
    require(ggplot2)
    require(gridExtra)
    require(grid)
    library(dplyr)
    
    plot_heatmap <- function(df,title){
      ph <- ggplot(df, aes(as.numeric(as.character(fric)), as.numeric(as.character(vow)))) +
        geom_tile(aes(fill = n)) + 
        geom_text(aes(label = n)) +
        scale_fill_gradient(low = "white", high = "darkred") +
        ggtitle(title)
      return(ph)
    }
    
  }
  
  
  ###get totals established #INHERE
  {
    all$stimcond<-paste(all$stimulus,all$condition,sep="")
    stim_counts<-all[all$pnum==10,] %>% count(stimcond)
    all$stimcount<-stim_counts$n[match(unlist(all$stimcond), stim_counts$stimcond)]
    xtabs(~all$stimcount+all$stimcond)
  }
  
  ###eyeball overall responses #INHERE
  {
    numZ_overall<-aggregate(all$isZ,list(all$fric,all$vow),FUN=sum)
    colnames(numZ_overall)<-c("fric","vow","n")
    (plot_heatmap(numZ_overall,"numZ overall"))
    
    
    percZ_by_par<-aggregate(all$isZ,list(all$pnum,all$fric,all$vow,all$group,all$condition,all$stimcount),FUN=sum)
    colnames(percZ_by_par)<-c("pnum","fric","vow","group","condition","stimcount","numZ")
    percZ_by_par$percZ<-(percZ_by_par$numZ/percZ_by_par$stimcount)*100
    
    percZ_overall<-aggregate(percZ_by_par$percZ,list(percZ_by_par$fric,percZ_by_par$vow),FUN=mean)
    colnames(percZ_overall)<-c("fric","vow","percZ")
    
    
    
    (plot_heatmap(agg_together,"together"))
    
  }
  
  
  ###by block
  {
    agg_block1<-all[all$block==1,] %>% count(stimulus,fric,vow)
    plot_block1<-plot_heatmap(agg_block1,"block1")
    
    agg_block2<-all[all$block==2,] %>% count(stimulus,fric,vow)
    plot_block2<-plot_heatmap(agg_block2,"block2")
    
    agg_block3<-all[all$block==3,] %>% count(stimulus,fric,vow)
    plot_block3<-plot_heatmap(agg_block3,"block3")
    
    multi_block<-arrangeGrob(plot_block1,plot_block2,plot_block3,ncol=3)
    grid.draw(multi_block)
    
  }
  
  ###by group
  {
    agg_group1<-all[all$group==1,] %>% count(stimulus,fric,vow)
    plot_group1<-plot_heatmap(agg_group1,"group1")
    
    agg_group2<-all[all$group==2,] %>% count(stimulus,fric,vow)
    plot_group2<-plot_heatmap(agg_group2,"group2")
    
    multi_group<-arrangeGrob(plot_group1,plot_group2,ncol=2)
    grid.draw(multi_group)
    
  }
  
  ###by condition
  {
    agg_condition_fric<-all[all$condition=="fric",] %>% count(stimulus,fric,vow)
    plot_condition_fric<-plot_heatmap(agg_condition_fric,"condition_fric")
    
    agg_condition_vow<-all[all$condition=="vow",] %>% count(stimulus,fric,vow)
    plot_condition_vow<-plot_heatmap(agg_condition_vow,"condition_vow")
    
    agg_condition_both<-all[all$condition=="both",] %>% count(stimulus,fric,vow)
    plot_condition_both<-plot_heatmap(agg_condition_both,"condition_both")
    
    multi_condition<-arrangeGrob(plot_condition_fric,plot_condition_both,plot_condition_vow,ncol=3)
    grid.draw(multi_condition)
    
  }
  
}


#####other balancing
{
  summary(all[all$trial==block1_start,])
  summary(all[all$trial==block2_start,])
  summary(all[all$trial==block3_start,])
  summary(all[all$trial==block2_start-9,])
  summary(all[all$trial==block3_start-9,])
  all$left<-as.factor(all$left)
  all$right<-as.factor(all$right)
  summary(all)
  xtabs(~left+stimtype,all[all$trial==block1_start,])
  xtabs(~group+stimtype,all[all$trial==block1_start,])
  xtabs(~group+stimtype,all[all$trial==block2_start-9,])

}

###checking for outliers
{
  #rt
  summary(all[all$pnum==1,]$rt)
  ggplot(all,aes(pnum,rt)) +
    geom_boxplot()
  
  ggplot(all,aes(pnum,as.numeric(isZ))) +
    geom_point()
    #stat_summary(fun.data=count)
  
}

#####regression
{
  
  ###setup
  {
    library(lme4)
    all$response<-as.factor(all$response)
    all$pnum<-as.factor(all$pnum)
    all$fric<-as.numeric(as.character(all$fric))
    all$vow<-as.numeric(as.character(all$vow))
    all$fric<-(all$fric - mean(all$fric))/sd(all$fric) #centre them and use z scores
    all$vow<-(all$vow - mean(all$vow))/sd(all$vow) #centre them and use z scores
    summary(all)
  }
  
  ###loop of by participant regression main
  {
    all$participant<-all$pnum #just so that i don't have to refactor >>
    (participants = unique(all$participant))
    coefs = data.frame()
    
    for (p in participants)
    {
      all[all$participant==p,]$fric<-(all[all$participant==p,]$fric - mean(all[all$participant==p,]$fric))/sd(all[all$participant==p,]$fric) #centre them and use z scores
      all[all$participant==p,]$vow<-(all[all$participant==p,]$vow - mean(all[all$participant==p,]$vow))/sd(all[all$participant==p,]$vow) #centre them and use z scores
      fitloop<-glm(response~fric*vow, all[all$participant==p,], family=binomial)
      summary(fitloop)
      coefs<-rbind(coefs,cbind(t(as.data.frame(coef(summary(fitloop))[,4])),p))
      
    }
    
    colnames(coefs) <- c("intercept","fric","vow","participant")
    #colnames(coefs) <- c("intercept","fric","vow","interaction","participant")
    
    p<-0.05
    #coefs$fric<-as.character(as.numeric(coefs$fric))
    #coefs$vow<-as.character(as.numeric(coefs$vow))
    coefs$fricsig<-as.numeric(as.character(coefs$fric))<p
    coefs$vowsig<-as.numeric(as.character(coefs$vow))<p
    coefs  
  }
  

}
