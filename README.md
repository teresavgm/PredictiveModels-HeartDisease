# Predictive Models: Heart disease


# Objective

The main objective of this project is to develop a predictive model that estimates the risk of cardiovascular disease in adult patients, based on a set of clinical and demographic variables.


# Machine learning models

To identify the best predictive model, the following machine learning models were implemented using a **2x5 nested cross-validation** procedure, combining different techniques to perform feature selection.

- Support Vector Machines (_SVM_)

- Artificial Neural Networks (_ANN_)

- Decision Trees (_DT_)

Additionally, various techniques were employed to achieve optimal feature selection.

Finally, all implemented models were compiled into a table and compared using different metrics such as AUC and ACC. In conclusion, it was determined that the best model was the one based on artificial neural networks using all the variables.

![](https://github.com/teresavgm/PredictiveModels-HeartDisease/blob/main/TablaComparativa.PNG)


# ApplicationS

Finally, an application was created where input variables can be entered to predict the risk of developing heart disease.

![](https://github.com/teresavgm/PredictiveModels-HeartDisease/blob/main/App/App_captura.PNG)