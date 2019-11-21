
# coding: utf-8

# In[1]:


import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
from sklearn.naive_bayes import GaussianNB
from sklearn.linear_model import LogisticRegression, Lasso, LinearRegression, Ridge
from sklearn.ensemble import RandomForestClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import LinearSVC
from sklearn.model_selection import LeaveOneOut
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import make_pipeline
from sklearn.model_selection import cross_val_score, cross_val_predict
from sklearn.model_selection import permutation_test_score
from sklearn.tree import DecisionTreeClassifier
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)
from sklearn.preprocessing import Imputer

from sklearn.neural_network import MLPClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.gaussian_process import GaussianProcessClassifier
from sklearn.gaussian_process.kernels import RBF
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.discriminant_analysis import QuadraticDiscriminantAnalysis
from sklearn.linear_model import LogisticRegression, Lasso, LinearRegression, Ridge
from sklearn.preprocessing import PolynomialFeatures


# ## Classify if partner wants the partner
# 
# Based a three second interaction with social signals (smiles, eye fixations, etc.), we try to classify whether or not the person would like to date their partner

# In[2]:


df_first = df.query('Epoch_time==0')
df_mid = df.query('Epoch_time==1')
df_last = df.query('Epoch_time==2')

df_mid_first = df.query('Epoch_time!=0')
df_mid_first = df_mid_first.groupby(['ID_num'], as_index=False).mean()



# ## 1. Predict the continuous attractive rating on verbal for men
# Here we are separating and only looking at men directly after the verbal interaction. Using these predictors:
# 
# 
# 'Eyes', 'Face', 'Head','Body', 'Smile', 'Laugh', 'Head_Shake', 'Hand_Shake', 'Touch_Face', 'Mean_Pupil_response', 'Mean_IHR_response', 'Mean_EDA_response'
# 
# 
# and included all of the interactions, we try to predict the attraction score using a Lasso regression. Results are validated using a permutation test.
# 

# # Load data

# In[3]:


df = pd.read_csv('../data/Centered.csv', sep=',', na_values=['-999','999'])
#df = df[pd.notnull(df['FR_I_date_again_YN'])]
df = df.query('Gender == 1')
df_verbal = df.query('dummyverbal==1')


# # Define Lasso regression and make pipeline

# In[4]:


lr = Lasso(0.5)
# we have already demeaned our data, so just divide with the standard deviation
clf = make_pipeline(StandardScaler(with_mean=False), lr)


# In[5]:


# Dependent variable 
y = df_verbal['Attraction'].values

# Design matrix
X = df_verbal[['Eyes', 'Face', 'Head',
       'Body', 'Smile', 'Laugh', 'Head_Shake', 'Hand_Shake', 'Touch_Face',
       'Mean_Pupil_response', 'Mean_IHR_response', 'Mean_EDA_response',]].copy()

imp = Imputer(missing_values = 'NaN', strategy = 'mean', axis = 0)

# Add interaction effects to our Design matrix
pf = PolynomialFeatures(2, interaction_only=True)
poly_feats = pf.fit_transform(X)

X = imp.fit_transform(X)
X = np.c_[X, poly_feats]


# In[6]:


score = cross_val_score(clf, X, y, cv=10)
score.mean()


# In[8]:


p_score = permutation_test_score(clf, X, y, n_permutations=3000, n_jobs=1, cv=10)
sns.distplot(p_score[1])
score = p_score[0]

plt.plot(score, 2, '*', color='k', markersize=12)
plt.axvline(np.mean(p_score[1]), linestyle='--', color='black')

plt.title(f'R-squared = {p_score[0]:.2f}\np-value = {p_score[2]:.2f}')
plt.xlabel('R-squared', size=18)
sns.despine()
plt.show()


# ## 2. Predict the continuous attractive rating on verbal for women
# Here we are separating and only looking at men directly after the verbal interaction. Using these predictors:
# 
# 
# 'Eyes', 'Face', 'Head','Body', 'Smile', 'Laugh', 'Head_Shake', 'Hand_Shake', 'Touch_Face', 'Mean_Pupil_response', 'Mean_IHR_response', 'Mean_EDA_response'
# 
# 
# and included all of the interactions, we try to predict the attraction score using a Lasso regression. Results are validated using a permutation test.
# 

# # Load data

# In[139]:


df = pd.read_csv('../data/Centered.csv', sep=',', na_values=['-999','999'])
#df = df[pd.notnull(df['FR_I_date_again_YN'])]
df = df.query('Gender == 0')
df_verbal = df.query('dummyverbal==1')


# In[140]:


lr = Lasso(0.5)
# we have already demeaned our data, so just divide with the standard deviation
clf = make_pipeline(StandardScaler(with_mean=False), lr)


# In[141]:


# Dependent variable 
y = df_verbal['Attraction'].values

# Design matrix
X = df_verbal[['Eyes', 'Face', 'Head',
       'Body', 'Smile', 'Laugh', 'Head_Shake', 'Hand_Shake', 'Touch_Face',
       'Mean_Pupil_response', 'Mean_IHR_response', 'Mean_EDA_response',]].copy()

imp = Imputer(missing_values = 'NaN', strategy = 'mean', axis = 0)

# Add interaction effects to our Design matrix
pf = PolynomialFeatures(2, interaction_only=True)
poly_feats = pf.fit_transform(X)

X = imp.fit_transform(X)
X = np.c_[X, poly_feats]


# In[142]:


score = cross_val_score(clf, X, y, cv=10)
score.mean()


# In[143]:


p_score = permutation_test_score(clf, X, y, n_permutations=3000, n_jobs=1, cv=10)
sns.distplot(p_score[1])
score = p_score[0]

plt.plot(score, 2, '*', color='k', markersize=12)
plt.axvline(np.mean(p_score[1]), linestyle='--', color='black')

plt.title(f'R-squared = {p_score[0]:.2f}\np-value = {p_score[2]:.2f}')
plt.xlabel('R-squared', size=18)
sns.despine()
plt.show()


# ## 3. Predict the continuous attractive rating on non-verbal for men
# Here we are separating and only looking at men directly after the verbal interaction. Using these predictors:
# 
# 
# 'Eyes', 'Face', 'Head','Body', 'Smile', 'Laugh', 'Head_Shake', 'Hand_Shake', 'Touch_Face', 'Mean_Pupil_response', 'Mean_IHR_response', 'Mean_EDA_response'
# 
# 
# and included all of the interactions, we try to predict the attraction score using a Lasso regression. Results are validated using a permutation test.
# 

# # Load data

# In[144]:


df = pd.read_csv('../data/Centered.csv', sep=',', na_values=['-999','999'])
#df = df[pd.notnull(df['FR_I_date_again_YN'])]
df = df.query('Gender == 1')
df_verbal = df.query('dummyverbal==0')


# In[145]:


lr = Lasso(0.5)
# we have already demeaned our data, so just divide with the standard deviation
clf = make_pipeline(StandardScaler(with_mean=False), lr)


# In[146]:


# Dependent variable 
y = df_verbal['Attraction'].values

# Design matrix
X = df_verbal[['Eyes', 'Face', 'Head',
       'Body', 'Smile', 'Laugh', 'Head_Shake', 'Hand_Shake', 'Touch_Face',
       'Mean_Pupil_response', 'Mean_IHR_response', 'Mean_EDA_response',]].copy()

imp = Imputer(missing_values = 'NaN', strategy = 'mean', axis = 0)

# Add interaction effects to our Design matrix
pf = PolynomialFeatures(2, interaction_only=True)
poly_feats = pf.fit_transform(X)

X = imp.fit_transform(X)
X = np.c_[X, poly_feats]


# In[147]:


score = cross_val_score(clf, X, y, cv=10)
score.mean()


# In[148]:


p_score = permutation_test_score(clf, X, y, n_permutations=3000, n_jobs=1, cv=10)
sns.distplot(p_score[1])
score = p_score[0]

plt.plot(score, 2, '*', color='k', markersize=12)
plt.axvline(np.mean(p_score[1]), linestyle='--', color='black')

plt.title(f'R-squared = {p_score[0]:.2f}\np-value = {p_score[2]:.2f}')
plt.xlabel('R-squared', size=18)
sns.despine()
plt.show()


# ## 4. Predict the continuous attractive rating on non-verbal for women
# Here we are separating and only looking at men directly after the verbal interaction. Using these predictors:
# 
# 
# 'Eyes', 'Face', 'Head','Body', 'Smile', 'Laugh', 'Head_Shake', 'Hand_Shake', 'Touch_Face', 'Mean_Pupil_response', 'Mean_IHR_response', 'Mean_EDA_response'
# 
# 
# and included all of the interactions, we try to predict the attraction score using a Lasso regression. Results are validated using a permutation test.
# 

# # Load data

# In[149]:


df = pd.read_csv('../data/Centered.csv', sep=',', na_values=['-999','999'])
#df = df[pd.notnull(df['FR_I_date_again_YN'])]
df = df.query('Gender == 0')
df_verbal = df.query('dummyverbal==0')


# In[150]:


lr = Lasso(0.5)
# we have already demeaned our data, so just divide with the standard deviation
clf = make_pipeline(StandardScaler(with_mean=False), lr)


# In[151]:


# Dependent variable 
y = df_verbal['Attraction'].values

# Design matrix
X = df_verbal[['Eyes', 'Face', 'Head',
       'Body', 'Smile', 'Laugh', 'Head_Shake', 'Hand_Shake', 'Touch_Face',
       'Mean_Pupil_response', 'Mean_IHR_response', 'Mean_EDA_response',]].copy()

imp = Imputer(missing_values = 'NaN', strategy = 'mean', axis = 0)

# Add interaction effects to our Design matrix
pf = PolynomialFeatures(2, interaction_only=True)
poly_feats = pf.fit_transform(X)

X = imp.fit_transform(X)
X = np.c_[X, poly_feats]


# In[152]:


score = cross_val_score(clf, X, y, cv=10)
score.mean()


# In[153]:


p_score = permutation_test_score(clf, X, y, n_permutations=3000, n_jobs=1, cv=10)
sns.distplot(p_score[1])
score = p_score[0]

plt.plot(score, 2, '*', color='k', markersize=12)
plt.axvline(np.mean(p_score[1]), linestyle='--', color='black')

plt.title(f'R-squared = {p_score[0]:.2f}\np-value = {p_score[2]:.2f}')
plt.xlabel('R-squared', size=18)
sns.despine()
plt.show()


# # Educational purposes for permutation test

# In[112]:


a = y.copy()
s1 = cross_val_score(clf, X, a)
score = np.mean(s1)

shuffles = []
n_perm = 1000
for i in range(n_perm):
    np.random.shuffle(a)
    s2 = cross_val_score(clf, X, a)
    shuffles.append(np.mean(s2))

p_value = 1 - (sum(score > np.array(shuffles))/n_perm)

sns.distplot(shuffles)
plt.plot(score, 2, '*', color='k', markersize=12)
plt.axvline(p_value, linestyle='--', color='black')

plt.title(f'Accuracy = {score:.2f}\np-value = {p_value:.2f}')
plt.xlabel('Accuracy', size=18)
sns.despine()
plt.show()

