rm(list = ls())
uscrime <- read.table("uscrime.txt", stringsAsFactors = FALSE, header = TRUE)

## Histogram of our response variable
hist(uscrime$Crime)

## Plot response variable
qqnorm(uscrime$Crime)

PCA <- prcomp(uscrime[,1:15], scale = TRUE)
summary(PCA)

## Visually show how PCA eliminated multi collinearity
ggpairs(as.data.frame(PCA$x))


#  matrix of eigenvectors
PCA$rotation

# plot the variances of each of the PCs, we want to identify which variables provide the most variance
screeplot(PCA, type="lines",col="blue")

#  Grab first 4 PCs
PC <- PCA$x[,1:4]
PC

# Build linear regression model with first 4 PCs
uscrimePC <- cbind(PC, uscrime[,16])
head(uscrimePC)

# Build the model with crime as the response and every other column as the features
modelPCA <- lm(V5~., data = as.data.frame(uscrimePC))

# Observe summary output.  We can see our betas as well as our R^2.  
summary(modelPCA)

# Store our model's coefficients
beta0 <- modelPCA$coefficients[1]
betas <- modelPCA$coefficients[2:5]


x <- 1:4
(z <- x %*% x)    # scalar ("inner") product (1 x 1 matrix)
drop(z)             # as scalar
x
y <- diag(x)
z <- matrix(1:12, ncol = 3, nrow = 4)
y %*% z
y %*% x
x %*% z



PCA$rotation[,1:4]
alphas <- PCA$rotation[,1:4] %*% betas
t(alphas)
pca$rotation[1,1]*betas[1]


#define our coefficients as variables PC1,intercept
intercept <- as.vector(905.08511)
PC1 <- as.vector(65.21593)


#multiply each coefficient by each of the corresponding columns of data (columns 1,2,3,4)
PC1alpha <- PC1*PCArotationmatrix[,1]


# means
means <- as.matrix(PCA$center)

# standard deviations
sdev <- as.matrix(PCA$scale)


# unscale Principle components
unscaledPC1 <- PC1alpha/sdev

# unscaled intercept
unscaledintercept <- intercept - (unscaledPC1*means)/sdev

#bring in the new datapoint to predict on
newdata <- data.frame(M = 14.0,
                      So = 0,
                      Ed = 10.0,
                      Po1 = 12.0,
                      Po2 = 15.5,
                      LF = 0.640,
                      M.F = 94.0,
                      Pop = 150,
                      NW = 1.1,
                      U1 = 0.120,
                      U2 = 3.6,
                      Wealth = 3200,
                      Ineq = 20.1,
                      Prob = 0.04,
                      Time = 39.0
)

#my attempt at predicting on the new data point.  The value is wildly above our max of 1993. Its 10pm on Wednesday and after looking at this problem for the last 7 hours this isthe best I can do. Very dissappointing way to end my day.  This has been the most difficult homework for me for some reason.  
y <- (-15.76021129)*(14.0)+(-45.05187963*0)+(19.79863564*10.0)+(6.77273086*12.0)+(7.25348060*15.5) + (284.31251301*15.5) + (2.57572204*94.0) +(0.19370319*150)+(-1.86197945*1.1)+(146.50653318*0.120)+(1.39940609*3.6)+(0.02566324*3200)+(-5.97949828*20.1)+(	
  -742.55844893*0.04)+(-0.18983181*39.0) - intercept 






