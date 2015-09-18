//
//  City.swift
//  OpenWeatherForecast
//
//  Created by Neeraj Damle on 8/28/15.
//  Copyright (c) 2015 Neeraj Damle. All rights reserved.
//

import UIKit

let WEATHER_INFO_BASE_URL_WITH_NAME = "http://api.openweathermap.org/data/2.5/forecast/daily?"
let WEATHER_INFO_BASE_URL_WITH_ID = "http://api.openweathermap.org/data/2.5/forecast/daily?"

// This enum contains all the possible states a city weather record can be in
enum CityWeatherRecordState
{
    case New, Downloading, Downloaded, Failed;
}

class GeoCoordinates
{
    var latitude = 0.0;
    var longitude = 0.0;
}

class City: NSObject
{
    var name: String = "";
    var id: Int = -1;
    var geoCoordinates = GeoCoordinates();
    var country: String = "";
    var noOfWeatherDays: Int = 14;
    var weatherForDays: [Weather] = [];
    var weatherInfoURL: String = "";
    var state: CityWeatherRecordState = CityWeatherRecordState.New;
    
    override init()
    {
        
    }
    
    init(name: String)
    {
        self.name = name;
        weatherInfoURL = WEATHER_INFO_BASE_URL_WITH_NAME;
        //Add city name
        weatherInfoURL += "\(REQUEST_KEY_CITY_NAME)="
        weatherInfoURL += name;
        //Add no of days
        weatherInfoURL += "&\(REQUEST_KEY_DAY_COUNT)=";
        weatherInfoURL += String(noOfWeatherDays);
        //Add App ID
        weatherInfoURL += "&\(REQUEST_KEY_APP_ID)=";
        weatherInfoURL += OPEN_WEATHER_MAP_APP_ID;
    }
    
    init(id: Int)
    {
        self.id = id;
        weatherInfoURL = WEATHER_INFO_BASE_URL_WITH_ID;
        //Add city id
        weatherInfoURL += "\(REQUEST_KEY_CITY_ID)="
        weatherInfoURL += String(id);
        //Add no of days
        weatherInfoURL += "&\(REQUEST_KEY_DAY_COUNT)=";
        weatherInfoURL += String(noOfWeatherDays);
        //Add App ID
        weatherInfoURL += "&\(REQUEST_KEY_APP_ID)=";
        weatherInfoURL += OPEN_WEATHER_MAP_APP_ID;
    }
}

class PendingOperations
{
    lazy var downloadsInProgressBasedOnName = Dictionary<String,NSOperation>();
    lazy var downloadsInProgressBasedOnId = Dictionary<Int,NSOperation>();
    lazy var downloadQueueBasedOnName: NSOperationQueue = {
        var queue = NSOperationQueue();
        queue.name = "City name based weather info download queue";
        return queue;
        }();
    lazy var downloadQueueBasedOnId: NSOperationQueue = {
        var queue = NSOperationQueue();
        queue.name = "City ID based weather info download queue";
        return queue;
        }();
}

class WeatherInfoDownloader : NSOperation
{
    let city: City;
    
    init(city: City)
    {
        self.city = city;
        self.city.state = CityWeatherRecordState.Downloading;
    }
    
    override func main()
    {
        if(self.cancelled)
        {
            self.city.state = CityWeatherRecordState.Failed;
            return;
        }
        var strWeatherURL = self.city.weatherInfoURL;
        strWeatherURL = strWeatherURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!;
        println("Weather URL: \(strWeatherURL)");
        let weatherURL = NSURL(string: strWeatherURL);
        let weatherURLRequest = NSURLRequest(URL: weatherURL!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10);
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil;
        var err: NSError? = nil;
        NSURLConnection.sendAsynchronousRequest(weatherURLRequest, queue: NSOperationQueue.mainQueue())
            { (response, data, err) -> Void in
                println("Weather web service response: \(response)");
                
                var serializationError: NSError?;
                var jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &serializationError) as? NSDictionary;
                println("JSON response: \(jsonResult)");
                
                var requestCityName = self.city.name;
                
                if(jsonResult != nil)
                {
                    var isError = false;
                    
                    do
                    {
                        if((jsonResult[RESPONSE_KEY_INTERNAL_CODE] as? String) == nil)
                        {
                            isError = true;
                            break;
                        }
                        let internalCode = jsonResult[RESPONSE_KEY_INTERNAL_CODE] as! String;
                        if(internalCode.toInt() != 200)
                        {
                            isError = true;
                            if((jsonResult[RESPONSE_KEY_MESSAGE] as? String) != nil)
                            {
                                let message = jsonResult[RESPONSE_KEY_MESSAGE] as! String;
                                println("Message: \(message)");
                            }
                            break;
                        }
                        
                        //Parse city info
                        if((jsonResult[RESPONSE_KEY_CITY] as? NSDictionary) != nil)
                        {
                            let cityInfo = jsonResult[RESPONSE_KEY_CITY] as! NSDictionary;
                            
                            //Parse City ID
                            if((cityInfo[RESPONSE_KEY_CITY_ID] as? Int) != nil)
                            {
                                let cityId = cityInfo[RESPONSE_KEY_CITY_ID] as! Int;
                                self.city.id = cityId;
                            }
                            
                            //Parse City Name
                            if((cityInfo[RESPONSE_KEY_CITY_NAME] as? String) != nil)
                            {
                                let cityName = cityInfo[RESPONSE_KEY_CITY_NAME] as! String;
                                self.city.name = cityName;
                            }
                            
                            //Parse City Geo Coordinates
                            if((cityInfo[RESPONSE_KEY_CITY_GEO_COORDINATES] as? NSDictionary) != nil)
                            {
                                let cityGeoCoords = cityInfo[RESPONSE_KEY_CITY_GEO_COORDINATES] as! NSDictionary;
                                let latitude = cityGeoCoords[RESPONSE_KEY_LATITUDE] as! Double;
                                let longitude = cityGeoCoords[RESPONSE_KEY_LONGITUDE] as! Double;
                                self.city.geoCoordinates.latitude = latitude;
                                self.city.geoCoordinates.longitude = longitude;
                            }
                            
                            //Parse country name
                            if((cityInfo[RESPONSE_KEY_COUNTRY] as? String) != nil)
                            {
                                let country = cityInfo[RESPONSE_KEY_COUNTRY] as! String;
                                self.city.country = country;
                            }
                        }
                        
                        if((jsonResult[RESPONSE_KEY_COUNT] as? Int) == nil)
                        {
                            isError = true;
                            break;
                        }
                        let dayCount = jsonResult[RESPONSE_KEY_COUNT] as! Int;
                        
                        if((jsonResult[RESPONSE_KEY_LIST] as? NSArray) == nil)
                        {
                            isError = true;
                            break;
                        }
                        let weatherForDays = jsonResult[RESPONSE_KEY_LIST] as! NSArray;
                        
                        for weatherInfo in weatherForDays
                        {
                            if((weatherInfo as? NSDictionary) == nil)
                            {
                                isError = true;
                                break;
                            }
                            
                            var weather = Weather();
                            
                            if((weatherInfo[RESPONSE_KEY_TEMP] as? NSDictionary) == nil)
                            {
                                isError = true;
                                break;
                            }
                            
                            //Parse temperature information
                            let tempInfo = weatherInfo[RESPONSE_KEY_TEMP] as! NSDictionary;
                            let minDailyTemp = tempInfo[RESPONSE_KEY_MIN_DAILY_TEMP] as! Double;
                            let maxDailyTemp = tempInfo[RESPONSE_KEY_MAX_DAILY_TEMP] as! Double;
                            let morningTemp = tempInfo[RESPONSE_KEY_MORNING_TEMP] as! Double;
                            let eveningTemp = tempInfo[RESPONSE_KEY_EVENING_TEMP] as! Double;
                            let nightTemp = tempInfo[RESPONSE_KEY_NIGHT_TEMP] as! Double;
                            let overAllTemp = tempInfo[RESPONSE_KEY_OVERALL_TEMP] as! Double;
                            
                            var dayTemperature = DayTemperature();
                            dayTemperature.minDailyTemp = minDailyTemp;
                            dayTemperature.maxDailyTemp = maxDailyTemp;
                            dayTemperature.morningTemp = morningTemp;
                            dayTemperature.eveningTemp = eveningTemp;
                            dayTemperature.nightTemp = nightTemp;
                            dayTemperature.overAllTemp = overAllTemp;
                            
                            weather.temeperature = dayTemperature;
                            
                            //Parse weather information
                            if((weatherInfo[RESPONSE_KEY_WEATHER] as? NSArray) == nil)
                            {
                                isError = true;
                                break;
                            }
                            
                            let weatherGroupInfoArray = weatherInfo[RESPONSE_KEY_WEATHER] as! NSArray;
                            for weatherGroupInfo in weatherGroupInfoArray
                            {
                                let conditionID = weatherGroupInfo[RESPONSE_KEY_CONDITION_ID] as! Int;
                                let iconID = weatherGroupInfo[RESPONSE_KEY_ICON_ID] as! String;
                                let groupParameters = weatherGroupInfo[RESPONSE_KEY_GROUP_PARAMETERS] as! String;
                                let conditionDescription = weatherGroupInfo[RESPONSE_KEY_CONDITION_DESCRIPTION] as! String;
                                
                                var weatherGroup = WeatherGroup();
                                weatherGroup.conditionID = conditionID;
                                weatherGroup.iconID = iconID;
                                weatherGroup.groupParameters = groupParameters;
                                weatherGroup.conditionDescription = conditionDescription;
                                
                                weather.weatherGroups.append(weatherGroup);
                            }
                            
                            let cloudiness = weatherInfo[RESPONSE_KEY_CLOUDINESS] as! Double;
                            let windSpeed = weatherInfo[RESPONSE_KEY_WIND_SPEED] as! Double;
                            let windDirectionInDegrees = weatherInfo[RESPONSE_KEY_WIND_DIRECTION_IN_DEGREES] as! Double;
                            let humidity = weatherInfo[RESPONSE_KEY_HUMIDITY] as! Double;
                            let pressure = weatherInfo[RESPONSE_KEY_PRESSURE] as! Double;
                            let timeStamp = weatherInfo[RESPONSE_KEY_WEATHER_DATE] as! NSTimeInterval;
                            let date = NSDate(timeIntervalSince1970: timeStamp);
                            
                            weather.cloudiness = cloudiness;
                            weather.windSpeed = windSpeed;
                            weather.windDirectionInDegrees = windDirectionInDegrees;
                            weather.humidity = humidity;
                            weather.pressure = pressure;
                            weather.date = date;
                            
                            self.city.weatherForDays.append(weather);
                        }
                        
                        if(isError)
                        {
                            self.city.state = CityWeatherRecordState.Failed;
                            NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_WEATHER_INFO_DOWNLOAD_FAILED, object: nil, userInfo: [REQUEST_KEY_CITY_NAME:requestCityName,CITY_INFO_KEY_CITY_NAME:self.city.name]);
                            break;
                        }
                        
                        //Update state
                        self.city.state = CityWeatherRecordState.Downloaded;
                        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_WEATHER_INFO_DOWNLOAD_COMPLETE, object: nil, userInfo: [REQUEST_KEY_CITY_NAME:requestCityName,CITY_INFO_KEY_CITY_NAME:self.city.name]);
                    }while false
                    
                    if(isError)
                    {
                        self.city.state = CityWeatherRecordState.Failed;
                        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_WEATHER_INFO_DOWNLOAD_FAILED, object: nil, userInfo: [REQUEST_KEY_CITY_NAME:requestCityName,CITY_INFO_KEY_CITY_NAME:self.city.name]);
                    }
                }
                else
                {
                    self.city.state = CityWeatherRecordState.Failed;
                    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_WEATHER_INFO_DOWNLOAD_FAILED, object: nil, userInfo: [REQUEST_KEY_CITY_NAME:requestCityName,CITY_INFO_KEY_CITY_NAME:self.city.name]);
                }
        }
    }
}

