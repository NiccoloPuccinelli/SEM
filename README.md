# Predicting Failures in Smart Ecosystems

This replication package can be used to replicate the results of our manuscript **Predicting Failures in Smart Ecosystems**.

Our work proposes **Smart Ecosystem Monitoring (SEM)**, an approach that predicts **SES** failures. **SEM** identifies failure-prone scenarios from the reconstruction error of **SES** indicators, 
that is, metric values that **SEM** collects from **SES** at constant frequency. **SEM** computes the reconstruction error with a suitably trained deep autoencoder combined with Long Short-Term Memory units (LSTM). 
The experimental results that we collected on the digital mirror of peer-to-peer ride-sharing systems operating in San Francisco confirm that **SEM** can effectively predict **SES** failures early enough to activate preventing actions.

This replication package includes data and instructions on how to run, interpret and obtain the results presented in our work.

To clone this repository, you can download the folder in `.zip` format (**229 Mb**, 'Download repository' button at the top-right of this page), and extract it.


## Introduction

This replication package includes:

* The datasets of raw metrics collected from our *RS-Digital-Mirror*, available in datasets/raw.
* The results of the experiments of **SEM, Smart Ecosystem Monitoring**, the approach presented in our manuscript which predicts failures in Smart Ecosystems.
* The toolset to execute **SEM** to replicate the results obtained based on the provided datasets.
* The link to [download the **RS-Digital-Mirror**](https://drive.switch.ch/index.php/s/lpLW3YXKCTdrSuW), whose documentation can also be found in the simulator_docs folder.


## Structure

This replication package contains 10 folders, 8 Python notebooks, and 2 bash scripts: `run.sh` and `run_all.sh`, to quickly replicate our experiments (see Running Experiments section below). 

The folders are organized as follows:

* *cross_validation* contains the results of the 4-folds cross-validation, computed to find the best hyperparameters combination for the *Deep LSTM Autoencoder*.
* *datasets* contains the data used by *SEM*. The *raw* folder includes the raw metrics gathered from the execution of the *RS-Digital-Mirror*, while the *proc* folder includes, for each computation, the dataset obtained from the execution of the *Preprocessor*. More details can be found in the section below.
* *failed_requests* contains the graphs of the *Failed_requests* index for each scenario.
* *html_plots* contains the html visualization of all the raw metrics for each scenario.
* *losses* contains the graphs of the losses computed during the training of the model.
* *models* contains the trained models in `.pkl` format, that can be loaded for prediction.
* *predictions* contains the metrics computed for the training set and the events.
* *results* contains the graphs and the `.csv` data of the predictions of the model for each scenario.
* *scalers* contains the scaler used for the normalization of the data by the *Pre-processor*.
* *simulator_docs* contains the documentation of the *RS-Digital-Mirror*, available [here](https://drive.switch.ch/index.php/s/lpLW3YXKCTdrSuW) in `.zip` format.

The notebooks are organized as follows:

* *main.ipynb* is the main notebook used for all the computation. It loads the data, pre-process them, eventually re-trains the model, and computes the results. The final results (`.png` graphs and `.csv` data) are saved in the results/ folder.
* *preprocessing_selection.ipynb* is the notebook used for selecting the best pre-processing strategy.
* *preprocessing.ipynb* pre-process the data according to the best strategy, and performs normalization.
* *cross_validation.ipynb* performs the 4-folds cross-validation to find the best hyperparameters combination for the model.
* *preparation.ipynb* performs windowing and prepares the data to be given as input to the model.
* *training_lstm.ipynb* instantiates and trains the model with the best hyperparameters combination. The model is then saved in the models/ folder.
* *predict.ipynb* performs the prediction task for training and events datasets. The results are then saved in the predictions/ folder.
* *utils.ipynb* contains several utility functions.


## Datasets

This replication package contains the data of all the scenarios, that is, the normal scenario used for training, 5 single-event scenarios, and 4 combined-events scenarios, in `.csv` format.

* `sf_normal_final_indicators_93600.csv` is the training dataset, which contains 27 hours of raw metrics gathered from the execution of the *RS-Digital-Mirror*.
* `sf_underground_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the **Underground alarm** scenario.
* `sf_flash_mob_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the **Flash mob** scenario.
* `sf_driver_strike_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the **Wildcat strike** scenario.
* `sf_long_rides_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the **Long rides** scenario.
* `sf_progressive_greedy_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the **Greedy drivers** scenario.
* `sf_underground_greedy_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the combination of the **Underground alarm** and the **Greedy drivers** scenarios.
* `sf_flash_mob_greedy_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the combination of the **Flash mob** and the **Greedy drivers** scenarios.
* `sf_driver_strike_greedy_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the combination of the **Wildcat strike** and the **Greedy drivers** scenarios.
* `sf_long_rides_greedy_final_indicators_18000_day.csv` contains 5 hours of data corresponding to the combination of the **Long rides** and the **Greedy drivers** scenarios.


## Prerequisites

To run the experiments we used a machine with the following configuration. This is the tested setup, but the scripts presented in this replication package can be run also with Linux.

* OS: MacOS Sonoma
* Processor: Apple M3 Max
* RAM: 36 GB
* Software packages
    * [Python 3](https://www.python.org/downloads/)
    * [Conda](https://docs.anaconda.com/miniconda/miniconda-install/)


## Environment setup

### 1. Clone this repository

To clone this repository, you can download the folder in `.zip` format (**229 Mb**, 'Download repository' button at the top-right of this page), and extract it.

### 2. 'cd' inside this project

`cd {your_path_to_this_project}`

### 3. Create conda environment

`conda create --name SEM --channel conda-forge python=3.10`

### 4. Activate conda environment

`conda activate SEM`

### 5. Install required packages

`conda install pandas==2.2.0 numpy==1.23.0 tensorflow==2.15.0 scipy==1.12.0 plotly==5.18.0 matplotlib==3.6.2 time jupyterlab==3.4.6 scikit-learn==1.3.2 seaborn==0.13.1 statsmodels==0.14.1`


## Running Experiments

You can run the experiments in three different ways:

### 1. Automatically, scenario-specific

Through the `./run.sh` command (or `bash run.sh`) you can compute the results that we obtained for each specific scenario. The bash script at this point will ask which scenario to run and whether to run the model training again (please note that re-training takes up to 3 hours of computation on our configuration, while loading the model and predicting requires 40/50 seconds on average for each scenario). Once the two options are set, **SEM** will start and compute the results. 

For each scenario:
* The reconstruction error graph for the training set (Figure 2 in the paper, that is, normal scenario) will be saved in the results/ folder.
* The *Failed_requests* index plot (Figures 3 and 4 in the paper) will be saved in the failed_requests/ folder.
* The final reconstruction error graph (Figures 3 and 4 in the paper) will be shown in a new window and also saved in the results/ folder.

(If you encounter problems with permissions on MacOS, try running `chmod +x {filename}` from terminal).

### 2. Automatically, all scenarios at once

Through the `./run_all.sh` command (or `bash run_all.sh`) you can compute all the results that we obtained for each scenario at once. The bash script at this point will ask whether to run the model training again (please note that re-training takes up to 3 hours of computation on our configuration, while loading the model and predicting requires 40/50 seconds on average for each scenario, that is, around 7/8 minutes in total). Once the option is set, **SEM** will start and compute the results. 

For each scenario:
* The reconstruction error graph for the training set (Figure 2 in the paper, that is, normal scenario) will be saved in the results/ folder.
* The *Failed_requests* index plot (Figures 3 and 4 in the paper) will be saved in the failed_requests/ folder.
* The final reconstruction error graph (Figures 3 and 4 in the paper) will be saved in the results/ folder.

(If you encounter problems with permissions on MacOS, try running `chmod +x {filename}` from terminal).

### 3. Manually

By executing the notebooks directly from jupyter, after opening jupyter in the project folder with the command `jupyter lab`. 
