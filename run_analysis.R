## Create directory, Download File and unzip it
if(!file.exists("./proj")) {dir.create("./proj")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile="./proj/data.zip")
unzip(zipfile="./proj/data.zip", exdir="./proj")

## Set Working Directory
setwd("./proj/UCI HAR Dataset")

## Read Training Data and Testing Data
xtrain<-read.delim("./train/X_train.txt", sep="", header=FALSE)
xtest<-read.delim("./test/X_test.txt", sep="", header=FALSE)

## Read Training and Testing Labels
ytrain<-read.table("./train/Y_train.txt")
ytest<-read.table("./test/Y_test.txt")

## Read Training and Testing Subjects
strain<-read.table("./train/subject_train.txt")
stest<-read.table("./test/subject_test.txt")

## Append Row Labels and Subjects by combining the data, labels and subjects files for training and testing
xtrain<-cbind(strain, ytrain, xtrain)
xtest<-cbind(stest, ytest, xtest)

## Merge the training and the test sets to create one data set
x<-rbind(xtrain, xtest)
View(x)

## Find and apply Column Labels
name<-read.table("./features.txt")
names(x)<-c("Subjects", "Labels", as.character(name$V2))

## Extract only the measurements on the mean and standard deviation for each measurement
bothcol<-grep("[Ss][Tt][Dd]|[Mm][Ee][Aa][Nn]|Labels|Subjects", names(x))
x2<-x[,bothcol]
View(x2)

## Use descriptive activity names to name the activities in the data set
activity<-read.delim("activity_labels.txt", sep=" ", header=FALSE)
activitylabel<-gsub("_", " ", as.character(activity$V2))
names(activity)<-c("Labels", "Activity Name")
x3<-merge(activity, x2)
x3<-x3[,2:ncol(x3)]
View(x3)

## Appropriately label the data set with descriptive variable names
names(x3)<-gsub("^t", "Time", names(x3))
names(x3)<-gsub("^f", "Frequency", names(x3))
names(x3)<-gsub("BodyBody", "Body", names(x3))
names(x3)<-gsub("Acc", "Accelerometer", names(x3))
names(x3)<-gsub("Gyro", "Gyroscope", names(x3))
names(x3)<-gsub("Mag", "Magnitude", names(x3))
names(x3)<-gsub("mean", "Mean", names(x3))
names(x3)<-gsub("std", "Std", names(x3))

## Reorder Subjects and Activities
x3<-cbind(x3[2], x3[1], x3[3:ncol(x3)])
View(x3)

## Create an independent tidy data set with the average of each variable for each activity and each subject
library(dplyr)
AvgVals<-aggregate(x3[, 3:ncol(x3)], list(x3$`Activity Name`, x3$Subjects), mean)
AvgVals<-cbind(AvgVals[2], AvgVals[1], AvgVals[3:ncol(AvgVals)])
mnames<-c("Subject Number", "Label", names(AvgVals))
mnames<-c(mnames[1:2], mnames[5:length(mnames)])
names(AvgVals)<-mnames
View(AvgVals)
write.table(AvgVals, "TidyData.txt", row.name=FALSE)
