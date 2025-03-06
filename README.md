# Predicting Failures in Smart human-centric EcoSystems (SES)

This replication package can be used to replicate the results of our manuscript **Predicting Failures in Smart Human-Centric EcoSystems**.

Our work proposes **Smart human-centric Ecosystem Monitoring (SEM)**, an approach that predicts **SES** failures. **SEM** identifies failure-prone scenarios from the reconstruction error of **SES** indicators, 
that is, metric values that **SEM** collects from **SES** at constant frequency. **SEM** computes the reconstruction error with a suitably trained *Denoising Transformer Autoencoder*. 
The experimental results that we collected on the digital mirror of peer-to-peer ride-sharing systems operating in San Francisco confirm that **SEM** can effectively predict **SES** failures early enough to activate preventing actions.

This replication package includes data and instructions on how to run, interpret and obtain the results presented in our work.

To clone this repository, you can download the folder in `.zip` format (**~535 Mb**, 'Download Repository' button at the top-right of this page), and extract it.


## Introduction

This replication package includes:

* The datasets of raw metrics collected from our *RS-Digital-Mirror*, available [here](datasets/raw).
* The results of the experiments of **SEM, Smart Ecosystem Monitoring**, the approach presented in our manuscript which predicts failures in Smart Ecosystems.
* The toolset to execute **SEM** to replicate the results obtained based on the provided datasets.
* The link to [download the **RS-Digital-Mirror**](https://drive.switch.ch/index.php/s/cFDNG3zmqd4opST), whose documentation can also be found in the [digital_mirror_docs](digital_mirror_docs) folder.


## Structure

This replication package contains 10 folders, 8 Python notebooks, a requirements file, and 2 bash scripts: `run.sh` and `run_all.sh`, to quickly [replicate](#running-experiments) our experiments. 

The folders are organized as follows:

* *hyper_tuning* contains the results of the tuning of the hyperparameters, computed to find the best hyperparameters combination for the *Denoising Transformer Autoencoder*.
* *datasets* contains the data used by *SEM*. The *raw* folder includes the raw metrics gathered from the execution of the *RS-Digital-Mirror*, while the *proc* folder includes, for each computation, the dataset obtained from the execution of the *Pre-processor*. More details can be found in the [section below](#datasets).
* *failed_requests* contains the graphs of the *Failed_requests* index for each scenario.
* *html_plots* contains the html visualization of all the raw metrics for each scenario.
* *losses* contains the graph of the loss computed during the training of the model.
* *models* contains the trained model in `.pkl` format, that can be loaded for prediction.
* *predictions* contains the metrics computed for the training set and the events.
* *results* contains the graphs and the `.csv` data of the predictions of the model for each scenario.
* *scalers* contains the scaler used for the normalization of the data by the *Pre-processor*.
* *digital_mirror_docs* contains the documentation of the *RS-Digital-Mirror*, available [here](https://drive.switch.ch/index.php/s/cFDNG3zmqd4opST) in `.zip` format.

The notebooks are organized as follows:

* *main.ipynb* is the main notebook used for the main computation. It loads the data, pre-process them, eventually re-trains the model, and computes the results. The final results (`.png` graphs and `.csv` data) are saved in the [results](results/) folder.
* *continual_learning.ipynb* is the notebook used for the continual learning computation. It works like *main.ipynb*, but applies continual learning strategy instead of training on the entire initial dataset. The final results (`.png` graphs and `.csv` data) are saved in the [results](results/) folder.
* *preprocessing.ipynb* pre-process the data and performs normalization.
* *hyper_tuning.ipynb* performs the tuning of the hyperparameters to find the best hyperparameters combination for the model.
* *preparation.ipynb* performs windowing and prepares the data to be given as input to the model.
* *training_transformer.ipynb* instantiates and trains the model with the best hyperparameters combination. It also implements continual learning. The model is then saved in the [models](models/) folder.
* *predict.ipynb* performs the prediction task for training and events datasets. The results are then saved in the [predictions](predictions/) folder.
* *utils.ipynb* contains several utility functions.


## Datasets

This [folder](datasets/raw) contains the data of all the scenarios, that is, the normal scenario used for training, 7 single-event scenarios, and 11 combined-events scenarios, in `.csv` format.

* `sf_normal_final_indicators_97200.csv` is the training dataset, which contains 27 hours of raw metrics gathered from the execution of the *RS-Digital-Mirror*.
* `sf_underground_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the **Underground alarm** scenario.
* `sf_flash_mob_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the **Flash mob** scenario.
* `sf_wildcat_strike_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the **Wildcat strike** scenario.
* `sf_long_rides_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the **Long rides** scenario.
* `sf_greedy_drivers_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the **Greedy drivers** scenario.
* `sf_boycott_uber_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the **Boycott Uber** scenario.
* `sf_budget_passengers_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the **Budget passengers** scenario.
* `sf_underground_greedy_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the combination of the **Underground alarm** and the **Greedy drivers** scenarios.
* `sf_flash_mob_greedy_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the combination of the **Flash mob** and the **Greedy drivers** scenarios.
* `sf_wildcat_strike_greedy_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the combination of the **Wildcat strike** and the **Greedy drivers** scenarios.
* `sf_long_rides_greedy_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the combination of the **Long rides** and the **Greedy drivers** scenarios.
* `sf_long_rides_underground_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the combination of the **Long rides** and the **Greedy drivers** scenarios.
* `sf_long_rides_mob_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the combination of the **Long rides** and the **Greedy drivers** scenarios.
* `sf_long_rides_strike_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the combination of the **Long rides** and the **Greedy drivers** scenarios.
* `sf_greedy_drivers_budget_pass_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the combination of the **Greedy drivers** and the **Budget passengers** scenarios.
* `sf_boycott_uber_mob_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the combination of the **Boycott Uber** and the **Flash mob** scenarios.
* `sf_boycott_uber_strike_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the combination of the **Boycott Uber** and the **Wildcat strike** scenarios.
* `sf_wildcat_strike_budget_pass_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the combination of the **Wildcat strike** and the **Budget passengers** scenarios.

The [continual subfolder](datasets/raw/continual) contains the normal scenario and the 8 events with the flat-rate provider.

## Prerequisites

To run the experiments we used a machine with the following configuration. This is the tested setup, but the scripts presented in this replication package can be run also with Linux.

* OS: MacOS Sequoia
* Processor: Apple M3 Max
* RAM: 36 GB
* Software packages
    * [Python 3](https://www.python.org/downloads/)
    * [Conda](https://docs.anaconda.com/miniconda/miniconda-install/)


## Environment setup

### 1. Clone this repository

To clone this repository, you can download the folder in `.zip` format (**~535 Mb**, 'Download repository' button at the top-right of this page), and extract it.

### 2. 'cd' inside this project

`cd {your_path_to_this_project}`

### 3. Create conda environment

`conda create --name SEM --channel conda-forge python=3.10`

### 4. Activate conda environment

`conda activate SEM`

### 5. Install required packages

`conda install --yes --file requirements.txt`


## Running Experiments

You can replicate the experiments in three different ways:

### 1. Automatically, scenario-specific

Through the `./run.sh` command (or `bash run.sh`) you can compute the results that we obtained for each specific scenario.

* Select **mode**: [*main*, *continual*]. *main* will run **SEM** with the standard configuration, *continual* will run **SEM** with continual learning configuration.
* Select **scenario** to run among those listed.
* Select **training** option: [*yes*, *no*]. *yes* will run the model training again (or continual learning if mode == **continual**). Otherwise, **SEM** will predict failures with the pre-trained model. (Please note that, on our configuration, re-training with mode == *main* requires approximately 1 hour of computation, while with mode == *continual* it requires approximately 3 minutes. Predicting requires approximately 1 minute for each scenario). 
* Once the 3 options are set, **SEM** will **start and compute the results**. 

For each scenario:
* The reconstruction error graph for the training set (Figure 2 in the paper, that is, **normal** scenario) will be saved in the [results](results/) folder.
* The *Failed_requests* index plot (Figure 3 in the paper) will be saved in the [failed_requests](failed_requests/) folder.
* The final reconstruction error graph (Figure 3 in the paper) will be shown in a new window and also saved in the [results](results/) folder.

(If you encounter problems with permissions, try running `chmod +x {filename}` from terminal).

### 2. Automatically, all scenarios at once

Through the `./run_all.sh` command (or `bash run_all.sh`) you can compute all the results that we obtained for each scenario at once.

* Select **mode**: [*main*, *continual*]. *main* will run **SEM** with the standard configuration, *continual* will run **SEM** with continual learning configuration.
* Select **training** option: [*yes*, *no*]. *yes* will run the model training again (or continual learning if mode == **continual**). Otherwise, **SEM** will predict failures with the pre-trained model. (Please note that, on our configuration, re-training with mode == *main* requires approximately 1 hour of computation, while with mode == *continual* it requires approximately 3 minutes. Predicting requires approximately 1 minute for each scenario). 
* Once the 2 options are set, **SEM** will **start and compute the results**. 


For each scenario:
* The reconstruction error graph for the training set (Figure 2 in the paper, that is, **normal** scenario) will be saved in the [results](results/) folder.
* The *Failed_requests* index plot (Figure 3 in the paper) will be saved in the [failed_requests](failed_requests/) folder.
* The final reconstruction error graph (Figure 3 in the paper) will be saved in the [results](results/) folder.

(If you encounter problems with permissions, try running `chmod +x {filename}` from terminal).

### 3. Manually

By executing the notebooks directly from jupyter, after opening jupyter in the project folder with the command `jupyter lab`. 
