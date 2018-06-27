//
//  DailyWeather.swift
//  WeatherApp
//
//  Created by Mitchell Zeiter on 6/26/18.
//  Copyright © 2018 Mitchell Zeiter. All rights reserved.
//

import UIKit
import Foundation


class DailyWeather: NSObject {
    
    var conditionImg : UIImage?
    var high : Double?
    var low : Double?
    var dayOfWeek : String!  //not found in JSON
    
    convenience init (conditionImg: UIImage, high: Double, low: Double, dayOfWeek : String) {
        self.init()
        
        self.conditionImg = conditionImg
        self.high = high
        self.low = low
        self.dayOfWeek = dayOfWeek
        
    }
    
    
}
