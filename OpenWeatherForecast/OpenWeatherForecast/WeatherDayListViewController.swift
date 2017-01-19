//
//  WeatherDayListViewController.swift
//  OpenWeatherForecast
//
//  Created by Neeraj Damle on 9/1/15.
//  Copyright (c) 2015 Neeraj Damle. All rights reserved.
//

import UIKit

class WeatherDayListViewController: UIViewController {

    @IBOutlet var weatherDayTableView: UITableView!
    
    var city: City = City();
    var weatherDates: [String] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = self.city.name;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setSelectedCity(_ selectedCity: City)
    {
        self.city = selectedCity;
        
        //Extract dates
        for weather in self.city.weatherForDays
        {
            let weatherDate = weather.date;
            let dateFormatter = DateFormatter();
            dateFormatter.dateFormat = "EEE, MMM dd yyyy";
            let strDate = dateFormatter.string(from: weatherDate as Date);
            weatherDates.append(strDate);
        }
    }
    
    //UITableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return weatherDates.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let cell = weatherDayTableView.dequeueReusableCell(withIdentifier: "WeatherDateCell");
        
        let strDate = weatherDates[(indexPath as NSIndexPath).row];
        cell!.textLabel?.text = strDate;
        
        return cell!;
    }
    
    //UITableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        let selectedDayWeather = self.city.weatherForDays[(indexPath as NSIndexPath).row];
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil);
        let weatherDetailsViewController = storyBoard.instantiateViewController(withIdentifier: "WeatherDetailsViewController") as! WeatherDetailsViewController;
        weatherDetailsViewController.setSelectedDayWeather(selectedDayWeather);
        self.navigationController?.pushViewController(weatherDetailsViewController, animated: true);
        
        tableView.deselectRow(at: indexPath, animated: true);
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
