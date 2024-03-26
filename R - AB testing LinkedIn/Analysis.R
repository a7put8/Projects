library(tidyverse)
# Load the data
data <- read.csv("LinkedInData.csv")

str(data)

data1 <- data[,c(2:7)]

df <- pivot_longer(data1, cols = c(Control, Treatment_1, Treatment_2, Treatment_3, Treatment_4), names_to = "Variable", values_to = "Value")

df <- df[,c(1,2)]


percentages <- df %>%
  group_by(Variable, Response) %>%
  summarize(Count = n()) %>%
  mutate(Percentage = prop.table(Count) * 100)

# Create a pie chart with percentages and labels
ggplot(percentages, aes(x = "", y = Percentage, fill = as.factor(Response))) +
  geom_bar(width = 1, color = "white", stat = "identity") +
  coord_polar(theta = "y") +
  facet_wrap(~Variable) +  # Separate pie chart for each category
  theme_minimal() +
  ggtitle("Pie Chart of Response Percentages by Category") +
  labs(fill = "Response", y = "Percentage") +
  geom_text(
    aes(label = paste0(round(Percentage, 1), "%")),
    position = position_stack(vjust = 0.5),
    size = 3
  )

## Female Dummies
female_dummy <- ifelse(data$Sex=="F",1,0)

## Company size dummies
large <- ifelse(data$Company_Size=="L",1,0)
medium <- ifelse(data$Company_Size=="M",1,0)


## Number of connections dummies
connections1 <- ifelse(data$Number.of.connections >= 250 & data$Number.of.connections < 500,1,0)
connections2 <- ifelse(data$Number.of.connections >= 500,1,0)


data = data[,c(-1,-8,-9,-11,-13)]


############################################## Initial logistic regression model
model <- glm(Response ~ Treatment_1 + Treatment_2 + Treatment_3 + Treatment_4 + female_dummy + connections1 + connections2 + Years_of_experience + large + medium, data = data, family = binomial)

# Print the model summary
summary(model)


############################################# Covariate imbalance check

model0 <- glm(Control ~ female_dummy +  connections1 + connections2 + Years_of_experience + large + medium, data = data, family = binomial)

# Print the model summary
summary(model0) 
## Large imbalance

model1 <- glm(Treatment_1 ~ female_dummy +  connections1 + connections2 + Years_of_experience + large + medium, data = data, family = binomial)

# Print the model summary
summary(model1)

model2 <- glm(Treatment_2 ~ female_dummy +  connections1 + connections2 + Years_of_experience + large + medium, data = data, family = binomial)

# Print the model summary
summary(model2)
## Medium dummy imbalance

model3 <- glm(Treatment_3 ~ female_dummy  +  connections1 + connections2 + Years_of_experience + large + medium, data = data, family = binomial)

# Print the model summary
summary(model3)
### imbalance on medium and large dummies

model4 <- glm(Treatment_4 ~ female_dummy +  connections1 + connections2 + Years_of_experience + large + medium, data = data, family = binomial)

# Print the model summary
summary(model4)

######################################## Running without medium and large company dummy
model0 <- glm(Control ~ female_dummy +  connections1 + connections2 + Years_of_experience , data = data, family = binomial)

# Print the model summary
summary(model0)

model1 <- glm(Treatment_1 ~ female_dummy +  connections1 + connections2 + Years_of_experience , data = data, family = binomial)

# Print the model summary
summary(model1)

model2 <- glm(Treatment_2 ~ female_dummy +  connections1 + connections2 + Years_of_experience , data = data, family = binomial)

# Print the model summary
summary(model2)

model3 <- glm(Treatment_3 ~ female_dummy  +  connections1 + connections2 + Years_of_experience , data = data, family = binomial)

# Print the model summary
summary(model3)

model4 <- glm(Treatment_4 ~ female_dummy +  connections1 + connections2 + Years_of_experience , data = data, family = binomial)

# Print the model summary
summary(model4)

## Covariate balance achieved

############################################################# Final Model

model <- glm(Response ~ Treatment_1 + Treatment_2 + Treatment_3 + Treatment_4 + female_dummy + connections1 + connections2 + Years_of_experience, data = data, family = binomial)

summary(model)
