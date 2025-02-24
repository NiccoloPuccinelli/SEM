#!/bin/bash

echo ""
echo "------------------------------------"
echo "| SMART ECOSYSTEM MONITORING (SEM)|"
echo "------------------------------------"
echo ""
echo "-------------------------"
echo "| RUNNING ALL SCENARIOS |"
echo "-------------------------"
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

# List of all scenarios to run
if [[ "$MODE_VALUE" == "main" ]]; then
  scenarios=("underground" "flash_mob" "wildcat_strike" "long_rides" "greedy_drivers" "underground_greedy" "flash_mob_greedy" "wildcat_strike_greedy" "long_rides_greedy" "long_rides_underground" "long_rides_mob" "long_rides_strike" "budget_passengers" "boycott_uber" "greedy_drivers_budget_pass" "boycott_uber_mob" "boycott_uber_strike" "wildcat_strike_budget_pass")
else
  scenarios=("greedy_drivers" "underground_greedy" "flash_mob_greedy" "wildcat_strike_greedy" "long_rides_greedy" "budget_passengers" "greedy_drivers_budget_pass" "wildcat_strike_budget_pass")
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

# Capture start time
total_start_time=$(date +%s)

# Print the training option
if [[ "$TRAIN_VALUE" == "yes" && "$MODE_VALUE" == "main" ]]; then
  echo "Re-training the autoencoder, this will require approximately half an hour"
fi
if [[ "$TRAIN_VALUE" == "yes" && "$MODE_VALUE" == "continual" ]]; then
  echo "Re-training the autoencoder with continual learning, this will require approximately 3 minutes"
fi
if [[ "$TRAIN_VALUE" == "no" ]]; then
  echo "Predicting with the pre-trained autoencoder, this will require approximately 1 minute for each scenario"
fi

# Export to the environment
export TRAIN="$TRAIN_VALUE"
RUN_ALL_VALUE="yes"
export RUN="$RUN_ALL_VALUE"

# Loop through each scenario
for scenario in "${scenarios[@]}"; do
    echo ""
    echo "SCENARIO: $scenario"

    # Set scenario environment variable
    export FAIL="$scenario"

    # Run the main script for the current scenario
    echo "Running SEM setup for scenario: $scenario"
    echo ""
    # Convert notebook to a Python script and extract name
    if [[ "$MODE_VALUE" == "main" ]]; then
      NOTEBOOK_FILE="main.ipynb"
    else
      NOTEBOOK_FILE="continual_learning.ipynb"
    fi
    jupyter nbconvert --to script "$NOTEBOOK_FILE"
    PYTHON_SCRIPT="${NOTEBOOK_FILE%.ipynb}.py"
    echo ""

    # Run Python script and clean up after execution
    ipython "$PYTHON_SCRIPT"
    rm "$PYTHON_SCRIPT"

    echo ""
    echo "COMPLETED SCENARIO: $scenario"
    echo ""
    echo "------------------------------------"
    TRAIN_VALUE="no"
    export TRAIN="$TRAIN_VALUE"
done

# Capture end time
total_end_time=$(date +%s)

# Compute total elapsed time in seconds
total_elapsed_time=$((total_end_time - total_start_time))

# Convert to hours, minutes, and seconds format
total_hours=$((total_elapsed_time / 3600))
total_minutes=$(( (total_elapsed_time % 3600) / 60))
total_seconds=$((total_elapsed_time % 60))
echo "|      ALL SCENARIOS EXECUTED      |"
echo "| Total Execution Time: ${total_hours}h ${total_minutes}m ${total_seconds}s |"
echo "------------------------------------"
echo ""