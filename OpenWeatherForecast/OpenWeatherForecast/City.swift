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
    case new, downloading, downloaded, failed;
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
    var state: CityWeatherRecordState = CityWeatherRecordState.new;
    
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
    lazy var downloadsInProgressBasedOnName = Dictionary<String,Operation>();
    lazy var downloadsInProgressBasedOnId = Dictionary<Int,Operation>();
    lazy var downloadQueueBasedOnName: OperationQueue = {
        var queue = OperationQueue();
        queue.name = "City name based weather info download queue";
        return queue;
        }();
    lazy var downloadQueueBasedOnId: OperationQueue = {
        var queue = OperationQueue();
        queue.name = "City ID based weather info download queue";
        return queue;
        }();
}

class WeatherInfoDownloader : Operation
{
    let city: City;
    
    init(city: City)
    {
        self.city = city;
        self.city.state = CityWeatherRecordState.downloading;
    }
    
    override func main()
    {
        if(self.isCancelled)
        {
            self.city.state = CityWeatherRecordState.failed;
            return;
        }
        var strWeatherURL = self.city.weatherInfoURL;
        strWeatherURL = strWeatherURL.addingPercentEscapes(using: String.Encoding.utf8)!;
        print("Weather URL: \(strWeatherURL)");
        let weatherURL = URL(string: strWeatherURL);
        let weatherURLRequest = URLRequest(url: weatherURL!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10);
        var response: AutoreleasingUnsafeMutablePointer<URLResponse?>?=nil;
        var err: NSError? = nil;
        NSURLConnection.sendAsynchronousRequest(weatherURLRequest, queue: OperationQueue.main)
            { (response, data, err) -> Void in
//                println("Weather web service response: \(response)");
                
                do
                {
                    var serializationError: NSError?;
                    let jsonResult: [String:Any]! = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any];
                    print("JSON response: \(jsonResult)");
                    
                    let requestCityName = self.city.name;
                    var errorMessage: String = "";
                    
                    if(jsonResult != nil)
                    {
                        var isError = false;
                        repeat
                        {
                            if((jsonResult[RESPONSE_KEY_INTERNAL_CODE] as? String) == nil)
                            {
                                isError = true;
                                break;
                            }
                            let internalCode = jsonResult[RESPONSE_KEY_INTERNAL_CODE] as! String;
                            if(Int(internalCode) != 200)
                            {
                                isError = true;
                                if((jsonResult[RESPONSE_KEY_MESSAGE] as? String) != nil)
                                {
                                    errorMessage = jsonResult[RESPONSE_KEY_MESSAGE] as! String;
                                    print("Message: \(errorMessage)");
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
                            
                            if((jsonResult[RESPONSE_KEY_LIST] as? [[String:Any]]) == nil)
                            {
                                isError = true;
                                break;
                            }
                            let weatherForDays = jsonResult[RESPONSE_KEY_LIST] as! [[String:Any]]
                            
                            for weatherInfo in weatherForDays
                            {
                                if((weatherInfo as? [String:Any]) == nil)
                                {
                                    isError = true;
                                    break;
                                }
                                
                                let weather = Weather();

                                if((weatherInfo[RESPONSE_KEY_TEMP] as? [String:Any]) == nil)
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

                                let dayTemperature = DayTemperature();
                                dayTemperature.minDailyTemp = minDailyTemp;
                                dayTemperature.maxDailyTemp = maxDailyTemp;
                                dayTemperature.morningTemp = morningTemp;
                                dayTemperature.eveningTemp = eveningTemp;
                                dayTemperature.nightTemp = nightTemp;
                                dayTemperature.overAllTemp = overAllTemp;
                                
                                weather.temeperature = dayTemperature;

                                //Parse weather information
                                if((weatherInfo[RESPONSE_KEY_WEATHER] as? [[String:Any]]) == nil)
                                {
                                    isError = true;
                                    break;
                                }

                                let weatherGroupInfoArray = weatherInfo[RESPONSE_KEY_WEATHER] as! [[String:Any]];
                                for weatherGroupInfo in weatherGroupInfoArray
                                {
                                    let conditionID = weatherGroupInfo[RESPONSE_KEY_CONDITION_ID] as! Int;
                                    let iconID = weatherGroupInfo[RESPONSE_KEY_ICON_ID] as! String;
                                    let groupParameters = weatherGroupInfo[RESPONSE_KEY_GROUP_PARAMETERS] as! String;
                                    let conditionDescription = weatherGroupInfo[RESPONSE_KEY_CONDITION_DESCRIPTION] as! String;
                                    
                                    let weatherGroup = WeatherGroup();
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
                                let timeStamp = weatherInfo[RESPONSE_KEY_WEATHER_DATE] as! TimeInterval;
                                let date = Date(timeIntervalSince1970: timeStamp);
                                
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
                                self.city.state = CityWeatherRecordState.failed;
                                NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_WEATHER_INFO_DOWNLOAD_FAILED), object: nil, userInfo: [REQUEST_KEY_CITY_NAME:requestCityName,CITY_INFO_KEY_CITY_NAME:self.city.name, RESPONSE_KEY_MESSAGE:errorMessage]);
                                break;
                            }
                            
                            //Update state
                            self.city.state = CityWeatherRecordState.downloaded;
                            NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_WEATHER_INFO_DOWNLOAD_COMPLETE), object: nil, userInfo: [REQUEST_KEY_CITY_NAME:requestCityName,CITY_INFO_KEY_CITY_NAME:self.city.name]);
                        }while false
                        
                        if(isError)
                        {
                            self.city.state = CityWeatherRecordState.failed;
                            NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_WEATHER_INFO_DOWNLOAD_FAILED), object: nil, userInfo: [REQUEST_KEY_CITY_NAME:requestCityName,CITY_INFO_KEY_CITY_NAME:self.city.name,RESPONSE_KEY_MESSAGE:errorMessage]);
                        }
                    }
                    else
                    {
                        self.city.state = CityWeatherRecordState.failed;
                        NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_WEATHER_INFO_DOWNLOAD_FAILED), object: nil, userInfo: [REQUEST_KEY_CITY_NAME:requestCityName,CITY_INFO_KEY_CITY_NAME:self.city.name,RESPONSE_KEY_MESSAGE:errorMessage]);
                    }
                } catch {
                        
                    }
        }
    }
}

