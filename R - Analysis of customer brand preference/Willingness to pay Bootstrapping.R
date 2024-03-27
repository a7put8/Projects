library(readxl)
library(ggplot2)
library(tidyverse)

pref_ranks <- read_excel("Preference Ranks.xlsx")

ranks <- pref_ranks$Rank_Adi

design_matrix <- read_excel("Design Matrix.xlsx")

comp1_price <- 2500
comp2_price <- 2000

size_75 <- design_matrix$`Screen 75 inch`
size_85 <- design_matrix$`Screen 85 inch`
res_4k<- design_matrix$`Resolution 4K = 1`
sony <- design_matrix$`Sony = 1`
price_hi <- design_matrix$`Price (low = 0; hi =1)`

model_i <- lm(ranks ~ size_75 + size_85 + res_4k + sony + price_hi)

y_hat <- predict(model_i)

residuals <- model_i$residuals

n <- length(residuals)


## Function to calculate willingness to pay

willingness_to_pay <- function(model) {
  
  part_worth <- data.frame(round(model$coefficients,4))
  
  size_range <- part_worth[3,] - part_worth[2,]
  res_range <- part_worth[4,] - 0
  brand_range <- part_worth[5,] - 0
  price_range <-  0 - part_worth[6,]
  
  price_part_worth <- abs(part_worth[6,])
  
  savings <- max(comp1_price, comp2_price) - min(comp1_price, comp2_price)
  
  util_price <- savings/price_part_worth
  
  wtp <- cbind(round(util_price * part_worth[2,],3), round(util_price * part_worth[3,],3), round(util_price * part_worth[4,],3), round(util_price * part_worth[5,],3))
  
  return(wtp)
}

runs <- 1000

wtp_star_resid <- matrix(0, runs, 4)

##################################################################### Run Residual Boot Strap Regression

for (i in 1:runs) {
  
  y_star <- y_hat + residuals[sample(n ,n , replace = TRUE)]
  model_star <- lm(y_star ~ size_75 + size_85 + res_4k + sony + price_hi)
  wtp_star_resid[i,] <- willingness_to_pay(model_star)
  
}

colnames(wtp_star_resid) <- c("Screen 75 inch", "Screen 85 inch", "Resolution 4K", "Brand")

mean_summaries_resid <- colMeans(wtp_star_resid)

print("Mean values of willingness to pay for non-price attributes using residual bootstrapping: ")
print(mean_summaries_resid)

## 2.5th percentile and 97.5th percentiles of Willingness to pay for each non-price feature

wtp.resid.boot.summary <- matrix(0, nrow = 4, ncol = 2)

for (i in 1:4) {
  
  wtp.resid.boot <- quantile(wtp_star_resid[,i], probs = c(0.025, 0.975))
  wtp.resid.boot.summary[i,] <- wtp.resid.boot
  
}

rownames(wtp.resid.boot.summary) <- c("Screen 75 inch", "Screen 85 inch", "Resolution 4K", "Brand")

colnames(wtp.resid.boot.summary) <- c("2.5%", "97.5%")

print("2.5th and 97.5th percentile values of willingness to pay for non-price attributes using residual bootstrapping:")

print(wtp.resid.boot.summary)


######################################### Data Boot Strap Regression


data <- cbind(design_matrix, ranks)

n_rows <- nrow(data)

wtp_star_data <- matrix(0, runs, 4)

for (i in 1:runs) {
  
  data_star <- data[sample(n_rows, n_rows, replace = TRUE),]
  
  y_star <- data_star$ranks
  
  size_75 <- data_star$`Screen 75 inch`
  size_85 <- data_star$`Screen 85 inch`
  res_4k<- data_star$`Resolution 4K = 1`
  sony <- data_star$`Sony = 1`
  price_hi <- data_star$`Price (low = 0; hi =1)` 
  
  model_star <- lm(y_star ~ size_75 + size_85 + res_4k + sony + price_hi)
  wtp_star_data[i,] <- willingness_to_pay(model_star)
  
}

colnames(wtp_star_data) <- c("Screen 75 inch", "Screen 85 inch", "Resolution 4K", "Brand")

mean_summaries_data <- colMeans(wtp_star_data)

print("Mean values of willingness to pay for non-price attributes using data bootstrapping: ")

print(mean_summaries_data)

## 2.5th percentile and 97.5th percentiles of Willingness to pay for each non-price feature

wtp.data.boot.summary <- matrix(0, nrow = 4, ncol = 2)

for (i in 1:4) {
  
  wtp.data.boot <- quantile(wtp_star_data[,i], probs = c(0.025, 0.975))
  wtp.data.boot.summary[i,] <- wtp.data.boot
  
}

rownames(wtp.data.boot.summary) <- c("Screen 75 inch", "Screen 85 inch", "Resolution 4K", "Brand")

colnames(wtp.data.boot.summary) <- c("2.5%", "97.5%")

print("2.5th and 97.5th percentile values of willingness to pay for non-price attributes using data bootstrapping:")
print(wtp.data.boot.summary)
