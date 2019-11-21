install.packages("psych")

library(corrplot)
library(tidyverse)
library(psych)

setwd("~/Documents/Lowlands/Dataverse/Dataverse_Eliska/")
X3_Centered <- read_sav("5.Processed data/3.Centered.sav")
d <- X3_Centered

# Select females - to be paired with males
d$Gender <- as.factor(d$Gender)
d <- d[d$Gender!=1,] 
colnames(d)
d<-as.data.frame(d)


my_data <- d[, c("Body","Eyes","Face","Head","M_Eyes","M_Head","M_Face", "Mean_EDA_response",
                 "M_SCR_response","Smile", "M_Smile","Mean_IHR_response", "M_IHR_response", "M_Body",
                 "Touch_Face", "M_Touch_Face",  "M_Laugh", "Laugh",
                "M_Hand_Shake","M_Head_Shake","Hand_Shake",  "Head_Shake")]
# print the first 6 rows
head(my_data, 6)

# rename the variable names
data = my_data %>% 
  rename(F.Body = Body,F.Eyes = Eyes, F.Face = Face,F.Head = Head, M.Eyes = M_Eyes, M.Head = M_Head, M.Face= M_Face, 
         F.SCR = Mean_EDA_response, M.SCR = M_SCR_response,F.Smile = Smile, M.Smile = M_Smile, F.HR = Mean_IHR_response, 
         M.HR = M_IHR_response, M.Body = M_Body, F.Touch_Face = Touch_Face, M.TouchFace = M_Touch_Face,  M.Laugh = M_Laugh, F.Laugh = Laugh,
    M.Hand_gestures = M_Hand_Shake, M.Head_nod = M_Head_Shake, F.Hand_gestures = Hand_Shake, F.Head_nod = Head_Shake)


# Sperman correlation with fdr correction
ct <- corr.test(data, method="spearman", adjust="fdr")

matrix_ct <- (ct[["r"]])

Z <- round(matrix_ct, 1)


#Significant correlation
p.mat <- ct[["p"]]

# Plot the correlogram

col <- colorRampPalette(c("#4477AA", "#77AADD", "#FFFFFF", "#EE9988", "#BB4444"))
corrplot(Z, 
         method="color", 
         col=col(200),  
         type="upper", 
         order="hclust", 
         addCoef.col = "black", 
         tl.col="black",
         number.cex = 0.01,
         tl.cex = 0.6,
         tl.srt=70,
         p.mat =p.mat,
         sig.level = 0.05,
         insig = "label_sig")




# Randomly matched data

my_data1 <- d[, c("Eyes","Face","Head","S_Eyes","S_Face","S_Head", "Body", "S_Body",
                 "Hand_Shake", "S_Touch_face", "S_Hand_shake","S_Head_shake", "Head_Shake",
                 "Laugh", "S_Laugh", "Touch_Face","Mean_EDA_response", "S_SCR", 
                 "Smile", "S_Smile","Mean_IHR_response","S_HR")]


ct1 <- corr.test(my_data1, method="spearman", adjust="fdr")

Y = ct1[["r"]]

Y <- round(ct1, 1)

#Significant correlation
p.mat <- ct1[["p"]]

# Plot the correlogram

col <- colorRampPalette(c("#4477AA", "#77AADD", "#FFFFFF", "#EE9988", "#BB4444"))
corrplot(Y, 
         method="color", 
         col=col(200),  
         type="upper", 
         order="hclust", 
         addCoef.col = "black", 
         tl.col="black",
         number.cex = 0.01,
         tl.cex = 0.6,
         tl.srt=70,
         p.mat =p.mat,
         sig.level = 0.05,
         insig = "label_sig")




setwd("~/Documents/Lowlands/Dataverse")


write.table(ct[["r"]],"Rtest.txt",sep=",")

write.table(ct1[["r"]],"Surtest.txt",sep=",")

# Compare correlations

# cran repository
install.packages("cocor", lib="/my/own/R-packages/")

# alternative repository
install.packages("cocor", lib="/my/own/R-packages/", repo="http://comparingcorrelations.org/repo")



#INPUT:
  require(cocor) # load package

#Eyes
cocor.indep.groups(r1.jk=+0.69, r2.hm=+0.34, n1=162, n2=162, alternative="two.sided", alpha=0.05, conf.level=0.95, null.value=0)

#Head
cocor.indep.groups(r1.jk=+0.22, r2.hm=0.19, n1=162, n2=162, alternative="two.sided", alpha=0.05, conf.level=0.95, null.value=0)


#face
cocor.indep.groups(r1.jk=+0.14, r2.hm=0.13, n1=162, n2=162, alternative="two.sided", alpha=0.05, conf.level=0.95, null.value=0)

#Skin conductance
cocor.indep.groups(r1.jk=+0.32, r2.hm=-0.7, n1=162, n2=162, alternative="two.sided", alpha=0.05, conf.level=0.95, null.value=0)

#Heart rate
cocor.indep.groups(r1.jk=+0.36, r2.hm=-0.7, n1=162, n2=162, alternative="two.sided", alpha=0.05, conf.level=0.95, null.value=0)

# Smile
cocor.indep.groups(r1.jk=+0.31, r2.hm=+0.02, n1=162, n2=162, alternative="two.sided", alpha=0.05, conf.level=0.95, null.value=0)

#Laugh
cocor.indep.groups(r1.jk=+0.51, r2.hm=-0.28, n1=162, n2=162, alternative="two.sided", alpha=0.05, conf.level=0.95, null.value=0)

#Touch face
cocor.indep.groups(r1.jk=+0.27, r2.hm=+0.25, n1=162, n2=162, alternative="two.sided", alpha=0.05, conf.level=0.95, null.value=0)

#Head nod
cocor.indep.groups(r1.jk=+0.66, r2.hm=-0.23, n1=162, n2=162, alternative="two.sided", alpha=0.05, conf.level=0.95, null.value=0)

#Hand gestures
cocor.indep.groups(r1.jk=+0.87, r2.hm=+0.3, n1=162, n2=162, alternative="two.sided", alpha=0.05, conf.level=0.95, null.value=0)

