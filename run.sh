#!/bin/bash

echo ""
echo "------------------------------------"
echo "| SMART ECOSYSTEM MONITORING (SEM)|"
echo "------------------------------------"
echo ""
echo "--- SEM SETUP ---"
echo ""

# Choose between main or continual learning mode
echo "Choose training mode: "
echo "[main, continual]"
read -p "-> " MODE_VALUE
echo ""
# Convert input mode to lowercase
MODE_VALUE=$(echo "$MODE_VALUE" | tr '[:upper:]' '[:lower:]')
# Check if input mode is valid
if [[ "$MODE_VALUE" != "main" && "$MODE_VALUE" != "continual" ]]; then
  echo "Error: Invalid mode name. Allowed inputs are 'main' and 'continual'"
  exit 1
fi

# Read scenario name from input
echo "Enter the scenario name: "
if [[ "$MODE_VALUE" == "main" ]]; then
  echo "[underground, flash_mob, wildcat_strike, long_rides, greedy_drivers, underground_greedy, flash_mob_greedy, wildcat_strike_greedy, long_rides_greedy, long_rides_underground, long_rides_mob, long_rides_strike, budget_passengers, boycott_uber, greedy_drivers_budget_pass, boycott_uber_mob, boycott_uber_strike, wildcat_strike_budget_pass]"
  read -p "-> " FAIL_VALUE
else
  echo "[greedy_drivers, underground_greedy, flash_mob_greedy, wildcat_strike_greedy, long_rides_greedy, budget_passengers, greedy_drivers_budget_pass, wildcat_strike_budget_pass]"
  read -p "-> " FAIL_VALUE
fi
echo ""
# Convert input scenario to lowercase
FAIL_VALUE=$(echo "$FAIL_VALUE" | tr '[:upper:]' '[:lower:]')
# Check if input scenario is valid
if [[ "$MODE_VALUE" == "main" ]]; then
  if [[ "$FAIL_VALUE" != "wildcat_strike" && "$FAIL_VALUE" != "underground" && "$FAIL_VALUE" != "greedy_drivers" && "$FAIL_VALUE" != "flash_mob" && "$FAIL_VALUE" != "long_rides" && "$FAIL_VALUE" != "wildcat_strike_greedy" && "$FAIL_VALUE" != "underground_greedy" && "$FAIL_VALUE" != "flash_mob_greedy" && "$FAIL_VALUE" != "long_rides_greedy" && "$FAIL_VALUE" != "long_rides_underground" && "$FAIL_VALUE" != "long_rides_mob" && "$FAIL_VALUE" != "long_rides_strike" && "$FAIL_VALUE" != "budget_passengers" && "$FAIL_VALUE" != "boycott_uber" && "$FAIL_VALUE" != "greedy_drivers_budget_pass" && "$FAIL_VALUE" != "boycott_uber_mob" && "$FAIL_VALUE" != "boycott_uber_strike" && "$FAIL_VALUE" != "wildcat_strike_budget_pass" ]]; then
    echo "Error: Invalid scenario name. Allowed inputs are 'underground', 'flash_mob', 'wildcat_strike', 'long_rides', 'greedy_drivers', 'underground_greedy', 'flash_mob_greedy', 'wildcat_strike_greedy', 'long_rides_greedy', 'long_rides_underground', 'long_rides_mob', 'long_rides_strike', 'budget_passengers', 'boycott_uber', 'greedy_drivers_budget_pass', 'boycott_uber_mob', 'boycott_uber_strike', 'wildcat_strike_budget_pass'."
    exit 1
  fi
else
  if [[ "$FAIL_VALUE" != "greedy_drivers" && "$FAIL_VALUE" != "wildcat_strike_greedy" && "$FAIL_VALUE" != "underground_greedy" && "$FAIL_VALUE" != "flash_mob_greedy" && "$FAIL_VALUE" != "long_rides_greedy" && "$FAIL_VALUE" != "budget_passengers" && "$FAIL_VALUE" != "greedy_drivers_budget_pass" && "$FAIL_VALUE" != "wildcat_strike_budget_pass" ]]; then
    echo "Error: Invalid scenario name. Allowed inputs are 'greedy_drivers', 'underground_greedy', 'flash_mob_greedy', 'wildcat_strike_greedy', 'long_rides_greedy', 'budget_passengers', 'greedy_drivers_budget_pass', 'wildcat_strike_budget_pass'."
    exit 1
  fi
fi

# Read train option from input
if [[ "$MODE_VALUE" == "main" ]]; then
  echo "Train again the autoencoder? [Re-training requires approximately half an hour]"
else
  echo "Train again the autoencoder with continual learning? [Continual learning requires approximately 3 minutes]"
fi
echo "[yes, no]"
read -p "-> " TRAIN_VALUE
# Convert input to lowercase
TRAIN_VALUE=$(echo "$TRAIN_VALUE" | tr '[:upper:]' '[:lower:]')
# Check if input option is valid
if [[ "$TRAIN_VALUE" != "yes" && "$TRAIN_VALUE" != "no" ]]; then
  echo "Error: Invalid input for re-train. Allowed inputs are 'yes' and 'no'"
  exit 1
fi
echo ""

# Print the scenario and training option
if [[ "$TRAIN_VALUE" == "yes" && "$MODE_VALUE" == "main" ]]; then
  echo "Re-training the autoencoder, this will require approximately half an hour"
fi
if [[ "$TRAIN_VALUE" == "yes" && "$MODE_VALUE" == "continual" ]]; then
  echo "Re-training the autoencoder with continual learning, this will require approximately 3 minutes"
fi
if [[ "$TRAIN_VALUE" == "no" ]]; then
  echo "Predicting with the pre-trained autoencoder, this will require approximately 1 minute"
fi
echo "Scenario: "$FAIL_VALUE", re-train: "$TRAIN_VALUE""
echo ""

# Export to the environment
export FAIL="$FAIL_VALUE"
export TRAIN="$TRAIN_VALUE"
RUN_ALL_VALUE="no"
export RUN="$RUN_ALL_VALUE"

# Convert notebook to a Python script and extract name
if [[ "$MODE_VALUE" == "main" ]]; then
  NOTEBOOK_FILE="main.ipynb"
else
  NOTEBOOK_FILE="continual_learning.ipynb"
jupyter nbconvert --to script "$NOTEBOOK_FILE"
PYTHON_SCRIPT="${NOTEBOOK_FILE%.ipynb}.py"
echo ""

# Run Python script and clean up after execution
ipython "$PYTHON_SCRIPT"
rm "$PYTHON_SCRIPT"
echo ""