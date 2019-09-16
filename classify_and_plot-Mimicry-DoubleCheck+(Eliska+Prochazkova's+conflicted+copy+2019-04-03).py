
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


# In[2]:


df = pd.read_csv('../data/Data_for_modelling.csv', sep=',', na_values=['-999','999'])
df = df[pd.notnull(df['FR_I_date_again_YN'])]


# In[4]:



cols = df.columns[df.dtypes.eq('object')]
df[cols] = df[cols].apply(pd.to_numeric, errors='coerce')
df.columns


# ## Classify if partner wants the partner
# 
# Based a three second interaction with social signals (smiles, syncrony, etc.), we try to classify whether or not the person would like to date their partner

# In[5]:


#df = df[df.Gender == 1]

#X = df[['Eyes', 'Face', 'Head',
 #      'Body', 'Smile', 'Laugh', 'Head_Shake', 'Hand_Shake', 'Touch_Face']].copy()

X = df[['WCCmean_SCL','WCCmean_IHR','Both_Smile_mean',
       'Both_Laugh_mean', 'Both_Head_Shake_mean', 'Both_Hand_Shake_mean',
        'Both_Head_Fix_mean', 'Both_Face_Fix_mean',
       'Both_Eye_Fix_mean']].copy()

X = X.replace(' ', 0)
X = X.values.astype(np.float)

y = df['FR_I_date_again_YN'].values

#y = df['Match_Num'].values


# In[12]:




X = df[['WCCmean_SCL','WCCmean_IHR','Both_Smile_mean',
       'Both_Laugh_mean', 
     'Both_Face_Fix_mean',
       'Both_Eye_Fix_mean']].copy()

columns_new = ['WCCmean_SCL','WCCmean_IHR','Both_Smile_mean',
       'Both_Laugh_mean', 
        'Both_Face_Fix_mean',
       'Both_Eye_Fix_mean']

# pass in array and columns
xDF = pd.DataFrame(X, columns=columns_new)


# In[13]:


import seaborn as sns; sns.set(color_codes=True)

g = sns.clustermap(xDF.corr(), cmap='RdYlGn')


# In[19]:


sns.heatmap(xDF.corr(), square=True, xticklabels=True, yticklabels=True, vmin=0,  vmax=1)


# In[10]:


imp = Imputer(missing_values = 'NaN', strategy = 'mean', axis = 0)
X = imp.fit_transform(X)


# In[7]:


# setup classifier stuff
lr = LogisticRegression(class_weight='balanced')
gnb = GaussianNB()
svc = LinearSVC(C=0.5, class_weight='balanced')
rfc = RandomForestClassifier(3)
knn = KNeighborsClassifier()
dt = DecisionTreeClassifier()

loo = 10
#loo = LeaveOneOut()
# define classifier pipeline
clf = make_pipeline(StandardScaler(), lr)


# ## Classify and do permatutation test

# In[59]:


dt.fit(X, y)
dt.feature_importances_.shape


# In[60]:


dt.fit(X, y)

n_features = len(dt.feature_importances_)

fig = plt.figure(figsize=(13, 5))
plt.bar(np.arange(n_features), dt.feature_importances_
sns.despine(offset=5)
plt.xticks(np.arange(n_features), [['WCCmean_SCL','WCCmean_IHR','Both_Smile_mean',
       'Both_Laugh_mean', 'Both_Head_Shake_mean', 'Both_Hand_Shake_mean',
        'Both_Head_Fix_mean', 'Both_Face_Fix_mean',
       'Both_Eye_Fix_mean']])
plt.ylabel('Feature importance (AU)')
plt.show()


# In[61]:


p_score = permutation_test_score(clf, X, y, cv=loo, scoring='accuracy', n_permutations=3000, n_jobs=2)
sns.distplot(p_score[1])
plt.plot(p_score[0], 2, '*', color='k', markersize=12)
plt.axvline(np.mean(p_score[1]), linestyle='--', color='black')
plt.title(f'Accuracy = {p_score[0]*100:.2f}%\np-value = {p_score[2]:.2f}')
plt.xlabel('Accuracy', size=18)
sns.despine()
plt.show()


# ## Predict the continuous attractive rating

# In[1]:


from sklearn.linear_model import Lasso
from sklearn.linear_model import ElasticNet
from sklearn.linear_model import LinearRegression
from sklearn.linear_model import Ridge
from sklearn.linear_model import ARDRegression
from sklearn.metrics import classification_report
from sklearn.metrics import confusion_matrix


# In[1]:


df = pd.read_csv('../data/3.Change_Over_time.csv', sep=',', na_values=['-999','999'])

df = df.convert_objects(convert_numeric=True)

#df = df[df.Gender == 1]

#X = df[['WCCmean_SCL','WCCmean_IHR','Both_Smile_mean',
#       'Both_Laugh_mean', 'Both_Head_Shake_mean', 'Both_Hand_Shake_mean',
#       'Both_Touch_Face_mean', 'Both_Head_Fix_mean', 'Both_Face_Fix_mean',
#       'Both_Eye_Fix_mean', 'Gender', 'Epoch_time', 'VerbFirst_first']].copy()

X = df[['WCCmean_SCL','WCCmean_IHR','Both_Smile_mean',
      'Both_Laugh_mean','Both_Face_Fix_mean',
     'Both_Eye_Fix_mean']].copy()


y = df['Atract_prec_change'].values

mask = np.isnan(y)
y = y[~mask]
X = X[~mask]
imp = Imputer(missing_values = 'NaN', strategy = 'mean', axis = 0)
X = imp.fit_transform(X)


# In[74]:


# define classifier pipeline
ridge = Ridge(alpha = 0.1, normalize = True)
Lin_reg = LinearRegression()
lasso = Lasso(alpha = 0.053, normalize = True)
elastic_net = ElasticNet()
ARD = ARDRegression (fit_intercept = False)
loo = 10

clf = make_pipeline(StandardScaler(), lasso)


# In[75]:


p_score[0]


# In[76]:


sns.heatmap(X)


# In[103]:


mse = np.mean((y - y_hat)**2)
mean_error = np.mean((y - np.mean(y))**2)

r2 = 1 - (mse/mean_error)
r2


# In[104]:


lasso.fit(X, y)
y_hat = cross_val_predict(lasso, X, y)

plt.scatter(y_hat, y)


# In[105]:


p_score = permutation_test_score(clf, X, y, scoring="r2", n_permutations=3000, n_jobs=2)
sns.distplot(p_score[1])
r2 = p_score[0]

plt.plot(r2, 2, '*', color='k', markersize=12)
plt.axvline(np.mean(p_score[1]), linestyle='--', color='black')

plt.title(f'R2 = {p_score[0]:.2f}\np-value = {p_score[2]:.2f}\nr2 = {r2:.3f}')
plt.xlabel('R2', size=18)
sns.despine()
plt.show()


# In[36]:


Z = np.array(X)
Y = np.array(y)

model = lasso
model.fit(Z,Y)

#Plot the true vs estimated coefficients
plt.plot(np.arange(10), np.squeeze (model.coef_))
#plt.plot(np.arange(106), Y)
plt.legend(["Estimated", "True"])
plt.show
print(model.coef_)


# In[33]:


Z.shape


# In[34]:


Y.shape


# In[ ]:




