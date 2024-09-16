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

# List of all scenarios to run
scenarios=("underground" "flash_mob" "driver_strike" "long_rides" "progressive_greedy" "underground_greedy" "flash_mob_greedy" "driver_strike_greedy" "long_rides_greedy")

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

# Capture start time
total_start_time=$(date +%s)

# Print the training option
if [[ "$TRAIN_VALUE" == "yes" ]]; then
  echo "Re-training the autoencoder, this may take up to 3 hours"
fi
if [[ "$TRAIN_VALUE" == "no" ]]; then
  echo "Predicting with the pre-trained autoencoder, this will take 80-90 seconds for each scenario"
fi

# Export to the environment
export TRAIN="$TRAIN_VALUE"
RUN_ALL_VALUE="yes"
export RUN="$RUN_ALL_VALUE"

# Loop through each scenario
for scenario in "${scenarios[@]}"; do
    echo ""
    echo "RUNNING SCENARIO: $scenario"

    # Set scenario environment variable
    export FAIL="$scenario"

    # Run the main script for the current scenario
    echo "Running SEM setup for scenario: $scenario"
    echo ""
    # Convert notebook to a Python script and extract name
    NOTEBOOK_FILE="main.ipynb"
    jupyter nbconvert --to script "$NOTEBOOK_FILE"
    PYTHON_SCRIPT="${NOTEBOOK_FILE%.ipynb}.py"
    echo ""

    # Run Python script and clean up after execution
    ipython "$PYTHON_SCRIPT"
    rm "$PYTHON_SCRIPT"

    echo ""
    echo "COMPLETED SCENARIO: $scenario"
    echo ""
done

# Capture end time
total_end_time=$(date +%s)

# Compute total elapsed time in seconds
total_elapsed_time=$((total_end_time - total_start_time))

# Convert to hours, minutes, and seconds format
total_hours=$((total_elapsed_time / 3600))
total_minutes=$(( (total_elapsed_time % 3600) / 60))
total_seconds=$((total_elapsed_time % 60))

echo ""
echo "------------------------------------"
echo "|      ALL SCENARIOS EXECUTED      |"
echo "| Total Execution Time: ${total_hours}h ${total_minutes}m ${total_seconds}s |"
echo "------------------------------------"
echo ""