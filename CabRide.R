setwd("/Users/rasheshkothari/Desktop/Study/Semester One/AMoB/Regression Project")
rm(list=ls())
library(rio)
library(dplyr)
library(sqldf)
library(corrplot)
#Read in data.
uberdata = read.csv("6304 Regression Project Data.csv")
colnames(uberdata)=tolower(make.names(colnames(uberdata)))
attach(uberdata)

#setting a seed for sampling the data 
set.seed(98368729)
#taking a sample out of a dataset
ubersamp =uberdata[sample(1:nrow(uberdata),100,replace=FALSE),]
#removing the discrepancies  
ubersample = ubersamp[ubersamp$trip_seconds != 0 & ubersamp$trip_miles != 0,]
#check if there's any null values present in the sample.     
sum(is.na(ubersample))
#Summary to check 
summary(ubersample)

#Since tolls are 0, i am not considering the column in  analysis 
ubersample = select(ubersample, -c(tolls,taxi_id))
#replaceing NA with 0, if any
ubersample[is.na(ubersample)] = 0
#converting trip seconds to trip minutes and renaming the column
ubersample$trip_seconds= (ubersample$trip_seconds/60)
colnames(ubersample)[colnames(ubersample)=="trip_seconds"] <- "trip_minutes"

attach(ubersample)


#Analysis 1: Ploting the density graph
par(mfrow=c(3,2)) 
plot(density(trip_minutes),main = "Density plot of minutes" , data=ubersample)
plot(density(trip_miles),main = "Density plot of miles" , data=ubersample)
plot(density(fare),main = "Density plot of Fare", data=ubersample)
plot(density(tips),main = "Density plot of Tips",  data=ubersample)
plot(density(ubersample$extra),main = "Density plot of Extra")
plot(density(trip_total),main = "Density plot of Trip Total", data=ubersample)


#Plotting boxplots
par(mfrow=c(3,2)) 
#Minutes
boxplot(trip_minutes, main="Trip Minutes", data = ubersample)
which(ubersample$trip_minutes > 27.5) 

#(3rd qu - 1st qud )* 1.5 + 3rd qu. 
#Miles
boxplot(ubersample$trip_miles, main="Trip Miles")
which(ubersample$trip_miles > 5.7)

#Fare
boxplot(ubersample$fare , main="Trip Fare")
which(ubersample$fare > 25)
#Tips
boxplot(tips, main="Tips", data=ubersample)
which(ubersample$tips > 6)

#Extra
boxplot(extras, main="Extras", data=ubersample)
which(ubersample$extras > 4)
#Total
boxplot(trip_total, main="Trip Total", data=ubersample)
#From the boxplot we see there are quite few points which look like outliers

#removing the outliers: Outliers = (3rd quartile - 1st quartile )* 1.5 + 3rd quartile
ubersample1 = ubersample[which(ubersample$trip_miles < 5.7) ,]
ubersample2 = ubersample1[which(ubersample1$trip_minutes < 27.5),]
ubersample3 = ubersample2 [which(ubersample2$tips < 6),]
ubersample4 = ubersample3[which(ubersample3$extras < 4),]

ubersample4

#Analysis 2 
sqldf("select payment_type,count(payment_type) as counts
      from ubersample group by payment_type")

#Analysis 3 
#Making sure that payment type has no NA values
ubersample[is.na(payment_type)] = 0
#Converting the text to binary 
for(i in 1:length(ubersample$payment_type)) {
  if(ubersample$payment_type[i]== 'Cash') {
    ubersample$payment_typebin[i]=1
  } 
  if(ubersample$payment_type[i]== 'Credit Card') {
    ubersample$payment_typebin[i]=0
  } 
  if(ubersample$payment_type[i]== 'Others')  {
    ubersample$payment_typebin[i]  = -1
  }
}
par(mfrow=c(1,1))
correlation = cor(ubersample[sapply(ubersample, is.numeric)])
correlation
corrplot(correlation, method = "shade")

#Analysis 4 
#Using Fare as the dependent variable, building a regression model
fare_minutes_miles_payment = lm(ubersample$fare~
                   ubersample$trip_minutes
                 + ubersample$trip_miles
                 + ubersample$payment_type)
summary(fare_minutes_miles_payment)
#Chacking the confidence interval 
confint(fare_minutes_miles_payment)
#Plotting a Actual vs Fitted Values graph
plot(ubersample$fare,fare_minutes_miles_payment$fitted.values,pch=19,main="P&O Actual v. Fitted Values",
     xlab = "fare", ylab = "Fitted Values")
abline(0,1,col="red",lwd=3)

#Analysis  5
#Removing Payment_Type
fare_minutes_miles = lm(ubersample4$fare~
                          ubersample4$trip_minutes+
                          ubersample4$trip_miles)
summary(fare_minutes_miles)

plot(ubersample4$fare,fare_minutes_miles$fitted.values,pch=19,main="P&O Actual v. Fitted Values",
     xlab = "fare", ylab = "Fitted Values")
abline(0,1,col="red",lwd=3)

#Removing Miles
fare_minutes = lm(ubersample4$fare~
                    ubersample4$trip_minutes)
summary(fare_minutes)
plot(ubersample4$fare,fare_minutes$fitted.values,pch=19,main="P&O Actual v. Fitted Values",
     xlab = "fare", ylab = "Fitted Values")
abline(0,1,col="red",lwd=3)

#Removing Minutes, Keeping Miles
fare_miles = lm(ubersample4$fare~
                  ubersample4$trip_miles)
summary(fare_miles)
plot(ubersample4$fare,fare_miles$fitted.values,pch=19,main="P&O Actual v. Fitted Values",
     xlab = "fare", ylab = "Fitted Values")
abline(0,1,col="red",lwd=3)
#3 points  between 30-35 due to that the farefunction_mm  is  being affected. 

#Squaring the Miles
par(mfrow=c(1,1)) 
sq.miles = ubersample4$trip_miles ** 2 
fare_miles2_minutes = lm(ubersample4$fare~
                           ubersample4$trip_minutes
                   + sq.miles)

summary(fare_miles2_minutes)
plot(ubersample4$fare,fare_miles2_minutes$fitted.values,pch=19,main="P&O Actual v. Fitted Values",
     xlab = "fare", ylab = "Fitted Values")
abline(0,1,col="red",lwd=3)   #...compare it with normal minute+miles graph 

sq.minutes = ubersample4$trip_minutes ** 2 
fare_miles_minutes2 = lm(ubersample4$fare~
                           ubersample4$trip_miles
                         + sq.minutes)

summary(fare_miles_minutes2)
plot(ubersample4$fare,fare_miles_minutes2$fitted.values,pch=19,main="P&O Actual v. Fitted Values",
     xlab = "fare", ylab = "Fitted Values")
abline(0,1,col="red",lwd=3)


#Analysis 6
#LINE assumptions 
#Linearity
plot(ubersample$fare,fare_minutes_miles$fitted.values,pch=19,main="P&O Actual v. Fitted Values",
     xlab = "Fare", ylab= "Fitted Values")
abline(0,1,col="red",lwd=3)

#Normality
qqnorm(fare_minutes_miles$residuals,pch=19,main="P&O Normality Plot")
qqline(fare_minutes_miles$residuals,col="red",lwd=3)

#Equality of Variances
plot(fare_minutes_miles$fitted.values,fare_minutes_miles$residuals,pch=19,main="P&O Residuals",
     xlab="Fitted Values", ylab  = "Residuals")
abline(0,0,col="red",lwd=3)

#Analysis 7
#Checking the leverage points
lev=hat(model.matrix(fare_minutes_miles))
plot(lev,pch=19)
abline(3*mean(lev),0,col="red",lwd=3)
which (lev>3*mean(lev))
#removing the records for which the leverage is high 
sample_without_leverage_points=  ubersample[which (lev<3*mean(lev)) ,]
sample_without_leverage_points_lm  =  lm(sample_without_leverage_points$fare~
                                        sample_without_leverage_points$trip_minutes+
                                        sample_without_leverage_points$trip_miles)
summary(sample_without_leverage_points_lm)

plot(sample_without_leverage_points$fare,sample_without_leverage_points_lm$fitted.values,pch=19,main="P&O Actual v. Fitted Values",
     xlab = "fare", ylab = "Fitted Values")
abline(0,1,col="red",lwd=3)

  
#Analysis 8
#Setting random seed as  Uid + 5
set.seed(98368734)
ubernewsample =uberdata[sample(1:nrow(uberdata),100,replace=FALSE),]
ubernewsample = ubernewsample[ubernewsample$trip_seconds != 0 & ubernewsample$trip_miles != 0,]

#Doing the same preprocessing on new Sample
#check if there's any null values present in the sample.     
sum(is.na(ubernewsample))
#Summary to check 
summary(ubernewsample)
#Since tolls are 0, i am not considering the column in  analysis 
ubernewsample = select(ubernewsample, -c(tolls,taxi_id))
#replaceing NA with 0, if any
ubernewsample[is.na(ubernewsample)] = 0
#converting trip seconds to trip minutes 
ubernewsample$trip_seconds= (ubernewsample$trip_seconds/60)
colnames(ubernewsample)[colnames(ubernewsample)=="trip_seconds"] <- "trip_minutes"
attach(ubernewsample)

#Fare as a function of  minutes and miles 
sample_with_new_data_lm = lm(ubernewsample$fare~
                       ubernewsample$trip_minutes+
                       ubernewsample$trip_miles)
summary(sample_with_new_data_lm)
plot(ubernewsample$fare,sample_with_new_data_lm$fitted.values,pch=19,main="P&O Actual v. Fitted Values",
     xlab = "fare", ylab = "Fitted Values")
abline(0,1,col="red",lwd=3)




