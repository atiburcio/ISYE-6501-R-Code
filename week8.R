data <- read.table("uscrime.txt", stringsAsFactors = FALSE, header = TRUE)

set.seed(1)
# Fit the model 
lm.model <- lm(Crime ~., data = data)

# Build a model using AIC in a stepwise Algorithm
step(lm.model, 
     direction = "backward",
     trace= FALSE)

# Take a look at the stepwise model--we have selected 8 predictors.  Our R squared is 74.4%
summary(step.model)
step.model
# Take a look at the summary of the full model--15 predictors.  Our R squared is 70.1%
summary(lm.model)

# Reducing the number of features we use significantly increased the R squared value

# Look at the probability of a model with fewer predictors being better.  As you can see, there is significant probability that the model could be better.
exp((503.93-505.16)/2)

# Use forward direction--notice how different our AIC is from backward!
model_forward <- lm(Crime~1, data=data)
step(model_forward,
     scope = formula(lm(Crime~.,data=data)),
     direction="forward")

# Analyze our stepwise chosen model
model_fo<-lm(Crime ~ Po1 + Ineq + Ed + M + Prob + U2, data = data)
summary(model_fo)
plot(model_fo)

# Stepwise both ways--even lower than our foward stepwise analysis
model_both <- lm(Crime~., data=data)
step(model_both,
     scope = list(lower=formula(lm(Crime~1,data = data)),
                  upper=formula(lm(Crime~.,data=data))),
     direction = "both")


library(MASS)
library(glmnet) 

set.seed(1)
# Build our lasso model
lasso <- cv.glmnet(x=as.matrix(data[,-16]),
                   y=as.matrix(data[,16]),
                   alpha=1,
                   nfolds=8,
                   nlambda=20,
                   type.measure = "mse",
                   family="gaussian",
                   standardize=TRUE) # scale our data


lasso
plot(lasso) # visual analysis of min
lasso$lambda.min # lambda min value (8.84)
cbind(lasso$lambda, lasso$cvm, lasso$nzero) #lambda with respect to cvm and non zero variables
coef(lasso, s=lasso$lambda.min) # 










scaledData = as.data.frame(scale(data[,c(1,3,4,5,6,7,8,9,10,11,12,13,14,15)]))
scaledData <- cbind(data[,2],scaledData,data[,16]) # Add column 2 back in
colnames(scaledData)[1] <- "So"
colnames(scaledData)[16] <- "Crime"


x<- seq(0,1,0.1) # define values of alpha that we would like to loop through
R2 <- c()
for (i in 1:11) { #loop through values of x and store output in our lists above
  set.seed(1)
  # Build our lasso model
  elastic <- cv.glmnet(x=as.matrix(scaledData[,-16]),
                     y=as.matrix(scaledData[,16]),
                     alpha=x[i],
                     nfolds=8,
                     nlambda=20,
                     type.measure = "mse",
                     family="gaussian",
                     standardize=TRUE) # scale our data

  R2 <- cbind(R2,elastic$glmnet.fit$dev.ratio[which(elastic$glmnet.fit$lambda == elastic$lambda.min)])
}

R2
#Best value of alpha

alpha_best = (which.max(R2)-1)/10
alpha_best





#Therefore we find that the best value of alpha may not lie somewhere between 0 and 1

#Lets build the model using this alpha value.

Elastic_net=cv.glmnet(x=as.matrix(scaledData[,-16]),
                      y=as.matrix(scaledData[,16]),
                      alpha=alpha_best,
                      nfolds = 5,
                      type.measure="mse",
                      family="gaussian")

#Output the coefficients of the variables selected by Elastic Net

coef(Elastic_net, s=Elastic_net$lambda.min)


mod_Elastic_net = lm(Crime ~So+M+Ed+Po1+Po2+LF+M.F+NW+U1+U2+Ineq+Prob, data = scaledData)
summary(mod_Elastic_net)


# The R-SQuared value is similar using Elastic Net and 13 variables. Therefore this method 
# may not be doing a good job as it selects 3 more variables for a similar RSquared value

# Now let's see how it cross-validates:

SStot <- sum((data$Crime - mean(data$Crime))^2)
totsse <- 0
for(i in 1:nrow(scaledData)) {
  mod_lasso_i = lm(Crime ~ So+M+Ed+Po1+Po2+M.F+Pop+NW+U1+U2+Wealth+Ineq+Prob, data = scaledData[-i,])
  pred_i <- predict(mod_lasso_i,newdata=scaledData[i,])
  totsse <- totsse + ((pred_i - data[i,16])^2)
}
R2_mod <- 1 - totsse/SStot
R2_mod
