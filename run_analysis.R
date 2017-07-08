
getwd()
setwd("C:/Users/thedo/Documents/R/Assignment4")

install.packages("data.table")
library(data.table)

install.packages("readr")
library(readr)

library(dplyr)

# use fixed length 16, 561 columns for X

cols <- c(16)
cols_rep <- rep(cols, each = 561)

train_x <- read_fwf(
  file="./data/UCI HAR Dataset/train/X_train.txt",   
  skip=0,
  fwf_widths(cols_rep))

test_x <- read_fwf(
  file="./data/UCI HAR Dataset/test/X_test.txt",   
  skip=0,
  fwf_widths(cols_rep))

# combine x train and test
total_x <- rbind(train_x, test_x)

total_x <- data.table(total_x)

# read from features file
features <- data.table(read.table("./data/UCI HAR Dataset/features.txt", sep = " "))

# only keep the mean and std column names
features <- features[grepl("mean", V2) | grepl("std", V2),]
features <- features[!grepl("meanFreq", V2),]

nrow(features)
#keep columns we want
select_columns <- features$V1
total_x <- subset(total_x, , select_columns)

ncol(total_x)
#rename the columns
old_column_names <- names(total_x)
new_column_names <- sapply(features$V2, as.character)
setnames(total_x, old = old_column_names, new = new_column_names)

# read from activity labels file
activity_labels <- data.table(read.table("./data/UCI HAR Dataset/activity_labels.txt", sep = " "))
#rename the columns
setnames(activity_labels, old = c("V1", "V2"), new = c("activity_code", "activity_name"))

# read from train y file
train_y <- data.table(read.table("./data/UCI HAR Dataset/train/y_train.txt", sep = " "))

# read from test y file
test_y <- data.table(read.table("./data/UCI HAR Dataset/test/y_test.txt", sep = " "))

# combine test and train data
total_y <- rbind(train_y, test_y)

#rename the columns
setnames(total_y, old = c("V1"), new = c("activity_code"))

# merge activity name in
merged_Y = merge(total_y, activity_labels,by.x="activity_code", by.y="activity_code")


# read from train subject file
subject_train <- data.table(read.table("./data/UCI HAR Dataset/train/subject_train.txt", sep = " "))

# read from test subject file
subject_test <- data.table(read.table("./data/UCI HAR Dataset/test/subject_test.txt", sep = " "))

# combine subject file data
subject <- rbind(subject_train, subject_test)

# rename the column
setnames(subject, old = c("V1"), new = c("subject_code"))

# combine columns from subject, activities and x readings
wearable_study <- cbind(subject, activity_name = merged_Y$activity_name, total_x)

# for step 5, group by subject and activity
wearable_study_grouped <- group_by(wearable_study, subject_code, activity_name)

# get means for all measures
wearable_study_means <- summarize_all(wearable_study_grouped, funs(mean))

