#import libraries
library(downloader)
library(data.table)
library(utils)
library(dplyr)

#download, unzip and import file
src= ("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")
dest = ("./data/dataset.zip")
download.file(src, dest)
temp<- tempfile()
unzip(dest, exdir = "./data/zip")

#read in data
#label.set <- read.table("./data/zip/UCI HAR Dataset/activity_labels.txt", col.names = c('level', 'label'))
x_test <- read.table("./data/zip/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/zip/UCI HAR Dataset/test/y_test.txt")
colnames(y_test) <- "activity"
x_train <- read.table("./data/zip/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/zip/UCI HAR Dataset/train/y_train.txt")
colnames(y_train) <- "activity"
subject_train <- read.table("./data/zip/UCI HAR Dataset/train/subject_train.txt")
subject_test <- read.table("./data/zip/UCI HAR Dataset/test/subject_test.txt")
activity_labels <- read.table("./data/zip/UCI HAR Dataset/activity_labels.txt")



#Merges the training and the test sets to create one data set.
test <- cbind(y_test, x_test)
test<- cbind(subject_test, test)
train <- cbind(y_train, x_train)
train<- cbind(subject_train, train)
df <- rbind(test, train)

#add labels
features <-scan("./data/zip/UCI HAR Dataset/features.txt", character(), quote = "")
read_lines <- seq(2, length(features), by =2)
features <- features[read_lines]
add_features <- c("subject", "activity")
features <- append(features, add_features, after = 0)
colnames(df) <- features
#Uses descriptive activity names to name the activities in the data set

df[,2] <- activity_labels[df[,2], 2]

#Extracts only the measurements on the mean and standard deviation for each measurement. 
features2<- colnames(df)
requiredFeatures <- features2[grep('-(mean|std)\\(\\)', features2)]
requiredFeatures<- append(requiredFeatures, add_features, after = 0)
df2 <- df[, requiredFeatures]

#cleanup labels
clean_labels <- gsub('\\-|\\(|\\)', '', as.character(requiredFeatures))
colnames(df2) <- clean_labels

#output tidy data set
write.csv(df2, file="./smartphone_data_set_tidy.csv",  row.names= FALSE)

#melt data to produce second table containing average of each variable for each activiy & subject
av_each_variable <- aggregate(df2[,3:68],by=list(df2$activity,df2$subject),FUN=mean)
colnames(av_each_variable)[1] <- 'Activity'
colnames(av_each_variable)[2] <- 'Subject'

#write second table
write.table(av_each_variable, "./average_of_each_variable_by_subject.txt")