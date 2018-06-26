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
    var currentImg : UIImageView?
    var currentCondition : String!
    var location : String!
    
    init (currentTemp: Double, currentImg: UIImageView, currentCondition: String, location: String) {
        
        self.currentTemp = currentTemp
        self.currentImg = currentImg
        self.currentCondition = currentCondition
        self.location = location
        
    }

    
}
