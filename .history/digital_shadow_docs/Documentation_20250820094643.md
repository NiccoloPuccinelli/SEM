# Documentation

## RH Digital Shadow

The current repository implements the backend logic of a ride-hailing digital shadow. The logic interacts with [SUMO](https://sumo.dlr.de/docs/index.html) (a popular traffic generator and simulator) through [TraCI](https://sumo.dlr.de/docs/TraCI/Interfacing_TraCI_from_Python.html), an API interface specifically developed for Python (you can find the documentation [here](https://sumo.dlr.de/pydoc/traci.html)).

The digital shadow is developed to run executions on arbitrary (realistic or fantasy) urban nets.

The net can be developed from scratch using [NetEdit](https://sumo.dlr.de/docs/Netedit/index.html) (included in [SUMO](https://sumo.dlr.de/docs/index.html)), or it can be [downloaded](https://sumo.dlr.de/docs/Networks/Import/OpenStreetMapDownload.html) and [imported](https://sumo.dlr.de/docs/Networks/Import/OpenStreetMap.html) from OpenStreetMap.

During the execution, drivers and passengers are generated according to a customizable logic (which we call [scenario](#scenarios)), emulating the demand and offer of rides within the net, in a given interval of time.

You can find the details about the parameters of the digital shadow [here](doc/).


## The Smart Human-centric Ecosystem (SHE)

The code within the digital shadow contains the logic of all SHE components. These, however, operate independently, interacting with each other implicitly. The main components of the SHE are:
* The city.
* Uber.
* Lyft.
* The traffic.
* The drivers.
* The passengers.

The ride-hailing digital-shadow includes three main components: environment, people, and ride-hailing services. 

The Environment subsystem is composed of a city and the traffic. The People subsystem can be instantiated into different roles, by setting actions and behavior. In our experiments we instantiated drivers and passengers. The Ride-hailing subsystem is a parametric module that can be instantiated into different service providers, by specifying base fare, service fee, cost per mile, cost per minute, maximum ride length, maximum driver search area, and maximum driver shift time. In our experiments we instantiated Uber and Lyft, the two competing ride-hailing systems widely available in San Francisco.


### City (Net)

A [net](src/model/Net.py) is a collection of *edges* and *nodes*, grouped in **Traffic Analytic Zones** (TAZs). The *edges* and *nodes* represent the roads and the crossroads, while the TAZs represent the areas in which the net is divided.

The digital shadow relies on three different layers of the net that provide three different level of details and information:
* **Mobility layer**: provides the ride-hail vehicle activity (mean number of pickups and dropoffs requests in a TAZ per hour).
* **Analytics layer**: specifies the mean travel times (and the std. dev.) from each TAZ to the other TAZs of the net.
* **Boundary layer**: defines the layout of the TAZs of the net for the execution.

The three layers can have three different TAZs layouts. Indeed, the information related to the mobility and the travel times could derive from different sources and authorities. 

For example, in the net provided in the repo (in the `data` folder), we acquired the layers for the city of San Francisco (`data/sf`) from different authorities: the mobility layers from the [San Francisco County Transportation Authority (SFCTA)](https://www.sfcta.org/tools-data/maps); the analytics layers from the [Uber Movement](https://movement.uber.com/?lang=en-US) (unfortunately no longer available); the boundary layer from the [EarthWorks Stanford Project](https://earthworks.stanford.edu/catalog/stanford-df986nv4623). The three layers come from three different and independent authorities that published their data using three different TAZs layouts.

The digital shadow is able to manage different layouts from the three levels, and use the boundary layer for defining the TAZs layout of the execution. The connecting ring between the three layers is represented by the edges of the net. Indeed, for each layer, each edge belongs to one TAZ of the net. Therefore, given an edge it is possible to map it on the three different layers uniquely and acquire the corresponding information from each of the layer.

Downloading the map of San Francisco from [OpenStreetMap](https://sumo.dlr.de/docs/Networks/Import/OpenStreetMapDownload.html), one unfortunately realizes its limited usability. In fact, the map is too large to be automatically adjusted and made usable by [SUMO](https://sumo.dlr.de/docs/index.html)'s logic. Using flags during automatic map conversion (see [here](net_config/osmBuild.py)) helps but is not enough to solve the import problems. 

Therefore, extensive manual work on [NetEdit](https://sumo.dlr.de/docs/Netedit/index.html) was required to manually fix the problems by modifying roads and parameters individually. In case the programmer wants to add another city, he will have to take this factor into account, and the additional work required.


### Traffic

The traffic module generates cars according to the average hourly traffic of the city, and assigns a route to each generated car. The cars exit the system at the end of their route.   

We leveraged (the average of) 5 consecutive workdays of [real traffic hourly data](https://data.sfgov.org/Transportation/SFMTA-Transit-Vehicle-Location-History-Current-Yea/x344-v6h6/about_data) from the city of San Francisco to perform a realistic execution of the traffic during the day. Similar to what happens to drivers without requests, a random route is generated for each person, in a way that simulates the real traffic distribution.

Based on publicly available data, a specific number of cars are generated each hour and assigned predetermined routes. These entities are not required to manage user requests or perform tasks beyond their assigned routes, and they exit the system upon completion of their routes. 


### Drivers

The drivers module adds drivers to the digital shadow with distribution of new drivers and end of the shifts that we obtained from both the data of the [Transportation Authority of San Francisco](https://www.sfcta.org/projects/tncs-today-2017) and [Uber Movement](https://www.uber.com/ch/en/business/movement-decommissioning/). Uber Movement was discontinued in October 2023, in our experiments we use the data that we gathered prior up to the closure of the website, and that are available [in this folder](data/sf/net/taz/boundary/uber).

Each driver is affiliated to a ride-hailing service (either Uber or Lyft in our experiments), and moves on a route within the city (San Francisco). The digital shadow dynamically adjusts the initial route assigned to the driver, to model the reactions of the driver to the distribution of ride requests. Once the driver accepts a ride request, the digital shadow modifies the route to reach the pickup location.  When the driver reaches the pickup location, the digital shadow updates the ride to the destination of the passenger. The digital shadow monitors time, speed, and distance traveled, and computes the offered fare at the time of the request and the final fare at the conclusion of the ride, by including any surge pricing. The drivers either accept or decline requests depending on both the offered fare (that depends the value of the surge multiplier) and the personality of the driver. 

The digital shadow uses a simple model of the drivers’ personality that we defined according to different studies and the data about drivers from the [Transportation Authority of Chicago](https://data.cityofchicago.org/Transportation/Transportation-Network-Providers-Drivers/j6wf-834c/about_data). The model abstracts the personality of the drivers with the probability of accepting a ride request depending on the  revenue for the drivers. In our digital shadow, we define three different personalities for drivers: 
* Greedy: high probability of drivers accepting requests when the surge multiplier is high;
* Hurry: high probability of drivers accepting rides even when the surge multiplier is low;
* Normal: moderate probability of accepting rides, in between greedy and hurry.

In our experiments we use a ’normal’ distribution of 21% ‘hurry’ drivers, 24% ‘greedy’ drivers and  55% ‘normal’ drivers.

### Passengers

The passengers module adds passengers to the digital shadow, with distribution of new requests that we obtained from both the data of the Transportation Authority of San Francisco and Uber Movement, as in the case of drivers.

Each passenger enters the system with a request for a ride to a ride-hailing provider (either Uber or Lyft, in our experiments). Passengers’ requests are distributed among Uber and Lyft according to the [current market share](https://secondmeasure.com/datapoints/rideshare-industry-overview/), 75\% for Uber as first choice, and 25\% for Lyft. 

After the initial request, passengers wait for an offer, and either accept the offer (and complete the ride) or decline the offer and either forward the same request to the other ride-hailing provider or exit the system. If the ride is accepted by the driver of the corresponding ride service, the ride is marked as in progress, until its conclusion. If the ride is not accepted, the statistics of the relevant provider are updated, and the user has the option to refer to the other provider. At this point, if the other provider accepts the run, the service begins as described above, otherwise the passenger's run is not fulfilled. 

The passengers either accept or decline offers depending on personality and fare (specifically, depending on the value of the surge multiplier). Similarly to the drivers, the digital shadow abstracts passengers’ personality with the probability of accepting/declining an offer, and considers three types of personalities:
* Greedy: high probability of passengers accepting rides when the surge multiplier is low;
* Hurry: high probability of passengers accepting rides even when the surge multiplier is unfavorable (high);
* Normal: moderate probability of passengers accepting rides, in between the greedy and hurry ones.


### Uber

The Uber module instantiates the parameters of the Ride-hailing module with the data of Uber that are publicly available on different sources.

Uber [publicly shares](https://help.uber.com/riders/article/how-are-fares-calculated-/?nodeId=d2d43bbc-f4bb-4882-b8bb-4bd8acf03a9d) the factors that determine the pricing algorithm, which include the base fare, the service time, the miles driven, and the surge multiplier. The surge multiplier is a factor that adjusts the final price based on several dynamic factors, such as the time of day, weather conditions, the ratio between drivers and passengers, and traffic conditions. We implemented the pricing algorithm by referring to the information that is [publicly available](https://www.vatech.com/manuals/379746#). 

Further details on how the surge multiplier operates can be found under the section [Surge Multiplier](#surge-multiplier).


### Lyft

The Lyft’s internals are not publicly available. We implemented the Lyft module with a Random Forest model that we trained on a dataset that is publicly available at [Kaggle](https://www.kaggle.com/datasets/ravi72munde/uber-lyft-cab-prices) and that includes data about prices, distances and surge multiplier of the city of Boston, an urban area with characteristics comparable with San Francisco.


## Surge Multiplier

The surge multiplier is a parameter for computing the price of rides, which depends on multiple factors, such as weather and the relationship between supply and demand. Neither Uber or Lyft provide the algorithm for calculating the surge multiplier. However, the specification of its functioning is public, and common to both ride-hailing services. For this reason, the surge multiplier is calculated empirically through a formula that takes into account the number of active drivers and passengers, and the number of requests not accepted, by mirroring (some of) the real specifications given by the ride-hailing services.

Let:
- `num_active_cust` be the number of active passengers.
- `num_active_driv` be the number of active drivers.
- `num_not_served` be the number of not served passengers.
- `incr` be the calculated increment.

Then:

~~~python
    try:
        driv_per_cust = num_active_driv/num_active_cust
        if(driv_per_cust < 1):
            incr = ((1 - driv_per_cust)/10) + num_not_served/3
        elif(driv_per_cust == 1):
            incr = num_not_served/3
        else:
            incr = -((driv_per_cust - 1)/100) + num_not_served/3
        return incr
    except:
        return num_not_served/3
~~~

The surge multiplier ranges between 1 and 5.


## Dynamic greediness

In order to simulate human behavior realistically, we implemented a dynamic greediness system based on driver availability and surge multiplier. By means of the formula explained in the paper, greedy behavior is simulated constantly by going to change the drivers' ride acceptance rates. The latter depends on the ratio of pending passengers to the number of available drivers, simulating an increase in greediness in abnormal situations where available drivers decrease (e.g., due to an unexpected spike in requests). Drivers, in these situations, are more likely to systematically reject new requests in order to raise prices, controlled by the surge multiplier. However, the passenger-driver relationship is adjusted by the surge multiplier, simulating a price threshold above which drivers, however greedy, still accept profitable requests.


## Execution of the Digital Shadow

The core method of the [RH-Digital-Shadow](src/controller/Simulator.py) is the public method `run` that executes the life-cycle of a given scenario, for each timestamp of the execution.

The execution lasts for a given period of time, determined by two variables (`BEGIN` and`END`) in the environment file `.env` (the detailed content of the environment file is described [later](#environment-variables)).

The time of the execution is beaten by a [SUMO](https://sumo.dlr.de/docs/index.html) configuration variable `step-length`. By default, each cycle of the execution corresponds to `1` second in the real life (`step-length = 1`).

At each execution cycle, the digital shadow performs the following operations (in order):


### 1. Drivers, passengers and Persons generation

The digital shadow generates the [drivers](src/model/Driver.py) (Uber and Lyft), the [passengers](src/model/Customer.py) and the [traffic](src/model/Person.py) that are planned to be inserted in the net at a given timestamp of the execution (the [generation plan](#generation-plan) is created before calling the `run` method).


### 2. Ride requests generation

The digital shadow generates a [ride](src/model/Ride.py) request for each new passenger inserted in the system. In the current version of the digital shadow, at each timestamp the requests are generated with 80% of probability, simulating a small degree of hesitation before to performing the request. If the requests are not generated at the given timestamp, the digital shadow collects the passengers without a request yet, and it retries to generate them at the following timestamp.


### 3. Pending Requests Processing

For each ride request, the corresponding passenger accepts or rejects the offer proposed by the [provider](src/model/Provider.py), given the current [surge multiplier](#surge-multiplier) in the TAZ in which the passenger lies. If the passenger accepts the request, the digital shadow processes the pending ride request, searching for nearby driver candidates that can accept the ride request and accomplish it. Otherwise, it discards the request and the passenger is removed from the system. 


### 4. Pending Requests Management

At each timestamp, the digital shadow updates the status of each ride request already processed, through the support of the [provider](src/model/Provider.py). The provider selects the next candidate in the list (sorted by distance), forwards the request to the driver, and manages the requests according to the response of the selected driver candidate. The processing of a ride request can last several timestamps: given a driver candidate, the driver replies within 15 timestamps (the response time is a random value between 4 and 15 timestamps). The driver accepts or rejects the ride according to his [personality](#drivers) and the value of the [surge multiplier](#surge-multiplier) within the TAZ of the request. If the driver rejects the request, the ride request is forwarded to next driver in the candidate list (if the list is empty, the ride is marked as `not served`, and the passenger is removed from the net). Otherwise, if the driver accepts the ride request, the digital shadow associates the passenger to the driver, and the ride starts.


### 5. Update Drivers

At each timestamp, the digital shadow updates the position of each free driver (i.e., not involved in a ride) in the net. The free states of a driver are: `idle`, `responding`, or `moving` (more details in the [driver states section](#driver-states))

In particular, if the driver is `idle` (i.e., waiting for request) the digital shadow applies a policy to decide if the driver stops to work (and has to be removed from the net) or it continues to work. 

There is a stop work policy related to time. In fact, the more time passes, the greater the probability that, at each timestamp, each driver will stop working (up to a maximum of 3% at each timestamp after 4 hours of work, that is the [average work daily time](https://www.uber.com/en-GB/newsroom/introducing-new-driver-hours-policy/) in Uber). Moreover, Uber prevents driving beyond 12 hours in a row. Therefore, remaining drivers are forced to stop once that threshold is reached.

The *update drivers* phase also manages the behavior of a free driver which completed its route: indeed, the [SUMO](https://sumo.dlr.de/docs/index.html) digital shadow automatically removes a driver as soon as reaching the destination of the planned route. To avoid this, the digital shadow generates a new route for each driver in the net, whenever they are on the verge of concluding their route. The type of route generated by the digital shadow depends on the state of the driver: if the driver is free (i.e. `idle`, `responding` to a request, or `moving` from a TAZ to another TAZ), the driver does not have a new defined route at the end of the current one, therefore the digital shadow generates a random route within the current TAZ of the driver.

Please note that traffic follows a separate, much simpler logic. Since it does not have to satisfy requests of any kind in fact, the [state of a traffic car](#person-states) only considers the route to be taken.


### 6. Update Rides

At each timestamp, the digital shadow updates the state of each ride in progress and the position of the corresponding drivers and passengers. 

If the driver is in the `pickup` phase (ride request accepted and moving to the meeting point where the passenger lies), when the driver reaches the meeting point, the digital shadow sets the route to the destination point (i.e., the [ride state](#ride-states), the [driver state](#driver-states) and the [passenger state](#passenger-states) change from `pickup` to `on road`). 

Finally, if the driver is `on road` (i.e., moving with the passenger to the destination point), at the end of the route  the digital shadow generates a new random route with the same policy applied if the driver would be `idle` (indeed at the end of the ride, the driver state change from `on road` to `idle` again).

When a ride terminates, the passenger state becomes `inactive` (removed from the digital shadow), and the ride state is set to `end` (i.e., completed).


### 7. Update Drivers Movements

At fixed timestamps of the execution (defined by recurrent checkpoints), the digital shadow computes the probability, for each free driver, to move from their current TAZ to any other TAZ of the net, if the economic conditions of the ride requests (determined by the value of the [surge multiplier](#surge-multiplier)) are better in those areas of the net. If the free driver decides to move to another TAZ, the digital shadow sets a new route with an edge of the other TAZ as destination.


### 8. Perform Dynamic Greediness

At this point, using the data on available drivers, pending requests and surge multiplier, the dynamic greediness value is calculated for each minute using the formula explained in the paper and [above](#dynamic greediness). For each TAZ, the acceptance rate of each driver is then updated according to the calculated greediness value.


### 9. Perform Scenario Events

Some [scenario](#scenarios) can have events that can be triggered at specific timestamps of the execution. At each timestamp, the digital shadow checks if an event must be triggered, and in that case it executes the logic of the scenario event (the events can be easily extended, implementing the corresponding logic [here](data/sf/scenario)).


### 10. Update TAZs

In this phase the digital shadow updates the [surge multiplier](#surge-multiplier) and saves the statistics, related to drivers, passengers, and rides, for each TAZ.


## Environment Variables

The environment file (`.env`) is created after running the `init_env.py` script and can be directly modified accordingly to the user needs. It is composed of different variables on which the operation and result of the digital shadow depends, such as the city (actually only San Francisco), the execution time and other support variables. Further details are provided in the [README](README.md).


## Generation Plan 

The generation plan is computed before the actual execution, within the [MobilityGenerator](src/setup/MobilityGenerator.py) file. At each timestamp, drivers, passengers, and traffic are generated according to a probability which depends on real (San Francisco) data about rides and traffic, for each hour and TAZ. Furthermore, in the case of pre-runtime actionable scenarios (such as driver strike, which assumes a substantial decrease in the number of drivers), these are implemented directly at this stage, acting on the generation number.


## Scenarios

By providing the relevant json file [here](/data/sf/scenario) and implementing the logic within [MobilityGenerator](src/setup/MobilityGenerator.py) or [Simulator](src/controller/Simulator.py), new scenarios can be generated, in addition to those already provided ([here](README.md) you can find an overview of the scenarios already provided, while [here](doc/) you can find details about implementation and parameters).


## Component states

### Driver States

A driver can have one of the following states:

* `IDLE`: The driver is free and available for a ride, according to its personality.
* `RESPONDING`: The driver is responding to a ride request from a passenger.
* `PICKUP`: The driver accepted a request and is now moving to the passenger position to start the service.
* `ON_ROAD`: The driver picked up a passenger and is now bringing him to the desired location.
* `MOVING`: The driver is moving to another TAZ because of a more profitable surge multiplier.
* `INACTIVE`: The driver ended its service after some rides, some time, or because of a non profitable surge multiplier, and is now off work.


### Passenger States

Similarly, a passenger can have one of the following states:

* `ACTIVE`: The passenger is free and willing to request a ride.
* `PENDING`: The passenger requested a ride and is now waiting for a response.
* `PICKUP`: A driver accepted the ride, so the passenger is now waiting for the begin of the ride service.
* `ON_ROAD`: The passenger is going to its desired location, with the related driver.
* `INACTIVE`: The passenger ended the ride or is no longer available.


### Person States

A person (i.e., a car belonging to the traffic module) can have one of the following states:

* `ACTIVE`: The person spawned inside a specific TAZ and is waiting for a route to be assigned.
* `TRAVELING`: The route has been assigned and the person is now moving to complete it.
* `INACTIVE`: The person completed the route.


### Ride States

Each ride can have one of the following states:

* `REQUESTED`: The ride has been requested by a passenger.
* `PENDING`: The ride of the passenger is in queue, waiting for a driver to accept it.
* `PICKUP`: The ride has been accepted, by the driver, so now the passenger is waiting for the pick up.
* `ON_ROAD`: The passenger is going to the desired location with the related driver.
* `END`: The ride is over, the passenger has been served.
* `CANCELED`: The ride has been canceled by the user for some reason (e.g. non profitable surge multiplier).
* `NOT_SERVED`: The ride has not been served by the driver for some reason (e.g. progressive greedy scenario).
* `SIMULATION_ERROR`: The ride has not been completed because of an external execution error.