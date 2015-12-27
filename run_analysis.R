##dplyr is used later in processing
##install.packages("plyr")
##install.packages("dplyr")
library(plyr)
library(dplyr)

##read the data
setwd("~/Learning/coursera/datasciencecoursera/GettingData2015/data/project/UCI HAR Dataset")
xtrain<-read.table("./train/X_train.txt", stringsAsFactors = FALSE)
ytrain<-read.table("./train/y_train.txt", stringsAsFactors = FALSE)
ytest<-read.table("./test/y_test.txt", stringsAsFactors = FALSE)
xtest<-read.table("./test/x_test.txt", stringsAsFactors = FALSE)
features<-read.table("./features.txt",stringsAsFactors = FALSE)
act_labels<-read.table("./activity_labels.txt", stringsAsFactors = FALSE)
subj_train<-read.table("train/subject_train.txt", stringsAsFactors = FALSE)
subj_test<-read.table("test/subject_test.txt", stringsAsFactors = FALSE)

##make meaningful names for labels
colnames(ytrain) <- c("labels")
colnames(ytest)  <- c("labels")

##unify subject files
subject<-rbind(subj_train, subj_test)

##name subjects
colnames(subject)<-c("subjects")

##convert x file names using features
colnames(xtrain) <- features$V2
colnames(xtest) <- features$V2

##cbind y files to their respective x files
train<-cbind(xtrain, ytrain)
test<- cbind(xtest, ytest)

##rbind train and test into master file
master<-rbind(train, test)

##add subjects to master
master1<-cbind(master,subject)
names(master1)<-c(names(master),names(subject)) ##for some reason names got messed up; fixing here

##convert the vector's values to valid using make.names()
colnames(master1)<-make.names(names(master1),unique=TRUE)

##make logical vector for features related to mean or std deviation
log_vect<-grepl("(mean|std)",names(master1))

##subset and recombine: I was unable to find an easier way to subset based on logical and scalar argument
t<-master1[,log_vect]

## so I did this in 2 subsets
t1<-master1[,c("subjects","labels")]

## and recombined
new_master<-cbind(t,t1)

## convert labels data to factor in a new field called "activities"
##assign levels based on activity labels file
new_master$activities<- factor(new_master[,"labels"], labels=act_labels$V2)

##make a local data frame
data<-tbl_df(new_master)

## create a second, independent tidy data set with the average of each variable for each activity and each subject.
project<-data %>% group_by(activities, subjects) %>% summarise_each( funs(mean), contains("std"), contains("mean"))

##write project data set to a file
write.table(project, file = "getdata_035_project_dataset.txt", row.names = FALSE) 
