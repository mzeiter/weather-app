//
//  HourlyWeather.swift
//  WeatherApp
//
//  Created by Mitchell Zeiter on 6/26/18.
//  Copyright © 2018 Mitchell Zeiter. All rights reserved.
//

import UIKit
import Foundation


class HourlyWeather: NSObject {
    
    var temp : Double!
    {
        didSet {
            tempCelsius = ((temp - 32) * (5/9))
        }
    }
    var tempCelsius : Double!
    var conditionImg : UIImage?
    var hour : Int! //not found in JSON

    
    
    convenience init (temp: Double, conditionImg: UIImage, hour: Int, tempCelsius: Double) {
        self.init()
        
        self.temp = temp
        self.conditionImg = conditionImg
        self.hour = hour
        self.tempCelsius = tempCelsius

        
    }
    
    
    
}
