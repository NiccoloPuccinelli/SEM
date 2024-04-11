# Documentation

## Simulator

The current repository implements the backend logic of a ride-sharing simulator.  The logic interacts with [SUMO](https://sumo.dlr.de/docs/index.html) (a popular traffic generator and simulator) through [TraCI](https://sumo.dlr.de/docs/TraCI/Interfacing_TraCI_from_Python.html), an API interface specifically developed for Python (you can find the documentation [here](https://sumo.dlr.de/pydoc/traci.html)).

The simulator is developed to run simulations on arbitrary (realistic or fantasy) urban nets.

The net can be developed from scratch using [NetEdit](https://sumo.dlr.de/docs/Netedit/index.html) (included in SUMO), or it can be [downloaded](https://sumo.dlr.de/docs/Networks/Import/OpenStreetMapDownload.html) and [imported](https://sumo.dlr.de/docs/Networks/Import/OpenStreetMap.html) from OpenStreetMap.

During the simulation, drivers and customers are generated according to a customizable logic (which we call [*scenario*](#scenario)),  emulating the demand and offer of rides within the net, in a given interval of time.

You can find the details about the parameters of the simulator [here](doc/Parameters/).


## Net

A [net](/src/model/Net.py) is a collection of *edges* and *nodes*, grouped in **Traffic Analytic Zones** (TAZs). The *edges* and *nodes* represent the roads and the crossroads, while the TAZs represent the areas in which the net is divided.

The simulator relies on three different layers of the net that provide three different level of details and information:
* **Mobility layer**: provides the ride-hail vehicle activity (mean number of pickups and dropoffs requests in a TAZ per hour).
* **Analytics layer**: specifies the mean travel times (and the std. dev.) from each TAZ to the other TAZs of the net.
* **Boundary layer**: defines the layout of the TAZs of the net, for the simulation.

The three layers can have three different TAZs layouts. Indeed, the information related to the mobility and the travel times could derive from different sources and authorities. 

For example, in one of our two nets provided in the repo (in the `data` folder) we acquired the layers for the city of San Francisco (`data/sf`) from different authorities: the mobility layers from the [San Francisco County Transportation Authority (SFCTA)](https://www.sfcta.org/tools-data/maps); the analytics layers from the [Uber Movements](https://movement.uber.com/?lang=en-US) (unfortunately no longer available); the boundary layer from the [EarthWorks Stanford Project](https://earthworks.stanford.edu/catalog/stanford-df986nv4623). The three layers come from three different and independent authorities that published their data using three different TAZs layouts.

However, the simulator also accepts a configuration where the three layers derive from the same layout. For example, in the `data/city` demo, the three layers have been generated from a single layout, named `test`.

The simulator is able to manage different layouts from the three levels, and use the boundary layer for defining the TAZs layout of the simulation. The connecting ring between the three layers is represented by the edges of the net. Indeed, for each layer, each edge belongs to one TAZ of the net. Therefore, given an edge it is possible to map it on the three different layers uniquely and acquire the corresponding information from each of the layer.


## Simulation Life-Cycle

The core method of the [Simulator](/src/controller/Simulator.py) is the public method `run` that executes the life-cycle of a given *scenario*, for each timestamp of the simulation.

The simulation lasts for a given period of time, determined by two variables (`BEGIN` and`END`) in the environment file `.env`  (the detailed content of the environment file is described [later](#environment-variables)).

The time of the simulation is beaten by a SUMO configuration variable `step-length`. By default, each cycle of the simulation corresponds to `1` second in the real life (`step-length = 1`).

At each simulation cycle, the simulator performs the following operations (in order):


### 1. Drivers, Customers and Persons generation

The simulator generates the [drivers](src/model/Driver.py), the [customers](src/model/Customer.py) and the [persons](src/model/Person.py) that are planned to be inserted in the net at a given timestamp of the simulation (the [generation plan](#generation-plan) is created before to run the simulation).


### 2. Traffic generation

Regarding traffic, this is implemented using [real hourly data](https://data.sfgov.org/Transportation/SFMTA-Transit-Vehicle-Location-History-Current-Yea/x344-v6h6/about_data) from the city of San Francisco, for each TAZ. Similar to what happens to drivers without requests, a random route is generated for each person, in a way that simulates the real traffic distribution.


### 3. Ride requests generation

The simulator generates a [ride](src/model/Ride.py) request for each new customer inserted in the simulation. In the current version of the simulator, at each timestamp the requests are generated with 80% of probability, simulating a small degree of hesitation before to performing the request. If the requests are not generated at the given timestamp, the simulator collect the customers without a request yet, and it retry to generate them at the following timestamp.


### 4. Pending Requests Processing

For each ride request, the corresponding customer accepts or rejects the offer proposed by the [provider](/src/model/Provider.py),  given the current [surge multiplier](#surge-multiplier) in the TAZ in which the customer lies. If the customer accepts the request, the simulator processes the pending ride request, searching for nearby driver candidates that can accept the ride request and accomplish it. Otherwise, it discard the request and the customer is removed from the net. The selection of the list of candidates is based on distance criterion of the drivers from the customer (the maximum distance is established through a [configuration parameter](src/setup/sim_config/simulator.json)). In order to increase the efficiency of the simulation, instead of sorting the drivers at each iteration, the [8 closest drivers](https://doi.org/10.1145/2815675.2815681) are selected through an algorithm that exploits the heap.


### 5. Pending Requests Management

At each timestamp, the simulator update the status of each ride request already processed, through the support of the [provider](/src/model/Provider.py). The provider selects the next candidate in the list (sorted by distance), forwards  the request to the driver, and manage the requests according to the response of the selected driver candidate. The processing of a ride request can last several timestamps: given a driver candidate, the driver replies within 15 timestamps (the response time is a random value between 4 and 15 timestamps). The driver accepts or rejects the ride according to his [personality](#customer-and-driver-personality) and the value of the [surge multiplier](#surge-multiplier) within the TAZ of the request. If the driver rejects the request, the ride request is forwarded to next driver in the candidate list (if the list is empty, the ride is marked as `not served`, and the customer is removed from the net). Otherwise, if the driver accepts the ride request, the simulator associates the customer to the driver, and ride starts.


### 6. Update Drivers

At each timestamp, the simulator updates the position of each free driver (i.e. not involved in a ride) in the net. The free states of a driver are: `idle`, `responding`, or `moving` (more details in the [driver states section](#driver-states))

In particular, if the driver is `idle` (i.e. waiting for request) the simulator applies a policy to decide if the driver stops to work (and has to be removed from the net) or it continues to work. The policy through which the driver decides to stop to work is a [configuration parameter](src/setup/sim_config/simulator.json).

Furthermore, there is a stop work policy related to time. In fact, the more time passes, the greater the probability that, at each timestamp, each driver will stop working (up to a maximum of 5% at each timestamp after 4 hours of work, that is the [average work daily time](https://www.uber.com/en-GB/newsroom/introducing-new-driver-hours-policy/) in Uber). Moreover, Uber prevents driving beyond 12 hours in a row. Therefore, remaining drivers are forced to stop once that threshold is reached.

Moreover, the *update drivers* phase manages the behavior of a free driver which completed their route: indeed, the SUMO simulator automatically removes a driver as soon as they reach the destination of the planned route. To avoid this from happening the simulator generate a new route for each driver in the net, whenever they are on the verge of concluding their route. The type of route generated by the simulator depends on the state of the driver: if the driver is free (i.e. `idle`, `responding` to a request, or `moving` from a TAZ to another TAZ), the driver does not have a new defined route at the end of the current one, therefore the simulator generates a random route within the current TAZ of the driver.

Please note that traffic follows a separate, much simpler logic. Since it does not have to satisfy requests of any kind in fact, the [state of a person](#person-states) only considers the route to be taken.


### 7. Update Rides

At each timestamp, the simulator updates the state of each ride in progress and the position of the corresponding drivers and customers. 

Moreover, the simulator updates the route of the drivers, according to their state. If the driver is in the `pickup` phase  (meaning they accepted a ride request and they are moving to the meeting point where the customer lies), when the driver  reaches the meeting point, the simulator set the route to the destination point (the [ride state](#ride-states), the [driver state](#driver-states) and the [customer state](#customer-state) change consequently from `pickup` to `on road`). 

Finally, if the driver is `on road` (i.e. moving with the customer to the destination point) at the end of the route,  the simulator generates a new random route with the same policy applied if the driver would be `idle` (indeed at the end of the ride, the driver state change from `on road` to `idle` again).

When a ride terminates, the customer state becomes `inactive` (they are removed from the simulator), and the ride state is set to `end` (i.e. completed).


### 8. Update Drivers Movements

At fixed timestamps of the simulation (defined by recurrent checkpoints), the simulator computes the probability, for each free driver, to move from their current TAZ to any other TAZ of the net, if the economic conditions of the ride requests (determined by the value of the [surge multiplier](#surge-multiplier)) are better in those areas of the net. If the free driver decides to move to another TAZ, the simulator set a new route with an edge of the other TAZ as destination.


### 9. Perform Scenario Events

Some [*scenario*](#scenario) can have events that can be triggered at specific timestamps of the simulation. At each timestamp, the simulator checks if an event must be triggered, and in that case it executes the logic of the scenario event (the events can be easily extended, implementing the corresponding logic).


### 10. Update TAZs

In this phase the simulator saves the statistics, related to drivers, customers, and rides, for each TAZ.

Moreover, at fixed timestamps of the simulation (defined by recurrent checkpoints), the simulator updates the [surge multiplier](#surge-multiplier) for each TAZ, considering the ratio between the drivers (the offer) and the active customers (the demand).


### Environment Variables

The environment file (.env) is created after running the init_env.py script and can be directly modified accordingly to the user needs. It is composed of different variables on which the operation and result of the simulator depends, such as the city to simulate (actually only test and San Francisco), the time of the simulation and other support variables. Further details are provided [here](README.md).


### Generation Plan 

The generation plan is computed before the actual simulation, within the [MobilityGenerator](/src/setup/MobilityGenerator.py) file. At each timestamp, drivers, customers, and persons, are generated according to a probability which depends on real (San Francisco) data about rides and traffic, for each hour and TAZ. Furthermore, in the case of pre-runtime actionable scenarios (such as driver strike, which assumes a substantial decrease in the number of drivers), these are implemented directly at this stage, acting on the generation number.

The number of drivers is given by the number of real hourly requests and a driver ratio parameter. If the value is:
* equal to `1`, the number of drivers and customers generated during the simulation will be the same (i.e. equal to the average number of pickups for each TAZ of the net).
* less than `1`, the number of drivers per TAZ will be less than the number of customers generated on average in the same TAZ (the formula is `mean_TAZ_pickups_number * driver_ratio`).
* greater than `1`, the number of drivers per TAZ will be higher than the number of customers generated on average in the same TAZ (the formula is `mean_TAZ_pickups_number * driver_ratio`).


### Surge Multiplier

The surge multiplier is a parameter for computing the price of rides, which depends on multiple factors, such as weather and the relationship between supply and demand. However, Uber does not provide the algorithm for calculating the surge multiplier, so this is calculated empirically through a formula that takes into account the number of active drivers and customers, and the number of requests not accepted.

Let:
- `num_active_cust` be the number of active customers.
- `num_active_driv` be the number of active drivers.
- `num_not_served` be the number of not served customers.
- `incr` be the calculated increment.

Then:

~~~python
try:
    driv_per_cust = num_active_driv/num_active_cust
    if(driv_per_cust < 1):
        incr = ((1 - driv_per_cust)/10) + num_not_served/4
    elif(driv_per_cust == 1):
        incr = num_not_served/4
    else:
        incr = -((driv_per_cust - 1)/100) + num_not_served/4
    return incr
except:
    return num_not_served/4
~~~

The surge multiplier is always between 1 and 5.


### Customer and Driver Personality

At present, the personalities of drivers and customers are decided arbitrarily, just following some guidelines we found on several studies (you can find the references in the [parameters](/doc/parameters/) folder), while trying to follow a distribution as realistic as possible. Specifically, both drivers and customers may have 3 different personalities with the following probabilities:

Drivers:
* hurry (21%).
* greedy (24%).
* normal (55%).

Customers:
* hurry (37%).
* greedy (18%).
* normal (45%).


These personalities reflect driver and customer behavior, based on the surge multiplier. For example, a greedy driver/customer is more willing to make a run in case of an advantageous surge multiplier (high for the driver, and low for the customer), while a hurry driver/customer will be more likely to accept unfavorable conditions.


### Scenario

By providing the relevant json file [here](src/setup/default_config/scenario) and implementing the logic within [MobilityGenerator](/src/setup/MobilityGenerator.py) or [Simulator](/src/setup/Simulator.py), new scenarios can be generated, in addition to those already provided ([here](README.md) you can find an overview of the scenarios already provided, while [here](doc/Parameters/) you can find details about implementation and parameters).


### Driver States

A driver can have one of the following states:

* `IDLE`: The driver is free and available for a ride, according to its personality.
* `RESPONDING`: The driver is responding to a ride request from a customer.
* `PICKUP`: The driver accepted a request and is now moving to the customer position to start the service.
* `ON_ROAD`: The driver picked up a customer and is now bringing him to the desired location.
* `MOVING`: The driver is moving to another TAZ because of a more profitable surge multiplier.
* `INACTIVE`: The driver ended its service after some rides, some time, or because of a non profitable surge multiplier, and is now off work.


### Customer States

Similarly, a customer can have one of the following states:

* `ACTIVE`: The customer is free and willing to request a ride.
* `PENDING`: The customer requested a ride and is now waiting for a response.
* `PICKUP`: A driver accepted the ride, so the customer is now waiting for the begin of the ride service.
* `ON_ROAD`: The customer is going to its desired location, with the related driver.
* `INACTIVE`: The customer ended the ride or is no longer available.


### Person States

A person can have one of the following states:

* `ACTIVE`: The person spawned inside a specific TAZ and is waiting for a route to be assigned.
* `TRAVELING`: The route has been assigned and the person is now moving to complete it.
* `INACTIVE`: The person completed the route.


### Ride States

Each ride can have one of the following states:

* `REQUESTED`: The ride has been requested by a customer.
* `PENDING`: The ride of the customer is in queue, waiting for a driver to accept it.
* `PICKUP`: The ride has been accepted, by the driver, so now the customer is waiting for the pick up.
* `ON_ROAD`: The customer is going to the desired location with the related driver.
* `END`: The ride is over, the customer has been served.
* `CANCELED`: The ride has been canceled by the user for some reason (e.g. non profitable surge multiplier).
* `NOT_SERVED`: The ride has not been served by the driver for some reason (e.g. progressive greedy scenario).
* `SIMULATION_ERROR`: The ride has not been completed because of an external simulation error.


## San Francisco Net

Downloading the map of San Francisco from OpenStreetMap, one unfortunately realizes its limited usability. In fact, the map is too large to be automatically adjusted and made usable by SUMO's logic. Using flags during automatic map conversion (see [here](net_config/osmBuild.py)) helps but is not enough to solve the import problems. 

Therefore, extensive manual work on NetEdit was required to manually fix the problems by modifying roads and parameters individually. In case the programmer wants to add another city, he will have to take this factor into account, and the additional work required.


## Lyft

In order to make the simulator even more realistic, a competing Uber service called Lyft, which has already been present within the city of San Francisco for years, was implemented. The logic is the same as in the Uber simulator, except for the pricing and statistics calculation (separate).

To differentiate it from Uber, the calculation of the surge multiplier has been separated, while the final price is calculated using a Machine Learning algorithm (specifically, Random Forest), trained on the distances and surge multipliers of the city of Boston.

In order to simulate the current split between Uber and Lyft in San Francisco, the customer proceeds as follows:

* With a 75% probability, the customer selects Uber as their first choice, and Lyft with a 25% probability.

* Acceptance parameters are calculated based on customer and driver personalities and surge multiplier of the chosen service.

* If the ride is accepted, the chosen service behaves as described above.

* If the ride is not accepted, the statistics of the relevant provider are updated, and the user has the option to refer to the other provider.

* At this point, if the other provider accepts the run, the service begins as described above, otherwise the customer's run is not fulfilled and the relevant statistics are updated.


Please note that the final statistics computed in [this script](script/compute_indicators_performance.py) only takes into account Uber data, because the two provider are separated. However, since the logic of Lyft and how its statistics are computed are very similar to the case of Uber, it would be possible to visualize even Lyft data.