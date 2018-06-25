//
//  SettingsViewController.swift
//  WeatherApp
//
//  Created by Mitchell Zeiter on 6/25/18.
//  Copyright © 2018 Mitchell Zeiter. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var iconsBtn: UIButton!
    @IBOutlet weak var apixuBtn: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBAction func tappedToChangeView(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func apixuBtnPressed(_ sender: Any) {
        
        if let url = URL(string: "http://www.apixu.com") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func iconsBtnPressed(_ sender: Any) {
        if let url = URL(string: "http://www.icons8.com") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
}
