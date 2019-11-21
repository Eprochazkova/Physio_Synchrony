install.packages("psych")

Centered <- read_sav("Documents/Lowlands/Dataverse/Data/Centered.sav")

d <-Centered

d$Gender <- as.factor(d$Gender)
d <- d[d$Gender!=1,] 


colnames(d)
d<-as.data.frame(d)


my_data <- d[, c("Eyes","Face","Head","M_Eyes","M_Head","M_Face","Body", "M_Body",
                      "Hand_Shake", "M_Touch_Face", "M_Hand_Shake", "M_Head_Shake", "Head_Shake",
                 "Laugh", "M_Laugh", "Touch_Face","Mean_EDA_response", "M_SCR_response", 
                 "Smile", "M_Smile","Mean_IHR_response", "M_IHR_response")]
# print the first 6 rows
head(my_data, 6)

new = na.omit(my_data)
cormat<-signif(cor(new),2)
cormat

col<- colorRampPalette(c("blue", "white", "red"))(10)
heatmap(cormat, col=col, symm=TRUE)


# Randomly matched data

my_data1 <- agg[, c("Eyes","Face","Head","S_Eyes","S_Face","S_Head", "Body", "S_Body",
                 "Hand_Shake", "S_Touch_face", "S_Hand_shake","S_Head_shake", "Head_Shake",
                 "Laugh", "S_Laugh", "Touch_Face","Mean_EDA_response", "S_SCR", 
                 "Smile", "S_Smile","Mean_IHR_response","S_HR")]

library(psych)

ct <- corr.test(my_data, method="spearman", adjust="fdr")

ct1 <- corr.test(my_data1, method="spearman", adjust="fdr")

ct1[["r"]]

setwd("~/Documents/Lowlands/Dataverse")


write.table(ct[["p"]],"test.txt",sep=",")

write.table(ct1[["p"]],"Surtest.txt",sep=",")

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

