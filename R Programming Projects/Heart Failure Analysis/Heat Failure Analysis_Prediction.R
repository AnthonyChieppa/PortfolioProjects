# Installing Packages
#install.packages(c(dplyr", "caret", "ggplot2", "GGally"))

# Import libraries
library(caret)
library(dplyr)
library(GGally)
library(ggplot2)

# Importing data set
data <- read.csv('E:\\SQL DATA Folder\\heart_failure_clinical_records_dataset.csv')
head(data)

# Getting the dimensions of the data set
dim(data)

# Getting summary statistics for the data set
summary(data)

# Understanding variable types in the data set
str(data)

# Count missing values in each column
colSums(is.na(data))


# Visualizing the distribution of the DEATH_EVENT variable
ggplot(data, aes(x = DEATH_EVENT)) +
  geom_bar(fill = "orange", color = "black", stat = "count") +
  labs(title = "Distribution of the Death Event Variable", x = "Death Event", y = "Frequency")


# Histograms based on variables with booleans that can correlate to heart failure

# Diabetes and no diabetes
ggplot(data, aes(x = age, fill = factor(diabetes))) +
  geom_histogram(binwidth = 4, position = "dodge", color = 'grey') +
  labs(title = "Individuals without Diabetes 
       versus with Diabetes") +
  scale_fill_manual(values = c("0" = "blue", "1" = "red"), 
                    labels = c("Non-diabetic", "diabetic")) +
  facet_wrap(~diabetes, scales = "free_y")

# High Blood Pressure and no High Blood Pressure
ggplot(data, aes(x = age, fill = factor(high_blood_pressure))) +
  geom_histogram(binwidth = 4, position = "dodge", color = 'grey') +
  labs(title = "Individuals without High BP
       versus with High BP") +
  scale_fill_manual(values = c("0" = "blue", "1" = "red"), 
                    labels = c("No High BP", "High BP")) +
  facet_wrap(~high_blood_pressure, scales = "free_y")

# Anaemia and no Anaemia
ggplot(data, aes(x = age, fill = factor(anaemia))) +
  geom_histogram(binwidth = 4, position = "dodge", color = 'grey') +
  labs(title = "Individuals without Anaemia 
       versus with Anaemia") +
  scale_fill_manual(values = c("0" = "blue", "1" = "red"), 
                    labels = c("Not Anaemic", "Anaemic")) +
  facet_wrap(~anaemia, scales = "free_y")

# Smoking and no smoking
ggplot(data, aes(x = age, fill = factor(smoking))) +
  geom_histogram(binwidth = 4, position = "dodge", color = 'grey') +
  labs(title = "Non-Smokers versus Smokers") +
  scale_fill_manual(values = c("0" = "blue", "1" = "red"), 
                    labels = c("Non-Smoker", "Smoker")) +
  facet_wrap(~smoking, scales = "free_y")


# Visualizing the relationship between gender and heart failure
ggplot(data, aes(x = factor(sex), fill = factor(DEATH_EVENT))) + geom_bar() +
  labs(title = "Distribution of Gender by Heart Failure Status",
       x = "Gender (0 = Female, 1 = Male)", y = "Frequency") +
  scale_fill_manual(values = c("0" = "green", "1" = "yellow"), 
                    labels = c("No Heart Failure", "Heart Failure"))

# Correlation matrix
ggcorr(data, label = TRUE, label_size = 2.5, hjust = 1, layout.exp = 2)

# Ejection fraction  versus serum creatinine 
ggplot(data, aes(x = factor(serum_creatinine), fill = factor(DEATH_EVENT), 
                 y = factor(ejection_fraction))) +
  geom_dotplot(binwidth = .3, position = "dodge", color = 'grey') +
  labs(title = "Ejection Fraction  versus Serum Creatinine") +
  scale_fill_manual(values = c("0" = "blue", "1" = "red"), 
                    labels = c("Survived", "Dead"))

# Training the data
# Data Encoding
heart_failure <- data %>%
  mutate(anaemia = as.factor(anaemia),
         creatinine_phosphokinase = as.factor(creatinine_phosphokinase),
         diabetes = as.factor(diabetes),
         ejection_fraction = as.factor(ejection_fraction),
         high_blood_pressure = as.factor(high_blood_pressure),
         platelets = as.factor(platelets),
         serum_creatinine = as.factor(serum_creatinine),
         sex = as.factor(sex),
         smoking = as.factor(smoking),
         time = as.factor(time),
         DEATH_EVENT = as.factor(DEATH_EVENT))

# Checking the structure of the data set
str(heart_failure)

# Feature selection
features <- data[, c('age',	'anaemia',	'creatinine_phosphokinase',	
                   'diabetes',	'ejection_fraction',	'high_blood_pressure',	
                   'platelets',	'serum_creatinine',	'serum_sodium',	
                   'sex', 'smoking', 'time')]
target <- data$DEATH_EVENT

# Data normalization
preprocessParams <- preProcess(features, method = c("center", "scale"))
features_normalized <- predict(preprocessParams, features)

# Splitting the data
split <- createDataPartition(target, p = 0.7, list = FALSE)
X_train <- features_normalized[split, ]
X_test <- features_normalized[-split, ]
Y_train <- target[split]
Y_test <- target[-split]

# Print the shape of the training and test sets
print(paste("X_train shape:", paste(dim(X_train), collapse = "x")))
print(paste("X_test shape:", paste(dim(X_test), collapse = "x")))

# Combine features and target into a single data frame
train_data <- as.data.frame(cbind(target = Y_train, X_train))

# Training the logistic regression model
model <- glm(target ~ ., data = train_data, family = "binomial")

# Making predictions on the test set
predictions <- predict(model, newdata = as.data.frame(X_test), type = "response")

# Converting probabilities to binary predictions based on threshold 0.5
binary_predictions <- ifelse(predictions >= 0.5, 1, 0)

# Combining actual values and predicted values into a data frame
result <- data.frame(actual = Y_test, predicted = binary_predictions)

# Evaluating the model
confusionMatrix(data = as.factor(binary_predictions), 
                reference = as.factor(Y_test), 
                positive = "1")

# Predicting heart failure using the model
predict_heart_failure <- function(df) {
  
  # Ensure the input has the correct column names
  required_cols <- c(
    "age", "anaemia", "creatinine_phosphokinase",
    "diabetes", "ejection_fraction", "high_blood_pressure",
    "platelets", "serum_creatinine", "serum_sodium",
    "sex", "smoking", "time"
  )
  
  # Check for missing columns
  missing <- setdiff(required_cols, names(df))
  if (length(missing) > 0) {
    stop(paste("Missing required columns:", paste(missing, collapse = ", ")))
  }
  
  # Normalize using the same preprocessing as training
  df_norm <- predict(preprocessParams, df)
  
  # Predict probability
  prob <- predict(model, newdata = df_norm, type = "response")
  
  # Convert to class label
  class <- ifelse(prob >= 0.5, 1, 0)
  
  # Return results
  return(list(
    probability = prob,
    prediction = class
  ))
}

new_patient <- data.frame(
  age = 65,
  anaemia = 0,
  creatinine_phosphokinase = 250,
  diabetes = 1,
  ejection_fraction = 35,
  high_blood_pressure = 1,
  platelets = 250000,
  serum_creatinine = 1.2,
  serum_sodium = 137,
  sex = 1,
  smoking = 0,
  time = 120
)

result <- predict_heart_failure(new_patient)
# Output string comment based on result
cat("Predicted Probability of Death Event:", round(result$probability, 4), "\n")
cat("Predicted Class:", ifelse(result$prediction == 1, "High Risk", "Low Risk"))