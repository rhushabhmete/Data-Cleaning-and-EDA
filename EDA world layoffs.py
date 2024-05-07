#!/usr/bin/env python
# coding: utf-8

# In[1]:


import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


# In[2]:


df = pd.read_csv(r'World layoffs.csv')
df


# In[3]:


import warnings
warnings.filterwarnings('ignore')


# # Let's Explore dataset

# # Duplicate Data

# In[19]:


df[df.duplicated()]


# # View Duplicates

# In[28]:


df[df['company'] == 'Wildlife Studios']


# # Remove Duplicates

# In[29]:


df[df.duplicated()] = df.drop_duplicates()


# In[30]:


df[df.duplicated()]


# # Shape of Dataset

# In[4]:


df.shape


# # Column names in the dataset

# In[5]:


df.columns


# In[6]:


df.head()


# In[57]:


df.info()


# # Null values

# In[8]:


df.isnull().sum()

Most of the missing values are concentrated in three columns:

total_laid_off
percentage_laid_off
funds_raised.
# # Drop rows with missing values

# In[32]:


# Drops rows where the 'total_laid_off' column value is NA
df = df.dropna(subset = ['total_laid_off'])


# In[33]:


df.isnull().sum()


# In[34]:


# Checks for missing values in columns: industry and stage
df[
    df['industry'].isnull() |
    df['stage'].isnull()
]

Values for the 'industry' column may be manually filled in with the use of a quick Google search – we could assume that companies with the name 'Data' are in the data industry. And for the row with NaN in the 'stage' column, we will drop it because 'stage' and 'funds_raised' can be difficult to determine for small and private companies – another justification for dropping it is that it would be insignificant to the general distribution and impact of the analysis.Manually replace NULL and missing values in the column 'Industry'
# In[40]:


df.loc [8, 'industry'] = 'Data'
df.loc [330, 'industry'] = 'Data'
df.loc [736, 'industry'] = 'Crypto'
df.loc [1595, 'industry'] = 'Real Estate'


# In[54]:


df.isnull().sum()


# # update the records

# #### Rename the record 'crypto currency' in the column 'industry' to 'crypto'

# In[9]:


df.loc[df.index.isin([901,1258,1272]), 'industry'] = 'Crypto'


# #### Rename the record 'United States.' in the column 'country' to 'United States'

# In[10]:


df.loc[df.index.isin([10,34,102,912]), 'country'] = 'United States'


# # Top 5 countries affected by layoffs

# In[11]:


df.groupby('country')['total_laid_off'].sum().sort_values(ascending=False).head().plot(ylabel="", autopct='%1.2f%%', figsize=(8,8), kind='pie', stacked=True, colormap='Accent')

United State is the top country which is most affected by layoff followed by India
# # Top 5 industries affected by layoffs world wide

# In[12]:


df.groupby('industry')['total_laid_off'].sum().sort_values(ascending=False).head().plot(ylabel="", autopct='%1.2f%%', figsize=(8,8), kind='pie', stacked=True, colormap='Set3')

Consumer industry is mostly affected by layoff followed by Retail industry
# # Top 5 locations affected by layoffs world wide

# In[59]:


plt.figure(figsize = (8,8))
df1.plot(kind = 'bar', color = 'skyblue')
plt.ylabel('total_laid_off')
plt.xlabel('location')
plt.title('Top 5 Locations by Total Laid Off')
plt.show()

The SF Bay Area has the most layoff rounds. It is more than double the number of layoff rounds in the next city, New York.
# # Total Layoffs in different industries world wide since 2020

# In[17]:


plt.figure(figsize=(10, 6))
plt.title("Total Layoffs in different industries world wide since 2020")
plt.ylabel("Number of layoffs reported")
df_industries = df.groupby('industry').sum()['total_laid_off'].sort_values(ascending=False).plot(figsize=(16,8), kind='bar', stacked=True, colormap='Accent')

