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
    var dailyWeather: DailyWeather?
    
    var usrTextField: UITextField?
    var currentDegreeF: Double!
    var currentCondition: String!
    var imgURL: String!
    var city: String!
    var highF : Double!
    var lowF : Double!
    
    var dayHigh : Double!
    var dayLow : Double!
    
    var highArray : [String] = ["", "", "", "", "", ""]
    var lat : Double = 0.00
    
    
    var zipCode : String = ""
    var exists: Bool = true
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hourlyForecastCollectionView.delegate = self
        dailyForecastCollectionView.delegate = self
        
        self.view.addSubview(hourlyForecastCollectionView)
        self.view.addSubview(dailyForecastCollectionView)
        
        forwardGeocoding(address: "45066")

        // Do any additional setup after loading the view.
    }
    
    //Converts a zipCode into latitude and longitude
    func forwardGeocoding(address: String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error!)
                return
            }
            if placemarks!.count > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                self.lat = coordinate!.latitude
                print("\nlat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
                
            }
        })
    }
    
    //gets TODAY'S date
    func getDate () -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.dateFormat = "EEEE"
        let dayString: String = dateFormatter.string(from: date)
        print("Current date is \(dayString)")
        return dayString
        
    }
    
    
    func getDaysOfWeek () -> Array<String> {
        
        var daysOfWeekArray : [String] = ["", "","", "","", ""] //array has 6
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.dateFormat = "EEEE"
        let dayString: String = dateFormatter.string(from: date)
        print(dayString)
        
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
    
    
    
    func getHoursOfDay () -> Array<String> {
        
        var hoursOfDayArray : [String] = ["", "","", "","", "", "", "", "", "", "", "","", "","", "", "", "", "", "", "", "","", ""] //array has 24
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.dateFormat = "h a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        let dayString: String = dateFormatter.string(from: date)
        print(dayString)
        
        for i in 1...10 {
            let nextDay = NSCalendar.current.date(byAdding: Calendar.Component.hour,
                                                  value: i-1,
                                                  to: date as Date)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "h a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            let dayString: String = dateFormatter.string(from: nextDay!)
            hoursOfDayArray[i-1] = dayString
        }
        
        return hoursOfDayArray
        
    }
    
    
    
    @IBAction func editBtnPressed(_ sender: Any) {
        locationAlert(title: "Edit Location", message: "Enter your postal code below.")
    }
    
    
    
    func locationAlert (title: String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField{ (textField: UITextField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "e.g. 32256"
        }
        
        
        
        let OKAction = UIAlertAction(title: "OK", style: .default)  {  _ in
            self.zipCode = alert.textFields?[0].text ?? ""
            print (self.zipCode)
            
            self.getCurrentWeather(zip: self.zipCode, day: 0)
            self.highArray = self.getDailyWeather(zip: self.zipCode)
            print (self.highArray)
            
        }
        
        
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)

    }
    
    
    
    @IBAction func testBtnPressed(_ sender: Any) {
        print ("Test print #2 ----- \(zipCode)")
        print ("Did this work ---- \(city)")
        //print("Did this work ------ \(currentWeather?.location)")
        print("Did this work ------ \(lat)")


    }
    
    
    

    //Gets current weather data
    func getCurrentWeather(zip:String, day: Int) {
        
        let urlRequest = URLRequest(url: URL(string: "http://api.apixu.com/v1/forecast.json?key=57fbd314643d4439b5e23413182306&days=10&q=\(zip)")!)
        
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data,response, error) in
            if error == nil{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                    
                    //current parent
                    if let current = json["current"] as? [String : AnyObject] {
                    
                        
                        if let temp = current["temp_f"] as? Double {
                            self.currentDegreeF = temp
                            
                        }
                        if let condition = current["condition"] as? [String : AnyObject] {
                            self.currentCondition = condition["text"] as! String
                            let icon = condition["icon"] as! String
                            self.imgURL = "http:\(icon)"
                        }
                        
                    }
                    //location parent
                    if let location = json["location"] as? [String: AnyObject] {
                        self.city = location["name"] as! String
                        self.currentWeather?.location = location["name"] as! String
                    }
                    
                    //forecast parent
                    if let forecast = json["forecast"] as? [String : AnyObject] {
                        
                        if let forecastday = forecast["forecastday"] as? [AnyObject] {
                            if let day0 = forecastday[day] as? [String : AnyObject] {
                                if let day = day0["day"] as? [String : AnyObject] {
                                    if let maxtemp_f = day["maxtemp_f"] as? Double {
                                        self.highF = maxtemp_f
                                        self.dailyWeather?.high = maxtemp_f
                                        
                                    }
                                    if let mintemp_f = day["mintemp_f"] as? Double{
                                        self.lowF = mintemp_f
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
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
                            
                            
                            
                            self.currentTempLbl.text = "\(self.currentDegreeF.description)°"
                            self.cityLbl.text = self.city
                            self.currentConditionLbl.text = self.currentCondition
                            self.currentPic.downloadImage(from: self.imgURL!)
                            
                            self.currentHighLbl.text = "\(self.highF.description)°"
                            self.currentLowLbl.text = "\(self.lowF.description)°"
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
            }
            
        }
        
        task.resume()
        print ("Test print ----- \(zipCode)")
        
        let weekDay = DailyWeather.init(conditionImg: #imageLiteral(resourceName: "cloudy"), high: 22.21, low: 22.22, dayOfWeek: "Tuesday")
        print(weekDay)
        

    }
    
    
    //get daily weather data test (needs pic, high&low)
    
    func getDailyWeather(zip:String) -> Array <String> {
        var arrayOfHigh : [String] = ["a", "", "", "", "", ""]

        
        
            
        let urlRequest = URLRequest(url: URL(string: "http://api.apixu.com/v1/forecast.json?key=57fbd314643d4439b5e23413182306&days=10&q=\(zip)")!)
        
        
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data,response, error) in
            if error == nil{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                    
                    
                    //forecast parent
                    if let forecast = json["forecast"] as? [String : AnyObject]{
                        
                        if let forecastday = forecast["forecastday"] as? [AnyObject] {
                           
                            for i in 1...6 {
                            
                                if let day0 = forecastday[i] as? [String : AnyObject] {
                                    
                                    if let day = day0["day"] as? [String : AnyObject] {
                                        
                                        if let maxtemp_f = day["maxtemp_f"] as? Double {
                                            print (maxtemp_f.description)
                                            arrayOfHigh[i-1] = maxtemp_f.description
                                        }
                                        
                                    }
                                    
                                }
                            }
                                
                            
                            
                          
                            
                        }
                        
                    }
                    
                    if let _ = json["error"] {
                        self.exists = false
                    }
                    
                    DispatchQueue.main.async {
                        if self.exists{
                            
                         print ("yay")

                            
                        } else{
                            
                            self.cityLbl.text = "No matching city"
                            self.exists = true
                            
                        }
                    }
                    
                } catch let jsonError {
                    print(jsonError.localizedDescription)
                }
            }
            

        }
        
        task.resume()
        print("Array of high ---- \(arrayOfHigh)")
        return arrayOfHigh

        
    }

    
    //Test image array
    var imgArray = [UIImage (named: "cloudy"), UIImage (named: "cloudy"), UIImage (named: "cloudy"), UIImage (named: "cloudy"), UIImage (named: "cloudy"), UIImage (named: "cloudy"), UIImage (named: "cloudy")]
    
    lazy var daysOfWeekArray : [String] = getDaysOfWeek()
    lazy var hoursOfDayArray : [String] = getHoursOfDay()

    
    
    //Collection view count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.hourlyForecastCollectionView {
            return 10
        }
        else{
            return 6
            
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
            cell.conditionImg.image = imgArray[indexPath.row]
            cell.dayLbl.text = daysOfWeekArray[indexPath.row]
            
            
            //let hourlyweather = self.hourlyWeatherArray[indexPath.row]
            //cell.conditionImg = hourlyweather.conditionImg
          
            return cell
            
        }
        
        
    }
    
    

    
    
    
    
    
//LAST BRACKET OF CLASS
}
















extension UIImageView {
    func downloadImage(from url: String){
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest)  { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async{
                    self.image = UIImage(data: data!)
                }
            }
            }
        task.resume()
    }
    
    
}
