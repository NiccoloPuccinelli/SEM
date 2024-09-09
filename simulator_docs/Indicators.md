# Indicators

We divide indicators into 2 main categories: global and specific. Global indicators concern data about the overall system, at each timestamp, while specific indicators are related to specific rides, on which we compute the mean in order to aggregate them. 

Please note that we do not provide any time aggregation (e.g., windowing). This way, by simply obtaining raw data for each timestamp, we may decide how to perform pre-processing in a subsequent phase, according to the results we obtain and to factors (such as trend and seasonality) we observe in the time series.


## Global indicators

* Rides requested (not used, part of the index) --> number of rides requested by the customers.
* Rides canceled (not used, bias for the index) --> number of rides canceled by the customers.
* Rides not served (not used, part of the index) --> number of ride requests not served (no drivers available or no drivers accepted the request).
* Rides accepted (not used, bias for the index) --> number of ride requests accepted.
* Rides pending --> number of ride requests waiting for an answer by a driver candidate.
* Rides rejections (not used, bias for the index) --> number of requests rejected by driver candidates (this does not mean the ride requested has not been unserved. The counter increases if a driver rejects the request and the system tries to find another driver candidate).
* Idle drivers --> number of active drivers waiting for a ride request.
* Responding drivers --> number of drivers responding to ride requests.
* Pickup drivers (pickup customers) --> number of drivers moving to the meeting point.
* On-road drivers (on-road customers) --> number of drivers moving to the destination point.
* Moving drivers --> number of active drivers moving towards another area with more opportunity to gain.
* Pending customers --> number of customers with accepted request, waiting to be served.
* Rides completed --> number of rides completed for each timestamp.


## Specific indicators (average for each timestamp)

* Avg rejections before accepted --> average number of requests forwarded, before a driver candidate accepted the ride.
* Avg surge multiplier --> avg value of the surge multiplier, computed on each request and TAZ.
* Avg expected price --> average (expected_price/expected_distance) for each ride.
* Avg real price --> average (real_price/real_distance) for each ride.
* Avg diff price --> average (|expected_price-real_price|/expected_price) for each ride.
* Avg actual expected price (not used) --> average difference between expected cost of each ride at timestamp t - cost of the ride at timestamp t-start_ride.
* Avg actual real price (not used) --> average difference between real cost of each ride at timestamp t - cost of the ride at timestamp t-start_ride.
* Avg actual expected price 30min (not used) --> average difference between expected cost of each ride at timestamp t - cost of the ride at timestamp t-1800.
* Avg actual real price 30min (not used) --> average difference between real cost of each ride at timestamp t - cost of the ride at timestamp t-1800.
* Avg actual expected price 60min (not used) --> average difference between expected cost of each ride at timestamp t - cost of the ride at timestamp t-3600.
* Avg actual real price 60min (not used) --> average difference between real cost of each ride at timestamp t - cost of the ride at timestamp t-3600.
* Avg current error ride distance --> average error between the distance covered and the expected distance covered per timestamp.
* Avg speed wrt max speed --> average ratio between the actual speed of the driver and the maximum speed allowed in the road, for each ride.
* Avg speed --> average speed for each ride.
* Avg diff duration --> average difference between expected duration and real duration, for each ride.
* Avg expected ride time --> average expected time to complete a ride since the meeting.
* Avg expected meeting time --> average expected time of the driver to meet the customer.
* Avg expected total time --> average expected total time to complete a ride (meeting+ride).
* Avg ride time --> average time to complete a ride since the meeting.
* Avg meeting time --> average time of the driver to meet the customer.
* Avg total time --> average total time to complete a ride (meeting+ride).
* Avg ride length --> average length of each ride since meeting.
* Avg meeting length --> average length of each meeting route.
* Avg total length --> average total length of each ride (meeting+ride).
* Avg distance per timestamp --> average distance accomplished for each ride.
* Avg remaining distance covered --> average distance covered (ratio) by the drivers for each ride.