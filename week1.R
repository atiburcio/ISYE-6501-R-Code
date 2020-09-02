


# Question 2.2

# Problem 1
############################################################################################################################################################################

## Solution 1 (training and testing on same data)
###################################################
install.packages("kernlab")
library(kernlab)
library(ggplot2)

data <- read.table("credit_card_data.txt")

x<- seq(1,1000,2)

c_samples <-sapply(x, function(x){
  model <- ksvm(as.matrix(data[,1:10]),
                as.factor(data[,11]),
                type="C-svc",
                kernel= "rbfdot",
                C=x,
                scaled=TRUE)
  
  # a <- colSums(model@xmatrix[[1]] * model@coef[[1]])
  # a0 <- model@b
  credit.approval <- predict(model,data[,1:10])
  sum(credit.approval == data[,11]) / nrow(data)  
  
})

combined <- do.call(rbind, Map(data.frame, A=x, B=c_samples))
combined

ggplot(data=combined,aes(A,B))+geom_point()


combined[which.max(combined$B),]

## Solution 2 (splitting in to 70/30 train/test)
###################################################

install.packages("kernlab")
library(kernlab)
library(ggplot2)

# import data
data <- read.table("credit_card_data.txt")

# what is the size of the data? number of rows
m <- dim(data)[1]

#Grab 30% of the data for training (Validation)
val <- sample(1:m, size = round(m/3), replace = FALSE, 
              prob = rep(1/m, m)) 

#assigned training set
trainData.learn <- data[-val,]

#testing data set
testData.valid <- data[val,]

x<- seq(1,1000,2)

c_samples <-sapply(x, function(x){
  model <- ksvm(as.matrix(trainData.learn[,1:10]),
                as.factor(trainData.learn[,11]),
                type="C-svc",
                kernel= "rbfdot",
                C=x,
                scaled=TRUE)
  
  # a <- colSums(model@xmatrix[[1]] * model@coef[[1]])
  # a0 <- model@b
  credit.approval <- predict(model,testData.valid[,1:10])
  sum(credit.approval == testData.valid[,11]) / nrow(testData.valid)  
  
})

combined <- do.call(rbind, Map(data.frame, A=x, B=c_samples))
combined

ggplot(data=combined,aes(A,B))+geom_point()


combined[which.max(combined$B),]





# Problem 2
#######################################################################################################################################################################








# Problem 3
########################################################################################################################################################################
install.packages("kknn")
library(kknn)
library(ggplot2)
data <- read.table("credit_card_data.txt")

head(data)


check_accuracy = function(X){
# predictions <- vector(mode = "list")
predicted <- rep(0,(nrow(data))) # predictions: start with a vector of all zeros

for (i in 1:nrow(data)) {
  kknn.model <- kknn(V11~., 
                     data[-i,1:11], 
                     data[i,1:11], 
                     k = X,
                     scale = TRUE)
  preds <- fitted(kknn.model)
  # predicted[i] <- as.integer(fitted(model)+0.5) # round off to 0 or 1
  # predictions <- append(predictions, preds)
  predicted[i] <- as.integer(fitted(kknn.model)+0.5) # round off to 0 or 1
}

accuracy = sum(predicted == data[,11]) / nrow(data)
return(accuracy)
}

acc <- rep(0,25) # set up a vector of 20 zeros to start
for (X in 1:20){
  acc[X] = check_accuracy(X) # test knn with X neighbors
}

x <-  seq(1,25)


combined <- do.call(rbind, Map(data.frame, A=x, B=acc))
combined

ggplot(data=combined,aes(A,B))+geom_point()



