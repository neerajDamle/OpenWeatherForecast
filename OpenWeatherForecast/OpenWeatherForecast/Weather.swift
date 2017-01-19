//
//  Weather.swift
//  OpenWeatherForecast
//
//  Created by Neeraj Damle on 8/31/15.
//  Copyright (c) 2015 Neeraj Damle. All rights reserved.
//

import UIKit

class DayTemperature
{
    //Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit
    var minDailyTemp = 0.0;
    var maxDailyTemp = 0.0;
    var morningTemp = 0.0;
    var eveningTemp = 0.0;
    var nightTemp = 0.0;
    var overAllTemp = 0.0;
}

class WeatherGroup
{
    var conditionID = 0;
    var iconID = "";
    var groupParameters = "";
    var conditionDescription = "";
}

class Weather: NSObject
{
    var cloudiness = 0.0;   //In %
    
    var windSpeed = 0.0;    //Unit Default: meter/sec, Metric: meter/sec, Imperial: miles/hour
    var windDirectionInDegrees = 0.0;
    
    var humidity = 0.0; //In %
    
    var pressure = 0.0; //Atmospheric pressure on the sea level, hPa
    
    var date = Date();
    
    var temeperature = DayTemperature();
    var weatherGroups: [WeatherGroup] = [];
    
    override init() {
        
    }
}
