//
//  WeatherDetailsViewController.swift
//  OpenWeatherForecast
//
//  Created by Neeraj Damle on 9/1/15.
//  Copyright (c) 2015 Neeraj Damle. All rights reserved.
//

import UIKit

class WeatherDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var weatherDetailsTableView: UITableView!
    
    var cellTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer();
    var isTemperatureCellCollapsed = true;
    var tempCellHeight: CGFloat = 44.0;
    
    var weather: Weather = Weather();
    var weatherParameters: [String] = [WEATHER_DETAIL_KEY_WEATHER_CONDITION_DESCRIPTION,WEATHER_DETAIL_KEY_CLOUDINESS,WEATHER_DETAIL_KEY_WIND_SPEED,WEATHER_DETAIL_KEY_WIND_DIRECTION_IN_DEGREES,WEATHER_DETAIL_KEY_HUMIDITY,WEATHER_DETAIL_KEY_PRESSURE,WEATHER_DETAIL_KEY_TEMP];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cellTapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(WeatherDetailsViewController.collapsableCellTapped(_:)));
        cellTapGestureRecognizer.numberOfTapsRequired = 1;
        
        let weatherDate = weather.date;
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "EEE, MMM dd yyyy";
        let strDate = dateFormatter.string(from: weatherDate as Date);
        self.navigationItem.title = strDate;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setSelectedDayWeather(_ weather: Weather)
    {
        self.weather = weather;
    }

    func getValueForWeatherParameter(_ weatherParameter: String) -> String
    {
        var weatherParameterValue: String = "";
        
        if(weatherParameter == WEATHER_DETAIL_KEY_WEATHER_CONDITION_DESCRIPTION)
        {
            weatherParameterValue = self.weather.weatherGroups[0].conditionDescription;
        }
        else if(weatherParameter == WEATHER_DETAIL_KEY_CLOUDINESS)
        {
            weatherParameterValue = String(format:"%.1f",self.weather.cloudiness);
            weatherParameterValue += "%";
        }
        else if(weatherParameter == WEATHER_DETAIL_KEY_WIND_SPEED)
        {
            weatherParameterValue = String(format:"%.1f",self.weather.windSpeed);
            weatherParameterValue += " m/sec";
        }
        else if(weatherParameter == WEATHER_DETAIL_KEY_WIND_DIRECTION_IN_DEGREES)
        {
            weatherParameterValue = String(format:"%.1f",self.weather.windDirectionInDegrees);
            weatherParameterValue += " degrees";
        }
        else if(weatherParameter == WEATHER_DETAIL_KEY_HUMIDITY)
        {
            weatherParameterValue = String(format:"%.1f",self.weather.humidity);
            weatherParameterValue += "%";
        }
        else if(weatherParameter == WEATHER_DETAIL_KEY_PRESSURE)
        {
            weatherParameterValue = String(format:"%.1f",self.weather.pressure);
            weatherParameterValue += " hPa";
        }
        else if(weatherParameter == WEATHER_DETAIL_KEY_TEMP)
        {
            //For Kelvin
//            weatherParameterValue = String(format:"%.2f",self.weather.temeperature.overAllTemp);
//            weatherParameterValue += " Kelvin";
            
            //For Celsius
            weatherParameterValue = String(format:"%.2f",self.getCelsiusForKelvin(self.weather.temeperature.overAllTemp));
            weatherParameterValue += " Celsius";
        }
        return weatherParameterValue;
    }
    
    func getCelsiusForKelvin(_ tempInKelvin: Double) -> Double
    {
        let tempInCelsius: Double = tempInKelvin - 273.15;
        return tempInCelsius;
    }
    
    //Tap geture recognizer callback
    @IBAction func collapsableCellTapped(_ sender: AnyObject)
    {
        if(isTemperatureCellCollapsed)
        {
            tempCellHeight = 204.0;
            isTemperatureCellCollapsed = false;
        }
        else
        {
            tempCellHeight = 44.0
            isTemperatureCellCollapsed = true;
        }
//        isTemperatureCellCollapsed != isTemperatureCellCollapsed;
//        weatherDetailsTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top);
        weatherDetailsTableView.reloadData();
    }
    
    //UITableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return weatherParameters.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let weatherParameter = weatherParameters[(indexPath as NSIndexPath).row];

        if(weatherParameter != WEATHER_DETAIL_KEY_TEMP)
        {
            let cell = weatherDetailsTableView.dequeueReusableCell(withIdentifier: "WeatherParameterCell") ;
            cell!.textLabel?.text = weatherParameter;
            let weatherParameterValue = self.getValueForWeatherParameter(weatherParameter);
            cell!.detailTextLabel?.text = weatherParameterValue;
            
            cell!.selectionStyle = UITableViewCellSelectionStyle.none;
            cell!.accessoryType = UITableViewCellAccessoryType.none;
            
            return cell!;
        }
        else
        {
            let cell: CollapsableTableViewCell = weatherDetailsTableView.dequeueReusableCell(withIdentifier: "WeatherParameterCollapsableCell") as! CollapsableTableViewCell;
            cell.setSelectedDayTemperature(self.weather.temeperature);
            cell.textLbl.text = weatherParameter;
            let weatherParameterValue = self.getValueForWeatherParameter(weatherParameter);
            cell.detailTextLbl.text = weatherParameterValue;
            cell.addGestureRecognizer(cellTapGestureRecognizer);
            cell.selectionStyle = UITableViewCellSelectionStyle.none;
            cell.accessoryType = UITableViewCellAccessoryType.none;
            
            UIView.animate(withDuration: TimeInterval(0.8), delay: TimeInterval(0.0), options: [], animations: { () -> Void in
                
                cell.temperatureDetailsTableView.isHidden = self.isTemperatureCellCollapsed;
                return;
                }, completion: { (finished: Bool) -> Void in
                    var img: UIImage;
                    if(self.isTemperatureCellCollapsed)
                    {
                        img = UIImage(named: "CollapseArrow")!;
                    }
                    else
                    {
                        img = UIImage(named: "ExpandArrow")!;
                    }
                    cell.expandCollapseArrowImageView.image = img;
            })
            
            return cell;
        }
    }
    
    //UITableView delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var cellHeight: CGFloat = 44.0;
        let weatherParameter = weatherParameters[(indexPath as NSIndexPath).row];
        if(weatherParameter == WEATHER_DETAIL_KEY_TEMP)
        {
            cellHeight = tempCellHeight;
        }
        return cellHeight;
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
