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
    
    var currentTemp : String!
    var currentImg : UIImage?
    var currentCondition : String!
    var location : String! //not found in JSON
    var high : String!
    var low : String!
    var today : String!
    
    var hourlyWeather: [HourlyWeather] = []

    
    convenience init (currentTemp: String, currentImg: UIImage, currentCondition: String, location: String, high: String, low: String, today: String) {
        
        self.init()
        
        self.currentTemp = currentTemp
        self.currentImg = currentImg
        self.currentCondition = currentCondition
        self.location = location
        
        self.high = high
        self.low = low
        self.today = today
        
    }

    
}
