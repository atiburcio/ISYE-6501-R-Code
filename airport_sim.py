import random
import pandas as pd
import simpy

# Repurposed car wash example from simpy documentation to create an airport simulation. The objects/generators are still using carwash syntax but the print statements have been updated.

RANDOM_SEED = 42
NUM_WASH_MACHINES = 4  # Number of washing machines in carwash
NUM_WAX_MACHINES = 3
MEAN_WASHTIME = 0.75  # Avg minutes it takes to clean car (exponential distribution)
WAXTIME_PARAMS = [0.5,1] # Limits for uniform distibution of time to wax a car
T_INTERARRIVAL = 0.2 # Exponential distribution with mean 0.2 minutes
SIM_TIME = 480     # Simulation time in minutes (8hrs x 60 minutes)
ARRIVAL_TIMES = [] # Empty list to store arrival time for each car i
ENTER_QUEUE_1 = [] # Time car enters wash station
LEAVE_QUEUE_1 = [] # Time car leaves wash station
ENTER_QUEUE_2 = [] # Time car enters last station-wax station

class Carwash(object):
    """A carwash has a limited number of machines (``NUM_MACHINES``) to
    clean cars in parallel.

    Cars have to request one of the machines. When they got one, they
    can start the washing processes and wait for it to finish (which
    takes ``washtime`` minutes).

    """
    def __init__(self, 
                 env, 
                 NUM_WASH_MACHINES,
                 NUM_WAX_MACHINES,
                 MEAN_WASHTIME,
                 WAXTIME_PARAMS):
        self.env = env
        self.wash_machine = simpy.Resource(env, NUM_WASH_MACHINES)
        self.wax_machine = simpy.Resource(env, NUM_WAX_MACHINES)
        self.mean_washtime = MEAN_WASHTIME
        self.waxtime_params = WAXTIME_PARAMS

    def wash(self, car):
        """The washing processes. It takes a ``car`` processes and tries
        to clean it."""
        
        rand_wash_time = random.expovariate(1/self.mean_washtime) #random washtime using mean_washtime as parameter
        yield self.env.timeout(rand_wash_time) 
        print('Processed a traveler at check ID station in {}'.format(round(rand_wash_time,2)))
        
    def wax(self, car):
        
        rand_wax_time = random.uniform(self.waxtime_params[0], 
                                       self.waxtime_params[1]) #random wax time using waxtime_params 
        yield self.env.timeout(rand_wax_time)
        print('Processed a traveler at self check station in {} seconds'.format(round(rand_wax_time,2)))
        
def car(env, name, cw):
    """The car process (each car has a ``name``) arrives at the carwash
    (``cw``) and requests a cleaning machine.

    It then starts the washing process, waits for it to finish and
    leaves to never come back ...

    """
    print('{} arrives at airport at {} minutes'.format(name,
                                                         round(env.now,2)))
    arrival = (name,round(env.now,2))
    ARRIVAL_TIMES.append(arrival) # store arrival times in list above
    
    with cw.wash_machine.request() as wash_request:
        yield wash_request

        print('{} enters the check ID station at {} minutes'.format(name,
                                                                    round(env.now,2)))
        enter_first_queue = (name,round(env.now,2))
        ENTER_QUEUE_1.append(enter_first_queue) # store time in list above
        
        yield env.process(cw.wash(name))

        print('{} leaves the check ID station at {} minutes'.format(name, 
                                                                    round(env.now,2)))
        leave_first_queue = (name,round(env.now,2))
        LEAVE_QUEUE_1.append(leave_first_queue) # store time in list above
        
    with cw.wax_machine.request() as wax_request:
        yield wax_request

        print('{} enters the self check station at {} minutes'.format(name,
                                                                    round(env.now,2)))
        
        enter_second_queue = (name,round(env.now,2))
        ENTER_QUEUE_2.append(enter_second_queue) # store time in list above
        
        yield env.process(cw.wax(name))

        print('{} leaves the self check station at {} minutes'.format(name, 
                                                                    round(env.now,2)))
        
def setup(env,  
          NUM_WASH_MACHINES,
          NUM_WAX_MACHINES,
          MEAN_WASHTIME,
          WAXTIME_PARAMS,
          T_INTERARRIVAL):
    
    carwash = Carwash(env,
                      NUM_WASH_MACHINES,
                      NUM_WAX_MACHINES,
                      MEAN_WASHTIME,
                      WAXTIME_PARAMS)
    i = 0
    
    while True:
        yield env.timeout(random.expovariate(1/T_INTERARRIVAL))
        i += 1
        env.process(car(env,'Traveler {}'.format(i), carwash))
        
print('Planes!!')
random.seed(RANDOM_SEED)


env = simpy.Environment()
env.process(setup(env,
                  NUM_WASH_MACHINES,
                  NUM_WAX_MACHINES,
                  MEAN_WASHTIME,
                  WAXTIME_PARAMS,
                  T_INTERARRIVAL))

# Execute!
env.run(until=SIM_TIME)



import pandas as pd
# transfrom to dataframe
arrival_df = pd.DataFrame(ARRIVAL_TIMES)
enter_Q1 = pd.DataFrame(ENTER_QUEUE_1)
leave_Q1 = pd.DataFrame(LEAVE_QUEUE_1)
enter_Q2 = pd.DataFrame(ENTER_QUEUE_2)

# join tables to get average wait time for queue 1 (boarding pass ID check)
merged = pd.merge(arrival_df, enter_Q1, how='inner', on=0)
merged = merged.rename(columns={"0": "car_number", "1_x": "arrival_time", "1_y": "enter_Q1"})
wait_time = merged["enter_Q1"]-merged["arrival_time"]
average_wait_time_Q1 = sum(wait_time)/len(wait_time)

# join tables to get average wait time for queue 2 (self check)
merged_2 = pd.merge(leave_Q1, enter_Q2, how='inner', on=0)
merged_2 = merged_2.rename(columns={"0": "car_number", "1_x": "leave_Q1", "1_y": "enter_Q2"})
wait_time_Q2 = merged_2["enter_Q2"]-merged_2["leave_Q1"]
average_wait_time_Q2 = sum(wait_time_Q2)/len(wait_time_Q2)

# add the two average together
total_avg = average_wait_time_Q1 + average_wait_time_Q2

# total average wait time 
print(total_avg)