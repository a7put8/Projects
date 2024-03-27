library(readxl)
library(glmnet)
#library(tidyverse)

## Read data
data <- read.csv("Cars_Data.csv")  ## Converted excel to csv as xlsx file was nor reading


## Separate x and y variables

y <-  data[,17]
x <- as.matrix(data[,2:16])

brands <- data[,1]

col_names <- c(colnames(x))

## Create correlation matrix of x
cor_mat = cor(x)		

## PCA
decomp <- eigen(cor_mat)

eigen_val <- decomp$values
eigen_vec <- decomp$vectors


## Scree plot
plot(eigen_val, ylab = "Eigenvalues", xlab = "Component Nos", ylim = c(0, 10))
axis(side = 2, at = seq(from = 0, to = 10, by = 1))
abline(h = 1, col = "red")

## It can be observed that the we can retain 4 z variables

ego <- eigen_val[eigen_val > 1]
nn <- nrow(as.matrix(ego)) ## Number of factors to retain

out2 <- eigen_vec[, 1:nn]
out3 <- ifelse(abs(out2) < 0.3, 0, out2) ## Retain vectors with absolute values >=0.3
rownames(out3) <- col_names

## Run regression to check sign of coefficients

x_test <- x %*% out3 ## multiply weights with x

test_model <- lm(y ~ x_test)  ## Run regression

summary(test_model)

## It can be observed that the signs for coefficients of z1 and z2 are -ve and hence,
## we need to flip signs for ease of interpretation

out4 <- cbind(out3[,1] * c(-1), out3[,2]* (-1), out3[,3], out3[,4])	
out4

z <- x %*% out4

out5 <- lm(y ~ z)	

summary(out5)

## at 5% significance, only benefits Z1 and Z3 are statistically significant in determining overall preference

Z1 <- z[,1] ## Z1 describes benefit for a car that is 
## Attractive, Quiet, Well built, gives off vibes of prestige and success. Hence, naming the benefit as Luxury
Z3 <- z[,3] ## Z3 describes benefit for a car that is 
## not very interesting, Economical and has great value. Hence, naming the benefit as Utility

z.out <- cbind(Z1, Z3)

rownames(z.out) = c(brands)

b1 <- as.vector(coef(out5)[2]) ## Coefficient of Luxury
b3 <- as.vector(coef(out5)[4]) ## Coefficient of Utility


plot(Z1, Z3, main = "Brands' Luxury vs Utility", xlab = "Luxury", ylab = "Utility", col = "lightblue", pch = 19, cex = 2)
text(z.out, labels = row.names(z.out), font = 2, cex = 0.5, pos = 1)

slope.iso.preference = - b1/b3					
slope.ideal.vector = b3/b1		

# Angle of iso-preference line	
angle.iso.preference <- atan(slope.iso.preference)*180/pi	
cat("Angle of Iso-preference line in degrees is:", angle.iso.preference)

# Angle of ideal vector	
angle.ideal.vector <- atan(slope.ideal.vector)*180/pi
cat("Angle of ideal vector in degrees is:", angle.ideal.vector)

## Observation from the brand map:
## 1. Infinity's competitor is BMW
## 2. Infinity scores very high on Luxury compared to Utility
## 3. The ideal vector is angled at 33.79 degrees. i.e It is better to increase the luxury as compared to utility
## Or, the benefits of increasing luxury are slightly better the benefits of increasing utility
## 4. Iso-preference line is angled at -56.2 degrees. BMW and infinity could be equally preferred if they were to fall on the iso-preference line

## Recommendations to Infinity's brand managers:
## Focus on selling the car using it's Luxuriousness as it is preferred among the customers, i.e make it the car's selling point



## At 10% Z2 is significant. We do not consider this in our primary analysis and confidence interval estimate for ideal vector line
## The following plots are only for exploration

Z1 <- z[,1] ## Z1 describes benefit for a car that is 
## Attractive, Quiet, Well built, gives off vibes of prestige and success. Hence, naming the benefit as Luxury
Z2 <- z[,2] ## Z2 describes benefit for a car that is 
## unreliable, less sporty, roomy and less easy to service. Hence, naming the benifit as Clunkiness

z.out1 <- cbind(Z1, Z2)
rownames(z.out1) = c(brands)

b1 <- as.vector(coef(out5)[2]) ## Coefficient of Luxury
b2 <- as.vector(coef(out5)[3]) ## Coefficient of Clunkiness

plot(Z1, Z2, main = "Brands' Luxury and Clunkiness", xlab = "Luxury", ylab = "Clunkiness", col = "lightblue", pch = 19, cex = 2)

text(z.out1, labels = row.names(z.out1), font = 2, cex = 0.5, pos = 1)

slope.iso.preference1 = - b1/b2					
slope.ideal.vector1 = b2/b1		

# Angles of iso-preference and ideal vector	
angle.iso.preference1 <- atan(slope.iso.preference1)*180/pi	
angle.ideal.vector1 <- atan(slope.ideal.vector1)*180/pi

cat("Angle of Iso-preference line in degrees is:", angle.iso.preference1)

cat("Angle of ideal vector in degrees is:", angle.ideal.vector1)

## Observations:
## 1. Again, when considering clunkiness and luxury, BMW is the competitor
## 2. Angle of the iso-preference line suggests Luxury is preferred over clunkiness
## 3. Infinity's managers need to focus on improving the luxurious qualities like build and attractiveness

## Exploring Utility and clunkiness

z.out2 <- cbind(Z3, Z2)
rownames(z.out2) = c(brands)
plot(Z3, Z2, main = "Brands' Utility and Clunkiness", xlab = "Utility", ylab = "Clunkiness", col = "lightblue", pch = 19, cex = 2)

text(z.out2, labels = row.names(z.out2), font = 2, cex = 0.5, pos = 1)

slope.iso.preference2 = - b3/b2					
slope.ideal.vector2 = b2/b3		

# Angles of iso-preference and ideal vector	
angle.iso.preference2 <- atan(slope.iso.preference2)*180/pi	
angle.ideal.vector2 <- atan(slope.ideal.vector2)*180/pi

cat("Angle of Iso-preference line in degrees is:", angle.iso.preference2)

cat("Angle of ideal vector in degrees is:", angle.ideal.vector2)

## Observations:
## 1. Immediate competitor in this case is Mercury
## 2. Better to focus on increasing utility than clunkiness

## Overall recommendation to Infinity's managers
## Main benefit to focus on is Luxury followed by Utility and then clunkiness.
## Advertise the brand based on luxury, as it can be observed that consumers have a greater preference for it.

########################## Residual Bootstrapping for Ideal vector angle ############################

summary(out5)

y.hat <- predict(out5)
rr <- out5$residuals
nn <- nrow(data)

bb <- 1000

ideal.vector.angles <- matrix(0, bb, 1)


for (ii in 1:bb){
  
  y.star <- y.hat + rr[sample(nn, nn, replace = TRUE)]
  out.star <- lm(y.star ~ z)
  
  b1 <- as.vector(coef(out.star)[2]) ## Coefficient of z1
  b3 <- as.vector(coef(out.star)[4]) ## Coefficient of z3
  
  slope.iso.preference = - b1/b3		## slope is from the equation z3 = (c/b3 - b1/b3)	- z1 * b1/b3
  slope.ideal.vector = b3/b1		## Ideal vector is orthogonal to the iso-preference line
  
  # Angles of iso-preference and ideal vector	
  angle.iso.preference <- atan(slope.iso.preference)*180/pi	
  angle.ideal.vector <- atan(slope.ideal.vector)*180/pi
  
  ideal.vector.angles[ii] <- angle.ideal.vector
  
}

ideal.vector.angle.CI <- quantile(ideal.vector.angles, probs = c(0.025, 0.975))

cat("Confidence interval for the angle of ideal vector is:")
ideal.vector.angle.CI

ideal.vector.angle.avg <- mean(ideal.vector.angles)
cat("Average value of the ideal vector is:", ideal.vector.angle.avg)
