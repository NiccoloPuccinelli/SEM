# Lyft Price Prediction

This folder contains the Lyft price prediction work. We leveraged a Random Forest model trained on a [publicly available dataset](https://github.com/ravi72munde/scala-spark-cab-rides-predictions) to predict the final price of the rides for the ride-sharing provider Lyft.

We used *distance* and *surge_multiplier* as input for the model, and achieved 94% accuracy on the test set. 

We implemented the trained model in our *RS Digital Mirror* as the price manager for Lyft.

You can replicate our experiments by simply running the `lyft.pynb` notebook.