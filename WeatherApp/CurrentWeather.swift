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
    {
        didSet {
            tempCelsius = ((currentTemp - 32) * (5/9))
        }
    }
    var tempCelsius : Double!
    
    var currentImg : UIImage?
    var currentCondition : String!
    var location : String = ""       //not found in JSON
    var high : Double!
    {
        didSet {
            highCelsius = ((high - 32) * (5/9))
        }
    }
    var highCelsius : Double!
    var low : Double!
    {
        didSet {
            lowCelsius = ((low - 32) * (5/9))
        }
    }
    var lowCelsius : Double!
    var today : String!
    
    var hourlyWeather: [HourlyWeather] = []

    
    convenience init (currentTemp: Double, currentImg: UIImage, currentCondition: String, location: String, high: Double, low: Double, today: String, lowCelsius: Double, highCelsius: Double, tempCelsius: Double) {
        
        self.init()
        
        self.currentTemp = currentTemp
        self.currentImg = currentImg
        self.currentCondition = currentCondition
        self.location = location
        
        self.high = high
        self.low = low
        self.today = today
        
        self.lowCelsius = lowCelsius
        self.highCelsius = highCelsius
        self.tempCelsius = tempCelsius
        
    }

    
}
