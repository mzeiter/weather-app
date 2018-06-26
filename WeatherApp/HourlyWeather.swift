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
    
    var temp : CGFloat!
    var conditionImg : UIImage?
    
    init (temp: CGFloat, conditionImg: UIImage) {
        
        self.temp = temp
        self.conditionImg = conditionImg
        
    }
    
    
}
