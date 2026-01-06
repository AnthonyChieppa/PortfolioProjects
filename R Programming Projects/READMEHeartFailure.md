# Heart Failure Analysis and Prediction Project
R-based coding project 

## Citation
Davide Chicco, Giuseppe Jerman:
Machine learning can predict survival of patients with heart failure from serum creatinine and ejection fraction alone. BMC Medical Informatics and Decision Making 20, 16 (2020). (link)

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


# File Overview

- heart_failure_clinical_records_dataset.csv — Raw dataset
- model_training.R — Loads data, preprocesses features, trains logistic regression model
- predict_heart_failure() — Function to predict survival for new patients
- EDA_visualizations.R — Generates plots for feature distributions and correlations
