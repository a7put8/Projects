library(readxl)
library(ggplot2)


## Conjoint Analysis function

conjoint_analysis <- function(ranks, my_design = c(1,0,1,0,0), comp1_price = 2500, comp2_price = 2000, market_size = 100, comp1_design = c(1,1,0,1,1), comp2_design = c(1,0,1,1,0)) {
  
  ############################################ Read Design matrix
  
  design_matrix <- read_excel("Design Matrix.xlsx")
  

  size_75 <- design_matrix$`Screen 75 inch`
  size_85 <- design_matrix$`Screen 85 inch`
  res_4k<- design_matrix$`Resolution 4K = 1`
  sony <- design_matrix$`Sony = 1`
  price_hi <- design_matrix$`Price (low = 0; hi =1)`
  
  ############################################## Model
  
  model <- lm(ranks ~ size_75 + size_85 + res_4k + sony + price_hi)
  
  
  ################################################# Part Worth
  
  part_worth <- data.frame(round(model$coefficients,4))
  
  
  ############################################ Cost of attributes
  
  fixed_cost <- 1000
  screen_75 <- 500
  screen_85 <- 1000
  Res <- 250
  brand_Sony <- 250
  
  cost_vector <- c(fixed_cost, screen_75, screen_85, Res, brand_Sony)
  
  
  ################################################################ Relative importance
  
  size_range <- part_worth[3,] - part_worth[2,]
  res_range <- part_worth[4,] - 0
  brand_range <- part_worth[5,] - 0
  price_range <-  0 - part_worth[6,]
  
  price_part_worth <- abs(part_worth[6,])
  
  net <- size_range + res_range + brand_range + price_range
  
  size_imp <- size_range * 100/net
  res_imp <- res_range * 100/net
  brand_imp <- brand_range * 100/net
  price_imp <- price_range * 100/net
  
  attribute_importance <- data.frame(c("Size", "Resolution", "Brand", "Price"), round(c(size_imp,res_imp, brand_imp, price_imp),2))
  
  colnames(attribute_importance) <- c("Attributes", "Importance %")
  
  ######################################################################## Willingness to Pay for each non-price attribute
  
  savings <- max(comp1_price, comp2_price) - min(comp1_price, comp2_price)
  
  util_price <- savings/price_part_worth
  
  wtp.size75 <- util_price * part_worth[2,]
  wtp.size85 <- util_price * part_worth[3,]
  wtp.res <- util_price * part_worth[4,]
  wtp.brand <- util_price * part_worth[5,]
  
  wtp <- data.frame( c("Size_75", "Size_85", "Resolution", "Brand_Name"), c(wtp.size75,wtp.size85, wtp.res, wtp.brand))
  
  colnames(wtp) <- c("Attribute", "Willingness to pay $")
  
  
  
  
  ########################################################################## Market Share
  
  prices <- c(seq(1500, 2600, 100))
  
  profits <- c()
  
  market_shares <- c()
  
  sales_values <- c()
  
  margins <- c()
  
  comp_price_diff <- max(c(comp1_price, comp2_price)) - min(c(comp1_price, comp2_price))

  
  my_cost <- sum(my_design * cost_vector)
  
 
  
  for (my_price in prices) {
    
    ###################################################################################### Utilities
    
      my_util <- sum(my_design * part_worth[1:5,]) + part_worth[6,] * (my_price - min(c(comp1_price, comp2_price)))/ comp_price_diff
      
        
      sony_util <- sum(comp1_design * part_worth[1:5,]) + part_worth[6,] * (comp1_price - min(c(comp1_price, comp2_price)))/ comp_price_diff
      
      
      sharp_util <- sum(comp2_design * part_worth[1:5,]) + part_worth[6,] * (comp2_price - min(c(comp1_price, comp2_price)))/ comp_price_diff
      
      
      ################################################################################### Attractiveness
      
      my_attractiveness <- exp(my_util)
      
      sony_attractiveness <- exp(sony_util)
      
      sharp_attractiveness <- exp(sharp_util)
    
      
      net_attractiveness <- my_attractiveness + sony_attractiveness + sharp_attractiveness
      
      ######################################################################################## Market Shares
      
      my_market_share <- round(my_attractiveness / net_attractiveness,4)
      
      
      sony_market_share <- round(sony_attractiveness / net_attractiveness, 4)
      
      
      sharp_market_share <- round(sharp_attractiveness / net_attractiveness, 4)
      
      
      market_shares <- c(market_shares, my_market_share)
      
      ################################################# Sales
      
      sales <- my_market_share * market_size
      
      sales_values <- c(sales_values, sales)
      
      ################################################ Margin
      
      margin <- my_price - my_cost
      
      margins <- c(margins, margin)
      
      ######################################### Profit
      
      profit <- margin * sales
      
      profits <- c(profits, profit)
    
  }
  
  agg_df <- data.frame(prices, market_shares, sales_values, margins, profits)
  colnames(agg_df) <- c("Prices", "Market_Share", "Sales", "Margins", "Profits")
  
  ############################################################### Print Part Worth
  
  print("Part Worth:")
  
  print("******************")
  
  print(part_worth)
  
  print("*********************************************************")
  
  ############################################################ Print my cost for chosen design
  
  cat("My cost is: $", my_cost, "\n")
  
  print("*********************************************************")
  
  ################################################################### Print Attribute importance for customer
  
  print("Attribute importance:")
  
  print("******************")
  
  print(attribute_importance)

  print("*********************************************************")

  ################################################################## Print Willingness to pay
  
  print("Willingness to pay:")
  
  print("******************")
  
  print(wtp)
  
  print("*********************************************************")
  ##################################################################### Optimal price
  
  cat("Optimal Price: $", prices[which.max(profits)],"\n")
  
  print("*********************************************************")
  
  
  ##################################################################### Max profit
  
  cat("Maximum profit: $", max(profits), "\n")
  
  print("*********************************************************")
  
  ################################################################## Market share associated with optimal price
  
  cat("Market share associated with optimal price: ", market_shares[which.max(profits)], "\n")
  
  print("*********************************************************")
  
  ######################################################################### Profits as a function of price
  
  p1 <- ggplot(data = agg_df, mapping = aes(x = Prices, y = Profits)) + geom_line() + geom_point() + ggtitle("Profits vs Prices") + scale_x_continuous(breaks = seq(1500, 2600, by = 100))
  #ggplot(profit_df) + geom_point(aes(x = prices, y = profits))
  
  ######################################################################### Market Share as a function of price
  p2 <- ggplot(data = agg_df, mapping = aes(x = Prices, y = Market_Share)) + geom_line() + geom_point() + ggtitle("Market Share vs Price") + scale_x_continuous(breaks = seq(1500, 2600, by = 100))
  
  ######################################################################### Profit as a function of Price
  
  p3 <- ggplot(data = agg_df, mapping = aes(x = Prices, y = Sales)) + geom_line() + geom_point() + ggtitle("Sales vs Price") + scale_x_continuous(breaks = seq(1500, 2600, by = 100))
  
  show(p1)
  
  show(p2)
  
  show(p3)
  
  print(agg_df)

}


### Read Data ###
ranks <- read_excel("Preference Ranks.xlsx")  ### Input your customer rankings data


### Member 1 ###
ranks_0 <- ranks$Rank_Adi  ### Get ranks for the specific customer
conjoint_analysis(ranks_0, market_size = 100, my_design = c(1,0,1,0,0))  ## Run function to get the following outputs

## 1. Part Worth of each attribute
## 2. Attribute Importance of each attribute
## 3. Willingness to pay for each non-price attribute level
## 4. Optimal price
## 5. Maximum profit
## 6. Market share associated with optimal price
## 7. Plot of market shares as a function of prices
## 8. Plot of profit as a function of prices



### Member 2 ###
ranks_1 <- ranks$Rank_Vivi ### Get ranks for the specific customer
conjoint_analysis(ranks_1, market_size = 100, my_design = c(1,0,1,0,0))  ## Run function to get the outputs


### Member 3 ###
ranks_2 <- ranks$Rank_Leo ### Get ranks for the specific customer
conjoint_analysis(ranks_2, market_size = 100, my_design = c(1,0,1,0,0))  ## Run function to get the outputs


### Member 4 ###
ranks_3 <- ranks$Rank_Meitong  ### Get ranks for the specific customer
conjoint_analysis(ranks_3, market_size = 100, my_design = c(1,0,1,0,0))  ## Run function to get the outputs


### Member 5 ###
ranks_4 <- ranks$Rank_Abby  ### Get ranks for the specific customer
conjoint_analysis(ranks_4, market_size = 100, my_design = c(1,0,1,0,0))  ## Run function to get the outputs
