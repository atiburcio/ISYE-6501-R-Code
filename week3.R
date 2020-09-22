################################################################################
## Problem 5.1
install.packages("outliers")
library(outliers)


## Import the data
data_crime <- read.table("uscrime.txt")

## Take a look at the data
head(data_crime)

## Store the last column of data as a numeric value
x <- as.numeric(data_crime[2:48,16])


#create a histogram
hist(x, breaks = 12, freq = F, xlab = 'Crimes/100,000 People', ylab = 'Frequency', main = 'Histogram of Crime')

#create a box and whisker plot
boxplot(x, ylab = 'Crimes/100,000 People', main = '47 Records')


#create a normal probability plot
qqout = qqnorm(x, ylab = 'Crimes/100,000 People', main = '47 Records')
qqline(x)      #add a straight line to the normal probability plot


## Execute grubbs.test to identify the outlier
grubbs.test(x)
