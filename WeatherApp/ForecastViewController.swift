//
//  ViewController.swift
//  WeatherApp
//
//  Created by Mitchell Zeiter on 6/22/18.
//  Copyright © 2018 Mitchell Zeiter. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import AddressBookUI




class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    

    
    @IBOutlet weak var testBtn: UIButton!
    @IBOutlet weak var todayLbl: UILabel!
    @IBOutlet weak var currentDayLbl: UILabel!
    @IBOutlet weak var currentHighLbl: UILabel!
    @IBOutlet weak var currentLowLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var currentTempLbl: UILabel!
    @IBOutlet weak var currentConditionLbl: UILabel!
    @IBOutlet weak var currentPic: UIImageView!
    @IBOutlet weak var hourlyForecastCollectionView: UICollectionView!
    @IBOutlet weak var dailyForecastCollectionView: UICollectionView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    
    
    var currentWeather = CurrentWeather()
    var dailyWeather: [DailyWeather] = []
    var settingsVC = SettingsViewController()
    
    
    var zipCode : String = ""
    var exists: Bool = true
    
    var locationManager = CLLocationManager()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        //location stuff
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
        }
   
        
        
        
        dailyForecastCollectionView.delegate = self
        dailyForecastCollectionView.dataSource = self
        
        hourlyForecastCollectionView.delegate = self
        hourlyForecastCollectionView.dataSource = self
        
        hourlyForecastCollectionView.layer.borderColor = UIColor.darkGray.cgColor
        hourlyForecastCollectionView.layer.borderWidth = 0.25
        

        
        

        // Do any additional setup after loading the view.
    }
    
    
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        
        
        if let location = locations.first{
        locationManager.stopUpdatingLocation()

        
        print("locations = \(location.coordinate.latitude) \(location.coordinate.longitude)")
            
        reverseGeocoding(lat: location.coordinate.latitude, long: location.coordinate.longitude)
        
    
            
        }
        
        print("sup")
        

        
        
    }


    
    
    
    
    //Converts a zipcode into latitude and longitude

    func forwardGeocoding(zipcode: String) {
        CLGeocoder().geocodeAddressString(zipcode, completionHandler: { (placemarks, error) in
            
            let currentWeather = CurrentWeather()

            if error != nil {
                print(error!)
                print("Invalid zipcode!")
                
                
                let alert = UIAlertController(title: "Error", message: "Invalid zipcode entered.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)

                
                return
            }
            if placemarks!.count > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                
                let lat = coordinate!.latitude
                let long = coordinate!.longitude
                
                currentWeather.location = (placemark?.addressDictionary!["City"] as? String)!

                print ("Geocode city is  \((currentWeather.location))")
                print("Geocode lat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
                
                self.currentWeather = currentWeather
                
                self.cityLbl.text = self.currentWeather.location
                
                self.getCurrentWeather(lat: lat, long: long)
                
            }
            
            
        })
        
        
    }
    
    func reverseGeocoding (lat: Double, long: Double){
        
        print ("STARTING REVERSE GEO")
        let location = CLLocation(latitude: lat, longitude: long) //changed!!!
        print(location)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            print(location)
            
            let currentWeather = CurrentWeather()

            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = placemarks![0]
                print(pm.locality!)
                
    
                let placemark = placemarks?[0]
                
                currentWeather.location = (placemark?.addressDictionary!["City"] as? String)!
                
                print ("Reverse Geocode city is  \((currentWeather.location))")
                print("Reverse Geocode lat: \(lat), long: \(long)")
                
                
                
                self.currentWeather = currentWeather
                
                self.cityLbl.text = self.currentWeather.location
                
                self.getCurrentWeather(lat: lat, long: long)
                
                
                
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    
    //gets TODAY'S date
    func getDate () -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayString: String = dateFormatter.string(from: date)
        print("Current date is \(dayString)")
        return dayString
        
    }
    
    //Gets next 6 days of week based on today
    func getDaysOfWeek () -> Array<String> {
        
        var daysOfWeekArray : [String] = ["", "","", "","", ""] //array has 6
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        for i in 1...6 {
            let nextDay = NSCalendar.current.date(byAdding: Calendar.Component.day,
                                                  value: i,
                                                  to: date as Date)
            dateFormatter.dateFormat = "EEEE"
            let dayString: String = dateFormatter.string(from: nextDay!)
            daysOfWeekArray[i-1] = dayString
        }
        
        return daysOfWeekArray
        
    }
    
    
    //Gets next 24 hours starting with current time
    func getHoursOfDay () -> Array<String> {
        
        var hoursOfDayArray : [String] = ["", "","", "","", "", "", "", "", "", "", "","", "","", "", "", "", "", "", "", "","", "", ""] //array has 25
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
       
        for i in 1...25 {
            let nextDay = NSCalendar.current.date(byAdding: Calendar.Component.hour,
                                                  value: i-1,
                                                  to: date as Date)
            let dayString: String = dateFormatter.string(from: nextDay!)
            hoursOfDayArray[i-1] = dayString
        }
        
        return hoursOfDayArray

    }
    
    
    //User clicks edit button
    @IBAction func editBtnPressed(_ sender: Any) {
        locationAlert(title: "Edit Location", message: "Enter your postal code below.")
    }
    
    
    //Location alert asks user for zipcode
    func locationAlert (title: String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField{ (textField: UITextField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "e.g. 32256"
        }
        
        let OKAction = UIAlertAction(title: "OK", style: .default)  {  _ in
            self.zipCode = alert.textFields?[0].text ?? ""
            print ("\nZipcode entered by user: \(self.zipCode)")
            
            self.forwardGeocoding(zipcode: self.zipCode)
            
        }
        
        
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
        

    }
    
    
    
    
    //Test button to check values of vars
    @IBAction func testBtnPressed(_ sender: Any) {
        if let value = UserDefaults.standard.value(forKey: "chosenDegree"){
            let selectedIndex = value as! Int
            
            print("Segment Control Test : \(selectedIndex)")
        }
    }

    

    //Gets current weather data
    func getCurrentWeather(lat: Double, long: Double) {

        
        let urlRequest = URLRequest(url: URL(string: "https://api.darksky.net/forecast/382765538514b141e907ccb338fac67c/\(lat)" + ",\(long)")!)
        
        print ("-----url-----\(urlRequest)")
        let task = URLSession.shared.dataTask(with: urlRequest) { (data,response, error) in
        print("test")
            
            if error == nil{
                
                let currentWeather = CurrentWeather()
                let dailyWeather = NSMutableArray()
                let hourlyWeather = NSMutableArray()

                
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                    
                    //'currently' parent
                    if let currently = json["currently"] as? [String : AnyObject] {
                    
                        
                        if let temperature = currently["temperature"] as? Double {
                            currentWeather.currentTemp = temperature
                        }
                        if let icon = currently["icon"] as? String {
                            currentWeather.currentImg = UIImage (named: icon)
                        }
                        if let summary = currently["summary"] as? String {
                            currentWeather.currentCondition = summary
                        }
                        
                    }
                    //'hourly' parent
                    //set up for loop here
                    for i in 0...24{
                        // 'hour' object created
                        let hour = HourlyWeather()

                        if let hourly = json["hourly"] as? [String: AnyObject] {
                            if let data = hourly["data"] as? [AnyObject] {
                                if let hourNum = data[i] as? [String : AnyObject] {
                                    if let temperature = hourNum["temperature"] as? Double {
                                        hour.temp = temperature
                                    }
                                    if let icon = hourNum["icon"] as? String {
                                        hour.conditionImg = UIImage (named: icon)
                                    }
                                }
                            }
                        }
                        hourlyWeather.add(hour)
                    }
                
                    
                    //'daily' parent
                    //set up for loop here
                    for i in 0...6{
                        // 'day' object created
                        let day = DailyWeather()
                        
                        if let daily = json["daily"] as? [String : AnyObject] {
                            if let data = daily["data"] as? [AnyObject] {
                                if let dayNum = data[i] as? [String : AnyObject] {
                                    if let temperatureHigh = dayNum["temperatureHigh"] as? Double {
                                       
                                        if(i != 0) {
                                            day.high = temperatureHigh
                                        }
                                        else {
                                            currentWeather.high = temperatureHigh
                                        }
                                
                                    }
                                    if let temperatureLow = dayNum["temperatureLow"] as? Double {
                                        
                                        
                                        if(i != 0) {
                                            day.low = temperatureLow
                                        }
                                        else {
                                            currentWeather.low = temperatureLow
                                        }
                                        
                                    }
                                    if let icon = dayNum["icon"] as? String {
                                        
                                        if (i != 0){
                                            day.conditionImg = UIImage(named: icon)
                                        }
                                        
                                    }
                                }
                            }
                        }
                        if (i != 0) {
                            dailyWeather.add(day)
                        }
                    }
                    
                    

                    
                    if let _ = json["error"] {
                        self.exists = false
                    }
                    
                    DispatchQueue.main.async {
                        if self.exists{
                            
                            let isFah = (UserDefaults.standard.value(forKey: "chosenDegree") as? Int)

                            
                            self.currentTempLbl.isHidden = false
                            self.currentConditionLbl.isHidden = false
                            self.currentPic.isHidden = false
                            self.currentHighLbl.isHidden = false
                            self.currentLowLbl.isHidden = false
                            self.currentDayLbl.isHidden = false
                            self.todayLbl.isHidden = false
                            
                            self.currentConditionLbl.text = currentWeather.currentCondition
                            self.currentPic.image = currentWeather.currentImg
                            
                            
                            if (isFah == 0) {
                                let roundedHigh = lround(currentWeather.high)
                                let roundedLow = lround(currentWeather.low)
                                let roundedTemp = lround(currentWeather.currentTemp)
                                
                                self.currentHighLbl.text = roundedHigh.description
                                self.currentLowLbl.text = roundedLow.description
                                self.currentTempLbl.text = roundedTemp.description
                            }
                                
                                
                            else
                            {
                                let roundedHighCelsius = lround(currentWeather.highCelsius)
                                let roundedLowCelsius = lround(currentWeather.lowCelsius)
                                let roundedTempCelsius = lround(currentWeather.tempCelsius)
                                
                                self.currentHighLbl.text = roundedHighCelsius.description
                                self.currentLowLbl.text = roundedLowCelsius.description
                                self.currentTempLbl.text = roundedTempCelsius.description
                            }
                            
                            self.currentDayLbl.text = self.getDate()
                            
                            
                            self.hourlyForecastCollectionView.reloadData()
                            self.dailyForecastCollectionView.reloadData()

                            
                        } else{
                            self.currentTempLbl.isHidden = true
                            self.currentConditionLbl.isHidden = true
                            self.currentPic.isHidden = true
                            self.currentHighLbl.isHidden = true
                            self.currentLowLbl.isHidden = true
                            self.currentDayLbl.isHidden = true
                            self.todayLbl.isHidden = true
                            
                            
                            self.cityLbl.text = "No matching city"
                            self.exists = true
                            
                        }
         
                    }
                    
                } catch let jsonError {
                    print(jsonError.localizedDescription)
                }
                
                
                
                
                self.currentWeather = currentWeather
                self.dailyWeather = dailyWeather as! [DailyWeather]
                self.currentWeather.hourlyWeather = hourlyWeather as! [HourlyWeather]
                
                
                print("dailyWeather Array size: \(self.dailyWeather.count)")
                print("hourlyWeather Array size: \(self.currentWeather.hourlyWeather.count)")
                
                
                

            }
            

        }
        
        self.dailyForecastCollectionView.reloadData()
        self.hourlyForecastCollectionView.reloadData()

        
        task.resume()
        
    }
    
    
    

    
    
    
    
    
    
    //Arrays
    lazy var daysOfWeekArray : [String] = getDaysOfWeek()
    lazy var hoursOfDayArray : [String] = getHoursOfDay()
    
    
    
    
    //Collection view count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.hourlyForecastCollectionView {
            print("CV test: \(currentWeather.hourlyWeather.count)")
            print("CV test: \(dailyWeather.count)")

            
            if (currentWeather.hourlyWeather.count) != 0 {
                return (currentWeather.hourlyWeather.count)
            }
            else {
                return 0
            }

        }
        else{
            
            if dailyWeather.count != 0 {
                return dailyWeather.count
            }
            else {
                return 0
            }
            
            
        }

    }
    
    //Formatting cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.hourlyForecastCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCollectionViewCell", for: indexPath) as! HourlyCollectionViewCell
            
            
            
            cell.hourLbl.text = hoursOfDayArray[indexPath.row]
            cell.hourConditionImg.image = self.currentWeather.hourlyWeather[indexPath.row].conditionImg

            
            let isFah = (UserDefaults.standard.value(forKey: "chosenDegree") as? Int)
                if (isFah == 0) {
                let roundedDegree = lround(self.currentWeather.hourlyWeather[indexPath.row].temp)
                cell.hourDegreeLbl.text = roundedDegree.description
            }
                
                
            else
            {
                let roundedDegreeCelsius = lround(self.currentWeather.hourlyWeather[indexPath.row].tempCelsius)
                cell.hourDegreeLbl.text = roundedDegreeCelsius.description
            }
            
            
            return cell
        }
            
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyCollectionViewCell", for: indexPath) as! DailyCollectionViewCell
            
            
            cell.conditionImg.image = self.dailyWeather[indexPath.row].conditionImg
            cell.dayLbl.text = daysOfWeekArray[indexPath.row]

            
            let isFah = (UserDefaults.standard.value(forKey: "chosenDegree") as? Int)
            if (isFah == 0) {
                let roundedHigh = lround(self.dailyWeather[indexPath.row].high)
                cell.highLbl.text = roundedHigh.description
                let roundedLow = lround(self.dailyWeather[indexPath.row].low)
                cell.lowLbl.text = roundedLow.description

            }
                
                
            else
            {
                let roundedHighCelsius = lround(self.dailyWeather[indexPath.row].highCelsius)
                cell.highLbl.text = roundedHighCelsius.description
                let roundedLowCelsius = lround(self.dailyWeather[indexPath.row].lowCelsius)
                cell.lowLbl.text = roundedLowCelsius.description

            }
            
          
            return cell
            
        }
        
        
    }
    
    

    
    
    
    
    
//LAST BRACKET OF CLASS
}


