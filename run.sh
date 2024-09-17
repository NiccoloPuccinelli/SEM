#!/bin/bash

echo ""
echo "------------------------------------"
echo "| SMART ECOSYSTEM MONITORING (SEM)|"
echo "------------------------------------"
echo ""
echo "--- SEM SETUP ---"
echo ""

# Read scenario name from input
echo "Enter the scenario name: "
echo "[underground, flash_mob, driver_strike, long_rides, progressive_greedy, underground_greedy, flash_mob_greedy, driver_strike_greedy, long_rides_greedy]"
read -p "-> " FAIL_VALUE
echo ""
# Convert input to lowercase
FAIL_VALUE=$(echo "$FAIL_VALUE" | tr '[:upper:]' '[:lower:]')
# Check if input is valid
if [[ "$FAIL_VALUE" != "driver_strike" && "$FAIL_VALUE" != "underground" && "$FAIL_VALUE" != "progressive_greedy" && "$FAIL_VALUE" != "flash_mob" && "$FAIL_VALUE" != "long_rides" && "$FAIL_VALUE" != "driver_strike_greedy" && "$FAIL_VALUE" != "underground_greedy" && "$FAIL_VALUE" != "flash_mob_greedy" && "$FAIL_VALUE" != "long_rides_greedy" ]]; then
  echo "Error: Invalid scenario name. Allowed values are 'underground', 'flash_mob', 'driver_strike', 'long_rides', 'progressive_greedy', 'underground_greedy', 'flash_mob_greedy', 'driver_strike_greedy', 'long_rides_greedy'."
  exit 1
fi

# Read train option from input
echo "Train again the autoencoder? [Re-training requires up to 3 hours]"
echo "[yes, no]"
read -p "-> " TRAIN_VALUE
# Convert input to lowercase
TRAIN_VALUE=$(echo "$TRAIN_VALUE" | tr '[:upper:]' '[:lower:]')
# Check if input is valid
if [[ "$TRAIN_VALUE" != "yes" && "$TRAIN_VALUE" != "no" ]]; then
  echo "Error: Invalid input for re-train. Allowed values are 'yes' or 'no'"
  exit 1
fi
echo ""

# Print the scenario and training options
if [[ "$TRAIN_VALUE" == "yes" ]]; then
  echo "Re-training the autoencoder, this may take up to 3 hours"
fi
if [[ "$TRAIN_VALUE" == "no" ]]; then
  echo "Predicting with the pre-trained autoencoder, this will take 40-50 seconds"
fi
echo "Scenario: "$FAIL_VALUE", re-train: "$TRAIN_VALUE""
echo ""

# Export to the environment
export FAIL="$FAIL_VALUE"
export TRAIN="$TRAIN_VALUE"
RUN_ALL_VALUE="no"
export RUN="$RUN_ALL_VALUE"

# Convert notebook to a Python script and extract name
NOTEBOOK_FILE="main.ipynb"
jupyter nbconvert --to script "$NOTEBOOK_FILE"
PYTHON_SCRIPT="${NOTEBOOK_FILE%.ipynb}.py"
echo ""

# Run Python script and clean up after execution
ipython "$PYTHON_SCRIPT"
rm "$PYTHON_SCRIPT"