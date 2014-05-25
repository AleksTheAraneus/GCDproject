# Load libraries
library(utils)
library(plyr)
library(data.table)

# Set directory, download and unzip data
if (!file.exists("runAnalysis")) {
    dir.create("runAnalysis")
}

setwd("./runAnalysis")

fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile="./rawData.zip")
rawData<-unzip("./rawData.zip")

# Prepare data table for analysis:
# 1) Load desired files and merge them into one data frame
X_train<-read.table("./UCI HAR Dataset/train/X_train.txt")
Y_train<-read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train<-read.table("./UCI HAR Dataset/train/subject_train.txt")
X_test<-read.table("./UCI HAR Dataset/test/X_test.txt")
Y_test<-read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test<-read.table("./UCI HAR Dataset/test/subject_test.txt")

XYtrain<-cbind(X_train, Y_train)
XYtrain$trainOrTest<-factor("train")
XYtrain<-cbind(XYtrain, subject_train)
XYtest<-cbind(X_test, Y_test)
XYtest$trainOrTest<-factor("test")
XYtest<-cbind(XYtest, subject_test)

tempData<-rbind(XYtrain, XYtest)

# 2) Name columns
features<-read.table("./UCI HAR Dataset/features.txt")
colNames<-features[,2]
colNames<-as.vector(colNames)
colNames<-tolower(colNames)
colNames<-gsub("[[:punct:]]", "", colNames)
colNames<-c(colNames, "activity", "trainortest", "subject")

colnames(tempData)<-colNames

# 3) Extract only the variables which are means or standard deviations or not measurements
tempData<-tempData[c(grep("(mean|std|activity|trainortest|subject)",names(tempData)))]

# 4) Give the activity and subject factor forms
tempData$activity<-factor(tempData$activity,levels=c(1,2,3,4,5,6),
                                  labels=c("WALKING", "WALKING_UPSTAIRS",
                                           "WALKING_DOWNSTAIRS", "SITTING",
                                           "STANDING", "LAYING"))
tempData$subject<-as.factor(tempData$subject)

# 5) Convert into a data table
cleanDataTable<-as.data.table(tempData)

# Calculate the mean for each activity and each subject
result<-cleanDataTable[, lapply(.SD, mean), by=list(activity, subject, trainortest)]

# Save the result
write.table(result, "./resultOfRunAnalysis.txt", sep="\t")

# Tidy up
setwd("..")