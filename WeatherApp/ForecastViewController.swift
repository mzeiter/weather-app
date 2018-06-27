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




class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
   
    
    
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
    
    
    var currentWeather: CurrentWeather?
    var dailyWeather: [DailyWeather] = []
        
    var lat : Double = 0.00
    var long : Double = 0.00
    var zipCode : String = ""
    var exists: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hourlyForecastCollectionView.delegate = self
        dailyForecastCollectionView.delegate = self
        
        self.view.addSubview(hourlyForecastCollectionView)
        self.view.addSubview(dailyForecastCollectionView)
        
        //forwardGeocoding(address: "45066")

        // Do any additional setup after loading the view.
    }
    
    
    //Converts a zipcode into latitude and longitude

    func forwardGeocoding(zipcode: String) {
        CLGeocoder().geocodeAddressString(zipcode, completionHandler: { (placemarks, error) in
            
            let currentWeather = CurrentWeather()
            if error != nil {
                print(error!)
                return
            }
            if placemarks!.count > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                self.lat = coordinate!.latitude
                self.long = coordinate!.longitude
                
                if let placemark = placemarks?[0] {
                    
                    let city = placemark.addressDictionary!["City"] as? String

                    currentWeather.location = city
                    print (city!)
                    
                }
                
                print("\nlat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
                
            }
        })
    }
    
    //Converts Fahrenheit temp to Celsius    
    func convertToCelsius(fahrenheit: Int) -> Int {
        return Int(5.0 / 9.0 * (Double(fahrenheit) - 32.0))
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
    
    
    //Gets 24 hours starting with current time
    func getHoursOfDay () -> Array<String> {
        
        var hoursOfDayArray : [String] = ["", "","", "","", "", "", "", "", "", "", "","", "","", "", "", "", "", "", "", "","", ""] //array has 24
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
       
        for i in 1...24 {
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
            print (self.zipCode)
            
            self.forwardGeocoding(zipcode: self.zipCode)
            

            self.getCurrentWeather(lat : self.lat, long: self.long)
            
            
        }
        
        
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)

    }
    
    
    
    
    //Test button to check values of vars
    @IBAction func testBtnPressed(_ sender: Any) {
        let fahrenheitBool = SettingsViewController()
        
        print ("Test print zip ----- \(zipCode)")
        print("Did this work lat ------ \(lat.description)")
        print("STATUS Test ------\(fahrenheitBool.fahrenheit)")
    }
    
    
    
    

    //Gets current weather data
    func getCurrentWeather(lat: Double, long: Double) {
        
        let urlRequest = URLRequest(url: URL(string: "https://api.darksky.net/forecast/382765538514b141e907ccb338fac67c/\(lat)" + ",\(long)")!)
        
        print ("-----url-----\(urlRequest)")
        let task = URLSession.shared.dataTask(with: urlRequest) { (data,response, error) in
            
            if error == nil{
                
                let currentWeather = CurrentWeather()
                let dailyWeather = NSMutableArray()
                let hourlyWeather = NSMutableArray()
                //^ set = to themselves at end of this ^
                
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
                    for i in 0...5{
                        // 'day' object created
                        let day = DailyWeather()
                        
                        if let daily = json["daily"] as? [String : AnyObject] {
                            if let data = daily["data"] as? [AnyObject] {
                                if let dayNum = data[i] as? [String : AnyObject] {
                                    if let temperatureHigh = dayNum["temperatureHigh"] as? Double {
                                        day.high = temperatureHigh
                                    }
                                    if let temperatureLow = dayNum["temperatureLow"] as? Double {
                                        day.low = temperatureLow
                                    }
                                    if let icon = dayNum["icon"] as? String {
                                        day.conditionImg = UIImage(named: icon)
                                    }
                                }
                            }
                        }
                        
                        dailyWeather.add(day)
                    }
                    

                    
                    if let _ = json["error"] {
                        self.exists = false
                    }
                    
                    DispatchQueue.main.async {
                        if self.exists{
                            self.currentTempLbl.isHidden = false
                            self.currentConditionLbl.isHidden = false
                            self.currentPic.isHidden = false
                            self.currentHighLbl.isHidden = false
                            self.currentLowLbl.isHidden = false
                            self.currentDayLbl.isHidden = false
                            self.todayLbl.isHidden = false
                            
                                                    
                            self.currentTempLbl.text = "\(currentWeather.currentTemp.description)°"
                            self.cityLbl.text = currentWeather.location
                            self.currentConditionLbl.text = currentWeather.currentCondition
                            self.currentPic.image = currentWeather.currentImg
                            
                            
                            //self.currentHighLbl.text = "\(self.highF.description)°"
                            //self.currentLowLbl.text = "\(self.lowF.description)°"
                            self.currentDayLbl.text = self.getDate()
                            
                            
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
                
                //how to set hourly to itself
                self.currentWeather?.hourlyWeather = hourlyWeather as! [HourlyWeather]
                
            }
            
        }
        
        task.resume()
        print ("Test print ----- \(zipCode)")
        

    }
    
    
    

    
    
    
    
    
    
    //Arrays
    lazy var daysOfWeekArray : [String] = getDaysOfWeek()
    lazy var hoursOfDayArray : [String] = getHoursOfDay()
    
    
    
    
    //Collection view count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.hourlyForecastCollectionView {
            return hoursOfDayArray.count
        }
        else{
            return daysOfWeekArray.count
            
        }

    }
    
    //Formatting cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.hourlyForecastCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCollectionViewCell", for: indexPath) as! HourlyCollectionViewCell
            
            cell.hourLbl.text = hoursOfDayArray[indexPath.row]
            
            return cell
        }
            
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyCollectionViewCell", for: indexPath) as! DailyCollectionViewCell
            
            cell.dayLbl.text = daysOfWeekArray[indexPath.row]
            
            //let dailyWeather = DailyWeather ()
            
            let dailyWeather: [DailyWeather]
            
            // how do i access a value from an object in an array ?
            //cell.highLbl.text = dailyWeather[indexPath.row]

            //let hourlyweather = self.hourlyWeatherArray[indexPath.row]
            //cell.conditionImg = hourlyweather.conditionImg
            
          
            return cell
            
        }
        
        
    }
    
    

    
    
    
    
    
//LAST BRACKET OF CLASS
}


