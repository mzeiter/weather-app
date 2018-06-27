//
//  CurrentWeather.swift
//  WeatherApp
//
//  Created by Mitchell Zeiter on 6/26/18.
//  Copyright © 2018 Mitchell Zeiter. All rights reserved.
//

import UIKit
import Foundation


class CurrentWeather: NSObject {
    
    var currentTemp : Double!
    var currentImg : UIImage?
    var currentCondition : String!
    var location : String! //not found in JSON
    var hourlyWeather: [HourlyWeather] = []

    
    convenience init (currentTemp: Double, currentImg: UIImage, currentCondition: String, location: String) {
        
        self.init()
        
        self.currentTemp = currentTemp
        self.currentImg = currentImg
        self.currentCondition = currentCondition
        self.location = location
        
    }

    
}
