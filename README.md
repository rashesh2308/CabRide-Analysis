# CabRide-Analysis

# Data

Information about attributes:

    a.	taxi_id: A unique identifier for each individual taxi cab.
    b.	trip_seconds: The number of seconds elapsed during the trip.
    c.	trip_miles: The number of miles logged during the trip.
    d.	fare: The base fare charged to the customer for the trip.
    e.	tips: The tip given by the customer to the driver for the trip.
    f.	tolls: Any surcharges for road or bridge tolls incurred during the trip.
    g.	extras: Charges for any incidentals requested by the customer.
    h.	trip_total: The total charge to the customer for the trip.
    i.	payment_type: The method of payment used by the customer. This includes cash, credit card, and several other methods of payment jointly classed as “other”.

# Main Tasks:
1. Investigate relevant interactions and common independent variable transforms to determine if adding these to  model will result in a better model fit. 
2. Evaluate and explain model’s conformity to the LINE assumptions of regression.
3. Investigate and remove any data points deemed to have an inappropriately high leverage in determining the plot of the model.  

# Plotting the density graph

![alt text](https://github.com/rashesh2308/CabRide-Analysis/blob/master/images/1.png?raw=true)

**Conclusion:**
1. Density plot of Minutes: We can see that distribution of data is right-skewed distribution. i.e.  Majority of  records are present in the range of 0 to 40mins. There are very few rides which has trip time more than 40mins. This would help the business when trying a new promotional codes, they could target the users who has time>40, so that the number of people would increase and thus the revenue will increase.  
2. Density plot of Miles: Majority of records are present in the range of 0 to 6 miles. There are few rides which are very long rides (between  17 to 20 miles) It seems that people are highly inclined towards having short trips. 
3. Density plot of Fare: Fare ranges between 0 to $20. There are bumps near $30-$50 which shows that there are few rides which has a fare > $30. It seems that Fare has some relationship with minutes and miles. Because both minutes and miles has a bump towards the tail 
4. Density plot of Tips: People tend to tip between $0 to $4. However, there are few generous people who tend to give more than $5.
5. Density of Extra: Extras are very less, just between $0 to $3. There’s an asymptote after $5. 
6. Density of Trip total: The rightly-skewed graph shows that the majority of trip total is between $0 to $20. However, there are two bumps (similar to minutes and miles) between $40 to $70. 

# Plotting boxplots

![alt text](https://github.com/rashesh2308/CabRide-Analysis/blob/master/images/2.png?raw=true)

From the boxplots we can see that there are few outliers which lies beyond the 3rd quartile in each of the factors. 

# Correlation Matrix

![alt text](https://github.com/rashesh2308/CabRide-Analysis/blob/master/images/4.png?raw=true)

From the correlation matrix we can conclude the following observations:
  1.	There’s a high correlation between trip_minutes and trip_miles : 0.79 
  2.	Similarly, correlation(trip_minutes , fare) is 0.89
  3.	Correlation between Miles and Fare is the hight at 0.90
  4.	Highest correlation is observed between the fare and trip_total at 0.96
  5.	We can see that there’s almost no relation for the Payment Type. It is independent of any other factors. 
We can see that the fare/trip_total is dependent on very few factors: Trip_minutes and trip_miles. 

# Using Fare as the dependent variable, building a regression model

![alt text](https://github.com/rashesh2308/CabRide-Analysis/blob/master/images/17.png?raw=true)

Looking at the p-values, of payment_type, it is more than 0.05. So, we fail to reject the null hypothesis. 

Forming a linear model for Fare using trip_minutes, trip_miles, and payment typebin, we get the equation as follows:
F(fare) = 3.88 + 0.177(trip_minutes) + 2.01(trip_miles) 
1.	Every minute spend in the cab will increase the fare by $0.177 and it ranges from $0.09 to $0.25
2.	For every mile, the fare will increase by $2.01 and it ranges from $1.88 to $2.14

Moreover, the R-squared term is 0.98. Which says that this model fits our data perfectly.  The Confidence internal has the range very tight, so this will help us in predicting the fare more accurately. 

Looking at the actual vs predicted values, most of the points lies on the regression line and thus we can say that there’s a linear relationship between fare and minutes and miles. 

# Plotting a Actual vs Fitted Values graph 

![alt text](https://github.com/rashesh2308/CabRide-Analysis/blob/master/images/18.png?raw=true)

Below is the comparison table to analyze the output more clearly (After removing outliers) : 

![alt text](https://github.com/rashesh2308/CabRide-Analysis/blob/master/images/19.png?raw=true)

Removing the outliers from the dataset in fact reduces the accuracy to 87%. It is unusual but rare in some cases where the effect of removing the outliers decreases the least squared values. It this case, it might be possible that due to small sample size, it is affecting the R-squared value. 

# LINE assumptions 

**Linearity**
plot(ubersample$fare,fare_minutes_miles$fitted.values,pch=19,main="P&O Actual v. Fitted Values",
    xlab = "Fare", ylab= "Fitted Values")
abline(0,1,col="red",lwd=3)

![alt text](https://github.com/rashesh2308/CabRide-Analysis/blob/master/images/x.png?raw=true)

Plotting a graph between actual values and predicted values of linear regression, there seems to have a linear relation between fare, minutes and miles. 

**Normality**
qqnorm(fare_minutes_miles$residuals,pch=19,main="P&O Normality Plot")
qqline(fare_minutes_miles$residuals,col="red",lwd=3)

![alt text](https://github.com/rashesh2308/CabRide-Analysis/blob/master/images/y.png?raw=true)

Normality is to check how the residuals are normally distributed. It’s good when the residuals follows the diagonal line, but in this case we can see that few points after 1 are not following the line. So, we can say that errors are not normally distributed. 

**Equality of Variances**
plot(fare_minutes_miles$fitted.values,fare_minutes_miles$residuals,pch=19,main="P&O Residuals",
    xlab="Fitted Values", ylab  = "Residuals")
abline(0,0,col="red",lwd=3)

![alt text](https://github.com/rashesh2308/CabRide-Analysis/blob/master/images/z.png?raw=true)

This plot shows the homogeneity of variance of the residuals. Here I don’t think there’s any pattern among the residuals. Hence the data obeys homoscedasticity.

**Checking the leverage points**
lev=hat(model.matrix(fare_minutes_miles))
plot(lev,pch=19)
abline(3*mean(lev),0,col="red",lwd=3)

![alt text](https://github.com/rashesh2308/CabRide-Analysis/blob/master/images/lev.png?raw=true)

Here, we can see that there are 4 points above the leverage line. 


# Conclusion:

Building a model based on the new dataset, having minutes and miles,  in fact has the higher accuracy: 99.2%. 
The equation is a  follows:
F(fare) = 3.47 + (0.15)Minutes +  (1.99) Miles

This means that, increase in every minute  will increase  the fare by $0.15 and  similarly every mile  will  add $1.99 to the fare. 





