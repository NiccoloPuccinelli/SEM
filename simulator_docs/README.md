# Ride-Sharing Digital Mirror

## 1. Introduction

The current repository constitutes the backend logic of a ride-sharing digital mirror written in Python. The logic interacts with [SUMO](https://sumo.dlr.de/docs/index.html) (a popular traffic generator and digital mirror) through [TraCI](https://sumo.dlr.de/docs/TraCI/Interfacing_TraCI_from_Python.html) an API interface specifically developed for Python (you can find the documentation [here](https://sumo.dlr.de/pydoc/traci.html)).

## 2. Documentation

The documentation of the digital mirror (the architecture, the life-cycle, the logic, and the main functionalities) are described [here](Documentation.md).

## 3. Requirements

### 3.1 SUMO Digital Mirror

The project exploits the functionalities of [SUMO](https://sumo.dlr.de/docs/index.html). [SUMO](https://sumo.dlr.de/docs/index.html) can be installed following the instructions provided in the official [installation guide](https://sumo.dlr.de/docs/Installing/index.html) (for Windows users there is an executable installer, while for macOS and Linux users it is necessary to use a command-line tool such as **Homebrew** and **apt-get**, respectively. Note that macOS users have to install and run [XQuartz](https://formulae.brew.sh/cask/xquartz#default) to run the Sumo-GUI). The installation process will install on the local machine **SUMO** and all the accessory tools to generate and import maps in Sumo. **Be sure to install the SUMO version 1.19.0 (Nov. 2023)**.

For **Linux users**, in case you are unable to install [SUMO](https://sumo.dlr.de/docs/index.html) version 1.19.0, please refer to the following [guide](https://sumo.dlr.de/docs/Installing/Linux_Build.html).

### 3.2 Python 3

The logic of the ride-sharing digital mirror is written in **Python 3**. Therefore, a stable version of Python 3 (for example, 3.6 or more) is necessary to run the digital mirror. Making several tests, we recommend **3.6 <= Python version <= 3.10**.

### 3.3 Requirements.txt

Other requirements are provided in the requirements.txt file. Follow the instructions to install them.

## The Data folder

The `data` folder is the core for the generation of the net, the scenario, and the mobility generation plan for the subsequent execution. It has the following structure:

    root
        |---- data
                |---- {city_name}
                        |---- [mobility]
                        |       |---- [{mobility_layer}]
                        |       |       |---- json
                        |       |               |---- {city_name}_{mobility_layer}_pickups_stats.json
                        |       |---- [{analytics_layer}]
                        |               |---- json
                        |               |---- {city_name}_{analytics_layer}_travel_time.json
                        |               |---- {city_name}_{analytics_layer}_travel_time_missing_couples.json
                        |---- net
                        |       |---- taz
                        |               |---- boundary
                        |               |       |---- {boundary_layer}
                        |               |       |       |---- [shape]
                        |               |       |       |       |---- {city_name}_{boundary_layer}_taz_boundary.cpg
                        |               |       |       |       |---- {city_name}_{boundary_layer}_taz_boundary.dbf
                        |               |       |       |       |---- {city_name}_{boundary_layer}_taz_boundary.prj
                        |               |       |       |       |---- {city_name}_{boundary_layer}_taz_boundary.shp
                        |               |       |       |       |---- {city_name}_{boundary_layer}_taz_boundary.shx
                        |               |       |       |       |---- {city_name}_{boundary_layer}_taz_boundary.xml
                        |               |       |       |---- [xml]
                        |               |       |               |---- {city_name}_{boundary_layer}_taz_poly.poi.xml
                        |               |       |---- [{analytics_layer}]
                        |               |       |       |---- [shape]
                        |               |       |       |       |---- {city_name}_{analytics_layer}_taz_boundary.cpg
                        |               |       |       |       |---- {city_name}_{analytics_layer}_taz_boundary.dbf
                        |               |       |       |       |---- {city_name}_{analytics_layer}_taz_boundary.prj
                        |               |       |       |       |---- {city_name}_{analytics_layer}_taz_boundary.shp
                        |               |       |       |       |---- {city_name}_{analytics_layer}_taz_boundary.shx
                        |               |       |       |       |---- {city_name}_{analytics_layer}_taz_boundary.xml
                        |               |       |       |---- [xml]
                        |               |       |               |---- {city_name}_{analytics_layer}_taz_poly.poi.xml
                        |               |       |---- [{mobility_layer}]
                        |               |               |---- [shape]
                        |               |               |       |---- {city_name}_{mobility_layer}_taz_boundary.cpg
                        |               |               |       |---- {city_name}_{mobility_layer}_taz_boundary.dbf
                        |               |               |       |---- {city_name}_{mobility_layer}_taz_boundary.prj
                        |               |               |       |---- {city_name}_{mobility_layer}_taz_boundary.shp
                        |               |               |       |---- {city_name}_{mobility_layer}_taz_boundary.shx
                        |               |               |       |---- {city_name}_{mobility_layer}_taz_boundary.xml
                        |               |               |---- [xml]
                        |               |                       |---- {city_name}_{mobility_layer}_taz_poly.poi.xml
                        |               |---- centroids
                        |                       |---- {boundary_layer}
                        |                       |       |---- json
                        |                       |               |---- {city_name}_{boundary_layer}_taz_centroids.json
                        |                       |---- [{mobility_layer}]
                        |                       |       |---- json
                        |                       |               |---- {city_name}_{mobility_layer}_taz_centroids.json
                        |                       |---- [{analytics_layer}]
                        |                               |---- json
                        |                                       |---- {city_name}_{analytics_layer}_taz_centroids.json
                        |---- scenario
                                |---- {scenario_name}(1..*)
                                        |---- json
                                                |---- {city_name}_{scenario_name}_config.json

    Legend:
        {} - parametric value (the content is the parameter)
        [] - optional value

For each generated net, a corresponding sub-folder must be created under the main directory `data`. The label `city_name`, in the above folder scheme, represents a parameter that identifies the name of a net (in the current version, two net examples are available: `city`, that represents a fake city with a manhattan grid layout, and `sf`, that represents the real city of San Francisco). 

Each `net` is composed of three different layers: the `boundary` layer, the `mobility` layer, and the `analytics` layer (more details in the full [documentation](Documentation.md)). The `net` subfolder provides the information related to the TAZs layout of each layer (`boundary` and `centroids`). 

In particular, the `boundary` sub-folder supplies the profile of each TAZ. If the layout is provided in the form of shape files (whitin the `shape` subfolder), the layer must be converted in a format readable to [SUMO](https://sumo.dlr.de/docs/index.html). Therefore, the `POLY_CONVERSION` variable must bet set to `True` (otherwise `False`). The poly-conversion transforms the file in an XML format with a specific [structure](https://sumo.dlr.de/docs/polyconvert.html) (see `data/city/net/taz/boundary/test/xml/city_test_taz_poly.poi.xml`, `data/sf/net/taz/boundary/sfcta/xml/sf_sfcta_taz_poly.poi.xml`, `data/sf/net/taz/boundary/stanford/xml/sf_stanford_taz_poly.poi.xml`, or `data/sf/net/taz/boundary/uber/xml/sf_uber_taz_poly.poi.xml` as examples). Instead, if the layout is built with [NetEdit](https://sumo.dlr.de/docs/Netedit/index.html), the file exported is already in the right format, and the `POLY_CONVERSION` environment variable must be set to `False`. The content of the file must reflect the following pattern:

    <additional xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://sumo.dlr.de/xsd/additional_file.xsd">
        <!-- Shapes -->
        <poly id="taz_id_1" color="red" fill="0" layer="0.00" shape="float,float,float,..."/>
        <poly id="taz_id_2" color="red" fill="0" layer="0.00" shape="float,float,float,..."/>
        ...
    </additional>
    
where the parameters `id` and `shape` are mandatory (the `shape` is a string of float numbers which represent the vertices of a polygon), while the others are optional.

The `centroids` sub-folder provides the distance from the centroid of each TAZ to the centroids of all the other TAZs, grouped  in 4 categories (`short`, `normal`, `long`, `extreme`), according to the distance. The generation of this file is left to the developer. The structure of the file should be like the following:

    {
        "taz_id_1": {
            "short": [
                "taz_id_1",
                "taz_id_2"
            ],
            "normal": [
                "taz_id_3"
            ],
            "long": [
                "taz_id_4"
            ],
            "extreme": [
                "taz_id_5",
                "taz_id_6"
            ]
        },
        "taz_id_2": {
            "short": [
                "taz_id_1",
                "taz_id_2"
            ],
            "normal": [
                "taz_id_3",
                "taz_id_4"
            ],
            "long": [
                "taz_id_5",
                "taz_id_6"
            ],
            "extreme": []
        },
        ...
    }

Some concrete examples are provided in: `data/city/net/taz/centroids/test/json/city_test_taz_centroids.json`, `data/sf/net/taz/centroids/sfcta/json/sf_sfcta_taz_centroids.json`, `data/sf/net/taz/centroids/stanford/json/sf_stanford_taz_centroids.json`, `data/sf/net/taz/centroids/uber/json/sf_uber_taz_centroids.json`. In the case of the city net of san francisco `sf`, the centroids have been generated through the python notebooks that the developer can find in the repo in the directory `notebook/pre/net/*` (note that the geojson file imported from the notebooks has been generated  from the shape file previously presented, using [QGIS](https://www.qgis.org/it/site/)).

The sub-folder `mobility` provides information about the mobility of the net: the folder is optional. If no file about the mobility are provided, the `TEST_NET` environment variable must be set to `True`. In this case the digital mirror will generate a random mobility before starting the execution. The mobility of the net is represented by two piece of information:

* The mean number of pickups and dropoffs requests in each TAZ per hour, saved in `data/{city_name}/mobility/{mobility_layer}/json/{city_name}_{mobility_layer}_pickups_stats.json`
* The travel times from each source TAZ to all the others destination TAZs, saved in `data/{city_name}/mobility/{analytics_layer}/json/{city_name}_{analytics_layer}_travel_time.json`

The `data/{city_name}/mobility/{analytics_layer}/json/{city_name}_{analytics_layer}_travel_time_missing_couples.json` file provides the information about possible travel times couples missing. If the `TEST_NET` environment variable is set to `False` the file must be provided in any case (even if there are not missing couples) and the file must have the following structure:

    {
        "source_taz_id_1": [
            "missing_taz_id_1",
            "missing_taz_id_2",
        ],
        "source_taz_id_2": [
            "missing_taz_id_2",
            "missing_taz_id_3",
            "missing_taz_id_4"
        ],
        "source_taz_id_3": [],   # empty missing couples
        ...
    }

In `data/city/mobility/test/json/*` the developer can find an example of autogenerated mobility, when the `TEST_NET` environment variable is set to `True` (all the files are grouped on the same folder because in the `city` example, both the `boundary`, `mobility`, and `analytics` layers refers to the same layout, named `test`. This is a configuration accepted by the digital mirror, where the three layers derive from the same layout).

Instead, in `data/sf/mobility/*` the developer can find an example where the mobility has been generated through the python notebooks in `notebook/pre/mobility/*`, starting from the open data acquired from [Uber Movement](https://movement.uber.com/?lang=en-US) and the [SFCTA](https://www.sfcta.org/) authorities.

Unfortunately, in October 2023 Uber decided to close Uber Movement, so a data update is not currently possible.

Finally, the `scenario` sub-folder contains at least one scenario that the digital mirror can simulate (the digital mirror can run one scenario at a time, set the `SCENARIO` environment variable). The scenario is provided through a configuration file, with the following structure:

    {
        "mobility_intervals":[
            [
                begin_timestamp_1,
                end_timestamp_1
            ],
            [
                begin_timestamp_2,
                end_timestamp_2
            ],
            ...
        ],
       "mobility_tazs":[
            [
                "taz_id_1",
                # additional information
            ],
            [
                "taz_id_4",
                # additional information
            ],
            ...
       ],
       "simulation_intervals":[
            [
                begin_timestamp_1,
                end_timestamp_1
            ],
            [
                begin_timestamp_2,
                end_timestamp_2
            ],
            ...
       ],
       "simulation_tazs":[
            [
                "taz_id_1",
                # additional information
            ],
            [
                "taz_id_4",
                # additional information
            ],
            ...
       ],
       # additional information
}

The scenario configuration file is composed of 4 main lists (+ additional information): 
    * `mobility_intervals`,
    * `mobility_tazs`,
    * `simulation_intervals`,
    * `simulation_tazs`

The `mobility_intervals` and the `simulation_intervals` are lists of tuples, which indicates the begin timestamp of an event (first element of the tuple), and the end timestamp of the event (second element of the tuple). An empty list means there are no events.

The `mobility_tazs` and the `simulation_tazs` instead contain the list of the TAZs involved in the events. For each element in the list, additional information can be provided, depending on the specific scenario. If the list is empty, all the TAZs are considered to be involved in the corresponding events.

The difference between the `mobility` and the `simulation` lists refers to the timing in which the events are processed: the mobility events are generated during the generation of the mobility.

In the demo made available with the repository, 6 scenarios have been defined:

* `normal`: Replicates a scenario without any abnormal or dangerous event.
* `underground failure`: A sudden alarm in an underground station causes the evacuation of the station with an abrupt and chaotic explosion of ride requests in the area. The amount of new requests depends on the crowd in the station and the duration of the closure of the station. We implement the immediate surge in passenger volume, as a 100% increase in ride requests and a 50% increment of traffic in six contiguous high-traffic areas in the city center, for 40 minutes after the alarm.
* `flash mob`: An unexpected flash mob blocks the city center of the city with effects on the neighbor TAZs. The traffic worsen, and both pickup and drop-off intervals increase. We implement the flash mob with a 90%  decrease of the average speed in the streets of the city center (directly affected by the flash mob), and an 80% decrease in the streets of the neighbor TAZs (indirectly affected by the flash mob). 
* `driver strike`: A sudden wildcat strike of drivers dramatically reduces the availability of drivers. We implement a wildcat strike with a decrease of 40% drivers who enter the system after the beginning of the strike, and an increase of 60% drivers who terminate the workshift for 30 minutes after the beginning of the strike.
* `long rides`: We implement the unusual length of the ride requests by changing the distribution of the length of the rides requests from $\langle 36\%, 22\%, 18\%, 24\% \rangle$ in normal conditions to $\langle 5\%, 15\%, 30\%, 50\% \rangle$ in long rides conditions for $\langle Short, Normal, Long, Extreme \rangle$ lengths of ride requests.
* `progressive greedy`: A sudden increase of ‘greedy drivers’, who decline ride requests also with standard fares, when perceiving an increasing number of ride requests, by following the experience that both Uber and Lyft increase fares when the number of pending requests increases. We implement the unusual increment of greediness by (i) changing the distribution of new drivers who enter the system from $\langle 21\%, 55\%, 24\%\rangle$ in normal conditions  to $\langle 5\%, 15\%, 80\% \rangle$ in greedy drivers conditions for $\langle hurry, normal, greedy \rangle$ drivers, and (ii) dynamically recomputing the drivers' ride acceptance rate by subtracting the Greediness value that we compute as explained [here](Documentation.md) and in the formula in the paper.
* Each scenario (except of course `normal` and `progressive_greedy`) can be run also in its ‘greedy‘ version, by simply adding the string `_greedy` at the end of the scenario name, when [initializing](#Environment variables) the digital mirror.


The developer can find the details of the configuration in the `data/city/scenario/*` and `data/sf/scenario/*` folders. The scenarios can be extended, adding new scenario, but the developer must write the logic of the scenario. Indeed, in addition to the configuration file described above, for each scenario, there is a corresponding logic developed in the `src/scenario/*` folder. The developer must follow the same implementation rules and patterns to extend the scenarios and add new ones.

## 4. Digital mirror initialization

The digital mirror is developed to run SES executions on arbitrary (real or fantasy) urban nets. To run the digital mirror it is necessary to initialize it:

1. Set SUMO_HOME and install the requirements.
2. Setting up the environment variables.
3. Grant permissions to run scripts.
4. Processing the net.
5. Generating the scenario.
6. Generating the mobility of the simulation.

(The order in which the operations presented in the list are performed is relevant, because the following operations depends on files generated from the previous ones).

### 4.1 SUMO_HOME and requirements

First, set the SUMO_HOME variable so that it is visible to the digital mirror. To do this, follow these steps in the terminal:

macOS:
    In the terminal write `open ~/.zshrc`.
    In the opened file place `export SUMO_HOME="/opt/homebrew/sumo/share/sumo"` and save.
    In the terminal write `source ~/.zshrc`.

Linux:
    Go to `/home/YOUR_NAME/`.
    Open `.bashrc` with a text editor (you may have to enable showing hidden files in your file explorer).
    In the opened file place `export SUMO_HOME="/your/path/to/sumo/"` and save.
    Reboot your computer (alternatively, log out of your account and log in again).

This will permanently save the variable SUMO_HOME in the correct location. You can run the following command to check the right position of SUMO_HOME:

    echo $SUMO_HOME

To install the requirements run: 

    pip install -r requirements.txt

### 4.2 Environment variables

The environment variables are defined in a `.env` file. To generate the file there are two ways: (i) writing manually the file, or (ii) running a quick python program to generate it step by step.

For the second approach, run the command:

    python script/init_env.py

The CLI program will guide the developer in generating the `.env` file.

The `.env` file must contain the following environment variables:

    CITY                = [ Name of the (real or fantasy) net ]
    LAYER_BOUNDARY      = [ Name of the boundary layer ]
    LAYER_MOBILITY      = [ Name of the mobility layer ]
    LAYER_ANALYTICS     = [ Name of the analytics layer ]
    NET_SUMO            = [ Name of the sumo net ]
    SCENARIO            = [ Scenario name ]
    BEGIN_HOUR          = [ Hour start simulation ]
    END_HOUR            = [ Hour end simulation ]
    DRIVER_SUPPORT      = [ Additional number of drivers generated per TAZ at the beginning of the simulation ]
    POLY_CONVERSION     = [ True (Y) if the input net is a shape file and must by converted to a representation accepted by sumo ]
    TEST_NET            = [ True (Y) if the net does not have mobility and analytics data available ]
    ADVANCE_DISTANCE    = [ If set to True (Y), all the distance between all the couples of edges in the net are computed during the processing of the net ]
    DEFAULT_ROUTES      = [ If set to True (Y), the digital mirror computes a route for each edge in each TAZ, with each other edge in the TAZ as destination ]
    
The `city` name is an identifier for the net. For each net generated, a corresponding subfolder must be created in the main directory `data`. The name of this subfolder must have the same name of the `CITY` environment variable.

The three environment variables `LAYER_BOUNDARY`, `LAYER_MOBILITY`, `LAYER_ANALYTICS` define the corresponding identifiers of the three layers of the net (more details in the documentation [here](Documentation.md)).

The `DRIVER_SUPPORT` generates additional drivers at the beginning of the simulation, to decrease the probability to have customers requests at the beginning of the simulation, without drivers active in the net yet. As an example, if the `DRIVER_SUPPORT` is equal to `n` the digital mirror will generate `n` drivers (from `0` to `10`) in the first timestamp of the simulation, for each TAZ of the net, if the pickup value in the begin hour of each specific TAZ is greater than 30.

The `POLY_CONVERSION` is a boolean environment variable. Its meaning is explained in the previous [section](#the-data-folder). It must be set to `True` if the layout of the net layers are provided in a shape file. The poly-conversion transforms the shape file in an XML file that can be read by [SUMO](https://sumo.dlr.de/docs/index.html).

The `TEST_NET` is another boolean environment variable explained in the previous [section](#the-data-folder). It must be set to `True` if the mobility of the net is not provided by the developer. In this case, the digital mirror will generate a random mobility for the simulation.

The `ADVANCE_DISTANCE` boolean environment variable computes the driving time and distance between each couples of edges (roads) in the net, if set to `TRUE`. This process will speed up the computation of the routes at simulation time (since the calculation will be performed before the simulation), but it will increase the time to process the net and configure the simulation. Moreover, this is an expensive memory operation. It is recommended to set this variable `True` only if the net is small.

The `DEFAULT_ROUTES` boolean environment variable computes a default route for each edge (road) of each TAZ, within the same TAZ (this means the destination edge belongs to the same TAZ). This process will speed up the definition of default routes to assign to `idle` drivers when they complete a route (for more details, see the [update drivers section](Documentation.md) in the full documentation) at simulation time (since the calculation will be performed before the simulation), but it will increase the time to process the net and configure the simulation. Moreover, this is an expensive memory operation. It is recommended to set this variable `True` only if the net is small.

A concrete example of `.env` file to test San Francisco is the following:

    CITY=sf
    LAYER_BOUNDARY=stanford
    LAYER_MOBILITY=sfcta
    LAYER_ANALYTICS=uber
    NET_SUMO=sf.net
    SCENARIO=driver_strike
    BEGIN_HOUR=0
    END_HOUR=3
    DRIVER_SUPPORT=1
    POLY_CONVERSION=Y
    TEST_NET=F
    ADVANCE_DISTANCE=F
    DEFAULT_ROUTES=F

Pay attention to the answers for `init_env.py`. In the current version of the digital mirror Y/N are required instead of True/False.

### 4.3 Grant permissions to run the scripts

Execute the following command to gain the permissions to run the scripts in the folder `script`:

    chmod -R a+x bash

It is sufficient to run this command only once, when the developer clone the repository on their local machine. It is not necessary to run it again if the developer change the net for the simulations.

### 4.4 Clean escape characters in .env

Our experience in different environments and operating systems arose the need to take care of possible escape characters introduced when generating the `.env` (for example `\r`). Those escape characters can lead to unexpected behaviors when the environment variables are processed. The following command takes care of removing the escape character `\r` potentially introduced in the `.env` file:

    ./bash/env_cleaning.sh

### 4.5 Process the net

Execute the following command to process the net files and generate the simulation nets:

    ./bash/net_setup.sh

The script will generate the net of the simulation, taking into account the values of the environment variables describe above. The simulation net will be created in the path:

    data/{city_name}/net/sim/json/net_simulator.json

The script will generate also a backup folder:

    data/{city_name}/net/backup/{boundary_layer}/{mobility_layer}/{analytics_layer}/sim/json/net_simulator.json

To save the net for future use, without recomputing it, when other nets will be used.

### 4.6 Generate the scenario

Execute the following command to run the script that generates the scenario, for the given simulation net:

    ./bash/scenario_setup.sh

The script will generate the planner of the scenario, given the scenario configuration file, in the path:

    ./data/{city_name}/scenario/{scenario_name}/json/{city_name}_planner.json

`NOTE`: If the mobility information is not provided by the developer (i.e. `TEST_NET` environment variable is set to `True`) the script will run internally another script (`./bash/fake_mobility_file_generation.sh`) to generate a random mobility configuration and the scenario, consequently.

### 4.7 Generate the mobility

Execute the following command to run the script that generates the scenario, for the given simulation net and the given scenario:
    
    ./bash/mobility_setup.sh

The script will generate the mobility, given the mobility configuration, provided by the developer or generated at the step `4.5`.

The script will generate the mobility for the simulation, in the path:

    ./data/{city_name}/mobility/sim/*

Moreover, it will create a backup of the mobility, in the path:

    ./data/{city_name}/scenario/{scenario_name}/backup/{BEGIN_TIMESTAMP}_{END_TIMESTAMP}/sim/*

That backup folder can be useful if you want to reproduce the same scenario, with the same mobility configuration, even after running other scenarios.

### 4.8 Run the scenario

#### Automatic execution

Execute the following command to run the script that simulate the scenario:
    
    ./bash/run.sh

The script will perform the simulation and will save the results within the path:

    ./data/{city_name}/output/scenario/*

#### Manual execution 

The developer can also run the simulation manually, executing the following command:

    python runner.py    [--nogui]

If the `--no-gui` option is set, the simulation will run in the terminal. This will speed up the simulation time. The simulation will start automatically.

Otherwise, the command will open a [SUMO](https://sumo.dlr.de/docs/index.html) Graphical User Interface ([SUMO](https://sumo.dlr.de/docs/index.html) GUI) and will upload the simulation net (we use the `city` demo net as example, in the following instructions).

`Note` - For **macOS** users it could be necessary to execute the **XQuartz** application before running the aforementioned command.

To start the simulation click on the play icon, as shown in the following image.

![Start Simulation](assets/sumoGUI_arrow.png)

To show the id of the drivers and the customers generated during the simulation, set the visibility of the person and vehicle ids, as shown in the following screenshots.

![Start Simulation](assets/options.png)
![Show Person Ids](assets/person_id_arrow.png)
![Show Vehicle Ids](assets/vehicle_id_arrow.png)

To speed up or slow down the simulation, modify the value of the delay options.

The simulation produces data related to KPIs of the rides performed in each TAZ of the net. 

The statistics are collected within the the folder defined by the following path:

    ./data/{city_name}/output/scenario/*

### 4.9 Compute the indicators

Execute the following command to run the script that computes the final KPIs:
    
    ./bash/compute_indicators.sh

The script will compute the indicators of the simulation and will save the results within the path:

    ./data/{city_name}/output/scenario/csv/*

### 4.10 Visualize the statistics 

Execute the following command to visualize the statistics computed in the previous step:
    
    ./bash/visualize_stats.sh

The script will generate an interactive line plot and will save it as html file within the path:

    ./data/{city_name}/output/scenario/html/*

Run the command with `-d` flag to display the visualization in your browser:
    
    ./bash/visualize_stats.sh -d
