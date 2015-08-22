//
//  AnalyzeViewController.swift
//  Earth Diary
//
//  Created by Abdelaziz Elrashed on 8/21/15.
//  Copyright (c) 2015 Abdelaziz Elrashed. All rights reserved.
//

import UIKit
import Charts

class AnalyzeViewController: UIViewController {

    var pin:Pin!
    
    @IBOutlet weak var chart: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Chart Analyzer"
        
        var yVals = [ChartDataEntry]()
        
        for var i = 0; i < pin.forecasts.count; i++ {
            let fc = pin.forecasts[i]
            yVals.append(ChartDataEntry(value: fc.temp.doubleValue, xIndex: i))
        }
        
        var dataSet = LineChartDataSet(yVals: yVals)
        
        dataSet.label = "Temp"
        dataSet.lineWidth = 3.5
        var data = LineChartData(xVals: [-10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100], dataSet: dataSet)
        
        chart.data = data
        
        chart.animate(xAxisDuration: 2.5)
    }
}
