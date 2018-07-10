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
    @IBOutlet weak var fahrenheitControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if let value = UserDefaults.standard.value(forKey: "chosenDegree"){
            let selectedIndex = value as! Int
            print(selectedIndex)
            fahrenheitControl.selectedSegmentIndex = selectedIndex
        }


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
    

    @IBAction func controlChanged(_ sender: UISegmentedControl) {
        
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "chosenDegree")
        UserDefaults.standard.synchronize()

    }
    
    @IBAction func tappedToChangeView(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    

}
