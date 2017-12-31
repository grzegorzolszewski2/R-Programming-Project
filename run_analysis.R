library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="auto")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}


# Load activity and features labels
activityLab <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLab[,2] <- as.character(activityLab[,2])
featuresName <- read.table("UCI HAR Dataset/features.txt")
featuresName[,2] <- as.character(featuresName[,2])


# Extract columns with mean or standard deviation
featuresExtracted <- grep(".*mean.*|.*std.*", featuresName[,2])
featuresExtracted.names <- featuresName[featuresExtracted,2]
featuresExtracted.names = gsub('-mean', 'Mean', featuresExtracted.names)
featuresExtracted.names = gsub('-std', 'Std', featuresExtracted.names)
featuresExtracted.names <- gsub('[()-]', '', featuresExtracted.names)


# Load the dataset
## Load the train data
trainset <- read.table('UCI HAR Dataset/train/X_train.txt')[featuresExtracted]
trainActivities <- read.table('UCI HAR Dataset/train/Y_train.txt')
trainSubjects <- read.table('UCI HAR Dataset/train/subject_train.txt')
trainset <- cbind(trainSubjects, trainActivities, trainset)

## Load the test data
testset <- read.table('UCI HAR Dataset/test/X_test.txt')[featuresExtracted]
testActivities <- read.table('UCI HAR Dataset/test/Y_test.txt')
testSubjects <- read.table('UCI HAR Dataset/test/subject_test.txt')
testset <- cbind(testSubjects, testActivities, testset)


## Merge datasets and add labels
MergedData <- rbind(trainset, testset)
colnames(MergedData) <- c('subject','activity', featuresExtracted.names)


## Change activities and subjects to factors
MergedData$activity <- factor(MergedData$activity, levels = activityLab[,1], labels = activityLab[,2])
MergedData$subject <- as.factor(MergedData$subject)

## Melt data and summerise by every measure
allData.melted <- melt(MergedData, id = c('subject','activity'))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)


write.table(allData.mean, 'tidy_data.txt', row.names = FALSE, quote = FALSE)
