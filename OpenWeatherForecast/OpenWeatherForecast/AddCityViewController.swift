//
//  AddCityViewController.swift
//  OpenWeatherForecast
//
//  Created by Neeraj Damle on 8/28/15.
//  Copyright (c) 2015 Neeraj Damle. All rights reserved.
//

import UIKit
import CoreLocation

class AddCityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate
{
    @IBOutlet var cityNameTextfield: UITextField!
    @IBOutlet var addCityBtn: UIButton!
    @IBOutlet var cityListTableView: UITableView!
    
    var cities: [City] = [];
    
    let pendingOperations = PendingOperations();
    
    var locationManager: CLLocationManager!;
    var locationStatus : NSString = "Not Started";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        self.navigationItem.title = "Open Weather Map";
        
        cityNameTextfield.layer.cornerRadius = 8.0;
        cityNameTextfield.layer.masksToBounds = true;
        cityNameTextfield.layer.borderColor = UIColor.black.cgColor;
        cityNameTextfield.layer.borderWidth = 1.0;
        
        self.registerForNotifications();
        
        //Get location access
        locationManager = CLLocationManager();
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        if #available(iOS 8.0, *) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Fallback on earlier versions
        };
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func registerForNotifications()
    {
        let notificationCenter = NotificationCenter.default;
        let mainQueue = OperationQueue.main;
        
        _ = notificationCenter.addObserver(forName: NSNotification.Name(rawValue: NOTIFICATION_WEATHER_INFO_DOWNLOAD_COMPLETE), object: nil, queue: mainQueue) { (notification) -> Void in
            let cityInfo:Dictionary<String, String?> = (notification as NSNotification).userInfo as! Dictionary<String, String?>;
            let requestCityName = cityInfo[REQUEST_KEY_CITY_NAME];
            let cityName = cityInfo[CITY_INFO_KEY_CITY_NAME];
            print("Weather info download complete notification received for city \(cityName)");
            
            //Update city name as per response
            self.updateCityNameAsPerResponse(requestCityName!!, actualCityName: cityName!!);
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.cityListTableView.reloadData();
            })
        }
        
        _ = notificationCenter.addObserver(forName: NSNotification.Name(rawValue: NOTIFICATION_WEATHER_INFO_DOWNLOAD_FAILED), object: nil, queue: mainQueue) { (notification) -> Void in
            let cityInfo:Dictionary<String, String?> = (notification as NSNotification).userInfo as! Dictionary<String, String?>;
            let cityName = cityInfo[CITY_INFO_KEY_CITY_NAME];
            print("Weather info download failed notification received for city \(cityName)");
            
            let errorMessage = cityInfo[RESPONSE_KEY_MESSAGE];
            
            JLToast.makeText(errorMessage!!, duration: JLToastDelay.ShortDelay).show()
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.cityListTableView.reloadData();
            })
        }
    }
    
    func deregisterNotifications()
    {
        NotificationCenter.default.removeObserver(self);
    }
    
    func updateCityNameAsPerResponse(_ requestedCityName: String, actualCityName: String)
    {
        //Update only if the names differ
        if(requestedCityName != actualCityName)
        {
            for city in cities
            {
                if(city.name == requestedCityName)
                {
                    city.name = actualCityName;
                    break;
                }
            }
        }
    }
    
    func checkIfCityAlreadyAdded(_ cityNameToCheck: String) -> Bool
    {
        var isCityAlreadyAdded = false;
        for currentCity in cities
        {
            if(currentCity.name.caseInsensitiveCompare(cityNameToCheck) == ComparisonResult.orderedSame)
            {
                isCityAlreadyAdded = true;
                break;
            }
        }
        
        return isCityAlreadyAdded;
    }
    
    //Download weather info
    func startWeatherInfoDownload(_ city: City)
    {
        let weatherDownloader = WeatherInfoDownloader(city: city);
        
        //Add operation to pending operation
        pendingOperations.downloadsInProgressBasedOnName[city.name] = weatherDownloader;
        pendingOperations.downloadQueueBasedOnName.addOperation(weatherDownloader);
    }
    
    //Update UI for new city and start weather info download
    func fetchWeatherInfoForCity(_ cityName: String)
    {
        if(cityListTableView.isHidden)
        {
            //Show city list
            cityListTableView.isHidden = false;
        }
        
        //Refresh city list
        cityListTableView.reloadData();
        
        //Clear text field
        cityNameTextfield.text = "";
        
        //Create City object
        let addedCity = City(name: cityName);
        
        //Add city to the data source
        cities.append(addedCity);
        
        switch(addedCity.state)
        {
        case CityWeatherRecordState.new:
            print("Start weather info download");
            self.startWeatherInfoDownload(addedCity);
            
//            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
//            dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
//                self.startWeatherInfoDownload(addedCity);
//            })
        case CityWeatherRecordState.downloading:
            print("Weather info being downloaded");
        default:
            print("Unknown state");
        }
    }
    
    //Button click callbacks
    @IBAction func addCityBtnPressed(_ sender: AnyObject)
    {
        var cityName = cityNameTextfield.text;
        cityName = cityName!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);
        if (!cityName!.isEmpty)
        {
            //Check if city is already added
            let isCityAlreadyAdded = self.checkIfCityAlreadyAdded(cityName!);
            if(!isCityAlreadyAdded)
            {
                self.fetchWeatherInfoForCity(cityName!);
            }
            else
            {
                print("This city is already added");
            }
            
            //Dismiss keyboard
            cityNameTextfield.resignFirstResponder();
        }
    }
    
    //Location Manager delegate
    func locationManager(_ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus) {
            var shouldIAllow = false
            
            switch status
            {
                case CLAuthorizationStatus.restricted:
                    locationStatus = "Restricted Access to location"
                case CLAuthorizationStatus.denied:
                    locationStatus = "User denied access to location"
                case CLAuthorizationStatus.notDetermined:
                    locationStatus = "Status not determined"
                default:
                    locationStatus = "Allowed location Access"
                    shouldIAllow = true
            }
            
            if (shouldIAllow == true)
            {
                // Start location services
                locationManager.startUpdatingLocation()
            }
            else
            {
                NSLog("Denied access: \(locationStatus)")
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        locationManager.stopUpdatingLocation()
//        if (error != nil)
//        {
            print(error, terminator: "")
//        }
    }
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations:[CLLocation])
    {
        let locationArray = locations as NSArray;
        let locationObj = locationArray.lastObject as! CLLocation;
        let coord = locationObj.coordinate;
        
        print("Latitude: \(coord.latitude)");
        print("Longitude: \(coord.longitude)");
        
        locationManager.stopUpdatingLocation();
        
        //Get address details using geo coordinates
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            let placeArray = placemarks
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            let addressDict = placeMark.addressDictionary;
            
            // Address dictionary
            print(addressDict)
            
            // Location name
            if let locationName = placeMark.addressDictionary?["Name"] as? NSString {
                print(locationName)
            }
            
            // Street address
            if let street = placeMark.addressDictionary?["Thoroughfare"] as? NSString {
                print(street)
            }
            
            // City
            if let city = placeMark.addressDictionary?["City"] as? NSString {
                print(city)
            }
            
            // Zip code
            if let zip = placeMark.addressDictionary?["ZIP"] as? NSString {
                print(zip)
            }
            
            // Country
            if let country = placeMark.addressDictionary?["Country"] as? NSString {
                print(country)
            }
            
            var cityName = placeMark.addressDictionary?["City"] as! String;
            cityName = cityName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);
            if (!cityName.isEmpty)
            {
                //Check if city is already added
                let isCityAlreadyAdded = self.checkIfCityAlreadyAdded(cityName);
                if(!isCityAlreadyAdded)
                {
                    self.fetchWeatherInfoForCity(cityName);
                }
                else
                {
                    print("This city is already added");
                }
            }
        })
    }
    
    //UITableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return cities.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: CityNameTableViewCell = cityListTableView.dequeueReusableCell(withIdentifier: "CityNameCell") as! CityNameTableViewCell;
        
        let city = cities[(indexPath as NSIndexPath).row];
        let cityName = city.name;
        cell.cityNameLabel.text = cityName;
        if((city.state == CityWeatherRecordState.new) || (city.state == CityWeatherRecordState.downloading))
        {
            cell.selectionStyle = UITableViewCellSelectionStyle.none;
            cell.accessoryType = UITableViewCellAccessoryType.none;
            cell.isUserInteractionEnabled = false;
            cell.cityNameLabel.isEnabled = false;
            
            let progressImage = UIImage(named: "SyncIcon");
            cell.progressIconImageView.image = progressImage;

            //Animate sync icon to indicate progress
            UIView.animate(withDuration: TimeInterval(0.8), delay: TimeInterval(0.0), options: UIViewAnimationOptions.repeat, animations: { () -> Void in
                cell.progressIconImageView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI*180 / 180.0));
                return;
                }, completion: { (finished: Bool) -> Void in
                    return;
            })
        }
        else if(city.state == CityWeatherRecordState.downloaded)
        {
            cell.selectionStyle = UITableViewCellSelectionStyle.default;
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator;
            cell.isUserInteractionEnabled = true;
            cell.cityNameLabel.isEnabled = true;
            
            cell.progressIconImageView.image = nil;
        }
        else if(city.state == CityWeatherRecordState.failed)
        {
            cell.selectionStyle = UITableViewCellSelectionStyle.default;
            cell.accessoryType = UITableViewCellAccessoryType.none;
            cell.isUserInteractionEnabled = true;
            cell.cityNameLabel.isEnabled = false;
            
            cell.progressIconImageView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI*360 / 180.0));
            
            let failureImage = UIImage(named: "SyncFailureIcon");
            cell.progressIconImageView.image = failureImage;
        }
        
        return cell;
    }
    
    
    //UITableView delegate
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete)
        {
            // Handle delete (by removing the data from your array and updating the tableview)
            let city = cities[(indexPath as NSIndexPath).row];
            let cityName = city.name;
            print("City to delete: \(cityName)");
            
            cities.remove(at: (indexPath as NSIndexPath).row);
            cityListTableView.deleteRows(
                at: [indexPath], with: UITableViewRowAnimation.automatic);
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let city = cities[(indexPath as NSIndexPath).row];
//        let cityName = city.name;
        if(city.state == CityWeatherRecordState.downloaded)
        {
            //Show WeatherDayListViewController with list of days
            let selectedCity = cities[(indexPath as NSIndexPath).row];
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil);
            let weatherDayListViewController = storyBoard.instantiateViewController(withIdentifier: "WeatherDayListViewController") as! WeatherDayListViewController;
            weatherDayListViewController.setSelectedCity(selectedCity);
            self.navigationController?.pushViewController(weatherDayListViewController, animated: true);
        }
        else if(city.state == CityWeatherRecordState.failed)
        {
            //Retry for weather info
            self.startWeatherInfoDownload(city);
        }
        
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    //UITextField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        cityNameTextfield.resignFirstResponder();
        return true;
    }
}

