# Indicators

We collect a total of 41 indicators from the Ride-Hailing Digital Shadow.

Please note that we do not provide any time aggregation (e.g., windowing). This way, by simply obtaining raw data for each timestamp, we may decide how to perform pre-processing in a subsequent phase, according to the results we obtain and to factors (such as trend and seasonality) we observe in the time series.

* Rides requested --> number of rides requested by passengers.
* Rides canceled --> number of rides canceled by passengers.
* Rides not served --> number of ride requests not served (no drivers available or no drivers accepted the request).
* Rides accepted --> number of ride requests accepted.
* Rides rejections --> number of requests rejected by driver candidates.
* Rides in progress --> number of rides accepted and currently in progress.
* Idle drivers --> number of active drivers waiting for a ride request.
* Pickup drivers --> number of drivers moving to the meeting point.
* On-road drivers --> number of drivers moving to the destination point.
* Moving drivers --> number of active drivers moving towards another area with more opportunity to gain.
* Active passengers --> number of passengers requesting a ride.
* Rides completed --> number of rides completed for each timestamp.
* Avg rejections before accepted --> average number of requests forwarded, before a driver candidate accepted the ride.
* Avg surge multiplier --> average value of the surge multiplier.
* Avg expected price --> average expected price, computed at the beginning of each ride.
* Avg real price --> average real price, computed after the end of the ride.
* Avg diff price --> average price difference between expected and real for each ride.
* Avg actual expected price 30min --> average difference between expected cost of each ride at timestamp t - cost of the ride at timestamp t-1800.
* Avg actual real price 30min --> average difference between real cost of each ride at timestamp t - cost of the ride at timestamp t-1800.
* Avg current error ride distance --> average error between the distance covered and the expected distance covered per timestamp.
* Avg speed wrt max speed --> average ratio between the actual speed of the driver and the maximum speed allowed in the road.
* Avg speed kmh --> average speed value.
* Avg ride time min --> average time to complete a ride since the meeting.
* Avg meeting time min --> average time of the driver to meet the passenger.
* Avg total time min --> average total time to complete a ride (meeting+ride).
* Avg ride length km --> average length of each ride since meeting.
* Avg meeting length km --> average length of each meeting route.
* Avg total length km --> average total length of each ride (meeting+ride).
* Avg distance per timestamp --> average distance accomplished for each timestamp.
* Avg remaining distance covered --> average distance covered (ratio) by the drivers.
* Avg no surge expected price --> average ratio between real price and surge multiplier.
* Avg no surge real price --> average ratio between expected price and surge multiplier.
* Avg rides rejections rate --> average ratio between rides rejections and avg rejections before accepted.
* Avg price ratio --> average ratio between expected price and real price.
* Avg rejections idle drivers --> average product between rides rejections and idle drivers.
* Avg rejections sensitivity --> average product between avg rejections before accepted and avg diff price.
* Avg rejections on road drivers --> average product between avg rejections before accepted and on road drivers.
* Avg rejections diff min --> average product between avg rejections before accepted and (real min time - expected min time).
* Avg on road drivers surge --> average ratio between on road drivers and avg surge multiplier.
* Avg rides in progress surge --> average ratio between rides in progress and avg surge multiplier.
* Avg idle drivers surge --> average product between idle drivers and avg surge multiplier.