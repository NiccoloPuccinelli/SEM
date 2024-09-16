# Predicting Failures in Smart Ecosystems

This replication package can be used to replicate the results of our manuscript **Predicting Failures in Smart Ecosystems**.

Our work proposes **Smart Ecosystem Monitoring (SEM)**, an approach that predicts SES failures. **SEM** identifies failure-prone scenarios from the reconstruction error of SES indicators, 
that is, metric values that **SEM** collects from SES at constant frequency. **SEM** computes the reconstruction error with a suitably trained deep autoencoder combined with Long Short-Term Memory units (LSTM). 
The experimental results that we collected on the digital mirror of peer-to-peer ride-sharing systems operating in San Francisco confirm that **SEM** can effectively predict SES failures early enough to activate preventing actions.

This replication package includes data and instructions on how to run, interpret and obtain the results presented in our work.

Please note that Anonymous GitHub doesn't currently allow the direct cloning of the repository. To overcome this issue, you could either download the individual files, or use the tool publicly available at the following link: https://github.com/fedebotu/clone-anonymous-github.


## Introduction

This replication package includes:

* The datasets of raw metrics collected from our RS Digital Mirror, available [here](datasets/raw).
* The results of the experiments of **SEM, Smart Ecosystems Monitoring**, the approach presented in our manuscript which predicts failures in Smart Ecosystems.
* The toolset to execute **SEM** to replicate the results obtained based on the provided datasets.
* The link to [download the **RS-Digital-Mirror**](https://drive.switch.ch/index.php/s/lpLW3YXKCTdrSuW), whose documentation can also be found in the [simulator_docs](simulator_docs) folder.


## Structure

This replication package contains 10 folders, 8 Python notebooks, and a bash script `run.sh` to quickly [replicate](#running-experiments) our results. 

The folders are organized as follows:

* *cross_validation* contains the results of the 4-folds cross-validation, computed to find the best hyperparameters combination for the *Deep LSTM Autoencoder*.
* *datasets* contains the data used by *SEM*. The *raw* folder includes the raw metrics gathered from the execution of the *RS-Digital-Mirror*, while the *proc* folder includes, for each computation, the dataset obtained from the execution of the *Preprocessor*. More details can be found in the [section below](#datasets).
* *failed_requests* contains the graphs of the *Failed_requests* index for each scenario.
* *html_plots* contains the html visualization of all the raw metrics for each scenario.
* *losses* contains the graphs of the losses computed during the training of the model.
* *models* contains the trained models in `.pkl` format, that can be loaded for prediction.
* *predictions* contains the metrics computed for the training set and the events.
* *results* contains the graphs and the `.csv` data of the predictions of the model for each scenario.
* *scalers* contains the scaler used for the normalization of the data by the *Pre-processor*.
* *simulator_docs* contains the documentation of the *RS-Digital-Mirror*, available [here](https://drive.switch.ch/index.php/s/lpLW3YXKCTdrSuW) in `.zip` format.

The notebooks are organized as follows:

* *main.ipynb* is the main notebook used for all the computation. It loads the data, pre-process them, eventually re-trains the model, and computes the results. The final results (`.png` graphs and `.csv` data) are saved in the [results](results/) folder.
* *preprocessing_selection.ipynb* is the notebook used for selecting the best pre-processing strategy.
* *preprocessing.ipynb* pre-process the data according to the best strategy, and performs normalization.
* *cross_validation.ipynb* performs the 4-folds cross-validation to find the best hyperparameters combination for the model.
* *preparation.ipynb* performs windowing and prepares the data to be given as input to the model.
* *training_lstm.ipynb* instantiates and trains the model with the best hyperparameters combination. The model is then saved in the [models](models/) folder.
* *predict.ipynb* performs the prediction task for training and events datasets. The results are then saved in the [predictions](predictions/) folder.
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

To run the experiment we used a machine with the following configuration. This is a tested setup, but the scripts presented in this replication package can be run also with Linux.

* OS: MacOS Sonoma
* Processor: Apple M3 Max
* RAM: 36 GB
* Software packages
    * [Python 3](https://www.python.org/downloads/)
    * [Conda](https://docs.anaconda.com/miniconda/miniconda-install/)


## Environment setup

### 1. Clone this repository

Anonymous GitHub doesn't currently allow the direct cloning of the repository. To overcome this issue, you could either download the individual files, or use the tool publicly available at the following link: https://github.com/fedebotu/clone-anonymous-github.

### 2. cd inside this project

`cd {your_path_to_this_project}`

### 3. Create conda environment

`conda create --name SEM --channel conda-forge python=3.10`

### 4. Activate conda environment

`conda activate SEM`

### 5. Install required packages

`conda install pandas numpy tensorflow scipy plotly matplotlib time jupyterlab scikit-learn`


## Running Experiments

