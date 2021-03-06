
################################################################################
## Problem 3.1 (a)
install.packages("kknn")
install.packages("caret")
library(caret)
library(kknn)
library(ggplot2)

## Import the data
data_cv <- read.table("credit_card_data.txt")

head(data_cv)

set.seed(1)
## Take a random sample of 80% of the data aside for training
mask_test <- sample(nrow(data_cv), size = floor(nrow(data_cv) * 0.2))
test_cv <- data_cv[mask_test,]
train_cv <- data_cv[-mask_test,]

set.seed(1)
## Shuffle training data randomly
data_shuffled <- train_cv[sample(nrow(train_cv)),]

set.seed(1) 
# Create 10 equally size folds
folds <- cut(seq(1,nrow(data_shuffled)),breaks=10,labels=FALSE)

## Create a function for looping through the 10 kfolds and returning the 
## average accuracy of all 10 models across different values of k (nearest neighbor)
check_accuracy = function(X){
  
  ## Set value of kfolds
  k <- 10
  
  ## Empty list to store accuracy outputs from various k values  
  accuracy_list <- vector(mode = "list") 
  
  #Perform 10 fold cross validation
  for(i in 1:k){
    #Segement your data by fold using the which() function 
    testIndexes <- which(folds==i,arr.ind=TRUE)
    validationData <- data_shuffled[testIndexes, ]
    trainData <- data_shuffled[-testIndexes, ]
    
    kknn.model <- kknn(V11~., 
                       trainData[,1:11], 
                       validationData[,1:11], 
                       k = X,
                       scale = TRUE)
    set.seed(1)
    ## Predict on the validationData 
    preds <- as.integer(fitted(kknn.model)+0.5)
    ## Calculate the accuracy
    accuracy <- sum(preds == validationData[,11]) / nrow(validationData)
    #Store the values from each iteration of i in this list
    accuracy_list <- c(accuracy_list, accuracy)
    
  }
  ## Calculate the average of the 10 folds for each value of k
  final_C_outputs <- mean(as.numeric(accuracy_list))
  ## Return the output for each value of X (k = X) passed to the function
  return(final_C_outputs)
}

## Create an empty list to store the outputs from the check_accuracy function
acc <- vector(mode = "list") 

## For X values between 1 and 100..pass them to the function.
for (X in 1:100){
  acc[X] = check_accuracy(X) # test knn with X neighbors
}

##  Take a look at the results of function 
## (looping through 10 kfolds for each value of X 1-100)
acc

## Store the output of accuracy as a data.frame
as.data.frame(acc)

X<-seq(1,100)

## Combine the sequence of x and the accuracy values for ggplot next
combined <- do.call(rbind, Map(data.frame, A=X, B=acc))

## take a look at combined
combined

## Plot x against the accuracy values (k=1 gives us the highest percentage accuracy)
g <- ggplot(data=combined,aes(A,B))+geom_point()
g + ggtitle("Accuracy by K value") +
  xlab("k value") + ylab("Accuracy")




set.seed(1)
## using k=1 train the model on training+validation data and predict on unseen test data 
kknn.model_optimized <- kknn(V11~., 
                             train_cv[,1:11], ## this is the full training dataset
                             test_cv[,1:11], ## data the model has never seen before
                             k = 17,
                             scale = TRUE)
set.seed(1)
## Predict on the test_cv data that the model has never seen before
preds_optimized <- as.integer(fitted(kknn.model_optimized)+0.5)

## Final accuracy of 83.07%% (as expected, smaller than what we saw in the testing scenarios 
## above where we see 86.8% accuracy for our cv/k scenarios).  
sum(preds_optimized == test_cv[,11]) / nrow(test_cv)


###################################################################################################
## Problem 3.1 (b) USING SVM

install.packages("kernlab")
library(kernlab)
library(ggplot2)
data <- read.table("credit_card_data.txt")

## Look at a sample of the data
head(data)

set.seed(1)
## Take a random sample of 60% of the data aside for training
mask_train <- sample(nrow(data), size = floor(nrow(data) * 0.6))

## Store this data in the 'train' dataframe
train <- data[mask_train,]

## Store the remaining 40% as 'leftover'
leftover <- data[-mask_train,]

## Divide the leftover by 2 and place one in validation and one in test
validation <- leftover[1:(nrow(leftover)/2),]
test <- leftover[((nrow(leftover)/2)+1):nrow(leftover),]

## make the results reproducible
set.seed(1)

## Create a sequence of values in magnitudes of 10 from 1e-08 to 1e+08 (17 values to test)
x <- 10^seq(-8, 8, 1)


## Look at how different values of 'x' passed to the 'C' argument in the ksvm model produce 
## different accuracy percentages on the validation data
accuracy <-sapply(x, function(x){
  set.seed(1)
  model_scaled <- ksvm(V11~.,
                       data=train, ## Use the 60% training data
                       type = "C-svc", # Use C-classification method
                       kernel = "rbfdot",
                       C = x,
                       scaled=TRUE) # have ksvm scale the data for you
  
  set.seed(1)
  ##  Predict on the validation data (20% of our 654 rows)
  pred_scaled <- predict(model_scaled,validation[,1:10])
  
  ## Calculate the accuracy
  sum(pred_scaled == validation$V11) / nrow(validation)
})


## Combine the sequence of x and the accuracy values for ggplot next
combined <- do.call(rbind, Map(data.frame, A=x, B=accuracy))

## take a look at combined
combined

## Plot x against the accuracy values (k=1 gives us the highest percentage accuracy)
g <- ggplot(data=combined,aes(A,B))+geom_point()
g + ggtitle("Accuracy by C value") +
  xlab("C value") + ylab("Accuracy")



## It appears that a C value of 0.1 and 1 produce the highest accuracy of 82.44% when 
## looking at the validation data

set.seed(1)
## Now train the model using the determined value of C = (0.1)
model_highest_C <- ksvm(V11~.,data=train,
                        type = "C-svc", # Use C-classification method
                        kernel = "rbfdot", 
                        C = 1,
                        scaled=TRUE) # have ksvm scale the data for you

## Predict on an entirely unfamiliar dataset--'test'  the other 20% of our 
## 654 rows of data
set.seed(1)
pred_highest_C <- predict(model_highest_C,test[,1:10])

## What was the final accuracy of our model? In this case 90.8% 
sum(pred_highest_C == test$V11) / nrow(test)

##################################################################################

## Problem 4.1 

# In marketing analytics, part of my job as an analyst is to improve user engagement with advertisements.  
# Using a clustering analysis to group users in to audience segments is a very hot "buzzword."  
# Business leaders are always trying to break our audience in to meaningful segments.  
# Using a clustering analysis could do this!  
# Several predictors that might help could be: time spent,  device type, geo location, time of day, refer type (social, SEO, etc.).  
# After grouping users in to various clusters we might be able to better recommend site content and advertisements.   


####################################################################################

##  Problem 4.2

install.packages("factoextra")
library(factoextra)
library(tidyverse)
library(dplyr)

data("iris")      # Loading the data set

# scale the data (choosing pedal width and length--as these columns provide the most signal)
# Please see the attached excel spreadsheet for justification for this
df <- scale(iris[,1:4]) 

df <- as_tibble(df)

df <- df %>% select(3,4)

# View the firt 3 rows of the data
head(df, n = 3)

# Calculate the Euclidean distance between rows of a data matrix
distance <- get_dist(df)

# Plot the distance matrix to visualize (dis)similarity of the rows of the iris data 
fviz_dist(distance, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07")) + theme(axis.text.x = element_text(angle = 90, hjust = 1))


# Use kmeans on our dataframe, define number of clusters
set.seed(1)
k2 <- kmeans(df, centers = 2, nstart = 25)
k3 <- kmeans(df, centers = 3, nstart = 25)
k4 <- kmeans(df, centers = 4, nstart = 25)
k5 <- kmeans(df, centers = 5, nstart = 25)

# plots to compare
p1 <- fviz_cluster(k2, geom = "point", data = df) + ggtitle("k = 2")
p2 <- fviz_cluster(k3, geom = "point",  data = df) + ggtitle("k = 3")
p3 <- fviz_cluster(k4, geom = "point",  data = df) + ggtitle("k = 4")
p4 <- fviz_cluster(k5, geom = "point",  data = df) + ggtitle("k = 5")

library(gridExtra)
grid.arrange(p1, p2, p3, p4, nrow = 2)


set.seed(123)

# function to compute total within-cluster sum of square 
wss <- function(k) {
  kmeans(df, k, nstart = 10 )$tot.withinss
}

# Compute and plot wss for k = 1 to k = 15
k.values <- 1:15

# extract wss for 2-15 clusters
wss_values <- map_dbl(k.values, wss)

plot(k.values, wss_values,
     type="b", pch = 19, frame = FALSE, 
     xlab="Number of clusters K",
     ylab="Total within-clusters sum of squares")


set.seed(123)

fviz_nbclust(df, kmeans, method = "wss")

## Create a dataframe of our k3 model that uses 3 clusters since
#  this model creates the best clustering as determined by looking at the 
#  elbow method graph.  We see that 3 clusters is the best choice.
prediction_clusters <- as.data.frame(k3[["cluster"]])

## Rename the column as Cluster.prediction
colnames(prediction_clusters)[1] <- "Cluster.prediction"

## Case when value = x then create a column with the corresponding species
#  I'm choosing the case logic below based on the fact that the model is doing
#  "mostly" a fantastic job of clustering the first 50 rows.  These rows are 
#  'setosa' species. Then we have 'veriscolor' and 'verginica.' Cluster 1 and 2
#  are more difficult to predict because the predictors are so close together.

prediction_clusters <- prediction_clusters %>% 
  mutate(species = case_when(
    .$Cluster.prediction == 2  ~ "setosa",
    .$Cluster.prediction == 1  ~ "versicolor",
    .$Cluster.prediction == 3  ~ "virginica",
    TRUE ~ "other"
  )
  )

##  Take a look at the data
prediction_clusters

##  how often is the cluster correct in relation to the actual data set? looks
## like 96% of the time
sum(prediction_clusters[,2] == iris[,5]) / nrow(iris)
p2

##  Since there are only 4 columns here I played around with how each column
##  of data varies.  Petal length and width end up providing the most variance
##  across species.  This allows the model to distinguish more clearly and 
##  group the data in to corresponding clusters 1,2,3.  Using just petal data 
##  gives an improvement of over 13% from using all 4 of the columns (pedal and sepal)
