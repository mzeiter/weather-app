//
//  ViewController.swift
//  WeatherApp
//
//  Created by Mitchell Zeiter on 6/22/18.
//  Copyright © 2018 Mitchell Zeiter. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var imgArray = [UIImage (named: "cloudy"), UIImage (named: "cloudy"), UIImage (named: "cloudy"), UIImage (named: "cloudy"), UIImage (named: "cloudy"), UIImage (named: "cloudy"), UIImage (named: "cloudy")]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyCollectionViewCell", for: indexPath) as! DailyCollectionViewCell
        cell.conditionImg.image = imgArray[indexPath.row]
        
        return cell
    }
    
    
    @IBOutlet weak var todayLbl: UILabel!
    @IBOutlet weak var currentDayLbl: UILabel!
    @IBOutlet weak var currentHighLbl: UILabel!
    @IBOutlet weak var currentLowLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var currentTempLbl: UILabel!
    @IBOutlet weak var currentConditionLbl: UILabel!
    @IBOutlet weak var currentPic: UIImageView!
    @IBOutlet weak var hourForecastCollectionView: UICollectionView!
    @IBOutlet weak var dailyForecastCollectionView: UICollectionView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    
    var usrTextField: UITextField?
    var currentDegreeF: Double!
    var currentCondition: String!
    var imgURL: String!
    var city: String!
    var highF : Double!
    var lowF : Double!
    var exists: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        locationAlert(title: "Edit Location", message: "Enter your postal code below.")
    }
    
    
    func getDate () -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let tomorrow = NSCalendar.current.date(byAdding: Calendar.Component.day, //Here you can add year, month, hour, etc.
            value: 1,  //Here you can add number of units
            to: date as Date)

        dateFormatter.dateFormat = "EEEE"
        let dayString: String = dateFormatter.string(from: date)
        print("Current date is \(dayString)")
        return dayString

        
        
        
    }
    
    
    func locationAlert (title: String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField{ (textField: UITextField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "e.g. 32256"
        }
        
        let OKAction = UIAlertAction(title: "OK", style: .default) {  _ in
            let zip = alert.textFields?[0].text ?? ""
            print (zip)
            
            self.getDailyWeather(zip: zip, day: 0)
            
        }
        alert.addAction(OKAction)
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    
    
    
    //day of week, picture, high&low
    func getDailyWeather(zip:String, day: Int) {
        
        
        
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
                    }
                    
                    //forecast parent
                    if let forecast = json["forecast"] as? [String : AnyObject]{
                        print("test1")
                        
                        if let forecastday = forecast["forecastday"] as? [AnyObject] {
                            print("test 2")
                            if let day0 = forecastday[0] as? [String : AnyObject] {
                                print("test 3")
                                if let day = day0["day"] as? [String : AnyObject] {
                                    print ("test 4")
                                    if let maxtemp_f = day["maxtemp_f"] as? Double {
                                        self.highF = maxtemp_f
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
                            
                            
                            self.cityLbl.text = "No matching city found"
                            self.exists = true
                            
                        }
                    }
                    
                } catch let jsonError {
                    print(jsonError.localizedDescription)
                }
            }
            
        }
        
        task.resume()
        
        
    }

    
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
