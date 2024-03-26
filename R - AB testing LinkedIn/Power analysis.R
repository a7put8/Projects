# Load the pwr package
library(pwr)

# Set the effect size, significance level, and power
f2 <- 0.15
alpha <- 0.05
power <- 0.8

# Calculate the required sample size
effect_size <- pwr.f2.test(u = 10, v = NULL, f2 = f2, sig.level = alpha, power = power)

# Print the result
cat("The required sample size is", ceiling(effect_size$u + effect_size$v + 1), "\n")
