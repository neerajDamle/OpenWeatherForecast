//
//  Constants.swift
//  OpenWeatherForecast
//
//  Created by Neeraj Damle on 8/31/15.
//  Copyright (c) 2015 Neeraj Damle. All rights reserved.
//

import Foundation

//OpenWeatherMap app id
let OPEN_WEATHER_MAP_APP_ID = "44f61e4953fdec63c1ebab7b15d0f1f2";

//Weather map API request keys
let REQUEST_KEY_CITY_NAME = "q";
let REQUEST_KEY_CITY_ID = "id";
let REQUEST_KEY_DAY_COUNT = "cnt";
let REQUEST_KEY_APP_ID = "APPID";

//OpenWeatherMap API response keys
let RESPONSE_KEY_CITY = "city";
let RESPONSE_KEY_CITY_ID = "id";
let RESPONSE_KEY_CITY_NAME = "name";
let RESPONSE_KEY_CITY_GEO_COORDINATES = "coord";
let RESPONSE_KEY_LATITUDE = "lat";
let RESPONSE_KEY_LONGITUDE = "lon";
let RESPONSE_KEY_COUNTRY = "country";
let RESPONSE_KEY_COUNT = "cnt";
let RESPONSE_KEY_INTERNAL_CODE = "cod";
let RESPONSE_KEY_MESSAGE = "message";
let RESPONSE_KEY_LIST = "list";

let RESPONSE_KEY_WEATHER = "weather";
let RESPONSE_KEY_CONDITION_ID = "id";
let RESPONSE_KEY_ICON_ID = "icon";
let RESPONSE_KEY_GROUP_PARAMETERS = "main";
let RESPONSE_KEY_CONDITION_DESCRIPTION = "description"

let RESPONSE_KEY_CLOUDINESS = "clouds";
let RESPONSE_KEY_WIND_SPEED = "speed";
let RESPONSE_KEY_WIND_DIRECTION_IN_DEGREES = "deg";
let RESPONSE_KEY_HUMIDITY = "humidity"
let RESPONSE_KEY_PRESSURE = "pressure";
let RESPONSE_KEY_WEATHER_DATE = "dt";

let RESPONSE_KEY_TEMP = "temp";
let RESPONSE_KEY_MIN_DAILY_TEMP = "min";
let RESPONSE_KEY_MAX_DAILY_TEMP = "max";
let RESPONSE_KEY_MORNING_TEMP = "morn";
let RESPONSE_KEY_EVENING_TEMP = "eve";
let RESPONSE_KEY_NIGHT_TEMP = "night";
let RESPONSE_KEY_OVERALL_TEMP = "day";

//City details keys
let CITY_INFO_KEY_CITY_NAME = "CityName";

//Weather details tableview keys
let WEATHER_DETAIL_KEY_WEATHER_CONDITION_DESCRIPTION = "Condition";
let WEATHER_DETAIL_KEY_CLOUDINESS = "Cloudiness";
let WEATHER_DETAIL_KEY_WIND_SPEED = "Wind Speed";
let WEATHER_DETAIL_KEY_WIND_DIRECTION_IN_DEGREES = "Wind direction";
let WEATHER_DETAIL_KEY_HUMIDITY = "Humidity"
let WEATHER_DETAIL_KEY_PRESSURE = "Pressure";

let WEATHER_DETAIL_KEY_TEMP = "Temperature";
let WEATHER_DETAIL_KEY_MIN_DAILY_TEMP = "Min";
let WEATHER_DETAIL_KEY_MAX_DAILY_TEMP = "Max";
let WEATHER_DETAIL_KEY_MORNING_TEMP = "Morning";
let WEATHER_DETAIL_KEY_EVENING_TEMP = "Evening";
let WEATHER_DETAIL_KEY_NIGHT_TEMP = "Night";
let WEATHER_DETAIL_KEY_OVERALL_TEMP = "Day";

//Notification names
let NOTIFICATION_WEATHER_INFO_DOWNLOAD_COMPLETE = "WeatherInfoDownloadComplete";
let NOTIFICATION_WEATHER_INFO_DOWNLOAD_FAILED = "WeatherInfoDownloadFailed";
