# AirPollution
Final project for Udacity ios nanodegree program.

**To be able to use the app, user should be located in Stuttgart, Germany** 

App, mainly visualizes the air pollution data for **Stuttgart, Germany** city center and surrounding area and tracks user location to keep an air pollution history for user location.

Users can also see if there is a Air Pollution Alarm (FeinstaubAlarm) for Stuttgart and reach puplic transportation data for stations in Stuttgart.

## MapViewController

App tracks user location, gets data of closest sensor and saves it for further usage.

On top of screen, a label shows if there is an Air Pollution Alarm (FeinstaubAlarm) or not for Stuttgart. User can click this label and go to the official webpage for FeinstaubAlarm for further information. 

Collected data from the sensors are shown in the map. User can click the squares and see the data from sensor in annotation. Clicking annotatins opens the **PollutionDetailViewController**.

On the right bottom of the screen, there is a legend button. User can switch between the different data types from sensors. These data types are:

- P 10 (Particle Pollution https://airnow.gov/index.cfm?action=aqibasics.particle)
- P 2.5 (Particle Pollution https://airnow.gov/index.cfm?action=aqibasics.particle)
- Humidity
- Temperature
- Pressure

On the left bottom of screen, there is a button to switch between sensor data and stations. Users can see the stations in city by clicking stations button. People are encouraged by Stuttgart municipality to use public transportation if there is an air pollution alarm for Stuttgart. Clicking station pins shows the name of station. Clicking the name of station opens **DeparturesViewController** 

## DeparturesViewController

All the transportation info for selected station is shown in a table

## PollutionDetailViewController

Shows the last 24 hour and last 7 days information of selected sensor

## HistoryViewController

All saved sensors data (Closest one to user location) are grouped daily and shown in a chart and table view. User can switch between days either swiping to the right or left or using the top buttons.

## Background Operations

User location is tracked in background and when a location update is retrieved, closest sensor data is saved. And if there is a dramatic change in air quality, user is also informed via system notification.

## APIs

https://api.luftdaten.info/v1/

https://efa-api.asw.io/api/v1/

http://istheutefeinstaubalarm.rocks/

## Libraries

Alamofire : https://github.com/Alamofire/Alamofire

Charts : https://github.com/danielgindi/Charts





