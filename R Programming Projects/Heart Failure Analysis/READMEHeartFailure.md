# Heart Failure Analysis and Prediction Project
R-based coding project 
# Background
Cardiovascular diseases kill approximately 17 million people globally every year, and they mainly
exhibit as myocardial infarctions and heart failures. Heart failure (HF) occurs when the heart cannot pump enough
blood to meet the needs of the body.

## Citation
Davide Chicco, Giuseppe Jerman:
Machine learning can predict survival of patients with heart failure from serum creatinine and ejection fraction alone. BMC Medical Informatics and Decision Making 20, 16 (2020).

# Project Description 
This project uses logistic regression to predict patient survival based on clinical features from the UCI Heart Failure dataset. It includes exploratory data analysis, feature normalization, model training, evaluation, and a reusable prediction function.

### Attribute Information:
- Age: age of the patient (years)
- Anaemia: decrease of red blood cells or hemoglobin (boolean)
- Creatinine phosphokinase (CPK): level of the CPK enzyme in the blood (mcg/L)
- Diabetes: if the patient has diabetes (boolean)
- Ejection fraction: percentage of blood leaving the heart at each contraction (percentage)
- High blood pressure: if the patient has hypertension (boolean)
- Platelets: platelets in the blood (kiloplatelets/mL)
- Sex: woman or man (binary)
- Serum creatinine: level of serum creatinine in the blood (mg/dL)
- Serum sodium: level of serum sodium in the blood (mEq/L)
- Smoking: if the patient smokes or not (boolean)
- Time: follow-up period (days)
- DEATH_EVENT: if the patient died during the follow-up period (boolean)

# File Overview in Project

- heart_failure_clinical_records_dataset.csv — Raw dataset
  
- model_training.R — Loads data, preprocesses features, trains logistic regression model
  
- predict_heart_failure() — Function to predict survival for new patients
  
- EDA_visualizations.R — Generates plots for feature distributions and correlations

# Instructions 
Download `Heat Failure Analysis_Prediction.R` file in the folder, csv file labeled `heart_failure_clinical_records_dataset.csv`, open R-Studio, install all required libraries, and then run the following:

### Libraries Used in Project

- caret: This package provides a comprehensive framework for building and evaluating machine learning models. It includes tools for data splitting, pre-processing, feature selection, and model tuning, making it essential for predictive modeling tasks.

- dplyr: A widely-used package for data manipulation, dplyr offers a consistent set of verbs (such as filter, select, mutate, summarize) that simplify the process of transforming and summarizing data frames.

- GGally: An extension of ggplot2, GGally adds functions to simplify the creation of complex plots like pair plots and correlation matrices, which are useful for exploratory data analysis.

- ggplot2: A powerful and flexible visualization package based on the Grammar of Graphics. It allows for the creation of elegant and complex plots with minimal code, supporting a wide range of chart types and customization options.


# Visualizations

1. Distribution of DEATH_EVENT 
<img width="513" height="362" alt="image" src="https://github.com/user-attachments/assets/e9197994-0272-4c8d-a40e-3d02c781e536" />

2. Age vs Diabetes, Anaemia, Smoking, and High Blood Pressure Relationships
<img width="513" height="362" alt="image" src="https://github.com/user-attachments/assets/ea6e332c-51a6-485c-be75-45af05bdd33a" />
<img width="513" height="362" alt="image" src="https://github.com/user-attachments/assets/255ee0f2-6bd6-4b60-b46e-1c0e46738d17" />
<img width="513" height="362" alt="image" src="https://github.com/user-attachments/assets/1a53d0af-ee47-4fec-a810-a7c8fdf8b074" />
<img width="513" height="362" alt="image" src="https://github.com/user-attachments/assets/4a87ede5-9671-418b-8c98-0e2bc5329364" />


3. Gender vs Survival
<img width="513" height="362" alt="image" src="https://github.com/user-attachments/assets/3fb191ad-efcd-48b3-b75b-845a83a940f2" />

4. Correlation matrix
<img width="513" height="362" alt="image" src="https://github.com/user-attachments/assets/0b160af0-7832-4e5d-ba2a-a131d7636664" />

5. Serum Creatinine vs Ejection Fraction
<img width="513" height="362" alt="image" src="https://github.com/user-attachments/assets/939e88a3-65b9-47da-a24d-b61ed19353c5" />


## R script with output 
```{r example, echo=TRUE}
confusionMatrix(data = as.factor(binary_predictions), 
                reference = as.factor(Y_test), 
                positive = "1")
```
<img width="352" height="419" alt="image" src="https://github.com/user-attachments/assets/fa7f7760-8e3f-40f9-84c9-3bbc7ede3a9f" />

# Heart Failure Prediction using the model

```{r example, echo=TRUE}
result <- predict_heart_failure(new_patient)
# Output string comment based on result
cat("Predicted Probability of Death Event:", round(result$probability, 4), "\n")
cat("Predicted Class:", ifelse(result$prediction == 1, "High Risk", "Low Risk"))
```
<img width="685" height="96" alt="image" src="https://github.com/user-attachments/assets/5cb581a2-76bd-42a0-93dc-16868dce1d44" />


