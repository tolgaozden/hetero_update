counterfactual_main==benchmark case with randomized shocks
counterfactual_main2= single simulation code with "filtered" shocks. Since the collapsing step is different in estimations and 
simulations, this leads to different time series in both cases essentially. 
counterfactual_main3= single simulation, same as above. This is an attempt to get the collapsing step equal under both cases. 

counterfactual_experiments==redundant
counterfactual_experiments2=1D grid search with different values of n1. Shocks are fixed at estimated means
counterfactual_experiments3=2D grid search with different values of n1 and gain. Shocks are fixed at estimated means
counterfactual_experiments4=rolling window "forecast" with estimated values of n1 and gain
counterfactual_function: function for running the counterfactual simulation. Shocks are fixed are estimated values 
counterfactual_function_rnd: same as above, but the shocks are randomized over the counterfactual period. 
