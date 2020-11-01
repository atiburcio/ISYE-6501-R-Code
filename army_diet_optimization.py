
pip install pulp


import pandas as pd
from pulp import *


food = pd.read_excel("diet.xls")


food.head()


food = food[:64]


min_intake = [1500,30,20,800,130,125,60,1000,400,700,10]

max_intake = [2500,240,70,2000,450,250,100,10000,5000,1500,40]



# Get a nested list from the values 
# This is a list where each item is a row, as a list
food_data = food.values.tolist()
# look at an item in the list--carrots for example
print(food_data[1])



# Make a list of all of our 64 foods
foods = [x[0] for x in food_data]


# Take a look at food_data
# for x in food_data:
#     print('{}: {}'.format(x[0],x[3]))



# Make dictionaries (key / value pairs) from the lists
# Key = food name
# Value = value
costs = {x[0]:x[1] for x in food_data}
calories = {x[0]:x[3] for x in food_data}
cholesterol = {x[0]:x[4] for x in food_data}
fat = {x[0]:x[5] for x in food_data}
sodium = {x[0]:x[6] for x in food_data}
carbs = {x[0]:x[7] for x in food_data}
fiber = {x[0]:x[8] for x in food_data}
protein = {x[0]:x[9] for x in food_data}
vit_A = {x[0]:x[10] for x in food_data}
vit_C = {x[0]:x[11] for x in food_data}
calcium = {x[0]:x[12] for x in food_data}
iron = {x[0]:x[13] for x in food_data}



# Create the optimization problem
prob = LpProblem('Diet Problem', LpMinimize)



# Create the variables using LpVariable.dicts
lp_vars = LpVariable.dicts( "Amounts", foods, 0 )


# Create objective function using lpSum and list comprehension 
prob += lpSum( costs[i] * lp_vars[i] for i in foods )         # objective function


# Create constraints using lpSum and list comprehension

# Min daily intake constraints
prob += lpSum( calories[i] * lp_vars[i] for i in foods ) >= min_intake[0]  # min calorie intake
prob += lpSum( cholesterol[i] * lp_vars[i] for i in foods ) >= min_intake[1]  # min cholesterol intake
prob += lpSum( fat[i] * lp_vars[i] for i in foods ) >= min_intake[2]  # min fat intake
prob += lpSum( sodium[i] * lp_vars[i] for i in foods ) >= min_intake[3]  # min sodium intake
prob += lpSum( carbs[i] * lp_vars[i] for i in foods ) >= min_intake[4]  # min carbs intake
prob += lpSum( fiber[i] * lp_vars[i] for i in foods ) >= min_intake[5]  # min fiber intake
prob += lpSum( protein[i] * lp_vars[i] for i in foods ) >= min_intake[6]  # min protein intake
prob += lpSum( vit_A[i] * lp_vars[i] for i in foods ) >= min_intake[7]  # min vit_A intake
prob += lpSum( vit_C[i] * lp_vars[i] for i in foods ) >= min_intake[8]  # min vit_C intake
prob += lpSum( calcium[i] * lp_vars[i] for i in foods ) >= min_intake[9]  # min calcium intake
prob += lpSum( iron[i] * lp_vars[i] for i in foods ) >= min_intake[10]  # min iron intake

# Max daily intake constraints
prob += lpSum( calories[i] * lp_vars[i] for i in foods ) <= max_intake[0]  # max calorie intake
prob += lpSum( cholesterol[i] * lp_vars[i] for i in foods ) <= max_intake[1]  # max cholesterol intake
prob += lpSum( fat[i] * lp_vars[i] for i in foods ) <= max_intake[2]  # max fat intake
prob += lpSum( sodium[i] * lp_vars[i] for i in foods ) <= max_intake[3]  # max sodium intake
prob += lpSum( carbs[i] * lp_vars[i] for i in foods ) <= max_intake[4]  # max carbs intake
prob += lpSum( fiber[i] * lp_vars[i] for i in foods ) <= max_intake[5]  # max fiber intake
prob += lpSum( protein[i] * lp_vars[i] for i in foods ) <= max_intake[6]  # max protein intake
prob += lpSum( vit_A[i] * lp_vars[i] for i in foods ) <= max_intake[7]  # max vit_A intake
prob += lpSum( vit_C[i] * lp_vars[i] for i in foods ) <= max_intake[8]  # max vit_C intake
prob += lpSum( calcium[i] * lp_vars[i] for i in foods ) <= max_intake[9]  # max calcium intake
prob += lpSum( iron[i] * lp_vars[i] for i in foods ) <= max_intake[10]  # max iron intake


# Solve and check out the results
soln = prob.solve()


print( LpStatus[prob.status])
for v in prob.variables():
    print( f"{v.name} = {v.varValue:.2f}")

print(f"Cost: {value(prob.objective)}")





