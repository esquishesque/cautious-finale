
#####setup
{

  ###options
  {
    #definitions
    len_matrix <- 11 #how many rows and columns
    divisor <- 5 #divisor in combining the 1d distributions
    blocks <- 3 #distinct blocks in the experiment
  }

  ###the rest
  {
    #functions
    createMatrixFrom1D <- function(vector,len_matrix){
      return(matrix(rep(vector,len_matrix),nrow=len_matrix,ncol=len_matrix))
    }
    createMatrixFrom2D <- function(h_vector,v_vector,divisor){
      return(round((h_vector * v_vector)/divisor))
    }
    getTotalTrials <- function(matrix,blocks){
      return(sum(matrix)*2*blocks)
    }
    flip <- function(x){
      df <- cbind(x)
      df <- t(apply(df, 2, rev))
      df <- t(apply(df, 2, rev))
      return(df)
    }
    massage <- function(matrix){
      library(tidyverse)
      df <- matrix %>%
        tbl_df() %>%
        rownames_to_column('fric') %>%
        gather(vow, value, -fric) %>%
        mutate(
          fric = factor(fric, levels=1:11),
          vow = factor(gsub("V", "", vow), levels=1:11)
        )
      return(df)
    }
    
    #establish d = distribution
    d_narrow <- c(1,1,5,10,5,1,1,0,0,0,0)
    d_wide <- c(2,3,4,6,4,3,2,0,0,0,0)
    d_canon <- c(1,2,5,8,5,2,1,0,0,0,0)
    
    #establish h = horizonal matrix ; v = vertical matrix
    v_narrow <- createMatrixFrom1D(d_narrow,len_matrix)
    v_wide <- createMatrixFrom1D(d_wide,len_matrix)
    v_canon <- createMatrixFrom1D(d_canon,len_matrix)
    h_narrow <- t(v_narrow)
    h_wide <- t(v_wide)
    h_canon <- t(v_canon)
    
    #establish m = 2d matrix
    m_widenarrow <- createMatrixFrom2D(v_wide,h_narrow,divisor)
    print(getTotalTrials(m_widenarrow,blocks))
    m_narrowwide <- createMatrixFrom2D(v_narrow,h_wide,divisor)
    m_canoncanon <- createMatrixFrom2D(v_canon,h_canon,divisor)
    print(getTotalTrials(m_canoncanon,blocks))
    
    #establish s = /s/ matrix ; z = /z/ matrix
    s_widenarrow <- cbind(m_widenarrow)
    z_widenarrow <- flip(m_widenarrow)
    s_narrowwide <- cbind(m_narrowwide)
    z_narrowwide <- flip(m_narrowwide)
    s_canoncanon <- cbind(m_canoncanon)
    z_canoncanon <- flip(m_canoncanon)
    
    #establish c = combined matrix
    c_widenarrow <- s_widenarrow + z_widenarrow
    c_narrowwide <- s_narrowwide + z_narrowwide
    c_canoncanon <- s_canoncanon + z_canoncanon
    
    #establish p = probability S matrix
    p_widenarrow <- round((s_widenarrow/(s_widenarrow+z_widenarrow))*100)
    p_narrowwide <- round((s_narrowwide/(s_narrowwide+z_narrowwide))*100)
    p_canoncanon <- round((s_canoncanon/(s_canoncanon+z_canoncanon))*100)
  }

}

#####visualise
{
  ###setup
  {
    require(ggplot2)
    require(gridExtra)
    require(grid)
  }
    
  ###density plots
  {
    #establish dp = density plot
    dp_widenarrow<-massage(c_widenarrow*c_widenarrow/c_widenarrow)
    dp_narrowwide<-massage(c_narrowwide*c_narrowwide/c_narrowwide)
    dp_canoncanon<-massage(c_canoncanon*c_canoncanon/c_canoncanon)
    
    #build density plots
    plot_widenarrow <- ggplot(dp_widenarrow, aes(fric, vow)) +
      geom_tile(aes(fill = value)) + 
      geom_text(aes(label = round(value, 1))) +
      scale_fill_gradient(low = "white", high = "darkred", guide=FALSE) +
      ggtitle("wide/narrow") +
      labs(x="fricative stimulus",y="vowel stimulus") +
      theme(plot.title = element_text(hjust = 0.5))
    plot_narrowwide <- ggplot(dp_narrowwide, aes(fric, vow)) +
      geom_tile(aes(fill = value)) + 
      geom_text(aes(label = round(value, 1))) +
      scale_fill_gradient(low = "white", high = "darkred", guide=FALSE) +
      ggtitle("narrow/wide") +
      labs(x="fricative stimulus",y="vowel stimulus") +
      theme(plot.title = element_text(hjust = 0.5))
    plot_canoncanon <- ggplot(dp_canoncanon, aes(fric, vow)) +
      geom_tile(aes(fill = value)) + 
      geom_text(aes(label = round(value, 1))) +
      scale_fill_gradient(low = "white", high = "darkred", guide=FALSE) +
      ggtitle("even") +
      labs(x="fricative stimulus",y="vowel stimulus") +
      theme(plot.title = element_text(hjust = 0.5))
    multi_density2D<-arrangeGrob(plot_widenarrow,plot_canoncanon,plot_narrowwide,ncol=3)
    grid.draw(multi_density2D)
  }
  
  ###probability plots
  {
    #establish pp = probability plot
    pp_widenarrow<-massage(p_widenarrow)
    pp_narrowwide<-massage(p_narrowwide)
    pp_canoncanon<-massage(p_canoncanon)
    
    #build probability plots
    plot_widenarrow <- ggplot(pp_widenarrow, aes(fric, vow)) +
      geom_tile(aes(fill = value)) + 
      geom_text(aes(label = round(value, 1))) +
      scale_fill_gradient(low = "white", high = "darkred") +
      ggtitle("wide/narrow")
    plot_narrowwide <- ggplot(pp_narrowwide, aes(fric, vow)) +
      geom_tile(aes(fill = value)) + 
      geom_text(aes(label = round(value, 1))) +
      scale_fill_gradient(low = "white", high = "darkred") +
      ggtitle("narrow/wide")
    plot_canoncanon <- ggplot(pp_canoncanon, aes(fric, vow)) +
      geom_tile(aes(fill = value)) + 
      geom_text(aes(label = round(value, 1))) +
      scale_fill_gradient(low = "white", high = "darkred") +
      ggtitle("canon/canon")
    multi_probability<-arrangeGrob(plot_widenarrow,plot_narrowwide,plot_canoncanon)
    grid.draw(multi_probability)
  }
  
  ###distribution plots
  {
    #create df = dataframes of distributions
    df_narrow <- as.data.frame(cbind(d_narrow,rep("narrow",len_matrix)))
    colnames(df_narrow)<-c("density","type")
    df_narrow$density<-as.numeric(as.character(df_narrow$density))
    df_wide <- as.data.frame(cbind(d_wide,rep("wide",len_matrix)))
    colnames(df_wide)<-c("density","type")
    df_wide$density<-as.numeric(as.character(df_wide$density))
    df_canon <- as.data.frame(cbind(d_canon,rep("canon",len_matrix)))
    colnames(df_canon)<-c("density","type")
    df_canon$density<-as.numeric(as.character(df_canon$density))
    df_half <- rbind(df_narrow,df_wide,df_canon)
    df_half$index <- rep(1:len_matrix,3)
    
    #half distribution plot
    hd <- ggplot(df_half, aes(index,density,color=type,group=type)) +
      geom_line()
    
    #combo distribution plot
    df_narrow$density <- df_narrow$density+rev(df_narrow$density)
    df_wide$density <- df_wide$density+rev(df_wide$density)
    df_canon$density <- df_canon$density+rev(df_canon$density)
    df_combo<-rbind(df_narrow,df_wide,df_canon)
    df_combo$index <- rep(1:len_matrix,3)
    cd <- ggplot(df_combo, aes(index,density,color=type,group=type)) +
      geom_line()
    
  }
    
  }

