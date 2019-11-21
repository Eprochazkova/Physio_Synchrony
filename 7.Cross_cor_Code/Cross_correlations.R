
Physiology_Data_bef_Crosscor <- read_sav("Here load in Raw data file")


options(width = 110)


library(readxl)
library(plyr)
library(ggplot2)
library(data.table)
library(parallel)
library(pbapply) # add progress bar
library(seewave)
library(car)
library(dplyr)
library(magrittr)
library(tibble)
library(rlist)


d <- data.frame(Physio_data)


d$DIA_F_pupilDiameter[d$DIA_F_pupilDiameter == 999] <- NA
d$DIA_M_pupilDiameter[d$DIA_F_pupilDiameter == 999] <- NA

save(d, file = "AllfilenamesAllPhysio.RData")
load("AllfilenamesAllPhysio.RData")

### MISSINGs ###
# coded: 0 = include, 1 = exclude from analysis

head(d)
## person-/session-wise exclusion
# HR PPN1
d$ExclF_HR <- 0
d$ExclF_HR[(d$filename == "Dyad1")] <- 1 
d$ExclF_HR[(d$filename == "Dyad9")] <- 1 
d$ExclF_HR[(d$filename == "Dyad14" )] <- 1 
d$ExclF_HR[(d$filename == "Dyad16")] <- 1 
d$ExclF_HR[(d$filename == "Dyad23")] <- 1 
d$ExclF_HR[(d$filename == "Dyad28")] <- 1 
d$ExclF_HR[(d$filename == "Dyad35")] <- 1 
d$ExclF_HR[(d$filename == "Dyad36")] <- 1 
d$ExclF_HR[(d$filename == "Dyad42" )] <- 1 
d$ExclF_HR[(d$filename == "Dyad 58" )] <- 1 
d$ExclF_HR[(d$filename == "Dyad 59")] <- 1 
d$ExclF_HR[(d$filename == "Dyad 60" )] <- 1 
d$ExclF_HR[(d$filename == "Dyad46" & d$epochName== "ECG_F_S_Int")] <- 1 

# HR PPN2
d$ExclM_HR <- 0
d$ExclM_HR[d$filename == "Dyad1" ] <- 1
d$ExclM_HR[d$filename == "Dyad9" ] <- 1
d$ExclM_HR[d$filename == "Dyad14" ] <- 1
d$ExclM_HR[d$filename == "Dyad23" ] <- 1
d$ExclM_HR[d$filename == "Dyad28" ] <- 1
d$ExclM_HR[d$filename == "Dyad29" ] <- 1
d$ExclM_HR[d$filename == "Dyad30" ] <- 1
d$ExclM_HR[d$filename == "Dyad31" ] <- 1
d$ExclM_HR[d$filename == "Dyad32" ] <- 1
d$ExclM_HR[d$filename == "Dyad33" ] <- 1
d$ExclM_HR[d$filename == "Dyad34" ] <- 1
d$ExclM_HR[d$filename == "Dyad35" ] <- 1
d$ExclM_HR[d$filename == "Dyad36" ] <- 1
d$ExclM_HR[d$filename == "Dyad42" ] <- 1
d$ExclM_HR[d$filename == "Dyad 58" ] <- 1
d$ExclM_HR[d$filename == "Dyad 59" ] <- 1
d$ExclM_HR[d$filename == "Dyad 60" ] <- 1
d$ExclM_HR[d$filename == "Dyad 63" ] <- 1
d$ExclM_HR[(d$filename == "Dyad46" & d$epochName== "ECG_F_S_Int")] <- 1
# SC Female
d$ExclF_SC <- 0
d$ExclF_SC [(d$filename == "Dyad46" & d$epochName== "ECG_F_S_Int")] <- 1 
d$ExclF_SC[d$filename == "Dyad1"] <- 1 
d$ExclF_SC[d$filename == "Dyad7"] <- 1
d$ExclF_SC[d$filename == "Dyad9"] <- 1
d$ExclF_SC[d$filename == "Dyad13"] <- 1
d$ExclF_SC[d$filename == "Dyad14"] <- 1
d$ExclF_SC[d$filename == "Dyad23"] <- 1
d$ExclF_SC[d$filename == "Dyad28"] <- 1
d$ExclF_SC[d$filename == "Dyad29"] <- 1 
d$ExclF_SC[d$filename == "Dyad35"] <- 1
d$ExclF_SC[d$filename == "Dyad36"] <- 1
d$ExclF_SC[d$filename == "Dyad42"] <- 1
d$ExclF_SC[d$filename == "Dyad 51"] <- 1
d$ExclF_SC[d$filename == "Dyad 58"] <- 1
d$ExclF_SC[d$filename == "Dyad 59"] <- 1
d$ExclF_SC[d$filename == "Dyad 60"] <- 1
d$ExclF_SC[d$filename == "Dyad 63"] <- 1
# SC Male
d$ExclM_SC <- 0
d$ExclM_SC [(d$filename == "Dyad46" & d$epochName== "ECG_F_S_Int")] <- 1 
d$ExclM_SC[d$filename == "Dyad1"] <- 1 
d$ExclM_SC[d$filename == "Dyad9"] <- 1
d$ExclM_SC[d$filename == "Dyad11"] <- 1
d$ExclM_SC[d$filename == "Dyad12"] <- 1
d$ExclM_SC[d$filename == "Dyad13"] <- 1
d$ExclM_SC[d$filename == "Dyad14"] <- 1
d$ExclM_SC[d$filename == "Dyad22"] <- 1
d$ExclM_SC[d$filename == "Dyad23"] <- 1
d$ExclM_SC[d$filename == "Dyad28"] <- 1
d$ExclM_SC[d$filename == "Dyad35"] <- 1
d$ExclM_SC[d$filename == "Dyad36"] <- 1
d$ExclM_SC[d$filename == "Dyad40"] <- 1
d$ExclM_SC[d$filename == "Dyad41"] <- 1
d$ExclM_SC[d$filename == "Dyad42"] <- 1
d$ExclM_SC[d$filename == "Dyad 55"] <- 1
d$ExclM_SC[d$filename == "Dyad 57"] <- 1
d$ExclM_SC[d$filename == "Dyad 58"] <- 1
d$ExclM_SC[d$filename == "Dyad 59"] <- 1
d$ExclM_SC[d$filename == "Dyad 60"] <- 1
d$ExclM_SC[d$filename == "Dyad 63"] <- 1
d$ExclM_SC[d$filename == "Dyad 69"] <- 1
d$ExclM_SC[d$filename == "Dyad 70"] <- 1

#### create "global" excluding variable per physio response

d$Excl_HR <- 0
for (i in 1:length(d$ExclF_HR)) {
  if (d$ExclF_HR[i] || d$ExclM_HR[i]) {
    d$Excl_HR[i] <- 1
  }
}

d$Excl_SC <- 0
for (i in 1:length(d$ExclF_SC)) {
  if (d$ExclF_SC[i] || d$ExclM_SC[i]){
    d$Excl_SC[i] <- 1
  }
}


save(d, file = "DatingStudy.RData")
write.table(d, file = '~/Insert_path/Raw_data', sep = ',')

# Start

load("Raw_data.RData")


#### original filenames analysis -------------------

d <- Raw_data.RData 
d<-as.data.frame(d)

## setting up lists and matrices ----

#numdyad = length(unique(d$filename))

# set up dataset in a format such that there are different matrices for each filename stored in a list, separated for the face and noface condition
#here I created a new filename variable that consist of each name and epoch, then it means that I will have 55 x 9 matrixes

colnames(d)
d$Filename=gsub('.*d', '', d$filename)
d$Filename=as.numeric(d$Filename)


d$xx<- substr(d$epochName,7, nchar(d$epochName[1])+3)
unique(d$Filename)

d$ID_Trial<- with(d, paste(Filename, xx, sep='_'))
unique(d$ID_Trial)

d<- d[which (d$xx != "F_Imp"),]
d<- d[which (d$xx != "Base_F_Imp"),]
d<- d[which (d$xx != "Ratings_F_Imp"),]
d<- d[which (d$xx != "Base_F_Int"),]
d<- d[which (d$xx != "Ratings_F_Int"),]
d<- d[which (d$xx != "Base_S_Int"),]
d<- d[which (d$xx != "Ratings_S_Int"),]
d<- d[which (d$xx != "Post_F_Imp"),]

unique(d$xx)

d$ID_Trial<-d$Filename
unique(d$ID_Trial)

#getting rid off outliers---

dHR <- d[which(d$Excl_HR != 1),]
dSC<- d[which(d$Excl_SC != 1),]
dPupil<-d[which(d$Excl_Pupil != 1),]

unique(dHR$Filename)
unique(dSC$Filename)
unique(dPupil$Filename)
unique(d$Filename)

## setting up lists and matrices ----

HRdyad = length(unique(dHR$ID_Trial))
SCdyad = length(unique(dSC$ID_Trial))

HRlist <- vector("list", HRdyad)
SClist <- vector("list", SCdyad)

HRmatrix <- matrix(NA, nrow = 160000, ncol = ncol(d))
SCmatrix <- matrix(NA, nrow = 160000, ncol = ncol(d))


l = 1
for (i in unique(dHR$ID_Trial)){
  HRmatrix <- dHR[which(dHR$ID_Trial == i),]
  HRlist[[l]] <- HRmatrix
  l = l + 1
}

l = 1
for (i in unique(dSC$ID_Trial)){
  SCmatrix <- dSC[which(dSC$ID_Trial == i),]
  SClist[[l]] <- SCmatrix
  l = l + 1
}

numdyadWCC <- length(unique(d$ID_Trial))
HRWCC<- length(unique(dHR$ID_Trial))
SCWCC<- length(unique(dSC$ID_Trial))


################## WCC, peak picking and plots ------------------------------------


### make vectors to store outcome of WCC and peak picking for each combination of measures -------

# IHR
LLWCCList_IHR <- NULL
LLWCCList_IHR<-vector("list", HRWCC)
LLPeakList_IHR <- NULL
LLPeakList_IHR<-vector("list", HRWCC)


# SCL
LLWCCList_SCL <- NULL
LLWCCList_SCL<-vector("list", SCWCC)
LLPeakList_SCL <- NULL
LLPeakList_SCL<-vector("list", SCWCC)


# make a progressbar
pb <- txtProgressBar(min = 0, max = numdyadWCC, style = 3)


# number of samples (we have a sample rate of 20 Hz, so 20 samples = 1 sec)
wSize <- 10*8
tMax <- 10*4 # 4 sec
wInc <- 20  # 1/20 sec
tInc <- 1 

windowMax <- 10*8  # xxx
tauMax <- 10*4
windowInc <- 20
tauInc <- 1

### WCC correlation #########

# set-up for pilot; to change: (1) facelist_try = facelist, (2) delete 1:2000, (3) numdyadWCC = length(facelist) = unique(d$filename)

#### CHANGE NAMES FOR HF and LF variables 

for (i in 1:HRWCC){
  print(Sys.time())
  
  #IHR
  LLWCCList_IHR[[i]]<-WCC(HRlist[[i]][,"ECG_F_IHR"],HRlist[[i]][,"ECG_M_IHR"])
  LLWCCList_IHR[[i]] <- na.omit(t(LLWCCList_IHR[[i]])) # last column always NA -> delete
  LLWCCList_IHR[[i]] <- t(LLWCCList_IHR[[i]]) # columns: lags; rows: windows
  write.csv(LLWCCList_IHR[[i]], file = paste(HRlist[[i]]$Filename[1], "_IHR_", HRlist[[i]]$xx[1],"_W", wSize, "_Incr", wInc, "_Tmax", tMax, ".csv", sep = ""), row.names = FALSE)
  print(Sys.time())
  
} 

  for (i in 1:SCWCC){
    print(Sys.time())
  #SCL
  SClist[[i]][,"Excl_SC"]
  LLWCCList_SCL[[i]]<-WCC(SClist[[i]][,"EDA_F_SkinConductance"],SClist[[i]][,"EDA_M_SkinConductance"])
  LLWCCList_SCL[[i]] <- na.omit(t(LLWCCList_SCL[[i]])) # last column always NA -> delete
  LLWCCList_SCL[[i]] <- t(LLWCCList_SCL[[i]]) # columns: lags; rows: windows
  write.csv(LLWCCList_SCL[[i]], file = paste(SClist[[i]]$Filename[1], "_SCL_", SClist[[i]]$xx[1], "_W", wSize, "_Incr", wInc,"_Tmax", tMax, ".csv", sep = ""), row.names = FALSE)
  print(Sys.time())
  
  setTxtProgressBar(pb, SCWCC)
  } 

close(pb)

# dim(na.omit(FaceWCCList[[i]]))

#LoessSpan <- 0.25
#L <- 25   # this one 

#LoessSpan <- 0.30
#L <- 30

LoessSpan <- 0.35
#L <- 35
setwd("~/Documents/Lowlands/Data_Lowlands/FINAL_DATA_JULY_2018/Analysis4_Eliska/Peakpicking1")

# peak picking
for (i in 1:HRWCC) {

  # IHR
  LLPeakList_IHR[[i]] <- peakpick(LLWCCList_IHR[[i]], pspan = LoessSpan)
  write.csv(LLPeakList_IHR[[i]], file = paste(HRlist[[i]]$Filename[1], "_IHR_", HRlist[[i]]$xx[1],"_W",wSize, "_Incr", wInc, "_Tmax", tMax, "_peak.csv", sep = ""), row.names = FALSE)
  
}

for (i in 1:SCWCC) {
  # SCL
  LLPeakList_SCL[[i]] <- peakpick(LLWCCList_SCL[[i]], pspan = LoessSpan)
  write.csv(LLPeakList_SCL[[i]], file = paste(SClist[[i]]$Filename[1], "_SCL_", SClist[[i]]$xx[1],"_W",wSize, "_Incr", wInc, "_Tmax", tMax, "_peak.csv", sep = ""), row.names = FALSE)

}

library(Matrix)
library(plotrix)
library(fields)
library(viridis)
col1<-colorRampPalette(viridis(100))

for (i in 1:HRWCC) {

  # IHR
  pdf( paste(HRlist[[i]]$Filename[1], "_IHR_", HRlist[[i]]$xx[1],"_W",wSize, "_Incr", wInc, "_Tmax", tMax, ".pdf", sep = ""), width = 10, height = 5) 
  image(LLWCCList_IHR[[i]], col = col1(100))
  lines(seq(0,1,length.out=length(LLPeakList_IHR[[i]]$maxIndex)),(LLPeakList_IHR[[i]]$maxIndex/(tMax + 1))+.5,lwd=3)
  abline(h = 0.5)
  dev.off()
  
}
  for (i in 1:SCWCC) {
  
  # SCL
  pdf( paste(SClist[[i]]$Filename[1], "_SCL_", SClist[[i]]$xx[1],"_W",wSize, "_Incr", wInc, "_Tmax", tMax, ".pdf", sep = ""), width = 10, height = 5) 
  image(LLWCCList_SCL[[i]], col = col1(100))
  lines(seq(0,1,length.out=length(LLPeakList_SCL[[i]]$maxIndex)),(LLPeakList_SCL[[i]]$maxIndex/(tMax + 1))+.5,lwd=3)
  abline(h = 0.5)
  dev.off()
  }


HRSynchronyMeasures_matrix <- matrix(NA, nrow = numdyadWCC, ncol = 15)
colnames(HRSynchronyMeasures_matrix) <- c("dyad_HR", "Epochname","ID_trial", "WCCmean_HFHR", "WCCsd_HFHR", "TLmean_HFHR", "TLsd_HFHR", 
                                        "WCCmean_LFHR", "WCCsd_LFHR", "TLmean_LFHR", "TLsd_LFHR", 
                                        "WCCmean_IHR", "WCCsd_IHR", "TLmean_IHR", "TLsd_IHR")
                                  

SCSynchronyMeasures_matrix <- matrix(NA, nrow = numdyadWCC, ncol = 7)
colnames(SCSynchronyMeasures_matrix) <- c("dyad_SC", "Epochname","ID_trial", "WCCmean_SCL", "WCCsd_SCL", "TLmean_SCL", "TLsd_SCL") 
                                          
 
# get summary statistics 
epochnum <-length(unique(dHR$epochName))

for (i in 1:HRWCC){
  HRSynchronyMeasures_matrix[i,1] <- unique(HRlist[[i]][,"Filename"[1]]) 
  HRSynchronyMeasures_matrix[i,2] <- unique(HRlist[[i]][,"epochName"[1]]) 
  HRSynchronyMeasures_matrix[i,3] <- unique(HRlist[[i]][,"ID_Trial"[1]])
  HRSynchronyMeasures_matrix[i,4] <- mean(LLPeakList_IHR[[i]]$maxValue, na.rm = T)
  HRSynchronyMeasures_matrix[i,5] <- sd(LLPeakList_IHR[[i]]$maxValue, na.rm = T)
  HRSynchronyMeasures_matrix[i,6] <- mean(LLPeakList_IHR[[i]]$maxIndex, na.rm = T)
  HRSynchronyMeasures_matrix[i,7] <- sd(LLPeakList_IHR[[i]]$maxIndex, na.rm = T)

}
  write.csv(HRSynchronyMeasures_matrix, file = paste("HR_SynchMeasures", "_W", wSize, "_Incr", wInc, "_Tmax", tMax, "_L",  ".csv", sep = ""))  #check
  

for (i in 1:SCWCC){
  SCSynchronyMeasures_matrix[i,1] <- unique(SClist[[i]][,"Filename"[1]]) 
  SCSynchronyMeasures_matrix[i,2] <- unique(SClist[[i]][,"epochName"[1]]) 
  SCSynchronyMeasures_matrix[i,3] <- unique(SClist[[i]][,"ID_Trial"[1]])
  SCSynchronyMeasures_matrix[i,4] <- mean(LLPeakList_SCL[[i]]$maxValue, na.rm = T)
  SCSynchronyMeasures_matrix[i,5] <- sd(LLPeakList_SCL[[i]]$maxValue, na.rm = T)
  SCSynchronyMeasures_matrix[i,6] <- mean(LLPeakList_SCL[[i]]$maxIndex, na.rm = T)
  SCSynchronyMeasures_matrix[i,7] <- sd(LLPeakList_SCL[[i]]$maxIndex, na.rm = T)
  
}

  write.csv(SCSynchronyMeasures_matrix, file = paste("SC_SynchMeasures", "_W", wSize, "_Incr", wInc, "_Tmax", tMax, "_L",  ".csv", sep = ""))  #check
  
  

# WCC function -------------------------------


WCC<- function(ts1,ts2,windowSize=wSize,windowInc=wInc,tauMax=tMax,tauInc=tInc){
  #Prep data
  #Turn vecors into row
  if(is.null((dim(ts1)))){
    ts1<-t(ts1)
    ts2<-t(ts2)
  }
  #build results matrix
  resultsMatrix<-matrix(NA,nrow=(floor((NCOL(ts1)-windowSize-tauMax)/windowInc)),ncol=((tauMax/tauInc)*2)+2)
  for ( i in 1:floor((NCOL(ts1)-windowSize-tauMax)/windowInc)){
    #Lag offset value
    tau<--tauMax
    #window overlap
    window<--windowInc+i*windowInc
    #fill in results matrix
    for ( j in 1:((2*(tauMax/tauInc))+1)){
      if (tau<=0) {
        Wx<-ts1[(1+tauMax+window):(1+tauMax+(windowSize-1)+window)]
        Wy<-ts2[(1+tauMax+tau+window):(1+tauMax+(windowSize-1)+tau+window)]
      } else {
        Wx<-ts1[(1+tauMax-tau+window):(1+tauMax+(windowSize-1)-tau+window)]
        Wy<-ts2[(1+tauMax+window):(1+tauMax+(windowSize-1)+window)]
      }
      resultsMatrix[i,j]<-(1/(windowSize-1))*sum(((Wx-mean(t(Wx)))*(Wy-mean(t(Wy))))/(sd(Wx)*sd(Wy)))
      resultsMatrix[]
      tau<-tau+tauInc
    }
  }
  return(resultsMatrix)
}

# Plot function ------------

plotWCC<-function(r,color="heat",xtick=1,ytick=1,peaks=NA,main="Windowed Cross Correlations",horizontal=F,legend=F,xlab="Elapsed Time",ylab="Lag"){
  library(Matrix)
  library(plotrix)
  library(fields)
  library(viridis)
  if(horizontal==F & legend==T){
    par(mar=c(5,4.5,4,7))
  }else if(horizontal==T & legend==T){
    par(mar=c(9,4.5,5,4))
  }
  if (color=="rainbow"){
    col1<-colorRampPalette(c("red", "orange", "yellow", "green", "mediumspringgreen", "cyan", "dodgerblue4", "blue", "purple4","purple","violetred","red"))
  }
  if (color=="redblue"){
    col1<-colorRampPalette(c("dodgerblue4", "dodgerblue3", "dodgerblue2", "dodgerblue1", "dodgerblue", "white",  "red", "red1","red2","red3","red4","firebrick4"))
  }
  if (color=="heat"){
    col1<-colorRampPalette(heat.colors(100))
  }
  if (color=="gray"){
    col1<-colorRampPalette(gray.colors(100,start=0,end=1))
  }
  if (color=="cm"){
    col1<-colorRampPalette(cm.colors(100))
  }
  if (color=="viridis"){
    col1<-colorRampPalette(viridis(100))
  }
  image(1:nrow(r), 1:ncol(r),r,col=col1(100), xlab=xlab, ylab=ylab,axes=F,main= main)
  yLabels<-seq(1,nrow(r)) 
  xLabels<-seq(-tMax,tMax,tInc) 
  box()
  axis(side = 2, at=seq(0,length(xLabels)-1,xtick), labels=seq(-tMax,tMax,tInc*xtick),las=1,cex.axis=1.0)
  axis(side = 1, at=seq(0,length(yLabels)-1,ytick), labels=seq(0,length(yLabels)-1,ytick),las=1,cex.axis=1.0)
  if(legend==T){
    image.plot(1:nrow(r), 1:ncol(r),r,col=col1(100),breaks=seq(-1,1,length.out=101), legend.only=TRUE,horizontal=horizontal)}
  if (is.na(peaks[1]) == FALSE){
    lines(seq(1,nrow(r)),((peaks/2)+tMax)/tInc)
  }
  if(legend==T){
    par(mar=c(5, 4, 4, 2) + 0.1 )}
}

# Peak Picking function ------------

peakpick<- function(tAllCor, Lsize=8, graphs=0, pspan=.25, type="Max",tFileName="peak") { 
  #----------------check for validness of parameters -------------------
  colLen <- length(tAllCor[1,]) # col length --- number of columns 
  rowLen <- length(tAllCor[,1]) # row length --- number of rows     
  tLsize <- floor((1/2)*colLen) # maximum local search region
  
  if(Lsize<1 || Lsize>tLsize) { # Lsize too small or too large
    errorStr<- paste("Lsize should be >0 and <= ", tLsize, sep="")
    stop(errorStr) # print error message and stop the program
  }
  if(graphs<0||graphs>rowLen) { # num of graphics to print is too small or large
    errorStr <- paste("graphs should be >=0 and <= ", rowLen, sep="")
    stop(errorStr) # print error message and stop the program
  }
  if(pspan<0 || pspan>1) { # invalid pspan value
    stop("pspan should be >0 and <1\n") # print error message and stop program
  }
  if(type!="Max"&&type!="Min"&&type!="max"&&type!="min"){ # only two types
    stop("valid types are: max|Max or Min|min \n") # print error message and stop
  }
  #-----------Initilization------------------------------------------------
  drawgraph <- 0 # graphics drawed
  colLen <- length(tAllCor[1,]) # col length  
  rowLen <- length(tAllCor[,1]) # row length 
  xSequence <- seq(-(colLen-1), (colLen-1), by=1) # X axis for each graph
  mx<- rep(NA, (2*colLen-1)) #vector for keeping temp peak value for a row
  #data points will be 2*colLen-1 after smooth
  tIndex <- rep(NA, rowLen) #vector of peak index---one peak index for each row
  tValue <- rep(NA, rowLen) #vector of peak value---one peak value for each row 
  
  #------------- type == max or Max ---------------------------------------
  if(type=="Max"||type=="max") { #compute local maximum
    for(rowNo in c(1: rowLen)) { #acess each row
      #eliminate missing value
      miss <- is.na(tAllCor[rowNo, ]) #transfer a row to be T--"NA"  and F not "NA"
      #initialize the position of NA in a row 
      missposition <- 0 
      for(mIndex in c(1:colLen)) { #evaluate an entire row
        missposition <- mIndex #the position of NA
        if(miss[missposition]) break #find one
        missposition <- missposition+1 #increase count
        if(missposition==colLen+1) break #No NA in this row
      }
      #cat("missposition=", missposition, "\n")
      #if has missing value 
      if(missposition <= colLen) next #skip a row with NA
      
      else { # no missing value
        drawgraph <- drawgraph+1 #number of graph to draw
        tCor <- tAllCor[rowNo, ] #number of columns
        #smooth
        t1 <- predict(loess(tCor~c(1:colLen), degree=2, span=pspan ))
        #data points is set to n
        t2 <- spline(c(1:colLen), t1, n=(2*colLen-1))$y
        
        # show calculate progress
        # cat("row=", rowNo, "\n")
        #----------- process a row --find max value and max index------ 
        windowWidth <- 0  # searched region
        lookAhead <- 0  # look ahead data points
        for(j in 1:(colLen-1)) {  # search from 1 to colLen -1
          windowWidth <- windowWidth+1 # increase search ed region
          # select the search region, the center of search region 
          # is in the middle of t2, notice that t2 has 2*colLen-1
          # data points.
          tSelect <- (colLen - windowWidth):(colLen+windowWidth)
          mx[j] <- max(t2[tSelect], na.rm=T) # store temp max value
          if(j==1) mmx <- mx[j] # mmx is final local max value
          #remember current max
          else { # if j != 1
            if(mx[j]>mmx) { # new temp max value , note only one                                                     # max value in tSelect
              lookAhead <- 0 # set stop search criterion to 0,
              # the criterion is that if we find
              # Lsize data points less than current
              # max, then stop and the current max 
              # value is the local maximum we wanted
              mmx <- mx[j] # update new max value
            }
            else if(mx[j]<=mmx) { # if other values are less than
              # current maximum
              # increase the count---how many neighbor data                                            # point are less than current maximum 
              lookAhead <- lookAhead+1 
              if(lookAhead>=Lsize) break # meet criterion
            }
          }#else
        }#for j--max value and index for each row
        #use match function to find the index
        Index <- match(mmx, t2[tSelect])+tSelect[1]-1
        # tSelect[1] is the first index of the selected window
        
        # relative position to the middle point
        position <- Index -colLen
        
        #according to the local maximium definition 
        if(position >(colLen - Lsize - 1) || position < (-(colLen - Lsize -1))) { # fail
          tIndex[rowNo] <- NA
          tValue[rowNo] <- NA
        }
        else { # found a local maximum
          tIndex[rowNo] <- position
          tValue[rowNo] <-mmx
        }
        
        #draw plots      
        if(drawgraph <= graphs) {
          # define graphic file name
          tepsfile <- paste(tFileName, "Max", rowNo, ".eps", sep="") 
          # title of the graph
          tmain <- paste("max Index", tFileName, "r", rowNo,"w", Lsize, sep="")
          # write to postscript format
          postscript(tepsfile, height=6.4, horizontal=F)
          
          # draw borders and their labels
          plot(c(-(colLen-1), (colLen-1)), c(-1,1), xlab="Lag", ylab="Cross Correlation", main=tmain, type="n")
          
          # draw the curve
          lines(xSequence, t2, type="l")
          
          # draw the local maximum
          lines(c(position,position), c(-1,1), type="l", lty=8)
          
          # draw the axies
          lines(c(0,0), c(-1,1), type="l", lty=4)
          lines(c(-(colLen-1), (colLen-1)), c(0,0), type="l", lty=4)
          dev.off() # term off other device in order run drawing procedure
        } # if drawgraph
      } #else no missing value
    } # for rowNo-- process each row 
    #end of process a row
    return(list(maxIndex=tIndex, maxValue=tValue))
  }#if type=max
  
  #-------------------------------------------------------------------------------
  # type == Min or min
  #-------------------------------------------------------------------------------
  else if(type=="Min"||type=="min") {
    for(rowNo in c(1: rowLen)) { 
      #eliminate missing value
      miss <- is.na(tAllCor[rowNo, ])
      missposition <- 0
      for(mIndex in c(1:colLen)) {
        missposition <- mIndex #the position of NA
        if(miss[missposition]) break #find one
        missposition <- missposition+1
        if(missposition==colLen+1) break
      }
      #cat("missposition=", missposition, "\n")
      #if has missing value 
      if(missposition <= colLen) next #skip a row with NA
      
      else { # no missing value
        drawgraph <- drawgraph+1
        tCor <- tAllCor[rowNo, ]
        t1 <- predict(loess(tCor~c(1:colLen), degree=2, span=pspan ))
        t2 <- spline(c(1:colLen), t1, n=(2*colLen-1))$y
        # show calculate progress
        #cat("row=", rowNo, "\n")
        
        #process a row --find max value and max index 
        #-------------------------------------------------------------
        windowWidth <- 0
        lookAhead <- 0
        for(j in 1:(colLen-1)) { 
          windowWidth <- windowWidth+1
          tSelect <- (colLen - windowWidth):(colLen+windowWidth)
          mx[j] <- min(t2[tSelect], na.rm=T)
          if(j==1) mmx <- mx[j]
          #remember current max
          else {
            if(mx[j]<mmx) { #only one value in tSelect
              lookAhead <- 0
              mmx <- mx[j]
            }
            else if(mx[j]>=mmx) {
              lookAhead <- lookAhead+1
              if(lookAhead>=Lsize) break
            }
          }#else
        }#for j--max value and index for each row
        #use match function to find the index
        Index <- match(mmx, t2[tSelect])+tSelect[1]-1
        position <- Index -colLen
        
        if(position >(colLen - Lsize -1) || position < (-(colLen -Lsize -1))) { # fail
          tIndex[rowNo] <- NA
          tValue[rowNo] <- NA
        }
        else { 
          tIndex[rowNo] <- position
          tValue[rowNo] <-mmx
        }
        
        #draw first 10 plots      
        if(drawgraph <= graphs) {
          tepsfile <- paste(tFileName, "Min", rowNo, ".eps", sep="") 
          tmain <- paste( "min Index", tFileName, "r", rowNo,"w", Lsize, sep="")
          postscript(tepsfile, height=6.4, horizontal=F)
          plot(c(-(colLen-1), (colLen-1)), c(-1,1), xlab="Lag", ylab="Cross Correlation", main=tmain, type="n")
          
          lines(xSequence, t2, type="l")
          lines(c(position,position), c(-1,1), type="l", lty=8)
          lines(c(0,0), c(-1,1), type="l", lty=4)
          lines(c(-(colLen-1), (colLen-1)), c(0,0), type="l", lty=4)
          dev.off()
        } # if drawgraph 
      } #else no missing value
    } # rowNo-- process each row 
    #end of process a row
    #-----------------------------------------------------------------------
    
    return(list(minIndex=tIndex, minValue=tValue))
  }#if type=mix
}

