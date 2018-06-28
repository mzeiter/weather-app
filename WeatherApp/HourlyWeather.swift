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
    
    var temp : String!
    var conditionImg : UIImage?
    var hour : Int! //not found in JSON

    
    
    convenience init (temp: String, conditionImg: UIImage ,hour : Int) {
        self.init()
        
        self.temp = temp
        self.conditionImg = conditionImg
        self.hour = hour 

        
    }
    
    
    
}
