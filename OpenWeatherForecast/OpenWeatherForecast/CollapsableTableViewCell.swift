//
//  CollapsableTableViewCell.swift
//  OpenWeatherForecast
//
//  Created by Neeraj Damle on 9/2/15.
//  Copyright (c) 2015 Neeraj Damle. All rights reserved.
//

import UIKit

class CollapsableTableViewCell: UITableViewCell {

    @IBOutlet var expandCollapseArrowImageView: UIImageView!
    @IBOutlet var textLbl: UILabel!
    @IBOutlet var detailTextLbl: UILabel!
    @IBOutlet var temperatureDetailsTableView: UITableView!
    
    var dayTemperature: DayTemperature = DayTemperature();
    var dayTemperatureParameters: [String] = [WEATHER_DETAIL_KEY_MIN_DAILY_TEMP,WEATHER_DETAIL_KEY_MAX_DAILY_TEMP,WEATHER_DETAIL_KEY_MORNING_TEMP,WEATHER_DETAIL_KEY_EVENING_TEMP,WEATHER_DETAIL_KEY_NIGHT_TEMP];
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setSelectedDayTemperature(dayTemperature: DayTemperature)
    {
        self.dayTemperature = dayTemperature;
    }
    
    func getValueForTemperatureParameter(temperatureParameter: String) -> String
    {
        var temperatureParameterValueInKelvin: String = "";
        var temperatureParameterValueInCelsius: String = "";
        
        if(temperatureParameter == WEATHER_DETAIL_KEY_MIN_DAILY_TEMP)
        {
            temperatureParameterValueInKelvin = String(format:"%.2f",self.dayTemperature.minDailyTemp);
            temperatureParameterValueInKelvin += " Kelvin";
            
            temperatureParameterValueInCelsius = String(format:"%.2f",self.getCelsiusForKelvin(self.dayTemperature.minDailyTemp));
            temperatureParameterValueInCelsius += " Celsius";
        }
        else if(temperatureParameter == WEATHER_DETAIL_KEY_MAX_DAILY_TEMP)
        {
            temperatureParameterValueInKelvin = String(format:"%.2f",self.dayTemperature.maxDailyTemp);
            temperatureParameterValueInKelvin += " Kelvin";
            
            temperatureParameterValueInCelsius = String(format:"%.2f",self.getCelsiusForKelvin(self.dayTemperature.maxDailyTemp));
            temperatureParameterValueInCelsius += " Celsius";
        }
        else if(temperatureParameter == WEATHER_DETAIL_KEY_MORNING_TEMP)
        {
            temperatureParameterValueInKelvin = String(format:"%.2f",self.dayTemperature.morningTemp);
            temperatureParameterValueInKelvin += " Kelvin";
            
            temperatureParameterValueInCelsius = String(format:"%.2f",self.getCelsiusForKelvin(self.dayTemperature.morningTemp));
            temperatureParameterValueInCelsius += " Celsius";
        }
        else if(temperatureParameter == WEATHER_DETAIL_KEY_EVENING_TEMP)
        {
            temperatureParameterValueInKelvin = String(format:"%.2f",self.dayTemperature.eveningTemp);
            temperatureParameterValueInKelvin += " Kelvin";
            
            temperatureParameterValueInCelsius = String(format:"%.2f",self.getCelsiusForKelvin(self.dayTemperature.eveningTemp));
            temperatureParameterValueInCelsius += " Celsius";
        }
        else if(temperatureParameter == WEATHER_DETAIL_KEY_NIGHT_TEMP)
        {
            temperatureParameterValueInKelvin = String(format:"%.2f",self.dayTemperature.nightTemp);
            temperatureParameterValueInKelvin += " Kelvin";
            
            temperatureParameterValueInCelsius = String(format:"%.2f",self.getCelsiusForKelvin(self.dayTemperature.nightTemp));
            temperatureParameterValueInCelsius += " Celsius";
        }
        return temperatureParameterValueInCelsius;
    }
    
    func getCelsiusForKelvin(tempInKelvin: Double) -> Double
    {
        let tempInCelsius: Double = tempInKelvin - 273.15;
        return tempInCelsius;
    }
    
    //UITableView datasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dayTemperatureParameters.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell = temperatureDetailsTableView.dequeueReusableCellWithIdentifier("DayTemperatureParameterCell") as! UITableViewCell;
        
        let dayTemperatureParameter = dayTemperatureParameters[indexPath.row];
        cell.textLabel?.text = dayTemperatureParameter;
        let temperatureParameterValue = self.getValueForTemperatureParameter(dayTemperatureParameter);
        cell.detailTextLabel?.text = temperatureParameterValue;
        
        return cell;
    }
}
