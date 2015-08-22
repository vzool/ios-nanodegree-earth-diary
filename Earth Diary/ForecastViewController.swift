//
//  ForecastViewController.swift
//  Earth Diary
//
//  Created by Abdelaziz Elrashed on 8/21/15.
//  Copyright (c) 2015 Abdelaziz Elrashed. All rights reserved.
//

import UIKit

class ForecastViewController: UIViewController {
    
    var pin:Pin!
    var forcast:Forecast!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDirectionLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.title = "Todays Forecasts"

        if let pin = pin{
            
            let fc = pin.forecasts[0]
            
            tempLabel.text = "\(fc.temp)"
            maxTempLabel.text = "\(fc.temp_max)"
            minTempLabel.text = "\(fc.temp_min)"
            humidityLabel.text = "\(fc.humidity)"
            pressureLabel.text = "\(fc.pressure)"
            windSpeedLabel.text = "\(fc.wind_speed)"
            windDirectionLabel.text = "\(fc.wind_direction)"
            createdDateLabel.text = "\(fc.created_date)"
        }
        
        if let fc = forcast{
            
            tempLabel.text = "\(fc.temp)"
            maxTempLabel.text = "\(fc.temp_max)"
            minTempLabel.text = "\(fc.temp_min)"
            humidityLabel.text = "\(fc.humidity)"
            pressureLabel.text = "\(fc.pressure)"
            windSpeedLabel.text = "\(fc.wind_speed)"
            windDirectionLabel.text = "\(fc.wind_direction)"
            createdDateLabel.text = "\(fc.created_date)"
            
            navigationItem.title = "Forecasts Details"
        }
    }
}
