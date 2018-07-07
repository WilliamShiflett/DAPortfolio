
# coding: utf-8

# # Exploring US Births
# 
# This juptyer notebook is based on a guided project from [DataQuest](https://www.dataquest.io), a data analytics tutorial.
# 
# The data comes from a [FiveThirtyEight](https://fivethirtyeight.com/) analysis, [Some People Are Too Superstitious to Have a Baby on Friday the 13th](https://github.com/fivethirtyeight/data/tree/master/births).
# 
# ## Scope
# 
# In this project, I'll analyze CDC and SSA data to determine the frequency of births by
# 
# - year,
# - month,
# - day of the month,
# - and day of the week.

# # Making a list...
# 
# I'll start by reading both datasets into lists, and then creating a list of those lists:

# In[1]:


import csv
import requests

CDC_CSV_URL_1 = 'https://raw.githubusercontent.com/fivethirtyeight/data/master/births/US_births_1994-2003_CDC_NCHS.csv'
SSA_CSV_URL_2 = 'https://raw.githubusercontent.com/fivethirtyeight/data/master/births/US_births_2000-2014_SSA.csv'

seeEssVees = [CDC_CSV_URL_1, SSA_CSV_URL_2]
listOfLists = []

for each in seeEssVees:
    with requests.Session() as s:
        download = s.get(each)
        decoded_content = download.content.decode('utf-8')
        data = csv.reader(decoded_content.splitlines(), delimiter=',')
        listOfLists.append(list(data))
        


# # Checking it twice...
# 
# The first element of each list should be a header row describing the datapoints that follow:

# In[2]:


listOfLists[0][0:5]


# In[3]:


listOfLists[1][0:5]


# # Benchmarking...
# 
# Both datasets contain datapoints for the years 2000 - 2003. Presumably, the number of CDC and SSA records should match. 
# 
# The code below checks whether this is the case:

# In[4]:


checkListCDC = []
checkListSSA = []

for each in listOfLists[0]:
    try:
        year = int(each[0])
        if (2000 <= year) and (year < 2004):
            checkListCDC.append(each)
    except:
        pass
    
for each in listOfLists[1]:
    try:
        year = int(each[0])
        if (2000 <= year) and (year < 2004):
            checkListSSA.append(each)
    except:
        pass


print("It's",(len(checkListSSA) == len(checkListCDC)),"that both lists have the same number of elements:")
print("The CDC data has",len(checkListCDC), "observations for the years 2000-2003.")
print("The SSA data has",len(checkListSSA), "observations for the years 2000-2003.")
    


# # More Benchmarking...
# 
# Both datasets contain the same *number* of datapoints for the years 2000 - 2003. But are those data points the same?
# 
# The code below compares the first five observations:

# In[5]:


checkListCDC[0:5]


# In[6]:


checkListSSA[0:5]


# # Counting Function
# 
# There are differences in the number of births recorded by each dataset, so we should analyze them separately.
# 
# Rather than write code to analyze each dataset separately, the code below creates a function that sums the number of births by year, month, day of the month, and day of the week.

# In[7]:


import pprint

def calc_counts(data, column):
    totalBirths = {}
    for each in data:
        try:
            period = int(each[column])
            if period in totalBirths:
                totalBirths[period]+=int(each[4])
            else:
                totalBirths[period]=int(each[4])
        except:
            pass
    return totalBirths

for each1 in listOfLists:
    print("")
    print("New dataset begins below:")
    for i in range(4):
        print("")
        if i == 0:
            print("Years:")
        elif i == 1:
            print("Month:")
        elif i == 2:
            print("Day of Month:")
        else:
            print("Day of Week:")
                
        print("")
        pprint.pprint(calc_counts(each1,i))
        
        


# ## Better Output
# 
# So far, we've found the number of births over certain periods. In the output above, integers represent certain days of the week (1-7, with 1 being a Monday) or months of the year (1-12).
# 
# Since we know the data pretty well at this point, this isn't a problem. But if someone like Blake in Marketing sees the output in this format, he's going to shoot us a quick e-email asking if we can meet for coffee to discuss it.
# 
# Too much caffeine is bad for us, and nobody reads e-mails, so we'll make the output more user-friendly for Blake by renaming the days of the week and the months of the year with the code below: 

# In[8]:


for dataSet in listOfLists:
    for each in dataSet:
        try:
            month = int(each[1])
            if month == 1:
                each[1] = "January"
            elif month == 2:
                each[1] = "Febraury"
            elif month == 3:
                each[1] = "March"
            elif month == 4:
                each[1] = "April"
            elif month == 5:
                each[1] = "May"
            elif month == 6:
                each[1] = "June"
            elif month == 7:
                each[1] = "July"
            elif month == 8:
                each[1] = "August"
            elif month == 9:
                each[1] = "September"
            elif month == 10:
                each[1] = "October"
            elif month == 11:
                each[1] = "November"
            else:
                each[1] = "December"
        except:
            pass
        
for dataSet in listOfLists:
    for each in dataSet:
        try:
            DOW = int(each[3])
            if DOW == 1:
                each[3]= "Monday"
            elif DOW == 2:
                each[3]= "Tuesday"
            elif DOW == 3:
                each[3]= "Wednesday"
            elif DOW == 4:
                each[3] = "Thursday"
            elif DOW == 5:
                each[3] = "Friday"
            elif DOW == 6:
                each[3] = "Saturday"
            else:
                each[3] = "Sunday"
        except:
            pass

for dataSet in listOfLists:
    print("")
    print("New dataset begins below:")
    print("")
    for each in dataSet[0:10]:
        print(each)

    


# Now that out data is in a more user-friendly format, we can run the counting function again:

# In[10]:


import pprint

def calc_counts(data, column):
    totalBirths = {}
    for each in data[1:]:
        try:
            period = each[column]
            if period in totalBirths:
                totalBirths[period]+=int(each[4])
            else:
                totalBirths[period]=int(each[4])
        except:
            pass
    return totalBirths

for each1 in listOfLists:
    print("")
    print("New dataset begins below:")
    for i in range(4):
        print("")
        if i == 0:
            print("Year:")
        elif i == 1:
            print("Month:")
        elif i == 2:
            print("Day of Month:")
        else:
            print("Day of Week:")
                
        print("")
        pprint.pprint(calc_counts(each1,i))
        
        


# # More Functions
# 
# Write a function that can calculate the min and max values for any dictionary that's passed in.
# Write a function that extracts the same values across years and calculates the differences between consecutive values to show if number of births is increasing or decreasing.
# For example, how did the number of births on Saturday change each year between 1994 and 2003?
# Find a way to combine the CDC data with the SSA data, which you can find here. Specifically, brainstorm ways to deal with the overlapping time periods in the datasets.
# 
# 
# 
